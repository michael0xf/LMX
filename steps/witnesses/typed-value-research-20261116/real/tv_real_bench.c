/* FABLE-R-TV-D (opus, 2026-11-16): a bench of the CURRENT LMX runtime -- the address -> physical type scheme of the
 * arena's range index -- so that the TypedValue comparison has a measured base, not a model of it.
 *
 * Linked like an emitted fixture p.c: compiled with the fixture's p.c flags (-Dmain=l2_generated_main and the other
 * renames) and linked with the accepted G2 driver.o and the frontend's l2_libc.o.  The driver's own main runs its
 * self-checks and then calls this main with the arguments after "--".  When this main returns, the driver reports that
 * no host was launched; that report and the driver's exit status are not the bench's result -- the bench's result is its
 * TSV rows and the final "#tv-real done status=0" line (README.md).
 *
 * One source, two builds: bench-time (plain) for items 0, 1, 2, 4 and bench-mem (-DTV_WRAP=1, linked with
 * -Wl,--wrap=calloc,--wrap=malloc,--wrap=realloc,--wrap=free) for item 3.  Every timed loop is a noinline function whose
 * result goes into a checksum; sizes come from argv; time is QueryPerformanceCounter; a timed row gives the median, the
 * minimum and the maximum over R repetitions of the per-call (per-object) time.
 *
 * Only the runtime's exported C entries are called, the way generated code calls them; nothing of the runtime is
 * reimplemented here.  The one row that calls nothing (floor_direct) is marked as a floor, not as the runtime.
 */
#include "l2src/lmx_arena.lm1.h"
#include "l2src/lmx_arena_blocks.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_graph.lm1.h"
#include "l2src/lmx_walk_values.lm1.h"
#include "l2src/lmx_source_names.lm1.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef TV_WRAP
#define TV_WRAP 0
#endif

/* Win32, declared here: none of the headers above includes windows.h (checked 2026-11-16), and none declares these. */
int QueryPerformanceCounter(long long * count);
int QueryPerformanceFrequency(long long * frequency);
void * GetCurrentThread(void);
unsigned long long SetThreadAffinityMask(void * thread, unsigned long long mask);
void * GetCurrentProcess(void);
int SetPriorityClass(void * process, unsigned long priority);

/* ---- options ------------------------------------------------------------------------------------------------------ */

#define TV_LIST_MAX 8U

typedef struct TvOptions {
    size_t n_list[TV_LIST_MAX];
    size_t n_count;
    size_t f_list[TV_LIST_MAX];
    size_t f_count;
    size_t reps;
    size_t create_reps;
    size_t calls;
    size_t structs;
    size_t k;
    size_t k_named;
    size_t ints;
    size_t create_structs;
    size_t seed;
    size_t track;
    int ptr_type;
    long cpu;
    const char * out;
} TvOptions;

static void tv_defaults(TvOptions * o)
{
    memset(o, 0, sizeof *o);
    o->n_list[0] = 100U;
    o->n_list[1] = 1000U;
    o->n_list[2] = 10000U;
    o->n_count = 3U;
    o->f_list[0] = 4U;
    o->f_list[1] = 16U;
    o->f_list[2] = 64U;
    o->f_count = 3U;
    o->reps = 15U;
    o->create_reps = 7U;
    o->calls = 200000U;
    o->structs = 8U;
    o->k = 10000U;
    o->k_named = 1000U;
    o->ints = 100000U;
    o->create_structs = 10000U;
    o->seed = (size_t) 0x2545F4914F6CDD1DULL;
    o->track = (size_t) 1U << 20;
    /* The pointer cell of a native `@: px int @ x` (root_pointer_index p.c: LMX_TYPE_POINTER_BASE + 11). */
    o->ptr_type = LMX_TYPE_POINTER_BASE + 11;
    o->cpu = 1;
    o->out = 0;
}

static size_t tv_parse_list(const char * text, size_t * out, size_t max)
{
    size_t n = 0U;
    const char * p = text;
    char * end = 0;
    while (*p != '\0' && n < max) {
        unsigned long long v = strtoull(p, &end, 10);
        if (end == p)
            break;
        out[n++] = (size_t) v;
        p = end;
        if (*p == ',')
            p++;
    }
    return n;
}

static size_t tv_size(const char * text)
{
    return (size_t) strtoull(text, 0, 0);
}

