/* Local RESP protocol fixture; this is not a Redis-server integration test. */
#include <hiredis.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>

struct peer { int fd; int ok; };

static int transfer(int fd, void *buffer, size_t length, int writing)
{
    size_t offset = 0;
    unsigned char *bytes = buffer;
    while (offset < length) {
        ssize_t n = writing ? send(fd, bytes + offset, length - offset, 0)
                            : recv(fd, bytes + offset, length - offset, 0);
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) return 0;
        offset += (size_t)n;
    }
    return 1;
}

static void *serve(void *arg)
{
    static const char ping[] = "*1\r\n$4\r\nPING\r\n";
    static const char echo[] = "*2\r\n$4\r\nECHO\r\n$3\r\na\0b\r\n";
    char pong[] = "+PONG\r\n";
    char echoed[] = "$3\r\na\0b\r\n";
    char request[64];
    struct peer *p = arg;
    p->ok = transfer(p->fd, request, sizeof(ping) - 1, 0)
        && memcmp(request, ping, sizeof(ping) - 1) == 0
        && transfer(p->fd, pong, sizeof(pong) - 1, 1)
        && transfer(p->fd, request, sizeof(echo) - 1, 0)
        && memcmp(request, echo, sizeof(echo) - 1) == 0
        && transfer(p->fd, echoed, sizeof(echoed) - 1, 1);
    return NULL;
}

static int socket_fixture(void)
{
    int fds[2];
    int started = 0;
    int ok = 0;
    struct timeval timeout = {2, 0};
    struct peer peer;
    pthread_t thread;
    redisContext *context = NULL;
    redisReply *reply = NULL;
    const char data[] = {'a', '\0', 'b'};
    const char *args[] = {"ECHO", data};
    const size_t lengths[] = {4, sizeof(data)};
    if (socketpair(AF_UNIX, SOCK_STREAM, 0, fds) != 0) return 0;
    peer.fd = fds[1];
    peer.ok = 0;
    if (setsockopt(fds[1], SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) != 0
        || setsockopt(fds[1], SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout)) != 0)
        goto done;
    context = redisConnectFd(fds[0]);
    if (!context || context->err) goto done;
    if (redisSetTimeout(context, timeout) != REDIS_OK) goto done;
    if (pthread_create(&thread, NULL, serve, &peer) != 0) goto done;
    started = 1;
    reply = redisCommand(context, "PING");
    if (!reply || reply->type != REDIS_REPLY_STATUS || reply->len != 4
        || memcmp(reply->str, "PONG", 4) != 0) goto done;
    freeReplyObject(reply);
    reply = redisCommandArgv(context, 2, args, lengths);
    if (!reply || reply->type != REDIS_REPLY_STRING || reply->len != sizeof(data)
        || memcmp(reply->str, data, sizeof(data)) != 0) goto done;
    ok = 1;
done:
    freeReplyObject(reply);
    if (context) redisFree(context);
    else close(fds[0]);
    if (!ok) shutdown(fds[1], SHUT_RDWR);
    if (started) pthread_join(thread, NULL);
    close(fds[1]);
    return ok && peer.ok;
}

static int parser_fixture(void)
{
    static const char map[] = "%2\r\n+name\r\n+LMX\r\n+value\r\n:42\r\n";
    static const char deep[] = "*1\r\n*1\r\n*1\r\n*1\r\n*1\r\n*1\r\n:7\r\n";
    redisReader *reader = redisReaderCreate();
    redisReply *reply = NULL;
    void *result = NULL;
    int ok = 0;
    if (!reader) return 0;
    if (redisReaderFeed(reader, map, 11) != REDIS_OK
        || redisReaderGetReply(reader, &result) != REDIS_OK || result) goto done;
    if (redisReaderFeed(reader, map + 11, sizeof(map) - 1 - 11) != REDIS_OK
        || redisReaderGetReply(reader, &result) != REDIS_OK || !result) goto done;
    reply = result;
    if (reply->type != REDIS_REPLY_MAP || reply->elements != 4
        || reply->element[3]->type != REDIS_REPLY_INTEGER
        || reply->element[3]->integer != 42) goto done;
    freeReplyObject(reply);
    reply = NULL;
    result = NULL;
    reader->maxdepth = 4;
    if (redisReaderFeed(reader, deep, sizeof(deep) - 1) != REDIS_OK
        || redisReaderGetReply(reader, &result) != REDIS_ERR
        || reader->err != REDIS_ERR_PROTOCOL) goto done;
    ok = 1;
done:
    freeReplyObject(reply);
    redisReaderFree(reader);
    return ok;
}

int main(void)
{
    (void)signal(SIGPIPE, SIG_IGN);
    if (!socket_fixture() || !parser_fixture()) {
        fputs("hiredis local RESP fixture failed\n", stderr);
        return 1;
    }
    puts("hiredis: local PING, binary ECHO, incremental RESP3 map and depth rejection passed");
    return 0;
}
