#include "l2src/lmx_implements.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include <stdio.h>
#include <stdlib.h>
static int checks,failures;
static char token;
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL full proof: %s\n",why);}}
static Lmx *node(LmxArena *a,size_t n){Lmx *p=lmx_node_new_owned(a);if(!p||lmx_arena_refs_open_owned(a,p,n))abort();return p;}
static void put(Lmx *n,size_t i,void *v){if(lmx_arena_ref_store(n,i,v))abort();}
static void integer(LmxArena *a,Lmx *n,size_t i,int v){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,v))abort();put(n,i,p);}
static void sizecell(LmxArena *a,Lmx *n,size_t i,size_t v){void *p=lmx_size_new_owned(a);if(!p||lmx_size_store_known(p,v))abort();put(n,i,p);}
static void layout(LmxArena *a,Lmx *n){if(lmx_implements_register_map(a,n,n,NULL,0,&token)!=LMX_IMPLEMENTS_YES)abort();}
static void run(int frame_mode){
    LmxArena a={0};if(lmx_arena_open(&a))abort();
    Lmx *req=node(&a,1),*value=node(&a,1),*fresh=node(&a,1);
    integer(&a,req,0,1);integer(&a,value,0,7);integer(&a,fresh,0,1);
    layout(&a,req);layout(&a,value);layout(&a,fresh);
    Lmx *frame=node(&a,4),*catalog=node(&a,1),*references=node(&a,1);
    sizecell(&a,catalog,0,0);sizecell(&a,references,0,0);
    put(frame,0,catalog);sizecell(&a,frame,2,1);put(frame,3,references);
    int first=frame_mode?lmx_implements_admit_receiving_frame(&a,value,req,frame):
        lmx_implements_admit_templates(&a,value,req,NULL,0,NULL,1);
    ck(first==LMX_IMPLEMENTS_YES,"the original full receiving operation succeeds");
    LmxImplEntry *proof=lmx_implements_find(&a,value,req);
    ck(proof&&proof->reception_proof==2,"a successful full operation records full, not coordinate-only proof");
    void *changed=lmx_char_new_owned(&a);if(!changed)abort();put(value,0,changed);
    size_t before=a.impl_len;
    int again=frame_mode?lmx_implements_admit_receiving_frame(&a,value,req,frame):
        lmx_implements_admit_templates(&a,value,req,NULL,0,NULL,1);
    fprintf(stderr,"full-proof route=%s first=%d repeat=%d proof=%d\n",frame_mode?"current-frame":"templates",first,again,proof?proof->reception_proof:-1);
    ck(again==LMX_IMPLEMENTS_YES,"same full receiving pair reuses its established proof after value mutation");
    ck(a.impl_len==before,"proof reuse does not append or replace a correspondence");
    ck(lmx_implements_admit_receiving(&a,value,req,NULL,NULL)==LMX_IMPLEMENTS_YES,
       "the existing common receiving API already preserves this stable full-pair contract");
    int other=frame_mode?lmx_implements_admit_receiving_frame(&a,value,fresh,frame):
        lmx_implements_admit_templates(&a,value,fresh,NULL,0,NULL,1);
    ck(other==LMX_IMPLEMENTS_NO&&!lmx_implements_find(&a,value,fresh),
       "a new required pair still has its own admission and refuses the actual incompatible field");
    size_t scope[]={4,1,1,0};LmxImplUses uses={0};uses.map=scope;
    ck(lmx_implements_admit_templates(&a,value,req,NULL,0,&uses,1)==LMX_IMPLEMENTS_NO,
       "a scoped Consumer still has its own actual used-field admission");
    if(frame_mode){
        sizecell(&a,references,0,1);
        ck(lmx_implements_admit_receiving_frame(&a,value,req,frame)==LMX_IMPLEMENTS_UNKNOWN,
           "full proof does not authorize malformed current reference metadata");
        sizecell(&a,references,0,0);sizecell(&a,catalog,0,1);
        ck(lmx_implements_admit_receiving_frame(&a,value,req,frame)==LMX_IMPLEMENTS_UNKNOWN,
           "full proof does not bypass current catalog owner/extent validation");
    }
    lmx_arena_release(&a);
}
int main(void){run(0);run(1);printf("stable full receiving proof: %d checks, %d failures\n",checks,failures);return failures!=0;}
