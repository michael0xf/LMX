#include "l2src/lmx_implements.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
static int checks, failures;
static char tokens[300];
static void ck(int ok,const char *why){++checks;if(!ok){++failures;fprintf(stderr,"FAIL declared source: %s\n",why);}}
static Lmx *node(LmxArena *a,size_t n){Lmx *p=lmx_node_new_owned(a);if(!p||lmx_arena_refs_open_owned(a,p,n))abort();return p;}
static void put(Lmx *v,size_t i,void *p){if(lmx_arena_ref_store(v,i,p))abort();}
static void integer(LmxArena *a,Lmx *v,size_t i,int n){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,n))abort();put(v,i,p);}
static void sizecell(LmxArena *a,Lmx *v,size_t i,size_t n){void *p=lmx_size_new_owned(a);if(!p||lmx_size_store_known(p,n))abort();put(v,i,p);}
static void token(LmxArena *a,Lmx *v,size_t i,void *n){void *p=lmx_charptr_new_owned(a);if(!p||lmx_charptr_store_known(p,n))abort();put(v,i,p);}
static void *read_pointer(void *p){return *(Lmx **)p;}
static int write_pointer(void *p,void *v){*(Lmx **)p=v;return 0;}
static void *pointer(LmxArena *a,Lmx *v){void *p=lmx_pointer_new_typed_profiled(LMX_TYPE_POINTER_BASE+100,a,NULL,sizeof(Lmx *),read_pointer,write_pointer);if(!p||lmx_pointer_store_in(a,p,v))abort();return p;}
static void layout(LmxArena *a,Lmx *v,int t){if(lmx_implements_register_map(a,v,v,NULL,0,tokens+t)!=LMX_IMPLEMENTS_YES)abort();}
static size_t ident[]={0,1,0,1},swap[]={1,0,1,0};
static void bind(LmxArena *a,Lmx *v,Lmx *m,size_t *map){LmxImplEntry e={0};e.map=map;e.n=2;if(lmx_implements_admit_receiving(a,v,m,&e,NULL)!=LMX_IMPLEMENTS_YES)abort();}
static void row(LmxImplTemplate *r,int s,int t,size_t *map){memset(r,0,sizeof *r);r->source_layout=tokens+s;r->required_layout=tokens+t;r->correspondence.n=2;r->correspondence.map=map;}
static void root_case(int reverse,int selected){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *d=node(&a,2),*e=node(&a,2),*r=node(&a,2),*v=node(&a,2),*fake=node(&a,2);
 for(size_t i=0;i<2;++i){integer(&a,d,i,0);integer(&a,e,i,0);integer(&a,r,i,0);integer(&a,fake,i,0);}
 integer(&a,v,0,7);integer(&a,v,1,9);layout(&a,d,0);layout(&a,e,1);layout(&a,r,2);layout(&a,fake,3);
 bind(&a,v,reverse?e:d,reverse?swap:ident);bind(&a,v,reverse?d:e,reverse?ident:swap);
 LmxImplTemplate t[2];row(t+reverse,0,2,ident);row(t+!reverse,1,2,ident);
 Lmx *source=selected==1?e:selected==2?fake:NULL;
 size_t before=a.impl_len;
 int answer=lmx_implements_admit_templates_typed(&a,v,r,t,2,NULL,1,NULL,source,NULL);
 printf("root order=%d selected=%d answer=%d\n",reverse,selected,answer);
 ck(selected==1?answer==LMX_IMPLEMENTS_YES:answer!=LMX_IMPLEMENTS_YES,"only the current evidenced giving namespace disambiguates, independent of insertion order");
 ck(lmx_implements_layout(&a,v)==NULL,"declared namespace does not invent physical origin");
 if(selected==1){
  size_t at=99;void *p=NULL;
  ck(!lmx_implements_slot(&a,v,r,0,&at)&&at==1,"logical giving coordinate is composed once, into physical slot1");
  if(at<2)p=lmx_arena_ref_value(v,at);
  ck(p&&lmx_int_value_known(p)==9&&!lmx_int_store_known(p,41)&&lmx_int_value_known(p)==41,"read and write use the selected actual primitive");
  void *address=p;ck(address&&!lmx_int_store_known(address,43)&&lmx_int_value_known(lmx_arena_ref_value(v,1))==43&&lmx_int_value_known(lmx_arena_ref_value(v,0))==7,"dereferencing the taken address changes v, not its sibling");
  LmxImplEntry saved=*lmx_implements_find(&a,v,r);before=a.impl_len;
  ck(lmx_implements_admit_templates_typed(&a,v,r,t,2,NULL,1,NULL,d,NULL)!=LMX_IMPLEMENTS_YES&&before==a.impl_len&&!memcmp(&saved,lmx_implements_find(&a,v,r),sizeof saved),"another declared interpretation cannot overwrite established positive coordinates");
 }else ck(before==a.impl_len&&!lmx_implements_find(&a,v,r),"refusal publishes no target map or proof");
 lmx_arena_release(&a);
}
static void deep_case(size_t depth,int use_pointers,int bad){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx **s=calloc(depth+1,sizeof *s),**r=calloc(depth+1,sizeof *r),**v=calloc(depth+1,sizeof *v);
 LmxImplTemplate *rows=calloc(depth+2,sizeof *rows);
 size_t *scope=calloc(2+3*(depth+1),sizeof *scope);
 if(!s||!r||!v||!rows||!scope)abort();
 Lmx *other=node(&a,2);integer(&a,other,0,0);integer(&a,other,1,0);layout(&a,other,0);
 for(size_t i=0;i<=depth;++i){s[i]=node(&a,2);r[i]=node(&a,2);v[i]=node(&a,2);layout(&a,s[i],1+2*(int)i);layout(&a,r[i],2+2*(int)i);}
 integer(&a,s[depth],0,0);integer(&a,s[depth],1,0);integer(&a,r[depth],0,0);integer(&a,r[depth],1,0);
 integer(&a,v[depth],0,7);integer(&a,v[depth],1,9);
 bind(&a,v[depth],other,ident);bind(&a,v[depth],s[depth],swap);
 row(rows+depth,1+2*(int)depth,2+2*(int)depth,ident);
 row(rows+depth+1,0,2+2*(int)depth,ident);
 Lmx *source_refs=node(&a,use_pointers?1+3*depth:1),*target_refs=node(&a,use_pointers?1+3*depth:1);
 sizecell(&a,source_refs,0,use_pointers?depth:0);sizecell(&a,target_refs,0,use_pointers?depth:0);
 for(size_t i=depth;i-->0;){
  integer(&a,s[i],0,0);integer(&a,r[i],1,0);integer(&a,v[i],1,29);
  put(s[i],1,use_pointers?pointer(&a,NULL):(void *)s[i+1]);
  put(r[i],0,use_pointers?pointer(&a,NULL):(void *)r[i+1]);
  put(v[i],0,use_pointers?pointer(&a,v[i+1]):(void *)v[i+1]);
  bind(&a,v[i],s[i],swap);
  row(rows+i,1+2*(int)i,2+2*(int)i,swap);
  if(use_pointers){
   token(&a,source_refs,1+3*i,tokens+1+2*i);sizecell(&a,source_refs,2+3*i,1);put(source_refs,3+3*i,s[i+1]);
   token(&a,target_refs,1+3*i,tokens+2+2*i);sizecell(&a,target_refs,2+3*i,0);put(target_refs,3+3*i,r[i+1]);
  }
 }
 if(bad){void *p=lmx_char_new_owned(&a);if(!p)abort();put(v[depth],1,p);}
 scope[0]=2+3*(depth+1);
 for(size_t i=0;i<=depth;++i){size_t at=1+3*i;scope[at]=1;scope[at+1]=i%2?2:0;scope[at+2]=i<depth?at+3:0;}
 LmxImplUses uses={0};uses.map=scope;size_t before=a.impl_len;
 int answer=lmx_implements_admit_templates_typed(&a,v[0],r[0],rows,depth+2,&uses,1,target_refs,s[0],source_refs);
 ck(answer==(bad?LMX_IMPLEMENTS_NO:LMX_IMPLEMENTS_YES),"the same typed DFS transports source declarations across arbitrary-depth Structure/reference edges and both map halves");
 if(bad)ck(before==a.impl_len&&!lmx_implements_find(&a,v[0],r[0]),"a wrong deep leaf keeps all prefix correspondences unpublished");
 else {
  size_t slot=99;void *address=NULL;
  for(size_t i=0;i<depth;++i){
   ck(!lmx_implements_slot(&a,v[i],r[i],i%2?2:0,&slot)&&slot==0,"each nested logical projection is physical exactly once");
   void *child=lmx_arena_ref_value(v[i],slot);
   ck((use_pointers?lmx_pointer_value_in(&a,child):child)==v[i+1],"selected nested object is the actual held value");
  }
  if(!lmx_implements_slot(&a,v[depth],r[depth],0,&slot)&&slot<2)address=lmx_arena_ref_value(v[depth],slot);
  ck(address&&lmx_int_value_known(address)==9&&!lmx_int_store_known(address,43)&&lmx_int_value_known(lmx_arena_ref_value(v[depth],0))==7,"deep selected address observes9 then writes43 and preserves7");
 }
 free(scope);free(rows);free(s);free(r);free(v);lmx_arena_release(&a);
}
static void alias_conflict(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *d=node(&a,2),*e=node(&a,2),*r=node(&a,2),*v=node(&a,2),*sroot=node(&a,2),*rroot=node(&a,2),*vroot=node(&a,2);
 for(size_t i=0;i<2;++i){integer(&a,d,i,0);integer(&a,e,i,0);integer(&a,r,i,0);}
 integer(&a,v,0,7);integer(&a,v,1,9);layout(&a,d,0);layout(&a,e,1);layout(&a,r,2);layout(&a,sroot,3);layout(&a,rroot,4);
 bind(&a,v,d,ident);bind(&a,v,e,swap);
 for(size_t i=0;i<2;++i){put(sroot,i,pointer(&a,NULL));put(rroot,i,pointer(&a,NULL));put(vroot,i,pointer(&a,v));}
 bind(&a,vroot,sroot,ident);
 Lmx *st=node(&a,7),*rt=node(&a,7);sizecell(&a,st,0,2);sizecell(&a,rt,0,2);
 for(size_t i=0;i<2;++i){token(&a,st,1+3*i,tokens+3);sizecell(&a,st,2+3*i,i);put(st,3+3*i,i?d:e);token(&a,rt,1+3*i,tokens+4);sizecell(&a,rt,2+3*i,i);put(rt,3+3*i,r);}
 LmxImplTemplate t[3];row(t,0,2,ident);row(t+1,1,2,ident);row(t+2,3,4,ident);
 size_t before=a.impl_len;
 int answer=lmx_implements_admit_templates_typed(&a,vroot,rroot,t,3,NULL,1,rt,sroot,st);
 ck(answer!=LMX_IMPLEMENTS_YES&&before==a.impl_len&&!lmx_implements_find(&a,vroot,rroot)&&!lmx_implements_find(&a,v,r),"incompatible giving paths of the same pending pair refuse atomically, never YES with a null prepared view");
 lmx_arena_release(&a);
}
int main(void){
 for(int reverse=0;reverse<2;++reverse)for(int selected=0;selected<3;++selected)root_case(reverse,selected);
 deep_case(0,0,0);deep_case(1,0,0);deep_case(129,0,0);deep_case(1,1,0);deep_case(129,1,0);deep_case(129,1,1);
 alias_conflict();
 printf("typed giving kernel: %d checks, %d failures\n",checks,failures);return failures!=0;
}
