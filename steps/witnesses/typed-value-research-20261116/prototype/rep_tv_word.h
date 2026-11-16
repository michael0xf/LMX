/* rep_tv_word.h -- the author's exact layout: an UNTYPED arena of chunks with one bump allocator; records of all types lie
 * one after another, each starting on a machine-word boundary:
 *
 *   record = [int type][content of exactly its own size, at offset 4][filler up to a multiple of 8]
 *
 *   int, unsigned, char                 8 bytes     (4 + 4);  uninit:int (nested form, the protocol) 16 bytes: [UNINIT_INT][INT|EMBEDDED][value]
 *   double, size_t, reference, word    16 bytes     (4 + 8 + 4 filler); the 8-byte content sits at record + 4 (4 mod 8)
 *   Lmx descriptor                     32 bytes     (4 + 24 + 4); 40 with -DLMX_NATIVE_WORD=1 (4 + 32 + 4)
 *
 * No union space is reserved for the largest variant.  A slot (handle) is the address of the record start.  Dense data (slot
 * arrays, Array<int> data, Array-of-handle data) are raw blocks of the SAME arena stream, 8-aligned and without a tag; the
 * descriptor's storage points at them.  There is NO record-start map: type_of_address(p) treats p as a record start.
 *
 *   tag      *(const int *)rec                       (rec is 8-aligned)
 *   content  4-byte: *(const int *)(rec + 4);   8-byte and Lmx fields: memcpy of a fixed size (one mov each, see asm/)
 *
 * Chunks are the 64 KB-aligned chunks of chunks.h (kind CK_STREAM, unit = one 8-byte word), found by mask for a trusted record
 * and by the hash set of block bases for an arbitrary address.  GC: a mark bit per 8-byte word at the record's start offset.
 * A sequential sweep over a chunk would step by the tag, but raw blocks carry no tag, so only the reachability marking is
 * implemented (the same policy as in every other representation).
 *
 * --straddle: every 16-byte record is placed to start at 56 mod 64, so that its 8-byte content crosses a cache line.
 */
#ifndef REP_TV_WORD_H
#define REP_TV_WORD_H

#include "common.h"
#include "chunks.h"

#ifndef TW_TYPED_UNALIGNED
#define TW_TYPED_UNALIGNED 0 /* 1: control build -- same addresses, 8-byte accesses through typed pointers of alignment 1 (GNU extension) */
#endif
#ifndef TW_RAW_ALIGN
#define TW_RAW_ALIGN TV_RAW_ALIGN /* alignment of dense storage (slot arrays, Array data) in the stream; -DTW_RAW_ALIGN=8 reproduces the old point */
#endif
#if TW_TYPED_UNALIGNED
#define TW_SFX_TYPED "_typed"
#else
#define TW_SFX_TYPED ""
#endif
#if TW_RAW_ALIGN == 8
#define TW_SFX_RAW "_raw8"
#elif TW_RAW_ALIGN == 64
#define TW_SFX_RAW ""
#else
#define TW_SFX_RAW "_rawN"
#endif
#define REP_NAME "tv_word" TW_SFX_RAW TW_SFX_TYPED

/* 8-byte loads / stores at addresses that are 4 mod 8.  Default: memcpy of a fixed size (no UB, no GNU extension).
 * TW_TYPED_UNALIGNED=1 (control build only): the same addresses through typed lvalues of alignment 1 (GNU `aligned(1)` typedefs),
 * which keep strict aliasing -- to separate the cost of the unaligned access from the cost of the char-based memcpy access. */
