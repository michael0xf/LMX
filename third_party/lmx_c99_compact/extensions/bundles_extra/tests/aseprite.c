#include "check.h"
#include <stdint.h>
#include <string.h>
#include "cute_aseprite.h"
static void u16(unsigned char *p,unsigned v){p[0]=(unsigned char)v;p[1]=(unsigned char)(v>>8);}
static void u32(unsigned char *p,unsigned v){u16(p,v);u16(p+2,v>>16);}
int main(void) {
    /* A one-pixel .aseprite file is constructed as test code, no binary fixture. */
    unsigned char bytes[199]={0}; unsigned char *frame=bytes+128,*layer=frame+16,*cel=layer+25;
    ase_t *a;
    u32(bytes,sizeof(bytes));u16(bytes+4,0xa5e0);u16(bytes+6,1);u16(bytes+8,1);u16(bytes+10,1);u16(bytes+12,32);u32(bytes+14,1);u16(bytes+18,100);bytes[34]=1;bytes[35]=1;
    u32(frame,71);u16(frame+4,0xf1fa);u16(frame+6,2);u16(frame+8,100);
    u32(layer,25);u16(layer+4,0x2004);u16(layer+6,1);layer[18]=255;u16(layer+22,1);layer[24]='L';
    u32(cel,30);u16(cel+4,0x2005);cel[12]=255;u16(cel+22,1);u16(cel+24,1);cel[26]=23;cel[27]=67;cel[28]=101;cel[29]=255;
    a=cute_aseprite_load_from_memory(bytes,sizeof(bytes),NULL); REQUIRE(a);
    REQUIRE(a->w==1 && a->h==1 && a->frame_count==1 && a->layer_count==1);
    REQUIRE(a->frames[0].duration_milliseconds==100 && a->frames[0].cel_count==1);
    REQUIRE(a->frames[0].pixels[0].r==23 && a->frames[0].pixels[0].g==67 && a->frames[0].pixels[0].b==101 && a->frames[0].pixels[0].a==255);
    cute_aseprite_free(a); puts("cute_aseprite: layer/cel/RGBA frame decode PASS");return 0;
}
