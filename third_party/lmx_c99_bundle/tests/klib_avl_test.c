#include <stdio.h>
#include <stdlib.h>
#include "kavl.h"
#include "kavl-lite.h"
#include "krmq.h"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
typedef struct avl_node { int key; KAVL_HEAD(struct avl_node) head; } avl_node;
typedef struct lite_node { int key; KAVLL_HEAD(struct lite_node) head; } lite_node;
typedef struct rmq_node { int key, priority; KRMQ_HEAD(struct rmq_node) head; } rmq_node;
#define compare(a,b) (((a)->key > (b)->key) - ((a)->key < (b)->key))
#define priority_less(a,b) ((a)->priority < (b)->priority)
KAVL_INIT(avl, avl_node, head, compare)
KAVLL_INIT(lite, lite_node, head, compare)
KRMQ_INIT(rmq, rmq_node, head, compare, priority_less)
int main(void)
{
    avl_node nodes[3] = {{0}}, *root = NULL;
    lite_node lite_nodes[3] = {{0}}, *lite_root = NULL;
    rmq_node rmq_nodes[3] = {{0}}, *rmq_root = NULL;
    int i;
    for (i = 0; i < 3; ++i) {
        nodes[i].key = lite_nodes[i].key = rmq_nodes[i].key = i + 1;
        rmq_nodes[i].priority = i == 1 ? 0 : 10;
        CHECK(kavl_insert(avl, &root, &nodes[i], NULL) == &nodes[i]);
        CHECK(lite_insert(&lite_root, &lite_nodes[i]) == &lite_nodes[i]);
        CHECK(krmq_insert(rmq, &rmq_root, &rmq_nodes[i], NULL) == &rmq_nodes[i]);
    }
    CHECK(kavl_find(avl, root, &nodes[1], NULL) == &nodes[1]);
    CHECK(lite_find(lite_root, &lite_nodes[1]) == &lite_nodes[1]);
    CHECK(krmq_rmq(rmq, rmq_root, &rmq_nodes[0], &rmq_nodes[2]) == &rmq_nodes[1]);
    CHECK(kavl_erase(avl, &root, &nodes[1], NULL) == &nodes[1]);
    CHECK(lite_erase(&lite_root, &lite_nodes[1]) == &lite_nodes[1]);
    CHECK(krmq_erase(rmq, &rmq_root, &rmq_nodes[1], NULL) == &rmq_nodes[1]);
    return 0;
}
