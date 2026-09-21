using System;
using System.IO;
using System.Reflection;
using Emitter;
using Graph;
using Lmx;

namespace Smoke
{
    public static class CilExprSmokeDriver
    {
        private static int checks;
        private static int fails;
        private static string workDir;

        public static int Main(string[] args)
        {
            checks = 0;
            fails = 0;
            workDir = Path.Combine(Path.GetTempPath(), "vm_cil_l3_" + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(workDir);
            try
            {
                testSubjectFieldFollowAdd();
                testIfTrueFalse();
                testNestedReturnFromIf();
                testArg0FieldFollow();
                testEmittedPeReloadAndSignature();
                testCleanOutputNoPublishOnReject();
                testDistinctRoleIdentityRejected();
                testUnsupportedRejected();
                testBadArityRejected();
                testNullChildRejected();
                testOwnershipCycleRejected();
                testBadEntryRejected();
                testFieldFollowBadBaseRejected();
                testChildrenDefensiveCopy();

                testCallHelperTwoInts();
                testNestedReturnEvalOnce();
                testRecursiveCountdown();
                testMutualEvenOdd();
                testSubjectIdentityThroughCallee();
                testReloadAfterCallEmit();
                testUnsealedRejected();
                testDoubleSealRejected();
                testFailedSealLeavesUnsealed();
                testCallWrongTargetRejected();
                testCallWrongArityRejected();
                testBadArgRejected();
                testLegalCallCycleNotOwnershipCycle();

                testLocalsSetGet();
                testWhileInitialFalse();
                testWhileCountdown();
                testNestedBreakNearest();
                testContinueRechecks();
                testRedoSkipsProbe();
                testRecursiveFreshLocals();
                testNestedReturnFromWhile();
                testLocalGetUnassignedRejected();
                testBreakOutsideRejected();
                testWhileValueContextRejected();
                testWhileBadArityRejected();
            }
            finally
            {
                try { Directory.Delete(workDir, true); } catch { }
            }
            if (fails != 0)
            {
                Console.WriteLine("FAIL CilExprSmokeDriver checks=" + checks + " failures=" + fails);
                return 1;
            }
            Console.WriteLine("PASS CilExprSmokeDriver checks=" + checks + " failures=0");
            return 0;
        }

        private static void check(string name, bool ok)
        {
            checks++;
            if (!ok)
            {
                fails++;
                Console.WriteLine("FAIL " + name);
            }
        }

        private static int Eval(L3Node entry, LmxOccurrence subject, string peName)
        {
            string pe = Path.Combine(workDir, peName);
            L3CilEmitter.EmitCallableToPe(entry, pe);
            MethodInfo m = L3CilEmitter.LoadEval(pe);
            return (int)m.Invoke(null, new object[] { subject });
        }

        private static void testSubjectFieldFollowAdd()
        {
            check("subject field0+5 -> 12", Eval(L3ExprFixture.SubjectField0Plus5(), LmxOccurrence.Independent(7), "field_add.dll") == 12);
        }

        private static void testIfTrueFalse()
        {
            LmxOccurrence subj = LmxOccurrence.Independent(0);
            check("IF true -> 11", Eval(L3ExprFixture.IfTrueLiteral(), subj, "if_t.dll") == 11);
            check("IF false -> 22", Eval(L3ExprFixture.IfFalseLiteral(), subj, "if_f.dll") == 22);
        }

        private static void testNestedReturnFromIf()
        {
            check("nested RETURN from IF -> 10", Eval(L3ExprFixture.NestedReturnFromIf(), LmxOccurrence.Independent(0), "nret.dll") == 10);
        }

        private static void testArg0FieldFollow()
        {
            check("ARG(0) field0 -> 42", Eval(L3ExprFixture.Arg0Field0(), LmxOccurrence.Independent(42), "arg0.dll") == 42);
        }

        private static void testEmittedPeReloadAndSignature()
        {
            string pe = Path.Combine(workDir, "sig.dll");
            L3CilEmitter.EmitCallableToPe(L3ExprFixture.IfTrueLiteral(), pe);
            check("PE file exists", File.Exists(pe));
            byte[] raw = File.ReadAllBytes(pe);
            check("PE has MZ header", raw.Length > 2 && raw[0] == (byte)'M' && raw[1] == (byte)'Z');
            MethodInfo m = L3CilEmitter.LoadEval(pe);
            check("Eval name", m.Name == L3CilEmitter.EvalMethodName);
            check("Eval returns int", m.ReturnType == typeof(int));
            check("Eval arity 1", m.GetParameters().Length == 1);
            check("Eval arg LmxOccurrence", m.GetParameters()[0].ParameterType == typeof(LmxOccurrence));
            int once = (int)m.Invoke(null, new object[] { LmxOccurrence.Independent(0) });
            MethodInfo m2 = L3CilEmitter.LoadEval(pe);
            int twice = (int)m2.Invoke(null, new object[] { LmxOccurrence.Independent(0) });
            check("reload deterministic 11", once == 11 && twice == 11);
        }

        private static void testCleanOutputNoPublishOnReject()
        {
            string pe = Path.Combine(workDir, "reject_no_publish.dll");
            if (File.Exists(pe)) File.Delete(pe);
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.UnsupportedRoleGraph(), pe); }
            catch (ArgumentException) { threw = true; }
            check("unsupported throws", threw);
            check("no PE published on reject", !File.Exists(pe));
        }

        private static void testDistinctRoleIdentityRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.DistinctRoleRejected(), Path.Combine(workDir, "distinct.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("unsupported") >= 0; }
            check("distinct same-shaped role rejected by identity", threw);
        }

        private static void testUnsupportedRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.UnsupportedRoleGraph(), Path.Combine(workDir, "unsup.dll")); }
            catch (ArgumentException) { threw = true; }
            check("UNSUPPORTED rejected", threw);
        }

        private static void testBadArityRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.BadArityAdd(), Path.Combine(workDir, "arity.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("ADD arity") >= 0; }
            check("ADD bad arity rejected", threw);
        }

        private static void testNullChildRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.NullChildReturn(), Path.Combine(workDir, "nullc.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("null child") >= 0; }
            check("null child rejected", threw);
        }

        private static void testOwnershipCycleRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.OwnershipCycle(), Path.Combine(workDir, "cycle.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("ownership cycle") >= 0; }
            check("ownership cycle rejected", threw);
        }

        private static void testBadEntryRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.BadEntryNotCallable(), Path.Combine(workDir, "entry.dll")); }
            catch (Exception e) { threw = e.Message != null && e.Message.IndexOf("CALLABLE") >= 0; }
            check("bad entry shape rejected", threw);
        }

        private static void testFieldFollowBadBaseRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.FieldFollowBadBase(), Path.Combine(workDir, "ffbase.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("occurrence base") >= 0; }
            check("FIELD_FOLLOW bad base rejected", threw);
        }

        private static void testChildrenDefensiveCopy()
        {
            L3Node[] arr = new L3Node[] { L3Node.OfInt(L3Role.INT_LITERAL, 1), L3Node.OfInt(L3Role.INT_LITERAL, 2) };
            L3Node add = new L3Node(L3Role.ADD, 0, arr);
            arr[0] = L3Node.OfInt(L3Role.INT_LITERAL, 99);
            check("defensive copy: alias mutation does not affect node", add.Child(0).IntPayload == 1);
        }

        private static void testCallHelperTwoInts()
        {
            check("CALL helper two ints -> 12", Eval(L3ExprFixture.CallHelperTwoInts(), LmxOccurrence.Independent(7), "call2.dll") == 12);
        }

        private static void testNestedReturnEvalOnce()
        {
            EvalCounter.Reset();
            int r = Eval(L3ExprFixture.NestedReturnEvalOnce(), LmxOccurrence.Independent(0), "evalonce.dll");
            check("nested RETURN eval-once result -> 2", r == 2);
            check("nested RETURN eval-once probe ticks 1", EvalCounter.Get() == 1);
        }

        private static void testRecursiveCountdown()
        {
            check("recursive countdown 3 -> 3", Eval(L3ExprFixture.RecursiveCountdown(), LmxOccurrence.Independent(3), "rec.dll") == 3);
        }

        private static void testMutualEvenOdd()
        {
            check("mutual even(4) -> 1", Eval(L3ExprFixture.MutualEvenOdd(), LmxOccurrence.Independent(4), "even.dll") == 1);
            check("mutual even(3) -> 0", Eval(L3ExprFixture.MutualEvenOdd(), LmxOccurrence.Independent(3), "odd.dll") == 0);
        }

        private static void testSubjectIdentityThroughCallee()
        {
            check("subject identity through callee -> 9", Eval(L3ExprFixture.SubjectIdentityThroughCallee(), LmxOccurrence.Independent(9), "id.dll") == 9);
        }

        private static void testReloadAfterCallEmit()
        {
            string pe = Path.Combine(workDir, "reload_call.dll");
            L3CilEmitter.EmitCallableToPe(L3ExprFixture.CallHelperTwoInts(), pe);
            MethodInfo m = L3CilEmitter.LoadEval(pe);
            int a = (int)m.Invoke(null, new object[] { LmxOccurrence.Independent(10) });
            MethodInfo m2 = L3CilEmitter.LoadEval(pe);
            int b = (int)m2.Invoke(null, new object[] { LmxOccurrence.Independent(10) });
            check("reload CALL PE deterministic 15", a == 15 && b == 15);
        }

        private static void testUnsealedRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.UnsealedCallableGraph(), Path.Combine(workDir, "unsealed.dll")); }
            catch (Exception e) { threw = e.Message != null && e.Message.IndexOf("unsealed") >= 0; }
            check("unsealed CALLABLE rejected", threw);
        }

        private static void testDoubleSealRejected()
        {
            L3Node c = L3Node.UnsealedCallable();
            c.Seal(L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.INT_LITERAL, 1)));
            bool threw = false;
            try { c.Seal(L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.INT_LITERAL, 2))); }
            catch (InvalidOperationException) { threw = true; }
            check("double seal rejected", threw);
            check("still sealed after failed double seal", c.IsSealed);
        }

        private static void testFailedSealLeavesUnsealed()
        {
            L3Node c = L3Node.UnsealedCallable();
            bool threw = false;
            try { c.Seal(null); }
            catch (ArgumentException) { threw = true; }
            check("failed seal throws", threw);
            check("failed seal leaves unsealed", !c.IsSealed);
            c.Seal(L3Node.Of(L3Role.RETURN, L3Node.OfInt(L3Role.INT_LITERAL, 3)));
            check("retry seal after failed null succeeds", c.IsSealed);
            check("retry seal body", Eval(c, LmxOccurrence.Independent(0), "retry_seal.dll") == 3);
        }

        private static void testCallWrongTargetRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.CallWrongTarget(), Path.Combine(workDir, "badtgt.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("CALLABLE") >= 0; }
            check("CALL wrong target rejected", threw);
        }

        private static void testCallWrongArityRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.CallWrongArity(), Path.Combine(workDir, "badcallarity.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("CALL arity") >= 0; }
            check("CALL wrong arity rejected", threw);
        }

        private static void testBadArgRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.BadArgInIntContext(), Path.Combine(workDir, "badarg.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("ARG") >= 0; }
            check("ARG(0) in int context rejected", threw);
        }

        private static void testLegalCallCycleNotOwnershipCycle()
        {
            // Self-recursive graph must emit (CALL edge is non-ownership).
            int r = Eval(L3ExprFixture.RecursiveCountdown(), LmxOccurrence.Independent(2), "legal_cycle.dll");
            check("legal CALL cycle accepted (countdown 2 -> 2)", r == 2);
        }

        private static void testLocalsSetGet()
        {
            check("locals set/get arithmetic -> 7", Eval(L3ExprFixture.LocalsSetGetArithmetic(), LmxOccurrence.Independent(0), "loc.dll") == 7);
        }

        private static void testWhileInitialFalse()
        {
            check("WHILE initial-false -> 0", Eval(L3ExprFixture.WhileInitialFalse(), LmxOccurrence.Independent(0), "w0.dll") == 0);
        }

        private static void testWhileCountdown()
        {
            check("WHILE countdown -> 0", Eval(L3ExprFixture.WhileCountdown(), LmxOccurrence.Independent(0), "w3.dll") == 0);
        }

        private static void testNestedBreakNearest()
        {
            check("nested BREAK nearest -> 2", Eval(L3ExprFixture.NestedBreakNearest(), LmxOccurrence.Independent(0), "nbrk.dll") == 2);
        }

        private static void testContinueRechecks()
        {
            check("CONTINUE rechecks condition -> 3", Eval(L3ExprFixture.ContinueRechecksCondition(), LmxOccurrence.Independent(0), "cont.dll") == 3);
        }

        private static void testRedoSkipsProbe()
        {
            EvalCounter.Reset();
            int r = Eval(L3ExprFixture.RedoSkipsConditionProbe(), LmxOccurrence.Independent(0), "redo.dll");
            check("REDO skips condition -> n==2", r == 2);
            check("REDO skips condition probe ticks 1", EvalCounter.Get() == 1);
        }

        private static void testRecursiveFreshLocals()
        {
            check("recursive fresh locals countdown 3 -> 3", Eval(L3ExprFixture.RecursiveFreshLocals(), LmxOccurrence.Independent(3), "rloc.dll") == 3);
        }

        private static void testNestedReturnFromWhile()
        {
            check("nested RETURN from WHILE -> 77", Eval(L3ExprFixture.NestedReturnFromWhile(), LmxOccurrence.Independent(0), "nrw.dll") == 77);
        }

        private static void testLocalGetUnassignedRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.LocalGetUnassigned(), Path.Combine(workDir, "unass.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("unassigned") >= 0; }
            check("LOCAL_GET unassigned rejected", threw);
        }

        private static void testBreakOutsideRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.BreakOutsideLoop(), Path.Combine(workDir, "brkout.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("outside loop") >= 0; }
            check("BREAK outside loop rejected", threw);
        }

        private static void testWhileValueContextRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.WhileInValueContext(), Path.Combine(workDir, "wval.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("value context") >= 0; }
            check("WHILE in value context rejected", threw);
        }

        private static void testWhileBadArityRejected()
        {
            bool threw = false;
            try { L3CilEmitter.EmitCallableToPe(L3ExprFixture.WhileBadArity(), Path.Combine(workDir, "warity.dll")); }
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("WHILE arity") >= 0; }
            check("WHILE bad arity rejected", threw);
        }
    }
}
