#include <stdio.h>
#include "khashl.h"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
KHASHL_MAP_INIT(KH_LOCAL, map_t, map, int, int, kh_hash_uint32, kh_eq_generic)
KHASHL_CSET_INIT(KH_LOCAL, cache_t, cache, int, kh_hash_uint32, kh_eq_generic)
KHASHE_SET_INIT(KH_LOCAL, ensemble_t, ensemble, int, kh_hash_uint32, kh_eq_generic)
int main(void)
{
    int absent;
    khint_t k;
    kh_ensitr_t e;
    map_t *m = map_init();
    cache_t *c = cache_init();
    ensemble_t *h = ensemble_init(2);
    CHECK(m != NULL && c != NULL && h != NULL);
    k = map_put(m, 41, &absent);
    CHECK(absent != 0);
    kh_val(m, k) = 42;
    CHECK(kh_val(m, map_get(m, 41)) == 42);
    CHECK(map_del(m, k) != 0 && kh_size(m) == 0);
    k = cache_put(c, 99, &absent);
    CHECK(absent != 0 && cache_get(c, 99) == k);
    e = ensemble_put(h, 100, &absent);
    CHECK(absent != 0 && !kh_ens_is_end(e));
    CHECK(!kh_ens_is_end(ensemble_get(h, 100)));
    CHECK(ensemble_del(h, e) != 0 && kh_ens_size(h) == 0);
    map_destroy(m); cache_destroy(c); ensemble_destroy(h);
    return 0;
}
