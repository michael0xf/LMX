#include "check.h"
#include <string.h>
#include "cute_spritebatch.h"
typedef struct test_state {int submitted, generated, deleted, pixels;} test_state;
static void submit(spritebatch_sprite_t *sprites,int count,int w,int h,void *user) {
    test_state *s=user;int i; REQUIRE(w>0 && h>0); for(i=0;i<count;++i)REQUIRE(sprites[i].texture_id!=0);s->submitted+=count;
}
static void pixels(SPRITEBATCH_U64 id,void *out,int n,void *user) {
    test_state *s=user;REQUIRE(id==1||id==2);REQUIRE(n==16);memset(out,(int)id,n);s->pixels++;
}
static SPRITEBATCH_U64 create_texture(void *data,int w,int h,void *user) {
    test_state *s=user;REQUIRE(data && w>0 && h>0);return (SPRITEBATCH_U64)++s->generated;
}
static void destroy_texture(SPRITEBATCH_U64 id,void *user) {
    test_state *s=user;REQUIRE(id>0);s->deleted++;
}
int main(void) {
    spritebatch_t batch; spritebatch_config_t config; spritebatch_sprite_t sprite; test_state state={0,0,0,0};int i;
    spritebatch_set_default_config(&config);config.pixel_stride=4;config.atlas_width_in_pixels=16;config.atlas_height_in_pixels=16;
    config.batch_callback=submit;config.get_pixels_callback=pixels;config.generate_texture_callback=create_texture;config.delete_texture_callback=destroy_texture;
    REQUIRE(spritebatch_init(&batch,&config,&state)==0);
    memset(&sprite,0,sizeof(sprite));sprite.w=sprite.h=2;
    for(i=0;i<9;++i){sprite.image_id=(SPRITEBATCH_U64)(1+i%2);spritebatch_push(&batch,sprite);}
    spritebatch_flush(&batch);REQUIRE(state.submitted==9 && state.pixels==2 && state.generated==2);
    spritebatch_term(&batch);REQUIRE(state.deleted==state.generated);
    /* Force atlas creation, then check the atlas handle is also released. */
    config.lonely_buffer_count_till_flush=1;
    REQUIRE(spritebatch_init(&batch,&config,&state)==0);
    for(i=0;i<2;++i){sprite.image_id=(SPRITEBATCH_U64)(1+i);spritebatch_push(&batch,sprite);}
    spritebatch_flush(&batch);spritebatch_defrag(&batch);
    REQUIRE(batch.atlases!=NULL);
    spritebatch_term(&batch);REQUIRE(state.deleted==state.generated);
    puts("cute_spritebatch: image callbacks/batching/resource release PASS");return 0;
}
