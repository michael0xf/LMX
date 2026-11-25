#define _POSIX_C_SOURCE 200809L
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <curl/curl.h>
#include <zlib.h>

static const char response_text[] = "LMX local HTTP path, headers and gzip roundtrip\n";
struct received { char data[256]; size_t length; int saw_header; };

static int send_all(int socket_fd, const void *data, size_t length)
{
    const unsigned char *p = data;
    while (length) {
        ssize_t sent = send(socket_fd, p, length, 0);
        if (sent < 0 && errno == EINTR) continue;
        if (sent <= 0) return 1;
        p += sent;
        length -= (size_t)sent;
    }
    return 0;
}

static int serve_one(int listener)
{
    int client;
    char request[4096], header[256];
    unsigned char compressed[256];
    size_t used = 0;
    z_stream stream;
    int header_length;
    client = accept(listener, NULL, NULL);
    if (client < 0) return 1;
    request[0] = '\0';
    while (used + 1 < sizeof(request) && strstr(request, "\r\n\r\n") == NULL) {
        ssize_t length = recv(client, request + used, sizeof(request) - used - 1, 0);
        if (length < 0 && errno == EINTR) continue;
        if (length <= 0) { close(client); return 2; }
        used += (size_t)length;
        request[used] = '\0';
    }
    if (strncmp(request, "GET /lmx/check?value=7 HTTP/1.1\r\n", 33) != 0 ||
        strstr(request, "X-LMX-Test: request-value\r\n") == NULL) {
        close(client); return 3;
    }
    memset(&stream, 0, sizeof(stream));
    if (deflateInit2(&stream, Z_BEST_SPEED, Z_DEFLATED, MAX_WBITS + 16, 8, Z_DEFAULT_STRATEGY) != Z_OK) {
        close(client); return 4;
    }
    stream.next_in = (Bytef *)response_text;
    stream.avail_in = (uInt)(sizeof(response_text) - 1);
    stream.next_out = compressed;
    stream.avail_out = sizeof(compressed);
    if (deflate(&stream, Z_FINISH) != Z_STREAM_END) {
        deflateEnd(&stream); close(client); return 5;
    }
    header_length = snprintf(header, sizeof(header),
        "HTTP/1.1 200 OK\r\nContent-Encoding: gzip\r\nContent-Length: %lu\r\n"
        "X-LMX-Test: response-value\r\nConnection: close\r\n\r\n", (unsigned long)stream.total_out);
    if (header_length <= 0 || (size_t)header_length >= sizeof(header) ||
        send_all(client, header, (size_t)header_length) ||
        send_all(client, compressed, (size_t)stream.total_out)) {
        deflateEnd(&stream); close(client); return 6;
    }
    deflateEnd(&stream);
    close(client);
    return 0;
}

static size_t receive_body(char *data, size_t size, size_t count, void *user)
{
    struct received *received = user;
    size_t length = size * count;
    if (length > sizeof(received->data) - received->length) return 0;
    memcpy(received->data + received->length, data, length);
    received->length += length;
    return length;
}

static size_t receive_header(char *data, size_t size, size_t count, void *user)
{
    struct received *received = user;
    static const char expected[] = "X-LMX-Test: response-value\r\n";
    size_t length = size * count;
    if (length == sizeof(expected) - 1 && memcmp(data, expected, length) == 0)
        received->saw_header = 1;
    return length;
}

int main(void)
{
    int listener, status = 0, result = 1;
    struct sockaddr_in address;
    socklen_t address_length = sizeof(address);
    pid_t child;
    CURL *curl;
    CURLcode code;
    struct curl_slist *headers;
    struct received received = {{0}, 0, 0};
    char url[128];
    long response_code = 0;
    listener = socket(AF_INET, SOCK_STREAM, 0);
    if (listener < 0) return 1;
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(listener, (struct sockaddr *)&address, sizeof(address)) ||
        getsockname(listener, (struct sockaddr *)&address, &address_length) ||
        listen(listener, 1)) { close(listener); return 1; }
    child = fork();
    if (child < 0) { close(listener); return 1; }
    if (child == 0) {
        int child_result = serve_one(listener);
        close(listener);
        _exit(child_result);
    }
    close(listener);
    if (curl_global_init(CURL_GLOBAL_DEFAULT) != CURLE_OK) goto finish_child;
    curl = curl_easy_init();
    if (!curl) { curl_global_cleanup(); goto finish_child; }
    headers = curl_slist_append(NULL, "X-LMX-Test: request-value");
    if (!headers) { curl_easy_cleanup(curl); curl_global_cleanup(); goto finish_child; }
    snprintf(url, sizeof(url), "http://127.0.0.1:%u/lmx/check?value=7", (unsigned)ntohs(address.sin_port));
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_PROXY, "");
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_ACCEPT_ENCODING, "gzip");
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, receive_body);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &received);
    curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, receive_header);
    curl_easy_setopt(curl, CURLOPT_HEADERDATA, &received);
    code = curl_easy_perform(curl);
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
    if (code == CURLE_OK && response_code == 200 && received.saw_header &&
        received.length == sizeof(response_text) - 1 &&
        memcmp(received.data, response_text, received.length) == 0) result = 0;
    else fprintf(stderr, "local HTTP failed: %s, status=%ld, bytes=%lu\n", curl_easy_strerror(code), response_code, (unsigned long)received.length);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);
    curl_global_cleanup();
finish_child:
    if (result) kill(child, SIGTERM);
    if (waitpid(child, &status, 0) != child || !WIFEXITED(status) || WEXITSTATUS(status)) result = 1;
    return result;
}
