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
    /* The prior sixteen oracles above/below are unchanged. The additional
       checks use a real fn/frame/body inventory, not a return-type guess. */
    LmP0Text fn_word={0},fm_word={0},hidden={0};
    fn_word.data="fn";fn_word.length=2;fm_word.data="fm";fm_word.length=2;
    hidden.data="hidden";hidden.length=6;
    LmP0Frame fn_frame={0};fn_frame.head=&fn_word;
    LmP0Node fn_node={0},body_node={0};LmP0NodeAs fn_as={0},body_as={0};
    LmP0Structure body={0};
    fn_node.kind=LM_P0_NODE_FRAME;fn_node.as=&fn_as;fn_as.frame=&fn_frame;
    body_node.kind=LM_P0_NODE_STRUCTURE;body_node.as=&body_as;body_as.structure=&body;
    LmP0Node *method_nodes[]={&fn_node},*method_bodies[]={&body_node};
    l2_m_node=method_nodes;l2_m_body=method_bodies;
    LmP0Text *expanded[]={&b,&a,&hidden};void *expanded_rows[]={expanded};
    int three_mi[]={0,0,0},three_k[]={0,1,2},three_models[]={1,0,1};
    l2_m_fn=expanded_rows;l2_nsty_n=3;l2_nsty_mi=three_mi;
    l2_nsty_k=three_k;l2_nsty_ni=three_models;
    fact.next=NULL;fact.input_symbol=&b;fact.resolved.root_kind=0;
    fact.resolved.root=-1;fact.resolved.fi=1;fact.resolved.ni=1;
    l2_path_facts=l2_path_facts_tail=&fact;
    l2_path_init(NULL,0,&root);
    expect(!l2_source_use_binding(&fact,&root)&&root.model_input==0,
           "the shared producer retains the actual descriptor formal's args coordinate");
    fact.input_symbol=&a;
    expect(!l2_source_use_binding(&fact,&root)&&root.model_input==1,
           "another descriptor input has its own ordinary args coordinate");
    fact.input_symbol=&b;
    expect(!l2_reference_source(&first,1,0,&source)&&source.path==&fact&&
           fact.resolved.fi==0&&fact.resolved.model_input==0,
           "a whole typed binding publishes the current header anchor in the SAME fact");
    expect(!fact.stage&&!fact.resolved.n&&!fact.resolved.names&&
           !fact.resolved.indexed&&!fact.resolved.steps&&!fact.resolved.run_count,
           "retaining a Model address does not manufacture a consumed field path");
    l2_path_init(NULL,0,&root);root.model_input=77;
    expect(!l2_source_use_binding(&path,&root)&&root.fi==0&&root.model_input==0,
           "the canonical binding projection gives a field path the identical anchor");
    expanded[0]=&a;expanded[1]=&b;three_models[0]=0;three_models[1]=1;
    expect(!l2_reference_source(&first,1,0,&source)&&source.schema==1&&
           source.place==1&&fact.resolved.model_input==1,
           "input insertion refreshes the header anchor by row identity, not old index");
    method_bodies[0]=NULL;
    expect(!l2_reference_source(&first,1,0,&source)&&fact.resolved.model_input==-1,
           "a descriptor without fn parts clears stale args evidence");
    method_bodies[0]=&body_node;fn_frame.head=&fm_word;
    expect(!l2_source_use_binding(&fact,&root)&&root.model_input==-1,
           "an ordinary non-fn callable does not acquire an invented args graph");
    fn_frame.head=&fn_word;
    expect(!l2_reference_source(&first,1,0,&source)&&fact.resolved.model_input==1,
           "the current fn classification restores its declared Model anchor");
    dynamic[0]=1;expanded[1]=&hidden;expanded[2]=&b;
    /* Hidden names live in their own normal method row, not beyond the
       explicit-formal row. Supply its actual capture requirement too. */
    LmP0Text *hidden_names[]={&b};void *hidden_rows[]={hidden_names};
    int capture_model[]={0},capture_schema[]={1};LmP0Text *capture_names[]={&b};
    l2_m_dn=hidden_rows;l2_mcap_n=1;l2_mcap_model=capture_model;
    l2_mcap_ns=capture_schema;l2_mcap_name=capture_names;
    l2_path_init(NULL,0,&root);
    expect(!l2_source_use_binding(&fact,&root)&&root.model_input==-1,
           "a hidden transported value is not a signature description");
    expect(!l2_reference_source(&first,1,0,&source)&&source.place==2&&
           source.schema==1&&fact.resolved.fi==2&&fact.resolved.model_input==-1,
           "whole hidden bindings preserve their schema but clear an old formal anchor");
    expanded[1]=&b;expanded[2]=&hidden;three_models[1]=-1;
    expect(!l2_source_use_binding(&fact,&root)&&root.model_input==-1,
           "an unknown requirement does not borrow another formal's Model");
    expect(!l2_reference_source(&first,1,0,&source)&&source.schema==-1&&
           fact.resolved.model_input==-1,
           "a whole unknown binding does not retain the preceding successful anchor");
    three_models[1]=1;
    fact.method=-1;
    int invalid_low=l2_source_use_binding(&fact,&root);
    fact.method=1;
    expect(invalid_low==2&&l2_source_use_binding(&fact,&root)==2,
           "outside method inventory has no header coordinate");
    fact.method=0;dynamic[0]=0;fact.input_symbol=&hidden;
    int missing_input=l2_source_use_binding(&fact,&root);
    fact.input_symbol=&b;fact.source_use=-1;
    expect(missing_input==2&&l2_source_use_binding(&fact,&root)==2,
           "outside input inventory has no header coordinate");
    fact.source_use=2;
    fact.resolved.fi=-1;fact.input_symbol=NULL;fact.resolved.ni=1;
    root.model_input=88;
    expect(!l2_source_use_binding(&fact,&root)&&root.model_input==-1,
           "an ordinary Structure root cannot inherit a formal's old header anchor");
    l2_path_facts=l2_path_facts_tail=NULL;
    l2_bound_free();
    expect(l2_alloc_live==live,"source-environment snapshots leave no tracked allocation");
    printf("bound whole Model anchor: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
