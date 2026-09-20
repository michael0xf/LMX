package smoke;

import lmx.LmxOccurrence;
import lmx.LmxTerminal;

/**
 * GROK-BOT-JVM-NODE-FIX-20260920-52B: no reparent-on-store; two-phase map copy.
 */
public final class HelloStructureSmoke {
    private static int fails;
    private static int checks;

    public static void main(String[] args) {
        fails = 0;
        checks = 0;
        testIndependentNodeNull();
        testNestedExplicitParent();
        testStoreDoesNotReparent();
        testUnrelatedHolderCopy();
        testHiddenLexicalAncestor();
        testBackEdgeCycle();
        testRepeatedAlias();
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
        LmxOccurrence root = LmxOccurrence.independent("leaf");
        check("independent node null", root.node() == null);
    }

    private static void testNestedExplicitParent() {
        LmxOccurrence p = LmxOccurrence.independent();
        LmxOccurrence a = LmxOccurrence.nested(p, "x");
        check("nested node exact parent", a.node() == p);
    }

    private static void testStoreDoesNotReparent() {
        LmxOccurrence p = LmxOccurrence.independent();
        LmxOccurrence a = LmxOccurrence.nested(p, "x");
        LmxOccurrence h = LmxOccurrence.independent(a);
        check("store keeps A.node==P", a.node() == p);
        check("H does not become A.node", a.node() != h);
        check("H holds same A ref", h.child(0) == a);
    }

    private static void testUnrelatedHolderCopy() {
        LmxOccurrence p = LmxOccurrence.independent("P");
        LmxOccurrence a = LmxOccurrence.nested(p, "A");
        LmxOccurrence h = LmxOccurrence.independent(a);
        LmxOccurrence m = LmxOccurrence.merge(h);
        LmxOccurrence aCopy = (LmxOccurrence) m.child(0);
        check("A_copy != A", aCopy != a);
        check("A_copy.node != merge root", aCopy.node() != m);
        check("A_copy.node != H", aCopy.node() != h);
        LmxOccurrence pCopy = aCopy.node();
        check("A_copy.node is P_copy", pCopy != null && pCopy != p);
        check("P_copy leaf", "P".equals(pCopy.child(0)));
    }

    private static void testHiddenLexicalAncestor() {
        LmxOccurrence p = LmxOccurrence.independent("hidden");
        LmxOccurrence a = LmxOccurrence.nested(p, "A");
        LmxOccurrence h = LmxOccurrence.independent(a);
        LmxOccurrence m = LmxOccurrence.merge(h);
        check("result len 1 (ancestor not a field)", m.len() == 1);
        LmxOccurrence aCopy = (LmxOccurrence) m.child(0);
        LmxOccurrence pCopy = aCopy.node();
        boolean ancestorVisible = false;
        for (int i = 0; i < m.len(); i++) {
            if (m.child(i) == pCopy) {
                ancestorVisible = true;
            }
        }
        check("hidden lexical ancestor not a result field", !ancestorVisible);
        check("ancestor still reachable via node", pCopy != null);
    }

    private static void testBackEdgeCycle() {
        LmxOccurrence a = LmxOccurrence.independent((Object) null);
        a.setChild(0, a);
        check("setup self cycle", a.child(0) == a);
        LmxOccurrence holder = LmxOccurrence.independent(a);
        LmxOccurrence m = LmxOccurrence.merge(holder);
        LmxOccurrence aCopy = (LmxOccurrence) m.child(0);
        check("cycle preserved", aCopy.child(0) == aCopy);
        check("cycle copy distinct", aCopy != a);
    }

    private static void testRepeatedAlias() {
        LmxOccurrence shared = LmxOccurrence.independent("S");
        LmxOccurrence holder = LmxOccurrence.independent(shared, shared);
        check("setup alias", holder.child(0) == holder.child(1));
        LmxOccurrence m = LmxOccurrence.merge(holder);
        check("alias preserved in copy", m.child(0) == m.child(1));
        check("alias copy != source", m.child(0) != shared);
    }

    private static void testAdmittedTerminalShared() {
        LmxTerminal term = new LmxTerminal("T");
        LmxOccurrence a = LmxOccurrence.independent(term);
        LmxOccurrence b = LmxOccurrence.independent(term);
        LmxOccurrence m = LmxOccurrence.merge(a, b);
        check("terminal identity both slots", m.child(0) == term && m.child(1) == term);
    }

    private static void testOperandsUnchanged() {
        LmxOccurrence p = LmxOccurrence.independent("P");
        LmxOccurrence a = LmxOccurrence.nested(p, "A");
        LmxOccurrence h = LmxOccurrence.independent(a);
        LmxOccurrence.merge(h);
        check("source A unchanged", a.node() == p && a.child(0).equals("A"));
        check("source H unchanged", h.child(0) == a && h.node() == null);
        check("source P unchanged", p.node() == null && "P".equals(p.child(0)));
    }

    private static void testBounds() {
        LmxOccurrence s = LmxOccurrence.independent("x");
        boolean threw = false;
        try {
            s.child(1);
        } catch (IndexOutOfBoundsException e) {
            threw = true;
        }
        check("OOB child", threw);
        threw = false;
        try {
            s.setChild(-1, "no");
        } catch (IndexOutOfBoundsException e) {
            threw = true;
        }
        check("OOB setChild", threw);
    }

    private static void check(String name, boolean ok) {
        checks++;
        if (!ok) {
            fails++;
            System.out.println("FAIL " + name);
        }
    }
}
