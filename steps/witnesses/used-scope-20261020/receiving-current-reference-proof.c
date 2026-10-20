#include "l2src/lmx_implements.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include <stdio.h>
#include <stdlib.h>
static char tokens[3];
static Lmx *node(LmxArena *a,size_t n){Lmx *p=lmx_node_new_owned(a);if(!p||lmx_arena_refs_open_owned(a,p,n))abort();return p;}
static void put(Lmx *n,size_t i,void *v){if(lmx_arena_ref_store(n,i,v))abort();}
static void integer(LmxArena *a,Lmx *n,size_t i,int v){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,v))abort();put(n,i,p);}
static void sizecell(LmxArena *a,Lmx *n,size_t i,size_t v){void *p=lmx_size_new_owned(a);if(!p||lmx_size_store_known(p,v))abort();put(n,i,p);}
static void tokencell(LmxArena *a,Lmx *n,size_t i,char *v){void *p=lmx_charptr_new_owned(a);if(!p||lmx_charptr_store_known(p,v))abort();put(n,i,p);}
static void layout(LmxArena *a,Lmx *n,int t){if(lmx_implements_register_map(a,n,n,NULL,0,tokens+t)!=LMX_IMPLEMENTS_YES)abort();}
static void *readptr(void *p){return *(Lmx **)p;}
static int writeptr(void *p,void *v){*(Lmx **)p=v;return 0;}
static void *pointer(LmxArena *a,Lmx *v){void *p=lmx_pointer_new_typed_profiled(LMX_TYPE_POINTER_BASE+100,a,NULL,sizeof(Lmx *),readptr,writeptr);if(!p||lmx_pointer_store_in(a,p,v))abort();return p;}
int main(void){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *req=node(&a,1),*value=node(&a,1),*leaf_a=node(&a,1),*leaf_b=node(&a,1),*actual=node(&a,1);
 integer(&a,leaf_a,0,0);integer(&a,actual,0,7);put(leaf_b,0,lmx_char_new_owned(&a));
 put(req,0,pointer(&a,NULL));put(value,0,pointer(&a,actual));
 layout(&a,req,0);layout(&a,value,0);layout(&a,leaf_a,1);layout(&a,actual,1);layout(&a,leaf_b,2);
 Lmx *contracts=node(&a,4);sizecell(&a,contracts,0,1);tokencell(&a,contracts,1,tokens);sizecell(&a,contracts,2,0);put(contracts,3,leaf_a);
 size_t identity[]={0,0};LmxImplTemplate t={0};t.source_layout=tokens+1;t.required_layout=tokens+2;t.correspondence.map=identity;t.correspondence.n=1;
 int first=lmx_implements_admit_templates_contracts(&a,value,req,&t,1,NULL,1,contracts);
 LmxImplEntry *entry=lmx_implements_find(&a,value,req);size_t before=a.impl_len;
 /* Change the CURRENT required reference contract, not a candidate value.
    The same root address is no proof of unchanged receiving requirements. */
 put(contracts,3,leaf_b);
 int changed=lmx_implements_admit_templates_contracts(&a,value,req,&t,1,NULL,1,contracts);
 int ok=first==LMX_IMPLEMENTS_YES&&entry&&entry->reception_proof==2&&changed==LMX_IMPLEMENTS_NO&&a.impl_len==before&&!lmx_implements_find(&a,actual,leaf_b);
 printf("current reference requirement: first=%d full=%d changed=%d wanted=%d no-publication=%d result=%s\n",first,entry?entry->reception_proof:-1,changed,LMX_IMPLEMENTS_NO,a.impl_len==before,ok?"GREEN":"RED");
 lmx_arena_release(&a);return !ok;
}
