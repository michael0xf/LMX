#ifndef LMX_SYSTEMS_CHECK_H
#define LMX_SYSTEMS_CHECK_H
#include <stdio.h>
#define CHECK(condition) do { if (!(condition)) { \
    fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #condition); return 1; \
} } while (0)
#endif
