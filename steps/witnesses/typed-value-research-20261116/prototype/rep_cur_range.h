/* rep_cur_range.h -- the current layout at its best: untagged cells in dense typed pools; the type of an address is
 * found in ONE pass: binary search of the sorted range table {lo, hi, pool} (24 bytes per entry), then pool->type and
 * the check that the address starts an issued cell: (address - lo) % stride == 0 and address < hi (hi = lo + used cells).
 *
 * Pools: int (stride 4), double, size_t, reference cell (8, also slot arrays and Array-of-handle data), Structure
 * header (sizeof Lmx), Array<int> header, Array-of-handle header, uninit:int pointer cell (8).  Dense Array<int> data is a
 * run of cells of the int pool.  Chunks grow geometrically (4 KB doubling to 2 MB); a run longer than 2 MB gets its own
 * range.  uninit:int is the pointer cell of pool UNINIT_INT pointing to its own int cell of the int pool.
 * A handle is the address of the cell (of the header for Structure / Array).
 */
#ifndef REP_CUR_RANGE_H
#define REP_CUR_RANGE_H

#include "common.h"

#define REP_NAME "cur_range"
#define REP_INTERIOR_ADDR 1 /* type_of_address also answers for content addresses and dense-array elements */
#define RANGE_FIRST_BYTES ((size_t)4096)
#define RANGE_MAX_BYTES ((size_t)1 << 21)

enum { PI_INT, PI_REAL, PI_SIZE, PI_REF, PI_STRUCT, PI_AINT, PI_AREF, PI_UINT, NPOOLS };

typedef struct Pool {
    int type;
    size_t stride;
    char *top;         /* next free cell of the current chunk */
    char *limit;       /* end of the current chunk */
    size_t idx;        /* index of the current chunk's entry in the range table */
    size_t next_bytes; /* size of the next chunk */
    int has_chunk;
} Pool;

typedef struct Range {
    char *lo;
    char *hi; /* lo + issued cells * stride */
    Pool *pool;
} Range;

typedef struct Arena {
    Range *r;
    size_t n;
    size_t cap;
    uint64_t **bm; /* per range entry, only while gc_mark runs */
    Pool pool[NPOOLS];
} Arena;

static inline Arena *arena_new(void)
{
    Arena *a = (Arena *)xcalloc(1, sizeof(Arena));
    static const int types[NPOOLS] = {T_INT, T_REAL, T_SIZE, T_REF, T_STRUCT, T_ARRAY_INT, T_ARRAY_REF, T_UNINIT_INT};
    const size_t strides[NPOOLS] = {sizeof(int), sizeof(double), sizeof(size_t), sizeof(void *),
                                    sizeof(struct Lmx), sizeof(struct Lmx), sizeof(struct Lmx), sizeof(void *)};
    int i;
    for (i = 0; i < NPOOLS; i++) {
        a->pool[i].type = types[i];
        a->pool[i].stride = strides[i];
        a->pool[i].next_bytes = RANGE_FIRST_BYTES;
    }
    return a;
}

static inline void arena_free(Arena *a)
{
    size_t i;
    for (i = 0; i < a->n; i++) {
        free(a->r[i].lo);
    }
    free(a->r);
    free(a);
}

static inline void set_straddle(Arena *a, int on)
{
    (void)a;
    (void)on; /* aligned representation: nothing to shift */
}

/* ---- the range table: sorted by lo; a new chunk is inserted in place ---- */
static inline size_t range_insert(Arena *a, char *lo, char *hi, Pool *pool)
{
    size_t l = 0;
    size_t h = a->n;
    int i;
    while (l < h) {
        size_t m = (l + h) >> 1;
        if ((uintptr_t)a->r[m].lo < (uintptr_t)lo) {
            l = m + 1;
        } else {
            h = m;
        }
    }
    if (a->n == a->cap) {
        a->cap = a->cap ? a->cap * 2 : 16;
        a->r = (Range *)xrealloc(a->r, a->cap * sizeof(Range));
    }
    memmove(&a->r[l + 1], &a->r[l], (a->n - l) * sizeof(Range));
    a->r[l].lo = lo;
    a->r[l].hi = hi;
    a->r[l].pool = pool;
    a->n++;
    for (i = 0; i < NPOOLS; i++) {
        if (a->pool[i].has_chunk && a->pool[i].idx >= l) {
            a->pool[i].idx++;
        }
    }
    return l;
}

static inline void *pool_slow(Arena *a, Pool *p, size_t need)
{
    size_t sz;
    char *m;
    char *cell;
    size_t idx;
    if (need > RANGE_MAX_BYTES) { /* a dedicated range for one long dense run */
        m = (char *)xmalloc(need);
        range_insert(a, m, m + need, p);
        return m;
    }
    sz = p->next_bytes;
    if (sz < need) {
        sz = need;
    }
    sz = (sz / p->stride) * p->stride;
    if (p->next_bytes < RANGE_MAX_BYTES) {
        p->next_bytes *= 2;
    }
    m = (char *)xmalloc(sz);
    idx = range_insert(a, m, m, p);
    p->idx = idx;
    p->has_chunk = 1;
    p->top = m;
    p->limit = m + sz;
    cell = p->top;
    p->top += need;
    a->r[idx].hi = p->top;
    return cell;
}