/* key=value arguments after the mode; returns 0, or 1 for an unknown key. */
static int tv_parse(TvOptions * o, int argc, char ** argv)
{
    int i;
    for (i = 2; i < argc; i++) {
        const char * arg = argv[i];
        const char * eq = strchr(arg, '=');
        size_t key;
        const char * v;
        if (eq == 0) {
            fprintf(stderr, "tv-real: expected key=value, got %s\n", arg);
            return 1;
        }
        key = (size_t) (eq - arg);
        v = eq + 1;
        if (key == 1U && strncmp(arg, "N", key) == 0)
            o->n_count = tv_parse_list(v, o->n_list, TV_LIST_MAX);
        else if (key == 1U && strncmp(arg, "F", key) == 0)
            o->f_count = tv_parse_list(v, o->f_list, TV_LIST_MAX);
        else if (key == 1U && strncmp(arg, "R", key) == 0)
            o->reps = tv_size(v);
        else if (key == 2U && strncmp(arg, "CR", key) == 0)
            o->create_reps = tv_size(v);
        else if (key == 5U && strncmp(arg, "calls", key) == 0)
            o->calls = tv_size(v);
        else if (key == 7U && strncmp(arg, "structs", key) == 0)
            o->structs = tv_size(v);
        else if (key == 1U && strncmp(arg, "K", key) == 0)
            o->k = tv_size(v);
        else if (key == 2U && strncmp(arg, "KN", key) == 0)
            o->k_named = tv_size(v);
        else if (key == 4U && strncmp(arg, "ints", key) == 0)
            o->ints = tv_size(v);
        else if (key == 8U && strncmp(arg, "cstructs", key) == 0)
            o->create_structs = tv_size(v);
        else if (key == 4U && strncmp(arg, "seed", key) == 0)
            o->seed = tv_size(v);
        else if (key == 5U && strncmp(arg, "track", key) == 0)
            o->track = tv_size(v);
        else if (key == 7U && strncmp(arg, "ptrtype", key) == 0)
            o->ptr_type = (int) strtol(v, 0, 0);
        else if (key == 3U && strncmp(arg, "cpu", key) == 0)
            o->cpu = strtol(v, 0, 10);
        else if (key == 3U && strncmp(arg, "out", key) == 0)
            o->out = v;
        else {
            fprintf(stderr, "tv-real: unknown key in %s\n", arg);
            return 1;
        }
    }
    if (o->reps == 0U || o->create_reps == 0U || o->calls == 0U || o->structs == 0U || o->seed == 0U)
        return 1;
    return 0;
}

/* ---- output, clock, statistics ------------------------------------------------------------------------------------ */

static FILE * tv_file;

static void tv_emit(const char * line)
{
    fputs(line, stdout);
    if (tv_file != 0)
        fputs(line, tv_file);
}

/* One TSV row: item metric variant n_target n_ranges pools fields count reps median min max unit. */
static void tv_row(const char * item, const char * metric, const char * variant, size_t n_target, size_t n_ranges,
                   size_t pools, size_t fields, size_t count, size_t reps, double median, double low, double high,
                   const char * unit)
{
    char line[512];
    snprintf(line, sizeof line, "%s\t%s\t%s\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.3f\t%.3f\t%.3f\t%s\n", item, metric,
             variant, (double) n_target, (double) n_ranges, (double) pools, (double) fields, (double) count,
             (double) reps, median, low, high, unit);
    tv_emit(line);
}

static void tv_value(const char * item, const char * metric, const char * variant, size_t n_ranges, size_t pools,
                     size_t count, double value, const char * unit)
{
    tv_row(item, metric, variant, 0U, n_ranges, pools, 0U, count, 1U, value, value, value, unit);
}

static double tv_tick_ns;
static volatile size_t tv_sink;

static void tv_clock_open(void)
{
    long long f = 0;
    QueryPerformanceFrequency(&f);
    tv_tick_ns = f > 0 ? 1e9 / (double) f : 0.0;
}

static long long tv_now(void)
{
    long long c = 0;
    QueryPerformanceCounter(&c);
    return c;
}

static int tv_cmp(const void * a, const void * b)
{
    double x = *(const double *) a;
    double y = *(const double *) b;
    return (x > y) - (x < y);
}

static void tv_stats(double * v, size_t n, double * median, double * low, double * high)
{
    qsort(v, n, sizeof v[0], tv_cmp);
    *low = v[0];
    *high = v[n - 1U];
    *median = (n % 2U) != 0U ? v[n / 2U] : (v[n / 2U - 1U] + v[n / 2U]) / 2.0;
}

static void tv_pin(const TvOptions * o)
{
    if (o->cpu >= 0 && o->cpu < 63) {
        SetThreadAffinityMask(GetCurrentThread(), 1ULL << (unsigned) o->cpu);
        SetPriorityClass(GetCurrentProcess(), 0x00000080UL); /* HIGH_PRIORITY_CLASS */
    }
}

static size_t tv_rand_state;

static size_t tv_rand(void)
{
    size_t x = tv_rand_state;
    x ^= x << 13;
    x ^= x >> 7;
    x ^= x << 17;
    tv_rand_state = x;
    return x;
}

static void tv_shuffle(void ** v, size_t n)
{
    size_t i;
    for (i = n; i > 1U; i--) {
        size_t j = tv_rand() % i;
        void * t = v[i - 1U];
        v[i - 1U] = v[j];
        v[j] = t;
    }
}

/* ---- heap accounting (bench-mem only) ----------------------------------------------------------------------------- */

typedef struct TvMem {
    double live;      /* bytes requested and not yet freed */
    double requested; /* bytes requested by calloc/malloc/realloc, cumulative */
    double allocs;    /* calloc + malloc calls that returned memory */
    double reallocs;  /* realloc calls that returned memory */
    double frees;     /* free calls with a non-null pointer */
    double unknown;   /* frees of pointers this tracker never saw (CRT-internal allocations) */
    double dropped;   /* allocations not tracked because the table was full */
} TvMem;

#if TV_WRAP
static TvMem tv_mem;

void * __real_calloc(size_t n, size_t m);
void * __real_malloc(size_t n);
void * __real_realloc(void * p, size_t n);
void __real_free(void * p);

typedef struct TvTrack {
    void * key;
    size_t size;
} TvTrack;

