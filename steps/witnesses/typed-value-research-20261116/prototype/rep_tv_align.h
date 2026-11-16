/* rep_tv_align.h -- tv_word's record format with the OPTIMAL UNIVERSAL ALIGNMENT (not the rules of a C union).
 *
 *   record = [int tag][value, aligned to its own type]      the tag is the four bytes immediately before the value,
 *                                                            the slot holds the address of the tag, the value is at +4
 *
 *   value                         alignment   record start      allocation
 *   int                           4           any multiple of 4   8
 *   double, size_t, reference     8           4 mod 8             12  (+4 padding when the previous record ended on a multiple of 8
 *                                                                      -> 16 in a mixed stream)
 *   Lmx descriptor (parent|length|storage[|native])  8   4 mod 8   28 (+4) -> 32; 36 (+4) -> 40 with -DLMX_NATIVE_WORD=1
 *   uninit:int, nested            4           any multiple of 4   12   [UNINIT_INT][INT|EMBEDDED][int]; @u = start + 4
 *   uninit:T with an 8-byte T     8           0 mod 8             16   [UNINIT_T][T|EMBEDDED][8 bytes] (counted in sizes, not built)
 *
 * Padding lies BETWEEN records, before the tag.  The stream is a single untyped bump allocator (raw blocks of slot arrays and
 * dense Array data, 8-aligned and tagless, share it); there is no record-start map; type_of_address(p) treats p as a record
 * start (as in tv_word).  GC marks one bit per 4-byte granule at the record start.
 *
 * Line rule (-DTA_LINE_RULE=1, default; -DTA_LINE_RULE=0 builds tv_align_noline): a record (tag to end of value, at most 40 bytes)
 * never crosses a 64-byte line.  If it does not fit in the rest of the current line its tag is placed at the start of the next
 * line (shifted by 4 when the value needs 8-alignment).  A skipped tail of at least 8 bytes is remembered (one hole per arena) and
 * given to the next record with a 4-byte value (int, nested uninit:int) that fits.
 *
 * C99 basis: the memory is malloc'd storage; its effective type is set by the store that fills it (C99 6.5p6) -- every
 * record is written with the lvalue types it is later read with (int tag, int / double / size_t / void * value, struct Lmx).
 * Alignment of every typed access is guaranteed by the placement above (checked by the static asserts below and by the
 * allocator invariants), so no unaligned access, no packed attribute, no memcpy is needed; the descriptor is used as
 * (struct Lmx *)(rec + 4).
 */
#ifndef REP_TV_ALIGN_H
#define REP_TV_ALIGN_H

#include "common.h"
#include "chunks.h"

#ifndef TA_LINE_RULE
#define TA_LINE_RULE 1
#endif
#ifndef TA_MEMCPY
#define TA_MEMCPY 0 /* 1: control build -- aligned addresses, but 8-byte values and Lmx fields are accessed through memcpy */
#endif
#ifndef TA_RAW_ALIGN
#define TA_RAW_ALIGN TV_RAW_ALIGN /* alignment of dense storage (slot arrays, Array data) in the stream */
#endif
#if TA_LINE_RULE
#define TA_SFX_LINE ""
#else
#define TA_SFX_LINE "_noline"
#endif
#if TA_MEMCPY
#define TA_SFX_MEM "_memcpy"
#else
#define TA_SFX_MEM ""
#endif
#if TA_RAW_ALIGN == 8
#define TA_SFX_RAW "_raw8"
#elif TA_RAW_ALIGN == 64
#define TA_SFX_RAW ""
#else
#define TA_SFX_RAW "_rawN"
#endif
#define REP_NAME "tv_align" TA_SFX_LINE TA_SFX_MEM TA_SFX_RAW
#define REP_INTERIOR_ADDR 0 /* type_of_address answers for record starts (slot values) only */
#define REP_HAS_FILL 1

#define TA_INT_REC ((size_t)8)
#define TA_WIDE_REC ((size_t)12)
#define TA_LMX_REC (sizeof(int) + sizeof(struct Lmx))
#define TA_UNINIT_REC ((size_t)12)
#define TA_UNINIT_WIDE_REC ((size_t)16)

