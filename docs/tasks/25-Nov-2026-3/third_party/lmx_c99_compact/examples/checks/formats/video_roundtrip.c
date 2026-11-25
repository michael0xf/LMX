#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pl_mpeg.h"
#include "jo_mpeg.h"
#include "minih264e.h"
#include "h264bsd_decoder.h"
#define CHECK(c) do { if (!(c)) { fprintf(stderr, "video check failed at %d: %s\n", __LINE__, #c); return 1; } } while (0)

int main(void)
{
    unsigned char rgbx[32 * 32 * 4];
    FILE *fp = tmpfile();
    plm_buffer_t *buffer;
    plm_video_t *video;
    plm_frame_t *frame;
    size_t i;
    CHECK(fp);
    memset(rgbx, 128, sizeof(rgbx));
    jo_write_mpeg(fp, rgbx, 32, 32, 25);
    jo_write_mpeg(fp, rgbx, 32, 32, 25);
    jo_write_mpeg(fp, rgbx, 32, 32, 25);
    CHECK(!ferror(fp) && ftell(fp) > 20);
    rewind(fp);
    buffer = plm_buffer_create_with_file(fp, 1);
    CHECK(buffer);
    video = plm_video_create_with_buffer(buffer, 1);
    CHECK(video && plm_video_has_header(video));
    frame = plm_video_decode(video);
    CHECK(frame && frame->width == 32 && frame->height == 32);
    for (i = 0; i < 32 * 32; ++i) CHECK(frame->y.data[i] > 115 && frame->y.data[i] < 140);
    plm_video_destroy(video);
    {
        H264E_create_param_t create;
        H264E_run_param_t run;
        H264E_io_yuv_t yuv;
        H264E_persist_t *encoder;
        H264E_scratch_t *scratch;
        void *persist_mem = NULL, *scratch_mem = NULL, *input_mem = NULL;
        unsigned char *coded, *input;
        int persist_size, scratch_size, coded_size;
        storage_t decoder;
        u32 offset = 0, pictures = 0, loops = 0;
        memset(&create, 0, sizeof(create));
        memset(&run, 0, sizeof(run));
        create.width = create.height = 32;
        create.gop = 1; create.const_input_flag = 1;
#if H264E_SVC_API
        create.num_layers = 1;
#endif
#if H264E_MAX_THREADS
        create.max_threads = 1;
#endif
        run.qp_min = run.qp_max = 20;
        run.encode_speed = H264E_SPEED_FASTEST;
        CHECK(H264E_sizeof(&create, &persist_size, &scratch_size) == 0);
        CHECK(posix_memalign(&persist_mem, 64, (size_t)persist_size) == 0);
        CHECK(posix_memalign(&scratch_mem, 64, (size_t)scratch_size) == 0);
        CHECK(posix_memalign(&input_mem, 64, 32 * 32 * 3 / 2) == 0);
        encoder = (H264E_persist_t *)persist_mem;
        scratch = (H264E_scratch_t *)scratch_mem;
        input = (unsigned char *)input_mem;
        memset(input, 90, 32 * 32);
        memset(input + 32 * 32, 128, 32 * 32 / 2);
        yuv.yuv[0] = input; yuv.stride[0] = 32;
        yuv.yuv[1] = input + 32 * 32; yuv.stride[1] = 16;
        yuv.yuv[2] = input + 32 * 32 * 5 / 4; yuv.stride[2] = 16;
        CHECK(H264E_init(encoder, &create) == 0);
        CHECK(H264E_encode(encoder, scratch, &run, &yuv, &coded, &coded_size) == 0);
        CHECK(coded_size > 20);
        CHECK(h264bsdInit(&decoder, 1) == 0);
        while (offset < (u32)coded_size && ++loops < 128) {
            u32 consumed = 0, status = h264bsdDecode(&decoder, coded + offset,
                (u32)coded_size - offset, 0, &consumed);
            CHECK(consumed <= (u32)coded_size - offset);
            CHECK(status == H264BSD_RDY || status == H264BSD_HDRS_RDY || status == H264BSD_PIC_RDY);
            offset += consumed;
            if (status == H264BSD_PIC_RDY) {
                u32 id, idr, errors;
                unsigned char *pic = h264bsdNextOutputPicture(&decoder, &id, &idr, &errors);
                CHECK(pic && errors == 0 && idr);
                CHECK(h264bsdPicWidth(&decoder) == 2 && h264bsdPicHeight(&decoder) == 2);
                for (i = 0; i < 32 * 32; ++i) CHECK(abs((int)pic[i] - 90) <= 3);
                for (; i < 32 * 32 * 3 / 2; ++i) CHECK(abs((int)pic[i] - 128) <= 3);
                ++pictures;
            }
        }
        CHECK(pictures == 1 && loops < 128);
        h264bsdShutdown(&decoder);
        free(input_mem); free(scratch_mem); free(persist_mem);
    }
    puts("video: jo_mpeg -> pl_mpeg and minih264 -> h264bsd dimensions/pixels OK");
    return 0;
}