#if TW_TYPED_UNALIGNED
typedef double tw_u_double __attribute__((aligned(1)));
typedef size_t tw_u_size_t __attribute__((aligned(1)));
typedef void *tw_u_voidp __attribute__((aligned(1)));
#define TW_LD(T, p) (*(const tw_u_##T *)(p))
#define TW_ST(T, p, v) (*(tw_u_##T *)(p) = (v))
#else
static inline double tw_ld_double(const void *p)
{
    double v;
    memcpy(&v, p, sizeof v);
    return v;
}
static inline size_t tw_ld_size_t(const void *p)
{
    size_t v;
    memcpy(&v, p, sizeof v);
    return v;
}
static inline void *tw_ld_voidp(const void *p)
{
    void *v;
    memcpy(&v, p, sizeof v);
    return v;
}
static inline void tw_st_double(void *p, double v) { memcpy(p, &v, sizeof v); }
static inline void tw_st_size_t(void *p, size_t v) { memcpy(p, &v, sizeof v); }
static inline void tw_st_voidp(void *p, void *v) { memcpy(p, &v, sizeof v); }
#define TW_LD(T, p) tw_ld_##T(p)
#define TW_ST(T, p, v) tw_st_##T((p), (v))
#endif
#define REP_INTERIOR_ADDR 0 /* type_of_address answers for record starts (slot values) only */

#define TW_ROUND8(n) (((n) + 7) & ~(size_t)7)
#define TW_INT_REC ((size_t)8)
#define TW_WIDE_REC ((size_t)16)
#define TW_LMX_REC TW_ROUND8(sizeof(int) + sizeof(struct Lmx))
#define TW_UNINIT_REC ((size_t)16) /* nested form: [UNINIT_INT][INT|EMBEDDED][value] = 12 -> 16; the flat form {UNINIT_INT; int} is 8 */

typedef char tw_assert_int4[(sizeof(int) == 4) ? 1 : -1];
typedef char tw_assert_wide8[(sizeof(double) == 8 && sizeof(size_t) == 8 && sizeof(void *) == 8) ? 1 : -1];

#define REP_HAS_FILL 1

typedef struct Arena {
    ChunkSet cs;
    Chunk *cur;     /* current stream chunk */
    int straddle;
    size_t records; /* statistics: record allocations, net bytes (tag + value), raw block bytes, raw-alignment padding */
    size_t net;
    size_t raw;
    size_t pad_raw;
} Arena;

static inline Arena *arena_new(void)
{
    Arena *a = (Arena *)xcalloc(1, sizeof(Arena));
    cs_init(&a->cs);
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

/* `words` 8-byte words from the stream (a block longer than a normal chunk gets a dedicated chunk) */
static inline char *tw_take(Arena *a, size_t words, size_t pad_phase_56)
{
    Chunk *c = a->cur;
    size_t pad = 0;
    char *r;
    if (words > (CHUNK_BYTES - CHUNK_HDR) / 8) {
        Chunk *d = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 8, words, CHUNK_HDR);
        d->used = words;
        return d->data;
    }
    if (c != NULL && pad_phase_56) {
        pad = ((56 + 64 - ((c->used * 8) & 63)) & 63) / 8;
    }
    if (c == NULL || c->cap - c->used < words + pad) {
        c = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 8, 0, CHUNK_HDR);
        a->cur = c;
        pad = pad_phase_56 ? ((56 + 64 - ((c->used * 8) & 63)) & 63) / 8 : 0;
    }
    r = c->data + (c->used + pad) * 8;
    c->used += pad + words;
    return r;
}

static inline char *tw_rec(Arena *a, size_t bytes, int wide, size_t net)
{
    a->records++;
    a->net += net;
    return tw_take(a, bytes / 8, a->straddle && wide);
}

/* dense storage: starts on a TW_RAW_ALIGN boundary (64 by default: a cache line), tagless, in the same stream */
static inline void *tw_raw(Arena *a, size_t bytes)
{
    size_t words = (bytes + 7) / 8;
    size_t pad = 0;
    char *r;
    if (words > (CHUNK_BYTES - CHUNK_HDR) / 8) {
        r = tw_take(a, words, 0); /* a dedicated chunk: its data starts 64-aligned */
    } else {
        if (a->cur != NULL) {
            pad = ((TW_RAW_ALIGN - ((a->cur->used * 8) % TW_RAW_ALIGN)) % TW_RAW_ALIGN) / 8;
        }
        if (a->cur == NULL || a->cur->cap - a->cur->used < pad + words) {
            a->cur = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 8, 0, CHUNK_HDR);
            pad = 0;
        }
        r = tw_take(a, pad + words, 0) + pad * 8;
        a->pad_raw += pad * 8;
    }
    a->raw += words * 8;
    memset(r, 0, bytes);
    return r;
}

