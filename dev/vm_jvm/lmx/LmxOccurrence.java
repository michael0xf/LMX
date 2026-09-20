package lmx;

import java.util.IdentityHashMap;
import java.util.Map;

/**
 * Isolated JVM ABI for {@code {node, len, data}}.
 *
 * <p>{@code node} is the lexical parent occurrence, or {@code null} if independent.
 * Storing a reference in {@code data} does <em>not</em> reparent the target
 * (docs/LMX_semantics.en.md ?8: "A field can retain a reference to an existing
 * object. This neither copies it nor reparents its lexical parent.").
 *
 * <p>Lexical nesting is explicit via {@link #nested}. Graph copy / bounded merge
 * uses a two-phase identity map: allocate all reachable occurrences (data graph
 * and {@code node} ancestor chains), then rewrite {@code data} edges and set
 * {@code dst.node = map(src.node)} ? never the data-slot container.
 *
 * <p>Bounded merge API: result root {@code node == null} (isolated expression /
 * zero parent). Not a full merge entrypoint with expression-location parent.
 */
public final class LmxOccurrence {
    private LmxOccurrence node;
    private final Object[] data;

    private LmxOccurrence(LmxOccurrence node, Object[] data) {
        if (data == null) {
            throw new IllegalArgumentException("data");
        }
        this.node = node;
        this.data = data;
    }

    /** Placeholder shell for phase-1 of graph copy (node filled in phase 2). */
    private LmxOccurrence(int len) {
        this.node = null;
        this.data = new Object[len];
    }

    /** Independent root: {@code node == null}. Does not reparent field targets. */
    public static LmxOccurrence independent(Object... fields) {
        return new LmxOccurrence(null, copyFields(fields));
    }

    /**
     * Explicit lexical nesting: {@code node == parent}. Does not reparent
     * arbitrary values stored in {@code fields}.
     */
    public static LmxOccurrence nested(LmxOccurrence parent, Object... fields) {
        if (parent == null) {
            throw new IllegalArgumentException("parent");
        }
        return new LmxOccurrence(parent, copyFields(fields));
    }

    public LmxOccurrence node() {
        return node;
    }

    public int len() {
        return data.length;
    }

    public Object child(int index) {
        checkBounds(index);
        return data[index];
    }

    public void setChild(int index, Object value) {
        checkBounds(index);
        data[index] = value;
    }

    /**
     * Bounded graph-copy merge into a fresh independent root ({@code node == null}).
     * Direct fields = operand fields in order (mapped). Hidden lexical ancestors
     * are copied into the identity map but are not result fields.
     */
    public static LmxOccurrence merge(LmxOccurrence... parts) {
        if (parts == null || parts.length == 0) {
            throw new IllegalArgumentException("parts");
        }
        Map<LmxOccurrence, LmxOccurrence> map = new IdentityHashMap<LmxOccurrence, LmxOccurrence>();
        int n = 0;
        for (LmxOccurrence p : parts) {
            if (p == null) {
                throw new IllegalArgumentException("null part");
            }
            n += p.len();
            for (int i = 0; i < p.len(); i++) {
                Object c = p.child(i);
                if (c instanceof LmxOccurrence) {
                    ensure((LmxOccurrence) c, map);
                }
            }
        }
        finishCopy(map);

        Object[] fields = new Object[n];
        LmxOccurrence root = new LmxOccurrence(null, fields);
        int k = 0;
        for (LmxOccurrence p : parts) {
            for (int i = 0; i < p.len(); i++) {
                fields[k++] = mapRef(p.child(i), map);
            }
        }
        return root;
    }

    /** Phase 1: allocate shell; walk {@code node} ancestors and data occurrence edges. */
    private static void ensure(LmxOccurrence src, Map<LmxOccurrence, LmxOccurrence> map) {
        if (src == null || map.containsKey(src)) {
            return;
        }
        map.put(src, new LmxOccurrence(src.len()));
        ensure(src.node, map);
        for (int i = 0; i < src.len(); i++) {
            Object c = src.child(i);
            if (c instanceof LmxOccurrence) {
                ensure((LmxOccurrence) c, map);
            }
        }
    }

    /** Phase 2: rewrite data edges; set {@code dst.node = map(src.node)}. */
    private static void finishCopy(Map<LmxOccurrence, LmxOccurrence> map) {
        for (Map.Entry<LmxOccurrence, LmxOccurrence> e : map.entrySet()) {
            LmxOccurrence src = e.getKey();
            LmxOccurrence dst = e.getValue();
            if (src.node == null) {
                dst.node = null;
            } else {
                LmxOccurrence mapped = map.get(src.node);
                if (mapped == null) {
                    throw new IllegalStateException("ancestor missing from copy map");
                }
                dst.node = mapped;
            }
            for (int i = 0; i < src.len(); i++) {
                dst.data[i] = mapRef(src.child(i), map);
            }
        }
    }

    private static Object mapRef(Object value, Map<LmxOccurrence, LmxOccurrence> map) {
        if (value instanceof LmxOccurrence) {
            LmxOccurrence mapped = map.get((LmxOccurrence) value);
            if (mapped == null) {
                throw new IllegalStateException("occurrence missing from copy map");
            }
            return mapped;
        }
        return value;
    }

    private static Object[] copyFields(Object[] fields) {
        Object[] copy = new Object[fields.length];
        System.arraycopy(fields, 0, copy, 0, fields.length);
        return copy;
    }

    private void checkBounds(int index) {
        if (index < 0 || index >= data.length) {
            throw new IndexOutOfBoundsException(
                    "LmxOccurrence index " + index + " not in [0," + data.length + ")");
        }
    }
}
