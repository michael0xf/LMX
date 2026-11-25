#include "stc_test_common.h"
#include <string.h>
#include <stc/cstr.h>
#include <stc/algorithm.h>

#define i_type IntVec, int
#define i_use_cmp
#include <stc/vec.h>
#define i_type IntDeque, int
#include <stc/deque.h>
#define i_type IntQueue, int
#include <stc/queue.h>
#define i_type IntStack, int
#include <stc/stack.h>
#define i_type IntList, int
#define i_use_cmp
#include <stc/list.h>
#define i_type IntMap, int, int
#include <stc/hmap.h>
#define i_type IntSet, int
#include <stc/hset.h>
#define i_type SortedMap, int, int
#include <stc/smap.h>
#define i_type SortedSet, int
#include <stc/sset.h>
#define i_type IntPriority, int
#include <stc/pqueue.h>
#define i_type IntBox, int
#include <stc/box.h>
#define i_type IntShared, int
#define i_no_atomic
#include <stc/arc.h>
#define i_type StringVec
#define i_keypro cstr
#include <stc/vec.h>

int main(void) {
    IntVec v = {0};
    for (int i = 99; i >= 0; --i) IntVec_push(&v, i);
    CHECK(IntVec_size(&v) == 100);
    IntVec_sort(&v);
    CHECK(v.data[0] == 0 && v.data[99] == 99);
    CHECK(IntVec_binary_search(&v, 42) == 42);
    IntVec copy = IntVec_clone(v);
    IntVec_erase_n(&v, 40, 20);
    CHECK(IntVec_size(&v) == 80 && v.data[40] == 60);
    CHECK(IntVec_size(&copy) == 100 && copy.data[40] == 40);
    IntVec_drop(&v);
    IntVec_drop(&copy);

    IntDeque dq = {0};
    IntDeque_push_back(&dq, 2);
    IntDeque_push_front(&dq, 1);
    IntDeque_push_back(&dq, 3);
    CHECK(*IntDeque_front(&dq) == 1 && *IntDeque_back(&dq) == 3);
    IntDeque_pop_front(&dq);
    IntDeque_pop_back(&dq);
    CHECK(IntDeque_size(&dq) == 1 && *IntDeque_front(&dq) == 2);
    IntDeque_drop(&dq);

    IntQueue q = {0};
    IntStack stack = {0};
    for (int i = 0; i < 50; ++i) {
        IntQueue_push(&q, i);
        IntStack_push(&stack, i);
    }
    for (int i = 0; i < 50; ++i) {
        CHECK(*IntQueue_front(&q) == i);
        CHECK(*IntStack_top(&stack) == 49 - i);
        IntQueue_pop(&q);
        IntStack_pop(&stack);
    }
    CHECK(IntQueue_size(&q) == 0 && IntStack_size(&stack) == 0);
    IntQueue_drop(&q);
    IntStack_drop(&stack);

    IntList list = {0};
    IntList_push_back(&list, 3);
    IntList_push_back(&list, 1);
    IntList_push_back(&list, 2);
    IntList_sort(&list);
    CHECK(IntList_count(&list) == 3 && *IntList_front(&list) == 1);
    int expected = 1;
    c_foreach(it, IntList, list) CHECK(*it.ref == expected++);
    IntList_pop_front(&list);
    CHECK(*IntList_front(&list) == 2);
    IntList_drop(&list);

    IntMap map = {0};
    IntSet set = {0};
    SortedMap smap = {0};
    SortedSet sset = {0};
    for (int i = 127; i >= 0; --i) {
        IntMap_insert(&map, i, i * 2);
        IntSet_insert(&set, i);
        SortedMap_insert(&smap, i, i * 3);
        SortedSet_insert(&sset, i);
    }
    CHECK(IntMap_get(&map, 17)->second == 34);
    CHECK(SortedMap_get(&smap, 17)->second == 51);
    CHECK(!IntSet_insert(&set, 17).inserted);
    CHECK(!SortedSet_insert(&sset, 17).inserted);
    CHECK(IntMap_size(&map) == 128 && IntSet_size(&set) == 128);
    CHECK(IntMap_erase(&map, 17) == 1 && IntMap_get(&map, 17) == NULL);
    CHECK(SortedMap_erase(&smap, 17) == 1 && SortedMap_get(&smap, 17) == NULL);
    CHECK(IntSet_erase(&set, 17) == 1 && !IntSet_contains(&set, 17));
    CHECK(SortedSet_erase(&sset, 17) == 1 && !SortedSet_contains(&sset, 17));
    int previous = -1;
    c_foreach(it, SortedSet, sset) {
        CHECK(*it.ref > previous);
        previous = *it.ref;
    }
    IntMap_drop(&map);
    IntSet_drop(&set);
    SortedMap_drop(&smap);
    SortedSet_drop(&sset);

    IntPriority pq = {0};
    IntPriority_push(&pq, 2);
    IntPriority_push(&pq, 9);
    IntPriority_push(&pq, 4);
    CHECK(*IntPriority_top(&pq) == 9);
    IntPriority_pop(&pq);
    CHECK(*IntPriority_top(&pq) == 4);
    IntPriority_drop(&pq);

    IntBox box = IntBox_make(23);
    IntBox boxcopy = IntBox_clone(box);
    CHECK(*box.get == 23 && box.get != boxcopy.get);
    *boxcopy.get = 24;
    CHECK(*box.get == 23);
    IntBox_drop(&boxcopy);
    IntBox_drop(&box);
    IntShared shared = IntShared_make(71);
    IntShared sharedcopy = IntShared_clone(shared);
    CHECK(IntShared_use_count(&shared) == 2 && shared.get == sharedcopy.get);
    IntShared_drop(&sharedcopy);
    CHECK(IntShared_use_count(&shared) == 1 && *shared.get == 71);
    IntShared_drop(&shared);

    StringVec names = {0};
    StringVec_emplace(&names, "alpha");
    StringVec_emplace(&names, "a string long enough to exercise heap allocation");
    StringVec other = StringVec_clone(names);
    cstr_assign(&names.data[1], "changed");
    CHECK(strcmp(cstr_str(&other.data[1]), "a string long enough to exercise heap allocation") == 0);
    StringVec_drop(&names);
    CHECK(strcmp(cstr_str(&other.data[0]), "alpha") == 0);
    StringVec_drop(&other);
    return EXIT_SUCCESS;
}
