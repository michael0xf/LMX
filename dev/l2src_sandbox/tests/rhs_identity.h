#ifndef LMX_TEST_RHS_IDENTITY_H
#define LMX_TEST_RHS_IDENTITY_H
/* A normal foreign ABI leaf: L2 must not infer a numeric result for it. */
struct Lmx;
static inline struct Lmx *l2_test_rhs_identity(struct Lmx *value) {
    return value;
}
static inline void *l2_test_rhs_probe(int *value) {
    return *value == 7 ? value : 0;
}
#endif
