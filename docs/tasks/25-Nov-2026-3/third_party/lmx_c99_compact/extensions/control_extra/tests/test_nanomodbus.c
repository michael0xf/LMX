#include "nanomodbus.h"
#include "test.h"
#include <string.h>
typedef struct { const uint8_t *input; size_t size,pos,out_size; uint8_t output[256]; } transport;
static int32_t read_bytes(uint8_t *buf,uint16_t count,int32_t timeout,void *arg) {
    transport *t=arg; (void)timeout;
    size_t n=count; if(n>t->size-t->pos)n=t->size-t->pos;
    memcpy(buf,t->input+t->pos,n);t->pos+=n;return (int32_t)n;
}
static int32_t write_bytes(const uint8_t *buf,uint16_t count,int32_t timeout,void *arg) {
    transport *t=arg; (void)timeout;
    if(count>sizeof(t->output)-t->out_size)return -1;
    memcpy(t->output+t->out_size,buf,count);t->out_size+=count;return count;
}
static nmbs_error holding(uint16_t address,uint16_t quantity,uint16_t *out,uint8_t unit,void *arg) {
    (void)unit;(void)arg;
    if(address!=0||quantity!=2)return NMBS_EXCEPTION_ILLEGAL_DATA_ADDRESS;
    out[0]=0x1234;out[1]=0xabcd;return NMBS_ERROR_NONE;
}
int main(void) {
    static const uint8_t request[]={0,1,0,0,0,6,1,3,0,0,0,2};
    static const uint8_t expected[]={0,1,0,0,0,7,1,3,4,0x12,0x34,0xab,0xcd};
    transport t={.input=request,.size=sizeof(request)};
    nmbs_platform_conf platform;nmbs_platform_conf_create(&platform);
    platform.transport=NMBS_TRANSPORT_TCP;platform.read=read_bytes;platform.write=write_bytes;platform.arg=&t;
    nmbs_callbacks callbacks;nmbs_callbacks_create(&callbacks);callbacks.read_holding_registers=holding;
    nmbs_t server;CHECK(nmbs_server_create(&server,1,&platform,&callbacks)==NMBS_ERROR_NONE);
    nmbs_set_read_timeout(&server,0);
    CHECK(nmbs_server_poll(&server)==NMBS_ERROR_NONE);
    CHECK(t.out_size==sizeof(expected)&&memcmp(t.output,expected,sizeof(expected))==0);
    static const uint8_t bad_request[]={0,2,0,0,0,6,1,3,0,99,0,2};
    static const uint8_t error_response[]={0,2,0,0,0,3,1,0x83,2};
    t.input=bad_request;t.size=sizeof(bad_request);t.pos=0;t.out_size=0;
    CHECK(nmbs_server_poll(&server)==NMBS_ERROR_NONE);
    CHECK(t.out_size==sizeof(error_response)&&memcmp(t.output,error_response,sizeof(error_response))==0);
    puts("nanoMODBUS: in-memory TCP holding-register response and exception passed");
    return 0;
}
