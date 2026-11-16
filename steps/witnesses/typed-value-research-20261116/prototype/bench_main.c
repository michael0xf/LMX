/* bench_main.c -- the common benchmark and selftest driver of the TypedValue research prototype.
 *
 * One executable per representation:  gcc ... -DREP=<name> bench_main.c  (see build.sh).  The logical graph, the access
 * order (one PRNG per seed) and every check are identical in all representations; only the header chosen by REP differs.
 *
 *   bench [--straddle] t1  <nstruct> <nfields> <passes> <R> <seed>             known-type read-modify-write of int fields
 *   bench [--straddle] t1w <nstruct> <nfields> <passes> <R> <seed>             same with double / size_t fields
 *   bench [--straddle] t2  <nstruct> <nfields> <passes> <R> <seed>             dynamic read (t2a) and expected-type read (t2b)
 *   bench [--straddle] t3  <nstruct> <nfields> <nchain> <steps> <passes> <R> <seed>   sequential fields (t3a), chase (t3b)
 *   bench [--straddle] t3w <nstruct> <nfields> <nchain> <steps> <passes> <R> <seed>   same over double / size_t fields
 *   bench [--straddle] t4  <nstruct> <passes> <R> <seed>                       alias write / replace with another type
 *   bench [--straddle] t5  <nnodes> <fanout> <R> <seed>                        build, graph_copy, gc_mark (three rows)
 *   bench [--straddle] t6  <n> <passes> <R> <seed>                             control: dense Array<int> and C locals
 *   bench selftest                                                             text protocol, diff-compared across reps
 *
 * --straddle: tv_packed only -- every 12-byte record is placed so that its 8-byte content crosses a 64-byte line.
 * Output: one TSV line per measurement:
 *   rep test params ops R median_ns/op min_ns/op max_ns/op bytes_live checksum fill   (fill: padding share of the stream, or -)
 */
#include "common.h"
#include "rep_select.h"

/* =============================================================================================================== */
/* harness                                                                                                          */
/* =============================================================================================================== */

typedef uint64_t (*KernelFn)(void *ctx);

static int cmp_double(const void *x, const void *y)
{
    double a = *(const double *)x;
    double b = *(const double *)y;
    return (a > b) - (a < b);
}

/* last TSV column: the share of padding / holes / fillers in the stream (representations with REP_HAS_FILL), else "-" */
static const char *fill_text(Arena *a, char *buf)
{
#if defined(REP_HAS_FILL)
    FillStats f;
    fill_stats(a, &f);
    if (f.stream > 0) {
        double waste = (double)(f.stream - f.net - f.raw);
        sprintf(buf, "fill=%.1f%%", 100.0 * waste / (double)f.stream);
        return buf;
    }
#else
    (void)a;
#endif
    strcpy(buf, "-");
    return buf;
}

static void emit_row(const char *test, const char *params, size_t ops, int R, double *t, size_t live, uint64_t sum,
                     const char *extra)
{
    qsort(t, (size_t)R, sizeof(double), cmp_double);
    printf("%s\t%s\t%s\t%llu\t%d\t%.3f\t%.3f\t%.3f\t%llu\t%016llx\t%s\n", REP_NAME, test, params, (unsigned long long)ops, R,
           t[R / 2], t[0], t[R - 1], (unsigned long long)live, (unsigned long long)sum, extra);
    fflush(stdout);
}

static void report(const char *test, const char *params, size_t ops, int R, KernelFn fn, void *ctx, Arena *a)
{
    double *t = (double *)xmalloc((size_t)R * sizeof(double));
    uint64_t sum = 0;
    int i;
    for (i = 0; i < R; i++) {
        uint64_t t0 = now_ns();
        uint64_t c = fn(ctx);
        uint64_t t1 = now_ns();
        sum += c;
        t[i] = (double)(t1 - t0) / (double)ops;
    }
    {
        char fb[48];
        emit_row(test, params, ops, R, t, bytes_live(a), sum, fill_text(a, fb));
    }
    free(t);
}

static unsigned long long argu(const char *s)
{
    return strtoull(s, NULL, 10);
}

/* =============================================================================================================== */
/* data sets                                                                                                        */
/* =============================================================================================================== */

typedef struct TargetVec {
    void **v;
    size_t n;
    size_t cap;
} TargetVec;

static void tv_push(TargetVec *t, void *p)
{
    if (t->n == t->cap) {
        t->cap = t->cap ? t->cap * 2 : 1024;
        t->v = (void **)xrealloc(t->v, t->cap * sizeof(void *));
    }
    t->v[t->n++] = p;
}

/* ns Structures of nf int fields */
static void build_ints(Arena *a, size_t ns, size_t nf, Rng *r, void **S)
{
    size_t i;
    size_t j;
    for (i = 0; i < ns; i++) {
        void **sl;
        S[i] = new_struct(a, nf, NULL);
        sl = slots(S[i]);
        for (j = 0; j < nf; j++) {
            sl[j] = new_int(a, (int)rng_below(r, 1000));
        }
    }
}

/* ns Structures of nf wide fields: even index double, odd index size_t */
static void build_wide(Arena *a, size_t ns, size_t nf, Rng *r, void **S)
{
    size_t i;
    size_t j;
    for (i = 0; i < ns; i++) {
        void **sl;
        S[i] = new_struct(a, nf, NULL);
        sl = slots(S[i]);
        for (j = 0; j < nf; j++) {
            if (j & 1) {
                sl[j] = new_size(a, (size_t)rng_below(r, 100000));
            } else {
                sl[j] = new_real(a, (double)rng_below(r, 1000));
            }
        }
    }
}

