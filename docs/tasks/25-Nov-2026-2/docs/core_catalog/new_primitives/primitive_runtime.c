#include "primitive_runtime.h"
#include <stdlib.h>
#include <string.h>
#include <limits.h>

typedef char LmxRefCodeMustBeFourBytes[(sizeof(int) == 4) ? 1 : -1];

struct LmxRefChunk {
    LmxRefChunk *previous;
    unsigned char *bytes;
    size_t used;
    size_t capacity;
};

struct LmxRefFinalizer {
    LmxRefFinalizer *previous;
    void *payload;
    LmxRefDrop drop;
};

static int lmx_ref_power_of_two(size_t value)
{
    return value && !(value & (value - 1));
}

LmxRefStatus lmx_ref_registry_validate(const LmxRefRegistry *registry)
{
    size_t i, j;
    if (!registry || (registry->count && !registry->rows))
        return LMX_REF_ARGUMENT;
    for (i = 0; i < registry->count; ++i) {
        const LmxRefType *row = &registry->rows[i];
        if (!row->name || !row->size || row->code <= 0 ||
            row->uninit_code <= 0 || row->code == row->uninit_code ||
            !lmx_ref_power_of_two(row->alignment) || !row->clone)
            return LMX_REF_TYPE;
        for (j = 0; j < i; ++j) {
            const LmxRefType *other = &registry->rows[j];
            if (row->code == other->code || row->code == other->uninit_code ||
                row->uninit_code == other->code ||
                row->uninit_code == other->uninit_code ||
                !strcmp(row->name, other->name))
                return LMX_REF_TYPE;
        }
    }
    return LMX_REF_OK;
}

const LmxRefType *lmx_ref_type(const LmxRefRegistry *registry, int code,
                             int *is_uninitialized)
{
    size_t i;
    if (!registry || !is_uninitialized) return NULL;
    for (i = 0; i < registry->count; ++i) {
        const LmxRefType *row = &registry->rows[i];
        if (code == row->code || code == row->uninit_code) {
            *is_uninitialized = code == row->uninit_code;
            return row;
        }
    }
    return NULL;
}

void lmx_ref_arena_init(LmxRefArena *arena, size_t chunk_size)
{
    arena->chunk = NULL;
    arena->finalizers = NULL;
    arena->chunk_size = chunk_size ? chunk_size : 4096;
    arena->live_finalizers = 0;
}

LmxRefMark lmx_ref_mark(const LmxRefArena *arena)
{
    LmxRefMark result;
    result.chunk = arena->chunk;
    result.used = arena->chunk ? arena->chunk->used : 0;
    result.finalizers = arena->finalizers;
    result.live_finalizers = arena->live_finalizers;
    return result;
}

void lmx_ref_revert(LmxRefArena *arena, LmxRefMark mark)
{
    while (arena->finalizers != mark.finalizers) {
        LmxRefFinalizer *item = arena->finalizers;
        arena->finalizers = item->previous;
        item->drop(item->payload);
        free(item);
    }
    arena->live_finalizers = mark.live_finalizers;
    while (arena->chunk != mark.chunk) {
        LmxRefChunk *chunk = arena->chunk;
        arena->chunk = chunk->previous;
        free(chunk->bytes);
        free(chunk);
    }
    if (arena->chunk) arena->chunk->used = mark.used;
}

void lmx_ref_arena_destroy(LmxRefArena *arena)
{
    LmxRefMark empty = { NULL, 0, NULL, 0 };
    lmx_ref_revert(arena, empty);
}

