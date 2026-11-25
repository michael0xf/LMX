/* Offline TLS integration: real curl clients -> CivetWeb server, one shared
 * static Mbed TLS. The shipped key/certificates are public test fixtures. */
#include <civetweb.h>
#include <curl/curl.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>

#define CLIENTS 8
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); goto cleanup; } } while (0)

struct server_state { pthread_mutex_t mutex; int requests; int failed; };
struct response { char data[64]; size_t used; int header; };
struct client_state { const char *ca; int port; long tls; int result; };

static int serve(struct mg_connection *connection, void *userdata)
{
    struct server_state *state = (struct server_state *)userdata;
    const struct mg_request_info *request = mg_get_request_info(connection);
    const char *header = mg_get_header(connection, "x-lmx");
    int failed = !request || !request->is_ssl || !request->request_method ||
        !request->local_uri || !request->query_string || !header ||
        strcmp(request->request_method, "GET") ||
        strcmp(request->local_uri, "/secure") ||
        strcmp(request->query_string, "value=7") || strcmp(header, "request");
    pthread_mutex_lock(&state->mutex);
    state->requests++;
    state->failed |= failed;
    pthread_mutex_unlock(&state->mutex);
    if (failed) {
        (void)mg_printf(connection, "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\nConnection: close\r\n\r\n");
        return 400;
    }
    (void)mg_printf(connection,
        "HTTP/1.1 200 OK\r\nContent-Length: 15\r\n"
        "X-LMX: verified\r\nConnection: close\r\n\r\nsecure-response");
    return 200;
}

static size_t body_callback(char *data, size_t size, size_t count, void *userdata)
{
    struct response *response = (struct response *)userdata;
    size_t bytes = size * count;
    if (bytes > sizeof(response->data) - response->used) return 0;
    memcpy(response->data + response->used, data, bytes);
    response->used += bytes;
    return bytes;
}

static size_t header_callback(char *data, size_t size, size_t count, void *userdata)
{
    struct response *response = (struct response *)userdata;
    size_t bytes = size * count;
    static const char expected[] = "X-LMX: verified\r\n";
    if (bytes == sizeof(expected) - 1 && !memcmp(data, expected, bytes)) response->header = 1;
    return bytes;
}

static int request(const char *ca, int port, int bad_hostname, long tls,
                   CURLcode expected)
{
    CURL *curl = curl_easy_init();
    struct curl_slist *resolve = NULL, *headers = NULL;
    struct response response = {{0}, 0, 0};
    char url[160], mapping[100], error[CURL_ERROR_SIZE] = {0};
    CURLcode code;
    long status = 0, verify = -1;
    int success = 0;
    if (!curl) return 0;
    snprintf(url, sizeof(url), "https://%s:%d/secure?value=7",
             bad_hostname ? "127.0.0.1" : "localhost", port);
    snprintf(mapping, sizeof(mapping), "localhost:%d:127.0.0.1", port);
    resolve = curl_slist_append(resolve, mapping);
    headers = curl_slist_append(headers, "X-LMX: request");
    if (!resolve || !headers) goto done;
#define SETOPT(k,v) do { if (curl_easy_setopt(curl,(k),(v)) != CURLE_OK) goto done; } while (0)
    SETOPT(CURLOPT_URL, url);
    SETOPT(CURLOPT_PROXY, "");
    SETOPT(CURLOPT_RESOLVE, resolve);
    SETOPT(CURLOPT_HTTPHEADER, headers);
    SETOPT(CURLOPT_CAINFO, ca);
    SETOPT(CURLOPT_SSL_VERIFYPEER, 1L);
    SETOPT(CURLOPT_SSL_VERIFYHOST, 2L);
    SETOPT(CURLOPT_SSLVERSION, tls);
    SETOPT(CURLOPT_HTTP_VERSION, (long)CURL_HTTP_VERSION_1_1);
    SETOPT(CURLOPT_CONNECTTIMEOUT_MS, 5000L);
    SETOPT(CURLOPT_TIMEOUT_MS, 10000L);
    SETOPT(CURLOPT_NOSIGNAL, 1L);
    SETOPT(CURLOPT_WRITEFUNCTION, body_callback);
    SETOPT(CURLOPT_WRITEDATA, &response);
    SETOPT(CURLOPT_HEADERFUNCTION, header_callback);
    SETOPT(CURLOPT_HEADERDATA, &response);
    SETOPT(CURLOPT_ERRORBUFFER, error);
#undef SETOPT
    code = curl_easy_perform(curl);
    if (code != expected) {
        fprintf(stderr, "TLS request expected %d got %d: %s\n", (int)expected, (int)code, error);
        goto done;
    }
    if (code == CURLE_OK) {
        if (curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &status) != CURLE_OK ||
            curl_easy_getinfo(curl, CURLINFO_SSL_VERIFYRESULT, &verify) != CURLE_OK ||
            status != 200 || verify != 0 || response.used != 15 || !response.header ||
            memcmp(response.data, "secure-response", 15)) goto done;
    }
    success = 1;
