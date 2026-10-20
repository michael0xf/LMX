/* Scratch assertions against the actual frontend; no replacement resolver. */
#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_use_roles_test_frontend_main
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
    LmP0Text a = {0}, b = {0}, c = {0}, d = {0}, same_a = {0};
    LmP0Text *from[] = {&a, &b}, *to[] = {&c, &d};
    void *rows[] = {from, to};
    int arity[] = {2,2}, dynamic[] = {0,0};
    LmP0Node atom = {0}, other_atom = {0}, group = {0}, call = {0}, site = {0};
    LmP0NodeAs group_as = {0}, call_as = {0};
    LmP0Structure body = {0};
    LmP0Frame frame = {0};
    LmP0Field bare = {0}, grouped = {0}, called = {0}, other = {0};
    L2PathFact fact = {0}, query = {0}, shadow = {0}, path = {0};
    L2UseReceiver *first_receiver;
    int memory, before, result;
    const char *previous_tag = "unit-previous";
    a.data="a"; a.length=1; b.data="b"; b.length=1;
    c.data="c"; c.length=1; d.data="d"; d.length=1;
    same_a.data="a"; same_a.length=1;
    atom.kind = other_atom.kind = LM_P0_NODE_ATOM;
    bare.value=&atom; other.value=&other_atom;
    body.first_field=&bare;
    group.kind=LM_P0_NODE_STRUCTURE; group.as=&group_as; group_as.structure=&body;
    grouped.value=&group;
    frame.body=&body; call.kind=LM_P0_NODE_FRAME; call.as=&call_as; call_as.frame=&frame;
    called.value=&call;
    l2_m_n=2; l2_m_arity=arity; l2_m_dyn=dynamic; l2_m_fn=rows;
    l2_src="source-use-role-unit";
    fact.method=0; fact.source=&atom; fact.source_use=2; fact.input_symbol=&a;
    query=fact; query.source_use=0; fact.next=&query;
    l2_path_facts=&fact;
    expect(l2_use_fact_at(&bare,1,0)==&fact,"compiler query is not a source role");
    expect(!l2_use_fact_at(&bare,1,1),"the same node in another method is not this occurrence");
    expect(!l2_use_fact_at(&other,1,0),"a different P0 atom cannot borrow a role");
    expect(l2_use_fact_at(&grouped,1,0)==&fact,"transparent grouping preserves source identity");
    expect(!l2_use_fact_at(&called,1,0),"a call argument is not the identity of the call result");
    expect(!l2_use_fact_at(&bare,2,0),"a larger expression is not its first bare binding");
    shadow=fact; shadow.next=0; query.next=&shadow;
    expect(!l2_use_fact_at(&bare,1,0),"ambiguous original source contexts stay unclassified");
    query.next=0;
    path=fact; path.source_use=1; path.resolved.n=2; path.resolved.run_count=5;
    fact.next=&path;
    expect(l2_use_fact_at(&bare,5,0)==&path,"a path role uses its complete prepared run count");
    expect(!l2_use_fact_at(&bare,3,0),"a path prefix is not a complete consumed value");
    fact.next=&query;
    l2_use_identity(&bare,1,0);
    expect(fact.use_roles==1 && !query.use_roles,"identity marks only the written source fact");
    expect(!fact.receivers,"identity does not invent a field or receiving contract");
    l2_room_tag=previous_tag;
    memory=l2_alloc_live;
    result=l2_use_receiver(&bare,1,0,1,0,-1,&site);
    first_receiver=fact.receivers;
    expect(!result && first_receiver && fact.use_roles==3,"a checked receiver adds a separate role");
    expect(first_receiver && first_receiver->method==1 && first_receiver->key==0 &&
           first_receiver->input_symbol==&c && !first_receiver->selector_symbol,
           "receiving input retains its canonical row address");
    before=l2_bnd_mem_n;
    expect(!l2_use_receiver(&bare,1,0,1,0,-1,&site) && l2_bnd_mem_n==before &&
           fact.receivers==first_receiver,"the same checked port is deduplicated");
    to[0]=&d; to[1]=&c;
    expect(!l2_use_receiver(&bare,1,0,1,1,-1,&site) && l2_bnd_mem_n==before &&
           l2_input_symbol_index(1,first_receiver->input_symbol)==1,
           "input permutation neither retargets nor duplicates a receiving role");
    result=l2_use_receiver(&bare,1,0,1,1,0,&site);
    expect(!result && fact.receivers!=first_receiver && fact.receivers->selector_symbol==&a,
           "dynamic selection retains the caller binding, not a prototype-body claim");
    from[0]=&b; from[1]=&a;
    expect(l2_input_symbol_index(0,fact.receivers->selector_symbol)==1,
           "selector identity survives input permutation");
    from[1]=&same_a;
    expect(l2_input_symbol_index(0,fact.receivers->selector_symbol)==-1,
           "equal spelling at another address is not the selected binding");
    from[1]=&a;
    before=l2_bnd_mem_n;
    expect(!l2_use_receiver(&bare,1,0,2,0,-1,&site) && l2_bnd_mem_n==before,
           "invalid receiver method does not classify the occurrence");
    expect(!l2_use_receiver(&bare,1,0,1,2,-1,&site) && l2_bnd_mem_n==before,
           "a nonexistent input is not an empty receiving role");
    expect(l2_room_tag==previous_tag,"role allocation restores its caller tag");
    fact.use_roles=0; fact.receivers=0;
    l2_fail_left=1;
    result=l2_use_receiver(&bare,1,0,1,-1,-1,&site);
    expect(result && l2_alloc_err && !fact.use_roles && !fact.receivers,
           "failed receiving-record allocation cannot publish a partial role");
    expect(l2_room_tag==previous_tag,"failed allocation restores caller tag");
    l2_fail_left=0; l2_alloc_err=0;
    l2_path_facts=0; l2_path_facts_tail=0;
    l2_bound_free();
    expect(l2_alloc_live==memory,"all role records use the existing binding lifetime");
    fprintf(stderr,"source-use roles: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
