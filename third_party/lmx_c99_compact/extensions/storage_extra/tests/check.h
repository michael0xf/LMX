/* SPDX-License-Identifier: 0BSD */
#ifndef LMX_STORAGE_CHECK_H
#define LMX_STORAGE_CHECK_H
#include <stdio.h>
#define CHECK(expr) do { if (!(expr)) { \
    fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #expr); return 1; \
} } while (0)
#endif