typedef char ta_assert_int4[(sizeof(int) == 4) ? 1 : -1];
typedef char ta_assert_wide8[(sizeof(double) == 8 && sizeof(size_t) == 8 && sizeof(void *) == 8) ? 1 : -1];
typedef char ta_assert_lmx8[(sizeof(struct Lmx) % 8 == 0 && TA_LMX_REC <= 40) ? 1 : -1]; /* descriptor fields 8-aligned at tag + 4; a record fits one 64-byte line */

typedef struct Arena {
    ChunkSet cs;
    Chunk *cur;          /* current stream chunk; its unit is a 4-byte granule */
    Chunk *hole_chunk;   /* the remembered line tail: [hole_start, hole_end) byte offsets inside hole_chunk->data */
    size_t hole_start;
    size_t hole_end;
    FillStats fs;
    int straddle;
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
    (void)a;
    (void)on; /* the placement is already the aligned one: nothing to shift */
}

/* one record of `size` bytes whose value needs 8-alignment (eight != 0: the tag lies at 4 mod 8) or only 4-alignment */
static inline char *ta_rec(Arena *a, size_t size, int eight)
{
    for (;;) {
        Chunk *c = a->cur;
        size_t pos;
        size_t at;
#if TA_LINE_RULE
        size_t tail_from;
        size_t tail_to;
        if (!eight && a->hole_chunk != NULL && a->hole_end - a->hole_start >= size) {
            Chunk *hc = a->hole_chunk;
            char *r = hc->data + a->hole_start;
            a->hole_start += size;
            a->fs.hole_filled += size;
            if (a->hole_end - a->hole_start < 8) {
                a->hole_chunk = NULL;
            }
            a->fs.records++;
            a->fs.net += size;
            return r;
        }
#endif
        if (c == NULL) {
            c = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 4, 0, CHUNK_HDR);
            a->cur = c;
        }
        pos = c->used * 4;
        at = pos;
        if (eight && (at & 7) == 0) {
            at += 4;
        }
#if TA_LINE_RULE
        tail_from = 0;
        tail_to = 0;
        if (at + size > (at & ~(size_t)63) + 64) { /* does not fit in the rest of the line */
            tail_from = pos;
            tail_to = (pos & ~(size_t)63) + 64;
            pos = tail_to;
            at = pos;
            if (eight) {
                at += 4;
            }
        }
#endif
        if ((at + size) / 4 > c->cap) {
            a->cur = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 4, 0, CHUNK_HDR);
            continue;
        }
#if TA_LINE_RULE
        if (tail_to > tail_from) { /* committed: the skipped tail lies inside the issued part of the chunk */
            size_t tail = tail_to - tail_from;
            if (tail >= 8 && (a->hole_chunk == NULL || tail > a->hole_end - a->hole_start)) {
                a->hole_chunk = c;
                a->hole_start = tail_from;
                a->hole_end = tail_to;
            }
            a->fs.pad_line += tail;
        }
#endif
        a->fs.pad_align += at - pos;
        c->used = (at + size) / 4;
        a->fs.records++;
        a->fs.net += size;
        return c->data + at;
    }
}

/* a raw block (slot array / dense data): 8-aligned, tagless, rounded up to a multiple of 8; may cross lines */
static inline void *ta_raw(Arena *a, size_t bytes)
{
    size_t rounded = (bytes + 7) & ~(size_t)7;
    char *r;
    if (rounded / 4 > (CHUNK_BYTES - CHUNK_HDR) / 4) {
        Chunk *d = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 4, rounded / 4, CHUNK_HDR);
        d->used = rounded / 4;
        a->fs.raw += rounded;
        r = d->data;
    } else {
        for (;;) {
            Chunk *c = a->cur;
            size_t pos;
            size_t at;
            if (c == NULL) {
                c = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 4, 0, CHUNK_HDR);
                a->cur = c;
            }
            pos = c->used * 4;
            at = (pos + TA_RAW_ALIGN - 1) & ~(size_t)(TA_RAW_ALIGN - 1);
            if ((at + rounded) / 4 > c->cap) {
                a->cur = cs_new_chunk_hdr(&a->cs, CK_STREAM, 0, 4, 0, CHUNK_HDR);
                continue;
            }
            a->fs.pad_raw += at - pos;
            c->used = (at + rounded) / 4;
            a->fs.raw += rounded;
            r = c->data + at;
            break;
        }
    }
    memset(r, 0, bytes);
    return r;
}

