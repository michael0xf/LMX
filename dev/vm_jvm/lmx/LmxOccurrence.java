package lmx;

/**
 * Minimal JVM ABI for an Lmx occurrence: {node, len, data}.
 *
 * Semantic rules (docs/LMX_semantics.*, vm_porting_plan_en.txt item 4):
 * - One Java object per occurrence; physical identity is ==.
 * - len is fixed at construction; never rewritten by assignment.
 * - Assignment replaces a child reference in data[i], with bounds checks.
 * - merge allocates a new root and copies children in forward order.
 * - Runtime library substrate, not "one Java class per Structure".
 * Independent of native dev/l3_interp. No L3-to-classfile printer yet.
 */
public final class LmxOccurrence {
    public final Kind node;
    private final Object[] data;

    public enum Kind {
        STRUCTURE,
        ARRAY,
        ATOM
    }

    private LmxOccurrence(Kind node, Object[] data) {
        if (node == null) {
            throw new IllegalArgumentException("node");
        }
        if (data == null) {
            throw new IllegalArgumentException("data");
        }
        this.node = node;
        this.data = data;
    }

    public static LmxOccurrence structure(Object... children) {
        Object[] copy = new Object[children.length];
        System.arraycopy(children, 0, copy, 0, children.length);
        return new LmxOccurrence(Kind.STRUCTURE, copy);
    }

    public static LmxOccurrence atom(Object value) {
        return new LmxOccurrence(Kind.ATOM, new Object[] { value });
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

    public static LmxOccurrence merge(LmxOccurrence... parts) {
        int n = 0;
        for (LmxOccurrence p : parts) {
            if (p == null) {
                throw new IllegalArgumentException("null part");
            }
            n += p.len();
        }
        Object[] out = new Object[n];
        int k = 0;
        for (LmxOccurrence p : parts) {
            for (int i = 0; i < p.len(); i++) {
                out[k++] = p.child(i);
            }
        }
        return new LmxOccurrence(Kind.STRUCTURE, out);
    }

    private void checkBounds(int index) {
        if (index < 0 || index >= data.length) {
            throw new IndexOutOfBoundsException(
                    "LmxOccurrence index " + index + " not in [0," + data.length + ")");
        }
    }
}
