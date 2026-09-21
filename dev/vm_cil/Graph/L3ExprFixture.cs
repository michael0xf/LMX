using System;

namespace Graph
{
    public static class L3ExprFixture
    {
        public static L3Node SubjectField0Plus5()
        {
            L3Node subject = L3Node.Of(L3Role.SUBJECT_REF);
            L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
            L3Node add = L3Node.Of(L3Role.ADD, field0, L3Node.OfInt(L3Role.INT_LITERAL, 5));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, add));
        }

        public static L3Node IfTrueLiteral()
        {
            L3Node iff = L3Node.Of(
                L3Role.IF,
                L3Node.OfInt(L3Role.INT_LITERAL, 1),
                L3Node.OfInt(L3Role.INT_LITERAL, 11),
                L3Node.OfInt(L3Role.INT_LITERAL, 22));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, iff));
        }

        public static L3Node IfFalseLiteral()
        {
            L3Node iff = L3Node.Of(
                L3Role.IF,
                L3Node.OfInt(L3Role.INT_LITERAL, 0),
                L3Node.OfInt(L3Role.INT_LITERAL, 11),
                L3Node.OfInt(L3Role.INT_LITERAL, 22));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, iff));
        }

        public static L3Node NestedReturnFromIf()
        {
            L3Node thenRet = L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.INT_LITERAL, 10));
            L3Node elseRet = L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.INT_LITERAL, 20));
            L3Node body = L3Node.Of(
                L3Role.SEQUENCE,
                L3Node.Of(L3Role.IF, L3Node.OfInt(L3Role.INT_LITERAL, 1), thenRet, elseRet),
                L3Node.OfInt(L3Role.INT_LITERAL, 99));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, body));
        }

        public static L3Node Arg0Field0()
        {
            L3Node arg0 = L3Node.OfInt(L3Role.ARG, 0);
            L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, arg0);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, field0));
        }

        public static L3Node UnsupportedRoleGraph()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.UNSUPPORTED)));
        }

        public static L3Node DistinctRoleRejected()
        {
            L3Role impostor = L3Role.DistinctForTest();
            L3Node bad = new L3Node(impostor, 0);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, bad));
        }

        public static L3Node BadArityAdd()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.INT_LITERAL, 1))));
        }

        public static L3Node NullChildReturn()
        {
            L3Node[] kids = new L3Node[] { null };
            return L3Node.AdoptChildrenForTest(L3Role.CALLABLE, new L3Node[] {
                L3Node.AdoptChildrenForTest(L3Role.RETURN, kids)
            });
        }

        public static L3Node OwnershipCycle()
        {
            L3Node[] slot = new L3Node[2];
            L3Node add = L3Node.AdoptChildrenForTest(L3Role.ADD, slot);
            slot[0] = L3Node.OfInt(L3Role.INT_LITERAL, 1);
            slot[1] = add;
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, add));
        }

        public static L3Node BadEntryNotCallable()
        {
            return L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.INT_LITERAL, 1));
        }

        public static L3Node FieldFollowBadBase()
        {
            L3Node lit = L3Node.OfInt(L3Role.INT_LITERAL, 0);
            L3Node ff = new L3Node(L3Role.FIELD_FOLLOW, 0, lit);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, ff));
        }
    }
}
