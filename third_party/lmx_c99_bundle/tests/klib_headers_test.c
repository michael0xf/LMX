#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "kbit.h"
#include "krng.h"
#include "kvec.h"
#include "khash.h"
#include "kbtree.h"
#include "kgraph.h"
#include "klist.h"
#include "ketopt.h"
#include "ksort.h"
#include "kseq.h"
#if SIZE_MAX > UINT32_MAX
#include "kdq.h"
KDQ_INIT(int)
#endif

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
#define discard_node(x) ((void)(x))
KHASH_MAP_INIT_INT(map, int)
KBTREE_INIT(tree, int, kb_generic_cmp)
KLIST_INIT(list, int, discard_node)
#define sort_key(x) (x)
KRADIX_SORT_INIT(sort, unsigned, sort_key, sizeof(unsigned))
KHASH_MAP_INIT_INT(edge, int)
typedef struct { int data; khash_t(edge) *_arc; } vertex_t;
KGRAPH_INIT(graph, static inline, vertex_t, int, edge)

typedef struct { const char *text; size_t offset; } memory_file;
static int memory_read(memory_file *file, void *out, int count)
{
    size_t n = strlen(file->text + file->offset);
    if (n > (size_t)count) n = (size_t)count;
    memcpy(out, file->text + file->offset, n);
    file->offset += n;
    return (int)n;
}
KSEQ_INIT(memory_file *, memory_read)

int main(void)
{
    int absent, item, value, i;
    khint_t k;
    khash_t(map) *map = kh_init(map);
    kvec_t(int) vec;
    kbtree_t(tree) *tree = kb_init(tree, KB_DEFAULT_SIZE);
    klist_t(list) *list = kl_init(list);
    kgraph_t(graph) *graph = kg_init_graph();
    int *forward, *reverse;
    unsigned values[] = {7, 1, 5, 2};
    unsigned radix_values[257];
    krng_t rng;
    ketopt_t opts = KETOPT_INIT;
    char arg0[] = "program", arg1[] = "-n", arg2[] = "42";
    char *argv[] = {arg0, arg1, arg2, NULL};
    memory_file file = {">record description\nACGT\n", 0};
    kseq_t *sequence = kseq_init(&file);

    CHECK(map != NULL && tree != NULL && list != NULL && graph != NULL);
    k = kh_put(map, map, 7, &absent);
    CHECK(absent != 0);
    kh_val(map, k) = 11;
    CHECK(kh_val(map, kh_get(map, map, 7)) == 11);
    kh_del(map, map, k);
    CHECK(kh_size(map) == 0);
    kh_destroy(map, map);

    kv_init(vec);
    for (i = 0; i < 32; ++i) kv_push(int, vec, i);
    CHECK(kv_size(vec) == 32 && kv_pop(vec) == 31);
    kv_destroy(vec);
    kb_put(tree, tree, 10); kb_put(tree, tree, 4); kb_put(tree, tree, 15);
    CHECK(*kb_get(tree, tree, 10) == 10);
    CHECK(kb_del(tree, tree, 10) == 10 && kb_get(tree, tree, 10) == NULL);
    __kb_destroy(tree);
    *kl_pushp(list, list) = 23;
    CHECK(kl_shift(list, list, &value) == 0 && value == 23);
    kl_destroy(list, list);

    kg_put_a_graph(graph, 1, 2, 0, &forward, &reverse);
    *forward = 9; *reverse = 9;
    CHECK(kg_get_v_graph(graph, 1) != NULL && kg_get_v_graph(graph, 2) != NULL);
    CHECK(kg_del_v_graph(graph, 1) != NULL);
    CHECK(kg_get_v_graph(graph, 1) == NULL);
    kg_destroy_graph(graph);

    radix_sort_sort(values, values + 4);
    CHECK(values[0] == 1 && values[3] == 7);
    for (i = 0; i < 257; ++i) radix_values[i] = (unsigned)(257 - i) * 37u;
    radix_sort_sort(radix_values, radix_values + 257);
    for (i = 0; i < 257; ++i) CHECK(radix_values[i] == (unsigned)(i + 1) * 37u);
    CHECK(kbi_popcount64(UINT64_C(0xf00f)) == 8);
    kr_srand_r(&rng, UINT64_C(123));
    CHECK(kr_rand_r(&rng) != 0);
    { double x = kr_drand_r(&rng); CHECK(x >= 0.0 && x < 1.0); }
    kr_jump_r(&rng);
    CHECK(ketopt(&opts, 3, argv, 0, "n:", NULL) == 'n');
    CHECK(strcmp(opts.arg, "42") == 0);
    CHECK(ketopt(&opts, 3, argv, 0, "n:", NULL) == -1);
    CHECK(sequence != NULL && kseq_read(sequence) == 4);
    CHECK(strcmp(sequence->name.s, "record") == 0);
    CHECK(strcmp(sequence->seq.s, "ACGT") == 0);
    CHECK(kseq_read(sequence) == -1);
    kseq_destroy(sequence);
#if SIZE_MAX > UINT32_MAX
    {
        kdq_t(int) *queue = kdq_init(int);
        for (i = 0; i < 20; ++i) kdq_push(int, queue, i);
        kdq_unshift(int, queue, -1);
        CHECK(*kdq_shift(int, queue) == -1);
        for (i = 0; i < 20; ++i) { item = *kdq_shift(int, queue); CHECK(item == i); }
        CHECK(kdq_size(queue) == 0);
        kdq_destroy(int, queue);
    }
#else
    (void)item;
#endif
    return 0;
}
