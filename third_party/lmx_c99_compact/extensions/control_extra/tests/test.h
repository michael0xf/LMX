#ifndef LMX_CONTROL_TEST_H
#define LMX_CONTROL_TEST_H
#include <stdio.h>
#include <stdlib.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s failed\n", __FILE__, __LINE__, #x); exit(1); } } while (0)
#endif
