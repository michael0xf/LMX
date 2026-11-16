/* rep_tv_packed.h -- the author's scheme: a record is a 4-byte tag followed IMMEDIATELY by the value of its own size,
 * with no alignment and no padding; records are issued one after another (bump) from the arena's chunks.
 *
 *   int                  8 bytes   [tag][int]
 *   uninit:int          12 bytes   [UNINIT_INT][INT|EMBEDDED][int]   (nested record; the flat form {UNINIT_INT; int} is 8, sizes only)
 *   double, size_t, ref 12 bytes   [tag][8 bytes]      (the 8-byte content sits at record + 4: often unaligned)
 *   Lmx descriptor      28 bytes   [tag][parent|length|storage]   (36 with -DLMX_NATIVE_WORD=1)
 *
 * A slot (handle) holds the address of the record start (its tag).  Every record size is a multiple of 4, so the tag is
 * always 4-aligned.  Access without undefined behaviour and without packed attributes:
 *   tag                *(const int *)rec                         (a 4-aligned int, written as an int)
 *   4-byte content     *(const int *)(rec + 4)                   (a 4-aligned int)
 *   8-byte content     memcpy of a fixed 8 bytes                 (gcc emits an ordinary mov; see asm/)
 *   Lmx fields         memcpy of one field at its offsetof       (parent, length, storage are never touched through a
 *                                                                 struct Lmx pointer: the Lmx image is unaligned)
 *
 * Arbitrary-address API (default, NO record-start map): type_of_address(p) finds the chunk through the hash set of block
 * bases and treats p as a record start (a 4-aligned address inside the issued records of a record chunk), reading the tag.
 * With -DPK_START_MAP=1 (rep name tv_packed_map) every chunk header is followed by a bitmap with one bit per 4-byte granule
 * marking the starts of records, and type_of_address becomes the CHECKED version: the nearest start bit at or left of the
 * address, the tag there, and the decision record start / content address / inner byte (T_NONE).  The map is maintained at
 * every allocation, so this build also shows the cost of keeping it.
 *
 * Dense data (slot arrays, Array<int> data, Array-of-handle data) stays dense and aligned in separate raw chunks.
 */
#ifndef REP_TV_PACKED_H
#define REP_TV_PACKED_H

#include "common.h"
#include "chunks.h"

#ifndef PK_START_MAP
#define PK_START_MAP 0
#endif
#if PK_START_MAP
#define REP_NAME "tv_packed_map"
#define REP_INTERIOR_ADDR 1
#define PK_BITMAP_BYTES ((size_t)2048)             /* 16384 bits: one per 4-byte granule of a 64 KB block */
#else
#define REP_NAME "tv_packed"
#define REP_INTERIOR_ADDR 0                        /* type_of_address answers for record starts (slot values) only */
#define PK_BITMAP_BYTES ((size_t)0)
#endif
#define PK_HDR (CHUNK_HDR + PK_BITMAP_BYTES)       /* 2112 = 33 * 64 with the map: the first record starts on a cache line */
#define PK_INT_REC (sizeof(int) + sizeof(int))
#define PK_UNINIT_REC (sizeof(int) + sizeof(int) + sizeof(int))
#define PK_WIDE_REC (sizeof(int) + 8)
#define PK_LMX_REC (sizeof(int) + sizeof(struct Lmx))

typedef char pk_assert_int4[(sizeof(int) == 4) ? 1 : -1];
typedef char pk_assert_wide8[(sizeof(double) == 8 && sizeof(size_t) == 8 && sizeof(void *) == 8) ? 1 : -1];
typedef char pk_assert_lmx4[(sizeof(struct Lmx) % 4 == 0) ? 1 : -1];

typedef struct Arena {
    ChunkSet cs;
    CPool raw_int;   /* dense Array<int> data */
    CPool raw_ref;   /* slot arrays and Array-of-handle data */
    Chunk *cur;      /* current record chunk */
    int straddle;    /* 1: every 12-byte record is placed so that its 8-byte content crosses a 64-byte line */
} Arena;

