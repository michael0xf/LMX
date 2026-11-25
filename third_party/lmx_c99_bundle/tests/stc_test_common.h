#ifndef LMX_STC_TEST_COMMON_H
#define LMX_STC_TEST_COMMON_H
#include <stdio.h>
#include <stdlib.h>
#define CHECK(condition) do { \
    if (!(condition)) { \
        fprintf(stderr, "%s:%d: check failed: %s\n", __FILE__, __LINE__, #condition); \
        return EXIT_FAILURE; \
    } \
} while (0)
#endif
