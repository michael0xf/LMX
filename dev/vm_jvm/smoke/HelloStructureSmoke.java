package smoke;

import lmx.LmxOccurrence;

/**
 * Bounded hello/Structure smoke for Path B item 4 runtime ABI.
 * Subset: Structure, index field-follow, merge-copy, identity, bounds.
 * Excludes: c.*, L2 machine ops, Message FIFO, Mix, native interpreter.
 */
public final class HelloStructureSmoke {
    private static int fails;

    public static void main(String[] args) {
        fails = 0;
        testFixedLenAndAssign();
        testBounds();
        testMergeNewRoot();
        testPhysicalIdentity();
        if (fails != 0) {
            System.out.println("FAIL checks=4 failures=" + fails);
            System.exit(1);
        }
        System.out.println("PASS HelloStructureSmoke checks=4 failures=0");
    }

    private static void testFixedLenAndAssign() {
        LmxOccurrence s = LmxOccurrence.structure(
                LmxOccurrence.atom("a"),
                LmxOccurrence.atom("b"));
        check("len==2", s.len() == 2);
        check("node STRUCTURE", s.node == LmxOccurrence.Kind.STRUCTURE);
        LmxOccurrence neu = LmxOccurrence.atom("B2");
        s.setChild(1, neu);
        check("assign wrote data[1]", s.child(1) == neu);
        check("len unchanged after assign", s.len() == 2);
    }

    private static void testBounds() {
        LmxOccurrence s = LmxOccurrence.structure(LmxOccurrence.atom("x"));
        boolean threw = false;
        try {
            s.child(1);
        } catch (IndexOutOfBoundsException e) {
            threw = true;
        }
        check("OOB child throws", threw);
        threw = false;
        try {
            s.setChild(-1, LmxOccurrence.atom("no"));
        } catch (IndexOutOfBoundsException e) {
            threw = true;
        }
        check("OOB setChild throws", threw);
    }

    private static void testMergeNewRoot() {
        LmxOccurrence left = LmxOccurrence.structure(LmxOccurrence.atom("L"));
        LmxOccurrence right = LmxOccurrence.structure(LmxOccurrence.atom("R"));
        LmxOccurrence m = LmxOccurrence.merge(left, right);
        check("merge len 2", m.len() == 2);
        check("merge new object", m != left && m != right);
        check("operands intact", left.len() == 1 && right.len() == 1);
        Object c0 = ((LmxOccurrence) m.child(0)).child(0);
        Object c1 = ((LmxOccurrence) m.child(1)).child(0);
        check("forward order", "L".equals(c0) && "R".equals(c1));
    }

    private static void testPhysicalIdentity() {
        LmxOccurrence a = LmxOccurrence.structure(LmxOccurrence.atom("same"));
        LmxOccurrence b = LmxOccurrence.structure(LmxOccurrence.atom("same"));
        check("equal content still distinct occurrences", a != b);
        check("== is physical identity", a == a);
    }

    private static void check(String name, boolean ok) {
        if (!ok) {
            fails++;
            System.out.println("FAIL " + name);
        }
    }
}
