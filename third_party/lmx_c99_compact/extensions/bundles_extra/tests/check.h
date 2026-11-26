/* 0BSD: focused offline integration checks. */
#include <stdio.h>
#include <stdlib.h>
#define REQUIRE(c) do { if (!(c)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #c); exit(1); } } while (0)
