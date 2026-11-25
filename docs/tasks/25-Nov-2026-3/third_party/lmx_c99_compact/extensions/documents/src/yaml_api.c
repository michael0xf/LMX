/* The standard Windows CRT name is _strdup; keep libyaml's API unchanged. */
#include <string.h>
#ifdef _WIN32
#define strdup _strdup
#endif
#include "api.c"