static TvTrack * tv_track;
static size_t tv_track_cap;
static size_t tv_track_used;
static size_t tv_track_want = (size_t) 1U << 20;

static size_t tv_hash(void * p)
{
    size_t h = (size_t) p;
    h ^= h >> 17;
    h *= (size_t) 0x9E3779B97F4A7C15ULL;
    return h ^ (h >> 29);
}

static void tv_track_open(void)
{
    size_t cap = 1024U;
    if (tv_track != 0)
        return;
    while (cap < tv_track_want)
        cap <<= 1;
    tv_track = (TvTrack *) __real_calloc(cap, sizeof(TvTrack));
    tv_track_cap = tv_track != 0 ? cap : 0U;
}

static void tv_track_put(void * p, size_t n)
{
    size_t mask;
    size_t i;
    tv_track_open();
    if (tv_track == 0 || p == 0 || tv_track_used * 10U >= tv_track_cap * 7U) {
        tv_mem.dropped += 1.0;
        return;
    }
    mask = tv_track_cap - 1U;
    i = tv_hash(p) & mask;
    while (tv_track[i].key != 0) {
        if (tv_track[i].key == p) {
            tv_track[i].size = n;
            return;
        }
        i = (i + 1U) & mask;
    }
    tv_track[i].key = p;
    tv_track[i].size = n;
    tv_track_used++;
}

/* k lies cyclically in (i, j]. */
static int tv_between(size_t i, size_t k, size_t j)
{
    return i <= j ? (i < k && k <= j) : (i < k || k <= j);
}

static int tv_track_take(void * p, size_t * n)
{
    size_t mask;
    size_t i;
    size_t j;
    if (tv_track == 0 || p == 0)
        return 0;
    mask = tv_track_cap - 1U;
    i = tv_hash(p) & mask;
    while (tv_track[i].key != 0 && tv_track[i].key != p)
        i = (i + 1U) & mask;
    if (tv_track[i].key == 0)
        return 0;
    *n = tv_track[i].size;
    j = i;
    for (;;) {
        j = (j + 1U) & mask;
        if (tv_track[j].key == 0)
            break;
        if (!tv_between(i, tv_hash(tv_track[j].key) & mask, j)) {
            tv_track[i] = tv_track[j];
            i = j;
        }
    }
    tv_track[i].key = 0;
    tv_track[i].size = 0U;
    tv_track_used--;
    return 1;
}

static void tv_track_free(void * p)
{
    size_t old = 0U;
    if (p == 0)
        return;
    if (tv_track_take(p, &old))
        tv_mem.live -= (double) old;
    else
        tv_mem.unknown += 1.0;
}

void * __wrap_calloc(size_t n, size_t m)
{
    void * p = __real_calloc(n, m);
    if (p != 0) {
        tv_mem.allocs += 1.0;
        tv_mem.requested += (double) n * (double) m;
        tv_mem.live += (double) n * (double) m;
        tv_track_put(p, n * m);
    }
    return p;
}

void * __wrap_malloc(size_t n)
{
    void * p = __real_malloc(n);
    if (p != 0) {
        tv_mem.allocs += 1.0;
        tv_mem.requested += (double) n;
        tv_mem.live += (double) n;
        tv_track_put(p, n);
    }
    return p;
}

void * __wrap_realloc(void * p, size_t n)
{
    void * q = __real_realloc(p, n);
    if (q == 0 && n != 0U)
        return q;
    if (p != 0) {
        tv_mem.frees += 1.0;
        tv_track_free(p);
    }
    if (q != 0) {
        tv_mem.reallocs += 1.0;
        tv_mem.requested += (double) n;
        tv_mem.live += (double) n;
        tv_track_put(q, n);
    }
    return q;
}

void __wrap_free(void * p)
{
    if (p != 0) {
        tv_mem.frees += 1.0;
        tv_track_free(p);
    }
    __real_free(p);
}
#endif

/* ---- the runtime, called as generated code calls it --------------------------------------------------------------- */

typedef struct TvArena {
    LmxArena * arena;
    Lmx * root;
} TvArena;

static int tv_open(TvArena * t)
{
    t->root = 0;
    t->arena = (LmxArena *) calloc(1U, sizeof(LmxArena));
    if (t->arena == 0 || lmx_arena_open(t->arena) != 0)
        return 1;
    t->root = lmx_node_new_owned(t->arena);
    return t->root == 0;
}

static void tv_close(TvArena * t)
{
    if (t->arena != 0) {
        lmx_arena_release(t->arena);
        free(t->arena);
    }
    t->arena = 0;
    t->root = 0;
}

static size_t tv_pools(LmxArena * arena)
{
    size_t n = 0U;
    LmxPool * pool = arena != 0 ? arena->arrays : 0;
    while (pool != 0) {
        n++;
        pool = pool->next;
    }
    return n;
}

/* Background int cells, one per call as generated code makes a scalar field, until the index has `target` ranges. */
static size_t tv_fill_ints(LmxArena * arena, size_t target, void ** cells, size_t cap)
{
    size_t n = 0U;
    while (n < cap && lmx_arena_index_len(arena) < target) {
        int * cell = (int *) lmx_int_new_profiled(arena, 0);
        if (cell == 0)
            break;
        *cell = (int) (n & 0x7fffffffU);
        if (cells != 0)
            cells[n] = (void *) cell;
        n++;
    }
    return n;
}

