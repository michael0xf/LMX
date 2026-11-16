/* common.h -- shared helpers of the TypedValue research prototype (pure C99, no UB; LP64 and LLP64).
 *
 * This is a research artifact (author's order 2026-11-16, model C99), not a maintained project test.
 * Everything representation-independent lives here: type codes, struct Lmx, PRNG, timing, pointer map,
 * bit helpers, vectors.  Each representation header (rep_*.h) provides the same static inline API.
 */
#ifndef TV_COMMON_H
#define TV_COMMON_H

#if !defined(_WIN32) && !defined(_POSIX_C_SOURCE)
#define _POSIX_C_SOURCE 199309L
#endif

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <time.h>
#endif

#if defined(__GNUC__)
#define NOINLINE __attribute__((noinline))
#else
#define NOINLINE
#endif

/* ---- type codes: the logical type of a stored value, identical in every representation ---- */
enum {
    T_NONE = 0,
    T_INT = 1,
    T_REAL = 2,
    T_SIZE = 3,
    T_REF = 4,          /* reference cell: holds the handle of its target */
    T_STRUCT = 5,       /* Structure: struct Lmx whose storage is an array of slots */
    T_ARRAY_INT = 6,    /* dense Array<int>: struct Lmx whose storage is int[length] */
    T_ARRAY_REF = 7,    /* dense Array of handles: struct Lmx whose storage is void *[length] */
    T_UNINIT_INT = 8,   /* uninit:int: keeps its type after writes; its int cell has its own address */
    T_EXT_LMX = 9,      /* internal: externally allocated struct Lmx (tv_compact only), never a value type */
    T_NTYPES = 10
};

/* Tagged representations (tv_word, tv_tagged, tv_packed) store uninit:int as ONE allocation holding a nested record:
 *   [int T_UNINIT_INT][int T_INT | T_EMBEDDED][int value]
 * The slot holds the start of the outer record; @u is outer + 4, the start of the nested record, whose tag is read like any other
 * and whose content is at nested + 4.  T_EMBEDDED marks a record that starts 4 bytes after its allocation (the collector steps
 * back) and is masked out when a type is reported. */
#define T_EMBEDDED 0x100
#define TAG_MASK 0xFF

/* ---- the common Lmx header: flat target layout (24 bytes), +native word with -DLMX_NATIVE_WORD=1 (32 bytes) ---- */
struct Lmx {
    struct Lmx *parent;
    size_t length;
    void *storage;
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    void *native;
#endif
};

/* Placement statistics of the stream representations (tv_word, tv_align): REP_HAS_FILL is defined by their headers and fill_stats()
 * fills this record.  waste = stream - net - raw = alignment padding + skipped line tails + unused holes + record fillers. */
typedef struct FillStats {
    size_t records;     /* record allocations (Lmx descriptors, ints, doubles, ...), raw blocks excluded */
    size_t net;         /* bytes of those records without any filler: tag + value */
    size_t raw;         /* bytes of raw blocks (slot arrays, dense Array data), rounded as allocated */
    size_t stream;      /* bytes issued from the stream chunks: records + raw + every kind of padding */
    size_t pad_raw;     /* padding inserted to align dense storage (slot arrays, Array data) */
    size_t pad_align;   /* tv_align: padding inserted to align a value */
    size_t pad_line;    /* tv_align: tails of 64-byte lines left unused because the next record did not fit */
    size_t hole_filled; /* tv_align: bytes of such tails reused by a later record */
} FillStats;

/* alignof by the offsetof trick (C99 has no _Alignof) */
#define ALIGNOF(T) offsetof(struct { char c_; T t_; }, t_)

/* ---- memory helpers: abort on failure, never return NULL ---- */
static inline void *xmalloc(size_t n)
{
    void *p = malloc(n ? n : 1);
    if (p == NULL) {
        fprintf(stderr, "out of memory (%llu bytes)\n", (unsigned long long)n);
        exit(2);
    }
    return p;
}

static inline void *xcalloc(size_t n, size_t m)
{
    void *p = calloc(n ? n : 1, m ? m : 1);
    if (p == NULL) {
        fprintf(stderr, "out of memory (%llu x %llu bytes)\n", (unsigned long long)n, (unsigned long long)m);
        exit(2);
    }
    return p;
}

static inline void *xrealloc(void *old, size_t n)
{
    void *p = realloc(old, n ? n : 1);
    if (p == NULL) {
        fprintf(stderr, "out of memory (realloc %llu bytes)\n", (unsigned long long)n);
        exit(2);
    }
    return p;
}

/* ---- PRNG: splitmix64, one stream per seed, identical in every representation ---- */
typedef struct Rng {
    uint64_t s;
} Rng;

static inline uint64_t rng_next(Rng *r)
{
    uint64_t z = (r->s += 0x9E3779B97F4A7C15ULL);
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
    return z ^ (z >> 31);
}

