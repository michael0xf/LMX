#include "l2src/lmx_implements.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include "l2src/lmx_graph_copy_owned.lm1.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
static int checks,failures;
static char tokens[8];
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL contract dependencies: %s\n",why);}}
static Lmx *node(LmxArena *a,size_t n){Lmx *p=lmx_node_new_owned(a);if(!p||lmx_arena_refs_open_owned(a,p,n))abort();return p;}
static void put(Lmx *n,size_t i,void *v){if(lmx_arena_ref_store(n,i,v))abort();}
static void integer(LmxArena *a,Lmx *n,size_t i,int v){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,v))abort();put(n,i,p);}
static void character(LmxArena *a,Lmx *n,size_t i){void *p=lmx_char_new_owned(a);if(!p)abort();put(n,i,p);}
static void sz(LmxArena *a,Lmx *n,size_t i,size_t v){void *p=lmx_size_new_owned(a);if(!p||lmx_size_store_known(p,v))abort();put(n,i,p);}
static void tok(LmxArena *a,Lmx *n,size_t i,char *v){void *p=lmx_charptr_new_owned(a);if(!p||lmx_charptr_store_known(p,v))abort();put(n,i,p);}
static void layout(LmxArena *a,Lmx *n,int t){if(lmx_implements_register_map(a,n,n,NULL,0,tokens+t)!=LMX_IMPLEMENTS_YES)abort();}
static int full(LmxArena *a,Lmx *v,Lmx *m){return lmx_implements_admit_templates(a,v,m,NULL,0,NULL,1);}
static void *readptr(void *p){return *(Lmx **)p;}
static int writeptr(void *p,void *v){*(Lmx **)p=v;return 0;}
static void *pointer(LmxArena *a,Lmx *v){void *p=lmx_pointer_new_typed_profiled(LMX_TYPE_POINTER_BASE+100,a,NULL,sizeof(Lmx *),readptr,writeptr);if(!p||lmx_pointer_store_in(a,p,v))abort();return p;}
static void row(LmxArena *a,Lmx *table,size_t at,size_t field,Lmx *model){tok(a,table,at,tokens);sz(a,table,at+1,field);put(table,at+2,model);}
static void primitive_and_extent(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();Lmx *m=node(&a,2),*v=node(&a,2);
 integer(&a,m,0,1);integer(&a,m,1,2);integer(&a,v,0,7);integer(&a,v,1,9);layout(&a,m,0);layout(&a,v,0);
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES,"original full two-field contract succeeds");
 LmxImplEntry *e=lmx_implements_find(&a,v,m);LmxImplContract *first=e?e->contract:NULL;
 ck(first&&first->owners==1&&first->facts.array.len<=first->facts.capacity,"stored key owns a complete typed DynamicArray");
 integer(&a,m,0,99);integer(&a,v,0,41);
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES&&e->contract==first,"primitive values and replacement cells do not change the required type key");
 character(&a,m,0);size_t before=a.impl_len;
 ck(full(&a,v,m)==LMX_IMPLEMENTS_NO&&a.impl_len==before&&e->contract==first,"a changed required primitive type is a new refusal, not stale full permission");
 integer(&a,m,0,0);
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES&&e->contract==first,"restoring the same semantic requirements can reuse the still-valid proof");
 m->array.size=1;
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES,"a valid shorter requirement is freshly admitted");
 ck(e->contract!=first&&e->contract->facts.array.len==2&&e->contract->owners==1&&e->n==1,
    "requirement shrink updates the key, model extent AND semantic map count together");
 m->array.size=2;
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES&&e->n==2&&e->contract->facts.array.len==3,"restoring width rebuilds one coherent current record");
 lmx_arena_release(&a);
}
static void nested(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *m=node(&a,1),*v=node(&a,1),*leaf=node(&a,1),*actual=node(&a,1),*changed=node(&a,1);
 integer(&a,leaf,0,0);integer(&a,actual,0,7);character(&a,changed,0);put(m,0,leaf);put(v,0,actual);
 layout(&a,m,0);layout(&a,v,0);layout(&a,leaf,1);layout(&a,actual,1);layout(&a,changed,2);
 size_t identity[]={0,0};LmxImplTemplate t={0};t.source_layout=tokens+1;t.required_layout=tokens+2;t.correspondence.map=identity;t.correspondence.n=1;
 ck(lmx_implements_admit_templates(&a,v,m,&t,1,NULL,1)==LMX_IMPLEMENTS_YES,"owned child shares the prepared requirement closure");
 LmxImplEntry *e=lmx_implements_find(&a,v,m);LmxImplContract *key=e?e->contract:NULL;size_t before=a.impl_len;
 put(m,0,changed);
 ck(lmx_implements_admit_templates(&a,v,m,&t,1,NULL,1)==LMX_IMPLEMENTS_NO&&a.impl_len==before&&e->contract==key,"replacing an owned required model invalidates full reuse without publishing child maps");
 put(m,0,leaf);character(&a,leaf,0);
 ck(lmx_implements_admit_templates(&a,v,m,&t,1,NULL,1)==LMX_IMPLEMENTS_NO&&e->contract==key,"an in-place nested required type change is also a changed contract");
 integer(&a,leaf,0,0);
 ck(lmx_implements_admit_templates(&a,v,m,&t,1,NULL,1)==LMX_IMPLEMENTS_YES&&e->contract==key,"same nested type with a new primitive cell is not a new requirement");
 lmx_arena_release(&a);
}
static void references(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *m=node(&a,2),*v=node(&a,2),*ma=node(&a,1),*mb=node(&a,1),*va=node(&a,1),*vb=node(&a,1);
 integer(&a,ma,0,0);character(&a,mb,0);integer(&a,va,0,7);character(&a,vb,0);
 put(m,0,pointer(&a,NULL));put(m,1,pointer(&a,NULL));put(v,0,pointer(&a,va));put(v,1,pointer(&a,vb));
 layout(&a,m,0);layout(&a,v,0);layout(&a,ma,1);layout(&a,va,1);layout(&a,mb,2);layout(&a,vb,2);
 Lmx *f=node(&a,7);sz(&a,f,0,2);row(&a,f,1,0,ma);row(&a,f,4,1,mb);
 size_t identity[]={0,0};LmxImplTemplate t={0};t.source_layout=tokens+1;t.required_layout=tokens+2;t.correspondence.map=identity;t.correspondence.n=1;
 ck(lmx_implements_admit_templates_contracts(&a,v,m,&t,1,NULL,1,f)==LMX_IMPLEMENTS_YES,"two declared pointees are part of one full contract");
 LmxImplEntry *e=lmx_implements_find(&a,v,m);LmxImplContract *key=e?e->contract:NULL;size_t before=a.impl_len;
 row(&a,f,1,1,mb);row(&a,f,4,0,ma);
 ck(lmx_implements_admit_templates_contracts(&a,v,m,&t,1,NULL,1,f)==LMX_IMPLEMENTS_YES&&e->contract==key,"reference row order is representation, not a different receiving requirement");
 put(m,0,pointer(&a,mb));
 ck(lmx_implements_admit_templates_contracts(&a,v,m,&t,1,NULL,1,f)==LMX_IMPLEMENTS_YES&&e->contract==key,"the mutable default pointer does not replace the declared pointee contract");
 Lmx *conflict=node(&a,10);sz(&a,conflict,0,3);row(&a,conflict,1,0,ma);row(&a,conflict,4,1,mb);row(&a,conflict,7,0,mb);
 ck(lmx_implements_admit_templates_contracts(&a,v,m,&t,1,NULL,1,conflict)==LMX_IMPLEMENTS_UNKNOWN&&a.impl_len==before,"conflicting current declarations are UNKNOWN even after full proof");
 row(&a,f,4,0,mb);
 ck(lmx_implements_admit_templates_contracts(&a,v,m,&t,1,NULL,1,f)==LMX_IMPLEMENTS_NO&&a.impl_len==before&&e->contract==key,"changed current pointee types get their own admission and preserve old state on refusal");
 lmx_arena_release(&a);
}
static void ownership(void){
 LmxArena a={0},b={0};if(lmx_arena_open(&a)||lmx_arena_open(&b))abort();
 Lmx *m=node(&a,1),*v=node(&a,1);integer(&a,m,0,0);integer(&a,v,0,7);layout(&a,m,0);layout(&a,v,0);size_t before=a.impl_len;
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES,"ownership fixture has a real full proof");
 LmxImplContract *key=lmx_implements_find(&a,v,m)->contract;
 lmx_arena_impl_contract_retain(key);
 ck(key->owners==2,"an explicit retained metadata reference is counted");
 lmx_arena_impl_truncate(&a,before);
 ck(key->owners==1&&!lmx_implements_find(&a,v,m),"truncate releases only the removed entry's metadata ownership");
 lmx_arena_impl_contract_release(key);
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES,"the same value can receive a fresh proof after rollback");
 key=lmx_implements_find(&a,v,m)->contract;
 ck(lmx_arena_attach(&b,&a)==0&&key->owners==1&&a.impl_len==0&&lmx_implements_find(&b,v,m)->contract==key,
    "arena attach transfers stored-entry ownership exactly once");
 integer(&b,v,0,41);
 ck(full(&b,v,m)==LMX_IMPLEMENTS_YES&&lmx_implements_find(&b,v,m)->contract==key,"moved current dependencies still validate at their unchanged physical addresses");
 lmx_arena_impl_contract_retain(key);lmx_arena_release(&b);
 ck(key->owners==1,"arena release releases its proof references without freeing a separately retained key");
 lmx_arena_impl_contract_release(key);lmx_arena_release(&a);
}
static void layout_enrichment(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *m=node(&a,1),*v=node(&a,1);integer(&a,m,0,0);integer(&a,v,0,7);
 ck(lmx_implements_admit_receiving(&a,v,m,NULL,NULL)==LMX_IMPLEMENTS_YES,"explicit coordinate admission establishes a full type requirement before classification");
 LmxImplContract *key=lmx_implements_find(&a,v,m)->contract;
 character(&a,v,0);
 ck(lmx_implements_admit_receiving(&a,v,m,NULL,NULL)==LMX_IMPLEMENTS_YES,"changing only a value preserves the unclassified full requirement");
 ck(lmx_implements_register_map(&a,m,m,NULL,0,tokens+3)==LMX_IMPLEMENTS_YES,"current required graph receives real physical classification without changing its fields");
 LmxImplEntry *e=lmx_implements_find(&a,v,m);
 ck(lmx_implements_admit_receiving(&a,v,m,NULL,NULL)==LMX_IMPLEMENTS_YES&&e->contract==key,"physical classification enrichment is not a new semantic requirement or a value recheck");
 lmx_arena_release(&a);
}
static void deep_contract(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();Lmx *m[129],*v[129];
 for(size_t i=0;i<129;++i){m[i]=node(&a,1);v[i]=node(&a,1);layout(&a,m[i],4);layout(&a,v[i],4);}
 for(size_t i=0;i<128;++i){put(m[i],0,m[i+1]);put(v[i],0,v[i+1]);}
 integer(&a,m[128],0,0);integer(&a,v[128],0,7);
 ck(full(&a,v[0],m[0])==LMX_IMPLEMENTS_YES,"129 nested required owners use the same finite closure, without a shallow contract limit");
 LmxImplContract *key=lmx_implements_find(&a,v[0],m[0])->contract;
 ck(key&&key->facts.array.len==258&&key->facts.capacity>=258,"every deep owner and field is retained once after dynamic growth");
 size_t before=a.impl_len;character(&a,m[128],0);
 ck(full(&a,v[0],m[0])==LMX_IMPLEMENTS_NO&&a.impl_len==before&&lmx_implements_find(&a,v[0],m[0])->contract==key,"deep changed type invalidates reuse and refuses with all completed entries untouched");
 integer(&a,m[128],0,0);
 ck(full(&a,v[0],m[0])==LMX_IMPLEMENTS_YES&&lmx_implements_find(&a,v[0],m[0])->contract==key,"restored deep requirement reuses the original semantic contract");
 lmx_arena_release(&a);
}
static void cyclic_contract(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();Lmx *m=node(&a,1),*v=node(&a,1);
 put(m,0,m);put(v,0,v);layout(&a,m,5);layout(&a,v,5);
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES,"cyclic current requirements reach a finite shared full admission");
 LmxImplContract *key=lmx_implements_find(&a,v,m)->contract;
 ck(key&&key->facts.array.len==2,"cycle closure deduplicates the same owner, not an ancestor graph snapshot");
 integer(&a,m,0,0);size_t before=a.impl_len;
 ck(full(&a,v,m)==LMX_IMPLEMENTS_NO&&a.impl_len==before&&lmx_implements_find(&a,v,m)->contract==key,"changing a cycle edge to a required primitive is not stale permission");
 lmx_arena_release(&a);
}
static void copied_contract(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();Lmx *m=node(&a,1),*v=node(&a,1),*copy=NULL,*holder=node(&a,1),*copied_holder=NULL;
 integer(&a,m,0,0);integer(&a,v,0,7);layout(&a,m,6);layout(&a,v,6);
 ck(full(&a,v,m)==LMX_IMPLEMENTS_YES,"copy fixture starts from a real current requirement");
 LmxImplContract *key=lmx_implements_find(&a,v,m)->contract;
 /* A composition root receives its own layout. Test the retained nested graph. */
 put(holder,0,v);
 int result=lmx_graph_copy_owned(holder,&a,&a,&copied_holder);
 copy=copied_holder?(Lmx *)lmx_arena_ref_value(copied_holder,0):NULL;
 LmxImplEntry *e=copy?lmx_implements_find(&a,copy,m):NULL;
 ck(result==0&&copy&&copy!=v&&e&&!e->contract&&key->owners==1,"relocated graph copies correspondences, not old proof dependency addresses or ownership");
 ck(full(&a,copy,m)==LMX_IMPLEMENTS_YES&&lmx_implements_find(&a,copy,m)->contract&&lmx_implements_find(&a,copy,m)->contract!=key,"copy obtains a separate full key through the same admission");
 character(&a,copy,0);
 ck(full(&a,copy,m)==LMX_IMPLEMENTS_YES&&lmx_implements_find(&a,v,m)->contract==key&&key->owners==1,"copied value mutation preserves its own proof without changing the source key");
 lmx_arena_release(&a);
}
int main(void){primitive_and_extent();nested();references();ownership();layout_enrichment();deep_contract();cyclic_contract();copied_contract();printf("current contract dependencies: %d checks, %d failures\n",checks,failures);return failures!=0;}
