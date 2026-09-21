using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Reflection.Emit;
using System.Runtime.CompilerServices;
using Graph;
using Lmx;

namespace Emitter
{
    public static class L3CilEmitter
    {
        public const string EvalMethodName = "Eval";
        public const string GeneratedTypeName = "L3Gen.EvalHost";

        public static string EmitCallableToPe(L3Node entry, string pePath)
        {
            if (pePath == null) throw new ArgumentException("pePath");
            if (entry == null || !object.ReferenceEquals(entry.Role, L3Role.CALLABLE))
                throw new ArgumentException("expected CALLABLE root");
            List<L3Node> order = new List<L3Node>();
            Dictionary<L3Node, int> map = new Dictionary<L3Node, int>(RefCmp.Instance);
            CollectCallables(entry, order, map);
            Dictionary<L3Node, int> arity = new Dictionary<L3Node, int>(RefCmp.Instance);
            for (int i = 0; i < order.Count; i++)
                arity[order[i]] = ComputeArity(order[i]);
            ValidateAll(order, map, arity);

            if (File.Exists(pePath)) File.Delete(pePath);
            string fullPath = Path.GetFullPath(pePath);
            string dir = Path.GetDirectoryName(fullPath);
            string fileName = Path.GetFileName(fullPath);
            string unique = "L3CilGen_" + Guid.NewGuid().ToString("N");
            AssemblyName an = new AssemblyName(unique);
            AssemblyBuilder ab = AppDomain.CurrentDomain.DefineDynamicAssembly(
                an, AssemblyBuilderAccess.Save, dir);
            ModuleBuilder mb = ab.DefineDynamicModule(fileName, fileName);
            TypeBuilder tb = mb.DefineType(
                GeneratedTypeName,
                TypeAttributes.Public | TypeAttributes.Sealed | TypeAttributes.Abstract);

            MethodBuilder[] methods = new MethodBuilder[order.Count];
            for (int i = 0; i < order.Count; i++)
            {
                int a = arity[order[i]];
                Type[] ps = ParamTypes(a);
                methods[i] = tb.DefineMethod(
                    "c" + i,
                    MethodAttributes.Public | MethodAttributes.Static,
                    typeof(int),
                    ps);
            }

            MethodBuilder eval = tb.DefineMethod(
                EvalMethodName,
                MethodAttributes.Public | MethodAttributes.Static,
                typeof(int),
                new Type[] { typeof(LmxOccurrence) });

            for (int i = 0; i < order.Count; i++)
            {
                ILGenerator il = methods[i].GetILGenerator();
                EmitReturnBody(il, order[i].Child(0), map, arity, methods, arity[order[i]]);
            }

            // public Eval(subject) -> call entry method (arity must be 1 = subject only)
            int entryArity = arity[entry];
            if (entryArity != 1)
                throw new ArgumentException("entry CALLABLE must take only subject (arity 1)");
            ILGenerator eil = eval.GetILGenerator();
            eil.Emit(OpCodes.Ldarg_0);
            eil.Emit(OpCodes.Call, methods[map[entry]]);
            eil.Emit(OpCodes.Ret);

            tb.CreateType();
            ab.Save(fileName);
            if (!File.Exists(fullPath))
                throw new InvalidOperationException("PE not written: " + fullPath);
            return fullPath;
        }

        public static MethodInfo LoadEval(string pePath)
        {
            Assembly asm = Assembly.LoadFrom(pePath);
            Type t = asm.GetType(GeneratedTypeName, true);
            MethodInfo m = t.GetMethod(EvalMethodName, BindingFlags.Public | BindingFlags.Static);
            if (m == null) throw new InvalidOperationException("Eval missing");
            ParameterInfo[] ps = m.GetParameters();
            if (m.ReturnType != typeof(int) || ps.Length != 1 || ps[0].ParameterType != typeof(LmxOccurrence))
                throw new InvalidOperationException("Eval signature mismatch");
            return m;
        }

