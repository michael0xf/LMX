/* SPDX-License-Identifier: 0BSD */
#include "lfs.h"
#include "check.h"
#include <string.h>
static unsigned char flash[128 * 512];
static int rd(const struct lfs_config *c, lfs_block_t b, lfs_off_t o, void *p, lfs_size_t n) {
    if (b >= c->block_count || o+n > c->block_size) return LFS_ERR_IO;
    memcpy(p, flash+b*c->block_size+o, n); return 0;
}
static int prog(const struct lfs_config *c, lfs_block_t b, lfs_off_t o, const void *p, lfs_size_t n) {
    const unsigned char *s=p; lfs_size_t i;
    if (b >= c->block_count || o+n > c->block_size) return LFS_ERR_IO;
    for (i=0;i<n;++i) flash[b*c->block_size+o+i] &= s[i];
    return 0;
}
static int erase(const struct lfs_config *c, lfs_block_t b) {
    if (b >= c->block_count) return LFS_ERR_IO;
    memset(flash+b*c->block_size,255,c->block_size); return 0;
}
static int sync_bd(const struct lfs_config *c) { (void)c; return 0; }
int main(void) {
    lfs_t fs; lfs_file_t f; struct lfs_info info; unsigned char input[4096],output[4096]; size_t i;
    const struct lfs_config cfg={.read=rd,.prog=prog,.erase=erase,.sync=sync_bd,
        .read_size=16,.prog_size=16,.block_size=512,.block_count=128,
        .block_cycles=100,.cache_size=64,.lookahead_size=16};
    memset(flash,255,sizeof flash);
    for(i=0;i<sizeof input;++i) input[i]=(unsigned char)(i*37u);
    CHECK(lfs_format(&fs,&cfg)==0); CHECK(lfs_mount(&fs,&cfg)==0);
    CHECK(lfs_mkdir(&fs,"measurements")==0);
    CHECK(lfs_file_open(&fs,&f,"measurements/day.bin",LFS_O_CREAT|LFS_O_WRONLY)==0);
    CHECK(lfs_file_write(&fs,&f,input,sizeof input)==sizeof input);
    CHECK(lfs_file_sync(&fs,&f)==0); CHECK(lfs_file_close(&fs,&f)==0);
    CHECK(lfs_rename(&fs,"measurements/day.bin","measurements/saved.bin")==0);
    CHECK(lfs_unmount(&fs)==0); memset(&fs,0,sizeof fs);
    CHECK(lfs_mount(&fs,&cfg)==0); CHECK(lfs_stat(&fs,"measurements/saved.bin",&info)==0);
    CHECK(info.size==sizeof input); CHECK(lfs_file_open(&fs,&f,"measurements/saved.bin",LFS_O_RDWR)==0);
    CHECK(lfs_file_read(&fs,&f,output,sizeof output)==sizeof output); CHECK(!memcmp(input,output,sizeof input));
    CHECK(lfs_file_truncate(&fs,&f,257)==0); CHECK(lfs_file_close(&fs,&f)==0);
    CHECK(lfs_remove(&fs,"measurements/saved.bin")==0); CHECK(lfs_unmount(&fs)==0);
    return 0;
}
