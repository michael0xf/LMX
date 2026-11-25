#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "nuklear.h"
#include "microui.h"
#include "olive.c"
/* C99 compile-time checks of the sizeof-only NK_ALIGNOF against named
 * struct offsetof. These also run as compiler checks in Android cross-builds. */
#define LMX_NK_CHECK_ALIGN(tag, type) \
    struct lmx_nk_align_##tag { char c; type value; }; \
    typedef char lmx_nk_align_check_##tag[(NK_ALIGNOF(type) == offsetof(struct lmx_nk_align_##tag, value)) ? 1 : -1]
LMX_NK_CHECK_ALIGN(command, struct nk_command);
LMX_NK_CHECK_ALIGN(vec2, struct nk_vec2);
LMX_NK_CHECK_ALIGN(draw_command, struct nk_draw_command);
LMX_NK_CHECK_ALIGN(draw_index, nk_draw_index);
LMX_NK_CHECK_ALIGN(pointer, void *);
LMX_NK_CHECK_ALIGN(wide_float, long double);
#undef LMX_NK_CHECK_ALIGN
#define CHECK(c) do { if(!(c)){fprintf(stderr,"GUI check failed line %d: %s\n",__LINE__,#c);return 1;} }while(0)
static float nk_width(nk_handle h,float height,const char *text,int len){(void)h;(void)height;(void)text;return (float)len*7;}
static int mu_width(mu_Font f,const char *text,int len){(void)f;return (len<0?(int)strlen(text):len)*7;}
static int mu_height(mu_Font f){(void)f;return 14;}
int main(void){
    struct nk_context ctx;struct nk_user_font font={0};const struct nk_command *cmd;
    mu_Context *mu;mu_Command *mc=NULL;int count=0,mcount=0;
    uint32_t pixels[16*16];Olivec_Canvas canvas=olivec_canvas(pixels,16,16,16);
    font.height=14;font.width=nk_width;CHECK(nk_init_default(&ctx,&font));
    nk_input_begin(&ctx);nk_input_end(&ctx);
    if(nk_begin(&ctx,"LMX",nk_rect(0,0,160,120),NK_WINDOW_BORDER|NK_WINDOW_TITLE)){
        nk_layout_row_dynamic(&ctx,24,1);nk_label(&ctx,"Hello",NK_TEXT_LEFT);nk_button_label(&ctx,"Run");
    }
    nk_end(&ctx);nk_foreach(cmd,&ctx){++count;}CHECK(count>0);nk_free(&ctx);
    mu=calloc(1,sizeof *mu);CHECK(mu);mu_init(mu);mu->text_width=mu_width;mu->text_height=mu_height;
    mu_begin(mu);
    if(mu_begin_window(mu,"LMX",mu_rect(0,0,160,120))){
        int widths[1]={-1};mu_layout_row(mu,1,widths,24);mu_label(mu,"Hello");mu_button(mu,"Run");mu_end_window(mu);
    }
    mu_end(mu);while(mu_next_command(mu,&mc)){++mcount;}CHECK(mcount>0);free(mu);
    olivec_fill(canvas,0xff000000u);olivec_rect(canvas,2,2,6,6,0xff0000ffu);
    CHECK(pixels[3*16+3]==0xff0000ffu && pixels[15*16+15]==0xff000000u);
    {
        struct nk_font_atlas atlas;
        struct nk_draw_null_texture null_texture;
        struct nk_font *default_font;
        const void *atlas_pixels;
        int atlas_width=0, atlas_height=0;
        nk_font_atlas_init_default(&atlas);
        nk_font_atlas_begin(&atlas);
        default_font=nk_font_atlas_add_default(&atlas,14.0f,NULL);
        CHECK(default_font);
        atlas_pixels=nk_font_atlas_bake(&atlas,&atlas_width,&atlas_height,NK_FONT_ATLAS_RGBA32);
        CHECK(atlas_pixels && atlas_width>0 && atlas_height>0);
        nk_font_atlas_end(&atlas,nk_handle_id(1),&null_texture);
        CHECK(default_font->handle.height>0);
        nk_font_atlas_clear(&atlas);
    }
    printf("Nuklear commands=%d, microui commands=%d, Olive pixel raster passed\n",count,mcount);
    return 0;
}
