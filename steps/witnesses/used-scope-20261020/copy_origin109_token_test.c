#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main physical_token_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL physical token: %s\n",why);}}
int main(void){
    enum{N=129};L2ReferenceSource sources[N];memset(sources,0,sizeof sources);
    int live=l2_alloc_live,allocation=l2_alloc_err;
    int procedures[]={-1,-1,-1,-1,-1};l2_ns_proc=procedures;
    l2_ns_n=5;l2_mres_n=N;l2_mres_source=NULL;
    expect(l2_schema_token_slot(0)==0&&l2_schema_token_slot(4)==4,"original physical namespaces keep their token cells");
    expect(l2_schema_token_slot(l2_schema_method(0))==-1,"a method is not physical-layout evidence");
    expect(l2_schema_token_slot(l2_schema_merge(0))==5,"absence of a source record retains the actual constructor's own token");
    for(int i=0;i<N;++i)sources[i].layout=-1;
    l2_mres_source=sources;sources[0].schema=3;
    expect(l2_schema_token_slot(l2_schema_merge(0))==5,"a logical receiving Model never substitutes for unknown physical origin");
    sources[0].layout=1;
    expect(l2_schema_token_slot(l2_schema_merge(0))==1,"a complete copy consumes its retained physical constructor evidence");
    sources[0].method=99;sources[0].place=-9;sources[0].origin_count=7;
    expect(l2_schema_token_slot(l2_schema_merge(0))==1,"names,flow keys and operand shape do not choose another physical token");
    sources[0].layout=l2_schema_merge(1);sources[1].layout=3;
    expect(l2_schema_token_slot(l2_schema_merge(0))==3,"copy chains share one physical-origin projection");
    sources[1].schema=2;
    expect(l2_schema_token_slot(l2_schema_merge(0))==3,"another logical Model cannot change a proved physical source");
    sources[1].layout=-1;
    expect(l2_schema_token_slot(l2_schema_merge(0))==6,"unknown origin at the current chain tip retains that actual constructor token");
    for(int i=0;i<N-1;++i)sources[i].layout=l2_schema_merge(i+1);
    sources[N-1].layout=4;
    expect(l2_schema_token_slot(l2_schema_merge(0))==4,"129 current source links have no fixed depth limit");
    sources[N-1].layout=-1;
    expect(l2_schema_token_slot(l2_schema_merge(0))==5+N-1,"a long chain stops at its unknown physical constructor,not its logical Model");
    sources[N-1].layout=l2_schema_merge(0);
    expect(l2_schema_token_slot(l2_schema_merge(0))==-1,"cyclic physical-origin inventory is rejected without recursion or fallback");
    sources[0].layout=l2_schema_merge(0);
    expect(l2_schema_token_slot(l2_schema_merge(0))==-1,"a self source is not fabricated physical evidence");
    sources[0].layout=l2_schema_method(0);
    expect(l2_schema_token_slot(l2_schema_merge(0))==-1,"a method-valued origin cannot become a layout token");
    sources[0].layout=l2_schema_merge(N);
    expect(l2_schema_token_slot(l2_schema_merge(0))==-1,"an invalid origin row has no synthetic alias");
    sources[0].layout=2;
    expect(l2_schema_token_slot(l2_schema_merge(0))==2,"the current source is read after mutation,not an ancestor cached token");
    sources[2].layout=4;
    expect(l2_schema_token_slot(l2_schema_merge(0))==2,"an unrelated admitted view is never searched as a replacement origin");
    expect(l2_alloc_live==live&&l2_alloc_err==allocation,"physical-origin projection adds no allocation or error-state side effect");
    printf("current physical token: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