/* ns Structures of nf fields of mixed types: int, double, size_t, reference, nested Structure, uninit:int */
static void build_mixed(Arena *a, size_t ns, size_t nf, Rng *r, void **S)
{
    TargetVec tg;
    size_t i;
    size_t j;
    memset(&tg, 0, sizeof(tg));
    for (i = 0; i < ns; i++) {
        void **sl;
        S[i] = new_struct(a, nf, NULL);
        sl = slots(S[i]);
        for (j = 0; j < nf; j++) {
            uint32_t roll = rng_below(r, 100);
            if (roll < 30) {
                void *c = new_int(a, (int)rng_below(r, 1000));
                tv_push(&tg, c);
                sl[j] = c;
            } else if (roll < 50) {
                sl[j] = new_real(a, (double)rng_below(r, 1000));
            } else if (roll < 60) {
                sl[j] = new_size(a, (size_t)rng_below(r, 100000));
            } else if (roll < 75) {
                void *target;
                if (tg.n == 0) {
                    target = new_int(a, (int)rng_below(r, 1000));
                    tv_push(&tg, target);
                } else {
                    target = tg.v[rng_below(r, (uint32_t)tg.n)];
                }
                sl[j] = new_refcell(a, target);
            } else if (roll < 85) {
                void *nested = new_struct(a, 2, S[i]);
                slots(nested)[0] = new_int(a, (int)rng_below(r, 1000));
                slots(nested)[1] = new_int(a, (int)rng_below(r, 1000));
                sl[j] = nested;
            } else {
                void *u = new_uninit_int(a);
                uninit_set(u, (int)rng_below(r, 1000));
                sl[j] = u;
            }
        }
    }
    free(tg.v);
}

static uint32_t *identity_perm(size_t n)
{
    uint32_t *p = (uint32_t *)xmalloc(n * sizeof(uint32_t));
    size_t i;
    for (i = 0; i < n; i++) {
        p[i] = (uint32_t)i;
    }
    return p;
}

/* the value of a field whose type was read at run time; one level of indirection for references */
static inline uint64_t read_dyn(Arena *a, void *h, int t)
{
    switch (t) {
    case T_INT:
        return (uint32_t)int_get(h);
    case T_REAL:
        return (uint64_t)(int64_t)real_get(h);
    case T_SIZE:
        return (uint64_t)size_get(h);
    case T_REF: {
        void *tg = ref_get(h);
        int tt = type_of_ref(a, tg);
        return (tt == T_INT) ? (uint64_t)(uint32_t)int_get(tg) + 11u : 3u;
    }
    case T_STRUCT:
        return (uint64_t)length(h) * 5u + (uint32_t)int_get(slots(h)[0]);
    case T_UNINIT_INT:
        return (uint64_t)(uint32_t)uninit_get(h) + 7u;
    default:
        return 0xBADu;
    }
}

/* =============================================================================================================== */
/* T1: known-type read-modify-write through a ready index map; no tag check, no classification                      */
/* =============================================================================================================== */

typedef struct T1Ctx {
    void **S;
    const uint32_t *order;
    size_t nvis;
    const uint32_t *map;  /* int test: all fields; wide test: indices of the double fields */
    const uint32_t *map2; /* wide test: indices of the size_t fields */
    size_t nf;
    size_t nf2;
    size_t passes;
} T1Ctx;

static NOINLINE uint64_t t1_known_rw(void *vc)
{
    const T1Ctx *c = (const T1Ctx *)vc;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    size_t k;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->nvis; i++) {
            void **sl = slots(c->S[c->order[i]]);
            for (k = 0; k < c->nf; k++) {
                void *cell = sl[c->map[k]];
                int v = int_get(cell);
                sum += (uint32_t)v;
                int_set(cell, (int)((unsigned)v + (unsigned)k + 1u));
            }
        }
    }
    return sum;
}

static NOINLINE uint64_t t1w_known_rw(void *vc)
{
    const T1Ctx *c = (const T1Ctx *)vc;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    size_t k;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->nvis; i++) {
            void **sl = slots(c->S[c->order[i]]);
            for (k = 0; k < c->nf; k++) {
                void *cell = sl[c->map[k]];
                double v = real_get(cell);
                sum += (uint64_t)v;
                real_set(cell, v + (double)(k + 1));
            }
            for (k = 0; k < c->nf2; k++) {
                void *cell = sl[c->map2[k]];
                size_t v = size_get(cell);
                sum += (uint64_t)v;
                size_set(cell, v + k + 1u);
            }
        }
    }
    return sum;
}

static int run_t1(int wide, int argc, char **argv, int straddle)
{
    size_t ns, nf, passes;
    int R;
    Rng r;
    Arena *a;
    void **S;
    uint32_t *order;
    uint32_t *map;
    uint32_t *map2 = NULL;
    uint32_t *all;
    T1Ctx c;
    char pb[128];
    size_t i;
    if (argc != 5) {
        return 1;
    }
    ns = (size_t)argu(argv[0]);
    nf = (size_t)argu(argv[1]);
    passes = (size_t)argu(argv[2]);
    R = (int)argu(argv[3]);
    r.s = argu(argv[4]);
    if (wide && nf < 2) {
        nf = 2;
    }
    a = arena_new();
    set_straddle(a, straddle);
    S = (void **)xmalloc(ns * sizeof(void *));
    if (wide) {
        build_wide(a, ns, nf, &r, S);
    } else {
        build_ints(a, ns, nf, &r, S);
    }
    order = identity_perm(ns);
    shuffle_u32(&r, order, ns);
    all = identity_perm(nf);
    shuffle_u32(&r, all, nf);
    memset(&c, 0, sizeof(c));
    c.S = S;
    c.order = order;
    c.nvis = ns;
    c.passes = passes;
    if (wide) {
        size_t nr = 0;
        size_t nsz = 0;
        map = (uint32_t *)xmalloc(nf * sizeof(uint32_t));
        map2 = (uint32_t *)xmalloc(nf * sizeof(uint32_t));
        for (i = 0; i < nf; i++) {
            if (all[i] & 1u) {
                map2[nsz++] = all[i];
            } else {
                map[nr++] = all[i];
            }
        }
        c.nf = nr;
        c.nf2 = nsz;
    } else {
        map = all;
        c.nf = nf;
    }
    c.map = map;
    c.map2 = map2;
    sprintf(pb, "ns=%llu,nf=%llu,passes=%llu%s", (unsigned long long)ns, (unsigned long long)nf, (unsigned long long)passes,
            straddle ? ",straddle" : "");
    report(wide ? "t1w_known_rw" : "t1_known_rw", pb, ns * nf * passes, R, wide ? t1w_known_rw : t1_known_rw, &c, a);
    free(S);
    free(order);
    if (wide) {
        free(all);
    }
    free(map);
    if (map2 != NULL) {
        free(map2);
    }
    arena_free(a);
    return 0;
}

