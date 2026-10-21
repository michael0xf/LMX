#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main source_status_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){
    ++checks;if(!yes){++failures;fprintf(stderr,"FAIL source query status: %s\n",why);}
}
int main(void){
    int live=l2_alloc_live;
    LmP0Text arg={0},other_arg={0};
    arg.data="arg";arg.length=3U;other_arg=arg;
    LmP0Text *names[]={&arg};void *input_rows[]={names};
    int arity[]={1},dynamic[]={0};LmP0Node *empty_nodes[]={0};
    LmP0Node root={0};LmP0NodeAs root_as={0};LmP0Field first={0};
    root.kind=LM_P0_NODE_ATOM;root.as=&root_as;root_as.atom=&arg;first.value=&root;
    L2PathFact fact={0};L2PathStep step;L2SourceSite site={0};
    l2_path_init("arg\\field",9U,&fact.resolved);l2_path_step_clear(&step);
    fact.method=fact.source_method=0;fact.source=&root;fact.source_use=1;
    fact.input_symbol=&other_arg;fact.use_site=&site;
    fact.resolved.fi=0;fact.resolved.n=fact.resolved.cap=fact.resolved.names=1;
    fact.resolved.run_count=fact.resolved.names_run=3;fact.resolved.steps=&step;
    step.off=4U;step.len=5U;
    l2_m_n=1;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;
    l2_m_node=l2_m_body=empty_nodes;l2_cur_mi=l2_here_source_mi=0;
    l2_here_node=&root;l2_src="source-status-test";l2_rw_quiet=1;
    L2ReferenceSource source={0};
    expect(!l2_reference_source(NULL,0,0,&source)&&source.schema==-1&&
           !l2_diag_n&&!l2_translation_failed(l2_src,&root),
           "a genuine unknown source is success, not a fatal inventory error");
    expect(l2_reference_source(&first,3,0,NULL)==1&&l2_diag_n==1&&
           l2_rw_quiet==1&&!l2_alloc_err&&!l2_rw_quiet_msg,
           "a missing result is fatal even during a quiet speculative walk");
    l2_diag_n=0;l2_path_facts=l2_path_facts_tail=&fact;
    expect(l2_reference_source(&first,3,0,&source)==1&&l2_diag_n==1&&
           source.schema==-1&&l2_rw_quiet==1&&!l2_alloc_err,
           "an equal-spelled but noncanonical input row is fatal, not an unknown source");
    l2_diag_n=0;
    expect(l2_check_reference_receiving(&root,&first,3,0,NULL,0)==1&&
           l2_diag_n==1&&!l2_d105e_n&&!l2_d105s_n,
           "receiving checks stop before preparing maps from a failed source query");
    l2_diag_n=0;
    expect(l2_d105_note(0,0,0,&first,3,&root)==1&&l2_diag_n==1&&
           !l2_d105e_n&&!l2_d105s_n,
           "source-flow collection propagates the same failure without adding an edge");
    int cf_j[]={0},cf_ty[]={0},cf_kind[]={1},cf_span[]={3},cf_mi[]={0};
    LmP0Field *cf_a0[]={&first};LmP0Node *cf_at[]={&root};
    l2_cfa_j=cf_j;l2_cfa_ty=cf_ty;l2_cfa_kind=cf_kind;l2_cfa_span=cf_span;
    l2_cfa_mi=cf_mi;l2_cfa_a0=cf_a0;l2_cfa_at=cf_at;
    l2_diag_n=0;
    expect(l2_cfa_to(0,0)==1&&l2_diag_n==1&&!l2_d105e_n&&!l2_d105s_n,
           "callable propagation cannot reinterpret query failure as an empty source set");
    l2_diag_n=0;
    expect(l2_reference_bound_path_source(NULL,&source)==1&&l2_diag_n==1&&l2_rw_quiet==1,
           "a missing fact reports failure without dereferencing a nonexistent source");
    l2_diag_n=0;
    expect(l2_reference_bound_path_source(&fact,NULL)==1&&l2_diag_n==1&&l2_rw_quiet==1,
           "the bound producer also rejects a missing output without a crash");
    l2_diag_n=0;l2_path_facts=l2_path_facts_tail=NULL;
    expect(!l2_reference_source(NULL,0,0,&source)&&source.schema==-1&&!l2_diag_n&&
           !l2_alloc_err&&l2_rw_quiet==1&&!l2_rw_quiet_msg,
           "unknown-source success remains distinct without a sticky new failure flag");
    l2_rw_quiet=0;l2_bound_free();
    expect(l2_alloc_live==live,"query failure and flow-note cleanup retain no source storage");
    printf("source query status: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