static inline Arena *arena_new(void)
{
    Arena *a = (Arena *)xcalloc(1, sizeof(Arena));
    cs_init(&a->cs);
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
    a->straddle = on;
}

/* ---- bump allocation of one record of `bytes` bytes (a multiple of 4) ---- */
static inline size_t pk_pad(const Arena *a, const Chunk *c, int wide)
{
    if (a->straddle && wide) {
        /* content = rec + 4 must start 4 bytes before a 64-byte line end: rec at line offset 56 */
        size_t phase = (c->used * 4) & 63;
        return ((56 + 64 - phase) & 63) / 4;
    }
    return 0;
}

static inline char *pk_rec(Arena *a, size_t bytes, int wide)
{
    size_t g = bytes / 4;
    Chunk *c = a->cur;
    size_t pad = 0;
    size_t idx;
#if PK_START_MAP
    uint64_t *bm;
#endif
    if (c != NULL) {
        pad = pk_pad(a, c, wide);
    }
    if (c == NULL || c->cap - c->used < g + pad) {
        c = cs_new_chunk_hdr(&a->cs, CK_RECORDS, 0, 4, 0, PK_HDR);
        a->cur = c;
        pad = pk_pad(a, c, wide);
    }
    idx = c->used + pad;
    c->used = idx + g;
#if PK_START_MAP
    bm = (uint64_t *)((char *)c + CHUNK_HDR);
    bit_test_set(bm, idx);
#endif
    return c->data + idx * 4;
}

/* ---- field access ---- */
static inline int type_of_ref(Arena *a, void *h)
{
    (void)a;
    return *(const int *)h & TAG_MASK; /* T_EMBEDDED masked out */
}

static inline size_t pk_rec_size(int tag)
{
    switch (tag) {
    case T_INT:
        return PK_INT_REC;
    case T_UNINIT_INT:
        return PK_UNINIT_REC;
    case T_REAL:
    case T_SIZE:
    case T_REF:
        return PK_WIDE_REC;
    default:
        return PK_LMX_REC;
    }
}

static inline int int_get(void *h)
{
    return *(const int *)((const char *)h + 4);
}

static inline void int_set(void *h, int v)
{
    *(int *)((char *)h + 4) = v;
}

static inline int *int_addr(void *h)
{
    return (int *)((char *)h + 4);
}

static inline double real_get(void *h)
{
    double v;
    memcpy(&v, (const char *)h + 4, sizeof v);
    return v;
}

static inline void real_set(void *h, double v)
{
    memcpy((char *)h + 4, &v, sizeof v);
}

static inline size_t size_get(void *h)
{
    size_t v;
    memcpy(&v, (const char *)h + 4, sizeof v);
    return v;
}

static inline void size_set(void *h, size_t v)
{
    memcpy((char *)h + 4, &v, sizeof v);
}

static inline void *ref_get(void *h)
{
    void *v;
    memcpy(&v, (const char *)h + 4, sizeof v);
    return v;
}

static inline void ref_set(void *h, void *v)
{
    memcpy((char *)h + 4, &v, sizeof v);
}

/* nested uninit:int: [UNINIT_INT][INT|EMBEDDED][value]; @u = record + 4 (constant), its content at record + 8 */
static inline void *uninit_ref(void *h)
{
    return (char *)h + 4;
}

static inline int uninit_get(void *h)
{
    return *(const int *)((const char *)h + 8);
}

static inline void uninit_set(void *h, int v)
{
    *(int *)((char *)h + 8) = v;
}

/* ---- the Lmx image at rec + 4: fields are read and written by fixed-size memcpy at their offsets ---- */
static inline size_t length(void *s)
{
    size_t v;
    memcpy(&v, (const char *)s + 4 + offsetof(struct Lmx, length), sizeof v);
    return v;
}

