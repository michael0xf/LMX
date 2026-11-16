/* rep_tv_prefix.h -- minimum-size records (as tv_tagged) but a slot holds the address of the CONTENT; the tag lies in the
 * four bytes immediately BEFORE it:
 *
 *   struct PfInt    { int type; int value; }                  slot = &rec->value
 *   struct PfReal   { int reserved; int type; double value; } slot = &rec->value   (also PfSize, PfRef: 16 bytes)
 *   struct PfLmx    { int reserved; int type; struct Lmx lmx; } slot = &rec->lmx   (the handle of a Structure / Array
 *                                                                                  is the address of its struct Lmx)
 *   struct PfUninit { int tag_uninit; int tag_int; int value; } slot = &rec->tag_int (12 bytes, 4-aligned)
 *       the slot's previous four bytes are T_UNINIT_INT, the address of the int cell (= slot + 4) has T_INT before it:
 *       typeof(slot) = uninit:int, typeof(address of its cell) = int, with no stored pointer and no second allocation.
 *
 * The tag is read uniformly as  *(const int *)((const char *)p - sizeof(int)).
 * C99 basis: p points to a member (`value` / `lmx` / `tag_int`) of a struct object; the four bytes before it are the member
 * `type` (`tag_uninit`) of the SAME struct object -- offsetof(...,value) - offsetof(...,type) == sizeof(int) is checked at
 * compile time below.  The access reads that member through a pointer to int, which is its declared type (C99 6.5p7); the
 * address arithmetic is on the character representation of the enclosing struct object (C99 6.3.2.3p7, 6.5.6p8).  Like every
 * container_of idiom this relies on the member -> enclosing object byte layout; no packed attribute, no misaligned access.
 */
#ifndef REP_TV_PREFIX_H
#define REP_TV_PREFIX_H

#include "common.h"
#include "chunks.h"

#define REP_NAME "tv_prefix"
#define REP_INTERIOR_ADDR 1 /* type_of_address also answers for content addresses and dense-array elements */

struct PfInt {
    int type;
    int value;
};
struct PfUninit {
    int tag_uninit;
    int tag_int;
    int value;
};
struct PfReal {
    int reserved;
    int type;
    double value;
};
struct PfSize {
    int reserved;
    int type;
    size_t value;
};
struct PfRef {
    int reserved;
    int type;
    void *value;
};
struct PfLmx {
    int reserved;
    int type;
    struct Lmx lmx;
};

typedef char pf_assert_int[(offsetof(struct PfInt, value) - offsetof(struct PfInt, type) == sizeof(int)) ? 1 : -1];
typedef char pf_assert_uninit1[(offsetof(struct PfUninit, tag_int) - offsetof(struct PfUninit, tag_uninit) == sizeof(int)) ? 1 : -1];
typedef char pf_assert_uninit2[(offsetof(struct PfUninit, value) - offsetof(struct PfUninit, tag_int) == sizeof(int)) ? 1 : -1];
typedef char pf_assert_real[(offsetof(struct PfReal, value) - offsetof(struct PfReal, type) == sizeof(int)) ? 1 : -1];
typedef char pf_assert_size[(offsetof(struct PfSize, value) - offsetof(struct PfSize, type) == sizeof(int)) ? 1 : -1];
typedef char pf_assert_ref[(offsetof(struct PfRef, value) - offsetof(struct PfRef, type) == sizeof(int)) ? 1 : -1];
typedef char pf_assert_lmx[(offsetof(struct PfLmx, lmx) - offsetof(struct PfLmx, type) == sizeof(int)) ? 1 : -1];
typedef char pf_assert_class16[(sizeof(struct PfReal) == 16 && sizeof(struct PfSize) == 16 && sizeof(struct PfRef) == 16) ? 1 : -1];
typedef char pf_assert_distinct[(sizeof(struct PfInt) == 8 && sizeof(struct PfUninit) == 12 && sizeof(struct PfLmx) > 16) ? 1 : -1];

typedef struct Arena {
    ChunkSet cs;
    CPool c8;       /* PfInt */
    CPool c12;      /* PfUninit */
    CPool c16;      /* PfReal, PfSize, PfRef */
    CPool cl;       /* PfLmx */
    CPool raw_int;
    CPool raw_ref;
} Arena;

static inline Arena *arena_new(void)
{
    Arena *a = (Arena *)xcalloc(1, sizeof(Arena));
    cs_init(&a->cs);
    cpool_init(&a->c8, CK_RECORDS, 0, sizeof(struct PfInt));
    cpool_init(&a->c12, CK_RECORDS, 0, sizeof(struct PfUninit));
    cpool_init(&a->c16, CK_RECORDS, 0, sizeof(struct PfReal));
    cpool_init(&a->cl, CK_RECORDS, 0, sizeof(struct PfLmx));
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

/* the tag of any value: the int that precedes its address */
static inline int pf_tag(const void *p)
{
    return *(const int *)((const char *)p - sizeof(int));
}

static inline int type_of_ref(Arena *a, void *h)
{
    (void)a;
    return pf_tag(h);
}

static inline int int_get(void *h) { return *(const int *)h; }
static inline void int_set(void *h, int v) { *(int *)h = v; }
static inline int *int_addr(void *h) { return (int *)h; }
static inline double real_get(void *h) { return *(const double *)h; }
static inline void real_set(void *h, double v) { *(double *)h = v; }
static inline size_t size_get(void *h) { return *(const size_t *)h; }
static inline void size_set(void *h, size_t v) { *(size_t *)h = v; }
static inline void *ref_get(void *h) { return *(void *const *)h; }
static inline void ref_set(void *h, void *v) { *(void **)h = v; }

static inline struct PfUninit *pf_uninit(void *h)
{
    return (struct PfUninit *)((char *)h - offsetof(struct PfUninit, tag_int));
}
static inline void *uninit_ref(void *h) { return (void *)&pf_uninit(h)->value; } /* @u = slot + 4; tag_int precedes it */
static inline int uninit_get(void *h) { return pf_uninit(h)->value; }
static inline void uninit_set(void *h, int v) { pf_uninit(h)->value = v; }

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
    struct PfInt *r = (struct PfInt *)cpool_take(&a->cs, &a->c8, 1);
    r->type = T_INT;
    r->value = v;
    return &r->value;
}

