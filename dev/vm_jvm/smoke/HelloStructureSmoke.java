package smoke;

import lmx.LmxOccurrence;
import lmx.LmxTerminal;

/**
 * Corrected ABI smoke for GROK-BOT-JVM-FIX-20260920-51B.
 * Proves parent {@code node}, graph-copy merge, aliasing, terminals, bounds.
 */
public final class HelloStructureSmoke {
    private static int fails;
    private static int checks;

    public static void main(String[] args) {
        fails = 0;
        checks = 0;
        testIndependentNodeNull();
        testNestedNodeExactParent();
        testMutableDescendantsCopied();
        testRepeatedMutableCopiedOnce();
        testCopiedNodeLinksInCopiedGraph();
        testAdmittedTerminalShared();
        testOperandsUnchanged();
        testBounds();
        if (fails != 0) {
            System.out.println("FAIL checks=" + checks + " failures=" + fails);
            System.exit(1);
        }
        System.out.println("PASS HelloStructureSmoke checks=" + checks + " failures=0");
    }

    private static void testIndependentNodeNull() {
        LmxOccurrence root = LmxOccurrence.independent(LmxOccurrence.independent());
        // wait - nested empty as field gets rebound; use leaf string + independent
        root = LmxOccurrence.independent("leaf");
        check("independent node null", root.node() == null);
        check("independent len 1", root.len() == 1);
    }

    private static void testNestedNodeExactParent() {
        LmxOccurrence parent = LmxOccurrence.independent();
        // Build child nested under parent, then place as field ? bind sets node to container
        LmxOccurrence child = LmxOccurrence.nested(parent, "x");
        check("nested ctor node==parent", child.node() == parent);
        LmxOccurrence root = LmxOccurrence.independent(child);
        Object c0 = root.child(0);
        check("field child is occurrence", c0 instanceof LmxOccurrence);
        LmxOccurrence placed = (LmxOccurrence) c0;
        check("nested node exact parent container", placed.node() == root);
        check("parent root still independent", root.node() == null);
    }

    private static void testMutableDescendantsCopied() {
        LmxOccurrence inner = LmxOccurrence.independent("v");
        LmxOccurrence outer = LmxOccurrence.independent(inner);
        LmxOccurrence other = LmxOccurrence.independent("z");
        LmxOccurrence m = LmxOccurrence.merge(outer, other);
        check("merge len 2", m.len() == 2);
        LmxOccurrence innerCopy = (LmxOccurrence) m.child(0);
        check("mutable descendant copied", innerCopy != inner);
        check("copy has same leaf", "v".equals(innerCopy.child(0)));
    }

    private static void testRepeatedMutableCopiedOnce() {
        LmxOccurrence shared = LmxOccurrence.independent("S");
        LmxOccurrence holder = LmxOccurrence.independent(shared, shared);
        check("setup alias", holder.child(0) == holder.child(1));
        LmxOccurrence m = LmxOccurrence.merge(holder);
        Object a = m.child(0);
        Object b = m.child(1);
        check("repeated mutable copied once", a == b);
        check("copy distinct from source shared", a != shared);
    }

    private static void testCopiedNodeLinksInCopiedGraph() {
        LmxOccurrence mid = LmxOccurrence.independent("m");
        LmxOccurrence top = LmxOccurrence.independent(mid);
        LmxOccurrence m = LmxOccurrence.merge(top);
        LmxOccurrence midCopy = (LmxOccurrence) m.child(0);
        check("copied mid.node is merge root", midCopy.node() == m);
        check("merge root independent", m.node() == null);
        check("original mid.node unchanged null", mid.node() == null);
    }

    private static void testAdmittedTerminalShared() {
        LmxTerminal term = new LmxTerminal("METHOD-like");
        LmxOccurrence a = LmxOccurrence.independent(term);
        LmxOccurrence b = LmxOccurrence.independent(term);
        LmxOccurrence m = LmxOccurrence.merge(a, b);
        check("terminal shared left", m.child(0) == term);
        check("terminal shared right", m.child(1) == term);
        check("same terminal identity both fields", m.child(0) == m.child(1));
    }

    private static void testOperandsUnchanged() {
        LmxOccurrence left = LmxOccurrence.independent("L");
        LmxOccurrence right = LmxOccurrence.independent("R");
        int ll = left.len();
        int rl = right.len();
        Object l0 = left.child(0);
        LmxOccurrence.merge(left, right);
        check("left len intact", left.len() == ll);
        check("right len intact", right.len() == rl);
        check("left child intact", left.child(0) == l0);
        check("left still independent", left.node() == null);
    }

    private static void testBounds() {
        LmxOccurrence s = LmxOccurrence.independent("x");
        boolean threw = false;
        try {
            s.child(1);
        } catch (IndexOutOfBoundsException e) {
            threw = true;
        }
        check("OOB child throws", threw);
        threw = false;
        try {
            s.setChild(-1, "no");
        } catch (IndexOutOfBoundsException e) {
            threw = true;
        }
        check("OOB setChild throws", threw);
        s.setChild(0, "y");
        check("assign wrote data", "y".equals(s.child(0)));
        check("len fixed after assign", s.len() == 1);
    }

    private static void check(String name, boolean ok) {
        checks++;
        if (!ok) {
            fails++;
            System.out.println("FAIL " + name);
        }
    }
}
