/* rep_tv_tagged.h -- tag and typed content in ONE allocation, size by content, pools by size class (8 / 16 / 32|40).
 *
 *   struct TvInt  { int type; int value; }                 (8)   also uninit:int, tag T_UNINIT_INT, tag never changes
 *   struct TvReal { int type; double value; }              (16)
 *   struct TvSize { int type; size_t value; }              (16)
 *   struct TvRef  { int type; void *value; }               (16)
 *   struct TvLmx  { int type; struct Lmx lmx; }            (32; 40 with -DLMX_NATIVE_WORD=1)
 *
 * A slot holds the address of the record start; the tag is read as *(const int *)rec (C99 6.7.2.1p13: a pointer to a
 * structure, suitably converted, points to its first member; `type` is the first member of every record struct).
 */
#ifndef REP_TV_TAGGED_H
#define REP_TV_TAGGED_H

#include "common.h"
#include "chunks.h"

#define REP_NAME "tv_tagged"
#define REP_INTERIOR_ADDR 1 /* type_of_address also answers for content addresses and dense-array elements */

struct TvInt {
    int type;
    int value;
};
struct TvReal {
    int type;
    double value;
};
struct TvSize {
    int type;
    size_t value;
};
struct TvRef {
    int type;
    void *value;
};
struct TvLmx {
    int type;
    struct Lmx lmx;
};

struct TvUninit { /* uninit:int, one allocation: the nested record is a TvInt at offset 4 (tag T_INT | T_EMBEDDED) */
    int type;
    struct TvInt inner;
};

typedef char tg_assert_uninit12[(sizeof(struct TvUninit) == 12 && offsetof(struct TvUninit, inner) == 4) ? 1 : -1];
typedef char tg_assert_class16[(sizeof(struct TvReal) == 16 && sizeof(struct TvSize) == 16 && sizeof(struct TvRef) == 16) ? 1 : -1];

typedef struct Arena {
    ChunkSet cs;
    CPool c8;        /* TvInt */
    CPool c16;       /* TvReal, TvSize, TvRef */
    CPool cl;        /* TvLmx */
    CPool raw_int;   /* dense Array<int> data */
    CPool raw_ref;   /* slot arrays and Array-of-handle data */
} Arena;

static inline Arena *arena_new(void)
{
    Arena *a = (Arena *)xcalloc(1, sizeof(Arena));
    cs_init(&a->cs);
    cpool_init(&a->c8, CK_RECORDS, 0, sizeof(struct TvInt));
    cpool_init(&a->c16, CK_RECORDS, 0, sizeof(struct TvReal));
    cpool_init(&a->cl, CK_RECORDS, 0, sizeof(struct TvLmx));
    cpool_init(&a->raw_int, CK_RAW, T_INT, sizeof(int));
    cpool_init(&a->raw_ref, CK_RAW, T_REF, sizeof(void *));
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

static inline int type_of_ref(Arena *a, void *h)
{
    (void)a;
    return *(const int *)h & TAG_MASK; /* T_EMBEDDED masked out */
}

static inline int int_get(void *h) { return ((struct TvInt *)h)->value; }
static inline void int_set(void *h, int v) { ((struct TvInt *)h)->value = v; }
static inline int *int_addr(void *h) { return &((struct TvInt *)h)->value; }
static inline double real_get(void *h) { return ((struct TvReal *)h)->value; }
static inline void real_set(void *h, double v) { ((struct TvReal *)h)->value = v; }
static inline size_t size_get(void *h) { return ((struct TvSize *)h)->value; }
static inline void size_set(void *h, size_t v) { ((struct TvSize *)h)->value = v; }
static inline void *ref_get(void *h) { return ((struct TvRef *)h)->value; }
static inline void ref_set(void *h, void *v) { ((struct TvRef *)h)->value = v; }
static inline void *uninit_ref(void *h) { return &((struct TvUninit *)h)->inner; } /* @u = outer + 4, a nested TvInt record */
static inline int uninit_get(void *h) { return ((struct TvUninit *)h)->inner.value; }
static inline void uninit_set(void *h, int v) { ((struct TvUninit *)h)->inner.value = v; }

static inline struct Lmx *lmx_of(void *h) { return &((struct TvLmx *)h)->lmx; }
static inline size_t length(void *s) { return lmx_of(s)->length; }
static inline void *lmx_storage(void *s) { return lmx_of(s)->storage; }
static inline void *lmx_key(void *s) { return (void *)lmx_of(s); }
static inline void *parent_key(void *s) { return (void *)lmx_of(s)->parent; }
static inline void set_parent_key(void *s, void *key) { lmx_of(s)->parent = (struct Lmx *)key; }
static inline void **slots(void *s) { return (void **)lmx_of(s)->storage; }
static inline int *array_int_data(void *s) { return (int *)lmx_of(s)->storage; }
static inline void **array_ref_data(void *s) { return (void **)lmx_of(s)->storage; }

static inline void *new_int(Arena *a, int v)
{
    struct TvInt *r = (struct TvInt *)cpool_take(&a->cs, &a->c8, 1);
    r->type = T_INT;
    r->value = v;
    return r;
}

static inline void *new_real(Arena *a, double v)
{
    struct TvReal *r = (struct TvReal *)cpool_take(&a->cs, &a->c16, 1);
    r->type = T_REAL;
    r->value = v;
    return r;
}

static inline void *new_size(Arena *a, size_t v)
{
    struct TvSize *r = (struct TvSize *)cpool_take(&a->cs, &a->c16, 1);
    r->type = T_SIZE;
    r->value = v;
    return r;
}

/* nested form (the protocol): 12 bytes in the 16-byte class; typeof(slot) = uninit:int, typeof(@u) = int */
static inline void *new_uninit_int(Arena *a)
{
    struct TvUninit *r = (struct TvUninit *)cpool_take(&a->cs, &a->c16, 1);
    r->type = T_UNINIT_INT;
    r->inner.type = T_INT | T_EMBEDDED;
    r->inner.value = 0;
    return r;
}

/* flat form for the sizes table only: one TvInt {T_UNINIT_INT; int}; typeof(@u) would be uninit:int, so it fails the protocol */
static inline void *new_uninit_int_flat(Arena *a)
{
    struct TvInt *r = (struct TvInt *)cpool_take(&a->cs, &a->c8, 1);
    r->type = T_UNINIT_INT;
    r->value = 0;
    return r;
}
#define REP_HAS_FLAT_UNINIT 1

static inline void *new_refcell(Arena *a, void *target)
{
    struct TvRef *r = (struct TvRef *)cpool_take(&a->cs, &a->c16, 1);
    r->type = T_REF;
    r->value = target;
    return r;
}

static inline void *tg_new_lmx(Arena *a, int tag, size_t n, void *storage, void *parent)
{
    struct TvLmx *r = (struct TvLmx *)cpool_take(&a->cs, &a->cl, 1);
    r->type = tag;
    r->lmx.parent = parent ? lmx_of(parent) : NULL;
    r->lmx.length = n;
    r->lmx.storage = storage;
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    r->lmx.native = NULL;
#endif
    return r;
}

static inline void *new_struct(Arena *a, size_t nslots, void *parent)
{
    void *st = NULL;
    if (nslots > 0) {
        st = cpool_take_al(&a->cs, &a->raw_ref, nslots, TV_RAW_ALIGN);
        memset(st, 0, nslots * sizeof(void *));
    }
    return tg_new_lmx(a, T_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_int, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(int));
    }
    return tg_new_lmx(a, T_ARRAY_INT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_ref, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(void *));
    }
    return tg_new_lmx(a, T_ARRAY_REF, n, st, NULL);
}