/* A Structure of `fields` int fields, by the calls an emitted p.c makes for it (e1_const_index, private_hidden_binding
 * p.c): lmx_struct_new_profiled under a parent, lmx_arena_refs_open_profiled, then per slot lmx_arena_ref_cell and
 * slot[0] = lmx_int_new_profiled(arena, lmx_range_profile(arena, slot)); with name_base != 0 each slot also gets
 * lmx_source_name_set(arena, slot, code) as a named field does. */
static Lmx * tv_struct(TvArena * t, size_t fields, size_t name_base)
{
    Lmx * s = lmx_struct_new_profiled(t->root, t->arena, lmx_range_profile(t->arena, (void *) t->root));
    size_t i;
    if (s == 0 || lmx_arena_refs_open_profiled(t->arena, s, fields, lmx_range_profile(t->arena, (void *) s)) != 0)
        return 0;
    for (i = 0U; i < fields; i++) {
        void ** slot = lmx_arena_ref_cell(s, i);
        int * cell;
        if (slot == 0)
            return 0;
        cell = (int *) lmx_int_new_profiled(t->arena, lmx_range_profile(t->arena, (void *) slot));
        if (cell == 0)
            return 0;
        *cell = (int) (i + 1U);
        slot[0] = (void *) cell;
        if (name_base != 0U && lmx_source_name_set(t->arena, (void *) slot, name_base + i) != 0)
            return 0;
    }
    return s;
}

enum {
    TV_INT_SINGLE,
    TV_INT_BULK,
    TV_PTR_SINGLE,
    TV_PTR_BULK,
    TV_STRUCT4_SINGLE,
    TV_STRUCT4_NAMED,
    TV_STRUCT4_BULK,
    TV_UNINIT_INT,
    TV_GRAPH_INT,
    TV_KIND_COUNT
};

static const char * const tv_kind_names[TV_KIND_COUNT] = {
    "int_single", "int_bulk", "ptr_single", "ptr_bulk", "struct4_single", "struct4_named", "struct4_bulk",
    "uninit_int", "graph_int"
};

/* Builds `count` objects of one kind; returns how many were built (count on success).  The _bulk kinds use the
 * runtime's one multi-cell request, lmx_arena_take_n_profiled; a Structure's children array has no multi-structure
 * request (lmx_arena_refs_open_profiled makes one pool per Structure), so struct4_bulk takes headers and int cells in
 * bulk and still opens the children per Structure. */
static __attribute__((noinline)) size_t tv_build(TvArena * t, LmxGraph * g, int kind, size_t count, int ptr_type)
{
    size_t i;
    size_t j;
    if (kind == TV_INT_SINGLE) {
        for (i = 0U; i < count; i++) {
            int * cell = (int *) lmx_int_new_profiled(t->arena, 0);
            if (cell == 0)
                return i;
            *cell = (int) (i & 0x7fffffffU);
        }
        return count;
    }
    if (kind == TV_INT_BULK)
        return lmx_arena_take_n_profiled(t->arena, sizeof(int), LMX_KIND_PRIMITIVE, LMX_TYPE_INT, 0, count) != 0 ? count : 0U;
    if (kind == TV_PTR_SINGLE) {
        for (i = 0U; i < count; i++)
            if (lmx_pointer_new_profiled(ptr_type, t->arena, 0) == 0)
                return i;
        return count;
    }
    if (kind == TV_PTR_BULK)
        return lmx_arena_take_n_profiled(t->arena, sizeof(void *), LMX_KIND_PRIMITIVE, ptr_type, 0, count) != 0 ? count : 0U;
    if (kind == TV_STRUCT4_SINGLE || kind == TV_STRUCT4_NAMED) {
        for (i = 0U; i < count; i++)
            if (tv_struct(t, 4U, kind == TV_STRUCT4_NAMED ? 1000U + 4U * i : 0U) == 0)
                return i;
        return count;
    }
    if (kind == TV_STRUCT4_BULK) {
        Lmx * headers = (Lmx *) lmx_arena_take_n_profiled(t->arena, sizeof(Lmx), LMX_KIND_STRUCT, LMX_TYPE_STRUCT, 0, count);
        int * cells = (int *) lmx_arena_take_n_profiled(t->arena, sizeof(int), LMX_KIND_PRIMITIVE, LMX_TYPE_INT, 0, count * 4U);
        if (headers == 0 || cells == 0)
            return 0U;
        for (i = 0U; i < count; i++) {
            Lmx * s = headers + i;
            s->parent = t->root;
            if (lmx_arena_refs_open_profiled(t->arena, s, 4U, lmx_range_profile(t->arena, (void *) s)) != 0)
                return i;
            for (j = 0U; j < 4U; j++) {
                void ** slot = lmx_arena_ref_cell(s, j);
                if (slot == 0)
                    return i;
                cells[4U * i + j] = (int) (j + 1U);
                slot[0] = (void *) (cells + 4U * i + j);
            }
        }
        return count;
    }
    if (kind == TV_UNINIT_INT) {
        for (i = 0U; i < count; i++)
            if (lmx_graph_uninit_int(g) == 0)
                return i;
        return count;
    }
    if (kind == TV_GRAPH_INT) {
        for (i = 0U; i < count; i++)
            if (lmx_graph_int(g, (int) (i & 0x7fffffffU)) == 0)
                return i;
        return count;
    }
    return 0U;
}

