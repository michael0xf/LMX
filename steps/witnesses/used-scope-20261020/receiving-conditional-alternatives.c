#define main previous_used_evidence_main
#include "C:/Nyasha_Planet/LMX/steps/witnesses/used-scope-20261020/receiving-used-proof-equivalence.c"
#undef main
#include <string.h>
static void alternatives(int reverse,int last){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *A=node(&a,2),*B=node(&a,3),*R=node(&a,2),*v=node(&a,3);
 for(size_t i=0;i<2;i++){integer(&a,A,i,0);integer(&a,R,i,0);}
 for(size_t i=0;i<3;i++){integer(&a,B,i,0);integer(&a,v,i,i==0?7:i==1?9:29);}
 layout(&a,A,0);layout(&a,B,1);layout(&a,R,2);
 ck(lmx_implements_admit_receiving(&a,v,A,NULL,NULL)==LMX_IMPLEMENTS_YES,"first real bound model");
 ck(lmx_implements_admit_receiving(&a,v,B,NULL,NULL)==LMX_IMPLEMENTS_YES,"second real bound model");
 ck(lmx_implements_layout(&a,v)==NULL,"explicit model admissions never invent physical origin");
 size_t left[]={0,1,0,1},right[]={0,2,0,2};LmxImplTemplate rows[3]={0};
 for(size_t i=0;i<3;i++){
  int b=(i==1)^reverse;rows[i].source_layout=tokens+(b?1:0);rows[i].required_layout=tokens+2;
  rows[i].correspondence.n=2;rows[i].correspondence.map=b?right:left;
 }
 size_t scope[]={4,1,last?2:0,0};LmxImplUses used={0};used.map=scope;
 ck(lmx_implements_admit_templates(&a,v,R,rows,3,&used,1)==LMX_IMPLEMENTS_YES,"unrelated positive conflict does not veto used coordinate, in either order and half");
 LmxImplEntry *e=lmx_implements_find(&a,v,R);size_t x=SIZE_MAX,y=0,z=SIZE_MAX,w=0;
 ck(e&&e->n==2&&!lmx_implements_at(&a,e,0,&x)&&!lmx_implements_at(&a,e,1,&y)&&!lmx_implements_at_last(&a,e,0,&z)&&!lmx_implements_at_last(&a,e,1,&w)&&x==0&&z==0&&y==SIZE_MAX&&w==SIZE_MAX,
    "third row cannot resurrect ambiguous unused coordinates in either half");
 if(e){
  LmxImplEntry saved=*e;size_t before=a.impl_len;
  scope[2]=last?3:1;
  ck(lmx_implements_admit_templates(&a,v,R,rows,3,&used,1)!=LMX_IMPLEMENTS_YES&&a.impl_len==before&&!memcmp(&saved,lmx_implements_find(&a,v,R),sizeof saved),"next Consumer cannot use the unresolved address or change previous proof");
  ck(lmx_implements_admit_templates(&a,v,R,rows,3,NULL,1)!=LMX_IMPLEMENTS_YES&&a.impl_len==before&&!memcmp(&saved,lmx_implements_find(&a,v,R),sizeof saved),"scoped coordinates never become a full permission for ambiguous field");
  scope[2]=last?2:0;size_t at=SIZE_MAX;
  if(!lmx_implements_slot(&a,v,R,last?2:0,&at)){
   void *address=lmx_arena_ref_value(v,at);
   ck(address&&lmx_int_value_known(address)==7&&!lmx_int_store_known(address,43)&&lmx_int_value_known(lmx_arena_ref_value(v,0))==43&&lmx_int_value_known(lmx_arena_ref_value(v,1))==9&&lmx_int_value_known(lmx_arena_ref_value(v,2))==29,"actual read/address/write preserves both unconsumed fields");
  }else ck(0,"used field remains addressable");
 }
 lmx_arena_release(&a);
}
static void source_views(int consume_w){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *A=node(&a,2),*Alias=node(&a,2),*R=node(&a,2),*v=node(&a,3);
 for(size_t i=0;i<2;i++){integer(&a,A,i,0);integer(&a,Alias,i,0);integer(&a,R,i,0);}
 for(size_t i=0;i<3;i++)integer(&a,v,i,i==0?7:i==1?9:29);
 layout(&a,A,0);layout(&a,Alias,0);layout(&a,R,2);
 size_t p[]={0,1,0,1},q[]={0,2,0,2};LmxImplEntry e={0};e.n=2;e.map=p;
 ck(lmx_implements_admit_receiving(&a,v,A,&e,NULL)==LMX_IMPLEMENTS_YES,"first source-index-space reception");
 e.map=q;ck(lmx_implements_admit_receiving(&a,v,Alias,&e,NULL)==LMX_IMPLEMENTS_YES,"second source-index-space reception");
 LmxImplTemplate row={0};row.source_layout=tokens;row.required_layout=tokens+2;row.correspondence.n=2;row.correspondence.map=p;
 size_t cells[]={4,1,consume_w?1:0,0};LmxImplUses used={0};used.map=cells;
 int answer=lmx_implements_admit_templates(&a,v,R,&row,1,&used,1);
 ck(consume_w?answer!=LMX_IMPLEMENTS_YES:answer==LMX_IMPLEMENTS_YES,"composition uses the same alternative-coordinate operation, not a whole-source equality veto");
 lmx_arena_release(&a);
}
int main(void){
 previous_used_evidence_main();checks=failures=0;
 for(int order=0;order<2;order++)for(int half=0;half<2;half++)alternatives(order,half);
 source_views(0);source_views(1);
 printf("conditional receiving alternatives: %d checks, %d failures\n",checks,failures);return failures!=0;
}
