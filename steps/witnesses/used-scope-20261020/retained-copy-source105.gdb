set pagination off
set confirm off
python
import gdb
records=[]
active=[]
keys=('schema','layout','method','place','path','origin','origin_count','origin_method')
def word(pointer):
    if not pointer:
        return ''
    obj=pointer.dereference()
    return gdb.selected_inferior().read_memory(obj['data'],int(obj['length'])).tobytes().decode('utf-8')
def state(pointer):
    item=pointer.dereference()
    return tuple(int(item[k]) for k in keys)
class Built(gdb.FinishBreakpoint):
    def __init__(self,res):
        super().__init__(gdb.newest_frame(),internal=True)
        self.res=res
        self.saved=None
        active.append(self)
    def stop(self):
        if self in active:
            active.remove(self)
        if self.saved is None or int(self.return_value):
            return False
        source=gdb.parse_and_eval('l2_mres_source')[self.res]
        now=tuple(int(source[k]) for k in keys)
        path=source['path']
        geometry=None
        if path:
            f=path.dereference();p=f['resolved']
            geometry=tuple(int(x) for x in (f['stage'],f['source_use'],p['n'],p['names'],p['indexed'],p['steps'],p['run_count'],p['names_run']))
        link=int(gdb.parse_and_eval('l2_mres_from')[self.res])
        records.append((self.saved,now,geometry,link))
        print('COPY105 retained=%s geometry=%s own-copy-link=%d source=%s'%(self.saved==now,geometry,link,source))
        return False
class Build(gdb.Breakpoint):
    def stop(self):
        res=int(gdb.parse_and_eval('res'))
        own=int(gdb.parse_and_eval('l2_mres_own')[res])
        if word(gdb.parse_and_eval('l2_own_name')[own])=='copy':
            Built(res)
        return False
class Queried(gdb.FinishBreakpoint):
    def __init__(self,out,built):
        super().__init__(gdb.newest_frame(),internal=True)
        self.out=out;self.built=built
    def stop(self):
        if not int(self.return_value):
            self.built.saved=state(self.out)
        return False
class Query(gdb.Breakpoint):
    def stop(self):
        if not active or int(gdb.parse_and_eval('n'))!=1:
            return False
        out=gdb.parse_and_eval('out')
        built=active[-1]
        target=gdb.parse_and_eval('l2_mres_source')+built.res
        if int(out)==int(target):
            Queried(out,built)
        return False
Build('l2_mrs_build',internal=True)
Query('l2_reference_source',internal=True)
end
run
python
if not records:
    raise gdb.GdbError('No completed actual copy source record')
lost=sum(a!=b for a,b,geom,link in records)
bound=sum(geom is not None for a,b,geom,link in records)
print('COPY105 actual completed copies=%d;changed-query-results=%d;retained-facts=%d'%(len(records),lost,bound))
expect_loss=int(gdb.parse_and_eval('$expect_loss'))
if expect_loss:
    if lost<1:
        raise gdb.GdbError('The unchanged104 control did not expose its source erasure')
else:
    if lost or not bound:
        raise gdb.GdbError('The copy consumer still discards the exact source query')
    for a,b,geom,link in records:
        if geom is not None and geom!=(0,2,0,0,0,0,0,0):
            raise gdb.GdbError('A whole binding was promoted into field permission')
        place=b[keys.index('place')]
        if place<=-2 and link!=-2-place:
            raise gdb.GdbError('Body copy chain does not consume the canonical own key')
print('COPY105 read-only compiler observation complete;no runtime value/map correction claimed.')
end
