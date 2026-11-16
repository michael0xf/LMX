/* rep_cur_chunkhdr.h -- the same untagged typed cells as cur_range, but in 64 KB-aligned chunks whose header holds the
 * element type and stride.  A TRUSTED handle finds its header by masking the address; an ARBITRARY address first goes
 * through the hash set of chunk bases (chunks.h), then the same stride / used checks as cur_range.
 */
#ifndef REP_CUR_CHUNKHDR_H
#define REP_CUR_CHUNKHDR_H

#include "common.h"
#include "chunks.h"

#define REP_NAME "cur_chunkhdr"
#define REP_INTERIOR_ADDR 1 /* type_of_address also answers for content addresses and dense-array elements */

enum { CI_INT, CI_REAL, CI_SIZE, CI_REF, CI_STRUCT, CI_AINT, CI_AREF, CI_UINT, NCPOOLS };

typedef struct Arena {
    ChunkSet cs;
    CPool pool[NCPOOLS];
} Arena;

static inline Arena *arena_new(void)
{
    Arena *a = (Arena *)xcalloc(1, sizeof(Arena));
    static const int types[NCPOOLS] = {T_INT, T_REAL, T_SIZE, T_REF, T_STRUCT, T_ARRAY_INT, T_ARRAY_REF, T_UNINIT_INT};
    const size_t strides[NCPOOLS] = {sizeof(int), sizeof(double), sizeof(size_t), sizeof(void *),
                                     sizeof(struct Lmx), sizeof(struct Lmx), sizeof(struct Lmx), sizeof(void *)};
    int i;
    cs_init(&a->cs);
    for (i = 0; i < NCPOOLS; i++) {
        cpool_init(&a->pool[i], CK_CELLS, types[i], strides[i]);
    }
    return a;
}

static inline void arena_free(Arena *a)
{
    cs_free(&a->cs);
    free(a);
}

static inline void set_straddle(Arena *a, int on)
{
    (void)a;
    (void)on; /* aligned representation: nothing to shift */
}

/* trusted handle: the header is one mask away */
static inline int type_of_ref(Arena *a, void *h)
{
    (void)a;
    return cs_chunk_of(h)->type;
}

/* arbitrary address: hash-set membership, then the issued-cell test */
static inline int type_of_address(Arena *a, const void *p)
{
    Chunk *c;
    size_t off;
    if (p == NULL) {
        return T_NONE;
    }
    c = cs_lookup(&a->cs, p);
    if (c == NULL) {
        return T_NONE;
    }
    off = chunk_offset(c, p);
    if (off == (size_t)-1 || (off % c->stride) != 0) {
        return T_NONE;
    }
    return c->type;
}

static inline int int_get(void *c) { return *(int *)c; }
static inline void int_set(void *c, int v) { *(int *)c = v; }
static inline int *int_addr(void *c) { return (int *)c; }
static inline double real_get(void *c) { return *(double *)c; }
static inline void real_set(void *c, double v) { *(double *)c = v; }
static inline size_t size_get(void *c) { return *(size_t *)c; }
static inline void size_set(void *c, size_t v) { *(size_t *)c = v; }
static inline void *ref_get(void *c) { return *(void **)c; }
static inline void ref_set(void *c, void *v) { *(void **)c = v; }
static inline void *uninit_ref(void *c) { return *(void **)c; } /* @u: the int cell the pointer cell points at */
static inline int uninit_get(void *c) { return **(int **)c; }
static inline void uninit_set(void *c, int v) { **(int **)c = v; }

static inline struct Lmx *lmx_of(void *h) { return (struct Lmx *)h; }
static inline size_t length(void *s) { return lmx_of(s)->length; }
static inline void *lmx_storage(void *s) { return lmx_of(s)->storage; }
static inline void *lmx_key(void *s) { return s; }
static inline void *parent_key(void *s) { return (void *)lmx_of(s)->parent; }
static inline void set_parent_key(void *s, void *key) { lmx_of(s)->parent = (struct Lmx *)key; }
static inline void **slots(void *s) { return (void **)lmx_of(s)->storage; }
static inline int *array_int_data(void *s) { return (int *)lmx_of(s)->storage; }
static inline void **array_ref_data(void *s) { return (void **)lmx_of(s)->storage; }

static inline void *new_int(Arena *a, int v)
{
    int *c = (int *)cpool_take(&a->cs, &a->pool[CI_INT], 1);
    *c = v;
    return c;
}

static inline void *new_real(Arena *a, double v)
{
    double *c = (double *)cpool_take(&a->cs, &a->pool[CI_REAL], 1);
    *c = v;
    return c;
}

static inline void *new_size(Arena *a, size_t v)
{
    size_t *c = (size_t *)cpool_take(&a->cs, &a->pool[CI_SIZE], 1);
    *c = v;
    return c;
}

static inline void *new_uninit_int(Arena *a)
{
    int *ic = (int *)cpool_take(&a->cs, &a->pool[CI_INT], 1);
    void **uc;
    *ic = 0;
    uc = (void **)cpool_take(&a->cs, &a->pool[CI_UINT], 1);
    *uc = ic;
    return uc;
}

static inline void *new_refcell(Arena *a, void *target)
{
    void **c = (void **)cpool_take(&a->cs, &a->pool[CI_REF], 1);
    *c = target;
    return c;
}

static inline void *ch_new_lmx(Arena *a, int pool, size_t n, void *storage, void *parent)
{
    struct Lmx *l = (struct Lmx *)cpool_take(&a->cs, &a->pool[pool], 1);
    l->parent = parent ? lmx_of(parent) : NULL;
    l->length = n;
    l->storage = storage;
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    l->native = NULL;
#endif
    return l;
}

static inline void *new_struct(Arena *a, size_t nslots, void *parent)
{
    void *st = NULL;
    if (nslots > 0) {
        st = cpool_take(&a->cs, &a->pool[CI_REF], nslots);
        memset(st, 0, nslots * sizeof(void *));
    }
    return ch_new_lmx(a, CI_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take(&a->cs, &a->pool[CI_INT], n);
        memset(st, 0, n * sizeof(int));
    }
    return ch_new_lmx(a, CI_AINT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take(&a->cs, &a->pool[CI_REF], n);
        memset(st, 0, n * sizeof(void *));
    }
    return ch_new_lmx(a, CI_AREF, n, st, NULL);
}

static inline void gc_begin(Arena *a) { cs_gc_begin(&a->cs); }
static inline void gc_end(Arena *a) { cs_gc_end(&a->cs); }

static inline int obj_mark(Arena *a, void *h, int *type)
{
    Chunk *c = cs_chunk_of(h);
    size_t idx = (size_t)((char *)h - c->data) / c->stride;
    (void)a;
    *type = c->type;
    return !bit_test_set(c->mark, idx);
}

static inline size_t bytes_live(Arena *a)
{
    return cs_bytes(&a->cs) + sizeof(Arena);
}

static inline void rep_print_layout(void)
{
    PRINT_TYPE(Chunk);
    PRINT_TYPE(Arena);
    printf("  strides: int=%llu double=%llu size_t=%llu ref=%llu Lmx header=%llu uninit pointer cell=%llu\n",
           (unsigned long long)sizeof(int), (unsigned long long)sizeof(double), (unsigned long long)sizeof(size_t),
           (unsigned long long)sizeof(void *), (unsigned long long)sizeof(struct Lmx),
           (unsigned long long)sizeof(void *));
}

#include "graph_algos.h"

#endif /* REP_CUR_CHUNKHDR_H */
