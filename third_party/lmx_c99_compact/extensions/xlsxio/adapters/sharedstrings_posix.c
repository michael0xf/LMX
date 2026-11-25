/* POSIX strcasecmp declaration is absent from upstream's private header;
 * native Windows uses its CRT branch instead. */
#ifndef _MSC_VER
#include <strings.h>
#endif
#include "xlsxio_read_sharedstrings.c"