/* ---- item 0: record sizes ----------------------------------------------------------------------------------------- */

#define TV_SIZEOF(T) tv_value("0", "sizeof", #T, 0U, 0U, 0U, (double) sizeof(T), "B")

static int tv_item0(void)
{
    TV_SIZEOF(LmxRange);
    TV_SIZEOF(LmxPool);
    TV_SIZEOF(LmxChunk);
    TV_SIZEOF(LmxArenaBlock);
    TV_SIZEOF(LmxArena);
    TV_SIZEOF(Lmx);
    TV_SIZEOF(LmxWalkValue);
    TV_SIZEOF(LmxWalkPlace);
    TV_SIZEOF(LmxSourceName);
    TV_SIZEOF(LmxActivationBinding);
    return 0;
}

/* ---- item 1: one classification on a real arena ------------------------------------------------------------------- */

#define TV_ADDR_LOOP(NAME, CALL) \
    static __attribute__((noinline)) size_t NAME(LmxArena * arena, void ** addr, size_t n, size_t passes) \
    { \
        size_t sum = 0U; \
        size_t p; \
        size_t i; \
        for (p = 0U; p < passes; p++) \
            for (i = 0U; i < n; i++) \
                sum += (size_t) (CALL); \
        return sum; \
    }

TV_ADDR_LOOP(tv_loop_type_of, lmx_range_type_of(arena, addr[i]))
TV_ADDR_LOOP(tv_loop_classify, lmx_range_classify(arena, addr[i]))
TV_ADDR_LOOP(tv_loop_stride, lmx_range_stride(arena, addr[i]))
TV_ADDR_LOOP(tv_loop_cell_pool, lmx_range_cell_pool(arena, addr[i]))
TV_ADDR_LOOP(tv_loop_entry_at, lmx_range_entry_at(arena, addr[i]))
TV_ADDR_LOOP(tv_loop_profile, lmx_range_profile(arena, addr[i]))

typedef size_t (* TvAddrLoop)(LmxArena *, void **, size_t, size_t);

typedef struct TvAddrFn {
    const char * name;
    TvAddrLoop loop;
} TvAddrFn;

static const TvAddrFn tv_addr_fns[] = {
    { "lmx_range_type_of", tv_loop_type_of },
    { "lmx_range_classify", tv_loop_classify },
    { "lmx_range_stride", tv_loop_stride },
    { "lmx_range_cell_pool", tv_loop_cell_pool },
    { "lmx_range_entry_at", tv_loop_entry_at },
    { "lmx_range_profile", tv_loop_profile }
};

static int tv_foreign_probe;

static void tv_time_addr(const TvOptions * o, const TvAddrFn * fn, LmxArena * arena, void ** addr, size_t n,
                         const char * order, size_t target, double * samples)
{
    size_t passes = o->calls / n;
    size_t r;
    double median;
    double low;
    double high;
    if (passes == 0U)
        passes = 1U;
    tv_sink += fn->loop(arena, addr, n, passes);
    for (r = 0U; r < o->reps; r++) {
        long long t0 = tv_now();
        size_t sum = fn->loop(arena, addr, n, passes);
        long long t1 = tv_now();
        tv_sink += sum;
        samples[r] = (double) (t1 - t0) * tv_tick_ns / ((double) n * (double) passes);
    }
    tv_stats(samples, o->reps, &median, &low, &high);
    tv_row("1", fn->name, order, target, lmx_arena_index_len(arena), tv_pools(arena), 0U, n, o->reps, median, low, high,
           "ns/call");
}

static int tv_item1(const TvOptions * o)
{
    size_t ni;
    size_t f;
    double * samples = (double *) calloc(o->reps, sizeof(double));
    if (samples == 0)
        return 1;
    for (ni = 0U; ni < o->n_count; ni++) {
        size_t target = o->n_list[ni];
        size_t cap = target * 4U + 64U;
        size_t n;
        size_t i;
        TvArena t = { 0, 0 };
        void ** cells = (void **) calloc(cap, sizeof(void *));
        void ** shuffled = (void **) calloc(cap, sizeof(void *));
        void ** probe = (void **) calloc(cap, sizeof(void *));
        int status = 0;
        if (cells == 0 || shuffled == 0 || probe == 0 || tv_open(&t) != 0)
            status = 1;
        n = status == 0 ? tv_fill_ints(t.arena, target, cells, cap) : 0U;
        if (status == 0 && n == 0U)
            status = 1;
        if (status == 0) {
            memcpy(shuffled, cells, n * sizeof(void *));
            tv_shuffle(shuffled, n);
            tv_value("1", "arena", "int_cells", lmx_arena_index_len(t.arena), tv_pools(t.arena), n, (double) n, "cells");
            tv_value("1", "arena", "index_capacity_bytes", lmx_arena_index_len(t.arena), tv_pools(t.arena), n,
                     (double) t.arena->index.capacity * (double) sizeof(LmxRange), "B");
            for (f = 0U; f < sizeof tv_addr_fns / sizeof tv_addr_fns[0]; f++) {
                tv_time_addr(o, tv_addr_fns + f, t.arena, shuffled, n, "random", target, samples);
                tv_time_addr(o, tv_addr_fns + f, t.arena, cells, n, "alloc_order", target, samples);
                for (i = 0U; i < n; i++)
                    probe[i] = cells[n / 2U];
                tv_time_addr(o, tv_addr_fns + f, t.arena, probe, n, "repeat", target, samples);
                /* The second byte of a live int cell: inside a range, not a cell start. */
                for (i = 0U; i < n; i++)
                    probe[i] = (void *) ((char *) shuffled[i] + 1);
                tv_time_addr(o, tv_addr_fns + f, t.arena, probe, n, "interior", target, samples);
                /* An address no range of the arena holds: a static of this program. */
                for (i = 0U; i < n; i++)
                    probe[i] = (void *) &tv_foreign_probe;
                tv_time_addr(o, tv_addr_fns + f, t.arena, probe, n, "foreign", target, samples);
            }
        }
        tv_close(&t);
        free(cells);
        free(shuffled);
        free(probe);
        if (status != 0) {
            free(samples);
            return status;
        }
    }
    free(samples);
    return 0;
}