/* ---- field access ---- */
static inline int type_of_ref(Arena *a, void *h)
{
    (void)a;
    return *(const int *)h & TAG_MASK; /* T_EMBEDDED masked out */
}

static inline int int_get(void *h) { return *(const int *)((const char *)h + 4); }
static inline void int_set(void *h, int v) { *(int *)((char *)h + 4) = v; }
static inline int *int_addr(void *h) { return (int *)((char *)h + 4); }

static inline double real_get(void *h) { return TW_LD(double, (const char *)h + 4); }
static inline void real_set(void *h, double v) { TW_ST(double, (char *)h + 4, v); }
static inline size_t size_get(void *h) { return TW_LD(size_t, (const char *)h + 4); }
static inline void size_set(void *h, size_t v) { TW_ST(size_t, (char *)h + 4, v); }
static inline void *ref_get(void *h) { return TW_LD(voidp, (const char *)h + 4); }
static inline void ref_set(void *h, void *v) { TW_ST(voidp, (char *)h + 4, v); }

/* nested uninit:int: [UNINIT_INT][INT|EMBEDDED][value]; @u = record + 4 (constant, no memory read), its content at record + 8 */
static inline void *uninit_ref(void *h) { return (char *)h + 4; }
static inline int uninit_get(void *h) { return *(const int *)((const char *)h + 8); }
static inline void uninit_set(void *h, int v) { *(int *)((char *)h + 8) = v; }

static inline size_t length(void *s) { return TW_LD(size_t, (const char *)s + 4 + offsetof(struct Lmx, length)); }
static inline void *lmx_storage(void *s) { return TW_LD(voidp, (const char *)s + 4 + offsetof(struct Lmx, storage)); }

static inline void *lmx_key(void *s) { return s; }

static inline void *parent_key(void *s) { return TW_LD(voidp, (const char *)s + 4 + offsetof(struct Lmx, parent)); }
static inline void set_parent_key(void *s, void *key) { TW_ST(voidp, (char *)s + 4 + offsetof(struct Lmx, parent), key); }

static inline void **slots(void *s) { return (void **)lmx_storage(s); }
static inline int *array_int_data(void *s) { return (int *)lmx_storage(s); }
static inline void **array_ref_data(void *s) { return (void **)lmx_storage(s); }

/* ---- constructors ---- */
static inline void *new_int(Arena *a, int v)
{
    char *r = tw_rec(a, TW_INT_REC, 0, 8);
    *(int *)r = T_INT;
    *(int *)(r + 4) = v;
    return r;
}

static inline void *new_real(Arena *a, double v)
{
    char *r = tw_rec(a, TW_WIDE_REC, 1, 12);
    *(int *)r = T_REAL;
    TW_ST(double, r + 4, v);
    return r;
}

static inline void *new_size(Arena *a, size_t v)
{
    char *r = tw_rec(a, TW_WIDE_REC, 1, 12);
    *(int *)r = T_SIZE;
    TW_ST(size_t, r + 4, v);
    return r;
}

/* nested form (the protocol): 16 bytes; typeof(slot) = uninit:int, typeof(@u) = int */
static inline void *new_uninit_int(Arena *a)
{
    char *r = tw_rec(a, TW_UNINIT_REC, 0, 12);
    *(int *)r = T_UNINIT_INT;
    *(int *)(r + 4) = T_INT | T_EMBEDDED;
    *(int *)(r + 8) = 0;
    return r;
}