/* =============================================================================================================== */
/* T2: fields of mixed types read in pseudo-random order; the reader gets the actual type from the representation   */
/* =============================================================================================================== */

typedef struct T2Ctx {
    Arena *a;
    void **S;
    const uint32_t *os;
    const uint32_t *oj;
    const int *expected;
    size_t n;
    size_t passes;
} T2Ctx;

static NOINLINE uint64_t t2a_dyn_read(void *vc)
{
    const T2Ctx *c = (const T2Ctx *)vc;
    Arena *a = c->a;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->n; i++) {
            void *h = slots(c->S[c->os[i]])[c->oj[i]];
            int t = type_of_ref(a, h);
            sum += read_dyn(a, h, t);
        }
    }
    return sum;
}

static NOINLINE uint64_t t2b_expected_type(void *vc)
{
    const T2Ctx *c = (const T2Ctx *)vc;
    Arena *a = c->a;
    uint64_t sum = 0;
    uint64_t mismatches = 0;
    size_t p;
    size_t i;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->n; i++) {
            void *h = slots(c->S[c->os[i]])[c->oj[i]];
            int t = type_of_ref(a, h);
            if (t != c->expected[i]) {
                mismatches++;
                sum += 7777u * (uint64_t)t;
            } else {
                sum += read_dyn(a, h, t);
            }
        }
    }
    return sum ^ (mismatches << 40);
}

static int run_t2(int argc, char **argv, int straddle)
{
    size_t ns, nf, passes, n, i;
    int R;
    Rng r;
    Arena *a;
    void **S;
    uint32_t *pairs;
    uint32_t *os;
    uint32_t *oj;
    int *expected;
    T2Ctx c;
    char pb[128];
    if (argc != 5) {
        return 1;
    }
    ns = (size_t)argu(argv[0]);
    nf = (size_t)argu(argv[1]);
    passes = (size_t)argu(argv[2]);
    R = (int)argu(argv[3]);
    r.s = argu(argv[4]);
    a = arena_new();
    set_straddle(a, straddle);
    S = (void **)xmalloc(ns * sizeof(void *));
    build_mixed(a, ns, nf, &r, S);
    n = ns * nf;
    pairs = identity_perm(n);
    shuffle_u32(&r, pairs, n);
    os = (uint32_t *)xmalloc(n * sizeof(uint32_t));
    oj = (uint32_t *)xmalloc(n * sizeof(uint32_t));
    expected = (int *)xmalloc(n * sizeof(int));
    for (i = 0; i < n; i++) {
        void *h;
        int t;
        os[i] = (uint32_t)(pairs[i] / nf);
        oj[i] = (uint32_t)(pairs[i] % nf);
        h = slots(S[os[i]])[oj[i]];
        t = type_of_ref(a, h);
        expected[i] = (rng_below(&r, 1000) == 0) ? ((t == T_INT) ? T_REAL : T_INT) : t;
    }
    c.a = a;
    c.S = S;
    c.os = os;
    c.oj = oj;
    c.expected = expected;
    c.n = n;
    c.passes = passes;
    sprintf(pb, "ns=%llu,nf=%llu,passes=%llu%s", (unsigned long long)ns, (unsigned long long)nf, (unsigned long long)passes,
            straddle ? ",straddle" : "");
    report("t2a_dyn_read", pb, n * passes, R, t2a_dyn_read, &c, a);
    report("t2b_expected_type", pb, n * passes, R, t2b_expected_type, &c, a);
    free(S);
    free(pairs);
    free(os);
    free(oj);
    free(expected);
    arena_free(a);
    return 0;
}

/* =============================================================================================================== */
/* T3: a) sequential pass over all fields of the set; b) dependent chase through records placed in shuffled order    */
/* =============================================================================================================== */

typedef struct T3Ctx {
    Arena *a;
    void **S;
    size_t ns;
    size_t nf;
    size_t passes;
    void *start;
    size_t steps;
    int wide;
} T3Ctx;

static NOINLINE uint64_t t3a_seq_fields(void *vc)
{
    const T3Ctx *c = (const T3Ctx *)vc;
    Arena *a = c->a;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    size_t j;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->ns; i++) {
            void **sl = slots(c->S[i]);
            for (j = 0; j < c->nf; j++) {
                void *h = sl[j];
                int t = type_of_ref(a, h);
                sum += read_dyn(a, h, t);
            }
        }
    }
    return sum;
}

static NOINLINE uint64_t t3b_chase(void *vc)
{
    const T3Ctx *c = (const T3Ctx *)vc;
    Arena *a = c->a;
    uint64_t sum = 0;
    void *h = c->start;
    size_t s;
    for (s = 0; s < c->steps; s++) {
        void **sl = slots(h);
        void *idc = sl[1];
        sum += (uint64_t)type_of_ref(a, h);
        sum += c->wide ? (uint64_t)real_get(idc) : (uint64_t)(uint32_t)int_get(idc);
        h = sl[0];
    }
    return sum;
}

