"""Run 19 bounded Python scenarios and their declared companion modules.

Needs Python 3.10+. Companion IDs are resolved from implementation_ids so the
script remains valid after archive renumbering. No network or real database is
used; the receipt records exact source hashes and the test boundary.
"""
from pathlib import Path
from types import ModuleType, SimpleNamespace
import copy,datetime,hashlib,json,sys
PATTERNS_PATH=Path(__file__).with_name('patterns.json')
SOURCE_BYTES=PATTERNS_PATH.read_bytes()
DATA=json.loads(SOURCE_BYTES)
BY_ID={p['id']:p for p in DATA['patterns']}
ORIGINAL_IDS=list(range(16,35))
MODULE_NAMES={16:'lookup',31:'specification',32:'money'}
COMPANIONS={}
def source_code(pattern):
    return next(l['code'] for l in pattern['listings'] if l['language']=='Python')
def source_hash(code):
    return hashlib.sha256(code.encode('utf-8')).hexdigest()
def load_module(name,code):
    module=ModuleType(name)
    sys.modules[name]=module
    exec(compile(code,name+'.py','exec'),module.__dict__)
    return module
for usage_id,module_name in MODULE_NAMES.items():
    usage=BY_ID[usage_id]
    implementation_ids=usage.get('implementation_ids',[])
    assert len(implementation_ids)==1,('expected one declared companion',usage_id)
    implementation_id=implementation_ids[0]
    implementation=BY_ID[implementation_id]
    assert implementation.get('kind')=='implementation'
    assert usage_id in implementation.get('usage_ids',[])
    code=source_code(implementation)
    load_module(module_name,code)
    COMPANIONS[implementation_id]={
        'id':implementation_id,
        'language':'Python',
        'module':module_name,
        'usage_ids':implementation['usage_ids'],
        'source_sha256':source_hash(code),
        'check':'exact companion source loaded and exercised by its client scenarios',
        'result':'pass',
    }
RESULTS=[]
def failed(fn,exception=Exception):
    try: fn()
    except exception: return
    raise AssertionError('expected failure')
class Db:
    def __init__(self): self.values={1:100,2:20};self.calls=[];self.fail=False
    def upsert(self,id,cents):
        if self.fail and id==9: raise RuntimeError('injected write failure')
        self.values[id]=cents;self.calls.append((id,cents))
    def atomic(self,body):
        old=copy.deepcopy(self.values)
        try: return body()
        except Exception:
            self.values=old
            raise
    def read_locked(self,id): return self.values[id]
    def write(self,id,value): self.values[id]=value
