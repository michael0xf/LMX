/* SPDX-License-Identifier: 0BSD */
#include "ff.h"
#include "diskio.h"
#include "check.h"
#include <string.h>
#define SECTORS 16384u
static unsigned char disk[SECTORS*512u];
DSTATUS disk_initialize(BYTE p){return p?STA_NOINIT:0;}
DSTATUS disk_status(BYTE p){return p?STA_NOINIT:0;}
DRESULT disk_read(BYTE p,BYTE *b,LBA_t s,UINT n){
    if(p || s>=SECTORS || n>SECTORS-s)return RES_PARERR;
    memcpy(b,disk+(size_t)s*512,(size_t)n*512);return RES_OK;
}
DRESULT disk_write(BYTE p,const BYTE *b,LBA_t s,UINT n){
    if(p || s>=SECTORS || n>SECTORS-s)return RES_PARERR;
    memcpy(disk+(size_t)s*512,b,(size_t)n*512);return RES_OK;
}
DRESULT disk_ioctl(BYTE p,BYTE cmd,void *b){
    if(p)return RES_PARERR;
    switch(cmd){case CTRL_SYNC:return RES_OK;
    case GET_SECTOR_COUNT:*(LBA_t*)b=SECTORS;return RES_OK;
    case GET_SECTOR_SIZE:*(WORD*)b=512;return RES_OK;
    case GET_BLOCK_SIZE:*(DWORD*)b=1;return RES_OK;
    default:return RES_PARERR;}
}
static int roundtrip(BYTE format) {
    FATFS fs;FIL f;FILINFO info;MKFS_PARM opt={0};UINT n;unsigned char work[4096],in[1024],out[1024];size_t i;
    /* UTF-8: Cyrillic directory, Cyrillic plus Latin accented long name.
       Byte escapes make the test independent of the C compiler source charset. */
    const char *dir="0:/\320\264\320\260\320\275\320\275\321\213\320\265";
    const char *name="0:/\320\264\320\260\320\275\320\275\321\213\320\265/\320\230\320\267\320\274\320\265\321\200\320\265\320\275\320\270\320\265 caf\303\251.txt";
    const char *lower="0:/\320\264\320\260\320\275\320\275\321\213\320\265/\320\270\320\267\320\274\320\265\321\200\320\265\320\275\320\270\320\265 CAF\303\211.TXT";
    memset(disk,0,sizeof disk);opt.fmt=format|FM_SFD;
    CHECK(f_mkfs("0:",&opt,work,sizeof work)==FR_OK);CHECK(f_mount(&fs,"0:",1)==FR_OK);
    CHECK(f_mkdir(dir)==FR_OK);CHECK(f_open(&f,name,FA_CREATE_ALWAYS|FA_WRITE)==FR_OK);
    for(i=0;i<sizeof in;++i)in[i]=(unsigned char)(i*23u);
    CHECK(f_write(&f,in,sizeof in,&n)==FR_OK && n==sizeof in);CHECK(f_sync(&f)==FR_OK);CHECK(f_close(&f)==FR_OK);
    CHECK(f_mount(NULL,"0:",0)==FR_OK);memset(&fs,0,sizeof fs);CHECK(f_mount(&fs,"0:",1)==FR_OK);
    CHECK(f_stat(lower,&info)==FR_OK && info.fsize==sizeof in);
    CHECK(f_open(&f,lower,FA_READ)==FR_OK);CHECK(f_read(&f,out,sizeof out,&n)==FR_OK && n==sizeof out);
    CHECK(!memcmp(in,out,sizeof in));CHECK(f_close(&f)==FR_OK);
    CHECK(f_unlink(name)==FR_OK);CHECK(f_unlink(dir)==FR_OK);CHECK(f_mount(NULL,"0:",0)==FR_OK);return 0;
}
int main(void){CHECK(roundtrip(FM_FAT)==0);CHECK(roundtrip(FM_EXFAT)==0);return 0;}