static int run_t3(int wide, int argc, char **argv, int straddle)
{
    size_t ns, nf, nchain, steps, passes;
    int R;
    Rng r;
    Arena *a;
    void **S;
    void **nodes;
    uint32_t *perm;
    T3Ctx c;
    char pb[160];
    size_t i;
    if (argc != 7) {
        return 1;
    }
    ns = (size_t)argu(argv[0]);
    nf = (size_t)argu(argv[1]);
    nchain = (size_t)argu(argv[2]);
    steps = (size_t)argu(argv[3]);
    passes = (size_t)argu(argv[4]);
    R = (int)argu(argv[5]);
    r.s = argu(argv[6]);
    if (nchain < 2) {
        nchain = 2;
    }
    if (wide && nf < 2) {
        nf = 2;
    }
    a = arena_new();
    set_straddle(a, straddle);
    S = (void **)xmalloc(ns * sizeof(void *));
    if (wide) {
        build_wide(a, ns, nf, &r, S);
    } else {
        build_mixed(a, ns, nf, &r, S);
    }
    /* chain nodes: Structure { [0] next node, [1] id cell }, allocated in order, linked in shuffled order */
    nodes = (void **)xmalloc(nchain * sizeof(void *));
    for (i = 0; i < nchain; i++) {
        nodes[i] = new_struct(a, 2, NULL);
        slots(nodes[i])[1] = wide ? new_real(a, (double)(i % 1000)) : new_int(a, (int)(i % 1000));
    }
    perm = identity_perm(nchain);
    shuffle_u32(&r, perm, nchain);
    for (i = 0; i < nchain; i++) {
        slots(nodes[perm[i]])[0] = nodes[perm[(i + 1) % nchain]];
    }
    memset(&c, 0, sizeof(c));
    c.a = a;
    c.S = S;
    c.ns = ns;
    c.nf = nf;
    c.passes = passes;
    c.start = nodes[perm[0]];
    c.steps = steps;
    c.wide = wide;
    sprintf(pb, "ns=%llu,nf=%llu,passes=%llu%s", (unsigned long long)ns, (unsigned long long)nf, (unsigned long long)passes,
            straddle ? ",straddle" : "");
    report(wide ? "t3wa_seq_fields" : "t3a_seq_fields", pb, ns * nf * passes, R, t3a_seq_fields, &c, a);
    sprintf(pb, "nchain=%llu,steps=%llu%s", (unsigned long long)nchain, (unsigned long long)steps, straddle ? ",straddle" : "");
    report(wide ? "t3wb_chase" : "t3b_chase", pb, steps, R, t3b_chase, &c, a);
    free(S);
    free(nodes);
    free(perm);
    arena_free(a);
    return 0;
}

/* =============================================================================================================== */
/* T4: two slots on one cell: write through one, read through the other; then replace the reference with a cell of    */
/* ANOTHER type and read the current content with its type                                                          */
/* =============================================================================================================== */

typedef struct T4Ctx {
    Arena *a;
    void **S;
    void **ic;
    void **rc;
    const uint32_t *order;
    size_t n;
    size_t passes;
} T4Ctx;

static NOINLINE uint64_t t4_alias_replace(void *vc)
{
    const T4Ctx *c = (const T4Ctx *)vc;
    Arena *a = c->a;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->n; i++) {
            uint32_t k = c->order[i];
            void **sl = slots(c->S[k]);
            int t;
            uint32_t w = (uint32_t)(sum >> 3) + k;
            int wi = (int)(w & 0xFFFFu);
            int v;
            int_set(sl[0], wi);
            v = int_get(sl[1]);
            sum += (uint32_t)v;
            if (v != wi) {
                sum += 1000003u;
            }
            sl[0] = c->rc[k];
            t = type_of_ref(a, sl[0]);
            sum += (t == T_REAL) ? (uint64_t)real_get(sl[0]) : 1000033u * (uint64_t)t;
            sl[0] = c->ic[k];
        }
    }
    return sum;
}

/* wide variant: the aliased cell is a double, the replacement a size_t */
static NOINLINE uint64_t t4w_alias_replace(void *vc)
{
    const T4Ctx *c = (const T4Ctx *)vc;
    Arena *a = c->a;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->n; i++) {
            uint32_t k = c->order[i];
            void **sl = slots(c->S[k]);
            int t;
            uint32_t w = (uint32_t)(sum >> 3) + k;
            double wd = (double)(w & 0xFFFFu);
            double v;
            real_set(sl[0], wd);
            v = real_get(sl[1]);
            sum += (uint64_t)v;
            if (v != wd) {
                sum += 1000003u;
            }
            sl[0] = c->rc[k];
            t = type_of_ref(a, sl[0]);
            sum += (t == T_SIZE) ? (uint64_t)size_get(sl[0]) : 1000033u * (uint64_t)t;
            sl[0] = c->ic[k];
        }
    }
    return sum;
}

static int run_t4(int wide, int argc, char **argv, int straddle)
{
    size_t ns, passes, i;
    int R;
    Rng r;
    Arena *a;
    T4Ctx c;
    uint32_t *order;
    char pb[128];
    if (argc != 4) {
        return 1;
    }
    ns = (size_t)argu(argv[0]);
    passes = (size_t)argu(argv[1]);
    R = (int)argu(argv[2]);
    r.s = argu(argv[3]);
    a = arena_new();
    set_straddle(a, straddle);
    c.a = a;
    c.S = (void **)xmalloc(ns * sizeof(void *));
    c.ic = (void **)xmalloc(ns * sizeof(void *));
    c.rc = (void **)xmalloc(ns * sizeof(void *));
    for (i = 0; i < ns; i++) {
        c.S[i] = new_struct(a, 2, NULL);
        if (wide) {
            c.ic[i] = new_real(a, (double)rng_below(&r, 1000));
            c.rc[i] = new_size(a, (size_t)rng_below(&r, 100000));
        } else {
            c.ic[i] = new_int(a, (int)rng_below(&r, 1000));
            c.rc[i] = new_real(a, (double)rng_below(&r, 1000));
        }
        slots(c.S[i])[0] = c.ic[i];
        slots(c.S[i])[1] = c.ic[i];
    }
    order = identity_perm(ns);
    shuffle_u32(&r, order, ns);
    c.order = order;
    c.n = ns;
    c.passes = passes;
    sprintf(pb, "ns=%llu,passes=%llu%s", (unsigned long long)ns, (unsigned long long)passes, straddle ? ",straddle" : "");
    report(wide ? "t4w_alias_replace" : "t4_alias_replace", pb, ns * passes, R, wide ? t4w_alias_replace : t4_alias_replace,
           &c, a);
    free(c.S);
    free(c.ic);
    free(c.rc);
    free(order);
    arena_free(a);
    return 0;
}