done:
    curl_easy_cleanup(curl);
    curl_slist_free_all(headers);
    curl_slist_free_all(resolve);
    return success;
}

static void *client_thread(void *userdata)
{
    struct client_state *client = (struct client_state *)userdata;
    client->result = request(client->ca, client->port, 0, client->tls, CURLE_OK);
    return NULL;
}

int main(int argc, char **argv)
{
    char server_pem[1024], ca_pem[1024], untrusted_pem[1024];
    const char *options[] = {
        "listening_ports", "127.0.0.1:0s", "ssl_certificate", server_pem,
        "num_threads", "4", "enable_keep_alive", "no", "request_timeout_ms", "5000", NULL
    };
    struct mg_context *server = NULL;
    struct mg_server_port port;
    struct server_state state;
    struct client_state clients[CLIENTS];
    pthread_t threads[CLIENTS];
    const curl_version_info_data *version;
    long tls12 = CURL_SSLVERSION_TLSv1_2 | CURL_SSLVERSION_MAX_TLSv1_2;
    long tls13 = CURL_SSLVERSION_TLSv1_3 | CURL_SSLVERSION_MAX_TLSv1_3;
    int initialized = 0, curl_initialized = 0, mutex_initialized = 0;
    int started = 0, i, result = 1;
    memset(&state, 0, sizeof(state));
    CHECK(argc == 2);
    CHECK(snprintf(server_pem, sizeof(server_pem), "%s/server.pem", argv[1]) < (int)sizeof(server_pem));
    CHECK(snprintf(ca_pem, sizeof(ca_pem), "%s/ca.pem", argv[1]) < (int)sizeof(ca_pem));
    CHECK(snprintf(untrusted_pem, sizeof(untrusted_pem), "%s/untrusted-ca.pem", argv[1]) < (int)sizeof(untrusted_pem));
    CHECK(pthread_mutex_init(&state.mutex, NULL) == 0);
    mutex_initialized = 1;
    CHECK(mg_init_library(MG_FEATURES_TLS) == MG_FEATURES_TLS);
    initialized = 1;
    /* Start the TLS server independently of curl's global initialization. */
    server = mg_start(NULL, NULL, options);
    CHECK(server != NULL);
    mg_set_request_handler(server, "/secure", serve, &state);
    CHECK(mg_get_server_ports(server, 1, &port) == 1 && port.port > 0 && port.is_ssl);
    CHECK(curl_global_init(CURL_GLOBAL_DEFAULT) == CURLE_OK);
    curl_initialized = 1;
    version = curl_version_info(CURLVERSION_NOW);
    CHECK(version && version->ssl_version && strstr(version->ssl_version, "mbedTLS/3.6.7"));
    CHECK(request(ca_pem, port.port, 0, tls12, CURLE_OK));
    CHECK(request(ca_pem, port.port, 0, tls13, CURLE_OK));
    CHECK(request(untrusted_pem, port.port, 0, tls12, CURLE_PEER_FAILED_VERIFICATION));
    CHECK(request(ca_pem, port.port, 1, tls12, CURLE_PEER_FAILED_VERIFICATION));
    for (i = 0; i < CLIENTS; ++i) {
        clients[i].ca = ca_pem;
        clients[i].port = port.port;
        clients[i].tls = i % 2 ? tls12 : tls13;
        clients[i].result = 0;
        CHECK(pthread_create(&threads[i], NULL, client_thread, &clients[i]) == 0);
        ++started;
    }
    for (i = 0; i < started; ++i) (void)pthread_join(threads[i], NULL);
    started = 0;
    for (i = 0; i < CLIENTS; ++i) CHECK(clients[i].result);
    mg_stop(server);
    server = NULL;
    CHECK(state.requests == CLIENTS + 2 && !state.failed);
    puts("TLS 1.2/1.3, trusted CA+hostname, rejected CA/hostname, 8 concurrent clients: passed");
    result = 0;
cleanup:
    for (i = 0; i < started; ++i) (void)pthread_join(threads[i], NULL);
    if (server) mg_stop(server);
    if (initialized) (void)mg_exit_library();
    /* libcurl releases process-global PSA state: all TLS servers are stopped. */
    if (curl_initialized) curl_global_cleanup();
    if (mutex_initialized) (void)pthread_mutex_destroy(&state.mutex);
    return result;
}
