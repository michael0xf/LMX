#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef CELL133_SOURCE
#error Define CELL133_SOURCE to this profile's generated unit.c
#endif
#include CELL133_SOURCE
#undef main
struct token133 { int n; };
static int writes133,rejected133,wrong133,fail133_enabled;
static void *typed133_read(void *p){return *(struct token133 **)p;}
static int typed133_write(void *p,void *v){++writes133;*(struct token133 **)p=(struct token133 *)v;return 0;}
static int fail133_write(void *p,void *v){if(fail133_enabled){++rejected133;return 1;}*(struct token133 **)p=(struct token133 *)v;return 0;}
static int wrong133_write(void *p,void *v){(void)p;(void)v;++wrong133;return 1;}
static int canonical133_write(void *p,void *v){++writes133;*(void **)p=v;return 0;}
int main(void){
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *d=node(a,1),*e=node(a,1),*sheet=node(a,1);
 int ty=LMX_TYPE_POINTER_BASE+16;
 struct token133 first={7},second={9};struct token133 *external=&first;
 LmxWalkValue prior={0},giving={0},owner={0},saved={0};
 lmx_walk_value_ref_parts(&prior,ty,&first,d,sheet);
 lmx_walk_value_ref_parts(&giving,ty,&second,e,sheet);giving.referent=&saved;
 owner=prior;
 ck(lmx_value_cell_store(a,&external,&owner,&second,&giving,typed133_write)==0&&writes133==1&&external==&second,"unowned native C pointer cell is written exactly once through its exact struct token* accessor");
 ck(owner.model==e&&owner.references==sheet&&owner.referent==&saved,"the same physical store publishes the complete explicit CURRENT owner state");
 ck(giving.model==e&&giving.references==sheet&&giving.referent==&saved,"the giving context is not mutated by store");
 ck(lmx_value_cell_store(a,&external,&owner,&second,0,typed133_write)==0&&writes133==2&&external==&second,"SAME-address raw replacement still performs only one exact typed write");
 ck(!owner.model&&!owner.references&&!owner.referent,"SAME-address raw replacement clears every previous context component");
 owner=prior;fail133_enabled=1;
 ck(lmx_value_cell_store(a,&external,&owner,&first,&giving,fail133_write)==1&&rejected133==1&&external==&second,"rejected physical store leaves the actual payload unchanged");
 ck(owner.model==d&&owner.references==sheet&&!owner.referent,"rejected physical store publishes no giving state");
 ck(lmx_value_cell_store(a,&external,&owner,&first,&giving,0)==1&&external==&second&&owner.model==d,"an unowned C object without an exact producer-supplied accessor is not guessed to be void*");
 owner=giving;
 ck(lmx_value_cell_store(a,&external,&owner,&first,&owner,typed133_write)==0&&writes133==3&&external==&first,"input context may alias the explicit destination owner");
 ck(owner.model==e&&owner.references==sheet&&owner.referent==&saved,"aliased owner retains the pre-write giving state");
 int before133=writes133;
 void *typed=lmx_pointer_new_typed_profiled(ty,a,NULL,sizeof(struct token133 *),typed133_read,typed133_write);
 if(!typed)abort();
 ck(writes133==before133+1&&typed133_read(typed)==NULL,"the typed pool constructor initializes its own actual C pointer object once before store measurements");writes133=before133;
 owner=prior;
 ck(lmx_value_cell_store(a,typed,&owner,&second,&giving,wrong133_write)==0&&writes133==4&&!wrong133&&typed133_read(typed)==&second,"owned C pointer storage always uses its pool's exact accessor,not a competing native spelling");
 LmxWalkValue *stored=lmx_pointer_cell_context(a,typed);
 ck(stored&&stored->model==e&&stored->references==sheet&&stored->referent==&saved&&owner.model==e,"owned companion and distinct explicit resolved owner publish the same current state");
 ck(lmx_value_cell_store(a,typed,stored,&first,stored,wrong133_write)==0&&writes133==5&&!wrong133&&typed133_read(typed)==&first,"giving,explicit owner and stored companion may be the SAME record without losing state");
 ck(stored->model==e&&stored->references==sheet&&stored->referent==&saved,"same-record store snapshots the complete giving context");
 ck(lmx_pointer_store_in(a,typed,&first)==0&&writes133==6&&!stored->model&&!stored->references&&!stored->referent,"legacy raw pointer-pool API delegates to the same operation and clears SAME-address state");
 ck(lmx_pointer_store_context_in(a,typed,&second,&giving)==0&&writes133==7&&stored->model==e,"the existing contextual pointer-pool API delegates to that same exact typed store");
 LmxWalkPlace place={0};place.address=place.storage=typed;place.type=ty;place.context=&owner;
 ck(lmx_walk_value_store(a,&place,&giving)==LMX_WALK_OK&&writes133==8&&stored->model==e&&owner.model==e,"walker resolved-place writes consume the common physical/state operation");
 lmx_walk_value_ref_parts(&giving,ty,NULL,d,sheet);
 ck(lmx_walk_value_store(a,&place,&giving)==LMX_WALK_OK&&writes133==9&&typed133_read(typed)==NULL,"explicit present-null is one exact write,not an absent store");
 ck(stored->model==d&&stored->references==sheet&&owner.model==d,"present-null preserves the declared current namespace in both destination owners");
 fail133_enabled=0;
 void *failing=lmx_pointer_new_typed_profiled(ty,a,NULL,sizeof(struct token133 *),typed133_read,fail133_write);
 if(!failing)abort();fail133_enabled=1;LmxWalkValue *failed_context=lmx_pointer_cell_context(a,failing);*failed_context=prior;
 owner=prior;
 ck(lmx_value_cell_store(a,failing,&owner,&second,&giving,typed133_write)==1&&rejected133==2&&writes133==9,"pool's rejected accessor remains authoritative even when native supplies a successful competing writer");
 ck(failed_context->model==d&&owner.model==d,"failed owned-cell store preserves both previous destination contexts");
 void *canonical=NULL;owner=prior;
 ck(lmx_value_cell_store(a,&canonical,&owner,&first,&prior,canonical133_write)==0&&canonical==&first&&writes133==10&&owner.model==d,"an actual void* C object uses the same protocol with its own canonical accessor");
 ck(lmx_value_cell_store(a,NULL,&owner,NULL,&giving,typed133_write)==1&&writes133==10&&owner.model==d,"absent target neither invokes a writer nor publishes state");
 ck(lmx_pointer_store_context_in(a,&canonical,&first,&giving)==1&&writes133==10,"the old owned-pool API does not acquire a new unowned-address fallback");
 lmx_arena_release(a);
 printf("common physical value store: %d checks, %d failures\n",checks,failures);
 return failures!=0;
}
