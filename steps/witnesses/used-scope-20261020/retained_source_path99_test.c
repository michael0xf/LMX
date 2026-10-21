#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main retained_path_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){
    ++checks;if(!yes){++failures;fprintf(stderr,"FAIL retained source: %s\n",why);}
}
static int snapshot(L2Tx *out,const L2ReferenceSource *source){
    return l2_tx_clear(out)||l2_source_plan_path(out,source->path);
}
static int same(const L2Tx *a,const L2Tx *b){
    return a->len==b->len&&!memcmp(a->data,b->data,a->len);
}
int main(void){
    int live=l2_alloc_live;
    LmP0Node occurrence={0};
    L2Path p;
    l2_path_init("r\\x",3U,&p);
    p.n=p.cap=129;p.names=64;p.indexed=65;p.run_count=130;p.names_run=65;
    p.steps=l2_xmalloc((size_t)p.n*sizeof *p.steps);
    if(!p.steps)abort();
    memset(p.steps,0,(size_t)p.n*sizeof *p.steps);
    p.fi=p.oi=p.ni=p.res=p.root=p.model_input=-1;
    p.leaf_kind=13;p.leaf_model=5;p.leaf_ty=l2_graph_code();
    for(int i=0;i<p.n;++i){
        L2PathStep *s=p.steps+i;
        s->formal=s->node_host=s->own=s->nsrow=-1;
        s->model_input=s->model_step=s->view_model=s->model_context=-1;
        s->locus=i%2?1:7;s->kind=i%2?10:13;
        s->elem_model=5;s->elem_ty=l2_graph_code();s->off=2;s->len=1;
    }
    LmP0Text type_word={0};type_word.data="E";type_word.length=1U;
    L2TypeContract leaf={0},array={0},equal_leaf={0},equal_array={0};
    leaf.depth=1;leaf.word=&type_word;array.kind=1;array.operand=&leaf;
    equal_leaf=leaf;equal_array=array;equal_array.operand=&equal_leaf;
    p.steps[64].level=&array;
    l2_cur_mi=l2_here_source_mi=3;l2_here_node=&occurrence;l2_ns_n=6;
    expect(!l2_path_fact_note(&p),"the existing resolver-fact lifetime retains the prepared result");
    L2PathFact *fact=l2_path_facts;
    expect(fact&&fact==l2_path_facts_tail&&!fact->next,"one current occurrence has one existing fact");
    L2ReferenceSource source;memset(&source,0x71,sizeof source);
    expect(!l2_reference_source_of_path(&p,&source)&&source.schema==5&&source.path==fact,
           "typed source borrows the exact complete mixed path, not only its leaf schema");
    expect(source.layout==-1&&source.method==-1&&source.place==-1,
           "keeping the namespace route grants no physical origin or fabricated flow key");
    expect(fact&&fact->resolved.steps!=p.steps&&fact->resolved.text!=p.text,
           "the source borrows the existing owned fact rather than temporary parser storage");
    l2_path_release(&p);
    expect(source.path==fact&&fact->resolved.n==129&&fact->resolved.steps[64].level==&array,
           "temporary release leaves all retained steps and contract origins intact");
    char a_bytes[65536],b_bytes[65536];L2Tx a,b;
    l2_tx_local(&a,a_bytes,sizeof a_bytes);l2_tx_local(&b,b_bytes,sizeof b_bytes);
    expect(!snapshot(&a,&source),"the source convergence snapshot includes the whole route");
    fact->resolved.steps[64].level=&equal_array;
    expect(!snapshot(&b,&source)&&same(&a,&b),
           "equal contracts at different compiler allocation addresses converge identically");
    equal_leaf.depth=2;
    expect(!snapshot(&b,&source)&&!same(&a,&b),
           "changing an intermediate declared reference depth changes the current snapshot");
    equal_leaf.depth=1;fact->resolved.steps[64].level=&array;
    expect(!snapshot(&b,&source)&&same(&a,&b),"restoring the contract restores the exact route snapshot");
    fact->resolved.steps[64].view_model=4;
    expect(!snapshot(&b,&source)&&!same(&a,&b),
           "a changed intermediate implements map cannot hide behind the same leaf Model");
    fact->resolved.steps[64].view_model=-1;fact->resolved.model_input=2;
    expect(!snapshot(&b,&source)&&!same(&a,&b),"a different current input-header origin is observable");
    fact->resolved.model_input=-1;fact->stage=0;
    expect(source.path->stage==0&&!snapshot(&b,&source)&&!same(&a,&b),
           "a pending re-resolution is current state, never a secretly retained old verdict");
    fact->stage=1;
    expect(!snapshot(&b,&source)&&same(&a,&b),"a restored verdict has no new allocation identity in the snapshot");
    p=fact->resolved;p.owned=0;p.cap=0;
    l2_here_node=NULL;
    L2ReferenceSource other;memset(&other,0x71,sizeof other);
    expect(!l2_reference_source_of_path(&p,&other)&&!other.path,
           "an unrelated source occurrence never borrows the first matching leaf Model");
    l2_here_node=&occurrence;
    expect(l2_path_facts==fact&&!fact->next,"projection allocates no second fact, source graph or name table");
    l2_bound_free();
    expect(l2_alloc_live==live,"the retained source and all path storage use the existing bounded lifetime");
    printf("retained typed source path: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
