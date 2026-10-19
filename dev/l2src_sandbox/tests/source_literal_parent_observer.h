#ifndef LMX_SOURCE_LITERAL_PARENT_OBSERVER_H
#define LMX_SOURCE_LITERAL_PARENT_OBSERVER_H
#include <string.h>

static int l2_test_source_literal_values(LmxArena *arena, Lmx *parent)
{
    Lmx *text, *empty;
    if (!lmx_graph_node_in(arena, parent) || parent->array.size != 2)
        return 0;
    text = lmx_graph_node_in(arena, lmx_graph_value_in(arena, parent, 0));
    empty = lmx_graph_node_in(arena, lmx_graph_value_in(arena, parent, 1));
    if (!text || !empty || text == empty || text->parent != parent ||
        empty->parent != parent || text->native || empty->native ||
        lmx_range_classify(arena, text) != LMX_KIND_ARRAY ||
        lmx_range_classify(arena, empty) != LMX_KIND_ARRAY ||
        lmx_range_type_of(arena, text) != LMX_TYPE_ARRAY_OF_CHAR ||
        lmx_range_type_of(arena, empty) != LMX_TYPE_ARRAY_OF_CHAR ||
        text->array.size != 3 || empty->array.size != 0 || empty->array.data)
        return 0;
    return lmx_graph_cell_in(arena, text, 2) &&
           lmx_range_type_of(arena, text->array.data) == LMX_TYPE_CHAR &&
           memcmp(text->array.data, "abc", 3) == 0;
}

static int l2_test_source_literal_parent(LmxArena *arena, Lmx *parent)
{
    LmxArena destination;
    Lmx *copy = NULL;
    int okay;
    if (!l2_test_source_literal_values(arena, parent))
        return 0;
    memset(&destination, 0, sizeof destination);
    if (lmx_arena_open(&destination) != 0)
        return 0;
    okay = lmx_graph_copy_owned(parent, arena, &destination, &copy) == LMX_GRAPH_COPY_OK &&
           copy != parent && l2_test_source_literal_values(&destination, copy) &&
           lmx_graph_value_in(&destination, copy, 0) != lmx_graph_value_in(arena, parent, 0) &&
           l2_test_source_literal_values(arena, parent);
    return lmx_arena_release(&destination) == 0 && okay &&
           l2_test_source_literal_values(arena, parent);
}
#endif