        private static Type[] ParamTypes(int arity)
        {
            // arity = max ARG index + 1; 0 = subject
            Type[] ps = new Type[arity];
            ps[0] = typeof(LmxOccurrence);
            for (int i = 1; i < arity; i++) ps[i] = typeof(int);
            return ps;
        }

        private static void CollectCallables(L3Node entry, List<L3Node> order, Dictionary<L3Node, int> map)
        {
            WalkCollect(entry, order, map, new Dictionary<L3Node, bool>(RefCmp.Instance), new Dictionary<L3Node, bool>(RefCmp.Instance));
        }

        private static void WalkCollect(
            L3Node n, List<L3Node> order, Dictionary<L3Node, int> map,
            Dictionary<L3Node, bool> gray, Dictionary<L3Node, bool> black)
        {
            if (n == null) return;
            if (object.ReferenceEquals(n.Role, L3Role.CALLABLE))
            {
                if (map.ContainsKey(n)) return;
                RequireSealed(n);
                map[n] = order.Count;
                order.Add(n);
                GrayEnter(n, gray);
                try
                {
                    for (int i = 0; i < n.ChildCount; i++)
                        WalkCollect(n.Child(i), order, map, gray, black);
                }
                finally { gray.Remove(n); black[n] = true; }
                return;
            }
            if (black.ContainsKey(n)) return;
            GrayEnter(n, gray);
            try
            {
                if (object.ReferenceEquals(n.Role, L3Role.CALL))
                {
                    if (n.ChildCount < 1) throw new ArgumentException("CALL needs callee child");
                    L3Node callee = n.Child(0);
                    if (callee == null || !object.ReferenceEquals(callee.Role, L3Role.CALLABLE))
                        throw new ArgumentException("CALL callee must be CALLABLE node");
                    WalkCollect(callee, order, map, gray, black);
                    for (int i = 1; i < n.ChildCount; i++)
                        WalkCollect(n.Child(i), order, map, gray, black);
                    return;
                }
                for (int i = 0; i < n.ChildCount; i++)
                    WalkCollect(n.Child(i), order, map, gray, black);
            }
            finally { gray.Remove(n); black[n] = true; }
        }

        private static int ComputeArity(L3Node callable)
        {
            int[] max = new int[] { 0 }; // at least subject
            ScanArity(callable.Child(0), max, new Dictionary<L3Node, bool>(RefCmp.Instance), new Dictionary<L3Node, bool>(RefCmp.Instance));
            return max[0] + 1;
        }

        private static void ScanArity(L3Node n, int[] maxIdx, Dictionary<L3Node, bool> gray, Dictionary<L3Node, bool> black)
        {
            if (n == null) return;
            if (object.ReferenceEquals(n.Role, L3Role.CALLABLE)) return;
            if (black.ContainsKey(n)) return;
            GrayEnter(n, gray);
            try
            {
                if (object.ReferenceEquals(n.Role, L3Role.ARG))
                {
                    if (n.IntPayload > maxIdx[0]) maxIdx[0] = n.IntPayload;
                    return;
                }
                if (object.ReferenceEquals(n.Role, L3Role.CALL))
                {
                    for (int i = 1; i < n.ChildCount; i++)
                        ScanArity(n.Child(i), maxIdx, gray, black);
                    return;
                }
                for (int i = 0; i < n.ChildCount; i++)
                    ScanArity(n.Child(i), maxIdx, gray, black);
            }
            finally { gray.Remove(n); black[n] = true; }
        }

        private static void ValidateAll(List<L3Node> order, Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity)
        {
            for (int i = 0; i < order.Count; i++)
            {
                L3Node c = order[i];
                RequireSealed(c);
                if (c.ChildCount != 1 || c.Child(0) == null || !object.ReferenceEquals(c.Child(0).Role, L3Role.RETURN))
                    throw new ArgumentException("CALLABLE body must be a single RETURN");
                if (c.Child(0).ChildCount != 1)
                    throw new ArgumentException("RETURN arity: need exactly one value");
                var gray = new Dictionary<L3Node, bool>(RefCmp.Instance);
                ValidateExpr(c.Child(0), map, arity, c, arity[c], gray);
            }
        }

