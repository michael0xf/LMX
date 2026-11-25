/* Supply the platform CRT declarations without modifying upstream XLSXIO.
 * Its private header already maps strcasecmp to _stricmp for MSVC. */
#ifdef _WIN32
#include <io.h>
#endif
#ifndef _MSC_VER
#include <strings.h>
#endif
#include "xlsxio_read.c"
