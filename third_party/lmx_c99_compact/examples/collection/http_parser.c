#include "llhttp.h"
#include <string.h>

static int complete(llhttp_t *parser) {
    int *count = parser->data;
    ++*count;
    return 0;
}

int main(void) {
    static const char request[] = "GET /lmx?name=one HTTP/1.1\r\nHost: localhost\r\n\r\n";
    llhttp_settings_t settings;
    llhttp_t parser;
    int count = 0;
    llhttp_settings_init(&settings);
    settings.on_message_complete = complete;
    llhttp_init(&parser, HTTP_REQUEST, &settings);
    parser.data = &count;
    return llhttp_execute(&parser, request, strlen(request)) != HPE_OK || count != 1;
}