        private static void RequireSealed(L3Node callable)
        {
            if (callable == null || !object.ReferenceEquals(callable.Role, L3Role.CALLABLE))
                throw new ArgumentException("expected CALLABLE");
            if (!callable.IsSealed)
                throw new InvalidOperationException("unsealed CALLABLE");
            if (callable.ChildCount != 1 || callable.Child(0) == null)
                throw new InvalidOperationException("unsealed/unresolved CALLABLE body");
        }

        private static void ValidateExpr(
            L3Node expr, Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity,
            L3Node currentCallable, int currentArity, Dictionary<L3Node, bool> gray)
        {
            if (expr == null) throw new ArgumentException("null child");
            if (gray.ContainsKey(expr))
                throw new ArgumentException("ownership cycle: gray back-edge");
            gray[expr] = true;
            try
            {
                L3Role r = expr.Role;
                if (object.ReferenceEquals(r, L3Role.RETURN))
                {
                    if (expr.ChildCount != 1) throw new ArgumentException("RETURN arity");
                    ValidateExpr(expr.Child(0), map, arity, currentCallable, currentArity, gray);
                }
                else if (object.ReferenceEquals(r, L3Role.INT_LITERAL) || object.ReferenceEquals(r, L3Role.PROBE))
                {
                    if (expr.ChildCount != 0) throw new ArgumentException("literal/probe arity");
                }
                else if (object.ReferenceEquals(r, L3Role.SUBJECT_REF))
                {
                    if (expr.ChildCount != 0) throw new ArgumentException("SUBJECT_REF arity");
                    throw new ArgumentException("SUBJECT_REF is not an int expression");
                }
                else if (object.ReferenceEquals(r, L3Role.ARG))
                {
                    if (expr.ChildCount != 0) throw new ArgumentException("ARG arity");
                    int idx = expr.IntPayload;
                    if (idx < 1)
                        throw new ArgumentException("ARG out of range for int context (need >= 1)");
                    if (idx >= currentArity)
                        throw new ArgumentException("ARG out of range");
                }
                else if (object.ReferenceEquals(r, L3Role.FIELD_FOLLOW))
                {
                    if (expr.ChildCount != 1) throw new ArgumentException("FIELD_FOLLOW arity");
                    ValidateOccurrenceBase(expr.Child(0), currentArity);
                }
                else if (object.ReferenceEquals(r, L3Role.ADD))
                {
                    if (expr.ChildCount != 2) throw new ArgumentException("ADD arity");
                    ValidateExpr(expr.Child(0), map, arity, currentCallable, currentArity, gray);
                    ValidateExpr(expr.Child(1), map, arity, currentCallable, currentArity, gray);
                }
                else if (object.ReferenceEquals(r, L3Role.IF))
                {
                    if (expr.ChildCount != 3) throw new ArgumentException("IF arity");
                    ValidateExpr(expr.Child(0), map, arity, currentCallable, currentArity, gray);
                    ValidateStmtOrExpr(expr.Child(1), map, arity, currentCallable, currentArity, gray);
                    ValidateStmtOrExpr(expr.Child(2), map, arity, currentCallable, currentArity, gray);
                }
                else if (object.ReferenceEquals(r, L3Role.SEQUENCE))
                {
                    if (expr.ChildCount < 1) throw new ArgumentException("SEQUENCE arity");
                    for (int i = 0; i < expr.ChildCount - 1; i++)
                        ValidateStmtOrExpr(expr.Child(i), map, arity, currentCallable, currentArity, gray);
                    ValidateExpr(expr.Child(expr.ChildCount - 1), map, arity, currentCallable, currentArity, gray);
                }
                else if (object.ReferenceEquals(r, L3Role.CALL))
                {
                    if (expr.ChildCount < 2) throw new ArgumentException("CALL arity: need callee and subject");
                    L3Node callee = expr.Child(0);
                    if (callee == null || !object.ReferenceEquals(callee.Role, L3Role.CALLABLE))
                        throw new ArgumentException("CALL callee must be CALLABLE node");
                    if (!callee.IsSealed) throw new InvalidOperationException("unsealed CALLABLE");
                    if (!map.ContainsKey(callee)) throw new ArgumentException("CALL callee not reachable");
                    int need = arity[callee];
                    int got = expr.ChildCount - 1; // subject + ints
                    if (got != need) throw new ArgumentException("CALL arity mismatch");
                    ValidateOccurrenceBase(expr.Child(1), currentArity);
                    for (int i = 2; i < expr.ChildCount; i++)
                        ValidateExpr(expr.Child(i), map, arity, currentCallable, currentArity, gray);
                }
                else if (object.ReferenceEquals(r, L3Role.UNSUPPORTED))
                {
                    throw new ArgumentException("unsupported role");
                }
                else
                {
                    throw new ArgumentException("unsupported role");
                }
            }
            finally { gray.Remove(expr); }
        }

