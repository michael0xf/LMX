#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "l2src/lmx_walk.lm1.h"
#include "l2src/lmx_implements.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
/* Internal activation-entry routine,linked from the actual120 runtime. */
extern int lmx_walk_args_open(LmxWalkFrame *);
static int checks,failures;
static Lmx *test_parent;
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL typed value context: %s\n",why);}}
static Lmx *node(LmxArena *a,size_t n){Lmx *v=lmx_node_new_owned(a);if(!v||(n&&lmx_arena_refs_open_owned(a,v,n)))abort();return v;}
static void put(Lmx *v,size_t i,void *p){if(lmx_arena_ref_store(v,i,p))abort();}
static void *number(LmxArena *a,int n){void *v=lmx_int_new_owned(a);if(!v||lmx_int_store_known(v,n))abort();return v;}
static void size_at(LmxArena *a,Lmx *v,size_t i,size_t n){void *p=lmx_size_new_owned(a);if(!p||lmx_size_store_known(p,n))abort();put(v,i,p);}
static void token_at(LmxArena *a,Lmx *v,size_t i,void *t){void *p=lmx_charptr_new_owned(a);if(!p||lmx_charptr_store_known(p,t))abort();put(v,i,p);}
static Lmx *pair(LmxArena *a,int x,int y){Lmx *v=node(a,2);put(v,0,number(a,x));put(v,1,number(a,y));return v;}
static size_t identity[]={0,1,0,1},reverse[]={1,0,1,0};
static char tokens[4];
static Lmx *candidate(LmxArena *a,Lmx *d,Lmx *e){Lmx *v=pair(a,7,9);LmxImplEntry m={0};m.n=2;m.map=identity;if(lmx_implements_admit_receiving(a,v,d,&m,NULL)!=LMX_IMPLEMENTS_YES||lmx_implements_admit_receiving(a,v,e,&m,NULL)!=LMX_IMPLEMENTS_YES)abort();return v;}
static Lmx *catalog(LmxArena *a,int required,int sources){Lmx *v=node(a,1+(size_t)sources*7);size_at(a,v,0,(size_t)sources);for(int i=0;i<sources;++i){size_t at=1+(size_t)i*7;token_at(a,v,at,tokens+i);token_at(a,v,at+1,tokens+required);size_at(a,v,at+2,2);size_t *map=i==1?reverse:identity;for(size_t j=0;j<4;++j)size_at(a,v,at+3+j,map[j]);}return v;}
static Lmx *record(LmxArena *a,Lmx *cat,Lmx *refs,Lmx *stored){Lmx *ctx=node(a,2);put(ctx,0,stored);put(ctx,1,refs);Lmx *v=node(a,5);put(v,0,cat);size_at(a,v,2,1);put(v,3,refs);put(v,4,ctx);return v;}
static size_t slot(LmxArena *a,Lmx *v,Lmx *model,size_t edge){size_t at=(size_t)-1;if(lmx_implements_slot(a,v,model,edge,&at))return (size_t)-1;return at;}
static int read_at(LmxArena *a,Lmx *v,Lmx *model,size_t edge){size_t at=slot(a,v,model,edge);return at==(size_t)-1?-10000:lmx_int_value_known(lmx_graph_value_in(a,v,at));}
static Lmx *op(LmxArena *a,Lmx *roles,int kind,size_t n){Lmx *v=lmx_walk_frame(a,roles,test_parent,kind,n);if(!v)abort();return v;}
static Lmx *admit(LmxArena *a,Lmx *roles,Lmx *r,Lmx *data,Lmx *value){Lmx *v=op(a,roles,LMX_WALK_OP_ADMIT_AS,5);put(v,1,data);put(v,3,value);put(v,4,r);return v;}
int main(void){
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*s=pair(a,0,0);
 Lmx *models[]={d,e,r,s};for(int i=0;i<4;++i)if(lmx_implements_register_map(a,models[i],models[i],NULL,0,tokens+i)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *refs=node(a,1);size_at(a,refs,0,0);
 Lmx *rr=record(a,catalog(a,2,2),refs,d),*rs=record(a,catalog(a,3,3),refs,d);
 void *closed=lmx_graph_value_in(a,rr,4),*backing=rr->array.data;
 LmxWalkValue value={0},out={0};Lmx *v=candidate(a,d,e);
 ck(lmx_walk_value_ref_parts(&value,LMX_TYPE_LMX,v,e,refs)==LMX_WALK_OK&&value.ref==v&&value.model==e&&value.references==refs,"one computed value carries the exact declared Model and sheet");
 ck(lmx_walk_value_storage(&value)==&value.ref&&sizeof(value.ref)==sizeof(void *),"ordinary value storage remains a real pointer object,not a fat pointer in the graph");
 LmxArenaBlock *mark=lmx_arena_mark(a);
 ck(lmx_walk_value_admit(a,&value,r,rr)==LMX_WALK_OK&&value.ref==v&&value.model==r&&value.references==refs,"native C consumes the current pair and returns the receiving Model");
 ck(read_at(a,v,r,0)==9&&read_at(a,v,r,2)==9&&read_at(a,v,r,1)==7,"CURRENT E overrides stored D and resolves real ordinal/LAST values");
 ck(lmx_arena_mark(a)==mark&&rr->array.data==backing&&lmx_graph_value_in(a,rr,4)==closed,"common admission allocates no context graph and never edits the shared record");
 ck(lmx_walk_value_admit(a,&value,s,rs)==LMX_WALK_OK&&value.model==s&&read_at(a,v,s,0)==9,"the next admission consumes R's carried namespace,not the record's D");
 void **address=lmx_graph_ref_cell_in(a,v,slot(a,v,s,0));
 ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,v,s,0)==41,"write follows the carried map's actual physical cell");
 if(address)*address=number(a,43);
 ck(read_at(a,v,s,0)==43&&read_at(a,v,s,1)==7,"taken-address replacement preserves the mapped value and neighbor");
 Lmx *roles=lmx_walk_roles_open(a),*host=node(a,1);if(!roles)abort();
 test_parent=host;
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,64)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext context={0};context.arena=a;context.roles=roles;context.scratch=&scratch;
 LmxWalkFrame f={0};f.context=&context;f.arena=a;f.roles=roles;f.node=f.code=f.source=host;
 LmxWalkValue source={0};Lmx *w=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,w,e,refs);f.guarded=&source;
 Lmx *guarded=op(a,roles,LMX_WALK_OP_GUARDED,1),*ar=admit(a,roles,r,rr,guarded);
 ck(lmx_walk_eval(&f,ar,&out)==LMX_WALK_OK&&out.ref==w&&out.model==r&&out.references==refs,"walked ADMIT uses the same current-value helper as native C");
 ck(read_at(a,w,r,0)==9&&source.model==e&&source.ref==w,"walked admission selects E without mutating its source operand");
 Lmx *own=op(a,roles,LMX_WALK_OP_OWN,3);put(own,1,host);size_at(a,own,2,0);
 ck(lmx_walk_work_make(&f,own,host,0,lmx_arena_ref_cell(host,0))==LMX_WALK_OK&&f.work&&!f.work->model&&!f.work->references,"entry loading creates an unqualified row,not a guessed constructor namespace");
 Lmx *set=op(a,roles,LMX_WALK_OP_SET,3);put(set,1,own);put(set,2,ar);
 ck(lmx_walk_eval(&f,set,&out)==LMX_WALK_OK&&f.work->model==r&&f.work->references==refs&&f.work->dirty,"SET retains the admitted pair with its activation-local reference");
 ck(lmx_graph_value_in(a,host,0)==NULL,"typed working assignment does not publish an extra graph field or value early");
 ck(lmx_walk_eval(&f,own,&out)==LMX_WALK_OK&&out.ref==w&&out.model==r&&out.references==refs,"OWN reads that exact pair,not a reconstructed source");
 Lmx *as=admit(a,roles,s,rs,own);
 ck(lmx_walk_eval(&f,as,&out)==LMX_WALK_OK&&out.model==s&&read_at(a,w,s,0)==9,"a second walked receiver consumes the Model carried through SET/OWN");
 ck(lmx_walk_publish(&f)==LMX_WALK_OK&&lmx_graph_value_in(a,host,0)==w&&!f.work->dirty,"checkpoint publishes only the ordinary reference into its selected graph slot");
 ck(lmx_walk_eval(&f,own,&out)==LMX_WALK_OK&&out.model==r&&out.references==refs,"publication does not discard activation-local declared context");
 void *caller=NULL;void *arguments[]={&caller};f.args=arguments;f.nargs=1;
 ck(lmx_walk_args_open(&f)==LMX_WALK_OK&&f.argown,"input storage is allocated at the new typed-value size");
 Lmx *av=candidate(a,d,e);lmx_walk_value_ref_parts(&value,LMX_TYPE_LMX,av,e,refs);if(lmx_walk_value_admit(a,&value,r,rr)!=LMX_WALK_OK)abort();
 ck(lmx_walk_arg_write(&f,0,LMX_TYPE_LMX,&value,&out)==LMX_WALK_OK&&out.model==r&&f.argown[0].model==r&&!caller,"input rebinding preserves its current pair without changing caller storage");
 Lmx *arg=op(a,roles,LMX_WALK_OP_ARG,4);size_at(a,arg,1,0);put(arg,3,r);
 ck(lmx_walk_eval(&f,arg,&out)==LMX_WALK_OK&&out.ref==av&&out.model==r&&out.references==refs,"ARG reads the activation's retained pair after rebinding");
 ck(lmx_walk_eval(&f,admit(a,roles,s,rs,arg),&out)==LMX_WALK_OK&&read_at(a,av,s,0)==9,"reference input consumption keeps R's map instead of falling back to D");
 ck(lmx_walk_arg_write(&f,0,LMX_TYPE_LMX,&value,&value)==LMX_WALK_OK&&value.model==r&&value.references==refs,"in-place input write/output alias keeps metadata across the raw load");
 LmxWalkFrame df=f;void *missing[]={NULL};df.args=missing;df.argown=NULL;
 Lmx *dv=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,dv,e,refs);
 ck(lmx_walk_args_open(&df)==LMX_WALK_OK,"default-input activation owns separate typed storage");
 Lmx *default_arg=op(a,roles,LMX_WALK_OP_ARG,4);size_at(a,default_arg,1,0);put(default_arg,2,ar);put(default_arg,3,r);
 ck(lmx_walk_eval(&df,default_arg,&out)==LMX_WALK_OK&&out.ref==dv&&out.model==r&&df.argown[0].model==r,"evaluated-once default admission retains its pair in the input place");
 ck(lmx_walk_eval(&df,admit(a,roles,s,rs,default_arg),&out)==LMX_WALK_OK&&read_at(a,dv,s,0)==9,"a default input's subsequent receiver observes its current Model");
 Lmx *ret=op(a,roles,LMX_WALK_OP_RET,2);put(ret,1,default_arg);
 ck(lmx_walk_eval(&df,ret,&out)==LMX_WALK_OK&&df.returned&&df.result.model==r&&out.model==r&&out.references==refs,"RET and its copied typed result retain the pair inside the activation");
 Lmx *bad=candidate(a,d,e);lmx_walk_value_ref_parts(&value,LMX_TYPE_LMX,bad,e,NULL);
 ck(lmx_walk_value_admit(a,&value,r,rr)==LMX_WALK_THROWN+LMX_WALK_NAME_IMPLEMENTS&&!lmx_implements_find(a,bad,r),"malformed PRESENT context cannot recover the record's valid D context");
 lmx_walk_value_ref(&value,LMX_TYPE_LMX,bad);
 ck(!value.model&&!value.references&&lmx_walk_value_admit(a,&value,r,rr)==LMX_WALK_OK&&read_at(a,bad,r,0)==7,"unannotated legacy values still consume their explicit ordinary graph-data context");
 lmx_walk_value_ref_parts(&value,LMX_TYPE_LMX,NULL,e,refs);
 ck(lmx_walk_value_admit(a,&value,r,rr)==LMX_WALK_OK&&!value.ref&&value.model==r&&value.references==refs,"present null keeps the receiver's declared context without inventing a graph value");
 lmx_walk_value_num(&value,LMX_TYPE_INT,5);ck(!value.model&&!value.references,"numeric construction clears reference context");
 lmx_walk_value_ref_parts(&value,LMX_TYPE_LMX,v,e,refs);void *raw=v;
 ck(lmx_walk_value_load(a,&raw,LMX_TYPE_LMX,&value)==LMX_WALK_OK&&value.ref==v&&!value.model&&!value.references,"raw pointer storage does not fabricate a giving namespace from its payload");
 lmx_walk_value_clear(&value);ck(!value.present&&!value.model&&!value.references,"absence clears the complete typed value");
 Lmx *receiver_refs=node(a,1);size_at(a,receiver_refs,0,0);
 Lmx *other_rr=record(a,catalog(a,2,2),receiver_refs,d),*another=candidate(a,d,e);
 lmx_walk_value_ref_parts(&value,LMX_TYPE_LMX,another,e,refs);
 ck(lmx_walk_value_admit(a,&value,r,other_rr)==LMX_WALK_OK&&value.references==receiver_refs&&value.references!=refs,"successful reception replaces the source sheet by this receiver's actual ordinary sheet");
 lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,candidate(a,d,e),e,refs);
 ck(lmx_walk_eval(&f,admit(a,roles,r,other_rr,guarded),&out)==LMX_WALK_OK&&out.model==r&&out.references==receiver_refs,"walked output also carries the receiver sheet,not a source/prototype sheet");
 ck(rr->array.data==backing&&lmx_graph_value_in(a,rr,4)==closed,"native/walker/working/input tests leave every shared receiving record unchanged");
 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("typed reference value context: %d checks, %d failures\n",checks,failures);return failures!=0;
}
