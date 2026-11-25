/* Private platform declarations used by the generated Gumbo source view. */
#ifndef LMX_DOCUMENTS_STRINGS_H
#define LMX_DOCUMENTS_STRINGS_H
#include <string.h>
#ifdef _WIN32
#define strcasecmp _stricmp
#define strncasecmp _strnicmp
#else
#include <strings.h>
#endif
#endif
