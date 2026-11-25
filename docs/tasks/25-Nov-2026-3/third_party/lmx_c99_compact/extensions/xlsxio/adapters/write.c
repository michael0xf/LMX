/* The upstream Win32 pipe/file branch needs its native CRT declarations. */
#ifdef _WIN32
#include <io.h>
#endif
#include "xlsxio_write.c"
