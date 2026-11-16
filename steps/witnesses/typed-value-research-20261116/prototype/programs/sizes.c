/* sizes.c -- sizeof / alignof / offsetof of the records of ONE representation and the full storage cost of typical
 * values.  Build once per representation (-DREP=...), with and without -DLMX_NATIVE_WORD=1.  Prints no timings.
 *
 * Cost = (bytes_live after - before) / count over a batch of identical objects (chunk headers, record-start bitmaps,
 * hash sets and range tables included, because bytes_live includes them); a slot pointer in a Structure is +8 bytes.
 */
#include "common.h"
#include "rep_select.h"

/* ---- the walker's value record as it is now, against the TypedValue-shaped alternative: sizes and offsets only ---- */
struct WalkValueNow {
    int present;
    int kind;
    int type;
    void *ref;
    int number;
    size_t wide;
    unsigned natural;
    unsigned long long longnum;
    char byte;
    struct Lmx *model;
    struct Lmx *references;
    void *referent;
    void *scalar_abi;
    void *physical_profile;
    void *source_type;
};

struct WalkValueTv {
    int type;
    int flags;
    union {
        int integer;
        double real;
        size_t size;
        void *reference;
    } value;
    void *context;
};

#if defined(REP_HAS_FILL)
/* The T2 mixed stream (same roll distribution as bench_main.c build_mixed): how many bytes per record go to padding, fillers and holes */
static void mixed_stream_report(void)
{
    Arena *a = arena_new();
    Rng r;
    const size_t ns = 20000;
    const size_t nf = 12;
    void **ints = NULL;
    size_t nints = 0;
    size_t capints = 0;
    size_t i;
    size_t j;
    FillStats f;
    double rec_bytes;
    double waste;
    r.s = 1;
    for (i = 0; i < ns; i++) {
        void *s = new_struct(a, nf, NULL);
        void **sl = slots(s);
        for (j = 0; j < nf; j++) {
            uint32_t roll = rng_below(&r, 100);
            if (roll < 30) {
                void *c = new_int(a, (int)rng_below(&r, 1000));
                if (nints == capints) {
                    capints = capints ? capints * 2 : 1024;
                    ints = (void **)xrealloc(ints, capints * sizeof(void *));
                }
                ints[nints++] = c;
                sl[j] = c;
            } else if (roll < 50) {
                sl[j] = new_real(a, (double)rng_below(&r, 1000));
            } else if (roll < 60) {
                sl[j] = new_size(a, (size_t)rng_below(&r, 100000));
            } else if (roll < 75) {
                void *target;
                if (nints == 0) {
                    target = new_int(a, (int)rng_below(&r, 1000));
                    ints = (void **)xrealloc(ints, 1024 * sizeof(void *));
                    capints = 1024;
                    ints[nints++] = target;
                } else {
                    target = ints[rng_below(&r, (uint32_t)nints)];
                }
                sl[j] = new_refcell(a, target);
            } else if (roll < 85) {
                void *nested = new_struct(a, 2, s);
                slots(nested)[0] = new_int(a, (int)rng_below(&r, 1000));
                slots(nested)[1] = new_int(a, (int)rng_below(&r, 1000));
                sl[j] = nested;
            } else {
                void *u = new_uninit_int(a);
                uninit_set(u, (int)rng_below(&r, 1000));
                sl[j] = u;
            }
        }
    }
    fill_stats(a, &f);
    rec_bytes = (double)(f.stream - f.raw);
    waste = (double)(f.stream - f.net - f.raw);
    printf("-- mixed stream of the T2 test (%llu structures x %llu fields, same roll distribution) --\n", (unsigned long long)ns,
           (unsigned long long)nf);
    printf("  records                                  %10llu\n", (unsigned long long)f.records);
    printf("  net bytes per record (tag + value)       %10.3f\n", (double)f.net / (double)f.records);
    printf("  stream bytes per record (net + waste)    %10.3f\n", rec_bytes / (double)f.records);
    printf("  waste (padding, fillers, unused tails)   %10.0f bytes = %.2f%% of all %llu stream bytes (raw blocks %llu)\n", waste,
           100.0 * waste / (double)f.stream, (unsigned long long)f.stream, (unsigned long long)f.raw);
    printf("  dense-storage alignment padding %llu (included in raw blocks' neighbours' waste), value alignment padding %llu,\n"
           "  line tails skipped %llu, of them reused by the hole %llu (tv_align only)\n",
           (unsigned long long)f.pad_raw, (unsigned long long)f.pad_align, (unsigned long long)f.pad_line,
           (unsigned long long)f.hole_filled);
    printf("  bytes_live of the arena                  %10llu\n", (unsigned long long)bytes_live(a));
    free(ints);
    arena_free(a);
}
#endif

