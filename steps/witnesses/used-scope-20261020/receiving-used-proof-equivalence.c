#include "l2src/lmx_implements.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
static int checks,failures;
static char tokens[4];
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL used proof: %s\n",why);}}
static Lmx *node(LmxArena *a,size_t n){Lmx *p=lmx_node_new_owned(a);if(!p||lmx_arena_refs_open_owned(a,p,n))abort();return p;}
static void integer(LmxArena *a,Lmx *n,size_t i,int v){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,v)||lmx_arena_ref_store(n,i,p))abort();}
static void layout(LmxArena *a,Lmx *n,int k){if(lmx_implements_register_map(a,n,n,NULL,0,tokens+k)!=LMX_IMPLEMENTS_YES)abort();}
static void run(int mode){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *whole=node(&a,2),*shorter=node(&a,1),*required=node(&a,2),*value=node(&a,3);
 integer(&a,whole,0,0);integer(&a,whole,1,0);integer(&a,shorter,0,0);
 integer(&a,required,0,0);if(mode!=1)integer(&a,required,1,0);
 integer(&a,value,0,29);integer(&a,value,1,7);integer(&a,value,2,9);
 layout(&a,whole,0);layout(&a,shorter,1);layout(&a,required,2);layout(&a,value,3);
 size_t complete[]={1,2,1,2},prefix[]={1,1};LmxImplEntry e={0};
 e.map=complete;e.n=2;e.layout=tokens+3;
 ck(lmx_implements_admit_receiving(&a,value,whole,&e,NULL)==LMX_IMPLEMENTS_YES,"complete earlier model has real proved physical addresses");
 e.map=prefix;e.n=1;
 ck(lmx_implements_admit_receiving(&a,value,shorter,&e,NULL)==LMX_IMPLEMENTS_YES,"short earlier model proves the same used physical field");
 size_t identity[]={0,1,0,1},partial[]={0,SIZE_MAX,0,SIZE_MAX},scope[]={4,1,1,0};
 LmxImplTemplate templates[2]={0};LmxImplUses uses={0};uses.map=scope;
 templates[0].source_layout=tokens;templates[0].required_layout=tokens+2;
 templates[0].correspondence.map=identity;templates[0].correspondence.n=2;
 templates[1].source_layout=tokens+1;templates[1].required_layout=tokens+2;
 templates[1].correspondence.map=partial;templates[1].correspondence.n=2;
 size_t before=a.impl_len;
 int answer=lmx_implements_admit_templates(&a,value,required,templates,2,mode==0?&uses:NULL,mode==1?0:1);
 fprintf(stderr,"used proof mode=%d answer=%d old-state=%d\n",mode,answer,answer==LMX_IMPLEMENTS_YES||a.impl_len==before);
 ck(answer==LMX_IMPLEMENTS_YES,"compatible incomplete evidence must not veto the proved addresses required by this Consumer");
 lmx_arena_release(&a);
}
int main(void){run(0);run(1);run(2);printf("used receiving evidence: %d checks, %d failures\n",checks,failures);return failures!=0;}
