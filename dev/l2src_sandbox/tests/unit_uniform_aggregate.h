#ifndef L2_UNIFORM_AGGREGATE_H
#define L2_UNIFORM_AGGREGATE_H
#include <stddef.h>
typedef struct L2DispatchPair {
    int value;
    size_t wide;
} L2DispatchPair;
static L2DispatchPair l2_dispatch_original = {41, 4294967303U};
static L2DispatchPair l2_dispatch_pair_make(void) { return l2_dispatch_original; }
static L2DispatchPair l2_dispatch_pair_change(L2DispatchPair value) {
    value.value = 99;
    return value;
}
static int l2_dispatch_pair_read(L2DispatchPair value) {
    return value.wide == 4294967303U ? value.value : 0;
}
static int l2_dispatch_pair_original(void) {
    return l2_dispatch_pair_read(l2_dispatch_original);
}
#endif
