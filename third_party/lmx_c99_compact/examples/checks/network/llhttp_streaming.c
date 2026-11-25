#include "llhttp.h"
#include <stdio.h>
#include <string.h>

typedef struct capture {
    char url[128];
    char body[128];
    char header_names[8][64];
    char header_values[8][128];
    size_t headers;
    size_t url_chunks;
    unsigned complete;
} capture;

static int append(char *out, size_t cap, const char *at, size_t length) {
    size_t used = strlen(out);
    if (length >= cap - used) return -1;
    memcpy(out + used, at, length);
    out[used + length] = 0;
    return 0;
}

static int on_url(llhttp_t *p, const char *at, size_t length) {
    capture *c = p->data;
    ++c->url_chunks;
    return append(c->url, sizeof c->url, at, length);
}

static int on_body(llhttp_t *p, const char *at, size_t length) {
    capture *c = p->data;
    return append(c->body, sizeof c->body, at, length);
}

static int on_field(llhttp_t *p, const char *at, size_t length) {
    capture *c = p->data;
    if (c->headers >= 8) return -1;
    return append(c->header_names[c->headers], sizeof c->header_names[0], at, length);
}

static int on_value(llhttp_t *p, const char *at, size_t length) {
    capture *c = p->data;
    if (c->headers >= 8) return -1;
    return append(c->header_values[c->headers], sizeof c->header_values[0], at, length);
}

static int on_value_complete(llhttp_t *p) {
    capture *c = p->data;
    if (c->headers >= 8) return -1;
    ++c->headers;
    return 0;
}

static int on_complete(llhttp_t *p) {
    capture *c = p->data;
    ++c->complete;
    return 0;
}

static int header_is(const capture *c, const char *name, const char *value) {
    size_t i;
    for (i = 0; i < c->headers; ++i)
        if (strcmp(c->header_names[i], name) == 0 && strcmp(c->header_values[i], value) == 0)
            return 1;
    return 0;
}

static int good(const char *label, const char *request, const char *url,
                const char *body, llhttp_method_t method, int trailer) {
    capture c = {0};
    llhttp_settings_t s;
    llhttp_t p;
    size_t i;
    llhttp_settings_init(&s);
    s.on_url = on_url;
    s.on_header_field = on_field;
    s.on_header_value = on_value;
    s.on_header_value_complete = on_value_complete;
    s.on_body = on_body;
    s.on_message_complete = on_complete;
    llhttp_init(&p, HTTP_REQUEST, &s);
    p.data = &c;
    for (i = 0; i < strlen(request); ++i) {
        llhttp_errno_t err = llhttp_execute(&p, request + i, 1);
        if (err != HPE_OK) {
            fprintf(stderr, "%s: %s (%s) at byte %zu\n", label,
                    llhttp_errno_name(err), llhttp_get_error_reason(&p), i);
            return 1;
        }
    }
    if (llhttp_finish(&p) != HPE_OK || c.complete != 1 || c.url_chunks < 2 ||
        strcmp(c.url, url) != 0 || strcmp(c.body, body) != 0 ||
        p.method != method || p.http_major != 1 || p.http_minor != 1 ||
        !header_is(&c, "Host", "localhost") ||
        !header_is(&c, "X-LMX", "alpha beta") ||
        (trailer && !header_is(&c, "X-End", "yes"))) {
        fprintf(stderr, "%s: incorrect captured request\n", label);
        return 1;
    }
    printf("PASS %s, one-byte chunks, URL=%s, body=%zu bytes, headers=%zu\n",
           label, c.url, strlen(c.body), c.headers);
    return 0;
}

static int bad(const char *label, const char *request) {
    llhttp_settings_t s;
    llhttp_t p;
    size_t i;
    llhttp_errno_t err = HPE_OK;
    llhttp_settings_init(&s);
    llhttp_init(&p, HTTP_REQUEST, &s);
    for (i = 0; i < strlen(request) && err == HPE_OK; ++i)
        err = llhttp_execute(&p, request + i, 1);
    if (err == HPE_OK) err = llhttp_finish(&p);
    if (err == HPE_OK) {
        fprintf(stderr, "%s: malformed request accepted\n", label);
        return 1;
    }
    printf("PASS reject %s: %s\n", label, llhttp_errno_name(err));
    return 0;
}

int main(void) {
    int failures = 0;
    printf("llhttp %d.%d.%d; sizeof(llhttp_t)=%zu; sizeof(llhttp_settings_t)=%zu\n",
           LLHTTP_VERSION_MAJOR, LLHTTP_VERSION_MINOR, LLHTTP_VERSION_PATCH,
           sizeof(llhttp_t), sizeof(llhttp_settings_t));
    failures += good("GET path/query/headers",
        "GET /path/one?x=1&name=a%20b HTTP/1.1\r\nHost: localhost\r\nX-LMX: alpha beta\r\n\r\n",
        "/path/one?x=1&name=a%20b", "", HTTP_GET, 0);
    failures += good("fixed-length body",
        "POST /body HTTP/1.1\r\nHost: localhost\r\nX-LMX: alpha beta\r\nContent-Length: 11\r\n\r\nhello world",
        "/body", "hello world", HTTP_POST, 0);
    failures += good("chunked body and trailer",
        "POST /chunked HTTP/1.1\r\nHost: localhost\r\nX-LMX: alpha beta\r\nTransfer-Encoding: chunked\r\n\r\n"
        "5\r\nhello\r\n6\r\n world\r\n0\r\nX-End: yes\r\n\r\n",
        "/chunked", "hello world", HTTP_POST, 1);
    failures += bad("TE then CL",
        "POST / HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked\r\nContent-Length: 3\r\n\r\n0\r\n\r\n");
    failures += bad("CL then TE",
        "POST / HTTP/1.1\r\nHost: localhost\r\nContent-Length: 3\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n");
    failures += bad("invalid Content-Length",
        "POST / HTTP/1.1\r\nHost: localhost\r\nContent-Length: 1x\r\n\r\na");
    failures += bad("chunked not final transfer coding",
        "POST / HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked, gzip\r\n\r\n0\r\n\r\n");
    return failures != 0;
}
