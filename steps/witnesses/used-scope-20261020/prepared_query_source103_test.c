#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main source_query_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){
    ++checks;if(!yes){++failures;fprintf(stderr,"FAIL prepared query source: %s\n",why);}
}
int main(void){
    int live=l2_alloc_live;
    LmP0Text a={0},b={0},x={0},slash={0};
    a.data="a";a.length=1;b.data="b";b.length=1;x.data="x";x.length=1;
    slash.data="\\";slash.length=1;
    LmP0Text *inputs[]={&a,&b},*fields[]={&x},*empty_names[]={0};
    void *input_rows[]={inputs};
    int arity[]={2},dynamic[]={0},ns_negative[]={-1};
    int formal_mi[]={0,0},formal_k[]={0,1},formal_model[]={0,0};
    int owner[]={0},kind[]={7},ref[]={-1};
    LmP0Node *empty_nodes[]={0};
    LmP0Node nodes[3]={{0}};LmP0NodeAs node_as[3]={{0}};
    LmP0Field run[3]={{0}};LmP0Text *words[]={&b,&slash,&x};
    LmP0Node outer={0},elsewhere={0};
    for(int k=0;k<3;++k){nodes[k].kind=LM_P0_NODE_ATOM;nodes[k].as=node_as+k;
        node_as[k].atom=words[k];run[k].value=nodes+k;if(k<2)run[k].next=run+k+1;}
    l2_m_n=1;l2_e=0;l2_cur_mi=0;l2_here_source_mi=0;l2_here_node=&outer;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;
    l2_m_node=l2_m_body=empty_nodes;l2_m_name=empty_names;
    l2_ns_n=1;l2_ns_name=empty_names;l2_ns_eternal=l2_ns_proc=ns_negative;
    l2_nsty_n=2;l2_nsty_mi=formal_mi;l2_nsty_k=formal_k;l2_nsty_ni=formal_model;
    l2_nsf_n=1;l2_nsf_owner=owner;l2_nsf_kind=kind;l2_nsf_ref=ref;
    l2_nsf_fname=fields;l2_nsf_source=empty_nodes;
    L2Path path,view;L2PathFact *selected=NULL;L2ReferenceSource source={0};
    expect(!l2_path_resolve_run(run,3,&path)&&path.source_first==run&&
           path.run_count==3&&path.leaf_kind==7,
           "the real common adapter retains the original P0 run with its typed result");
    L2PathFact *fact=l2_path_facts;
    expect(fact&&fact->source_use==0&&fact->stage==1&&fact->use_site&&
           fact->source==&outer&&fact->resolved.source_first==run,
           "an early query retains its environment without becoming actual source consumption");
    l2_path_release(&path);
    expect(!path.source_first&&!path.n&&!path.steps,"release clears the run anchor with all view counters");
    expect(l2_query_fact_find(run,3,0,&selected)==1&&selected==fact,
           "the source consumer selects the prepared result by exact original run, not a root name");
    expect(!l2_use_fact_at(run,3,0),"query0 is still absent from the actual Consumer-use inventory");
    expect(!l2_reference_source(run,3,0,&source)&&source.path==fact&&
           source.schema==-1&&fact->resolved.leaf_kind==7&&fact->resolved.fi==1,
           "an early source query consumes the existing common semantic route, including a scalar's unknown schema");
    expect(!fact->source_use&&!fact->use_roles&&!fact->receivers,
           "typing a query does not publish a full field permission or receiving role");
    inputs[0]=&b;inputs[1]=&a;
    expect(!l2_reference_source(run,3,0,&source)&&source.path==fact&&fact->resolved.fi==0,
           "the prepared query uses the same canonical binding refresh after input insertion");
    l2_here_node=&elsewhere;selected=fact;
    expect(!l2_query_fact_find(run,3,0,&selected)&&!selected,
           "another source environment cannot reuse an incidental query's record");
    l2_here_node=&outer;LmP0Field another=run[0];selected=fact;
    expect(!l2_query_fact_find(&another,3,0,&selected)&&!selected,
           "equal tokens and node do not substitute a different P0 field-run address");
    L2PathFact duplicate=*fact;duplicate.next=NULL;fact->next=&duplicate;
    expect(l2_query_fact_find(run,3,0,&selected)==2&&!selected,
           "two applicable query records never select the first one as evidence");
    fact->next=NULL;
    expect(!l2_path_prepared_view(&fact->resolved,&view)&&view.source_first==run,
           "a grammar view carries the run anchor together with the original INDEX/name geometry");
    view.source_first=&another;
    expect(l2_path_fact_store(fact,&view)==1&&fact->resolved.source_first==run,
           "publication rejects a different source run before changing its typed verdict");
    l2_path_release(&view);
    /* A query's outer diagnostic cursor is not the operand's actual use.
       Keep their existing context-specific facts distinct; query0 must not
       become Consumer evidence simply because its adapter result is reused. */
    l2_here_node=nodes;
    int noted=l2_path_use_note(nodes,&fact->resolved,0);
    L2PathFact *actual=l2_use_fact_at(run,3,0);
    expect(!noted&&actual&&actual!=fact&&actual->source_use==1&&!actual->stage&&
           actual->resolved.source_first==run&&!fact->source_use&&!fact->use_roles,
           "actual consumption has its own correct source cursor and cannot promote an outer query into Consumer evidence");
    expect(!l2_reference_source(run,3,0,&source)&&source.path==actual&&
           actual->stage==1&&actual->resolved.leaf_kind==7&&!fact->source_use,
           "the source consumer uses the actual occurrence through the same semantic fold, without a fallback parse");
    l2_bound_free();
    expect(l2_alloc_live==live,"prepared query/source environment storage closes with the translation");
    printf("prepared query source: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
