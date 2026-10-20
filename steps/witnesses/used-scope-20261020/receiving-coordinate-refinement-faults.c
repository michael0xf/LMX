#define main inherited_pending_views_unused_main
#include "lmx_implements_pending_views_selftest.c"
#undef main
#include <stdint.h>

void *__real_malloc(size_t);
void *__real_calloc(size_t,size_t);
void *__real_realloc(void *,size_t);
void __real_free(void *);
typedef struct Allocation { void *pointer; struct Allocation *next; } Allocation;
static Allocation *allocated;
static size_t live,seen,fail_at;
static int armed,fired,cache_failure;
static void *cache;
static int deny(int kind,void *old) {
    if(!armed) return 0;
    ++seen;
    if(fail_at && seen==fail_at) {
        fired=1;
        cache_failure=kind==3&&old==cache;
        return 1;
    }
    return 0;
}
static Allocation *find_alloc(void *p) {
    for(Allocation *n=allocated;n;n=n->next) if(n->pointer==p)return n;
    return NULL;
}
static void remember(void *p) {
    if(!p) return;
    Allocation *n=__real_malloc(sizeof *n);
    if(!n) abort(); /* test bookkeeping, not an injection target */
    n->pointer=p;n->next=allocated;allocated=n;++live;
}
void *__wrap_malloc(size_t n) {
    if(deny(1,NULL)) return NULL;
    void *p=__real_malloc(n);remember(p);return p;
}
void *__wrap_calloc(size_t n,size_t z) {
    if(deny(2,NULL)) return NULL;
    void *p=__real_calloc(n,z);remember(p);return p;
}
void *__wrap_realloc(void *old,size_t z) {
    if(deny(3,old)) return NULL;
    Allocation *n=find_alloc(old);
    void *p=__real_realloc(old,z);
    if(p) { if(n)n->pointer=p;else remember(p); }
    return p;
}
void __wrap_free(void *p) {
    Allocation **at=&allocated;
    while(*at && (*at)->pointer!=p)at=&(*at)->next;
    if(*at){Allocation *n=*at;*at=n->next;__real_free(n);--live;}
    __real_free(p);
}
static Lmx *node(LmxArena *a,void *x,void *y) {
    Lmx *n=pn_node(a,x,y);
    if(!n)abort();
    return n;
}
static void layout(LmxArena *a,Lmx *v,void *token) {
    if(lmx_implements_register_map(a,v,v,NULL,0,token)!=LMX_IMPLEMENTS_YES)abort();
}
static void size_cell(LmxArena *a,Lmx *f,size_t i,size_t n){
    void *p=lmx_size_new_owned(a);
    if(!p||lmx_size_store_known(p,n)||lmx_arena_ref_store(f,i,p))abort();
}
static void token_cell(LmxArena *a,Lmx *f,size_t i,void *t){
    void *p=lmx_charptr_new_owned(a);
    if(!p||lmx_charptr_store_known(p,t)||lmx_arena_ref_store(f,i,p))abort();
}
int main(int argc,char **argv) {
    size_t startup_live=live;
    LmxArena a={0};
    size_t reverse[]={1,0,1,0},identity[]={0,1,0,1};
    size_t coverage[]={6,2,2,SIZE_MAX,3,0};
    char tokens[8];
    int mode=argc>2?atoi(argv[2]):0;
    if(lmx_arena_open(&a))return 2;
    Lmx *inner=node(&a,lmx_int_new_owned(&a),lmx_size_new_owned(&a));
    Lmx *source=node(&a,lmx_size_new_owned(&a),lmx_int_new_owned(&a));
    Lmx *child=node(&a,lmx_size_new_owned(&a),lmx_int_new_owned(&a));
    Lmx *model=node(&a,inner,lmx_int_new_owned(&a));
    Lmx *value=node(&a,lmx_int_new_owned(&a),child);
    layout(&a,inner,tokens);layout(&a,source,tokens+1);
    layout(&a,model,tokens+2);layout(&a,value,tokens+3);
    if(lmx_implements_register_map(&a,child,source,identity,2,NULL)!=LMX_IMPLEMENTS_YES)return 3;
    LmxImplTemplate t[2]={0};
    t[0].source_layout=tokens+3;t[0].required_layout=tokens+2;
    t[1].source_layout=tokens+1;t[1].required_layout=tokens;
    for(size_t i=0;i<2;++i){t[i].correspondence.map=reverse;t[i].correspondence.n=2;}
    LmxImplUses uses={0};
    if(mode&1){
        for(size_t i=0;i<2;++i){
            t[i].correspondence.frame=pn_frame(&a,reverse,4);
            t[i].correspondence.map=NULL;
        }
        uses.frame=pn_frame(&a,coverage,6);
    }else uses.map=coverage;
    Lmx *catalog=NULL;
    if((mode&3)>=2){
        catalog=lmx_node_new_owned(&a);
        if(!catalog||lmx_arena_refs_open_owned(&a,catalog,15))abort();
        size_cell(&a,catalog,0,2);
        for(size_t i=0;i<2;++i){
            size_t at=1+i*7;
            token_cell(&a,catalog,at,t[i].source_layout);
            token_cell(&a,catalog,at+1,t[i].required_layout);
            size_cell(&a,catalog,at+2,2);
            for(size_t j=0;j<4;++j)size_cell(&a,catalog,at+3+j,reverse[j]);
        }
    }
    /* A previous scoped reception already owns an incomplete child map.
       The later operation must refine it transactionally, never replace a
       known address or free its buffer before publication. */
    size_t prefix_map[]={1,SIZE_MAX,1,SIZE_MAX},prefix_coverage[]={4,1,0,0};
    LmxImplUses prefix_use={0};prefix_use.map=prefix_coverage;
    if(lmx_implements_register_map_owned(&a,child,inner,prefix_map,2,NULL)!=LMX_IMPLEMENTS_YES||
       lmx_implements_admit_receiving(&a,child,inner,NULL,&prefix_use)!=LMX_IMPLEMENTS_YES)abort();
    /* Guarantee the final atomic publication really has to reserve room. */
    while(a.impl_len<a.impl_cap) {
        Lmx *filler=node(&a,lmx_int_new_owned(&a),lmx_size_new_owned(&a));
        layout(&a,filler,tokens+4);
    }
    size_t before=a.impl_len,before_live=live;
    LmxImplEntry *saved=__real_malloc(before*sizeof *saved);
    if(!saved)abort();
    memcpy(saved,a.impl,before*sizeof *saved);
    cache=a.impl;
    fail_at=argc>1?(size_t)strtoull(argv[1],NULL,10):0;
    armed=1;
    int answer=(mode&3)<2?lmx_implements_admit_receiving_templates(&a,value,model,t,2,mode>=4?NULL:&uses):
        lmx_implements_admit_template_frame(&a,value,model,catalog,mode>=4?NULL:&uses,1);
    armed=0;
    int bad=0;
    if(answer==LMX_IMPLEMENTS_YES) {
        LmxImplEntry *p=lmx_implements_find(&a,child,inner);
        size_t slot;
        bad|=fired!=0||a.impl_len!=before+1||!p||!p->owned_map||
            lmx_implements_slot(&a,child,inner,2,&slot)||slot!=1;
        bad|=live!=before_live+(mode>=4?2U:0U); /* replaced map, plus full contract/key buffer when requested */
    }else {
        bad|=answer!=LMX_IMPLEMENTS_UNKNOWN||!fired||a.impl_len!=before||
            memcmp(saved,a.impl,before*sizeof *saved)!=0||live!=before_live;
        LmxImplEntry *old_child=lmx_implements_find(&a,child,inner);
        bad|=lmx_implements_find(&a,value,model)!=NULL||!old_child;
        if(old_child)bad|=!old_child->owned_map||old_child->n!=2||old_child->reception_proof!=1||
                           !old_child->map||memcmp(old_child->map,prefix_map,sizeof prefix_map)!=0;
    }
    __real_free(saved);
    lmx_arena_release(&a);
    bad|=live!=startup_live;
    printf("refinement_fault mode=%d fail=%llu seen=%llu fired=%d cache=%d answer=%d live_delta=%llu bad=%d\n",
           mode,(unsigned long long)fail_at,(unsigned long long)seen,fired,
           cache_failure,answer,(unsigned long long)(live-startup_live),bad);
    return bad!=0;
}