/* =============================================================================================================== */
/* T7: the arbitrary-address API on slot values (record starts / cell addresses) in shuffled order                    */
/* =============================================================================================================== */

typedef struct T7Ctx {
    Arena *a;
    void **hs;
    size_t n;
    size_t passes;
} T7Ctx;

static NOINLINE uint64_t t7_type_of_address(void *vc)
{
    const T7Ctx *c = (const T7Ctx *)vc;
    Arena *a = c->a;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->n; i++) {
            sum += (uint64_t)type_of_address(a, c->hs[i]);
        }
    }
    return sum;
}

static int run_t7(int argc, char **argv, int straddle)
{
    size_t ns, nf, passes, n, i, j, k;
    int R;
    Rng r;
    Arena *a;
    void **S;
    void **hs;
    uint32_t *perm;
    T7Ctx c;
    char pb[128];
    if (argc != 5) {
        return 1;
    }
    ns = (size_t)argu(argv[0]);
    nf = (size_t)argu(argv[1]);
    passes = (size_t)argu(argv[2]);
    R = (int)argu(argv[3]);
    r.s = argu(argv[4]);
    a = arena_new();
    set_straddle(a, straddle);
    S = (void **)xmalloc(ns * sizeof(void *));
    build_mixed(a, ns, nf, &r, S);
    n = ns * (nf + 1);
    hs = (void **)xmalloc(n * sizeof(void *));
    k = 0;
    for (i = 0; i < ns; i++) {
        hs[k++] = S[i];
        for (j = 0; j < nf; j++) {
            hs[k++] = slots(S[i])[j];
        }
    }
    perm = identity_perm(n);
    shuffle_u32(&r, perm, n);
    {
        void **shuffled = (void **)xmalloc(n * sizeof(void *));
        for (i = 0; i < n; i++) {
            shuffled[i] = hs[perm[i]];
        }
        free(hs);
        hs = shuffled;
    }
    c.a = a;
    c.hs = hs;
    c.n = n;
    c.passes = passes;
    sprintf(pb, "ns=%llu,nf=%llu,passes=%llu%s", (unsigned long long)ns, (unsigned long long)nf, (unsigned long long)passes,
            straddle ? ",straddle" : "");
    report("t7_type_of_address", pb, n * passes, R, t7_type_of_address, &c, a);
    free(S);
    free(hs);
    free(perm);
    arena_free(a);
    return 0;
}

/* =============================================================================================================== */
/* T5: build a graph (tree of Structures with int / double leaves, ~10% shared targets, cycles through parent links   */
/* and reference cells), copy it, mark it                                                                            */
/* =============================================================================================================== */

typedef struct QItem {
    void *node;
    void *parent;
} QItem;

static void *build_graph(Arena *a, size_t nnodes, uint32_t fan, Rng *r)
{
    QItem *q = (QItem *)xmalloc(nnodes * sizeof(QItem));
    size_t qh = 0;
    size_t qt = 0;
    size_t created = 1;
    TargetVec share;
    void *root;
    memset(&share, 0, sizeof(share));
    root = new_struct(a, fan, NULL);
    q[qt].node = root;
    q[qt].parent = NULL;
    qt++;
    while (qh < qt) {
        QItem it = q[qh++];
        void **sl = slots(it.node);
        uint32_t j;
        for (j = 0; j < fan; j++) {
            uint32_t roll = rng_below(r, 100);
            if (roll < 10 && share.n > 0) {
                sl[j] = share.v[rng_below(r, (uint32_t)share.n)];
            } else if (roll < 15) {
                void *target = (rng_below(r, 2) == 0 || it.parent == NULL) ? it.node : it.parent;
                sl[j] = new_refcell(a, target);
            } else if (created < nnodes && (qh == qt || rng_below(r, 100) < 40)) { /* qh == qt: never let the tree die out */
                void *child = new_struct(a, fan, it.node);
                q[qt].node = child;
                q[qt].parent = it.node;
                qt++;
                created++;
                sl[j] = child;
                if ((created & 3u) == 0) {
                    tv_push(&share, child);
                }
            } else {
                void *leaf;
                uint32_t kind = rng_below(r, 8);
                if (kind == 0) {
                    leaf = new_size(a, (size_t)rng_below(r, 100000));
                } else if (kind < 4) {
                    leaf = new_real(a, (double)rng_below(r, 1000));
                } else {
                    leaf = new_int(a, (int)rng_below(r, 1000));
                }
                sl[j] = leaf;
                if ((rng_below(r, 4)) == 0) {
                    tv_push(&share, leaf);
                }
            }
        }
    }
    free(q);
    free(share.v);
    return root;
}

