/* rep_tv_full.h -- the reference variant of the author, verbatim: every value is one TypedValue of one size, a slot holds
 * a TypedValue *; a Structure / Array is the struct Lmx stored INSIDE the record's union.  Dense data (slot arrays,
 * Array<int> data, Array-of-handle data) stays dense in raw chunks and is referenced by Lmx.storage.
 */
#ifndef REP_TV_FULL_H
#define REP_TV_FULL_H

#include "common.h"
#include "chunks.h"

#define REP_NAME "tv_full"
#define REP_INTERIOR_ADDR 1 /* type_of_address also answers for content addresses and dense-array elements */

struct TypedValue {
    int type;
    union {
        int integer;
        double real;
        size_t size;
        void *reference;
        struct Lmx structure_or_array;
    } value;
};
typedef struct TypedValue TypedValue;

typedef struct Arena {
    ChunkSet cs;
    CPool rec;
    CPool raw_int;
    CPool raw_ref;
} Arena;

static inline Arena *arena_new(void)
{
    Arena *a = (Arena *)xcalloc(1, sizeof(Arena));
    cs_init(&a->cs);
    cpool_init(&a->rec, CK_RECORDS, 0, sizeof(TypedValue));
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
    return ((const TypedValue *)h)->type;
}

static inline int int_get(void *h) { return ((TypedValue *)h)->value.integer; }
static inline void int_set(void *h, int v) { ((TypedValue *)h)->value.integer = v; }
static inline int *int_addr(void *h) { return &((TypedValue *)h)->value.integer; }
static inline double real_get(void *h) { return ((TypedValue *)h)->value.real; }
static inline void real_set(void *h, double v) { ((TypedValue *)h)->value.real = v; }
static inline size_t size_get(void *h) { return ((TypedValue *)h)->value.size; }
static inline void size_set(void *h, size_t v) { ((TypedValue *)h)->value.size = v; }
static inline void *ref_get(void *h) { return ((TypedValue *)h)->value.reference; }
static inline void ref_set(void *h, void *v) { ((TypedValue *)h)->value.reference = v; }
/* uninit:int as now: the outer record points to its own int record (@u) */
static inline void *uninit_ref(void *h) { return ((TypedValue *)h)->value.reference; }
static inline int uninit_get(void *h) { return int_get(uninit_ref(h)); }
static inline void uninit_set(void *h, int v) { int_set(uninit_ref(h), v); }

static inline struct Lmx *lmx_of(void *h) { return &((TypedValue *)h)->value.structure_or_array; }
static inline size_t length(void *s) { return lmx_of(s)->length; }
static inline void *lmx_storage(void *s) { return lmx_of(s)->storage; }
static inline void *lmx_key(void *s) { return (void *)lmx_of(s); }
static inline void *parent_key(void *s) { return (void *)lmx_of(s)->parent; }
static inline void set_parent_key(void *s, void *key) { lmx_of(s)->parent = (struct Lmx *)key; }
static inline void **slots(void *s) { return (void **)lmx_of(s)->storage; }
static inline int *array_int_data(void *s) { return (int *)lmx_of(s)->storage; }
static inline void **array_ref_data(void *s) { return (void **)lmx_of(s)->storage; }

static inline TypedValue *tf_rec(Arena *a, int tag)
{
    TypedValue *r = (TypedValue *)cpool_take(&a->cs, &a->rec, 1);
    r->type = tag;
    return r;
}

static inline void *new_int(Arena *a, int v)
{
    TypedValue *r = tf_rec(a, T_INT);
    r->value.integer = v;
    return r;
}

static inline void *new_real(Arena *a, double v)
{
    TypedValue *r = tf_rec(a, T_REAL);
    r->value.real = v;
    return r;
}

static inline void *new_size(Arena *a, size_t v)
{
    TypedValue *r = tf_rec(a, T_SIZE);
    r->value.size = v;
    return r;
}

static inline void *new_uninit_int(Arena *a)
{
    TypedValue *inner = tf_rec(a, T_INT);
    TypedValue *r;
    inner->value.integer = 0;
    r = tf_rec(a, T_UNINIT_INT);
    r->value.reference = inner;
    return r;
}

static inline void *new_refcell(Arena *a, void *target)
{
    TypedValue *r = tf_rec(a, T_REF);
    r->value.reference = target;
    return r;
}

static inline void *tf_new_lmx(Arena *a, int tag, size_t n, void *storage, void *parent)
{
    TypedValue *r = tf_rec(a, tag);
    struct Lmx *l = &r->value.structure_or_array;
    l->parent = parent ? lmx_of(parent) : NULL;
    l->length = n;
    l->storage = storage;
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    l->native = NULL;
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
    return tf_new_lmx(a, T_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_int, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(int));
    }
    return tf_new_lmx(a, T_ARRAY_INT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_ref, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(void *));
    }
    return tf_new_lmx(a, T_ARRAY_REF, n, st, NULL);
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
        return tag; /* the record itself, as a slot holds it */
    }
    if (roff == offsetof(TypedValue, value)) {
        return tag; /* the address of the content */
    }
    return T_NONE;
}

static inline void gc_begin(Arena *a) { cs_gc_begin(&a->cs); }
static inline void gc_end(Arena *a) { cs_gc_end(&a->cs); }

static inline int obj_mark(Arena *a, void *h, int *type)
{
    Chunk *c = cs_chunk_of(h);
    size_t idx = (size_t)((char *)h - c->data) / c->stride;
    (void)a;
    *type = *(const int *)h;
    return !bit_test_set(c->mark, idx);
}

static inline size_t bytes_live(Arena *a)
{
    return cs_bytes(&a->cs) + sizeof(Arena);
}

static inline void rep_print_layout(void)
{
    PRINT_TYPE(TypedValue);
    PRINT_OFF(TypedValue, value);
    PRINT_TYPE(Chunk);
    PRINT_TYPE(Arena);
}

#include "graph_algos.h"

#endif /* REP_TV_FULL_H */
