#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "kalloc.h"
#include "kbarena.h"
#include "keigen.h"
#include "kexpr.h"
#include "kmath.h"
#include "kmempool.h"
#include "kstring.h"
#include "knhx.h"
#include "kson.h"
#include "lmx/ksa.h"

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
KALLOC_POOL_INIT2(static inline, checked_pool, int)

int main(void)
{
    void *arena = km_init();
    unsigned char *p = (unsigned char *)kcalloc(arena, 8, 1);
    km_stat_t stat;
    void *blocked;
    void *pool;
    int *entry;
    int error = 0, n = 0, i;
    kexpr_t *expr;
    double a[] = {2.0, 0.0, 0.0, 3.0}, eigen[2];
    kstring_t text = {0, 0, NULL}, tree_text = {0, 0, NULL};
    knhx1_t *nodes;
    kson_t *json;
    const kson_node_t *items;
    const unsigned char banana[] = "banana";
    const int expected[] = {6, 5, 3, 1, 0, 4, 2};
    int sa[7];
    int64_t sa64[7];

    CHECK(arena != NULL && p != NULL && p[7] == 0);
    p[0] = 77;
    p = (unsigned char *)krealloc(arena, p, 32);
    CHECK(p != NULL && p[0] == 77);
    kfree(arena, p);
    km_stat(arena, &stat);
    CHECK(stat.capacity != 0);
    km_destroy(arena);
    {
        kmp_checked_pool_t *typed_pool = kmp_init_checked_pool(NULL);
        int *number;
        CHECK(typed_pool != NULL);
        number = kmp_alloc_checked_pool(typed_pool);
        CHECK(number != NULL);
        *number = 17;
        kmp_free_checked_pool(typed_pool, number);
        CHECK(kmp_alloc_checked_pool(typed_pool) == number);
        kmp_free_checked_pool(typed_pool, number);
        kmp_destroy_checked_pool(typed_pool);
    }

    blocked = kba_init(128);
    CHECK(blocked != NULL);
    CHECK(kba_alloc(blocked, 16, 8) != NULL);
    CHECK(kba_save(blocked) == 0);
    CHECK(kba_alloc(blocked, 100, 4) != NULL);
    CHECK(kba_restore(blocked) == 0);
    CHECK(kba_capacity(blocked) >= 128);
    kba_destroy(blocked);

    pool = kmp_init(sizeof(int));
    CHECK(pool != NULL);
    entry = (int *)kmp_alloc(pool);
    CHECK(entry != NULL);
    *entry = 42;
    kmp_free(pool, entry);
    CHECK(kmp_alloc(pool) == entry);
    kmp_destroy(pool);

    expr = ke_parse("x * 3 + 2", &error);
    CHECK(expr != NULL && error == 0);
    CHECK(ke_set_int(expr, "x", 5) == 1);
    CHECK(ke_eval_int(expr, &error) == 17 && error == 0);
    ke_destroy(expr);
    CHECK(ke_eigen_sd(2, a, eigen, 0, 0, 0) == 0);
    CHECK(fabs(eigen[0] + eigen[1] - 5.0) < 1e-10);
    CHECK(fabs(eigen[0] * eigen[1] - 6.0) < 1e-10);
    CHECK(fabs(kf_lgamma(5.0) - log(24.0)) < 1e-8);
    CHECK(fabs(kf_erfc(0.0) - 1.0) < 1e-8);
    CHECK(fabs(kf_gammap(1.0, 1.0) + kf_gammaq(1.0, 1.0) - 1.0) < 1e-8);

    CHECK(ksprintf(&text, "%s:%d", "LMX", 99) >= 0);
    CHECK(strcmp(text.s, "LMX:99") == 0);
    CHECK(kstrstr(text.s, ":99", NULL) == text.s + 3);
    free(text.s);

    nodes = kn_parse("(A:1,B:2);", &n, &error);
    CHECK(nodes != NULL && error == 0 && n == 3);
    kn_format(nodes, n - 1, &tree_text);
    CHECK(tree_text.s != NULL && strstr(tree_text.s, "A") != NULL);
    for (i = 0; i < n; ++i) { free(nodes[i].name); free(nodes[i].child); }
    free(nodes);
    free(tree_text.s);
    json = kson_parse("{\"items\":[1,2]}");
    CHECK(json != NULL);
    items = kson_by_key(json->root, "items");
    CHECK(items != NULL && items->n == 2);
    CHECK(strcmp(kson_by_index(items, 1)->v.str, "2") == 0);
    kson_destroy(json);

    CHECK(ksa_sa(banana, sa, 7, 256) == 0);
    CHECK(ksa_sa64(banana, sa64, 7, 256) == 0);
    for (i = 0; i < 7; ++i) CHECK(sa[i] == expected[i] && sa64[i] == expected[i]);
    return 0;
}
