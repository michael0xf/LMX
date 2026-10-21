#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main bound_source_verdict_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){
    ++checks;if(!yes){++failures;fprintf(stderr,"FAIL bound source verdict: %s\n",why);}
}
int main(void){
    int live=l2_alloc_live;
    LmP0Node occurrence={0},index_node={0};
    LmP0Field index_field={0},other_field={0};
    L2Path p,next,bad;
    L2PathStep step,replacement,bad_step;
    l2_path_init("r",1U,&p);l2_path_step_clear(&step);
    p.n=p.cap=p.indexed=1;p.names=0;p.run_count=4;p.names_run=1;
    p.steps=&step;p.leaf_kind=13;p.leaf_model=5;p.leaf_ty=l2_graph_code();
    step.locus=7;step.index.first=&index_field;step.index.node=&index_node;
    step.index.count=1;step.elem_ty=l2_graph_code();step.elem_model=5;
    l2_cur_mi=l2_here_source_mi=3;l2_here_node=&occurrence;l2_ns_n=6;
    expect(!l2_path_fact_note(&p),"the existing fact storage retains the grammar once");
    L2PathFact *fact=l2_path_facts;
    L2ReferenceSource source={0};
    expect(!l2_reference_source_of_path(&p,&source)&&source.schema==5&&source.path==fact,
           "a source initially consumes the current complete projection");
    next=p;replacement=step;next.steps=&replacement;
    next.model_input=2;next.leaf_model=4;
    replacement.elem_model=4;replacement.view_model=4;replacement.model_context=-3;
    expect(l2_path_same_grammar(&p,&next),"different verdicts do not invent different grammar");
    int retained_live=l2_alloc_live;
    expect(!l2_path_fact_store(fact,&next)&&fact->resolved.steps!=&replacement&&
           fact->resolved.steps[0].elem_model==4&&fact->resolved.steps[0].view_model==4&&
           fact->resolved.model_input==2&&l2_alloc_live==retained_live&&!fact->next,
           "all types and projection maps replace the same owned current verdict, without allocation");
    expect(!l2_reference_source_of_path(&next,&source)&&source.schema==4&&
           source.path==fact&&source.schema==source.path->resolved.leaf_model&&source.layout==-1,
           "publishing a new typed source refreshes its scalar projection and route together");
    bad=next;bad.n=0;
    expect(l2_path_fact_store(fact,&bad)==1&&fact->resolved.n==1,
           "publishing a verdict cannot cut the original view");
    bad=next;bad.names=1;
    expect(l2_path_fact_store(fact,&bad)==1&&fact->resolved.names==0,
           "name counters cannot change independently of the grammar");
    bad=next;bad.indexed=0;
    expect(l2_path_fact_store(fact,&bad)==1&&fact->resolved.indexed==1,
           "INDEX counters cannot disappear while the step remains");
    bad=next;bad.run_count=3;
    expect(l2_path_fact_store(fact,&bad)==1&&fact->resolved.run_count==4,
           "the complete original source span stays aligned");
    bad=next;bad.names_run=0;
    expect(l2_path_fact_store(fact,&bad)==1&&fact->resolved.names_run==1,
           "the names-prefix source span stays aligned");
    bad=next;bad.flat=&other_field;
    expect(l2_path_fact_store(fact,&bad)==1&&!fact->resolved.flat,
           "a different adjacent group is not silently attached");
    bad=next;bad_step=replacement;bad.steps=&bad_step;bad_step.index.first=&other_field;
    expect(l2_path_fact_store(fact,&bad)==1&&fact->resolved.steps[0].index.first==&index_field,
           "a different original INDEX expression is not the same view");
    bad_step=replacement;bad_step.off=1;
    expect(l2_path_fact_store(fact,&bad)==1&&fact->resolved.steps[0].off==0,
           "a changed source coordinate refuses before modifying the verdict");
    next.fail_why=2;next.fail_seg=1;next.leaf_kind=next.leaf_model=next.leaf_ty=-1;
    expect(!l2_path_fact_store(fact,&next)&&fact->stage==1&&fact->resolved.fail_why==2&&
           fact->resolved.leaf_model==-1&&fact->resolved.leaf_ty==-1,
           "a current refusal replaces the previous successful leaf and type");
    expect(l2_reference_source_of_path(&next,&source)==1&&!source.path,
           "a failed verdict cannot be published as its former successful source");
    l2_bound_free();
    expect(l2_alloc_live==live,"verdict publication and refusal preserve the bounded lifetime");
    printf("bound source verdict: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
