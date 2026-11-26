/* Upstream's finite test suite, including local transport and protocol cases. */
#define CUTE_NET_TESTS
#define CUTE_NET_IMPLEMENTATION
#include "cute_net.h"
int main(void) { return cn_run_tests(-1, false) != 0; }
