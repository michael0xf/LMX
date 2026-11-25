/* Offline C99 example: no connection to an external PostgreSQL server. */
#include <stdio.h>
#include <string.h>
#include <libpq-fe.h>

int main(void)
{
    char *error = NULL;
    PQconninfoOption *options;
    PQconninfoOption *entry;
    printf("libpq version: %d\n", PQlibVersion());
    options = PQconninfoParse(
        "host=/tmp dbname='lmx example' user=lmx sslmode=disable", &error);
    if (!options) {
        fprintf(stderr, "%s\n", error ? error : "Cannot allocate conninfo");
        PQfreemem(error);
        return 1;
    }
    for (entry = options; entry->keyword; ++entry) {
        if (entry->val && (strcmp(entry->keyword, "host") == 0 ||
                           strcmp(entry->keyword, "dbname") == 0 ||
                           strcmp(entry->keyword, "user") == 0))
            printf("%s = %s\n", entry->keyword, entry->val);
    }
    PQconninfoFree(options);
    puts("This collection's libpq profile has no TLS backend.");
    return 0;
}