static int run_t5(int argc, char **argv, int straddle)
{
    size_t nnodes;
    uint32_t fan;
    int R;
    Rng r;
    Arena *src;
    void *root;
    size_t marked;
    uint64_t dsrc;
    double *t;
    char pb[128];
    int i;
    if (argc != 4) {
        return 1;
    }
    nnodes = (size_t)argu(argv[0]);
    fan = (uint32_t)argu(argv[1]);
    R = (int)argu(argv[2]);
    r.s = argu(argv[3]);
    if (nnodes < 1) {
        nnodes = 1;
    }
    sprintf(pb, "nodes=%llu,fan=%llu%s", (unsigned long long)nnodes, (unsigned long long)fan, straddle ? ",straddle" : "");
    t = (double *)xmalloc((size_t)R * sizeof(double));

    /* build: R fresh arenas; the last one is kept as the copy source */
    src = NULL;
    root = NULL;
    for (i = 0; i < R; i++) {
        Rng rr;
        uint64_t t0;
        uint64_t t1;
        Arena *x;
        rr.s = r.s;
        if (src != NULL) {
            arena_free(src);
        }
        x = arena_new();
        set_straddle(x, straddle);
        t0 = now_ns();
        root = build_graph(x, nnodes, fan, &rr);
        t1 = now_ns();
        src = x;
        t[i] = (double)(t1 - t0) / (double)nnodes;
    }
    marked = gc_mark(src, root);
    dsrc = graph_digest(src, root);
    {
        char fb[48];
        emit_row("t5_build", pb, nnodes, R, t, bytes_live(src), dsrc ^ (uint64_t)marked, fill_text(src, fb));
    }

    /* copy */
    {
        Arena *dst = NULL;
        void *droot = NULL;
        uint64_t ddst = 0;
        size_t dmarked = 0;
        for (i = 0; i < R; i++) {
            uint64_t t0;
            uint64_t t1;
            Arena *x;
            if (dst != NULL) {
                arena_free(dst);
            }
            x = arena_new();
            set_straddle(x, straddle);
            t0 = now_ns();
            droot = graph_copy(x, src, root);
            t1 = now_ns();
            dst = x;
            t[i] = (double)(t1 - t0) / (double)marked;
        }
        ddst = graph_digest(dst, droot);
        dmarked = gc_mark(dst, droot);
        if (ddst != dsrc || dmarked != marked) {
            fprintf(stderr, "t5: graph_copy is not isomorphic (digest %016llx vs %016llx, marked %llu vs %llu)\n",
                    (unsigned long long)ddst, (unsigned long long)dsrc, (unsigned long long)dmarked,
                    (unsigned long long)marked);
            return 3;
        }
        {
            char fb[48];
            emit_row("t5_copy", pb, marked, R, t, bytes_live(dst), ddst ^ (uint64_t)dmarked, fill_text(dst, fb));
        }
        arena_free(dst);
    }

    /* mark */
    {
        size_t cnt = 0;
        for (i = 0; i < R; i++) {
            uint64_t t0 = now_ns();
            uint64_t t1;
            cnt = gc_mark(src, root);
            t1 = now_ns();
            t[i] = (double)(t1 - t0) / (double)marked;
        }
        {
            char fb[48];
            emit_row("t5_gc_mark", pb, marked, R, t, bytes_live(src), (uint64_t)cnt, fill_text(src, fb));
        }
    }
    free(t);
    arena_free(src);
    return 0;
}

/* =============================================================================================================== */
/* T6: control -- a dense Array<int> through array_int_data and a loop over ordinary C locals; the same everywhere   */
/* =============================================================================================================== */

typedef struct T6Ctx {
    void *A;
    size_t n;
    size_t passes;
} T6Ctx;

static NOINLINE uint64_t t6_array_sum(void *vc)
{
    const T6Ctx *c = (const T6Ctx *)vc;
    const int *d = array_int_data(c->A);
    uint64_t sum = 0;
    size_t p;
    size_t i;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->n; i++) {
            sum += (uint32_t)d[i] ^ (uint32_t)p;
        }
    }
    return sum;
}

static NOINLINE uint64_t t6_locals(void *vc)
{
    const T6Ctx *c = (const T6Ctx *)vc;
    uint32_t x = (uint32_t)c->n;
    uint64_t sum = 0;
    size_t p;
    size_t i;
    for (p = 0; p < c->passes; p++) {
        for (i = 0; i < c->n; i++) {
            x = x * 1664525u + 1013904223u;
            sum += x >> 16;
        }
    }
    return sum;
}

static int run_t6(int argc, char **argv, int straddle)
{
    size_t n, passes, i;
    int R;
    Rng r;
    Arena *a;
    T6Ctx c;
    int *d;
    char pb[96];
    if (argc != 4) {
        return 1;
    }
    n = (size_t)argu(argv[0]);
    passes = (size_t)argu(argv[1]);
    R = (int)argu(argv[2]);
    r.s = argu(argv[3]);
    a = arena_new();
    set_straddle(a, straddle);
    c.A = new_array_int(a, n);
    c.n = n;
    c.passes = passes;
    d = array_int_data(c.A);
    for (i = 0; i < n; i++) {
        d[i] = (int)rng_below(&r, 1000);
    }
    sprintf(pb, "n=%llu,passes=%llu", (unsigned long long)n, (unsigned long long)passes);
    report("t6_array_sum", pb, n * passes, R, t6_array_sum, &c, a);
    report("t6_locals", pb, n * passes, R, t6_locals, &c, a);
    arena_free(a);
    return 0;
}

/* =============================================================================================================== */
/* selftest: one text protocol for every representation (no addresses are printed); diff the outputs                  */
/* =============================================================================================================== */

/* representations whose type_of_address is defined for record starts only (tv_word, tv_packed without the map) print n/a for
 * content addresses, dense-array elements and inner bytes: the other lines of the protocol stay identical everywhere */
static void show_interior(const char *name, int v)
{
    if (REP_INTERIOR_ADDR) {
        printf("%s: %d\n", name, v);
    } else {
        printf("%s: n/a\n", name);
    }
}