/* ---- item 2: reading a slot of the graph -------------------------------------------------------------------------- */

#define TV_SLOT_LOOP(NAME, ...) \
    static __attribute__((noinline)) size_t NAME(LmxArena * arena, Lmx ** s, size_t ns, size_t fields, size_t passes) \
    { \
        size_t sum = 0U; \
        size_t p; \
        size_t j; \
        size_t i; \
        (void) arena; \
        for (p = 0U; p < passes; p++) \
            for (j = 0U; j < ns; j++) \
                for (i = 0U; i < fields; i++) { \
                    __VA_ARGS__ \
                } \
        return sum; \
    }

TV_SLOT_LOOP(tv_slot_node_in, sum += (size_t) lmx_graph_node_in(arena, (void *) s[j]);)
TV_SLOT_LOOP(tv_slot_cell_in, sum += (size_t) lmx_graph_cell_in(arena, s[j], i);)
TV_SLOT_LOOP(tv_slot_value_in, sum += (size_t) lmx_graph_value_in(arena, s[j], i);)
TV_SLOT_LOOP(tv_slot_name_get, sum += lmx_source_name_get(arena, (void *) ((void **) s[j]->array.data + i));)
/* Not the runtime: the same slot -> cell -> int loads with no classification at all, as a floor. */
TV_SLOT_LOOP(tv_slot_floor, sum += (size_t) *(int *) ((void **) s[j]->array.data)[i];)

/* The walker's read of an int field: the slot's value (lmx_graph_value_in), then lmx_walk_value_cell -- which
 * classifies the cell's kind and type and loads it -- and the number. */
static __attribute__((noinline)) size_t tv_slot_value_cell(LmxArena * arena, Lmx ** s, size_t ns, size_t fields,
                                                           size_t passes)
{
    size_t sum = 0U;
    size_t p;
    size_t j;
    size_t i;
    LmxWalkValue v;
    memset(&v, 0, sizeof v);
    for (p = 0U; p < passes; p++)
        for (j = 0U; j < ns; j++)
            for (i = 0U; i < fields; i++) {
                if (lmx_walk_value_cell(arena, lmx_graph_value_in(arena, s[j], i), &v) == LMX_WALK_OK)
                    sum += (size_t) v.number;
                else
                    sum += 1000003U;
            }
    return sum;
}

typedef size_t (* TvSlotLoop)(LmxArena *, Lmx **, size_t, size_t, size_t);

typedef struct TvSlotFn {
    const char * name;
    TvSlotLoop loop;
} TvSlotFn;

static const TvSlotFn tv_slot_fns[] = {
    { "lmx_graph_node_in", tv_slot_node_in },
    { "lmx_graph_cell_in", tv_slot_cell_in },
    { "lmx_graph_value_in", tv_slot_value_in },
    { "value_in+lmx_walk_value_cell", tv_slot_value_cell },
    { "lmx_source_name_get(slot)", tv_slot_name_get },
    { "floor_direct(no runtime call)", tv_slot_floor }
};

static int tv_item2(const TvOptions * o)
{
    size_t ni;
    size_t fi;
    size_t f;
    double * samples = (double *) calloc(o->reps, sizeof(double));
    Lmx ** s = (Lmx **) calloc(o->structs, sizeof(Lmx *));
    if (samples == 0 || s == 0) {
        free(samples);
        free(s);
        return 1;
    }
    for (ni = 0U; ni < o->n_count; ni++)
        for (fi = 0U; fi < o->f_count; fi++) {
            size_t target = o->n_list[ni];
            size_t fields = o->f_list[fi];
            size_t j;
            TvArena t;
            int status = tv_open(&t);
            for (j = 0U; status == 0 && j < o->structs; j++) {
                s[j] = tv_struct(&t, fields, 1000U + j * fields);
                if (s[j] == 0)
                    status = 1;
            }
            /* The Structures first, then background int cells up to the target number of ranges. */
            if (status == 0)
                tv_fill_ints(t.arena, target, 0, target * 4U + 64U);
            for (f = 0U; status == 0 && f < sizeof tv_slot_fns / sizeof tv_slot_fns[0]; f++) {
                size_t reads = o->structs * fields;
                size_t passes = o->calls / reads;
                size_t r;
                double median;
                double low;
                double high;
                if (passes == 0U)
                    passes = 1U;
                tv_sink += tv_slot_fns[f].loop(t.arena, s, o->structs, fields, passes);
                for (r = 0U; r < o->reps; r++) {
                    long long t0 = tv_now();
                    size_t sum = tv_slot_fns[f].loop(t.arena, s, o->structs, fields, passes);
                    long long t1 = tv_now();
                    tv_sink += sum;
                    samples[r] = (double) (t1 - t0) * tv_tick_ns / ((double) reads * (double) passes);
                }
                tv_stats(samples, o->reps, &median, &low, &high);
                tv_row("2", tv_slot_fns[f].name, "seq", target, lmx_arena_index_len(t.arena), tv_pools(t.arena), fields,
                       reads, o->reps, median, low, high, "ns/read");
            }
            tv_close(&t);
            if (status != 0) {
                free(samples);
                free(s);
                return status;
            }
        }
    free(samples);
    free(s);
    return 0;
}

