#ifndef LMX_REFERENCE_REAL_PROVIDER_H
#define LMX_REFERENCE_REAL_PROVIDER_H
#include "numeric_provider.h"
#include <libbf.h>

/* Per-actor native service state. Construct before the actor arena; destroy
 * after every owned real payload. It is never a global numeric context. */
typedef struct LmxRefRealOwner {
    bf_context_t backend;
    size_t live_values;
    size_t allocated_bytes;
    size_t allocation_limit;
    int initialized;
} LmxRefRealOwner;

typedef struct LmxRefReal {
    LmxRefRealOwner *owner;
    bf_t number;
} LmxRefReal;

/* Operation profile, independent of the provider's caches/allocator. */
typedef struct LmxRefRealContext {
    uint64_t precision_bits;
    unsigned exponent_bits;
    LmxRefRounding rounding;
    uint32_t traps;
    int subnormals;
    int exact_required;
} LmxRefRealContext;

void lmx_ref_real_owner_init(LmxRefRealOwner *owner);
/* Explicit owner budget includes allocator headers and backend caches. It
 * does not include the separate arena chunks/finalizer ledger. */
LmxRefStatus lmx_ref_real_owner_limit(LmxRefRealOwner *owner, size_t bytes);
/* Fails if owned values are still alive; does not invalidate them. */
LmxRefStatus lmx_ref_real_owner_end(LmxRefRealOwner *owner);
void lmx_ref_real_row(LmxRefType *row, LmxRefRealOwner *owner,
                      int code, int uninit_code);
LmxRefStatus lmx_ref_real_parse(LmxRefArena *arena, const LmxRefType *type,
                                const char *text, const LmxRefRealContext *context,
                                LmxRefNumericStatus *status, LmxRefRecord *out);
LmxRefStatus lmx_ref_real_add(LmxRefArena *arena, const LmxRefType *type,
                              const LmxRefReal *a, const LmxRefReal *b,
                              const LmxRefRealContext *context,
                              LmxRefNumericStatus *status, LmxRefRecord *out);
LmxRefStatus lmx_ref_real_sqrt(LmxRefArena *arena, const LmxRefType *type,
                               const LmxRefReal *a, const LmxRefRealContext *context,
                               LmxRefNumericStatus *status, LmxRefRecord *out);
/* Exact, base-16 canonical value text, not an ABI or a byte dump of bf_t.
 * Preserve the operation profile separately. Caller uses free(). */
LmxRefStatus lmx_ref_real_text(const LmxRefReal *value, char **out);
/* Explicit narrowing: no ordinary real operation silently uses double. */
LmxRefStatus lmx_ref_real_to_binary64(const LmxRefReal *value,
                                     const LmxRefRealContext *context,
                                     LmxRefNumericStatus *status, double *out);

#endif
