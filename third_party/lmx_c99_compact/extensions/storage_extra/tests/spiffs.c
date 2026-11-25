/* SPDX-License-Identifier: 0BSD */
#include "spiffs.h"
#include "check.h"
#include <string.h>
static unsigned char flash[128*1024], work[512];
/* malloc gives the descriptor and cache arrays their required alignment. */
static s32_t rd(spiffs *fs,u32_t addr,u32_t n,u8_t *p) {
    (void)fs; if (addr>sizeof flash || n>sizeof flash-addr) return -1;
    memcpy(p,flash+addr,n); return SPIFFS_OK;
}
static s32_t wr(spiffs *fs,u32_t addr,u32_t n,u8_t *p) {
    u32_t i; (void)fs; if(addr>sizeof flash || n>sizeof flash-addr) return -1;
    for(i=0;i<n;++i)flash[addr+i]&=p[i]; return SPIFFS_OK;
}
static s32_t er(spiffs *fs,u32_t addr,u32_t n) {
    (void)fs;if(addr>sizeof flash||n>sizeof flash-addr)return -1;
    memset(flash+addr,255,n);return SPIFFS_OK;
}
int main(void) {
    spiffs fs; spiffs_file f; unsigned char in[4096],out[4096]; size_t i;
    void *fds=malloc(4096),*cache=malloc(4096); spiffs_config cfg;
    CHECK(fds && cache); memset(&fs,0,sizeof fs);memset(&cfg,0,sizeof cfg);memset(flash,255,sizeof flash);
    cfg.phys_size=sizeof flash;cfg.phys_addr=0;cfg.phys_erase_block=4096;cfg.log_block_size=4096;
    cfg.log_page_size=256;cfg.hal_read_f=rd;cfg.hal_write_f=wr;cfg.hal_erase_f=er;
    (void)SPIFFS_mount(&fs,&cfg,work,fds,4096,cache,4096,NULL);
    if(SPIFFS_mounted(&fs))SPIFFS_unmount(&fs);
    CHECK(SPIFFS_format(&fs)==SPIFFS_OK);
    CHECK(SPIFFS_mount(&fs,&cfg,work,fds,4096,cache,4096,NULL)==SPIFFS_OK);
    for(i=0;i<sizeof in;++i)in[i]=(unsigned char)(i*19u);
    f=SPIFFS_open(&fs,"log.bin",SPIFFS_CREAT|SPIFFS_RDWR,0);CHECK(f>=0);
    CHECK(SPIFFS_write(&fs,f,in,sizeof in)==sizeof in);CHECK(SPIFFS_close(&fs,f)==SPIFFS_OK);
    CHECK(SPIFFS_rename(&fs,"log.bin","saved.bin")==SPIFFS_OK);SPIFFS_unmount(&fs);
    CHECK(SPIFFS_mount(&fs,&cfg,work,fds,4096,cache,4096,NULL)==SPIFFS_OK);
    f=SPIFFS_open(&fs,"saved.bin",SPIFFS_RDONLY,0);CHECK(f>=0);
    CHECK(SPIFFS_read(&fs,f,out,sizeof out)==sizeof out);CHECK(!memcmp(in,out,sizeof in));
    CHECK(SPIFFS_close(&fs,f)==SPIFFS_OK);CHECK(SPIFFS_check(&fs)==SPIFFS_OK);
    CHECK(SPIFFS_remove(&fs,"saved.bin")==SPIFFS_OK);SPIFFS_unmount(&fs);free(fds);free(cache);return 0;
}
