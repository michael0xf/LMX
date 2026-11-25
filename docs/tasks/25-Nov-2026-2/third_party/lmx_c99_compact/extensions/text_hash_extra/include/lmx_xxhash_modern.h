#ifndef LMX_XXHASH_MODERN_API_H
#define LMX_XXHASH_MODERN_API_H
/* This C translation unit must use only the modern xxHash header.
 * Legacy LZ4 xxHash calls belong in a separate C unit. The namespace aliases
 * are deliberately retained: undefining XXH_NAMESPACE breaks lazy expansion.
 */
#if defined(XXHASH_H_5627135585666179) || defined(XXH_NAMESPACE)
#error "Include lmx_xxhash_modern.h before any xxHash header; use separate C units for legacy xxHash"
#endif
#define XXH_NAMESPACE LMXC99_XXH_
#include "../../../vendor/xxhash/xxhash.h"
#endif
