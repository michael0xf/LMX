#include "check.h"
#include <string.h>
#include "cute_png.h"
int main(void) {
    cp_image_t image = cp_load_blank(19,13), decoded; cp_saved_png_t packed;
    int x,y,w=0,h=0; REQUIRE(image.pix);
    for(y=0;y<image.h;++y) for(x=0;x<image.w;++x) {
        cp_pixel_t *p=&image.pix[y*image.w+x]; p->r=(unsigned char)(x*13); p->g=(unsigned char)(y*19); p->b=(unsigned char)(x^y); p->a=(unsigned char)(255-x);
    }
    packed=cp_save_png_to_memory(&image); REQUIRE(packed.data && packed.size > 8);
    cp_load_png_wh(packed.data,packed.size,&w,&h); REQUIRE(w==19 && h==13);
    decoded=cp_load_png_mem(packed.data,packed.size); REQUIRE(decoded.pix && decoded.w==19 && decoded.h==13);
    REQUIRE(memcmp(image.pix,decoded.pix,19*13*sizeof(cp_pixel_t))==0);
    cp_free_png(&decoded); REQUIRE(cp_save_png("cute-pixels.png",&image));
    decoded=cp_load_png("cute-pixels.png"); REQUIRE(decoded.pix && memcmp(image.pix,decoded.pix,19*13*sizeof(cp_pixel_t))==0);
    cp_free_png(&decoded); cp_free_png(&image); free(packed.data); remove("cute-pixels.png");
    puts("cute_png: memory/file RGBA encode-decode PASS"); return 0;
}
