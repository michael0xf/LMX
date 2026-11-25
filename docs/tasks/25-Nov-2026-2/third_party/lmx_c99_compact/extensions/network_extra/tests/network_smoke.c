#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ares.h>
#include <event2/event.h>
#include <event2/buffer.h>
#include <event2/http.h>
#include "mdns.h"

static void tick(evutil_socket_t fd, short what, void *arg)
{
    int *counter = (int *)arg;
    (void)fd; (void)what;
    ++*counter;
}

int main(void)
{
    struct event_base *base;
    struct event *timer;
    struct evbuffer *buffer;
    struct timeval delay = {0, 1};
    struct evhttp_uri *uri;
    ares_channel channel;
    int ticks = 0;
    unsigned char *query = NULL;
    int query_len = 0;
    char encoded[128], decoded[128];
    size_t off = 0;
    mdns_string_t text;
    assert(ares_library_init(ARES_LIB_INIT_ALL) == ARES_SUCCESS);
    assert(ares_init(&channel) == ARES_SUCCESS);
    /* Building a DNS packet does not contact the Internet or a DNS service. */
    assert(ares_create_query("station.local", 1, 1, 0x1234, 1,
                             &query, &query_len, 0) == ARES_SUCCESS);
    assert(query_len > 12 && query[0] == 0x12 && query[1] == 0x34);
    ares_free_string(query);
    ares_destroy(channel);
    ares_library_cleanup();
    base = event_base_new(); assert(base != NULL);
    timer = evtimer_new(base, tick, &ticks); assert(timer != NULL);
    assert(evtimer_add(timer, &delay) == 0);
    assert(event_base_dispatch(base) >= 0);
    assert(ticks == 1);
    buffer = evbuffer_new(); assert(buffer != NULL);
    assert(evbuffer_add(buffer, "local", 5) == 0);
    assert(evbuffer_get_length(buffer) == 5);
    assert(evbuffer_remove(buffer, decoded, 5) == 5 && memcmp(decoded, "local", 5) == 0);
    uri = evhttp_uri_parse("http://station.local:8080/status"); assert(uri != NULL);
    assert(strcmp(evhttp_uri_get_host(uri), "station.local") == 0);
    assert(evhttp_uri_get_port(uri) == 8080);
    evhttp_uri_free(uri); evbuffer_free(buffer); event_free(timer); event_base_free(base);
    assert(mdns_string_make(encoded, sizeof encoded, encoded, "station.local.", 14, NULL) != NULL);
    text = mdns_string_extract(encoded, sizeof encoded, &off, decoded, sizeof decoded);
    assert(text.length == 14 && memcmp(text.str, "station.local.", 14) == 0);
    puts("network_offline_smoke: PASS (DNS packet, event timer, buffer, HTTP URI, mDNS name)");
    return 0;
}