/* offset of the content inside a record of this tag */
static inline size_t tg_content_off(int tag)
{
    return (tag == T_INT || tag == T_UNINIT_INT) ? offsetof(struct TvInt, value) : offsetof(struct TvReal, value);
}

static inline int type_of_address(Arena *a, const void *p)
{
    Chunk *c;
    size_t off;
    size_t roff;
    int tag;
    if (p == NULL) {
        return T_NONE;
    }
    c = cs_lookup(&a->cs, p);
    if (c == NULL) {
        return T_NONE;
    }
    off = chunk_offset(c, p);
    if (off == (size_t)-1) {
        return T_NONE;
    }
    if (c->kind == CK_RAW) {
        return (off % c->stride) ? T_NONE : c->type;
    }
    roff = off % c->stride;
    tag = *(const int *)(c->data + (off - roff));
    if (roff == 0) {
        return tag & TAG_MASK; /* the record itself, as a slot holds it */
    }
    if (tag == T_UNINIT_INT) {
        return (roff == offsetof(struct TvUninit, inner) || roff == offsetof(struct TvUninit, inner.value)) ? T_INT : T_NONE;
    }
    if (roff == tg_content_off(tag)) {
        return tag; /* the address of the content */
    }
    return T_NONE;
}

static inline void gc_begin(Arena *a) { cs_gc_begin(&a->cs); }
static inline void gc_end(Arena *a) { cs_gc_end(&a->cs); }

static inline int obj_mark(Arena *a, void *h, int *type)
{
    Chunk *c = cs_chunk_of(h);
    int tag = *(const int *)h;
    size_t idx;
    (void)a;
    if (tag & T_EMBEDDED) { /* @u: the allocation starts 4 bytes earlier */
        h = (char *)h - 4;
    }
    idx = (size_t)((char *)h - c->data) / c->stride;
    *type = tag & TAG_MASK;
    return !bit_test_set(c->mark, idx);
}

static inline size_t bytes_live(Arena *a)
{
    return cs_bytes(&a->cs) + sizeof(Arena);
}

static inline void rep_print_layout(void)
{
    PRINT_TYPE(struct TvInt);
    PRINT_OFF(struct TvInt, value);
    PRINT_TYPE(struct TvReal);
    PRINT_OFF(struct TvReal, value);
    PRINT_TYPE(struct TvSize);
    PRINT_TYPE(struct TvRef);
    PRINT_TYPE(struct TvLmx);
    PRINT_OFF(struct TvLmx, lmx);
    PRINT_TYPE(Chunk);
    PRINT_TYPE(Arena);
}

#include "graph_algos.h"

#endif /* REP_TV_TAGGED_H */
