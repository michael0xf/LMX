/* graph_algos.h -- gc_mark, graph_copy, graph_digest: ONE algorithm shared by every representation.
 *
 * Included at the end of each rep_*.h, after the representation's primitives:
 *   type_of_ref, length, lmx_storage, lmx_key, parent_key, set_parent_key, ref_get, ref_set, int_get, real_get,
 *   size_get, uninit_get, uninit_set, new_int, new_real, new_size, new_uninit_int, new_refcell, new_struct,
 *   new_array_int, new_array_ref, array_int_data, obj_mark, gc_begin, gc_end.
 * No representation has to expose a addressable struct Lmx (tv_packed keeps it unaligned): everything goes through
 * length/lmx_storage/lmx_key/parent_key/set_parent_key.
 * Edges followed by gc_mark and graph_copy: slot targets of a Structure, elements of an Array of handles, the target
 * of a reference cell.  The parent link is NOT an edge for gc_mark; graph_copy preserves it (parent copy, if reachable).
 */
#ifndef TV_GRAPH_ALGOS_H
#define TV_GRAPH_ALGOS_H

/* ---- gc_mark: depth-first mark with one bit per object, returns the number of marked objects ---- */
static inline size_t gc_mark(Arena *a, void *root)
{
    PtrStack st;
    size_t count = 0;
    memset(&st, 0, sizeof(st));
    gc_begin(a);
    if (root != NULL) {
        pstack_push(&st, root);
    }
    while (st.n > 0) {
        void *h = st.v[--st.n];
        int t = T_NONE;
        if (!obj_mark(a, h, &t)) {
            continue;
        }
        count++;
        if (t == T_STRUCT || t == T_ARRAY_REF) {
            void **s = (void **)lmx_storage(h);
            size_t n = length(h);
            size_t i;
            for (i = 0; i < n; i++) {
                if (s[i] != NULL) {
                    pstack_push(&st, s[i]);
                }
            }
        } else if (t == T_REF) {
            void *tg = ref_get(h);
            if (tg != NULL) {
                pstack_push(&st, tg);
            }
        }
    }
    free(st.v);
    gc_end(a);
    return count;
}

/* ---- graph_copy: one source->copy map (open addressing) keeping shared targets and cycles ---- */
typedef struct CopyPair {
    void *src;
    void *dst;
    int type;
} CopyPair;

typedef struct CopyVec {
    CopyPair *v;
    size_t n;
    size_t cap;
} CopyVec;

typedef struct CopyCtx {
    Arena *src;
    Arena *dst;
    PtrMap map;
    CopyVec work; /* objects whose content (slots / target) is still to copy */
    CopyVec fix;  /* objects with a struct Lmx: parent link is fixed at the end */
} CopyCtx;

static inline void copyvec_push(CopyVec *cv, void *src, void *dst, int type)
{
    if (cv->n == cv->cap) {
        cv->cap = cv->cap ? cv->cap * 2 : 256;
        cv->v = (CopyPair *)xrealloc(cv->v, cv->cap * sizeof(CopyPair));
    }
    cv->v[cv->n].src = src;
    cv->v[cv->n].dst = dst;
    cv->v[cv->n].type = type;
    cv->n++;
}

/* map key: lmx_key(h) for objects that carry a struct Lmx (the parent link stores exactly this key), the handle otherwise */
static inline const void *copy_key(void *h, int t)
{
    if (t == T_STRUCT || t == T_ARRAY_INT || t == T_ARRAY_REF) {
        return (const void *)lmx_key(h);
    }
    return (const void *)h;
}

static inline void *copy_obj(CopyCtx *c, void *h)
{
    int t;
    const void *key;
    void *d;
    size_t n;
    if (h == NULL) {
        return NULL;
    }
    t = type_of_ref(c->src, h);
    key = copy_key(h, t);
    d = map_get(&c->map, key);
    if (d != NULL) {
        return d;
    }
    switch (t) {
    case T_INT:
        d = new_int(c->dst, int_get(h));
        break;
    case T_REAL:
        d = new_real(c->dst, real_get(h));
        break;
    case T_SIZE:
        d = new_size(c->dst, size_get(h));
        break;
    case T_UNINIT_INT:
        d = new_uninit_int(c->dst);
        uninit_set(d, uninit_get(h));
        break;
    case T_REF:
        d = new_refcell(c->dst, NULL);
        break;
    case T_STRUCT:
        d = new_struct(c->dst, length(h), NULL);
        break;
    case T_ARRAY_INT:
        n = length(h);
        d = new_array_int(c->dst, n);
        if (n > 0) {
            memcpy(array_int_data(d), array_int_data(h), n * sizeof(int));
        }
        break;
    case T_ARRAY_REF:
        d = new_array_ref(c->dst, length(h));
        break;
    default:
        fprintf(stderr, "graph_copy: unexpected type %d\n", t);
        abort();
    }
    map_put(&c->map, key, d);
    if (t == T_REF || t == T_STRUCT || t == T_ARRAY_REF) {
        copyvec_push(&c->work, h, d, t);
    }
    if (t == T_STRUCT || t == T_ARRAY_INT || t == T_ARRAY_REF) {
        copyvec_push(&c->fix, h, d, t);
    }
    return d;
}