        private static void ValidateStmtOrExpr(
            L3Node n, Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity,
            L3Node currentCallable, int currentArity, Dictionary<L3Node, bool> gray)
        {
            if (n == null) throw new ArgumentException("null child");
            if (object.ReferenceEquals(n.Role, L3Role.RETURN))
            {
                if (n.ChildCount != 1) throw new ArgumentException("RETURN arity");
                ValidateExpr(n.Child(0), map, arity, currentCallable, currentArity, gray);
                return;
            }
            ValidateExpr(n, map, arity, currentCallable, currentArity, gray);
        }

        private static void ValidateOccurrenceBase(L3Node n, int currentArity)
        {
            if (n == null) throw new ArgumentException("null child");
            if (object.ReferenceEquals(n.Role, L3Role.SUBJECT_REF))
            {
                if (n.ChildCount != 0) throw new ArgumentException("SUBJECT_REF arity");
                return;
            }
            if (object.ReferenceEquals(n.Role, L3Role.ARG) && n.IntPayload == 0)
            {
                if (n.ChildCount != 0) throw new ArgumentException("ARG arity");
                if (currentArity < 1) throw new ArgumentException("ARG out of range");
                return;
            }
            throw new ArgumentException("occurrence base must be SUBJECT_REF or ARG(0)");
        }

        private static void EmitReturnBody(
            ILGenerator il, L3Node retNode,
            Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity,
            MethodBuilder[] methods, int currentArity)
        {
            EmitValue(il, retNode.Child(0), map, arity, methods, currentArity);
            il.Emit(OpCodes.Ret);
        }