static inline void *pool_take(Arena *a, Pool *p, size_t count)
{
    size_t need = count * p->stride;
    char *cell;
    if (!p->has_chunk || (size_t)(p->limit - p->top) < need) {
        return pool_slow(a, p, need);
    }
    cell = p->top;
    p->top += need;
    a->r[p->idx].hi = p->top;
    return cell;
}

/* index of the range entry containing the address, or (size_t)-1 */
static inline size_t range_find(const Arena *a, const void *p)
{
    uintptr_t u = (uintptr_t)p;
    size_t l = 0;
    size_t h = a->n;
    while (l < h) {
        size_t m = (l + h) >> 1;
        if ((uintptr_t)a->r[m].lo <= u) {
            l = m + 1;
        } else {
            h = m;
        }
    }
    if (l == 0 || u >= (uintptr_t)a->r[l - 1].hi) {
        return (size_t)-1;
    }
    return l - 1;
}

/* ---- the one-pass address -> type ---- */
static inline int type_of_address(Arena *a, const void *p)
{
    size_t i;
    const Range *e;
    if (p == NULL) {
        return T_NONE;
    }
    i = range_find(a, p);
    if (i == (size_t)-1) {
        return T_NONE;
    }
    e = &a->r[i];
    if ((size_t)((uintptr_t)p - (uintptr_t)e->lo) % e->pool->stride) {
        return T_NONE;
    }
    return e->pool->type;
}

static inline int type_of_ref(Arena *a, void *h)
{
    return type_of_address(a, h); /* no trusted shortcut: the cell has no tag */
}

/* ---- access ---- */
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

/* ---- constructors ---- */
static inline void *new_int(Arena *a, int v)
{
    int *c = (int *)pool_take(a, &a->pool[PI_INT], 1);
    *c = v;
    return c;
}

static inline void *new_real(Arena *a, double v)
{
    double *c = (double *)pool_take(a, &a->pool[PI_REAL], 1);
    *c = v;
    return c;
}

static inline void *new_size(Arena *a, size_t v)
{
    size_t *c = (size_t *)pool_take(a, &a->pool[PI_SIZE], 1);
    *c = v;
    return c;
}

static inline void *new_uninit_int(Arena *a)
{
    int *ic = (int *)pool_take(a, &a->pool[PI_INT], 1);
    void **uc;
    *ic = 0;
    uc = (void **)pool_take(a, &a->pool[PI_UINT], 1);
    *uc = ic;
    return uc;
}

static inline void *new_refcell(Arena *a, void *target)
{
    void **c = (void **)pool_take(a, &a->pool[PI_REF], 1);
    *c = target;
    return c;
}

static inline void *cr_new_lmx(Arena *a, int pool, size_t n, void *storage, void *parent)
{
    struct Lmx *l = (struct Lmx *)pool_take(a, &a->pool[pool], 1);
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
        st = pool_take(a, &a->pool[PI_REF], nslots);
        memset(st, 0, nslots * sizeof(void *));
    }
    return cr_new_lmx(a, PI_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = pool_take(a, &a->pool[PI_INT], n);
        memset(st, 0, n * sizeof(int));
    }
    return cr_new_lmx(a, PI_AINT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = pool_take(a, &a->pool[PI_REF], n);
        memset(st, 0, n * sizeof(void *));
    }
    return cr_new_lmx(a, PI_AREF, n, st, NULL);
}

/* ---- gc support: bitmaps parallel to the range table ---- */
static inline void gc_begin(Arena *a)
{
    size_t i;
    a->bm = (uint64_t **)xcalloc(a->n ? a->n : 1, sizeof(uint64_t *));
    for (i = 0; i < a->n; i++) {
        size_t cells = (size_t)(a->r[i].hi - a->r[i].lo) / a->r[i].pool->stride;
        a->bm[i] = (uint64_t *)xcalloc(cells / 64 + 1, sizeof(uint64_t));
    }
}

static inline void gc_end(Arena *a)
{
    size_t i;
    for (i = 0; i < a->n; i++) {
        free(a->bm[i]);
    }
    free(a->bm);
    a->bm = NULL;
}

static inline int obj_mark(Arena *a, void *h, int *type)
{
    size_t i = range_find(a, h);
    const Range *e;
    if (i == (size_t)-1) {
        fprintf(stderr, "obj_mark: address outside the arena\n");
        abort();
    }
    e = &a->r[i];
    *type = e->pool->type;
    return !bit_test_set(a->bm[i], (size_t)((uintptr_t)h - (uintptr_t)e->lo) / e->pool->stride);
}

static inline size_t bytes_live(Arena *a)
{
    size_t i;
    size_t total = sizeof(Arena) + a->cap * sizeof(Range);
    for (i = 0; i < a->n; i++) {
        total += (size_t)(a->r[i].hi - a->r[i].lo);
    }
    return total;
}

static inline void rep_print_layout(void)
{
    PRINT_TYPE(Range);
    PRINT_TYPE(Pool);
    PRINT_TYPE(Arena);
    printf("  strides: int=%llu double=%llu size_t=%llu ref=%llu Lmx header=%llu uninit pointer cell=%llu\n",
           (unsigned long long)sizeof(int), (unsigned long long)sizeof(double), (unsigned long long)sizeof(size_t),
           (unsigned long long)sizeof(void *), (unsigned long long)sizeof(struct Lmx),
           (unsigned long long)sizeof(void *));
}

#include "graph_algos.h"

#endif /* REP_CUR_RANGE_H */
