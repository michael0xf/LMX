using System;
using Lmx;

namespace Smoke
{
    public static class HelloStructureSmoke
    {
        private static int checks;
        private static int fails;

        public static int Main(string[] args)
        {
            checks = 0; fails = 0;
            testIndependentNodeNull();
            testNestedExplicitParent();
            testStoreDoesNotReparent();
            testMergeCopy();
            testBounds();
            if (fails != 0)
            {
                Console.WriteLine("FAIL HelloStructureSmoke checks=" + checks + " failures=" + fails);
                return 1;
            }
            Console.WriteLine("PASS HelloStructureSmoke checks=" + checks + " failures=0");
            return 0;
        }

        private static void check(string name, bool ok)
        {
            checks++;
            if (!ok) { fails++; Console.WriteLine("FAIL " + name); }
        }

        private static void testIndependentNodeNull()
        {
            LmxOccurrence root = LmxOccurrence.Independent("leaf");
            check("independent node null", root.Node == null);
        }

        private static void testNestedExplicitParent()
        {
            LmxOccurrence p = LmxOccurrence.Independent();
            LmxOccurrence a = LmxOccurrence.Nested(p, "x");
            check("nested node exact parent", object.ReferenceEquals(a.Node, p));
        }

        private static void testStoreDoesNotReparent()
        {
            LmxOccurrence p = LmxOccurrence.Independent();
            LmxOccurrence a = LmxOccurrence.Nested(p, "x");
            LmxOccurrence h = LmxOccurrence.Independent(a);
            check("store keeps A.node==P", object.ReferenceEquals(a.Node, p));
            check("H does not become A.node", !object.ReferenceEquals(a.Node, h));
            check("H holds same A ref", object.ReferenceEquals(h.Child(0), a));
        }

        private static void testMergeCopy()
        {
            LmxOccurrence p = LmxOccurrence.Independent("P");
            LmxOccurrence a = LmxOccurrence.Nested(p, "A");
            LmxOccurrence h = LmxOccurrence.Independent(a);
            LmxOccurrence m = LmxOccurrence.Merge(h);
            LmxOccurrence aCopy = (LmxOccurrence)m.Child(0);
            check("A_copy != A", !object.ReferenceEquals(aCopy, a));
            check("A_copy.node != merge root", !object.ReferenceEquals(aCopy.Node, m));
        }

        private static void testBounds()
        {
            LmxOccurrence o = LmxOccurrence.Independent(1);
            bool threw = false;
            try { o.Child(1); } catch (IndexOutOfRangeException) { threw = true; }
            check("bounds rejected", threw);
        }
    }
}
