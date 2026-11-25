#include "lwip/init.h"
#include "lwip/udp.h"
#include "lwip/tcp.h"
#include "lwip/netif.h"
#include "lwip/timeouts.h"
#include "lwip/ip_addr.h"
#include "test.h"
#include <string.h>
static u32_t tick;static unsigned datagrams,tcp_connected,tcp_received;static struct tcp_pcb *accepted;
u32_t sys_now(void) { return tick; }
uint32_t lmx_lwip_rand(void) { static uint32_t state=0x12345678;state=1664525U*state+1013904223U;return state; }
static void poll_stack(void) { for(unsigned i=0;i<20;++i){netif_poll_all();tick+=10;sys_check_timeouts();} }
static void receive_udp(void *arg,struct udp_pcb *pcb,struct pbuf *p,const ip_addr_t *address,u16_t port) {
    (void)arg;(void)pcb;(void)address;(void)port;char data[32];CHECK(p->tot_len==5);CHECK(pbuf_copy_partial(p,data,5,0)==5);CHECK(memcmp(data,"local",5)==0);++datagrams;pbuf_free(p);
}
static err_t receive_tcp(void *arg,struct tcp_pcb *pcb,struct pbuf *p,err_t error) {
    (void)arg;CHECK(error==ERR_OK);
    if(p){char data[16];CHECK(p->tot_len==6);CHECK(pbuf_copy_partial(p,data,6,0)==6);CHECK(memcmp(data,"sensor",6)==0);tcp_recved(pcb,p->tot_len);pbuf_free(p);++tcp_received;}
    return ERR_OK;
}
static err_t accept_tcp(void *arg,struct tcp_pcb *pcb,err_t error) { (void)arg;CHECK(error==ERR_OK);accepted=pcb;tcp_recv(pcb,receive_tcp);return ERR_OK; }
static err_t connected_tcp(void *arg,struct tcp_pcb *pcb,err_t error) { (void)arg;(void)pcb;CHECK(error==ERR_OK);tcp_connected=1;return ERR_OK; }
int main(void) {
    lwip_init();ip_addr_t loop;
    for(unsigned family=0;family<2;++family){
        const u8_t type=family?IPADDR_TYPE_V6:IPADDR_TYPE_V4;ip_addr_set_loopback(type,&loop);
        struct udp_pcb *server=udp_new_ip_type(type),*client=udp_new_ip_type(type);CHECK(server&&client);
        CHECK(udp_bind(server,&loop,15000)==ERR_OK);udp_recv(server,receive_udp,NULL);
        struct pbuf *payload=pbuf_alloc(PBUF_TRANSPORT,5,PBUF_RAM);CHECK(payload);CHECK(pbuf_take(payload,"local",5)==ERR_OK);
        CHECK(udp_sendto(client,payload,&loop,15000)==ERR_OK);pbuf_free(payload);poll_stack();CHECK(datagrams==family+1);
        udp_remove(client);udp_remove(server);
    }
    ip_addr_set_loopback(IPADDR_TYPE_V4,&loop);
    struct tcp_pcb *listener=tcp_new_ip_type(IPADDR_TYPE_V4),*client=tcp_new_ip_type(IPADDR_TYPE_V4);CHECK(listener&&client);
    CHECK(tcp_bind(listener,&loop,15123)==ERR_OK);listener=tcp_listen(listener);CHECK(listener);tcp_accept(listener,accept_tcp);
    CHECK(tcp_connect(client,&loop,15123,connected_tcp)==ERR_OK);poll_stack();CHECK(tcp_connected&&accepted);
    CHECK(tcp_write(client,"sensor",6,TCP_WRITE_FLAG_COPY)==ERR_OK);CHECK(tcp_output(client)==ERR_OK);poll_stack();CHECK(tcp_received==1);
    tcp_abort(client);tcp_abort(accepted);CHECK(tcp_close(listener)==ERR_OK);
    puts("lwIP: IPv4/IPv6 UDP and IPv4 TCP raw API loopback passed without NIC/OS sockets");
    return 0;
}
