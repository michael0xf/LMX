/* Run from a writable directory. No display, GPU, or platform window needed. */
#include <stdio.h>
#include "olive.c"
#include "lodepng.h"
int main(void) {
    uint32_t pixels[128*96];
    Olivec_Canvas canvas=olivec_canvas(pixels,128,96,128);
    unsigned char rgba[128*96*4];
    size_t i;
    olivec_fill(canvas,0xff282018u);
    olivec_rect(canvas,8,8,112,80,0xff704020u);
    olivec_circle(canvas,64,48,28,0xff40c0ffu);
    /* Olive stores numeric AABBGGRR; serialize channels explicitly so this
       example's PNG is independent of host byte order. */
    for(i=0;i<128*96;++i){
        rgba[4*i]=(unsigned char)pixels[i];
        rgba[4*i+1]=(unsigned char)(pixels[i]>>8);
        rgba[4*i+2]=(unsigned char)(pixels[i]>>16);
        rgba[4*i+3]=(unsigned char)(pixels[i]>>24);
    }
    if(lodepng_encode32_file("lmx_headless.png",rgba,128,96))return 1;
    puts("Wrote lmx_headless.png with Olive.c + LodePNG, without a window");
    return 0;
}
