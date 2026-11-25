/* SPDX-License-Identifier: 0BSD */
#include "heatshrink_encoder.h"
#include "heatshrink_decoder.h"
#include "check.h"
#include <string.h>
int main(void) {
    unsigned char in[4096],packed[8192],out[8192];size_t i,pos=0,clen=0,olen=0,n;unsigned rounds=0;
    heatshrink_encoder *e=heatshrink_encoder_alloc(8,4);
    heatshrink_decoder *d=heatshrink_decoder_alloc(32,8,4);
    HSE_finish_res ef;HSD_finish_res df;
    CHECK(e && d);
    for(i=0;i<sizeof in;++i)in[i]=(unsigned char)((i%137)<100?i%13:i*71u);
    while(pos<sizeof in){
        size_t amount=sizeof in-pos;if(amount>17)amount=17;
        CHECK(heatshrink_encoder_sink(e,in+pos,amount,&n)>=0);pos+=n;
        do{CHECK(heatshrink_encoder_poll(e,packed+clen,sizeof packed-clen,&n)>=0);clen+=n;}while(n);
        CHECK(++rounds<100000);
    }
    do{
        ef=heatshrink_encoder_finish(e);CHECK(ef>=0);
        do{CHECK(heatshrink_encoder_poll(e,packed+clen,sizeof packed-clen,&n)>=0);clen+=n;}while(n);
        CHECK(++rounds<100000);
    }while(ef!=HSER_FINISH_DONE);
    pos=0;
    while(pos<clen){
        size_t amount=clen-pos;if(amount>11)amount=11;
        CHECK(heatshrink_decoder_sink(d,packed+pos,amount,&n)>=0);pos+=n;
        do{CHECK(heatshrink_decoder_poll(d,out+olen,sizeof out-olen,&n)>=0);olen+=n;}while(n);
        CHECK(++rounds<100000);
    }
    do{
        df=heatshrink_decoder_finish(d);CHECK(df>=0);
        do{CHECK(heatshrink_decoder_poll(d,out+olen,sizeof out-olen,&n)>=0);olen+=n;}while(n);
        CHECK(++rounds<100000);
    }while(df!=HSDR_FINISH_DONE);
    CHECK(olen==sizeof in);CHECK(!memcmp(in,out,sizeof in));CHECK(clen<sizeof in);
    heatshrink_encoder_free(e);heatshrink_decoder_free(d);return 0;
}