/* ---- 8-byte values and Lmx fields: ordinary typed accesses at aligned addresses; TA_MEMCPY=1 uses memcpy instead (control build) ---- */
#if TA_MEMCPY
static inline double ta_ld_double(const void *p) { double v; memcpy(&v, p, sizeof v); return v; }
static inline size_t ta_ld_size_t(const void *p) { size_t v; memcpy(&v, p, sizeof v); return v; }
static inline void *ta_ld_voidp(const void *p) { void *v; memcpy(&v, p, sizeof v); return v; }
static inline void ta_st_double(void *p, double v) { memcpy(p, &v, sizeof v); }
static inline void ta_st_size_t(void *p, size_t v) { memcpy(p, &v, sizeof v); }
static inline void ta_st_voidp(void *p, void *v) { memcpy(p, &v, sizeof v); }
#define TA_LMX_LD(T, s, field) ta_ld_##T((const char *)(s) + 4 + offsetof(struct Lmx, field))
#define TA_LMX_ST(T, s, field, v) ta_st_##T((char *)(s) + 4 + offsetof(struct Lmx, field), (v))
#else
static inline double ta_ld_double(const void *p) { return *(const double *)p; }
static inline size_t ta_ld_size_t(const void *p) { return *(const size_t *)p; }
static inline void *ta_ld_voidp(const void *p) { return *(void *const *)p; }
static inline void ta_st_double(void *p, double v) { *(double *)p = v; }
static inline void ta_st_size_t(void *p, size_t v) { *(size_t *)p = v; }
static inline void ta_st_voidp(void *p, void *v) { *(void **)p = v; }
/* the descriptor is used as (struct Lmx *)(rec + 4) */
#define TA_LMX_LD(T, s, field) (((const struct Lmx *)((const char *)(s) + 4))->field)
#define TA_LMX_ST(T, s, field, v) (((struct Lmx *)((char *)(s) + 4))->field = (v))
#endif

/* ---- field access ---- */
static inline int type_of_ref(Arena *a, void *h)
{
    (void)a;
    return *(const int *)h & TAG_MASK; /* T_EMBEDDED masked out */
}

static inline int int_get(void *h) { return *(const int *)((const char *)h + 4); }
static inline void int_set(void *h, int v) { *(int *)((char *)h + 4) = v; }
static inline int *int_addr(void *h) { return (int *)((char *)h + 4); }
static inline double real_get(void *h) { return ta_ld_double((const char *)h + 4); }
static inline void real_set(void *h, double v) { ta_st_double((char *)h + 4, v); }
static inline size_t size_get(void *h) { return ta_ld_size_t((const char *)h + 4); }
static inline void size_set(void *h, size_t v) { ta_st_size_t((char *)h + 4, v); }
static inline void *ref_get(void *h) { return ta_ld_voidp((const char *)h + 4); }
static inline void ref_set(void *h, void *v) { ta_st_voidp((char *)h + 4, v); }

/* nested uninit:int: [UNINIT_INT][INT|EMBEDDED][value]; @u = record + 4 (constant), its content at record + 8 */
static inline void *uninit_ref(void *h) { return (char *)h + 4; }
static inline int uninit_get(void *h) { return *(const int *)((const char *)h + 8); }
static inline void uninit_set(void *h, int v) { *(int *)((char *)h + 8) = v; }

static inline size_t length(void *s) { return TA_LMX_LD(size_t, s, length); }
static inline void *lmx_storage(void *s) { return (void *)TA_LMX_LD(voidp, s, storage); }
static inline void *lmx_key(void *s) { return (char *)s + 4; } /* the address of the descriptor, never dereferenced here */
static inline void *parent_key(void *s) { return (void *)TA_LMX_LD(voidp, s, parent); }
static inline void set_parent_key(void *s, void *key) { TA_LMX_ST(voidp, s, parent, (struct Lmx *)key); }
static inline void **slots(void *s) { return (void **)lmx_storage(s); }
static inline int *array_int_data(void *s) { return (int *)lmx_storage(s); }
static inline void **array_ref_data(void *s) { return (void **)lmx_storage(s); }

/* ---- constructors ---- */
static inline void *new_int(Arena *a, int v)
{
    char *r = ta_rec(a, TA_INT_REC, 0);
    *(int *)r = T_INT;
    *(int *)(r + 4) = v;
    return r;
}