/* copies the graph reachable from root of src into dst; returns the copy of root */
static inline void *graph_copy(Arena *dst, Arena *src, void *root)
{
    CopyCtx c;
    void *droot;
    size_t i;
    memset(&c, 0, sizeof(c));
    c.src = src;
    c.dst = dst;
    map_init(&c.map, 1024);
    droot = copy_obj(&c, root);
    for (i = 0; i < c.work.n; i++) {
        CopyPair w = c.work.v[i]; /* by value: copy_obj may reallocate the vector */
        if (w.type == T_REF) {
            ref_set(w.dst, copy_obj(&c, ref_get(w.src)));
        } else {
            void **ss = (void **)lmx_storage(w.src);
            void **sd = (void **)lmx_storage(w.dst);
            size_t n = length(w.src);
            size_t k;
            for (k = 0; k < n; k++) {
                sd[k] = copy_obj(&c, ss[k]);
            }
        }
    }
    for (i = 0; i < c.fix.n; i++) {
        void *sp = parent_key(c.fix.v[i].src);
        if (sp != NULL) {
            void *dp = map_get(&c.map, (const void *)sp);
            if (dp != NULL) {
                set_parent_key(c.fix.v[i].dst, lmx_key(dp));
            }
        }
    }
    free(c.work.v);
    free(c.fix.v);
    map_free(&c.map);
    return droot;
}

/* ---- graph_digest: representation-independent hash of the reachable graph (types, values, sharing, parents) ---- */
static inline uint64_t digest_mix(uint64_t h, uint64_t v)
{
    h ^= v + 0x9E3779B97F4A7C15ULL + (h << 6) + (h >> 2);
    return h * 0x100000001B3ULL;
}

static inline uint64_t graph_digest(Arena *a, void *root)
{
    PtrMap seen;
    PtrStack st;
    uint64_t h = 1469598103934665603ULL;
    size_t ord = 0;
    if (root == NULL) {
        return 0;
    }
    memset(&st, 0, sizeof(st));
    map_init(&seen, 1024);
    map_put(&seen, copy_key(root, type_of_ref(a, root)), (void *)(uintptr_t)(++ord));
    pstack_push(&st, root);
    while (st.n > 0) {
        void *x = st.v[--st.n];
        int t = type_of_ref(a, x);
        h = digest_mix(h, (uint64_t)t);
        switch (t) {
        case T_INT:
            h = digest_mix(h, (uint64_t)(uint32_t)int_get(x));
            break;
        case T_REAL:
            h = digest_mix(h, (uint64_t)(int64_t)real_get(x));
            break;
        case T_SIZE:
            h = digest_mix(h, (uint64_t)size_get(x));
            break;
        case T_UNINIT_INT:
            h = digest_mix(h, (uint64_t)(uint32_t)uninit_get(x));
            break;
        case T_ARRAY_INT: {
            size_t n = length(x);
            size_t i;
            const int *d = array_int_data(x);
            for (i = 0; i < n; i++) {
                h = digest_mix(h, (uint64_t)(uint32_t)d[i]);
            }
            break;
        }
        case T_REF:
        case T_STRUCT:
        case T_ARRAY_REF: {
            void **s;
            size_t n;
            size_t i;
            void *one;
            if (t == T_REF) {
                one = ref_get(x);
                s = &one;
                n = 1;
            } else {
                s = (void **)lmx_storage(x);
                n = length(x);
                h = digest_mix(h, (uint64_t)(uintptr_t)map_get(&seen, (const void *)parent_key(x)));
            }
            for (i = 0; i < n; i++) {
                void *ch = s[i];
                if (ch == NULL) {
                    h = digest_mix(h, 0);
                } else {
                    const void *k = copy_key(ch, type_of_ref(a, ch));
                    void *o = map_get(&seen, k);
                    if (o == NULL) {
                        o = (void *)(uintptr_t)(++ord);
                        map_put(&seen, k, o);
                        pstack_push(&st, ch);
                    }
                    h = digest_mix(h, (uint64_t)(uintptr_t)o);
                }
            }
            break;
        }
        default:
            break;
        }
    }
    free(st.v);
    map_free(&seen);
    return digest_mix(h, (uint64_t)ord);
}

#endif /* TV_GRAPH_ALGOS_H */