static inline void *new_real(Arena *a, double v)
{
    struct PfReal *r = (struct PfReal *)cpool_take(&a->cs, &a->c16, 1);
    r->reserved = 0;
    r->type = T_REAL;
    r->value = v;
    return &r->value;
}

static inline void *new_size(Arena *a, size_t v)
{
    struct PfSize *r = (struct PfSize *)cpool_take(&a->cs, &a->c16, 1);
    r->reserved = 0;
    r->type = T_SIZE;
    r->value = v;
    return &r->value;
}

static inline void *new_uninit_int(Arena *a)
{
    struct PfUninit *r = (struct PfUninit *)cpool_take(&a->cs, &a->c12, 1);
    r->tag_uninit = T_UNINIT_INT;
    r->tag_int = T_INT;
    r->value = 0;
    return &r->tag_int;
}

static inline void *new_refcell(Arena *a, void *target)
{
    struct PfRef *r = (struct PfRef *)cpool_take(&a->cs, &a->c16, 1);
    r->reserved = 0;
    r->type = T_REF;
    r->value = target;
    return &r->value;
}

static inline void *pf_new_lmx(Arena *a, int tag, size_t n, void *storage, void *parent)
{
    struct PfLmx *r = (struct PfLmx *)cpool_take(&a->cs, &a->cl, 1);
    r->reserved = 0;
    r->type = tag;
    r->lmx.parent = parent ? lmx_of(parent) : NULL;
    r->lmx.length = n;
    r->lmx.storage = storage;
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    r->lmx.native = NULL;
#endif
    return &r->lmx;
}

static inline void *new_struct(Arena *a, size_t nslots, void *parent)
{
    void *st = NULL;
    if (nslots > 0) {
        st = cpool_take_al(&a->cs, &a->raw_ref, nslots, TV_RAW_ALIGN);
        memset(st, 0, nslots * sizeof(void *));
    }
    return pf_new_lmx(a, T_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_int, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(int));
    }
    return pf_new_lmx(a, T_ARRAY_INT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_ref, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(void *));
    }
    return pf_new_lmx(a, T_ARRAY_REF, n, st, NULL);
}

/* the offsets inside a record of this class at which a value address (a slot / a content address) may stand */
static inline int pf_valid_offset(size_t stride, size_t roff)
{
    if (stride == sizeof(struct PfInt)) {
        return roff == offsetof(struct PfInt, value);
    }
    if (stride == sizeof(struct PfUninit)) {
        return roff == offsetof(struct PfUninit, tag_int) || roff == offsetof(struct PfUninit, value);
    }
    if (stride == sizeof(struct PfReal)) {
        return roff == offsetof(struct PfReal, value);
    }
    return roff == offsetof(struct PfLmx, lmx);
}

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
    if (off == (size_t)-1) {
        return T_NONE;
    }
    if (c->kind == CK_RAW) {
        return (off % c->stride) ? T_NONE : c->type;
    }
    if (!pf_valid_offset(c->stride, off % c->stride)) {
        return T_NONE;
    }
    return pf_tag(p);
}

static inline void gc_begin(Arena *a) { cs_gc_begin(&a->cs); }
static inline void gc_end(Arena *a) { cs_gc_end(&a->cs); }

static inline int obj_mark(Arena *a, void *h, int *type)
{
    Chunk *c = cs_chunk_of(h);
    size_t idx = (size_t)((char *)h - c->data) / c->stride;
    (void)a;
    *type = pf_tag(h);
    return !bit_test_set(c->mark, idx);
}

static inline size_t bytes_live(Arena *a)
{
    return cs_bytes(&a->cs) + sizeof(Arena);
}

static inline void rep_print_layout(void)
{
    PRINT_TYPE(struct PfInt);
    PRINT_OFF(struct PfInt, value);
    PRINT_TYPE(struct PfUninit);
    PRINT_OFF(struct PfUninit, tag_int);
    PRINT_OFF(struct PfUninit, value);
    PRINT_TYPE(struct PfReal);
    PRINT_OFF(struct PfReal, value);
    PRINT_TYPE(struct PfSize);
    PRINT_TYPE(struct PfRef);
    PRINT_TYPE(struct PfLmx);
    PRINT_OFF(struct PfLmx, lmx);
    PRINT_TYPE(Chunk);
    PRINT_TYPE(Arena);
}

#include "graph_algos.h"

#endif /* REP_TV_PREFIX_H */
