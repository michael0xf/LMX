#define main preceding_typed_fixture_main
#include "C:/Nyasha_Planet/LMX/build/codex_declared92_kernel_test_01.c"
#undef main
#include "l2src/lmx_array_owned.lm1.h"
static void indexed_case(int last,int bad){
 LmxArena a={0};if(lmx_arena_open(&a))abort();
 Lmx *d=node(&a,2),*e=node(&a,2),*r=node(&a,2),*v=node(&a,2);
 Lmx *sroot=node(&a,2),*rroot=node(&a,2),*vroot=node(&a,2);
 for(size_t i=0;i<2;++i){integer(&a,d,i,0);integer(&a,e,i,0);integer(&a,r,i,0);}
 integer(&a,v,0,7);integer(&a,v,1,9);layout(&a,d,0);layout(&a,e,1);layout(&a,r,2);
 bind(&a,v,d,ident);bind(&a,v,e,swap);
 LmxArray *sa=lmx_array_new_typed_profiled(LMX_TYPE_ARRAY_OF_POINTER_BASE+100,3,&a,NULL,sizeof(Lmx *),read_pointer,write_pointer);
 LmxArray *ra=lmx_array_new_typed_profiled(LMX_TYPE_ARRAY_OF_POINTER_BASE+100,3,&a,NULL,sizeof(Lmx *),read_pointer,write_pointer);
 LmxArray *va=lmx_array_new_typed_profiled(LMX_TYPE_ARRAY_OF_POINTER_BASE+100,3,&a,NULL,sizeof(Lmx *),read_pointer,write_pointer);
 if(!sa||!ra||!va||lmx_pointer_store_in(&a,lmx_array_cell_in(&a,va,1),v))abort();
 layout(&a,sa,5);layout(&a,ra,6);layout(&a,sroot,3);layout(&a,rroot,4);
 size_t array_map[]={0,1,2,0,1,2};
 if(lmx_implements_register_map(&a,va,sa,array_map,3,NULL)!=LMX_IMPLEMENTS_YES)abort();
 integer(&a,sroot,0,0);put(sroot,1,sa);put(rroot,0,ra);integer(&a,rroot,1,0);
 put(vroot,0,va);integer(&a,vroot,1,29);bind(&a,vroot,sroot,swap);
 Lmx *st=node(&a,4),*rt=node(&a,4);sizecell(&a,st,0,1);sizecell(&a,rt,0,1);
 token(&a,st,1,tokens+5);sizecell(&a,st,2,1);put(st,3,e);
 token(&a,rt,1,tokens+6);sizecell(&a,rt,2,1);put(rt,3,r);
 LmxImplTemplate t[4];row(t,0,2,ident);row(t+1,1,2,ident);row(t+2,3,4,swap);row(t+3,5,6,array_map);t[3].correspondence.n=3;
 if(bad){void *p=lmx_char_new_owned(&a);if(!p)abort();put(v,1,p);}
 size_t coverage[]={10,1,0,4,1,last?4:1,7,1,0,0};LmxImplUses uses={0};uses.map=coverage;
 size_t before=a.impl_len;
 int answer=lmx_implements_admit_templates_typed(&a,vroot,rroot,t,4,&uses,1,rt,sroot,st);
 printf("indexed last=%d bad=%d answer=%d\n",last,bad,answer);
 ck(answer==(bad?LMX_IMPLEMENTS_NO:LMX_IMPLEMENTS_YES),"an explicitly entered Array index/reference continues the SAME typed DFS instead of only comparing its Array storage type");
 if(bad)ck(before==a.impl_len&&!lmx_implements_find(&a,vroot,rroot),"a bad leaf behind an Array index refuses before any prefix publication");
 else{
  size_t slot=99;void *address=NULL;
  ck(!lmx_implements_slot(&a,va,ra,last?4:1,&slot)&&slot==1&&lmx_pointer_value_in(&a,lmx_graph_value_in(&a,va,slot))==v,"the indexed projection selects the actual pointer cell and held child");
  if(!lmx_implements_slot(&a,v,r,0,&slot)&&slot<2)address=lmx_arena_ref_value(v,slot);
  ck(address&&lmx_int_value_known(address)==9&&!lmx_int_store_known(address,43)&&lmx_int_value_known(lmx_arena_ref_value(v,0))==7&&lmx_int_value_known(lmx_arena_ref_value(vroot,1))==29,"indexed declared correspondence reads9 then address-writes43, preserving7 and pad29");
 }
 lmx_arena_release(&a);
}
int main(void){for(int last=0;last<2;++last){indexed_case(last,0);indexed_case(last,1);}printf("typed indexed kernel: %d checks, %d failures\n",checks,failures);return failures!=0;}
