#define main preceding_typed_fixture_main
#include "C:/Nyasha_Planet/LMX/build/codex_declared92_kernel_test_01.c"
#undef main
#include "l2src/lmx_graph_copy_owned.lm1.h"
typedef struct ReceivingFixture { LmxArena arena;Lmx *root,*d,*e,*r,*v,*record,*context,*source_refs; } ReceivingFixture;
static Lmx *empty_refs(LmxArena *a){Lmx *n=node(a,1);sizecell(a,n,0,0);return n;}
static void fresh(ReceivingFixture *f,int reverse){
 memset(f,0,sizeof *f);if(lmx_arena_open(&f->arena))abort();LmxArena *a=&f->arena;
 f->root=node(a,5);f->d=node(a,2);f->e=node(a,2);f->r=node(a,2);f->v=node(a,2);f->record=node(a,5);
 for(size_t i=0;i<2;++i){integer(a,f->d,i,0);integer(a,f->e,i,0);integer(a,f->r,i,0);}
 integer(a,f->v,0,7);integer(a,f->v,1,9);layout(a,f->d,0);layout(a,f->e,1);layout(a,f->r,2);
 bind(a,f->v,reverse?f->e:f->d,reverse?swap:ident);bind(a,f->v,reverse?f->d:f->e,reverse?ident:swap);
 put(f->root,0,f->r);put(f->root,1,f->e);put(f->root,2,f->d);put(f->root,3,f->v);put(f->root,4,f->record);
 Lmx *catalog=node(a,15);sizecell(a,catalog,0,2);
 for(size_t i=0;i<2;++i){size_t at=1+7*i;token(a,catalog,at,tokens+(reverse?1-i:i));token(a,catalog,at+1,tokens+2);sizecell(a,catalog,at+2,2);for(size_t j=0;j<4;++j)sizecell(a,catalog,at+3+j,ident[j]);}
 put(f->record,0,catalog);sizecell(a,f->record,2,1);put(f->record,3,empty_refs(a));
 f->context=node(a,2);f->source_refs=empty_refs(a);put(f->context,0,f->e);put(f->context,1,f->source_refs);put(f->record,4,f->context);
}
static void actual(ReceivingFixture *f){
 size_t at=99;void *address=NULL;
 ck(lmx_implements_admit_receiving_frame(&f->arena,f->v,f->r,f->record)==LMX_IMPLEMENTS_YES,"current ordinary record resolves its explicit giving namespace through the common typed kernel");
 ck(!lmx_implements_slot(&f->arena,f->v,f->r,0,&at)&&at==1,"frame/catalog composition produces the actual physical address once");
 if(at<2)address=lmx_arena_ref_value(f->v,at);
 ck(address&&lmx_int_value_known(address)==9&&!lmx_int_store_known(address,41)&&lmx_int_value_known(address)==41&&!lmx_int_store_known(address,43)&&lmx_int_value_known(lmx_arena_ref_value(f->v,0))==7,"native common frame read9/write41/address43 preserves sibling7");
 ck(lmx_implements_layout(&f->arena,f->v)==NULL,"giving context does not fabricate candidate origin");
}
static void malformed(int reverse){
 ReceivingFixture f;fresh(&f,reverse);actual(&f);
 LmxImplEntry saved=*lmx_implements_find(&f.arena,f.v,f.r);size_t before=f.arena.impl_len;
 put(f.context,0,NULL);
 ck(lmx_implements_admit_receiving_frame(&f.arena,f.v,f.r,f.record)==LMX_IMPLEMENTS_UNKNOWN,"present context without a Model is malformed, not absence or cached success");put(f.context,0,f.e);
 sizecell(&f.arena,f.source_refs,0,1);
 ck(lmx_implements_admit_receiving_frame(&f.arena,f.v,f.r,f.record)==LMX_IMPLEMENTS_UNKNOWN,"malformed source-reference extent refuses even when this Consumer reads no pointer");sizecell(&f.arena,f.source_refs,0,0);
 put(f.record,4,f.v);
 ck(lmx_implements_admit_receiving_frame(&f.arena,f.v,f.r,f.record)==LMX_IMPLEMENTS_UNKNOWN,"an arbitrary two-field value is not a valid source context merely by apparent width");put(f.record,4,f.context);
 ck(before==f.arena.impl_len&&!memcmp(&saved,lmx_implements_find(&f.arena,f.v,f.r),sizeof saved),"malformed current data never mutates an already accepted map or permission");
 lmx_arena_release(&f.arena);
}
static void absence_and_legacy(void){
 ReceivingFixture f;fresh(&f,0);put(f.record,4,NULL);size_t before=f.arena.impl_len;
 ck(lmx_implements_admit_receiving_frame(&f.arena,f.v,f.r,f.record)!=LMX_IMPLEMENTS_YES&&before==f.arena.impl_len,"explicitly absent context does not choose one of two contradictory bound interpretations");
 Lmx *old=node(&f.arena,4);for(size_t i=0;i<4;++i)put(old,i,lmx_arena_ref_value(f.record,i));
 ck(lmx_implements_admit_receiving_frame(&f.arena,f.v,f.r,old)==LMX_IMPLEMENTS_UNKNOWN&&before==f.arena.impl_len,"old record4 is not retained as an alternate decoder");lmx_arena_release(&f.arena);
}
static void copy_context(void){
 ReceivingFixture f;fresh(&f,1);LmxArena target={0};if(lmx_arena_open(&target))abort();Lmx *root=NULL;
 ck(lmx_graph_copy_owned(f.root,&f.arena,&target,&root)==LMX_GRAPH_COPY_OK&&root,"ordinary graph copy carries the Model and source-contract data, with no context-specific copier");
 if(!root){lmx_arena_release(&f.arena);lmx_arena_release(&target);return;}
 Lmx *e=lmx_arena_ref_struct(root,1),*r=lmx_arena_ref_struct(root,0),*v=lmx_arena_ref_struct(root,3),*record=lmx_arena_ref_struct(root,4);
 Lmx *context=lmx_arena_ref_struct(record,4);
 ck(e&&context&&lmx_arena_ref_struct(context,0)==e&&e!=f.e,"copied receiving context names the copied current Model, not a source ancestor");
 ck(!lmx_implements_find(&target,v,r),"copy has no target permission before its own receiving operation");
 lmx_arena_release(&f.arena);
 ck(lmx_implements_admit_receiving_frame(&target,v,r,record)==LMX_IMPLEMENTS_YES,"copied source contract still answers after release of the complete original arena");
 size_t at=99;void *address=NULL;if(!lmx_implements_slot(&target,v,r,0,&at)&&at<2)address=lmx_arena_ref_value(v,at);
 ck(address&&lmx_int_value_known(address)==9&&!lmx_int_store_known(address,43)&&lmx_int_value_known(lmx_arena_ref_value(v,0))==7,"copied declared namespace applies to real read/address-write values");lmx_arena_release(&target);
}

