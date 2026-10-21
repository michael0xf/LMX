#define main preceding_typed_fixture_main
#include "C:/Nyasha_Planet/LMX/build/codex_declared92_kernel_test_01.c"
#undef main
#include "l2src/lmx_array_owned.lm1.h"
static size_t one_index[]={0,0};
static Lmx *refarray(LmxArena *a){Lmx *p=lmx_array_new_typed_profiled(LMX_TYPE_ARRAY_OF_POINTER_BASE+100,1,a,NULL,sizeof(Lmx *),read_pointer,write_pointer);if(!p)abort();return p;}
static void mixed(size_t depth,int last,int bad){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx **s=calloc(depth+1,sizeof *s),**r=calloc(depth+1,sizeof *r),**v=calloc(depth+1,sizeof *v);
 LmxImplTemplate *rows=calloc(depth+2,sizeof *rows);size_t *coverage=calloc(2+3*(depth+1),sizeof *coverage);
 if(!s||!r||!v||!rows||!coverage)abort();
 Lmx *d=node(&a,2);s[depth]=node(&a,2);r[depth]=node(&a,2);v[depth]=node(&a,2);
 for(size_t i=0;i<2;++i){integer(&a,d,i,0);integer(&a,s[depth],i,0);integer(&a,r[depth],i,0);}
 integer(&a,v[depth],0,7);integer(&a,v[depth],1,9);layout(&a,d,0);layout(&a,s[depth],1);layout(&a,r[depth],2);
 bind(&a,v[depth],d,ident);bind(&a,v[depth],s[depth],swap);
 row(rows+depth,0,2,ident);row(rows+depth+1,1,2,ident);
 Lmx *st=node(&a,1+3*depth),*rt=node(&a,1+3*depth);sizecell(&a,st,0,depth);sizecell(&a,rt,0,depth);
 for(size_t i=depth;i-->0;){
  int indexed=(i%2)==0;size_t source_field=indexed?0:1;
  s[i]=indexed?refarray(&a):node(&a,2);r[i]=indexed?refarray(&a):node(&a,2);v[i]=indexed?refarray(&a):node(&a,2);
  layout(&a,s[i],3+2*(int)i);layout(&a,r[i],4+2*(int)i);
  if(indexed){if(lmx_pointer_store_in(&a,lmx_array_cell_in(&a,v[i],0),v[i+1]))abort();}
  else{integer(&a,s[i],0,0);put(s[i],1,pointer(&a,NULL));put(r[i],0,pointer(&a,NULL));integer(&a,r[i],1,0);put(v[i],0,pointer(&a,v[i+1]));integer(&a,v[i],1,29);}
  if(lmx_implements_register_map(&a,v[i],s[i],indexed?one_index:swap,indexed?1:2,NULL)!=LMX_IMPLEMENTS_YES)abort();
  row(rows+i,3+2*(int)i,4+2*(int)i,indexed?one_index:swap);rows[i].correspondence.n=indexed?1:2;
  token(&a,st,1+3*i,tokens+3+2*i);sizecell(&a,st,2+3*i,source_field);put(st,3+3*i,s[i+1]);
  token(&a,rt,1+3*i,tokens+4+2*i);sizecell(&a,rt,2+3*i,0);put(rt,3+3*i,r[i+1]);
 }
 if(bad){void *p=lmx_char_new_owned(&a);if(!p)abort();put(v[depth],1,p);}
 coverage[0]=2+3*(depth+1);
 for(size_t i=0;i<=depth;++i){size_t at=1+3*i;coverage[at]=1;coverage[at+1]=last?r[i]->array.size:0;coverage[at+2]=i<depth?at+3:0;}
 LmxImplUses uses={0};uses.map=coverage;size_t before=a.impl_len;
 int answer=lmx_implements_admit_templates_typed(&a,v[0],r[0],rows,depth+2,&uses,1,rt,s[0],st);
 ck(answer==(bad?LMX_IMPLEMENTS_NO:LMX_IMPLEMENTS_YES),"one typed DFS follows arbitrarily interleaved Array index/reference/Structure steps");
 if(bad)ck(before==a.impl_len&&!lmx_implements_find(&a,v[0],r[0]),"the wrong mixed deep leaf publishes no prefix relation");
 else{
  size_t slot=99;
  for(size_t i=0;i<depth;++i){
   ck(!lmx_implements_slot(&a,v[i],r[i],last?r[i]->array.size:0,&slot)&&slot==0,"mixed step is a resolved physical coordinate, not a second mapping input");
   ck(lmx_pointer_value_in(&a,lmx_graph_value_in(&a,v[i],slot))==v[i+1],"mixed step holds the actual next graph Structure");
  }
  void *address=NULL;if(!lmx_implements_slot(&a,v[depth],r[depth],0,&slot)&&slot<2)address=lmx_arena_ref_value(v[depth],slot);
  ck(address&&lmx_int_value_known(address)==9&&!lmx_int_store_known(address,43)&&lmx_int_value_known(lmx_arena_ref_value(v[depth],0))==7,"deep mixed selected address reads9 then writes43, preserving sibling7");
 }
 free(coverage);free(rows);free(s);free(r);free(v);lmx_arena_release(&a);
}
int main(void){mixed(0,0,0);mixed(1,0,0);mixed(129,0,0);mixed(129,1,0);mixed(129,0,1);printf("typed mixed kernel: %d checks, %d failures\n",checks,failures);return failures!=0;}
