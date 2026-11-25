/* C99 reference ABI for the documentation catalogue, not an installed kernel ABI.
 * Every frame is explicit, temporary and owned by one actor/call. No global R0.
 * See README.ru.md. LMX graph <-> frame conversion is an integration obligation.
 */
#ifndef LMX_CATALOG_BRIDGE_H
#define LMX_CATALOG_BRIDGE_H
#include <stddef.h>
#include <stdint.h>
#include <limits.h>

enum lmx_catalog_status {
    LMXC_OK = 0,
    LMXC_REVIEW_REQUIRED = 1,
    LMXC_BAD_FRAME = 2,
    LMXC_ARITY = 3,
    LMXC_TYPE = 4,
    LMXC_RANGE = 5,
    LMXC_OWNER = 6,
    LMXC_EXPIRED = 7,
    LMXC_READ_ONLY = 8,
    LMXC_LENGTH = 9,
    LMXC_ALIGNMENT = 10,
    LMXC_EMBEDDED_NUL = 11
};
enum lmx_catalog_kind {
    LMXC_NONE, LMXC_SIGNED, LMXC_UNSIGNED, LMXC_REAL,
    LMXC_SPAN, LMXC_RESOURCE
};

/* These are C-only transport slots, never records of the LMX arena. A span is
 * produced by an explicit checked borrow/materialisation, not an Lmx* cast. */
typedef struct lmx_catalog_span {
    void *bytes;
    size_t length_bytes;
    size_t alignment;
    const void *owner;
    const uint64_t *live_generation;
    uint64_t borrowed_generation;
    int writable;
} lmx_catalog_span;

typedef struct lmx_catalog_resource {
    void *native;
    const void *owner;
    const uint64_t *live_generation;
    uint64_t borrowed_generation;
    const char *native_type;
} lmx_catalog_resource;

typedef struct lmx_catalog_slot {
    enum lmx_catalog_kind kind;
    int64_t signed_value;
    uint64_t unsigned_value;
    double real_value;
    lmx_catalog_span span;
    lmx_catalog_resource resource;
} lmx_catalog_slot;

typedef struct lmx_catalog_frame {
    uint32_t abi_version;
    const void *owner;
    const lmx_catalog_slot *arguments;
    size_t argument_count;
    lmx_catalog_slot result;
    int status;
    const char *diagnostic_symbol;
} lmx_catalog_frame;

int lmx_catalog_check(void *opaque, size_t arity);
int lmx_catalog_review_required(void *opaque, const char *symbol);
int lmx_catalog_read_i64(lmx_catalog_frame *, size_t, int64_t, int64_t, int64_t *);
int lmx_catalog_read_u64(lmx_catalog_frame *, size_t, uint64_t, uint64_t *);
int lmx_catalog_read_int(lmx_catalog_frame *, size_t, int *);
int lmx_catalog_read_uint(lmx_catalog_frame *, size_t, unsigned int *);
int lmx_catalog_read_ulong(lmx_catalog_frame *, size_t, unsigned long *);
int lmx_catalog_read_size(lmx_catalog_frame *, size_t, size_t *);
int lmx_catalog_read_double(lmx_catalog_frame *, size_t, double *);
int lmx_catalog_read_span(lmx_catalog_frame *, size_t, size_t, size_t, int, void **);
int lmx_catalog_read_cstring(lmx_catalog_frame *, size_t, const char **);
int lmx_catalog_read_resource(lmx_catalog_frame *, size_t, const char *, void **);
int lmx_catalog_write_i64(lmx_catalog_frame *, int64_t);
int lmx_catalog_write_u64(lmx_catalog_frame *, uint64_t);
int lmx_catalog_write_real(lmx_catalog_frame *, double);
int lmx_catalog_write_none(lmx_catalog_frame *);

/* Integration must keep the owner and generation cells alive through the
 * entire foreign call; the generation pointer itself is NOT an immortal token.
 * A generation comparison alone cannot pin storage. Materialise or pin the
 * backing and retain resources until return, including during reentrant foreign
 * callbacks; alternatively refuse every callback that can mutate/close them.
 * Shared immutable input may be copied into an owner-local lease. The strict
 * same-owner rule here does not repeal LMX independent-immutable sharing.
 * Async retention/callbacks need a different owned lease and an actor message.
 * Review-required is not a successful C result and must never be swallowed. */
#endif