/* uniform in [0, n), n < 2^32 */
static inline uint32_t rng_below(Rng *r, uint32_t n)
{
    return (uint32_t)(((rng_next(r) >> 32) * (uint64_t)n) >> 32);
}

static inline void shuffle_u32(Rng *r, uint32_t *v, size_t n)
{
    size_t i;
    for (i = n; i > 1; i--) {
        size_t j = rng_below(r, (uint32_t)i);
        uint32_t t = v[i - 1];
        v[i - 1] = v[j];
        v[j] = t;
    }
}

/* ---- timing: QueryPerformanceCounter on Windows, clock_gettime elsewhere ---- */
static inline uint64_t now_ns(void)
{
#if defined(_WIN32)
    static LARGE_INTEGER freq;
    LARGE_INTEGER c;
    uint64_t q;
    uint64_t f;
    if (freq.QuadPart == 0) {
        QueryPerformanceFrequency(&freq);
    }
    QueryPerformanceCounter(&c);
    q = (uint64_t)c.QuadPart;
    f = (uint64_t)freq.QuadPart;
    return (q / f) * 1000000000ULL + (q % f) * 1000000000ULL / f;
#else
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
#endif
}

/* ---- bit helpers ---- */
static inline int bit_test_set(uint64_t *bm, size_t i)
{
    uint64_t m = (uint64_t)1 << (i & 63);
    uint64_t *w = &bm[i >> 6];
    int was = (*w & m) != 0;
    *w |= m;
    return was;
}

/* ---- open-addressing pointer map (key != NULL), power-of-two capacity, grows at load 1/2 ---- */
typedef struct PtrMap {
    const void **keys;
    void **vals;
    size_t cap;
    size_t count;
} PtrMap;

static inline size_t ptr_hash(const void *p)
{
    uint64_t x = (uint64_t)(uintptr_t)p;
    x ^= x >> 33;
    x *= 0xFF51AFD7ED558CCDULL;
    x ^= x >> 33;
    return (size_t)x;
}

static inline void map_init(PtrMap *m, size_t hint)
{
    size_t cap = 16;
    while (cap < hint * 2) {
        cap <<= 1;
    }
    m->keys = (const void **)xcalloc(cap, sizeof(void *));
    m->vals = (void **)xcalloc(cap, sizeof(void *));
    m->cap = cap;
    m->count = 0;
}

static inline void map_free(PtrMap *m)
{
    free((void *)m->keys);
    free(m->vals);
    m->keys = NULL;
    m->vals = NULL;
    m->cap = 0;
    m->count = 0;
}

static inline void *map_get(const PtrMap *m, const void *key)
{
    size_t mask = m->cap - 1;
    size_t i = ptr_hash(key) & mask;
    while (m->keys[i] != NULL) {
        if (m->keys[i] == key) {
            return m->vals[i];
        }
        i = (i + 1) & mask;
    }
    return NULL;
}

static inline void map_put(PtrMap *m, const void *key, void *val);

static inline void map_grow(PtrMap *m)
{
    PtrMap bigger;
    size_t i;
    bigger.keys = (const void **)xcalloc(m->cap * 2, sizeof(void *));
    bigger.vals = (void **)xcalloc(m->cap * 2, sizeof(void *));
    bigger.cap = m->cap * 2;
    bigger.count = 0;
    for (i = 0; i < m->cap; i++) {
        if (m->keys[i] != NULL) {
            map_put(&bigger, m->keys[i], m->vals[i]);
        }
    }
    free((void *)m->keys);
    free(m->vals);
    *m = bigger;
}

static inline void map_put(PtrMap *m, const void *key, void *val)
{
    size_t mask;
    size_t i;
    if ((m->count + 1) * 2 > m->cap) {
        map_grow(m);
    }
    mask = m->cap - 1;
    i = ptr_hash(key) & mask;
    while (m->keys[i] != NULL && m->keys[i] != key) {
        i = (i + 1) & mask;
    }
    if (m->keys[i] == NULL) {
        m->keys[i] = key;
        m->count++;
    }
    m->vals[i] = val;
}

static inline size_t map_bytes(const PtrMap *m)
{
    return m->cap * 2 * sizeof(void *);
}

/* ---- pointer stack / vector ---- */
typedef struct PtrStack {
    void **v;
    size_t n;
    size_t cap;
} PtrStack;

static inline void pstack_push(PtrStack *s, void *p)
{
    if (s->n == s->cap) {
        s->cap = s->cap ? s->cap * 2 : 64;
        s->v = (void **)xrealloc(s->v, s->cap * sizeof(void *));
    }
    s->v[s->n++] = p;
}

/* ---- printing helpers for sizes and layouts ---- */
#define PRINT_TYPE(T) \
    printf("  %-28s size=%3llu align=%2llu\n", #T, (unsigned long long)sizeof(T), (unsigned long long)ALIGNOF(T))
#define PRINT_OFF(T, M) \
    printf("  offsetof(%s, %s) = %llu\n", #T, #M, (unsigned long long)offsetof(T, M))

#endif /* TV_COMMON_H */
