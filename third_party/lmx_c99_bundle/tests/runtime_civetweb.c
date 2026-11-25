/* Real loopback HTTP exchange; no Internet, external server or fixed port. */
#include "civetweb.h"
#include <stdio.h>
#include <string.h>

struct exchange {
    int requests;
    int failed;
};

static int serve_ping(struct mg_connection *connection, void *data)
{
    struct exchange *state = (struct exchange *)data;
    const struct mg_request_info *request = mg_get_request_info(connection);
    const char *header = mg_get_header(connection, "x-lmx");
    char query[32];

    if (!request || !request->request_method || !request->local_uri ||
        !request->query_string || !header ||
        strcmp(request->request_method, "GET") != 0 ||
        strcmp(request->local_uri, "/ping") != 0 ||
        strcmp(header, "request") != 0 ||
        mg_get_var(request->query_string, strlen(request->query_string),
                   "value", query, sizeof(query)) != 11 ||
        strcmp(query, "hello world") != 0) {
        state->failed = 1;
        (void)mg_printf(connection,
            "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\n"
            "Connection: close\r\n\r\nbad request");
        return 400;
    }

    ++state->requests;
    if (mg_printf(connection,
            "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n"
            "Content-Length: 4\r\nX-LMX: response\r\n"
            "Connection: close\r\n\r\npong") <= 0) {
        state->failed = 1;
    }
    return 200;
}

#define CHECK(condition) do { if (!(condition)) { \
    fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #condition); \
    goto cleanup; \
} } while (0)

int main(void)
{
    const char *options[] = {
        "listening_ports", "127.0.0.1:0",
        "num_threads", "1",
        "enable_keep_alive", "no",
        "request_timeout_ms", "3000",
        NULL
    };
    unsigned required = MG_FEATURES_IPV6 | MG_FEATURES_WEBSOCKET;
    unsigned initialized_features;
    struct mg_context *server = NULL;
    struct mg_connection *client = NULL;
    struct mg_server_port port;
    const struct mg_response_info *response;
    const char *header;
    struct exchange state = {0, 0};
    char error[256] = {0};
    char body[32] = {0};
    char decoded[32];
    size_t used = 0;
    int count;
    int initialized = 0;
    int result = 1;

#if LMX_TEST_CIVETWEB_TLS
    required |= MG_FEATURES_TLS;
#endif
#if LMX_TEST_CIVETWEB_ZLIB
    required |= MG_FEATURES_COMPRESSION;
#endif
    /* CivetWeb 1.16 initializes only the low eight feature bits. */
    initialized_features = mg_init_library(required & 0xFFu);
    initialized = initialized_features != 0;
    CHECK((initialized_features & (required & 0xFFu)) == (required & 0xFFu));
    CHECK(mg_version() != NULL);
    CHECK(mg_check_feature(required) == required);
    CHECK(mg_get_var("path=a%20b%2Fc", 14, "path", decoded,
                     sizeof(decoded)) == 5);
    CHECK(strcmp(decoded, "a b/c") == 0);

    server = mg_start(NULL, NULL, options);
    CHECK(server != NULL);
    mg_set_request_handler(server, "/ping", serve_ping, &state);
    CHECK(mg_get_server_ports(server, 1, &port) == 1);
    CHECK(port.port > 0 && !port.is_ssl);
    client = mg_connect_client("127.0.0.1", port.port, 0,
                               error, sizeof(error));
    CHECK(client != NULL);
    CHECK(mg_printf(client,
            "GET /ping?value=hello%%20world HTTP/1.1\r\n"
            "Host: localhost\r\nX-LMX: request\r\n"
            "Connection: close\r\n\r\n") > 0);
    CHECK(mg_get_response(client, error, sizeof(error), 3000) >= 0);
    response = mg_get_response_info(client);
    CHECK(response != NULL && response->status_code == 200);
    CHECK(response->content_length == 4);
    header = mg_get_header(client, "x-lmx");
    CHECK(header != NULL && strcmp(header, "response") == 0);

    while (used < sizeof(body) - 1) {
        count = mg_read(client, body + used, sizeof(body) - 1 - used);
        CHECK(count >= 0);
        if (count == 0) break;
        used += (size_t)count;
    }
    CHECK(used == 4 && memcmp(body, "pong", 4) == 0);

    mg_close_connection(client);
    client = NULL;
    mg_stop(server);
    server = NULL;
    /* Worker threads have joined; inspect callback state only after mg_stop. */
    CHECK(state.requests == 1 && !state.failed);
    result = 0;

cleanup:
    if (client) mg_close_connection(client);
    if (server) mg_stop(server);
    if (initialized) (void)mg_exit_library();
    if (result && error[0]) fprintf(stderr, "%s\n", error);
    return result;
}