static inline void *lmx_storage(void *s)
{
    void *v;
    memcpy(&v, (const char *)s + 4 + offsetof(struct Lmx, storage), sizeof v);
    return v;
}

static inline void *lmx_key(void *s)
{
    return s;
}

static inline void *parent_key(void *s)
{
    void *v;
    memcpy(&v, (const char *)s + 4 + offsetof(struct Lmx, parent), sizeof v);
    return v;
}

static inline void set_parent_key(void *s, void *key)
{
    memcpy((char *)s + 4 + offsetof(struct Lmx, parent), &key, sizeof key);
}

static inline void **slots(void *s)
{
    return (void **)lmx_storage(s);
}

static inline int *array_int_data(void *s)
{
    return (int *)lmx_storage(s);
}

static inline void **array_ref_data(void *s)
{
    return (void **)lmx_storage(s);
}

/* ---- constructors ---- */
static inline void *new_int(Arena *a, int v)
{
    char *r = pk_rec(a, PK_INT_REC, 0);
    *(int *)r = T_INT;
    *(int *)(r + 4) = v;
    return r;
}

static inline void *new_real(Arena *a, double v)
{
    char *r = pk_rec(a, PK_WIDE_REC, 1);
    *(int *)r = T_REAL;
    memcpy(r + 4, &v, sizeof v);
    return r;
}

static inline void *new_size(Arena *a, size_t v)
{
    char *r = pk_rec(a, PK_WIDE_REC, 1);
    *(int *)r = T_SIZE;
    memcpy(r + 4, &v, sizeof v);
    return r;
}

/* nested form (the protocol): 12 bytes; typeof(slot) = uninit:int, typeof(@u) = int */
static inline void *new_uninit_int(Arena *a)
{
    char *r = pk_rec(a, PK_UNINIT_REC, 0);
    *(int *)r = T_UNINIT_INT;
    *(int *)(r + 4) = T_INT | T_EMBEDDED;
    *(int *)(r + 8) = 0;
    return r;
}

/* flat form for the sizes table only: {UNINIT_INT; int}, 8 bytes; typeof(@u) would be uninit:int -- fails the protocol */
static inline void *new_uninit_int_flat(Arena *a)
{
    char *r = pk_rec(a, PK_INT_REC, 0);
    *(int *)r = T_UNINIT_INT;
    *(int *)(r + 4) = 0;
    return r;
}
#define REP_HAS_FLAT_UNINIT 1

static inline void *new_refcell(Arena *a, void *target)
{
    char *r = pk_rec(a, PK_WIDE_REC, 1);
    *(int *)r = T_REF;
    memcpy(r + 4, &target, sizeof target);
    return r;
}

static inline void *pk_new_lmx(Arena *a, int tag, size_t n, void *storage, void *parent)
{
    struct Lmx l;
    char *r = pk_rec(a, PK_LMX_REC, 0);
    memset(&l, 0, sizeof l);
    l.parent = (struct Lmx *)parent;
    l.length = n;
    l.storage = storage;
    *(int *)r = tag;
    memcpy(r + 4, &l, sizeof l);
    return r;
}

static inline void *new_struct(Arena *a, size_t nslots, void *parent)
{
    void *st = NULL;
    if (nslots > 0) {
        st = cpool_take_al(&a->cs, &a->raw_ref, nslots, TV_RAW_ALIGN);
        memset(st, 0, nslots * sizeof(void *));
    }
    return pk_new_lmx(a, T_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_int, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(int));
    }
    return pk_new_lmx(a, T_ARRAY_INT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = NULL;
    if (n > 0) {
        st = cpool_take_al(&a->cs, &a->raw_ref, n, TV_RAW_ALIGN);
        memset(st, 0, n * sizeof(void *));
    }
    return pk_new_lmx(a, T_ARRAY_REF, n, st, NULL);
}

