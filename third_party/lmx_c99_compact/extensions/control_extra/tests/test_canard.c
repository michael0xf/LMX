#include "canard.h"
#include "test.h"
#include <string.h>
typedef struct { uint32_t id;size_t size;unsigned char data[64]; } frame;
static frame frames[64];static size_t frame_count,allocations,received;
static unsigned char message[512];static size_t message_size;static canard_us_t tick=1000;
static void *allocate(canard_mem_t m,size_t n) { (void)m;void *p=malloc(n);if(p)++allocations;return p; }
static void release(canard_mem_t m,size_t n,void *p) { (void)m;(void)n;if(p){CHECK(allocations>0);--allocations;free(p);} }
static canard_us_t now(const canard_t *self) { (void)self;return tick; }
static bool transmit(canard_t *self,void *context,canard_us_t deadline,uint_least8_t iface,bool fd,uint32_t id,canard_bytes_t data) {
    (void)self;(void)context;(void)deadline;(void)iface;(void)fd;
    CHECK(frame_count<64&&data.size<=64);frames[frame_count].id=id;frames[frame_count].size=data.size;
    memcpy(frames[frame_count].data,data.data,data.size);++frame_count;return true;
}
static void on_message(canard_subscription_t *sub,canard_us_t ts,canard_prio_t priority,uint_least8_t source,uint_least8_t tid,canard_payload_t p) {
    (void)ts;(void)priority;(void)tid;CHECK(source==11&&p.view.size<=sizeof(message));
    memcpy(message,p.view.data,p.view.size);message_size=p.view.size;++received;
    if(p.origin.data)release(sub->owner->mem.rx_payload,p.origin.size,p.origin.data);
}
static void deliver(canard_t *receiver) {
    for(size_t i=0;i<frame_count;++i){canard_bytes_t data={.size=frames[i].size,.data=frames[i].data};(void)canard_ingest_frame(receiver,tick++,0,frames[i].id,data);}
}
int main(void) {
    const canard_mem_vtable_t memory_vtable={.free=release,.alloc=allocate};
    const canard_mem_t memory={.vtable=&memory_vtable};
    const canard_mem_set_t resources={.tx_transfer=memory,.tx_frame=memory,.rx_session=memory,.rx_payload=memory,.rx_filters=memory};
    const canard_vtable_t vtable={.now=now,.tx=transmit};
    const canard_subscription_vtable_t subscription_vtable={.on_message=on_message};
    canard_t sender,receiver;CHECK(canard_new(&sender,&vtable,resources,1,100,123,0));CHECK(canard_new(&receiver,&vtable,resources,1,100,456,0));
    CHECK(canard_set_node_id(&sender,11));CHECK(canard_set_node_id(&receiver,42));sender.tx.fd=false;
    canard_subscription_t sub;CHECK(canard_subscribe_13b(&receiver,&sub,7509,512,CANARD_DEFAULT_TRANSFER_ID_TIMEOUT_us,&subscription_vtable)==&sub);
    const unsigned char tiny[]={1,2,3};canard_bytes_chain_t chain={.bytes={.size=sizeof(tiny),.data=tiny}};
    CHECK(canard_publish_13b(&sender,tick+1000000,1,canard_prio_nominal,7509,0,chain,NULL));canard_poll(&sender,1);CHECK(frame_count==1);deliver(&receiver);
    CHECK(received==1&&message_size==sizeof(tiny)&&memcmp(message,tiny,sizeof(tiny))==0);
    deliver(&receiver);CHECK(received==1);
    unsigned char large[200];for(size_t i=0;i<sizeof(large);++i)large[i]=(unsigned char)(i*7U);
    frame_count=0;chain.bytes.size=sizeof(large);chain.bytes.data=large;
    CHECK(canard_publish_13b(&sender,tick+1000000,1,canard_prio_nominal,7509,1,chain,NULL));canard_poll(&sender,1);CHECK(frame_count>1);deliver(&receiver);
    CHECK(received==2&&message_size==sizeof(large)&&memcmp(message,large,sizeof(large))==0);
    frame_count=0;CHECK(canard_publish_13b(&sender,tick+1000000,1,canard_prio_nominal,7509,2,chain,NULL));canard_poll(&sender,1);
    frames[1].data[0]^=0x80;deliver(&receiver);CHECK(received==2);
    canard_unsubscribe(&receiver,&sub);canard_destroy(&sender);canard_destroy(&receiver);CHECK(allocations==0);
    puts("libcanard: classic CAN single/multiframe, duplicate/CRC rejection, allocation cleanup passed");
    return 0;
}
