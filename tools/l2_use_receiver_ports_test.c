/* Actual frontend receiver projection; no substitute parser or flow closure. */
#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_use_ports_test_frontend_main
#include L2_FRONTEND_SOURCE
#undef main

static int checks, failures;
static void expect(int good, const char *what)
{
    ++checks;
    if (!good) { ++failures; fprintf(stderr, "FAIL %s\n", what); }
}
int main(void)
{
    LmP0Text a={0},b={0},c={0},d={0},e={0},f={0},g={0},h={0},same={0};
    LmP0Text *caller[]={&a,&b},*prototype[]={&c,&d};
    LmP0Text *first[]={&e,&f},*second[]={&g,&h};
    void *rows[]={caller,prototype,first,second};
    int arity[]={2,2,2,2},dynamic[]={0,0,0,0},own_method[]={3};
    int classes_c[]={0,0,1,0},classes_t[]={0,0,1,0},classes_m[]={2,3,1,-1};
    L2PathFact fact={0};
    L2UseReceiver receiver={0};
    int mi=999,key=999,status,memory=l2_alloc_live;
    a.data="op";a.length=2;same.data="op";same.length=2;
    c.data="p";c.length=1;e.data="other";e.length=5;g.data="renamed";g.length=7;
    l2_m_n=4;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=rows;
    l2_own_n=1;l2_own_mi=own_method;l2_nsf_n=2;
    l2_cfr_n=3;l2_cfr_c=classes_c;l2_cfr_t=classes_t;l2_cfr_m=classes_m;
    fact.method=0;fact.source_use=2;
    receiver.method=1;receiver.key=0;receiver.input_symbol=&c;
#define PORT(n) l2_use_receiver_port(&fact,&receiver,(n),&mi,&key)
    expect(PORT(0)==0 && mi==1 && key==0,"static receiver selects its declared canonical input");
    expect(PORT(1)==1 && mi==-1 && key==-1,"end clears stale output ports");
    expect(PORT(-1)==2 && mi==-1 && key==-1,"negative enumeration is unknown, not a port");
    prototype[0]=&d;prototype[1]=&c;
    expect(PORT(0)==0 && mi==1 && key==1,"static canonical input survives permutation");
    receiver.input_symbol=&same;
    expect(PORT(0)==2 && mi==-1 && key==-1,"equal spelling cannot replace a canonical input");
    receiver.input_symbol=0;
    expect(PORT(0)==2,"a positive key without its canonical row is invalid");
    receiver.key=l2_d105_own_key(0);
    expect(PORT(0)==0 && mi==3 && key==-2,"own key selects its actual host method");
    receiver.key=-1;
    expect(PORT(0)==0 && mi==1 && key==-1,"result key is a real receiving port, not end");
    receiver.key=l2_d105_field_key(1);
    expect(PORT(0)==0 && mi==1 && key==INT_MIN+1,"namespace field keys retain their existing identity");
    receiver.key=-4;
    expect(PORT(0)==2 && mi==-1 && key==-1,"invalid negative key cannot become empty coverage");
    receiver.key=0;receiver.input_symbol=&c;
    receiver.selector_symbol=&a;
    expect(PORT(0)==0 && mi==2 && key==1,"dynamic receiver selects actual method, not descriptor body");
    expect(PORT(1)==0 && mi==3 && key==1,"every reachable implementation contributes its own port");
    expect(PORT(2)==1 && mi==-1 && key==-1,"actual class list ends without a prototype fallback");
    expect(PORT(0)==0 && l2_input_name(mi,key)==&f,"actual formal spelling need not match prototype");
    l2_cfr_n=4;
    expect(PORT(0)==2 && mi==-1 && key==-1,"known plus unfollowed source stays unknown");
    l2_cfr_n=0;
    expect(PORT(0)==2,"zero reachable implementations is unknown, not empty");
    l2_cfr_n=3;
    caller[0]=&b;caller[1]=&a;
    expect(PORT(0)==2,"moved selector does not borrow stale positional class facts");
    classes_t[0]=classes_t[1]=1;
    expect(PORT(0)==0 && mi==2 && key==1,"current selector address projects current class closure");
    caller[1]=&same;
    expect(PORT(0)==2 && mi==-1 && key==-1,"same spelling at another source row cannot select a class");
    caller[1]=&a;
    classes_m[0]=4;
    expect(PORT(0)==2 && mi==-1 && key==-1,"invalid actual implementation is unknown");
    classes_m[0]=2;arity[2]=1;
    expect(PORT(0)==2 && mi==-1 && key==-1,"actual missing interface position is unknown");
    arity[2]=2;arity[1]=1;
    expect(PORT(0)==2,"hidden input is not guessed by dynamic positional projection");
    arity[1]=2;receiver.input_symbol=0;receiver.key=-1;
    expect(PORT(0)==2,"dynamic actual cannot reuse the prototype result port");
    receiver.input_symbol=&c;receiver.key=0;receiver.method=4;
    expect(PORT(0)==2,"invalid prototype contract is unknown");
    receiver.method=1;fact.source_use=0;
    expect(PORT(0)==2,"compiler query is not a checked receiving occurrence");
    fact.source_use=2;fact.method=4;
    expect(PORT(0)==2,"nonexistent source method is invalid inventory");
    fact.method=0;
    status=l2_use_receiver_port(0,&receiver,0,&mi,&key);
    expect(status==2 && mi==-1 && key==-1,"missing original occurrence clears outputs");
    status=l2_use_receiver_port(&fact,0,0,&mi,&key);
    expect(status==2 && mi==-1 && key==-1,"missing receiver clears outputs");
    expect(l2_use_receiver_port(&fact,&receiver,0,0,&key)==2,"null destination is rejected");
    receiver.selector_symbol=0;receiver.input_symbol=&c;
    expect(PORT(0)==0 && mi==1 && key==1,"static receiver does not consult unrelated callable classes");
    expect(l2_alloc_live==memory,"port projection allocates no second graph or name registry");
    fprintf(stderr,"bound receiver ports: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