        private static void EmitValue(
            ILGenerator il, L3Node expr,
            Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity,
            MethodBuilder[] methods, int currentArity)
        {
            L3Role r = expr.Role;
            if (object.ReferenceEquals(r, L3Role.INT_LITERAL))
            {
                il.Emit(OpCodes.Ldc_I4, expr.IntPayload);
            }
            else if (object.ReferenceEquals(r, L3Role.PROBE))
            {
                MethodInfo tick = typeof(EvalCounter).GetMethod("Tick", Type.EmptyTypes);
                il.Emit(OpCodes.Call, tick);
            }
            else if (object.ReferenceEquals(r, L3Role.ARG))
            {
                il.Emit(OpCodes.Ldarg, expr.IntPayload);
            }
            else if (object.ReferenceEquals(r, L3Role.FIELD_FOLLOW))
            {
                EmitOccurrence(il, expr.Child(0));
                il.Emit(OpCodes.Ldc_I4, expr.IntPayload);
                MethodInfo child = typeof(LmxOccurrence).GetMethod("Child", new Type[] { typeof(int) });
                il.Emit(OpCodes.Callvirt, child);
                il.Emit(OpCodes.Unbox_Any, typeof(int));
            }
            else if (object.ReferenceEquals(r, L3Role.ADD))
            {
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity);
                EmitValue(il, expr.Child(1), map, arity, methods, currentArity);
                il.Emit(OpCodes.Add);
            }
            else if (object.ReferenceEquals(r, L3Role.CALL))
            {
                L3Node callee = expr.Child(0);
                EmitOccurrence(il, expr.Child(1));
                for (int i = 2; i < expr.ChildCount; i++)
                    EmitValue(il, expr.Child(i), map, arity, methods, currentArity);
                il.Emit(OpCodes.Call, methods[map[callee]]);
            }
            else if (object.ReferenceEquals(r, L3Role.IF))
            {
                bool thenRet = object.ReferenceEquals(expr.Child(1).Role, L3Role.RETURN);
                bool elseRet = object.ReferenceEquals(expr.Child(2).Role, L3Role.RETURN);
                Label elseL = il.DefineLabel();
                Label endL = il.DefineLabel();
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity);
                il.Emit(OpCodes.Brfalse, elseL);
                EmitStmtOrValue(il, expr.Child(1), map, arity, methods, currentArity);
                if (!thenRet) il.Emit(OpCodes.Br, endL);
                il.MarkLabel(elseL);
                EmitStmtOrValue(il, expr.Child(2), map, arity, methods, currentArity);
                if (!thenRet || !elseRet) il.MarkLabel(endL);
            }
            else if (object.ReferenceEquals(r, L3Role.SEQUENCE))
            {
                for (int i = 0; i < expr.ChildCount - 1; i++)
                {
                    L3Node ch = expr.Child(i);
                    EmitStmtOrValue(il, ch, map, arity, methods, currentArity);
                    if (object.ReferenceEquals(ch.Role, L3Role.RETURN)) return;
                    if (object.ReferenceEquals(ch.Role, L3Role.IF)
                        && object.ReferenceEquals(ch.Child(1).Role, L3Role.RETURN)
                        && object.ReferenceEquals(ch.Child(2).Role, L3Role.RETURN))
                        return;
                    il.Emit(OpCodes.Pop);
                }
                EmitValue(il, expr.Child(expr.ChildCount - 1), map, arity, methods, currentArity);
            }
            else if (object.ReferenceEquals(r, L3Role.RETURN))
            {
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity);
                il.Emit(OpCodes.Ret);
            }
            else throw new ArgumentException("unsupported role at emit");
        }

        private static void EmitStmtOrValue(
            ILGenerator il, L3Node n,
            Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity,
            MethodBuilder[] methods, int currentArity)
        {
            if (object.ReferenceEquals(n.Role, L3Role.RETURN))
            {
                EmitValue(il, n.Child(0), map, arity, methods, currentArity);
                il.Emit(OpCodes.Ret);
                return;
            }
            EmitValue(il, n, map, arity, methods, currentArity);
        }

        private static void EmitOccurrence(ILGenerator il, L3Node n)
        {
            if (object.ReferenceEquals(n.Role, L3Role.SUBJECT_REF) ||
                (object.ReferenceEquals(n.Role, L3Role.ARG) && n.IntPayload == 0))
            {
                il.Emit(OpCodes.Ldarg_0);
                return;
            }
            throw new ArgumentException("occurrence base must be SUBJECT_REF or ARG(0)");
        }

        private static void GrayEnter(L3Node n, Dictionary<L3Node, bool> gray)
        {
            if (gray.ContainsKey(n))
                throw new ArgumentException("ownership cycle: gray back-edge");
            gray[n] = true;
        }

        private sealed class RefCmp : IEqualityComparer<L3Node>
        {
            public static readonly RefCmp Instance = new RefCmp();
            public bool Equals(L3Node x, L3Node y) { return object.ReferenceEquals(x, y); }
            public int GetHashCode(L3Node obj) { return RuntimeHelpers.GetHashCode(obj); }
        }
    }
}