static inline void *new_real(Arena *a, double v)
{
    char *r = ta_rec(a, TA_WIDE_REC, 1);
    *(int *)r = T_REAL;
    ta_st_double(r + 4, v);
    return r;
}

static inline void *new_size(Arena *a, size_t v)
{
    char *r = ta_rec(a, TA_WIDE_REC, 1);
    *(int *)r = T_SIZE;
    ta_st_size_t(r + 4, v);
    return r;
}

/* nested form (the protocol): 12 bytes; typeof(slot) = uninit:int, typeof(@u) = int */
static inline void *new_uninit_int(Arena *a)
{
    char *r = ta_rec(a, TA_UNINIT_REC, 0);
    *(int *)r = T_UNINIT_INT;
    *(int *)(r + 4) = T_INT | T_EMBEDDED;
    *(int *)(r + 8) = 0;
    return r;
}

static inline void *new_refcell(Arena *a, void *target)
{
    char *r = ta_rec(a, TA_WIDE_REC, 1);
    *(int *)r = T_REF;
    ta_st_voidp(r + 4, target);
    return r;
}

static inline void *ta_new_lmx(Arena *a, int tag, size_t n, void *storage, void *parent)
{
    char *r = ta_rec(a, TA_LMX_REC, 1);
    *(int *)r = tag;
    TA_LMX_ST(voidp, r, parent, parent ? (struct Lmx *)lmx_key(parent) : NULL);
    TA_LMX_ST(size_t, r, length, n);
    TA_LMX_ST(voidp, r, storage, storage);
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    TA_LMX_ST(voidp, r, native, NULL);
#endif
    return r;
}

static inline void *new_struct(Arena *a, size_t nslots, void *parent)
{
    void *st = (nslots > 0) ? ta_raw(a, nslots * sizeof(void *)) : NULL;
    return ta_new_lmx(a, T_STRUCT, nslots, st, parent);
}

static inline void *new_array_int(Arena *a, size_t n)
{
    void *st = (n > 0) ? ta_raw(a, n * sizeof(int)) : NULL;
    return ta_new_lmx(a, T_ARRAY_INT, n, st, NULL);
}

static inline void *new_array_ref(Arena *a, size_t n)
{
    void *st = (n > 0) ? ta_raw(a, n * sizeof(void *)) : NULL;
    return ta_new_lmx(a, T_ARRAY_REF, n, st, NULL);
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
    if (off == (size_t)-1 || (off & 3) != 0) { /* a record starts on a 4-byte boundary */
        return T_NONE;
    }
    return *(const int *)p & TAG_MASK;
}

/* ---- gc support: a mark bit per 4-byte granule at the record start ---- */
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
    idx = (size_t)((char *)h - c->data) >> 2;
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
    *f = a->fs;
    f->stream = 0;
    for (i = 0; i < a->cs.nall; i++) {
        f->stream += a->cs.all[i]->used * 4;
    }
}

static inline void rep_print_layout(void)
{
    printf("  aligned tag+value records (tag at 4 mod 8 for 8-byte values, any multiple of 4 for int), one untyped bump stream:\n");
    printf("    int record                   = %llu bytes\n", (unsigned long long)TA_INT_REC);
    printf("    double / size_t / ref record = %llu bytes (+4 padding after a record ending on a multiple of 8)\n",
           (unsigned long long)TA_WIDE_REC);
    printf("    Lmx descriptor record        = %llu bytes (+4 padding likewise)\n", (unsigned long long)TA_LMX_REC);
    printf("    uninit:int nested            = %llu bytes [UNINIT_INT][INT|EMBEDDED][int]\n", (unsigned long long)TA_UNINIT_REC);
    printf("    uninit:T, 8-byte T, nested   = %llu bytes [UNINIT_T][T|EMBEDDED][8 bytes], start 0 mod 8 (formula only, not built)\n",
           (unsigned long long)TA_UNINIT_WIDE_REC);
    printf("    64-byte line rule            = %s\n", TA_LINE_RULE ? "ON (records never cross a line; one hole of >= 8 bytes is reused)" : "OFF");
    PRINT_TYPE(Chunk);
    PRINT_TYPE(Arena);
}

#include "graph_algos.h"

#endif /* REP_TV_ALIGN_H */
