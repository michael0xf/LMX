#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define main l2_frontend_unused_main
#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#include L2_FRONTEND_SOURCE
#undef main
static int type_checks,type_failures;
static void type_ck(int yes,const char *why){++type_checks;if(!yes){++type_failures;fprintf(stderr,"FAIL closed pointer value type: %s\n",why);}}
int main(void){
 const char *names[]={"char","size_t","int","void","unsigned","ulong"};
 int expected[2][6]={{12,9,11,16,25,38},{17,20,19,18,24,39}};
 for(int level=1;level<=2;++level)for(int k=0;k<6;++k){
  LmP0Text word={0},parts={0};word.data=(char *)names[k];word.length=strlen(names[k]);
  int core=-1,closed=-1,depth=-1,qualified=-1;
  type_ck(l2_core_pointer_type(&word,level,&core)==0&&core==expected[level-1][k],"the one core table supplies every builtin pointer depth1/2");
  type_ck(l2_ptr_type_word(&word,level,&closed)==0&&closed==core,"source pointer typing delegates to the same table");
  type_ck(l2_type_parts(core,&parts,&depth,&qualified)==0&&depth==level&&!qualified&&parts.length==word.length&&!memcmp(parts.data,word.data,word.length),"the closed type projects back to its actual C pointer contract");
  int abi=l2_foreign_intern(&word,level,0);
  type_ck(abi>=100&&l2_result_value_ty(abi)==core,"legacy return ABI tags produce the SAME consumed value and witness type");
 }
 int value=-1,before=l2_foreign_n;LmP0Text raw={0};raw.data="c.Foo";raw.length=5;
 type_ck(l2_core_pointer_type(NULL,1,&value)==2,"core table rejects a missing word");
 type_ck(l2_ptr_type_word(NULL,1,&value)==2,"source wrapper retains its missing-word precondition");
 type_ck(l2_ptr_type_word(&raw,1,NULL)==2,"missing output cannot enter namespace/foreign resolution");
 type_ck(l2_core_pointer_type(&raw,1,NULL)==2,"core table rejects a missing output");
 type_ck(l2_foreign_n==before,"invalid lookups do not intern types");
 raw.data="c.void";raw.length=6;int foreign=l2_foreign_intern(&raw,2,0);
 type_ck(foreign>=100&&l2_foreign_raw_c[foreign-100]&&l2_result_value_ty(foreign)==foreign,"the explicit c. door remains a distinct closed type");
 raw.data="void";raw.length=4;int constant=l2_foreign_intern(&raw,2,1);
 type_ck(constant>=100&&l2_result_value_ty(constant)==constant,"qualification is not erased by builtin canonical projection");
 type_ck(l2_result_value_ty(3)==12&&l2_result_value_ty(35)==3&&l2_result_value_ty(32)==17,"existing char return ABI adapters retain their correct value types");
 raw.data="c.ExternalValue";raw.length=strlen(raw.data);int aggregate=l2_foreign_intern(&raw,0,0);
 type_ck(aggregate>=100&&l2_result_value_ty(aggregate)==aggregate,"a foreign aggregate does not become a pointer");
 type_ck(l2_core_pointer_type(&raw,1,&value)==2,"the core table is not a Model or foreign-name resolver");
 printf("closed pointer value type: %d checks, %d failures\n",type_checks,type_failures);
 return type_failures!=0;
}