/* flat form for the sizes table only: one record {UNINIT_INT; int}, 8 bytes; typeof(@u) would be uninit:int -- fails the protocol */
static inline void *new_uninit_int_flat(Arena *a)
{
    char *r = tw_rec(a, TW_INT_REC, 0, 8);
    *(int *)r = T_UNINIT_INT;
    *(int *)(r + 4) = 0;
    return r;
}
#define REP_HAS_FLAT_UNINIT 1

static inline void *new_refcell(Arena *a, void *target)
{
    char *r = tw_rec(a, TW_WIDE_REC, 1, 12);
    *(int *)r = T_REF;
    TW_ST(voidp, r + 4, target);
    return r;
}

static inline void *tw_new_lmx(Arena *a, int tag, size_t n, void *storage, void *parent)
{
    char *r = tw_rec(a, TW_LMX_REC, 0, sizeof(int) + sizeof(struct Lmx));
    *(int *)r = tag;
    TW_ST(voidp, r + 4 + offsetof(struct Lmx, parent), parent);
    TW_ST(size_t, r + 4 + offsetof(struct Lmx, length), n);
    TW_ST(voidp, r + 4 + offsetof(struct Lmx, storage), storage);
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    TW_ST(voidp, r + 4 + offsetof(struct Lmx, native), NULL);
#endif
    return r;
}

static inline void *new_struct(Arena *a, size_t nslots, void *parent)
{
    void *st = (nslots > 0) ? tw_raw(a, nslots * sizeof(void *)) : NULL;
    return tw_new_lmx(a, T_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = (n > 0) ? tw_raw(a, n * sizeof(int)) : NULL;
    return tw_new_lmx(a, T_ARRAY_INT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = (n > 0) ? tw_raw(a, n * sizeof(void *)) : NULL;
    return tw_new_lmx(a, T_ARRAY_REF, n, st, NULL);
}

/* ---- arbitrary address: the chunk list decides "inside the arena", then p is taken for a record start ---- */
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
    if (off == (size_t)-1 || (off & 3) != 0) { /* a record starts on a 4-byte boundary: 8-aligned, or 4 mod 8 for a nested record */
        return T_NONE;
    }
    return *(const int *)p & TAG_MASK;
}

/* ---- gc support: a mark bit per 8-byte word at the record start ---- */
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
    idx = (size_t)((char *)h - c->data) >> 3;
    *type = tag & TAG_MASK;
    return !bit_test_set(c->mark, idx);
}

static inline size_t bytes_live(Arena *a)
{
    return cs_bytes(&a->cs) + sizeof(Arena);
}

static inline void fill_stats(const Arena *a, FillStats *f)
{
    size_t i;
    memset(f, 0, sizeof(*f));
    f->records = a->records;
    f->net = a->net;
    f->raw = a->raw;
    f->pad_raw = a->pad_raw;
    for (i = 0; i < a->cs.nall; i++) {
        f->stream += a->cs.all[i]->used * 8;
    }
}

static inline void rep_print_layout(void)
{
    printf("  word records ([int type][content at +4][filler to 8], start 8-aligned, one untyped bump stream):\n");
    printf("    int record                   = %llu bytes (uninit:int nested = %llu, flat single record = %llu)\n", (unsigned long long)TW_INT_REC, (unsigned long long)TW_UNINIT_REC, (unsigned long long)TW_INT_REC);
    printf("    double / size_t / ref record = %llu bytes\n", (unsigned long long)TW_WIDE_REC);
    printf("    Lmx descriptor record        = %llu bytes\n", (unsigned long long)TW_LMX_REC);
    printf("    chunk: header %llu bytes, unit = 8-byte word\n", (unsigned long long)CHUNK_HDR);
    PRINT_TYPE(Chunk);
    PRINT_TYPE(Arena);
}

#include "graph_algos.h"

#endif /* REP_TV_WORD_H */
