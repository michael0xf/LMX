#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main source_root_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){
    ++checks;if(!yes){++failures;fprintf(stderr,"FAIL bound whole source: %s\n",why);}
}
int main(void){
    int live=l2_alloc_live;
    LmP0Text a={0},b={0},other_b={0},z={0};
    a.data="a";a.length=1;b.data="b";b.length=1;other_b=b;
    z.data="not_the_binding";z.length=15;
    LmP0Text *inputs[]={&a,&b};void *input_rows[]={inputs};
    int arity[]={2},dynamic[]={0};LmP0Node *empty_nodes[]={0};
    LmP0Text *empty_names[]={0};
    int formal_mi[]={0,0},formal_k[]={0,1},formal_model[]={0,1};
    int ns_negative[]={-1,-1};
    LmP0Node node={0};LmP0NodeAs node_as={0};LmP0Field first={0};
    node.kind=LM_P0_NODE_ATOM;node.as=&node_as;node_as.atom=&z;first.value=&node;
    L2SourceSite site={0};L2PathFact fact={0};L2Path root;
    L2ReferenceSource source={0};
    l2_m_n=1;l2_e=0;l2_cur_mi=0;l2_here_source_mi=0;l2_here_node=&node;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;
    l2_m_node=l2_m_body=empty_nodes;l2_m_name=empty_names;
    l2_ns_n=2;l2_ns_name=empty_names;l2_ns_eternal=l2_ns_proc=ns_negative;
    l2_nsty_n=2;l2_nsty_mi=formal_mi;l2_nsty_k=formal_k;l2_nsty_ni=formal_model;
    site.method=site.source_method=site.current_method=0;site.excluded=-1;
    fact.method=fact.source_method=0;fact.source=&node;fact.source_use=2;
    fact.input_symbol=&b;fact.use_site=&site;
    l2_path_init(z.data,z.length,&fact.resolved);fact.resolved.fi=0;
    l2_path_facts=l2_path_facts_tail=&fact;
    expect(!l2_reference_source(&first,1,0,&source)&&source.schema==1&&
           source.layout==-1&&source.method==0&&source.place==1,
           "the saved canonical b row selects current input1 without looking up z");
    expect(source.path==&fact&&fact.resolved.fi==1&&!fact.stage&&
           !fact.resolved.n&&!fact.resolved.steps&&!fact.resolved.run_count,
           "the borrowed whole fact stays stage0 with no fabricated field steps");
    expect(source.origin==&node&&source.origin_count==1&&source.origin_method==0,
           "the original source operand identity survives the root projection");
    inputs[0]=&b;inputs[1]=&a;formal_model[0]=1;formal_model[1]=0;
    expect(!l2_reference_source(&first,1,0,&source)&&source.schema==1&&
           source.place==0&&fact.resolved.fi==0,
           "another input permutation retains both the binding and its current declared Model");
    l2_path_init(NULL,0,&root);
    expect(!l2_source_use_binding(&fact,&root)&&root.fi==0&&root.ni==1,
           "whole and path consumers share the same root contract projection");
    L2PathStep step;l2_path_step_clear(&step);
    L2PathFact path=fact;path.source_use=1;
    l2_path_init("z\\field",7,&path.resolved);path.resolved.fi=1;
    path.resolved.n=path.resolved.cap=path.resolved.names=1;path.resolved.steps=&step;
    path.resolved.run_count=path.resolved.names_run=3;
    expect(!l2_source_use_binding(&path,&root)&&root.fi==0&&root.ni==1,
           "the same canonical row and current Model seed a written path");
    fact.input_symbol=&other_b;l2_rw_quiet=1;l2_src="bound-whole-source-test";
    expect(l2_reference_source(&first,1,0,&source)==1&&l2_diag_n==1&&
           source.schema==-1&&!source.path&&l2_rw_quiet==1,
           "equal spelling at another address is fatal inventory, not an old name fallback");
    l2_diag_n=0;fact.input_symbol=&b;
    fact.resolved.n=1;fact.resolved.steps=&step;
    expect(l2_reference_source(&first,1,0,&source)==1&&l2_diag_n==1&&
           source.schema==-1&&!source.path,
           "a whole read cannot masquerade as a prepared field path");
    l2_diag_n=0;fact.resolved.n=0;fact.resolved.steps=NULL;
    L2PathFact duplicate=fact;fact.next=&duplicate;
    L2PathFact *selected=&fact;
    expect(l2_use_fact_find(&first,1,0,&selected)==2&&!selected,
           "ambiguous occurrence selection exposes no arbitrary row");
    expect(!l2_use_fact_at(&first,1,0),"legacy role queries retain the same unclassified ambiguity");
    expect(!l2_reference_source(&first,1,0,&source)&&source.schema==-1&&
           !source.path&&!l2_diag_n,
           "ambiguous evidence does not restart a later-scope name lookup");
    fact.next=NULL;fact.resolved.fi=-1;fact.input_symbol=NULL;fact.resolved.ni=0;
    expect(!l2_reference_source(&first,1,0,&source)&&source.schema==0&&
           source.layout==0&&source.path==&fact,
           "an already selected original constructor retains its genuine physical source");
    fact.resolved.ni=-1;fact.resolved.root_kind=1;
    source.schema=77;source.layout=88;
    expect(!l2_reference_bound_root_source(&fact,&source)&&source.schema==-1&&
           source.layout==-1&&source.path==&fact&&!fact.stage,
           "an unresolved node source neither retains stale evidence nor invents its layout");
    fact.resolved.root_kind=3;fact.resolved.root=0;
    expect(!l2_reference_source(&first,1,0,&source)&&source.schema==-1&&source.layout==-1,
           "a bare method is not implicitly replaced by its declared result model");
    fact.resolved.root=1;
    expect(l2_reference_source(&first,1,0,&source)==1&&l2_diag_n==1,
           "an invalid method-row address is not another name query");
    l2_diag_n=0;l2_path_facts=l2_path_facts_tail=NULL;l2_rw_quiet=0;
    l2_bound_free();
    expect(l2_alloc_live==live,"source-environment snapshots leave no tracked allocation");
    printf("bound whole source: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