/* ---- item 3: heap per object (bench-mem) -------------------------------------------------------------------------- */

static int tv_item3(const TvOptions * o)
{
#if TV_WRAP
    int kind;
    for (kind = 0; kind < TV_KIND_COUNT; kind++) {
        TvArena t;
        LmxGraph * g = 0;
        TvMem before_arena = tv_mem;
        TvMem a;
        TvMem b;
        size_t count = kind == TV_STRUCT4_NAMED ? o->k_named : o->k;
        size_t ranges0;
        size_t pools0;
        size_t built;
        size_t ranges1;
        size_t pools1;
        double k;
        const char * name = tv_kind_names[kind];
        if (tv_open(&t) != 0) {
            tv_close(&t);
            return 1;
        }
        if (kind == TV_UNINIT_INT || kind == TV_GRAPH_INT) {
            g = lmx_graph_open(t.arena);
            if (g == 0) {
                tv_close(&t);
                return 1;
            }
        }
        ranges0 = lmx_arena_index_len(t.arena);
        pools0 = tv_pools(t.arena);
        a = tv_mem;
        built = tv_build(&t, g, kind, count, o->ptr_type);
        b = tv_mem;
        ranges1 = lmx_arena_index_len(t.arena);
        pools1 = tv_pools(t.arena);
        tv_sink += built;
        if (built != count) {
            fprintf(stderr, "tv-real: %s built %.0f of %.0f\n", name, (double) built, (double) count);
            if (g != 0)
                lmx_graph_close(g);
            tv_close(&t);
            return 1;
        }
        k = (double) count;
        tv_value("3", "live_bytes", name, ranges1, pools1, count, (b.live - a.live) / k, "B/obj");
        tv_value("3", "requested_bytes", name, ranges1, pools1, count, (b.requested - a.requested) / k, "B/obj");
        tv_value("3", "alloc_calls", name, ranges1, pools1, count, (b.allocs - a.allocs) / k, "calls/obj");
        tv_value("3", "realloc_calls", name, ranges1, pools1, count, (b.reallocs - a.reallocs) / k, "calls/obj");
        tv_value("3", "free_calls", name, ranges1, pools1, count, (b.frees - a.frees) / k, "calls/obj");
        tv_value("3", "ranges", name, ranges1, pools1, count, ((double) ranges1 - (double) ranges0) / k, "ranges/obj");
        tv_value("3", "pools", name, ranges1, pools1, count, ((double) pools1 - (double) pools0) / k, "pools/obj");
        tv_value("3", "index_capacity_bytes", name, ranges1, pools1, count,
                 (double) t.arena->index.capacity * (double) sizeof(LmxRange), "B");
        if (b.dropped != a.dropped || b.unknown != a.unknown)
            tv_value("3", "untracked_events", name, ranges1, pools1, count,
                     (b.dropped - a.dropped) + (b.unknown - a.unknown), "events");
        if (g != 0)
            lmx_graph_close(g);
        tv_close(&t);
        tv_value("3", "live_after_release", name, 0U, 0U, count, tv_mem.live - before_arena.live, "B");
    }
    return 0;
#else
    (void) o;
    tv_emit("# item 3 needs the bench-mem build (-DTV_WRAP=1 with --wrap); skipped\n");
    return 0;
#endif
}

/* ---- item 4: creation time ---------------------------------------------------------------------------------------- */

