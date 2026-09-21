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
            LmxOccurrence subj = LmxOccurrence.Independent(7);
            int r = Eval(L3ExprFixture.SubjectField0Plus5(), subj, "field_add.dll");
            check("subject field0+5 -> 12", r == 12);
        }

        private static void testIfTrueFalse()
        {
            LmxOccurrence subj = LmxOccurrence.Independent(0);
            check("IF true -> 11", Eval(L3ExprFixture.IfTrueLiteral(), subj, "if_t.dll") == 11);
            check("IF false -> 22", Eval(L3ExprFixture.IfFalseLiteral(), subj, "if_f.dll") == 22);
        }

        private static void testNestedReturnFromIf()
        {
            LmxOccurrence subj = LmxOccurrence.Independent(0);
            check("nested RETURN from IF -> 10", Eval(L3ExprFixture.NestedReturnFromIf(), subj, "nret.dll") == 10);
        }

        private static void testArg0FieldFollow()
        {
            LmxOccurrence subj = LmxOccurrence.Independent(42);
            check("ARG(0) field0 -> 42", Eval(L3ExprFixture.Arg0Field0(), subj, "arg0.dll") == 42);
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
            ParameterInfo[] ps = m.GetParameters();
            check("Eval arity 1", ps.Length == 1);
            check("Eval arg LmxOccurrence", ps[0].ParameterType == typeof(LmxOccurrence));
            int once = (int)m.Invoke(null, new object[] { LmxOccurrence.Independent(0) });
            Assembly asm2 = Assembly.LoadFrom(pe);
            MethodInfo m2 = asm2.GetType(L3CilEmitter.GeneratedTypeName, true)
                .GetMethod(L3CilEmitter.EvalMethodName, BindingFlags.Public | BindingFlags.Static);
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
            catch (ArgumentException e) { threw = e.Message != null && e.Message.IndexOf("CALLABLE") >= 0; }
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
    }
}
