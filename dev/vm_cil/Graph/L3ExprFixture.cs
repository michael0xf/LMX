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

        /** helper(s,a,b)=a+b; entry calls helper(subject, subject[0], 5). */
        public static L3Node CallHelperTwoInts()
        {
            L3Node helper = L3Node.Of(
                L3Role.CALLABLE,
                L3Node.Of(
                    L3Role.RETURN,
                    L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.ARG, 1), L3Node.OfInt(L3Role.ARG, 2))));
            L3Node subject = L3Node.Of(L3Role.SUBJECT_REF);
            L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
            L3Node call = L3Node.Of(
                L3Role.CALL, helper, L3Node.Of(L3Role.SUBJECT_REF), field0, L3Node.OfInt(L3Role.INT_LITERAL, 5));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, call));
        }

        /** Nested RETURN short-circuit: IF(1, RETURN(PROBE+1), PROBE) — else arm not evaluated. */
        public static L3Node NestedReturnEvalOnce()
        {
            L3Node thenRet = L3Node.Of(
                L3Role.RETURN,
                L3Node.Of(L3Role.ADD, L3Node.Of(L3Role.PROBE), L3Node.OfInt(L3Role.INT_LITERAL, 1)));
            L3Node elseArm = L3Node.Of(L3Role.PROBE);
            L3Node iff = L3Node.Of(L3Role.IF, L3Node.OfInt(L3Role.INT_LITERAL, 1), thenRet, elseArm);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, iff));
        }

        public static L3Node RecursiveCountdown()
        {
            L3Node self = L3Node.UnsealedCallable();
            L3Node n = L3Node.OfInt(L3Role.ARG, 1);
            L3Node dec = L3Node.Of(L3Role.ADD, n, L3Node.OfInt(L3Role.INT_LITERAL, -1));
            L3Node rec = L3Node.Of(L3Role.CALL, self, L3Node.OfInt(L3Role.ARG, 0), dec);
            L3Node onePlus = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.INT_LITERAL, 1), rec);
            L3Node iff = L3Node.Of(L3Role.IF, L3Node.OfInt(L3Role.ARG, 1), onePlus, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            self.Seal(L3Node.Of(L3Role.RETURN, iff));
            L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.Of(L3Role.SUBJECT_REF));
            L3Node call = L3Node.Of(L3Role.CALL, self, L3Node.Of(L3Role.SUBJECT_REF), field0);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, call));
        }

        public static L3Node MutualEvenOdd()
        {
            L3Node even = L3Node.UnsealedCallable();
            L3Node odd = L3Node.UnsealedCallable();
            L3Node n = L3Node.OfInt(L3Role.ARG, 1);
            L3Node dec = L3Node.Of(L3Role.ADD, n, L3Node.OfInt(L3Role.INT_LITERAL, -1));
            L3Node callOdd = L3Node.Of(L3Role.CALL, odd, L3Node.OfInt(L3Role.ARG, 0), dec);
            L3Node callEven = L3Node.Of(L3Role.CALL, even, L3Node.OfInt(L3Role.ARG, 0), dec);
            L3Node evenBody = L3Node.Of(
                L3Role.IF, n, callOdd, L3Node.OfInt(L3Role.INT_LITERAL, 1));
            L3Node oddBody = L3Node.Of(
                L3Role.IF, n, callEven, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            even.Seal(L3Node.Of(L3Role.RETURN, evenBody));
            odd.Seal(L3Node.Of(L3Role.RETURN, oddBody));
            L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.Of(L3Role.SUBJECT_REF));
            L3Node call = L3Node.Of(L3Role.CALL, even, L3Node.Of(L3Role.SUBJECT_REF), field0);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, call));
        }

        /** Callee returns subject[0]; entry CALL preserves subject identity. */
        public static L3Node SubjectIdentityThroughCallee()
        {
            L3Node leaf = L3Node.Of(
                L3Role.CALLABLE,
                L3Node.Of(L3Role.RETURN, new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.OfInt(L3Role.ARG, 0))));
            L3Node call = L3Node.Of(L3Role.CALL, leaf, L3Node.Of(L3Role.SUBJECT_REF));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, call));
        }

        public static L3Node UnsupportedRoleGraph()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.UNSUPPORTED)));
        }

        public static L3Node DistinctRoleRejected()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, new L3Node(L3Role.DistinctForTest(), 0)));
        }

        public static L3Node BadArityAdd()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.INT_LITERAL, 1))));
        }

        public static L3Node NullChildReturn()
        {
            return L3Node.AdoptChildrenForTest(L3Role.CALLABLE, new L3Node[] {
                L3Node.AdoptChildrenForTest(L3Role.RETURN, new L3Node[] { null })
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
            L3Node ff = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, ff));
        }

        public static L3Node UnsealedCallableGraph()
        {
            return L3Node.UnsealedCallable();
        }

        public static L3Node CallWrongArity()
        {
            L3Node helper = L3Node.Of(
                L3Role.CALLABLE,
                L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.ARG, 1)));
            L3Node call = L3Node.Of(L3Role.CALL, helper, L3Node.Of(L3Role.SUBJECT_REF)); // missing int arg
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, call));
        }

        public static L3Node CallWrongTarget()
        {
            L3Node notCallable = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.INT_LITERAL, 1), L3Node.OfInt(L3Role.INT_LITERAL, 2));
            L3Node call = L3Node.Of(L3Role.CALL, notCallable, L3Node.Of(L3Role.SUBJECT_REF));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, call));
        }

        public static L3Node BadArgInIntContext()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.ARG, 0)));
        }

        // --- locals / WHILE (GROK-BOT-CIL-L3-LOCALS-WHILE-20260921-103) ---

        public static L3Node LocalsSetGetArithmetic()
        {
            L3Node set0 = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 3));
            L3Node set1 = new L3Node(L3Role.LOCAL_SET, 1, L3Node.OfInt(L3Role.INT_LITERAL, 4));
            L3Node add = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.LOCAL_GET, 1));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, set0, set1, add)));
        }

        public static L3Node WhileInitialFalse()
        {
            L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            L3Node body = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 99));
            L3Node w = L3Node.Of(L3Role.WHILE, L3Node.OfInt(L3Role.LOCAL_GET, 0), body);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, init, w, L3Node.OfInt(L3Role.LOCAL_GET, 0))));
        }

        public static L3Node WhileCountdown()
        {
            L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 3));
            L3Node dec = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, -1));
            L3Node body = new L3Node(L3Role.LOCAL_SET, 0, dec);
            L3Node w = L3Node.Of(L3Role.WHILE, L3Node.OfInt(L3Role.LOCAL_GET, 0), body);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, init, w, L3Node.OfInt(L3Role.LOCAL_GET, 0))));
        }

        public static L3Node NestedBreakNearest()
        {
            L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            L3Node incr = new L3Node(L3Role.LOCAL_SET, 0, L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, 1)));
            L3Node inner = L3Node.Of(L3Role.WHILE, L3Node.OfInt(L3Role.INT_LITERAL, 1), L3Node.Of(L3Role.BREAK));
            L3Node ge2 = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, -2));
            L3Node ifBreak = L3Node.Of(L3Role.IF, ge2, L3Node.OfInt(L3Role.INT_LITERAL, 0), L3Node.Of(L3Role.BREAK));
            L3Node outerBody = L3Node.Of(L3Role.SEQUENCE, incr, inner, ifBreak);
            L3Node outer = L3Node.Of(L3Role.WHILE, L3Node.OfInt(L3Role.INT_LITERAL, 1), outerBody);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, init, outer, L3Node.OfInt(L3Role.LOCAL_GET, 0))));
        }

        public static L3Node ContinueRechecksCondition()
        {
            L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            L3Node incr = new L3Node(L3Role.LOCAL_SET, 0, L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, 1)));
            L3Node body = L3Node.Of(L3Role.SEQUENCE, incr, L3Node.Of(L3Role.CONTINUE));
            L3Node eq3 = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, -3));
            // WHILE continues while nonzero: IF(n-3,1,0) — nonzero when n!=3
            L3Node cond = L3Node.Of(L3Role.IF, eq3, L3Node.OfInt(L3Role.INT_LITERAL, 1), L3Node.OfInt(L3Role.INT_LITERAL, 0));
            L3Node w = L3Node.Of(L3Role.WHILE, cond, body);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, init, w, L3Node.OfInt(L3Role.LOCAL_GET, 0))));
        }

        public static L3Node RedoSkipsConditionProbe()
        {
            L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            L3Node incr = new L3Node(L3Role.LOCAL_SET, 0, L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, 1)));
            L3Node eq1 = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, -1));
            L3Node ifRedo = L3Node.Of(L3Role.IF, eq1, L3Node.OfInt(L3Role.INT_LITERAL, 0), L3Node.Of(L3Role.REDO));
            L3Node ge2 = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, -2));
            L3Node ifBreak = L3Node.Of(L3Role.IF, ge2, L3Node.OfInt(L3Role.INT_LITERAL, 0), L3Node.Of(L3Role.BREAK));
            L3Node body = L3Node.Of(L3Role.SEQUENCE, incr, ifRedo, ifBreak);
            L3Node cond = L3Node.Of(L3Role.SEQUENCE, L3Node.Of(L3Role.PROBE), L3Node.OfInt(L3Role.INT_LITERAL, 1));
            L3Node w = L3Node.Of(L3Role.WHILE, cond, body);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, init, w, L3Node.OfInt(L3Role.LOCAL_GET, 0))));
        }

        /** Recursive with local: f(n) uses local slot; fresh per activation. */
        public static L3Node RecursiveFreshLocals()
        {
            L3Node self = L3Node.UnsealedCallable();
            L3Node set = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.ARG, 1));
            L3Node dec = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.LOCAL_GET, 0), L3Node.OfInt(L3Role.INT_LITERAL, -1));
            L3Node rec = L3Node.Of(L3Role.CALL, self, L3Node.OfInt(L3Role.ARG, 0), dec);
            L3Node onePlus = L3Node.Of(L3Role.ADD, L3Node.OfInt(L3Role.INT_LITERAL, 1), rec);
            L3Node iff = L3Node.Of(L3Role.IF, L3Node.OfInt(L3Role.LOCAL_GET, 0), onePlus, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            self.Seal(L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, set, iff)));
            L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.Of(L3Role.SUBJECT_REF));
            L3Node call = L3Node.Of(L3Role.CALL, self, L3Node.Of(L3Role.SUBJECT_REF), field0);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, call));
        }

        public static L3Node NestedReturnFromWhile()
        {
            L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.OfInt(L3Role.INT_LITERAL, 0));
            L3Node body = L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.INT_LITERAL, 77));
            L3Node w = L3Node.Of(L3Role.WHILE, L3Node.OfInt(L3Role.INT_LITERAL, 1), body);
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, init, w, L3Node.OfInt(L3Role.INT_LITERAL, 0))));
        }

        public static L3Node LocalGetUnassigned()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.LOCAL_GET, 0)));
        }

        public static L3Node BreakOutsideLoop()
        {
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, L3Node.Of(L3Role.BREAK), L3Node.OfInt(L3Role.INT_LITERAL, 0))));
        }

        public static L3Node WhileInValueContext()
        {
            L3Node w = L3Node.Of(L3Role.WHILE, L3Node.OfInt(L3Role.INT_LITERAL, 0), L3Node.OfInt(L3Role.INT_LITERAL, 0));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, w));
        }

        public static L3Node WhileBadArity()
        {
            L3Node w = L3Node.Of(L3Role.WHILE, L3Node.OfInt(L3Role.INT_LITERAL, 1));
            return L3Node.Of(L3Role.CALLABLE, L3Node.Of(L3Role.RETURN, L3Node.Of(L3Role.SEQUENCE, w, L3Node.OfInt(L3Role.INT_LITERAL, 0))));
        }
    }
}
