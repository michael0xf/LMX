#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main effects_scan_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){
    ++checks;if(!yes){++failures;fprintf(stderr,"FAIL single effects path: %s\n",why);}
}
int main(void){
    int live=l2_alloc_live;
    LmP0Text a={0},b={0},x={0},slash={0};
    a.data="a";a.length=1;b.data="b";b.length=1;x.data="x";x.length=1;
    slash.data="\\";slash.length=1;
    LmP0Text *inputs[]={&a,&b},*fields[]={&x},*empty_names[]={0};
    void *input_rows[]={inputs};int types[]={42,42};int *type_rows[]={types};
    int arity[]={2},dynamic[]={0},ns_negative[]={-1};
    int formal_mi[]={0,0},formal_k[]={0,1},formal_model[]={0,0};
    int owner[]={0},kind[]={7},ref[]={-1};
    LmP0Node *empty_nodes[]={0};
    LmP0Node nodes[3]={{0}};LmP0NodeAs node_as[3]={{0}};
    LmP0Field run[3]={{0}};LmP0Text *words[]={&b,&slash,&x};LmP0Node outer={0};
    for(int k=0;k<3;++k){nodes[k].kind=LM_P0_NODE_ATOM;nodes[k].as=node_as+k;
        node_as[k].atom=words[k];run[k].value=nodes+k;if(k<2)run[k].next=run+k+1;}
    l2_m_n=1;l2_e=0;l2_cur_mi=0;l2_here_source_mi=0;l2_here_node=&outer;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=type_rows;
    /* A real parsed method always has its local-slot count row, including
       the zero-local case. Refused/failing paths also consult the C door. */
    l2_m_sn=dynamic;
    l2_m_node=l2_m_body=empty_nodes;l2_m_name=empty_names;
    l2_ns_n=1;l2_ns_name=empty_names;l2_ns_eternal=l2_ns_proc=ns_negative;
    l2_nsty_n=2;l2_nsty_mi=formal_mi;l2_nsty_k=formal_k;l2_nsty_ni=formal_model;
    l2_nsf_n=1;l2_nsf_owner=owner;l2_nsf_kind=kind;l2_nsf_ref=ref;
    l2_nsf_fname=fields;l2_nsf_source=empty_nodes;
    L2Path path;int before=l2_alloc_n;
    expect(!l2_path_resolve_run(run,3,&path)&&path.run_count==3&&path.leaf_kind==7,
           "the actual adapter resolves the original formal path and its complete span");
    int budget=l2_alloc_n-before;
    expect(budget>0&&l2_path_effect_raises(&path,0,0)==1,
           "the same typed result identifies a nullable formal effect");
    l2_path_release(&path);l2_bound_free();
    expect(l2_alloc_live==live,"the reference resolution has no retained allocations after disposal");
    before=l2_alloc_n;
    expect(l2_fields_path_effects(run,3,0,NULL,0)==1&&!l2_alloc_err,
           "the effects scan agrees with the already measured semantic result");
    expect(l2_alloc_n-before==budget,
           "effects uses exactly the one adapter/resolution allocation budget, not a second span parse");
    l2_bound_free();
    l2_fail_left=budget+1;
    expect(l2_fields_path_effects(run,3,0,NULL,0)==1&&!l2_alloc_err&&l2_fail_left==1,
           "an allocation armed after the common result cannot be consumed by a fallback adapter");
    l2_fail_left=0;l2_bound_free();
    for(int fault=1;fault<=budget;++fault){
        l2_fail_left=fault;
        int answer=l2_fields_path_effects(run,3,0,NULL,0);
        expect(answer==1&&l2_alloc_err,"every actual source allocation failure remains a fatal scan result");
        l2_fail_left=0;l2_alloc_err=0;l2_bound_free();
        expect(l2_alloc_live==live,"each failing common-result allocation closes its path and environment");
    }
    /* The missing field is a semantic refusal, not permission or another
       span parser. It must preserve the source count and the error channel. */
    x.data="missing";x.length=7;
    expect(l2_fields_path_effects(run,3,0,NULL,0)==1&&!l2_alloc_err,
           "a refused common path retains its ordinary effect channel");
    l2_bound_free();
    expect(l2_alloc_live==live,"all completed/refused/failing paths release their owned storage");
    printf("single effects path: %d checks, %d failures; one-resolution allocations=%d\n",checks,failures,budget);
    return failures!=0;
}
