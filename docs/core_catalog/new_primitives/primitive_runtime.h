#ifndef LMX_REFERENCE_PRIMITIVE_RUNTIME_H
#define LMX_REFERENCE_PRIMITIVE_RUNTIME_H

/* C99 integration example, NOT the current kernel ABI. See README.ru.md.
 * The caller supplies rows resolved from its graph; there is no global table.
 * Records have natural payload alignment >= 4; the type is exactly at p-4.
 */
#include <stddef.h>
#include <stdint.h>

#define LMX_REF_ALIGNOF(T) offsetof(struct { char prefix; T value; }, value)

typedef enum LmxRefStatus {
    LMX_REF_OK = 0,
    LMX_REF_ARGUMENT,
    LMX_REF_RANGE,
    LMX_REF_ALLOCATION,
    LMX_REF_TYPE,
    LMX_REF_ABSENT,
    LMX_REF_NUMERIC,
    LMX_REF_ENCODING
} LmxRefStatus;

typedef LmxRefStatus (*LmxRefClone)(void *destination, const void *source,
                                     void *destination_context);
typedef void (*LmxRefDrop)(void *payload);

typedef struct LmxRefType {
    int code;
    int uninit_code;
    const char *name;
    size_t size;
    size_t alignment;
    LmxRefClone clone;
    LmxRefDrop drop;
    /* Actor-owned provider state resolved from the destination graph. */
    void *context;
} LmxRefType;

typedef struct LmxRefRegistry {
    const LmxRefType *rows;
    size_t count;
} LmxRefRegistry;

typedef struct LmxRefChunk LmxRefChunk;
typedef struct LmxRefFinalizer LmxRefFinalizer;
typedef struct LmxRefArena {
    LmxRefChunk *chunk;
    LmxRefFinalizer *finalizers;
    size_t chunk_size;
    size_t live_finalizers;
} LmxRefArena;

/* Allocator service handle only. An uninit value has value == NULL and exactly
 * one int code in the arena. This is not a new public LMX pointer ABI. */
typedef struct LmxRefRecord {
    int *code;
    void *value;
} LmxRefRecord;

typedef struct LmxRefMark {
    LmxRefChunk *chunk;
    size_t used;
    LmxRefFinalizer *finalizers;
    size_t live_finalizers;
} LmxRefMark;

LmxRefStatus lmx_ref_registry_validate(const LmxRefRegistry *registry);
const LmxRefType *lmx_ref_type(const LmxRefRegistry *registry, int code,
                             int *is_uninitialized);
void lmx_ref_arena_init(LmxRefArena *arena, size_t chunk_size);
LmxRefMark lmx_ref_mark(const LmxRefArena *arena);
/* Marks must belong to this arena and be unwound in stack order. */
void lmx_ref_revert(LmxRefArena *arena, LmxRefMark mark);
void lmx_ref_arena_destroy(LmxRefArena *arena);
LmxRefStatus lmx_ref_record_new(LmxRefArena *arena, const LmxRefType *type,
                               int initialized, LmxRefRecord *out);
/* Register only after initializing the payload. Fails before publication. */
LmxRefStatus lmx_ref_record_own(LmxRefArena *arena, const LmxRefType *type,
                               LmxRefRecord record);
/* Primitive-copy hook; caller's ordinary graph source->copy map owns identity.
 * This function never implements a second graph or copies a callable owner. */
LmxRefStatus lmx_ref_record_copy(LmxRefArena *destination,
                                const LmxRefRegistry *registry,
                                LmxRefRecord source, LmxRefRecord *out);

#endif
