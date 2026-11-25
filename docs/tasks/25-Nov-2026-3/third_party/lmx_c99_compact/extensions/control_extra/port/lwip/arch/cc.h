#ifndef LMX_LWIP_ARCH_CC_H
#define LMX_LWIP_ARCH_CC_H
#include <stdint.h>
/* A target port may override BYTE_ORDER on the compiler command line. */
#ifndef BYTE_ORDER
# if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#  define BYTE_ORDER 4321
# elif (defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__) || defined(_WIN32)
#  define BYTE_ORDER 1234
# else
#  error "Define BYTE_ORDER as 1234 (little) or 4321 (big) for this target"
# endif
#endif
#ifdef _MSC_VER
#define PACK_STRUCT_USE_INCLUDES
#endif
/* The application supplies its entropy policy and monotonic clock. */
uint32_t lmx_lwip_rand(void);
#define LWIP_RAND() lmx_lwip_rand()
#endif