for i in ORIGINAL_IDS:
    p=BY_ID[i]
    code=source_code(p)
    n=load_module(f'pattern_{i}',code).__dict__
    if i==16:
        a,b=n['Account'](7,100),n['Account'](9,250);r=n['Repository']([a,b])
        assert r.find(9) is b and r.find(10) is None
        duplicate=n['Account'](7,999)
        assert n['Repository']([a,duplicate]).find(7) is a
        assert n['Repository']([]).find(7) is None
        class NeverRead:
            @property
            def id(self): raise AssertionError('search continued after first match')
        assert n['Repository']([a,NeverRead()]).find(7) is a
    elif i==17:
        db=Db();w=n['UnitOfWork'](db)
        w.mark(7,120);w.mark(7,130);w.mark(9,200)
        assert db.calls==[]
        w.flush();assert db.calls==[(7,130),(9,200)] and not w.dirty
        w.mark(7,999);w.mark(9,999);old=db.values.copy();db.fail=True
        failed(w.flush,RuntimeError);assert db.values==old and w.dirty=={7:999,9:999}
    elif i==18:
        rows={7:[7,1250]}
        port=SimpleNamespace(read=lambda id:rows[id],write=lambda id,cents:rows.__setitem__(id,[id,cents]))
        m=n['Mapper'](port);a=m.load(7);assert (a.id,a.cents)==(7,1250)
        a.cents=1300;m.save(a);assert rows[7]==[7,1300]
    elif i==19:
        db=Db();a=n['Account'](db);a.debit(30);a.save()
        failed(lambda:a.debit(80),ValueError);assert a.cents==70 and db.calls==[(7,70)]
    elif i==20:
        calls=[]
        port=SimpleNamespace(scalar=lambda *x:(calls.append(x),100)[1],execute=lambda *x:(calls.append(x),1)[1])
        a=n['Accounts'](port);assert a.balance(7)==100 and a.update(9,200)==1
        assert calls[0][1:]==(7,) and calls[1][1:]==(200,9)
    elif i==21:
        calls=[];port=SimpleNamespace(execute=lambda *x:(calls.append(x),1)[1])
        a=n['RowGateway'](port,7,100);a.cents=150;assert a.update()==1 and calls[0][1:]==(150,7)
    elif i==22:
        port=SimpleNamespace(scalar=lambda sql,id:100)
        assert n['read'](n['DbDao'](port),7)==100 and n['read'](n['FixedDao'](),7)==25
    elif i==23:
        result=n['export'](SimpleNamespace(id=7,cents=1250,token='secret'))
        assert vars(result)=={'id':7,'cents':1250}
    elif i==24:
        a=n['Account']();assert a.debit(30)==70
        failed(lambda:a.debit(80),ValueError);assert a.balance==70
    elif i==25:
        db=Db();n['transfer'](db,1,2,30);assert db.values=={1:70,2:50}
        failed(lambda:n['transfer'](db,1,2,200),ValueError);assert db.values=={1:70,2:50}
    elif i==26:
        rows=[{'quantity':2,'price':10},{'quantity':3,'price':7}]
        assert n['OrderTable'](rows).total()==41
    elif i==27:
        calls=[]
        class Account:
            def debit(self,amount):
                calls.append(('debit',amount))
                if amount>100: raise ValueError('funds')
        repo=SimpleNamespace(load=lambda id:(calls.append(('load',id)),Account())[1],save=lambda a:calls.append(('save',)))
        n['checkout'](Db(),repo,7,30);assert calls==[('load',7),('debit',30),('save',)]
        calls.clear();failed(lambda:n['checkout'](Db(),repo,7,200),ValueError)
        assert calls==[('load',7),('debit',200)]
    elif i==28:
        calls=[];s=n['Session'](lambda id:(calls.append(id),object())[1])
        a,b,c=s.get(7),s.get(7),s.get(9)
        assert a is b and a is not c and calls==[7,9]
    elif i==29:
        calls=[];h=n['Holder'](lambda:(calls.append(1),0)[1])
        assert h.get()==0 and h.get()==0 and len(calls)==1
        def retry_load():
            calls.append(1)
            if len(calls)==2: raise ValueError('temporary')
            return 0
        h=n['Holder'](retry_load);failed(h.get,ValueError);assert not h.loaded and h.get()==0
    elif i==30:
        calls=[]
        db=SimpleNamespace(query=lambda sql,a,b:(calls.append((sql,a,b)),[x for x in [99,100,200,201] if a<=x<=b])[1])
        assert n['RangeQuery'](100,200).execute(db)==[100,200]
        failed(lambda:n['RangeQuery'](200,100).execute(db),ValueError);assert len(calls)==1
    elif i==31:
        f=n['build']();assert [f(x) for x in [-1,50,100]]==[False,True,False]
        calls=[];f=n['both'](lambda x:False,lambda x:calls.append(x));assert not f(1) and not calls
        nested=n['both'](n['build'](),lambda x:x%2==0)
        assert [nested(x) for x in [50,51,-2]]==[True,False,False]
        assert nested(50) and nested(50)
    elif i==32:
        a,b,c=n['Money'](100,840),n['Money'](100,840),n['Money'](100,978)
        assert n['same'](a,b) and a is not b and not n['same'](a,c)
        assert n['demo']()==10
        failed(lambda:setattr(a,'cents',9),AttributeError)
        failed(lambda:setattr(a,'currency',9),AttributeError)
        assert not hasattr(a,'__dict__')
        def overwrite_component(): a[0]=9
        failed(overwrite_component,TypeError)
    elif i==33:
        state={'version':4,'cents':100}
        def cas(id,version,cents):
            if id!=7 or version!=state['version']: return 0
            state.update(version=version+1,cents=cents);return 1
        db=SimpleNamespace(compare_and_set=cas);n['save'](db,7,4,120)
        failed(lambda:n['save'](db,7,4,150),RuntimeError)
        assert state=={'version':5,'cents':120}
    elif i==34:
        active={};version=[40];saved=[]
        def reserve(id,session):
            if id in active:return 0
            version[0]+=1;active[id]=(session,version[0]);return version[0]
        def release(id,session,token):
            if active.get(id)!=(session,token):return 0
            del active[id];return 1
        def write(id,session,token,cents):
            if active.get(id)!=(session,token):return 0
            saved.append(cents);return 1
        e=n['Edit'](SimpleNamespace(reserve=reserve,release=release),SimpleNamespace(write_with_lease=write))
        assert e.acquire(7,1)==41 and e.acquire(7,2)==0
        assert e.release(7,1,41)==1 and e.acquire(7,2)==42
        assert e.save(7,1,41,99)==0 and e.save(7,2,42,150)==1 and saved==[150]
    RESULTS.append({'id':i,'language':'Python','source_sha256':source_hash(code),'implementation_ids':p.get('implementation_ids',[]),'check':'bounded scenario with explicit in-memory fixtures','result':'pass'})
assert len(RESULTS)==19
report={
    'engine':sys.version.split()[0],
    'review_time_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'input':'patterns.json',
    'input_sha256':hashlib.sha256(SOURCE_BYTES).hexdigest(),
    'harness':'validate_python.py',
    'harness_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'original_scenarios':19,
    'companion_modules_exercised':len(COMPANIONS),
    'all_passed':True,
    'scope':'Python controls and the exact declared companion implementations only. Fixtures validate bounded client/helper logic, first-match identity/absence/early return, reusable predicate short-circuiting, and Money read-only components. In-memory fixtures do not validate real database, transaction, lock, HTTP, Message or transport providers. LMX and C# were not executed.',
    'checks':RESULTS,
    'companions':[COMPANIONS[i] for i in sorted(COMPANIONS)],
}
Path(__file__).with_name('python_validation.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(report,ensure_ascii=False))