static int tv_item4(const TvOptions * o)
{
    static const int kinds[] = { TV_INT_SINGLE, TV_INT_BULK, TV_STRUCT4_SINGLE, TV_STRUCT4_BULK, TV_PTR_SINGLE,
                                 TV_UNINIT_INT };
    size_t ki;
    double * samples = (double *) calloc(o->create_reps, sizeof(double));
    double * totals = (double *) calloc(o->create_reps, sizeof(double));
    if (samples == 0 || totals == 0) {
        free(samples);
        free(totals);
        return 1;
    }
    for (ki = 0U; ki < sizeof kinds / sizeof kinds[0]; ki++) {
        int kind = kinds[ki];
        size_t count = (kind == TV_STRUCT4_SINGLE || kind == TV_STRUCT4_BULK) ? o->create_structs : o->ints;
        size_t r;
        size_t ranges = 0U;
        size_t pools = 0U;
        double median;
        double low;
        double high;
        for (r = 0U; r < o->create_reps; r++) {
            TvArena t;
            LmxGraph * g = 0;
            long long t0;
            long long t1;
            size_t built;
            if (tv_open(&t) != 0) {
                tv_close(&t);
                free(samples);
                free(totals);
                return 1;
            }
            if (kind == TV_UNINIT_INT)
                g = lmx_graph_open(t.arena);
            t0 = tv_now();
            built = tv_build(&t, g, kind, count, o->ptr_type);
            t1 = tv_now();
            tv_sink += built;
            ranges = lmx_arena_index_len(t.arena);
            pools = tv_pools(t.arena);
            if (g != 0)
                lmx_graph_close(g);
            tv_close(&t);
            if (built != count) {
                fprintf(stderr, "tv-real: %s built %.0f of %.0f\n", tv_kind_names[kind], (double) built, (double) count);
                free(samples);
                free(totals);
                return 1;
            }
            totals[r] = (double) (t1 - t0) * tv_tick_ns / 1e6;
            samples[r] = (double) (t1 - t0) * tv_tick_ns / (double) count;
        }
        tv_stats(samples, o->create_reps, &median, &low, &high);
        tv_row("4", "create", tv_kind_names[kind], 0U, ranges, pools, 0U, count, o->create_reps, median, low, high,
               "ns/obj");
        tv_stats(totals, o->create_reps, &median, &low, &high);
        tv_row("4", "create_total", tv_kind_names[kind], 0U, ranges, pools, 0U, count, o->create_reps, median, low, high,
               "ms");
    }
    free(samples);
    free(totals);
    return 0;
}

/* ---- the generated program's entries the driver links against ----------------------------------------------------- */

/* Every emitted p.c defines these four; driver.o has them undefined (nm -u).  The bench is a program with no graph and
 * no qualified roots, as an emitted p.c without them answers (e1_const_index p.c: qualified count 0, at 0).  The driver
 * calls l2_program_build only from a host launch, which the bench never makes; refusing it keeps a launch from
 * pretending to build. */
Lmx * l2_program_graph(void);
size_t l2_program_qualified_count(void);
Lmx * l2_program_qualified_at(size_t index);
int l2_program_build(LmxArena * arena, Lmx * graph, Lmx * settings);

Lmx * l2_program_graph(void)
{
    return 0;
}

size_t l2_program_qualified_count(void)
{
    return 0U;
}

Lmx * l2_program_qualified_at(size_t index)
{
    (void) index;
    return 0;
}

int l2_program_build(LmxArena * arena, Lmx * graph, Lmx * settings)
{
    (void) arena;
    (void) graph;
    (void) settings;
    return 1;
}

/* ---- main (renamed to l2_generated_main by -Dmain=l2_generated_main) ---------------------------------------------- */

int main(int argc, char ** argv)
{
    TvOptions o;
    const char * mode;
    char line[512];
    int status = 0;
    tv_defaults(&o);
    if (argc < 2) {
        fputs("usage: <bench> 0 -- sizes|classify|slot|mem|create|all [key=value ...] (README.md)\n", stderr);
        return 2;
    }
    mode = argv[1];
    if (tv_parse(&o, argc, argv) != 0)
        return 2;
#if TV_WRAP
    tv_track_want = o.track;
#endif
    tv_rand_state = o.seed;
    tv_clock_open();
    tv_pin(&o);
    if (o.out != 0) {
        tv_file = fopen(o.out, "a");
        if (tv_file == 0) {
            fprintf(stderr, "tv-real: cannot open %s\n", o.out);
            return 2;
        }
    }
    snprintf(line, sizeof line, "#tv-real\tmode=%s\tbuild=%s\tR=%.0f\tCR=%.0f\tcalls=%.0f\tstructs=%.0f\tK=%.0f\tKN=%.0f"
             "\tints=%.0f\tcstructs=%.0f\tptrtype=%d\tcpu=%ld\ttick_ns=%.3f\n", mode, TV_WRAP ? "mem" : "time",
             (double) o.reps, (double) o.create_reps, (double) o.calls, (double) o.structs, (double) o.k,
             (double) o.k_named, (double) o.ints, (double) o.create_structs, o.ptr_type, o.cpu, tv_tick_ns);
    tv_emit(line);
    tv_emit("#item\tmetric\tvariant\tn_target\tn_ranges\tpools\tfields\tcount\treps\tmedian\tmin\tmax\tunit\n");
    if (strcmp(mode, "sizes") == 0 || strcmp(mode, "all") == 0)
        status = status != 0 ? status : tv_item0();
    if (strcmp(mode, "classify") == 0 || strcmp(mode, "all") == 0)
        status = status != 0 ? status : tv_item1(&o);
    if (strcmp(mode, "slot") == 0 || strcmp(mode, "all") == 0)
        status = status != 0 ? status : tv_item2(&o);
    if (strcmp(mode, "mem") == 0 || strcmp(mode, "all") == 0)
        status = status != 0 ? status : tv_item3(&o);
    if (strcmp(mode, "create") == 0 || strcmp(mode, "all") == 0)
        status = status != 0 ? status : tv_item4(&o);
    snprintf(line, sizeof line, "#checksum\t%.0f\n#tv-real done status=%d\n", (double) tv_sink, status);
    tv_emit(line);
    if (tv_file != 0)
        fclose(tv_file);
    return status;
}