static LmxRefStatus lmx_ref_chunk_new(LmxRefArena *arena, size_t need)
{
    LmxRefChunk *chunk = (LmxRefChunk *)malloc(sizeof *chunk);
    if (!chunk) return LMX_REF_ALLOCATION;
    chunk->capacity = need > arena->chunk_size ? need : arena->chunk_size;
    chunk->bytes = (unsigned char *)malloc(chunk->capacity);
    if (!chunk->bytes) { free(chunk); return LMX_REF_ALLOCATION; }
    chunk->used = 0;
    chunk->previous = arena->chunk;
    arena->chunk = chunk;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_record_new(LmxRefArena *arena, const LmxRefType *type,
                               int initialized, LmxRefRecord *out)
{
    size_t alignment, payload_size, need, padding, start, end;
    uintptr_t candidate;
    LmxRefStatus status;
    LmxRefChunk *chunk;
    if (!arena || !type || !out || (initialized != 0 && initialized != 1))
        return LMX_REF_ARGUMENT;
    alignment = initialized ? type->alignment : 4;
    if (alignment < 4) alignment = 4;
    if (!lmx_ref_power_of_two(alignment)) return LMX_REF_TYPE;
    payload_size = initialized ? type->size : 0;
    if (payload_size > SIZE_MAX - 4 ||
        payload_size + 4 > SIZE_MAX - (alignment - 1)) return LMX_REF_RANGE;
    need = payload_size + 4 + alignment - 1;
    chunk = arena->chunk;
    if (!chunk || need > chunk->capacity - chunk->used) {
        status = lmx_ref_chunk_new(arena, need);
        if (status != LMX_REF_OK) return status;
        chunk = arena->chunk;
    }
    /* We align using the actual address, so malloc base and chunk boundaries
     * need no extra promise. No payload reads use memcpy or unaligned casts. */
    candidate = (uintptr_t)(chunk->bytes + chunk->used + 4);
    padding = (size_t)((alignment - (candidate & (alignment - 1))) &
                       (alignment - 1));
    start = chunk->used + padding;
    end = start + 4 + payload_size;
    out->code = (int *)(void *)(chunk->bytes + start);
    *out->code = initialized ? type->code : type->uninit_code;
    out->value = initialized ? (void *)(chunk->bytes + start + 4) : NULL;
    chunk->used = end;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_record_own(LmxRefArena *arena, const LmxRefType *type,
                               LmxRefRecord record)
{
    LmxRefFinalizer *item;
    if (!arena || !type || !record.code || *record.code != type->code ||
        !record.value) return LMX_REF_ARGUMENT;
    if (!type->drop) return LMX_REF_OK;
    if (arena->live_finalizers == SIZE_MAX) return LMX_REF_RANGE;
    item = (LmxRefFinalizer *)malloc(sizeof *item);
    if (!item) return LMX_REF_ALLOCATION;
    item->previous = arena->finalizers;
    item->payload = record.value;
    item->drop = type->drop;
    arena->finalizers = item;
    ++arena->live_finalizers;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_record_copy(LmxRefArena *destination,
                                const LmxRefRegistry *registry,
                                LmxRefRecord source, LmxRefRecord *out)
{
    int uninitialized;
    const LmxRefType *type;
    LmxRefStatus status;
    LmxRefMark mark;
    LmxRefRecord record;
    if (!destination || !registry || !source.code || !out)
        return LMX_REF_ARGUMENT;
    type = lmx_ref_type(registry, *source.code, &uninitialized);
    if (!type) return LMX_REF_TYPE;
    if ((uninitialized && source.value) || (!uninitialized && !source.value))
        return LMX_REF_TYPE;
    mark = lmx_ref_mark(destination);
    status = lmx_ref_record_new(destination, type, !uninitialized, &record);
    if (status != LMX_REF_OK) return status;
    if (uninitialized) { *out = record; return LMX_REF_OK; }
    status = type->clone(record.value, source.value, type->context);
    if (status != LMX_REF_OK) {
        /* A failing clone cleans up any private partial allocation itself. */
        lmx_ref_revert(destination, mark);
        return status;
    }
    status = lmx_ref_record_own(destination, type, record);
    if (status != LMX_REF_OK) {
        if (type->drop) type->drop(record.value);
        lmx_ref_revert(destination, mark);
        return status;
    }
    *out = record;
    return LMX_REF_OK;
}
