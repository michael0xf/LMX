#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main source_projection_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,parsers,roots,folds;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){(void)site;if(!watching)return;if(fn==(void*)l2_path_steps_operand||fn==(void*)l2_reference_fields)++parsers;if(fn==(void*)l2_path_root_resolve)++roots;if(fn==(void*)l2_path_walk_steps_from)++folds;}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void expect(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL resolved source projection: %s\n",why);}}
static void prepared(L2Path *p,L2PathStep *steps,int n,int indexed){
 memset(p,0,sizeof *p);memset(steps,0,(size_t)n*sizeof *steps);
 p->n=p->cap=n;p->steps=steps;p->leaf_model=5;p->leaf_kind=indexed?13:10;
 p->leaf_mi=p->leaf_ty=l2_graph_code();p->indexed=indexed;
 for(int i=0;i<n;++i){steps[i].formal=steps[i].node_host=steps[i].own=steps[i].nsrow=-1;}
 steps[n-1].kind=indexed?13:10;steps[n-1].locus=indexed?7:1;
 steps[n-1].elem_model=5;steps[n-1].elem_ty=l2_graph_code();
}
static void kept(const L2Path *p,int method,int place,const char *why){
 L2ReferenceSource out;memset(&out,0x71,sizeof out);
 int result=l2_reference_source_of_path(p,&out);
 expect(!result&&out.schema==5,why);
 expect(!result&&out.layout==-1&&out.method==method&&out.place==place&&out.origin==NULL&&out.origin_count==0,"projected logical Model never fabricates physical origin, a declaration row, or another source expression");
}
int main(void){
 int live=l2_alloc_live,kinds[]={10};size_t models[]={6};
 l2_e=3;l2_ns_n=6;l2_nsf_n=1;l2_nsf_kind=kinds;l2_nsf_val=models;
 L2Path p;L2PathStep steps[129];
 prepared(&p,steps,1,0);steps[0].nsrow=0;
 kept(&p,l2_e,l2_d105_field_key(0),"an ordinary field retains its prepared Model and real source flow key");
 prepared(&p,steps,1,0);
 kept(&p,-1,-1,"a composed reference without a named NSF row still retains the common resolver's leaf Model");
 prepared(&p,steps,1,1);
 kept(&p,-1,-1,"an indexed reference uses the already resolved element Model, without another index or type lookup");
 prepared(&p,steps,129,1);p.names=64;p.indexed=65;
 for(int i=0;i<128;++i){steps[i].locus=i%2?7:1;steps[i].kind=i%2?13:10;}
 kept(&p,-1,-1,"an arbitrary-depth mixed prepared path is the same leaf projection, with no shape/depth branch");
 L2ReferenceSource out;
 p.fail_why=2;
 expect(l2_reference_source_of_path(&p,&out)==1,"a refused path is not accepted using a leftover leaf snapshot");
 p.fail_why=0;p.array_leaf=1;
 expect(l2_reference_source_of_path(&p,&out)==1,"whole Array storage is not silently interpreted as its declared element Model");
 p.array_leaf=0;p.leaf_model=-1;p.leaf_ty=0;
 expect(l2_reference_source_of_path(&p,&out)==1,"a primitive or opaque element has no invented Structure model");
 prepared(&p,steps,1,0);steps[0].nsrow=0;l2_own_n=INT_MAX;
 expect(l2_reference_source_of_path(&p,&out)==1&&l2_alloc_err==2,"flow-key exhaustion remains an index/allocation error, not a synthetic result key");
 l2_own_n=0;l2_alloc_err=0;
 expect(l2_alloc_live==live,"projecting the common result allocates no path, Model copy, or parser record");
 L2Path root;l2_path_init("selected",8,&root);root.fi=3;root.ni=5;
 /* An invalid-to-dereference requirement owner makes any substitution of
    its declaration for the ACTUAL hidden input visible in this test. */
 root.root_contract_own=INT_MAX;
 watching=1;int status=l2_reference_record_source(&root,9,&out);watching=0;
 expect(!status&&out.schema==5&&out.layout==-1&&out.method==9&&out.place==3,"selected hidden/formal source is its current input,never its lexical requirement declaration");
 expect(!parsers&&!roots&&!folds,"whole input source consumes the selected root without another adapter,binding or field fold");
 root.fi=-1;root.res=2;root.ni=-1;
 watching=1;status=l2_reference_record_source(&root,9,&out);watching=0;
 expect(!status&&out.schema==l2_schema_merge(2)&&out.layout==-1&&out.method==-1&&out.place==-1,"composed root keeps its existing logical schema without fabricated constructor identity");
 root.res=-1;root.ni=5;
 watching=1;status=l2_reference_record_source(&root,9,&out);watching=0;
 expect(!status&&out.schema==5&&out.layout==5&&out.method==-1&&out.place==-1,"only an original constructor root denotes its existing physical layout");
 for(int kind=1;kind<=6;++kind){root.root_kind=kind;root.ni=-1;root.root=1;watching=1;status=l2_reference_record_source(&root,9,&out);watching=0;expect(status==1&&out.schema==-1&&out.layout==-1&&out.method==-1&&out.place==-1,"method,node,control,machine and external roots acquire no invented return/source model");}
 prepared(&p,steps,129,1);p.names=64;p.indexed=65;
 watching=1;status=l2_reference_record_source(&p,9,&out);watching=0;
 expect(!status&&out.schema==5&&out.layout==-1&&out.method==-1&&out.place==-1,"arbitrary-depth mixed path is the same source projection as a whole root,with no private grammar route");
 p.fail_why=2;
 watching=1;status=l2_reference_record_source(&p,9,&out);watching=0;
 expect(status==1&&out.schema==-1&&out.layout==-1&&out.method==-1&&out.place==-1,"refused current path discards all old source metadata and never retries source selection");
 expect(!parsers&&!roots&&!folds&&l2_alloc_live==live,"root and terminal projections allocate no replacement grammar,lookup or semantic walk");
 printf("SOURCE163 record projection: %d checks, %d failures\n",checks,failures);
 return failures!=0;
}
