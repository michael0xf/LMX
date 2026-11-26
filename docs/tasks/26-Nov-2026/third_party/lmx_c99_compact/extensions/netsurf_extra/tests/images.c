/* SPDX-License-Identifier: MIT. Fixtures are generated here; no external assets. */
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <libnsbmp.h>
#include <nsgif.h>
static void *new_bitmap(int w, int h, unsigned state)
{ (void)state; return calloc((size_t)w * (size_t)h, 4); }
static void *new_gif_bitmap(int w, int h) { return new_bitmap(w, h, 0); }
static unsigned char *buffer(void *bitmap) { return bitmap; }
static void le16(uint8_t *p, unsigned v) { p[0] = (uint8_t)v; p[1] = (uint8_t)(v >> 8); }
static void le32(uint8_t *p, unsigned v)
{ p[0] = (uint8_t)v; p[1] = (uint8_t)(v >> 8); p[2] = (uint8_t)(v >> 16); p[3] = (uint8_t)(v >> 24); }
static void dib(uint8_t *p, unsigned height)
{ le32(p, 40); le32(p + 4, 1); le32(p + 8, height); le16(p + 12, 1); le16(p + 14, 24); le32(p + 20, 4); }
int main(void)
{
    bmp_bitmap_callback_vt callbacks = {new_bitmap, free, buffer};
    nsgif_bitmap_cb_vt gif_callbacks = {0};
    uint8_t bmp_data[58] = {0}, ico_data[70] = {0};
    const uint8_t gif_data[] = {'G','I','F','8','9','a',1,0,1,0,0x80,0,0,0,0,0,255,0,0,0x2c,0,0,0,0,1,0,1,0,0,2,2,0x4c,1,0,0x3b};
    bmp_image bmp, *icon;
    ico_collection ico;
    nsgif_t *gif;
    nsgif_bitmap_t *gif_bitmap;
    const nsgif_info_t *info;
    const unsigned char *pixels;
    bmp_data[0] = 'B'; bmp_data[1] = 'M'; le32(bmp_data + 2, sizeof bmp_data); le32(bmp_data + 10, 54);
    dib(bmp_data + 14, 1); bmp_data[56] = 255;
    assert(bmp_create(&bmp, &callbacks) == BMP_OK);
    assert(bmp_analyse(&bmp, sizeof bmp_data, bmp_data) == BMP_OK && bmp.width == 1 && bmp.height == 1);
    assert(bmp_decode(&bmp) == BMP_OK);
    pixels = buffer(bmp.bitmap); assert(pixels[0] == 255 && pixels[1] == 0 && pixels[2] == 0 && pixels[3] == 255);
    bmp_finalise(&bmp);
    le16(ico_data + 2, 1); le16(ico_data + 4, 1); ico_data[6] = 1; ico_data[7] = 1;
    le16(ico_data + 10, 1); le16(ico_data + 12, 24); le32(ico_data + 14, 48); le32(ico_data + 18, 22);
    dib(ico_data + 22, 2); ico_data[63] = 255;
    assert(ico_collection_create(&ico, &callbacks) == BMP_OK);
    assert(ico_analyse(&ico, sizeof ico_data, ico_data) == BMP_OK);
    icon = ico_find(&ico, 1, 1); assert(icon != NULL && bmp_decode(icon) == BMP_OK);
    pixels = buffer(icon->bitmap); assert(pixels[0] == 0 && pixels[1] == 255 && pixels[2] == 0 && pixels[3] == 255);
    ico_finalise(&ico);
    gif_callbacks.create = new_gif_bitmap; gif_callbacks.destroy = free; gif_callbacks.get_buffer = buffer;
    assert(nsgif_create(&gif_callbacks, NSGIF_BITMAP_FMT_R8G8B8A8, &gif) == NSGIF_OK);
    assert(nsgif_data_scan(gif, sizeof gif_data, gif_data) == NSGIF_OK); nsgif_data_complete(gif);
    info = nsgif_get_info(gif); assert(info && info->width == 1 && info->height == 1 && info->frame_count == 1);
    assert(nsgif_frame_decode(gif, 0, &gif_bitmap) == NSGIF_OK);
    pixels = buffer(gif_bitmap); assert(pixels[0] == 255 && pixels[1] == 0 && pixels[2] == 0 && pixels[3] == 255);
    assert(nsgif_reset(gif) == NSGIF_OK); nsgif_destroy(gif);
    return 0;
}
