/* LMX adapter, MIT. vfork is a platform API, not a C language extension. */
#ifndef _XOPEN_SOURCE
#define _XOPEN_SOURCE 700
#endif
#ifndef _DEFAULT_SOURCE
#define _DEFAULT_SOURCE 1
#endif
#ifndef _DARWIN_C_SOURCE
#define _DARWIN_C_SOURCE 1
#endif
#include <sys/select.h>
#include <sys/wait.h>
#include "../kopen.c"