static void selftest(void)
{
    Arena *a = arena_new();
    Arena *b;
    void *c;
    void *S;
    void *rl;
    void *u;
    void *A;
    void *AR;
    void *child;
    int ext = 0;
    void *addr0;
    int i;

    printf("protocol: tv-research-selftest-1\n");

    /* 1. a write through one slot is seen through the alias */
    c = new_int(a, 5);
    S = new_struct(a, 2, NULL);
    slots(S)[0] = c;
    slots(S)[1] = c;
    int_set(slots(S)[0], 42);
    printf("alias_write_seen_by_other_slot: %d\n", int_get(slots(S)[1]));
    printf("alias_type_slot0: %d\n", type_of_ref(a, slots(S)[0]));
    printf("alias_type_slot1: %d\n", type_of_ref(a, slots(S)[1]));

    /* 2. replacing the reference in a slot does not inherit the type of the previous content */
    rl = new_real(a, 2.5);
    slots(S)[0] = rl;
    printf("replace_slot0_type: %d\n", type_of_ref(a, slots(S)[0]));
    printf("replace_slot0_value_x2: %d\n", (int)(real_get(slots(S)[0]) * 2.0));
    printf("replace_slot1_type: %d\n", type_of_ref(a, slots(S)[1]));
    printf("replace_slot1_value: %d\n", int_get(slots(S)[1]));
    real_set(rl, 7.0);
    printf("replace_slot0_after_write_type_value: %d %d\n", type_of_ref(a, slots(S)[0]), (int)real_get(slots(S)[0]));

    /* 3. uninit:int stays uninit:int after writes; the address of its int cell does not change */
    u = new_uninit_int(a);
    addr0 = uninit_ref(u);
    printf("uninit_slot_type_before: %d\n", type_of_ref(a, u));
    printf("uninit_cell_type_before: %d\n", type_of_address(a, uninit_ref(u)));
    uninit_set(u, 7);
    uninit_set(u, 9);
    printf("uninit_slot_type_after: %d\n", type_of_ref(a, u));
    printf("uninit_cell_type_after: %d\n", type_of_address(a, uninit_ref(u)));
    printf("uninit_cell_address_stable: %d\n", uninit_ref(u) == addr0);
    printf("uninit_value: %d\n", uninit_get(u));

    /* 4. type_of_address: null, external, content, dense array element, inner byte */
    A = new_array_int(a, 8);
    for (i = 0; i < 8; i++) {
        array_int_data(A)[i] = i * i;
    }
    AR = new_array_ref(a, 4);
    printf("tya_null: %d\n", type_of_address(a, NULL));
    printf("tya_external: %d\n", type_of_address(a, &ext));
    printf("tya_slot_int: %d\n", type_of_address(a, c));
    printf("tya_slot_real: %d\n", type_of_address(a, rl));
    printf("tya_slot_struct: %d\n", type_of_address(a, S));
    printf("tya_slot_uninit: %d\n", type_of_address(a, u));
    show_interior("tya_int_content", type_of_address(a, int_addr(c)));
    show_interior("tya_array_elem3", type_of_address(a, array_int_data(A) + 3));
    show_interior("tya_array_elem7", type_of_address(a, array_int_data(A) + 7));
    show_interior("tya_array_ref_elem1", type_of_address(a, array_ref_data(AR) + 1));
    show_interior("tya_inner_byte_of_int", type_of_address(a, (const char *)int_addr(c) + 1));
    show_interior("tya_inner_byte_of_array_elem", type_of_address(a, (const char *)(array_int_data(A) + 2) + 2));
    printf("type_of_ref_array: %d %d\n", type_of_ref(a, A), type_of_ref(a, AR));
    printf("type_of_ref_struct: %d\n", type_of_ref(a, S));

    /* 5. a mismatch with the expected type is detected */
    printf("expect_real_on_int_detected: %d\n", type_of_ref(a, c) != T_REAL);
    printf("expect_int_on_int_ok: %d\n", type_of_ref(a, c) == T_INT);

    /* 6. a dense array stays dense */
    printf("array_elem_size: %d\n", (int)sizeof(*array_int_data(A)));
    printf("array_stride_bytes: %d\n", (int)((const char *)(array_int_data(A) + 1) - (const char *)array_int_data(A)));
    printf("array_length: %d\n", (int)length(A));
    printf("array_values: %d %d %d\n", array_int_data(A)[0], array_int_data(A)[5], array_int_data(A)[7]);

    /* 7. Structure shape and parent link */
    child = new_struct(a, 3, S);
    printf("struct_length: %d %d\n", (int)length(S), (int)length(child));
    printf("child_parent_is_S: %d\n", parent_key(child) == lmx_key(S));
    printf("S_parent_null: %d\n", parent_key(S) == NULL);
    printf("child_slots_zero: %d\n", slots(child)[0] == NULL && slots(child)[2] == NULL);

    /* 7b. the observable results pinned by tests/graph/typeof.lm2 and struct_index.lm2, one line per item */
    {
        void *vi = new_int(a, 5);          /* int: i 5 */
        void *vp = vi;                     /* @: p int @i -- the reference value @i is the handle of i */
        void *vu = new_uninit_int(a);      /* int: u */
        void *at_u = uninit_ref(vu);       /* @u */
        void *vj = new_int(a, 40);         /* int: j 40 */
        void *vS = new_struct(a, 3, NULL); /* S: int: a 1; int: u; N(int: x 7) */
        void *vN = new_struct(a, 1, vS);
        void *vh = vS;                     /* @: h Box -- a reference to the Structure */
        void *vq;
        slots(vN)[0] = new_int(a, 7);
        slots(vS)[0] = new_int(a, 1);
        slots(vS)[1] = vu;
        slots(vS)[2] = vN;
        printf("fx_typeof_at_i: %d\n", type_of_address(a, vi));
        printf("fx_typeof_p: %d\n", type_of_address(a, vp));
        printf("fx_deref_p: %d\n", int_get(vp));
        printf("fx_typeof_at_u: %d\n", type_of_address(a, at_u));
        printf("fx_typeof_slot_u: %d\n", type_of_address(a, slots(vS)[1]));
        uninit_set(vu, 5);
        printf("fx_typeof_at_u_after_write: %d\n", type_of_address(a, uninit_ref(vu)));
        printf("fx_typeof_slot_u_after_write: %d\n", type_of_address(a, slots(vS)[1]));
        printf("fx_at_u_same_address: %d\n", uninit_ref(vu) == at_u);
        printf("fx_read_through_saved_at_u: %d\n", int_get(at_u));
        printf("fx_typeof_S: %d\n", type_of_address(a, vS));
        printf("fx_typeof_h: %d\n", type_of_address(a, vh));
        printf("fx_typeof_null: %d\n", type_of_address(a, NULL));
        printf("fx_length_S_nested: %d %d\n", (int)length(vS), (int)length(slots(vS)[2]));
        printf("fx_typeof_nested: %d\n", type_of_address(a, slots(vS)[2]));
        printf("fx_nested_x: %d\n", int_get(slots(slots(vS)[2])[0]));
        slots(vS)[0] = vj;                 /* S[0] := @j */
        vq = slots(vS)[0];                 /* @: q int S[0] */
        printf("fx_q_reads_j: %d\n", int_get(vq));
        slots(vS)[1] = slots(vS)[0];       /* S[1] := S[0] */
        printf("fx_typeof_S1_after_assign: %d\n", type_of_address(a, slots(vS)[1]));
        printf("fx_length_S_after: %d\n", (int)length(vS));
        printf("fx_x_after: %d\n", int_get(slots(slots(vS)[2])[0]));
        {
            void *S2 = new_struct(a, 2, NULL); /* a slot that holds @u next to the slot that holds u: the collector must cope */
            slots(S2)[0] = vu;
            slots(S2)[1] = at_u;
            printf("gc_with_at_u_in_slot_ok: %d\n", gc_mark(a, S2) >= 2);
        }
    }

    /* 8. gc_mark / graph_copy over a graph with a shared target, a reference-cell cycle and a parent link */
    {
        void *x = new_int(a, 3);
        void *root = new_struct(a, 4, NULL);
        void *rc;
        void *ch = new_struct(a, 2, root);
        void *droot;
        void *dch;
        size_t m1;
        size_t m2;
        size_t m3;
        slots(root)[0] = x;
        slots(root)[1] = x;
        rc = new_refcell(a, root);
        slots(root)[2] = rc;
        slots(root)[3] = ch;
        slots(ch)[0] = x;
        slots(ch)[1] = new_real(a, 1.5);
        b = arena_new();
        m1 = gc_mark(a, root);
        droot = graph_copy(b, a, root);
        m2 = gc_mark(b, droot);
        m3 = gc_mark(a, root);
        printf("gc_marked_src_dst_again: %d %d %d\n", (int)m1, (int)m2, (int)m3);
        printf("digest_equal: %d\n", graph_digest(a, root) == graph_digest(b, droot));
        dch = slots(droot)[3];
        printf("copy_shared_target_preserved: %d\n", slots(droot)[0] == slots(droot)[1]);
        printf("copy_shared_across_structures: %d\n", slots(dch)[0] == slots(droot)[0]);
        printf("copy_cycle_preserved: %d\n", ref_get(slots(droot)[2]) == droot);
        printf("copy_parent_preserved: %d\n", parent_key(dch) == lmx_key(droot));
        printf("copy_types: %d %d %d %d\n", type_of_ref(b, slots(droot)[0]), type_of_ref(b, slots(droot)[2]),
               type_of_ref(b, dch), type_of_ref(b, slots(dch)[1]));
        int_set(slots(droot)[0], 99);
        printf("copy_is_independent: %d %d\n", int_get(x), int_get(slots(droot)[0]));
        arena_free(b);
    }
    arena_free(a);
}