static double cost_batch(int kind, size_t count)
{
    Arena *a = arena_new();
    void *target = new_int(a, 1);
    size_t before = bytes_live(a);
    size_t after;
    size_t i;
    size_t j;
    for (i = 0; i < count; i++) {
        switch (kind) {
        case 0:
            (void)new_int(a, (int)i);
            break;
        case 1:
            (void)new_real(a, (double)i);
            break;
        case 2:
            (void)new_size(a, i);
            break;
        case 3:
            (void)new_refcell(a, target);
            break;
        case 4:
            (void)new_uninit_int(a);
            break;
        case 5:
            (void)new_struct(a, 4, NULL);
            break;
        case 6:
            (void)new_array_int(a, 1000);
            break;
        case 7: { /* a Structure with four int fields, slots included */
            void *s = new_struct(a, 4, NULL);
            for (j = 0; j < 4; j++) {
                slots(s)[j] = new_int(a, (int)j);
            }
            break;
        }
        case 8:
#if defined(REP_HAS_FLAT_UNINIT)
            (void)new_uninit_int_flat(a);
#endif
            break;
        default:
            break;
        }
    }
    after = bytes_live(a);
    arena_free(a);
    return (double)(after - before) / (double)count;
}

int main(void)
{
    static const char *names[] = {"int cell / record",
                                  "double cell / record",
                                  "size_t cell / record",
                                  "reference cell / record",
                                  "uninit:int (nested form where the rep has one)",
                                  "Structure, 4 slots (header + slots array)",
                                  "Array<int>, 1000 elements (header + data)",
                                  "Structure with 4 int fields (all included)"};
    static const size_t counts[] = {200000, 200000, 200000, 200000, 200000, 100000, 2000, 50000};
    int k;
    int nw = 0;
#if defined(LMX_NATIVE_WORD) && LMX_NATIVE_WORD
    nw = 1;
#endif
    printf("== representation %s, native word %s ==\n", REP_NAME, nw ? "ON (struct Lmx 32 bytes)" : "off (struct Lmx 24 bytes)");
    PRINT_TYPE(struct Lmx);
    PRINT_OFF(struct Lmx, parent);
    PRINT_OFF(struct Lmx, length);
    PRINT_OFF(struct Lmx, storage);
    printf("  pointer=%llu size_t=%llu int=%llu double=%llu long=%llu (LP64 / LLP64 neutral code)\n",
           (unsigned long long)sizeof(void *), (unsigned long long)sizeof(size_t), (unsigned long long)sizeof(int),
           (unsigned long long)sizeof(double), (unsigned long long)sizeof(long));
    printf("-- records of this representation --\n");
    rep_print_layout();
    printf("-- full storage cost of typical values, bytes per value (a slot pointer in a Structure is +%llu) --\n",
           (unsigned long long)sizeof(void *));
    for (k = 0; k < 8; k++) {
        printf("  %-46s %10.2f\n", names[k], cost_batch(k, counts[k]));
    }
#if defined(REP_HAS_FLAT_UNINIT)
    printf("  %-46s %10.2f   <- flat form {UNINIT_INT; int}: typeof(@u) = UNINIT_INT, FAILS the protocol (nested form above passes)\n",
           "uninit:int, FLAT single record", cost_batch(8, 200000));
#endif
#if defined(REP_HAS_FILL)
    mixed_stream_report();
#endif
    printf("-- walker value record --\n");
    PRINT_TYPE(struct WalkValueNow);
    PRINT_OFF(struct WalkValueNow, ref);
    PRINT_OFF(struct WalkValueNow, number);
    PRINT_OFF(struct WalkValueNow, wide);
    PRINT_OFF(struct WalkValueNow, natural);
    PRINT_OFF(struct WalkValueNow, longnum);
    PRINT_OFF(struct WalkValueNow, byte);
    PRINT_OFF(struct WalkValueNow, model);
    PRINT_OFF(struct WalkValueNow, references);
    PRINT_OFF(struct WalkValueNow, referent);
    PRINT_OFF(struct WalkValueNow, scalar_abi);
    PRINT_OFF(struct WalkValueNow, physical_profile);
    PRINT_OFF(struct WalkValueNow, source_type);
    PRINT_TYPE(struct WalkValueTv);
    PRINT_OFF(struct WalkValueTv, flags);
    PRINT_OFF(struct WalkValueTv, value);
    PRINT_OFF(struct WalkValueTv, context);
    return 0;
}
