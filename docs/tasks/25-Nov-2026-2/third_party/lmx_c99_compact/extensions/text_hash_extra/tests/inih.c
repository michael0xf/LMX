#include <ini.h>
#include <stdio.h>
#include <string.h>

#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "check failed at %d: %s\n", __LINE__, #expr); return 1; } } while (0)

typedef struct configuration_t { int seen, valid; } configuration_t;

static int on_value(void *user, const char *section, const char *name, const char *value)
{
    configuration_t *config = (configuration_t *)user;
    ++config->seen;
    if (strcmp(section, "network") != 0) config->valid = 0;
    if (strcmp(name, "host") == 0 && strcmp(value, "lan.local") == 0) return 1;
    if (strcmp(name, "port") == 0 && strcmp(value, "27017") == 0) return 1;
    config->valid = 0;
    return 1;
}

static int reject_value(void *user, const char *section, const char *name, const char *value)
{
    (void)user; (void)section; (void)name; (void)value;
    return 0;
}

int main(void)
{
    configuration_t config = { 0, 1 };
    CHECK(ini_parse_string("; local configuration\n[network]\nhost=lan.local\nport=27017\n", on_value, &config) == 0);
    CHECK(config.seen == 2 && config.valid == 1);
    CHECK(ini_parse_string("[broken\n", on_value, &config) == 1);
    CHECK(ini_parse_string("x=1\n", reject_value, NULL) == 1);
    return 0;
}