/* =============================================================================================================== */

static void usage(void)
{
    fprintf(stderr,
            "usage: bench selftest\n"
            "       bench [--straddle] t1|t1w|t2 <nstruct> <nfields> <passes> <R> <seed>\n"
            "       bench [--straddle] t3|t3w <nstruct> <nfields> <nchain> <steps> <passes> <R> <seed>\n"
            "       bench [--straddle] t4|t4w <nstruct> <passes> <R> <seed>\n"
            "       bench [--straddle] t7 <nstruct> <nfields> <passes> <R> <seed>\n"
            "       bench [--straddle] t5 <nnodes> <fanout> <R> <seed>\n"
            "       bench [--straddle] t6 <n> <passes> <R> <seed>\n");
}

int main(int argc, char **argv)
{
    int straddle = 0;
    int i = 1;
    const char *test;
    int rc = 1;
    if (i < argc && strcmp(argv[i], "--straddle") == 0) {
        straddle = 1;
        i++;
    }
    if (i >= argc) {
        usage();
        return 1;
    }
    test = argv[i++];
    if (strcmp(test, "selftest") == 0) {
        selftest();
        return 0;
    }
    if (strcmp(test, "t1") == 0) {
        rc = run_t1(0, argc - i, argv + i, straddle);
    } else if (strcmp(test, "t1w") == 0) {
        rc = run_t1(1, argc - i, argv + i, straddle);
    } else if (strcmp(test, "t2") == 0) {
        rc = run_t2(argc - i, argv + i, straddle);
    } else if (strcmp(test, "t3") == 0) {
        rc = run_t3(0, argc - i, argv + i, straddle);
    } else if (strcmp(test, "t3w") == 0) {
        rc = run_t3(1, argc - i, argv + i, straddle);
    } else if (strcmp(test, "t4") == 0) {
        rc = run_t4(0, argc - i, argv + i, straddle);
    } else if (strcmp(test, "t4w") == 0) {
        rc = run_t4(1, argc - i, argv + i, straddle);
    } else if (strcmp(test, "t7") == 0) {
        rc = run_t7(argc - i, argv + i, straddle);
    } else if (strcmp(test, "t5") == 0) {
        rc = run_t5(argc - i, argv + i, straddle);
    } else if (strcmp(test, "t6") == 0) {
        rc = run_t6(argc - i, argv + i, straddle);
    }
    if (rc == 1) {
        usage();
    }
    return rc;
}