/* ---- arbitrary address -> type ---- */
#if PK_START_MAP
static inline unsigned pk_msb(uint64_t m)
{
    unsigned r = 0;
    if (m >> 32) { m >>= 32; r += 32; }
    if (m >> 16) { m >>= 16; r += 16; }
    if (m >> 8) { m >>= 8; r += 8; }
    if (m >> 4) { m >>= 4; r += 4; }
    if (m >> 2) { m >>= 2; r += 2; }
    if (m >> 1) { r += 1; }
    return r;
}

/* nearest record-start bit at or to the left of granule g, or (size_t)-1 */
static inline size_t pk_prev_start(const uint64_t *bm, size_t g)
{
    size_t w = g >> 6;
    unsigned b = (unsigned)(g & 63);
    uint64_t m = bm[w] & (b == 63 ? ~(uint64_t)0 : (((uint64_t)1 << (b + 1)) - 1));
    for (;;) {
        if (m != 0) {
            return (w << 6) + pk_msb(m);
        }
        if (w == 0) {
            return (size_t)-1;
        }
        m = bm[--w];
    }
}
#endif

#if PK_START_MAP
/* CHECKED: nearest record-start bit at or left of p decides record start / content address / inner byte */
static inline int type_of_address(Arena *a, const void *p)
{
    Chunk *c;
    size_t off;
    size_t s;
    size_t rel;
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
    s = pk_prev_start((const uint64_t *)((const char *)c + CHUNK_HDR), off >> 2);
    if (s == (size_t)-1) {
        return T_NONE;
    }
    tag = *(const int *)(c->data + s * 4);
    rel = off - s * 4;
    if (rel == 0) {
        return tag & TAG_MASK; /* the record itself, as a slot holds it */
    }
    if (tag == T_UNINIT_INT) {
        return (rel == 4 || rel == 8) ? T_INT : T_NONE; /* @u (the nested record) and the address of its content */
    }
    if (rel == 4) {
        return tag; /* the address of the content */
    }
    return T_NONE;
}
#else
/* NO map: the chunk list decides "inside the arena"; p is taken for a record start */
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
    if ((off & 3) != 0) {
        return T_NONE;
    }
    return *(const int *)p & TAG_MASK;
}
#endif

/* ---- gc support: one mark bit per 4-byte granule of the record start ---- */
static inline void gc_begin(Arena *a)
{
    cs_gc_begin(&a->cs);
}

static inline void gc_end(Arena *a)
{
    cs_gc_end(&a->cs);
}

static inline int obj_mark(Arena *a, void *h, int *type)
{
    Chunk *c = cs_chunk_of(h);
    int tag = *(const int *)h;
    size_t g;
    (void)a;
    if (tag & T_EMBEDDED) { /* @u: the allocation starts 4 bytes earlier */
        h = (char *)h - 4;
    }
    g = (size_t)((char *)h - c->data) >> 2;
    *type = tag & TAG_MASK;
    return !bit_test_set(c->mark, g);
}

static inline size_t bytes_live(Arena *a)
{
    return cs_bytes(&a->cs) + sizeof(Arena);
}

static inline void rep_print_layout(void)
{
    printf("  packed records (tag + value, no padding, bump-allocated, handle = record start):\n");
    printf("    int record                   = %llu bytes (uninit:int nested = %llu, flat single record = %llu)\n", (unsigned long long)PK_INT_REC, (unsigned long long)PK_UNINIT_REC, (unsigned long long)PK_INT_REC);
    printf("    double / size_t / ref record = %llu bytes\n", (unsigned long long)PK_WIDE_REC);
    printf("    Lmx descriptor record        = %llu bytes\n", (unsigned long long)PK_LMX_REC);
    printf("    chunk: header %llu + record-start bitmap %llu = %llu bytes before the first record\n",
           (unsigned long long)CHUNK_HDR, (unsigned long long)PK_BITMAP_BYTES, (unsigned long long)PK_HDR);
    PRINT_TYPE(Chunk);
    PRINT_TYPE(Arena);
}

#include "graph_algos.h"

#endif /* REP_TV_PACKED_H */
