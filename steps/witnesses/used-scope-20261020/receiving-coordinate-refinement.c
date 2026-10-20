#define main original_evidence_main
#include "C:/Nyasha_Planet/LMX/steps/witnesses/used-scope-20261020/receiving-used-proof-equivalence.c"
#undef main
#include <string.h>
static size_t bridge_full[]={0,1,0,1},bridge_short[]={0,SIZE_MAX,0,SIZE_MAX};
typedef struct Fixture {
 LmxArena arena;Lmx *whole,*shorter,*required,*value;
 size_t complete[4],prefix[2];LmxImplTemplate rows[2];
} Fixture;
static void fresh(Fixture *f){
 memset(f,0,sizeof *f);if(lmx_arena_open(&f->arena))abort();
 f->whole=node(&f->arena,2);f->shorter=node(&f->arena,1);f->required=node(&f->arena,2);f->value=node(&f->arena,3);
 integer(&f->arena,f->whole,0,0);integer(&f->arena,f->whole,1,0);integer(&f->arena,f->shorter,0,0);
 integer(&f->arena,f->required,0,0);integer(&f->arena,f->required,1,0);
 integer(&f->arena,f->value,0,29);integer(&f->arena,f->value,1,7);integer(&f->arena,f->value,2,9);
 layout(&f->arena,f->whole,0);layout(&f->arena,f->shorter,1);layout(&f->arena,f->required,2);layout(&f->arena,f->value,3);
 f->complete[0]=f->complete[2]=1;f->complete[1]=f->complete[3]=2;f->prefix[0]=f->prefix[1]=1;
 LmxImplEntry e={0};e.map=f->complete;e.n=2;e.layout=tokens+3;
 ck(lmx_implements_admit_receiving(&f->arena,f->value,f->whole,&e,NULL)==LMX_IMPLEMENTS_YES,"full source fixture is genuinely admitted");
 e.map=f->prefix;e.n=1;
 ck(lmx_implements_admit_receiving(&f->arena,f->value,f->shorter,&e,NULL)==LMX_IMPLEMENTS_YES,"short source fixture is genuinely admitted");
 f->rows[0].source_layout=tokens;f->rows[0].required_layout=tokens+2;f->rows[0].correspondence.map=bridge_full;f->rows[0].correspondence.n=2;
 f->rows[1].source_layout=tokens+1;f->rows[1].required_layout=tokens+2;f->rows[1].correspondence.map=bridge_short;f->rows[1].correspondence.n=2;
}
static int slots(Fixture *f){
 size_t x=0,y=0,z=0,w=0;
 return !lmx_implements_slot(&f->arena,f->value,f->required,0,&x)&&x==1&&
        !lmx_implements_slot(&f->arena,f->value,f->required,1,&y)&&y==2&&
        !lmx_implements_slot(&f->arena,f->value,f->required,2,&z)&&z==1&&
        !lmx_implements_slot(&f->arena,f->value,f->required,3,&w)&&w==2;
}
static void ordered(int reverse){
 Fixture f;fresh(&f);LmxImplTemplate rows[2]={f.rows[reverse?1:0],f.rows[reverse?0:1]};
 size_t cells[]={4,1,0,0};LmxImplUses uses={0};uses.map=cells;
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,rows,2,&uses,1)==LMX_IMPLEMENTS_YES,"compatible complete/partial evidence admits in either order");
 LmxImplEntry *e=lmx_implements_find(&f.arena,f.value,f.required);
 ck(e&&e->n==2&&slots(&f),"all known ordinal/LAST coordinates survive the same join");
 size_t at=0;void *address=NULL;
 if(!lmx_implements_slot(&f.arena,f.value,f.required,0,&at))address=lmx_arena_ref_value(f.value,at);
 ck(address==lmx_arena_ref_value(f.value,1)&&lmx_int_value_known(address)==7&&!lmx_int_store_known(address,43)&&
    lmx_int_value_known(lmx_arena_ref_value(f.value,1))==43&&lmx_int_value_known(lmx_arena_ref_value(f.value,2))==9&&lmx_int_value_known(lmx_arena_ref_value(f.value,0))==29,
    "actual mapped read/address write changes v and preserves w/pad");
 ck(e&&e->reception_proof==1&&!e->contract,"joining coordinates does not manufacture a full semantic permission");
 void *changed=lmx_char_new_owned(&f.arena);if(!changed||lmx_arena_ref_store(f.value,2,changed))abort();
 cells[2]=1;if(!e){lmx_arena_release(&f.arena);return;}
 LmxImplEntry saved=*e;size_t before=f.arena.impl_len;
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,rows,2,&uses,1)==LMX_IMPLEMENTS_NO&&f.arena.impl_len==before&&
    !memcmp(&saved,lmx_implements_find(&f.arena,f.value,f.required),sizeof saved),"a new Consumer still checks the actual type, without changing its old map");
 lmx_arena_release(&f.arena);
}
static void refine_cached(void){
 Fixture f;fresh(&f);size_t cells[]={4,1,0,0};LmxImplUses uses={0};uses.map=cells;
 int answer=lmx_implements_admit_templates(&f.arena,f.value,f.required,f.rows+1,1,&uses,1);
 LmxImplEntry *e=lmx_implements_find(&f.arena,f.value,f.required);size_t at=0;
 ck(answer==LMX_IMPLEMENTS_YES&&e&&e->n==2&&e->reception_proof==1&&!lmx_implements_at(&f.arena,e,1,&at)&&at==SIZE_MAX,"first scoped reception records genuinely incomplete coordinates");
 LmxImplEntry saved=*e;size_t before=f.arena.impl_len;
 void *changed=lmx_char_new_owned(&f.arena);if(!changed||lmx_arena_ref_store(f.required,1,changed))abort();cells[2]=1;
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,f.rows,2,&uses,1)==LMX_IMPLEMENTS_NO&&f.arena.impl_len==before&&
    !memcmp(&saved,lmx_implements_find(&f.arena,f.value,f.required),sizeof saved),"failed refinement publishes no coordinate, count, permission or key");
 integer(&f.arena,f.required,1,0);
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,f.rows,2,&uses,1)==LMX_IMPLEMENTS_YES&&slots(&f),"later informed Consumer refines the unknown coordinate while preserving v");
 e=lmx_implements_find(&f.arena,f.value,f.required);
 ck(e&&e->reception_proof==1&&!e->contract,"refinement remains scoped until its own full analytical admission");
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,f.rows,2,NULL,1)==LMX_IMPLEMENTS_YES&&
    lmx_implements_find(&f.arena,f.value,f.required)->reception_proof==2&&lmx_implements_find(&f.arena,f.value,f.required)->contract,"complete coordinate set gets a full key only after the full check");
 ck(lmx_implements_admit_receiving(&f.arena,f.value,f.required,NULL,NULL)==LMX_IMPLEMENTS_YES&&slots(&f),"no optional override preserves the already proved non-positional relation");
 lmx_arena_release(&f.arena);
}
static void duplicate_views(void){
 Fixture f;fresh(&f);size_t only_v[]={1,SIZE_MAX,1,SIZE_MAX},only_w[]={SIZE_MAX,2,SIZE_MAX,2};LmxImplEntry views[2]={0};
 for(size_t i=0;i<2;++i){views[i].value=f.value;views[i].req=f.required;views[i].layout=tokens+3;views[i].n=2;}
 views[0].map=only_v;views[1].map=only_w;
 ck(lmx_implements_admit_receiving_views(&f.arena,f.value,f.required,views,2,NULL)==LMX_IMPLEMENTS_YES&&slots(&f),"complementary explicit rows produce one coherent receiving record");
 if(!lmx_implements_find(&f.arena,f.value,f.required)){lmx_arena_release(&f.arena);return;}
 LmxImplEntry saved=*lmx_implements_find(&f.arena,f.value,f.required);size_t before=f.arena.impl_len;
 size_t swapped[]={2,1,2,1},cells[]={4,1,0,0};LmxImplUses uses={0};uses.map=cells;views[0].map=swapped;
 ck(lmx_implements_admit_receiving(&f.arena,f.value,f.required,views,&uses)==LMX_IMPLEMENTS_NO&&f.arena.impl_len==before&&
    !memcmp(&saved,lmx_implements_find(&f.arena,f.value,f.required),sizeof saved),"different known addresses remain a real conflict and preserve all state");
 Lmx *bad=node(&f.arena,3);
 for(size_t i=0;i<3;++i){void *p=lmx_size_new_owned(&f.arena);if(!p||lmx_size_store_known(p,1)||lmx_arena_ref_store(bad,i,p))abort();}
 views[0].map=NULL;views[0].frame=bad;views[0].at=0;
 ck(lmx_implements_admit_receiving_views(&f.arena,f.value,f.required,views,1,&uses)==LMX_IMPLEMENTS_UNKNOWN&&f.arena.impl_len==before,
    "unused tail of a frame row must still fit its complete physical owner");
 views[0].frame=NULL;views[0].map=only_v;views[0].n=1;
 ck(lmx_implements_admit_receiving_views(&f.arena,f.value,f.required,views,1,&uses)!=LMX_IMPLEMENTS_YES&&f.arena.impl_len==before,"mismatched incoming map count cannot become a sliced successful proof");
 size_t empty[]={2,0};uses.map=empty;views[0].frame=bad;views[0].map=NULL;views[0].n=2;
 ck(lmx_implements_receiving_views(&f.arena,f.value,f.value,f.required,views,1,&uses)==LMX_IMPLEMENTS_YES,"pure empty Consumer ignores unused metadata without publishing it");
 lmx_arena_release(&f.arena);
}
static void owned_and_resize(void){
 Fixture f;fresh(&f);size_t only_v[]={1,SIZE_MAX,1,SIZE_MAX},only_w[]={SIZE_MAX,2,SIZE_MAX,2};
 ck(lmx_implements_register_map_owned(&f.arena,f.value,f.required,only_v,2,tokens+3)==LMX_IMPLEMENTS_YES,"owned initial coordinate row is retained");
 ck(lmx_implements_register_map_owned(&f.arena,f.value,f.required,only_w,2,tokens+3)==LMX_IMPLEMENTS_YES&&slots(&f)&&
    lmx_implements_find(&f.arena,f.value,f.required)->owned_map,"owned complementary registration retains the joined buffer, not a freed temporary");
 size_t *kept=lmx_implements_find(&f.arena,f.value,f.required)->map;
 ck(lmx_implements_register_map_owned(&f.arena,f.value,f.required,f.complete,2,tokens+3)==LMX_IMPLEMENTS_YES&&
    lmx_implements_find(&f.arena,f.value,f.required)->map==kept&&slots(&f),"equal registrations preserve the old owned storage lifetime");
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,NULL,0,NULL,1)==LMX_IMPLEMENTS_YES,"owned coordinate evidence is fully checked before semantic promotion");
 f.required->array.size=1;
 int answer=lmx_implements_admit_templates(&f.arena,f.value,f.required,NULL,0,NULL,1);
 LmxImplEntry *e=lmx_implements_find(&f.arena,f.value,f.required);size_t x=0,y=0;
 ck(answer==LMX_IMPLEMENTS_YES&&e&&e->n==1&&e->contract&&e->contract->facts.array.len==2&&
    !lmx_implements_at(&f.arena,e,0,&x)&&x==1&&!lmx_implements_at_last(&f.arena,e,0,&y)&&y==1,
    "shrinking a non-identity record rebases both halves and its current key/count together");
 LmxImplEntry saved=*e;size_t before=f.arena.impl_len;f.required->array.size=2;
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,NULL,0,NULL,1)==LMX_IMPLEMENTS_NO&&f.arena.impl_len==before&&
    !memcmp(&saved,lmx_implements_find(&f.arena,f.value,f.required),sizeof saved),"restoring width cannot invent new coordinates from an old shorter record");
 ck(lmx_implements_admit_templates(&f.arena,f.value,f.required,f.rows,2,NULL,1)==LMX_IMPLEMENTS_YES&&slots(&f)&&
    lmx_implements_find(&f.arena,f.value,f.required)->n==2&&lmx_implements_find(&f.arena,f.value,f.required)->contract->facts.array.len==3,
    "informed width restoration rebuilds a complete current record through the same join");
 ck(lmx_implements_admit_receiving(&f.arena,f.value,f.required,NULL,NULL)==LMX_IMPLEMENTS_YES&&slots(&f),"full reuse never replaces non-positional coordinates by an implicit identity");
 lmx_arena_release(&f.arena);
}
int main(void){original_evidence_main();ordered(0);ordered(1);refine_cached();duplicate_views();owned_and_resize();printf("refined receiving maps: %d checks, %d failures\n",checks,failures);return failures!=0;}
