#define main inherited_pending_views_unused_main
#include "lmx_implements_pending_views_selftest.c"
#undef main
#include <stdint.h>
void *__real_malloc(size_t);
void *__real_calloc(size_t,size_t);
void *__real_realloc(void *,size_t);
void __real_free(void *);
typedef struct C106Allocation{void *pointer;struct C106Allocation *next;} C106Allocation;
static C106Allocation *allocated;
static size_t live,seen,fail_at;
static int armed,fired;
static int deny(void){if(!armed)return 0;++seen;if(fail_at&&seen==fail_at){fired=1;return 1;}return 0;}
static C106Allocation *find(void *p){for(C106Allocation *n=allocated;n;n=n->next)if(n->pointer==p)return n;return NULL;}
static void remember(void *p){
    if(!p)return;C106Allocation *n=__real_malloc(sizeof *n);if(!n)abort();
    n->pointer=p;n->next=allocated;allocated=n;++live;
}
void *__wrap_malloc(size_t n){if(deny())return NULL;void *p=__real_malloc(n);remember(p);return p;}
void *__wrap_calloc(size_t n,size_t z){if(deny())return NULL;void *p=__real_calloc(n,z);remember(p);return p;}
void *__wrap_realloc(void *old,size_t z){
    if(deny())return NULL;C106Allocation *n=find(old);void *p=__real_realloc(old,z);
    if(p){if(n)n->pointer=p;else remember(p);}return p;
}
void __wrap_free(void *p){
    C106Allocation **at=&allocated;while(*at&&(*at)->pointer!=p)at=&(*at)->next;
    if(*at){C106Allocation *n=*at;*at=n->next;__real_free(n);--live;}__real_free(p);
}
static Lmx *node(LmxArena *a,size_t n){Lmx *v=lmx_node_new_owned(a);if(!v||lmx_arena_refs_open_owned(a,v,n))abort();return v;}
static void *num(LmxArena *a,int n){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,n))abort();return p;}
static void put(Lmx *v,size_t i,void *p){if(lmx_arena_ref_store(v,i,p))abort();}
static int read_slot(LmxArena *a,Lmx *v,Lmx *req,size_t k){
    size_t p;if(lmx_implements_slot(a,v,req,k,&p))return -10000;
    void *cell=lmx_graph_value_in(a,v,p);return cell?lmx_int_value_known(cell):-10000;
}
int main(int argc,char **argv){
    size_t startup_live=live;int mode=argc>2?atoi(argv[2]):0;
    LmxArena a={0};if(lmx_arena_open(&a))return 2;
    size_t u=SIZE_MAX,dm[]={0,u,1,u,0,u,1,u},em[]={1,u,0,u,1,u},identity[]={0,1,0,1};
    Lmx *d=node(&a,4),*e=node(&a,4),*v=node(&a,2),*copy=NULL;
    for(size_t i=0;i<4;i+=2){put(d,i,num(&a,(int)i));put(e,i,num(&a,(int)i));}
    put(v,0,num(&a,7));put(v,1,num(&a,9));
    if(mode==2){d=e=v;}
    for(int k=0;k<(mode==2?1:2);++k){
        LmxImplEntry view={0};view.n=mode==2?2:4;view.map=mode==2?identity:(k?em:dm);
        if(mode==1){view.map=lmx_implements_map_clone(view.map,view.n);view.owned_map=1;if(!view.map)abort();}
        if(lmx_implements_admit_receiving(&a,v,k?e:d,&view,NULL)!=LMX_IMPLEMENTS_YES)abort();
    }
    while(a.impl_len<a.impl_cap){
        Lmx *filler=node(&a,1);put(filler,0,num(&a,1));
        if(lmx_implements_register_map(&a,filler,filler,NULL,0,NULL)!=LMX_IMPLEMENTS_YES)abort();
    }
    size_t before=a.impl_len;LmxImplEntry *saved=__real_malloc(before*sizeof *saved);if(!saved)abort();
    memcpy(saved,a.impl,before*sizeof *saved);
    fail_at=argc>1?(size_t)strtoull(argv[1],NULL,10):0;
    LmxCopyMap relocated={0};Lmx *operands[]={v,v};
    armed=1;
    int answer=lmx_merge_used_relocated_profiled_owned(operands,mode==3?2:1,NULL,&a,&a,NULL,0,
        NULL,NULL,NULL,NULL,0,0,NULL,0,NULL,&copy,&relocated);
    armed=0;
    int bad=0;
    if(answer==LMX_MERGE_OK){
        Lmx *required=mode==2?copy:e;
        LmxImplEntry *record=lmx_implements_find(&a,copy,required);
        bad|=fired||!copy||copy==v||lmx_copy_map_get(&relocated,v)!=copy;
        if(mode!=3){
            bad|=!record||record->reception_proof!=2;
            bad|=read_slot(&a,copy,required,0)!=(mode==2?7:9);
        }else{
            bad|=copy->array.size!=4||lmx_int_value_known(lmx_graph_value_in(&a,copy,0))!=7||
                 lmx_int_value_known(lmx_graph_value_in(&a,copy,1))!=9;
            bad|=lmx_copy_map_get(&relocated,lmx_graph_ref_cell_in(&a,v,0))!=lmx_graph_ref_cell_in(&a,copy,0);
        }
    }else{
        bad|=!fired||copy!=NULL||relocated.n||lmx_copy_map_keys_data(&relocated)||
             lmx_copy_map_vals_data(&relocated)||a.impl_len!=before||memcmp(saved,a.impl,before*sizeof *saved)!=0;
    }
    bad|=read_slot(&a,v,e,0)!=(mode==2?7:9);
    lmx_graph_copy_map_dispose(&relocated);
    __real_free(saved);lmx_arena_release(&a);bad|=live!=startup_live;
    printf("merge_relocated_fault mode=%d fail=%llu seen=%llu fired=%d answer=%d live_delta=%llu bad=%d\n",
           mode,(unsigned long long)fail_at,(unsigned long long)seen,fired,answer,(unsigned long long)(live-startup_live),bad);
    return bad!=0;
}