static int reached(ReceivingFixture *f,int framed,Lmx *req){
 if(framed)return lmx_implements_admit_receiving_frame(&f->arena,f->v,req,f->record);
 LmxImplTemplate t[2];row(t,0,2,ident);row(t+1,1,2,ident);
 return lmx_implements_admit_templates_typed(&f->arena,f->v,req,t,2,NULL,1,lmx_arena_ref_struct(f->record,3),lmx_arena_ref_struct(f->context,0),f->source_refs);
}
static void stable_typed(int framed){
 ReceivingFixture f;fresh(&f,framed);actual(&f);
 LmxImplEntry saved=*lmx_implements_find(&f.arena,f.v,f.r);size_t before=f.arena.impl_len;
 void *changed=lmx_char_new_owned(&f.arena);if(!changed)abort();put(f.v,1,changed);
 int repeated=reached(&f,framed,f.r);
 ck(repeated==LMX_IMPLEMENTS_YES&&before==f.arena.impl_len&&!memcmp(&saved,lmx_implements_find(&f.arena,f.v,f.r),sizeof saved),"unchanged full receiving requirement reuses the established proof with the same typed source context, like the original untyped stable16 contract");
 put(f.context,0,f.d);
 int other_source=reached(&f,framed,f.r);
 ck(other_source==LMX_IMPLEMENTS_YES&&before==f.arena.impl_len&&!memcmp(&saved,lmx_implements_find(&f.arena,f.v,f.r),sizeof saved),"a different giving context cannot reselect or replace the already established receiving correspondence");
 put(f.context,0,f.e);
 Lmx *new_required=node(&f.arena,2);integer(&f.arena,new_required,0,0);integer(&f.arena,new_required,1,0);layout(&f.arena,new_required,2);
 ck(reached(&f,framed,new_required)==LMX_IMPLEMENTS_NO&&!lmx_implements_find(&f.arena,f.v,new_required),"a fresh required role still examines actual incompatible data, even with the same source context");
 void *new_type=lmx_size_new_owned(&f.arena);if(!new_type)abort();put(f.r,0,new_type);
 ck(reached(&f,framed,f.r)==LMX_IMPLEMENTS_NO&&!memcmp(&saved,lmx_implements_find(&f.arena,f.v,f.r),sizeof saved),"changed CURRENT receiving requirements are not authorized by the previous full proof");
 printf("typed stable route=%d repeat=%d other-source=%d\n",framed,repeated,other_source);
 lmx_arena_release(&f.arena);
}
int main(void){stable_typed(0);stable_typed(1);printf("typed stable full proof: %d checks, %d failures\n",checks,failures);return failures!=0;}
