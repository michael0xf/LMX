using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Reflection.Emit;
using System.Runtime.CompilerServices;
using System.Threading;
using Graph;
using Lmx;

namespace Emitter
{
    public static class L3CilEmitter
    {
        public const string EvalMethodName = "Eval";
        public const string GeneratedTypeName = "L3Gen.EvalHost";

        private static int LoopDepth;
        private static readonly Stack<Label[]> LoopStack = new Stack<Label[]>();

        public static string EmitCallableToPe(L3Node entry, string pePath)
        {
            if (pePath == null) throw new ArgumentException("pePath");
            if (entry == null || !object.ReferenceEquals(entry.Role, L3Role.CALLABLE))
                throw new ArgumentException("expected CALLABLE root");
            List<L3Node> order = new List<L3Node>();
            Dictionary<L3Node, int> map = new Dictionary<L3Node, int>(RefCmp.Instance);
            CollectCallables(entry, order, map);
            Dictionary<L3Node, int> arity = new Dictionary<L3Node, int>(RefCmp.Instance);
            Dictionary<L3Node, int> slots = new Dictionary<L3Node, int>(RefCmp.Instance);
            for (int i = 0; i < order.Count; i++)
            {
                arity[order[i]] = ComputeArity(order[i]);
                slots[order[i]] = ComputeSlotCount(order[i]);
            }
            ValidateAll(order, map, arity, slots);

            if (File.Exists(pePath)) File.Delete(pePath);
            string fullPath = Path.GetFullPath(pePath);
            string dir = Path.GetDirectoryName(fullPath);
            string fileName = Path.GetFileName(fullPath);
            string unique = "L3CilGen_" + Guid.NewGuid().ToString("N");
            AssemblyBuilder ab = AppDomain.CurrentDomain.DefineDynamicAssembly(
                new AssemblyName(unique), AssemblyBuilderAccess.Save, dir);
            ModuleBuilder mb = ab.DefineDynamicModule(fileName, fileName);
            TypeBuilder tb = mb.DefineType(
                GeneratedTypeName, TypeAttributes.Public | TypeAttributes.Sealed | TypeAttributes.Abstract);

            MethodBuilder[] methods = new MethodBuilder[order.Count];
            for (int i = 0; i < order.Count; i++)
            {
                methods[i] = tb.DefineMethod(
                    "c" + i, MethodAttributes.Public | MethodAttributes.Static,
                    typeof(int), ParamTypes(arity[order[i]]));
            }
            MethodBuilder eval = tb.DefineMethod(
                EvalMethodName, MethodAttributes.Public | MethodAttributes.Static,
                typeof(int), new Type[] { typeof(LmxOccurrence) });

            for (int i = 0; i < order.Count; i++)
            {
                ILGenerator il = methods[i].GetILGenerator();
                int a = arity[order[i]];
                int sc = slots[order[i]];
                LocalBuilder[] locs = new LocalBuilder[sc];
                for (int s = 0; s < sc; s++)
                    locs[s] = il.DeclareLocal(typeof(int));
                LoopDepth = 0;
                LoopStack.Clear();
                EmitReturnBody(il, order[i].Child(0), map, arity, methods, a, locs);
            }

            if (arity[entry] != 1)
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
            Type[] ps = new Type[arity];
            ps[0] = typeof(LmxOccurrence);
            for (int i = 1; i < arity; i++) ps[i] = typeof(int);
            return ps;
        }

        private static void CollectCallables(L3Node entry, List<L3Node> order, Dictionary<L3Node, int> map)
        {
            WalkCollect(entry, order, map, new Dictionary<L3Node, bool>(RefCmp.Instance), new Dictionary<L3Node, bool>(RefCmp.Instance));
        }

        private static void WalkCollect(L3Node n, List<L3Node> order, Dictionary<L3Node, int> map,
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
                try { for (int i = 0; i < n.ChildCount; i++) WalkCollect(n.Child(i), order, map, gray, black); }
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
                    for (int i = 1; i < n.ChildCount; i++) WalkCollect(n.Child(i), order, map, gray, black);
                    return;
                }
                for (int i = 0; i < n.ChildCount; i++) WalkCollect(n.Child(i), order, map, gray, black);
            }
            finally { gray.Remove(n); black[n] = true; }
        }

        private static int ComputeArity(L3Node callable)
        {
            int[] max = new int[] { 0 };
            ScanArity(callable.Child(0), max, new Dictionary<L3Node, bool>(RefCmp.Instance), new Dictionary<L3Node, bool>(RefCmp.Instance));
            return max[0] + 1;
        }

        private static int ComputeSlotCount(L3Node callable)
        {
            int[] max = new int[] { -1 };
            ScanSlots(callable.Child(0), max, new Dictionary<L3Node, bool>(RefCmp.Instance), new Dictionary<L3Node, bool>(RefCmp.Instance));
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
                    for (int i = 1; i < n.ChildCount; i++) ScanArity(n.Child(i), maxIdx, gray, black);
                    return;
                }
                for (int i = 0; i < n.ChildCount; i++) ScanArity(n.Child(i), maxIdx, gray, black);
            }
            finally { gray.Remove(n); black[n] = true; }
        }

        private static void ScanSlots(L3Node n, int[] maxIdx, Dictionary<L3Node, bool> gray, Dictionary<L3Node, bool> black)
        {
            if (n == null) return;
            if (object.ReferenceEquals(n.Role, L3Role.CALLABLE)) return;
            if (black.ContainsKey(n)) return;
            GrayEnter(n, gray);
            try
            {
                if (object.ReferenceEquals(n.Role, L3Role.LOCAL_SET) || object.ReferenceEquals(n.Role, L3Role.LOCAL_GET))
                {
                    if (n.IntPayload > maxIdx[0]) maxIdx[0] = n.IntPayload;
                }
                if (object.ReferenceEquals(n.Role, L3Role.CALL))
                {
                    for (int i = 1; i < n.ChildCount; i++) ScanSlots(n.Child(i), maxIdx, gray, black);
                    return;
                }
                for (int i = 0; i < n.ChildCount; i++) ScanSlots(n.Child(i), maxIdx, gray, black);
            }
            finally { gray.Remove(n); black[n] = true; }
        }

        private static void ValidateAll(List<L3Node> order, Dictionary<L3Node, int> map,
            Dictionary<L3Node, int> arity, Dictionary<L3Node, int> slots)
        {
            for (int i = 0; i < order.Count; i++)
            {
                L3Node c = order[i];
                RequireSealed(c);
                if (c.ChildCount != 1 || c.Child(0) == null || !object.ReferenceEquals(c.Child(0).Role, L3Role.RETURN))
                    throw new ArgumentException("CALLABLE body must be a single RETURN");
                if (c.Child(0).ChildCount != 1) throw new ArgumentException("RETURN arity: need exactly one value");
                LoopDepth = 0;
                var gray = new Dictionary<L3Node, bool>(RefCmp.Instance);
                ValidateExpr(c.Child(0), map, arity, slots, c, arity[c], slots[c], new Assigned(slots[c]), gray);
            }
        }

        private static void RequireSealed(L3Node callable)
        {
            if (callable == null || !object.ReferenceEquals(callable.Role, L3Role.CALLABLE))
                throw new ArgumentException("expected CALLABLE");
            if (!callable.IsSealed) throw new InvalidOperationException("unsealed CALLABLE");
            if (callable.ChildCount != 1 || callable.Child(0) == null)
                throw new InvalidOperationException("unsealed/unresolved CALLABLE body");
        }

        private static Assigned ValidateExpr(
            L3Node expr, Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, Dictionary<L3Node, int> slots,
            L3Node currentCallable, int currentArity, int slotCount, Assigned assigned, Dictionary<L3Node, bool> gray)
        {
            if (expr == null) throw new ArgumentException("null child");
            if (gray.ContainsKey(expr)) throw new ArgumentException("ownership cycle: gray back-edge");
            gray[expr] = true;
            try
            {
                return ValidateExprBody(expr, map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
            }
            finally { gray.Remove(expr); }
        }

        private static Assigned ValidateExprBody(
            L3Node expr, Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, Dictionary<L3Node, int> slots,
            L3Node currentCallable, int currentArity, int slotCount, Assigned assigned, Dictionary<L3Node, bool> gray)
        {
            L3Role r = expr.Role;
            if (object.ReferenceEquals(r, L3Role.INT_LITERAL) || object.ReferenceEquals(r, L3Role.PROBE))
            {
                if (expr.ChildCount != 0) throw new ArgumentException("literal/probe arity");
                return assigned;
            }
            if (object.ReferenceEquals(r, L3Role.SUBJECT_REF))
            {
                if (expr.ChildCount != 0) throw new ArgumentException("SUBJECT_REF arity");
                throw new ArgumentException("SUBJECT_REF is not an int expression");
            }
            if (object.ReferenceEquals(r, L3Role.ARG))
            {
                if (expr.ChildCount != 0) throw new ArgumentException("ARG arity");
                if (expr.IntPayload < 1) throw new ArgumentException("ARG out of range for int context (need >= 1)");
                if (expr.IntPayload >= currentArity) throw new ArgumentException("ARG out of range");
                return assigned;
            }
            if (object.ReferenceEquals(r, L3Role.LOCAL_GET))
            {
                if (expr.ChildCount != 0) throw new ArgumentException("LOCAL_GET arity");
                int idx = expr.IntPayload;
                if (idx < 0 || idx >= slotCount) throw new ArgumentException("LOCAL_GET out of range");
                if (!assigned.Get(idx)) throw new ArgumentException("LOCAL_GET unassigned");
                return assigned;
            }
            if (object.ReferenceEquals(r, L3Role.LOCAL_SET))
            {
                if (expr.ChildCount != 1) throw new ArgumentException("LOCAL_SET arity: need RHS");
                int idx = expr.IntPayload;
                if (idx < 0 || idx >= slotCount) throw new ArgumentException("LOCAL_SET out of range");
                Assigned after = ValidateExpr(expr.Child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
                Assigned next = after.Clone();
                next.Set(idx);
                return next;
            }
            if (object.ReferenceEquals(r, L3Role.FIELD_FOLLOW))
            {
                if (expr.ChildCount != 1) throw new ArgumentException("FIELD_FOLLOW arity");
                ValidateOccurrenceBase(expr.Child(0), currentArity);
                return assigned;
            }
            if (object.ReferenceEquals(r, L3Role.ADD))
            {
                if (expr.ChildCount != 2) throw new ArgumentException("ADD arity");
                Assigned a = ValidateExpr(expr.Child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
                return ValidateExpr(expr.Child(1), map, arity, slots, currentCallable, currentArity, slotCount, a, gray);
            }
            if (object.ReferenceEquals(r, L3Role.IF))
            {
                if (expr.ChildCount != 3) throw new ArgumentException("IF arity");
                Assigned afterCond = ValidateExpr(expr.Child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
                Assigned thenA = ValidateStmtOrExpr(expr.Child(1), map, arity, slots, currentCallable, currentArity, slotCount, afterCond.Clone(), gray);
                Assigned elseA = ValidateStmtOrExpr(expr.Child(2), map, arity, slots, currentCallable, currentArity, slotCount, afterCond.Clone(), gray);
                return thenA.Intersect(elseA);
            }
            if (object.ReferenceEquals(r, L3Role.SEQUENCE))
            {
                if (expr.ChildCount < 1) throw new ArgumentException("SEQUENCE arity");
                Assigned a = assigned;
                for (int i = 0; i < expr.ChildCount - 1; i++)
                    a = ValidateStmt(expr.Child(i), map, arity, slots, currentCallable, currentArity, slotCount, a);
                return ValidateExpr(expr.Child(expr.ChildCount - 1), map, arity, slots, currentCallable, currentArity, slotCount, a, gray);
            }
            if (object.ReferenceEquals(r, L3Role.RETURN))
            {
                if (expr.ChildCount != 1) throw new ArgumentException("RETURN arity");
                Assigned after = ValidateExpr(expr.Child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
                Assigned exited = after.Clone();
                for (int i = 0; i < slotCount; i++) exited.Set(i);
                return exited;
            }
            if (object.ReferenceEquals(r, L3Role.CALL))
            {
                if (expr.ChildCount < 2) throw new ArgumentException("CALL arity: need callee and subject");
                L3Node callee = expr.Child(0);
                if (callee == null || !object.ReferenceEquals(callee.Role, L3Role.CALLABLE))
                    throw new ArgumentException("CALL callee must be CALLABLE node");
                if (!callee.IsSealed) throw new InvalidOperationException("unsealed CALLABLE");
                if (!map.ContainsKey(callee)) throw new ArgumentException("CALL callee not reachable");
                int need = arity[callee];
                if (expr.ChildCount - 1 != need) throw new ArgumentException("CALL arity mismatch");
                ValidateOccurrenceBase(expr.Child(1), currentArity);
                Assigned a = assigned;
                for (int i = 2; i < expr.ChildCount; i++)
                    a = ValidateExpr(expr.Child(i), map, arity, slots, currentCallable, currentArity, slotCount, a, gray);
                return a;
            }
            if (object.ReferenceEquals(r, L3Role.WHILE) || object.ReferenceEquals(r, L3Role.BREAK)
                || object.ReferenceEquals(r, L3Role.CONTINUE) || object.ReferenceEquals(r, L3Role.REDO))
                throw new ArgumentException(RoleName(r) + " not allowed in value context");
            if (object.ReferenceEquals(r, L3Role.UNSUPPORTED))
                throw new ArgumentException("unsupported role");
            throw new ArgumentException("unsupported role");
        }

        private static Assigned ValidateStmtOrExpr(
            L3Node n, Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, Dictionary<L3Node, int> slots,
            L3Node currentCallable, int currentArity, int slotCount, Assigned assigned, Dictionary<L3Node, bool> gray)
        {
            if (n == null) throw new ArgumentException("null child");
            if (object.ReferenceEquals(n.Role, L3Role.RETURN)
                || object.ReferenceEquals(n.Role, L3Role.BREAK)
                || object.ReferenceEquals(n.Role, L3Role.CONTINUE)
                || object.ReferenceEquals(n.Role, L3Role.REDO)
                || object.ReferenceEquals(n.Role, L3Role.WHILE)
                || object.ReferenceEquals(n.Role, L3Role.SEQUENCE)
                || object.ReferenceEquals(n.Role, L3Role.IF))
                return ValidateStmt(n, map, arity, slots, currentCallable, currentArity, slotCount, assigned);
            return ValidateExpr(n, map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
        }

        private static Assigned ValidateStmt(
            L3Node expr, Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, Dictionary<L3Node, int> slots,
            L3Node currentCallable, int currentArity, int slotCount, Assigned assigned)
        {
            L3Role r = expr.Role;
            if (object.ReferenceEquals(r, L3Role.RETURN))
            {
                var gray = new Dictionary<L3Node, bool>(RefCmp.Instance);
                return ValidateExpr(expr, map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
            }
            if (object.ReferenceEquals(r, L3Role.BREAK) || object.ReferenceEquals(r, L3Role.CONTINUE) || object.ReferenceEquals(r, L3Role.REDO))
            {
                if (expr.IntPayload != 0) throw new ArgumentException("loop transfer payload");
                if (expr.ChildCount != 0) throw new ArgumentException(RoleName(r) + " arity");
                if (LoopDepth < 1) throw new ArgumentException(RoleName(r) + " outside loop");
                return assigned;
            }
            if (object.ReferenceEquals(r, L3Role.WHILE))
            {
                if (expr.ChildCount != 2) throw new ArgumentException("WHILE arity: need condition, body");
                if (expr.IntPayload != 0) throw new ArgumentException("WHILE payload");
                var gray = new Dictionary<L3Node, bool>(RefCmp.Instance);
                Assigned afterCond = ValidateExpr(expr.Child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
                LoopDepth = LoopDepth + 1;
                try
                {
                    ValidateStmt(expr.Child(1), map, arity, slots, currentCallable, currentArity, slotCount, afterCond.Clone());
                }
                finally { LoopDepth = LoopDepth - 1; }
                return assigned; // body may not execute
            }
            if (object.ReferenceEquals(r, L3Role.SEQUENCE))
            {
                if (expr.ChildCount < 1) throw new ArgumentException("SEQUENCE arity");
                Assigned a = assigned;
                for (int i = 0; i < expr.ChildCount; i++)
                    a = ValidateStmt(expr.Child(i), map, arity, slots, currentCallable, currentArity, slotCount, a);
                return a;
            }
            if (object.ReferenceEquals(r, L3Role.IF))
            {
                if (expr.ChildCount != 3) throw new ArgumentException("IF arity");
                var gray = new Dictionary<L3Node, bool>(RefCmp.Instance);
                Assigned afterCond = ValidateExpr(expr.Child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
                Assigned thenA = ValidateStmt(expr.Child(1), map, arity, slots, currentCallable, currentArity, slotCount, afterCond.Clone());
                Assigned elseA = ValidateStmt(expr.Child(2), map, arity, slots, currentCallable, currentArity, slotCount, afterCond.Clone());
                return thenA.Intersect(elseA);
            }
            var g2 = new Dictionary<L3Node, bool>(RefCmp.Instance);
            return ValidateExpr(expr, map, arity, slots, currentCallable, currentArity, slotCount, assigned, g2);
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
                return;
            }
            throw new ArgumentException("occurrence base must be SUBJECT_REF or ARG(0)");
        }

        private static void EmitReturnBody(ILGenerator il, L3Node retNode,
            Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, MethodBuilder[] methods,
            int currentArity, LocalBuilder[] locs)
        {
            EmitValue(il, retNode.Child(0), map, arity, methods, currentArity, locs);
            il.Emit(OpCodes.Ret);
        }

        private static void EmitValue(ILGenerator il, L3Node expr,
            Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, MethodBuilder[] methods,
            int currentArity, LocalBuilder[] locs)
        {
            L3Role r = expr.Role;
            if (object.ReferenceEquals(r, L3Role.INT_LITERAL))
            { il.Emit(OpCodes.Ldc_I4, expr.IntPayload); return; }
            if (object.ReferenceEquals(r, L3Role.PROBE))
            { il.Emit(OpCodes.Call, typeof(EvalCounter).GetMethod("Tick", Type.EmptyTypes)); return; }
            if (object.ReferenceEquals(r, L3Role.ARG))
            { il.Emit(OpCodes.Ldarg, expr.IntPayload); return; }
            if (object.ReferenceEquals(r, L3Role.LOCAL_GET))
            { il.Emit(OpCodes.Ldloc, locs[expr.IntPayload]); return; }
            if (object.ReferenceEquals(r, L3Role.LOCAL_SET))
            {
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Dup);
                il.Emit(OpCodes.Stloc, locs[expr.IntPayload]);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.FIELD_FOLLOW))
            {
                EmitOccurrence(il, expr.Child(0));
                il.Emit(OpCodes.Ldc_I4, expr.IntPayload);
                il.Emit(OpCodes.Callvirt, typeof(LmxOccurrence).GetMethod("Child", new Type[] { typeof(int) }));
                il.Emit(OpCodes.Unbox_Any, typeof(int));
                return;
            }
            if (object.ReferenceEquals(r, L3Role.ADD))
            {
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity, locs);
                EmitValue(il, expr.Child(1), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Add);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.CALL))
            {
                EmitOccurrence(il, expr.Child(1));
                for (int i = 2; i < expr.ChildCount; i++)
                    EmitValue(il, expr.Child(i), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Call, methods[map[expr.Child(0)]]);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.IF))
            {
                bool thenRet = object.ReferenceEquals(expr.Child(1).Role, L3Role.RETURN);
                bool elseRet = object.ReferenceEquals(expr.Child(2).Role, L3Role.RETURN);
                Label elseL = il.DefineLabel();
                Label endL = il.DefineLabel();
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Brfalse, elseL);
                EmitStmtOrValue(il, expr.Child(1), map, arity, methods, currentArity, locs);
                if (!thenRet) il.Emit(OpCodes.Br, endL);
                il.MarkLabel(elseL);
                EmitStmtOrValue(il, expr.Child(2), map, arity, methods, currentArity, locs);
                if (!thenRet || !elseRet) il.MarkLabel(endL);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.SEQUENCE))
            {
                for (int i = 0; i < expr.ChildCount - 1; i++)
                {
                    L3Node ch = expr.Child(i);
                    EmitStmt(il, ch, map, arity, methods, currentArity, locs);
                    if (object.ReferenceEquals(ch.Role, L3Role.RETURN)) return;
                    if (object.ReferenceEquals(ch.Role, L3Role.BREAK) || object.ReferenceEquals(ch.Role, L3Role.CONTINUE) || object.ReferenceEquals(ch.Role, L3Role.REDO))
                        return;
                }
                EmitValue(il, expr.Child(expr.ChildCount - 1), map, arity, methods, currentArity, locs);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.RETURN))
            {
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Ret);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.WHILE) || object.ReferenceEquals(r, L3Role.BREAK)
                || object.ReferenceEquals(r, L3Role.CONTINUE) || object.ReferenceEquals(r, L3Role.REDO))
                throw new ArgumentException(RoleName(r) + " not allowed in value context");
            throw new ArgumentException("unsupported role at emit");
        }

        private static void EmitStmt(ILGenerator il, L3Node expr,
            Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, MethodBuilder[] methods,
            int currentArity, LocalBuilder[] locs)
        {
            L3Role r = expr.Role;
            if (object.ReferenceEquals(r, L3Role.RETURN))
            {
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Ret);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.BREAK) || object.ReferenceEquals(r, L3Role.CONTINUE) || object.ReferenceEquals(r, L3Role.REDO))
            {
                Label[] frame = LoopStack.Peek();
                int idx = object.ReferenceEquals(r, L3Role.CONTINUE) ? 0 : (object.ReferenceEquals(r, L3Role.BREAK) ? 1 : 2);
                il.Emit(OpCodes.Br, frame[idx]);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.WHILE))
            {
                Label cond = il.DefineLabel();
                Label done = il.DefineLabel();
                Label body = il.DefineLabel();
                Label[] frame = new Label[] { cond, done, body };
                LoopStack.Push(frame);
                try
                {
                    il.MarkLabel(cond);
                    EmitValue(il, expr.Child(0), map, arity, methods, currentArity, locs);
                    il.Emit(OpCodes.Brfalse, done);
                    il.MarkLabel(body);
                    EmitStmt(il, expr.Child(1), map, arity, methods, currentArity, locs);
                    il.Emit(OpCodes.Br, cond);
                    il.MarkLabel(done);
                }
                finally { LoopStack.Pop(); }
                return;
            }
            if (object.ReferenceEquals(r, L3Role.SEQUENCE))
            {
                for (int i = 0; i < expr.ChildCount; i++)
                    EmitStmt(il, expr.Child(i), map, arity, methods, currentArity, locs);
                return;
            }
            if (object.ReferenceEquals(r, L3Role.IF))
            {
                Label elseL = il.DefineLabel();
                Label endL = il.DefineLabel();
                EmitValue(il, expr.Child(0), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Brfalse, elseL);
                EmitStmt(il, expr.Child(1), map, arity, methods, currentArity, locs);
                il.Emit(OpCodes.Br, endL);
                il.MarkLabel(elseL);
                EmitStmt(il, expr.Child(2), map, arity, methods, currentArity, locs);
                il.MarkLabel(endL);
                return;
            }
            EmitValue(il, expr, map, arity, methods, currentArity, locs);
            il.Emit(OpCodes.Pop);
        }

        private static void EmitStmtOrValue(ILGenerator il, L3Node n,
            Dictionary<L3Node, int> map, Dictionary<L3Node, int> arity, MethodBuilder[] methods,
            int currentArity, LocalBuilder[] locs)
        {
            if (object.ReferenceEquals(n.Role, L3Role.RETURN)
                || object.ReferenceEquals(n.Role, L3Role.BREAK)
                || object.ReferenceEquals(n.Role, L3Role.CONTINUE)
                || object.ReferenceEquals(n.Role, L3Role.REDO)
                || object.ReferenceEquals(n.Role, L3Role.WHILE))
            {
                EmitStmt(il, n, map, arity, methods, currentArity, locs);
                return;
            }
            EmitValue(il, n, map, arity, methods, currentArity, locs);
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

        private static string RoleName(L3Role r)
        {
            if (object.ReferenceEquals(r, L3Role.WHILE)) return "WHILE";
            if (object.ReferenceEquals(r, L3Role.BREAK)) return "BREAK";
            if (object.ReferenceEquals(r, L3Role.CONTINUE)) return "CONTINUE";
            if (object.ReferenceEquals(r, L3Role.REDO)) return "REDO";
            return "ROLE";
        }

        private static void GrayEnter(L3Node n, Dictionary<L3Node, bool> gray)
        {
            if (gray.ContainsKey(n)) throw new ArgumentException("ownership cycle: gray back-edge");
            gray[n] = true;
        }

        private sealed class Assigned
        {
            private readonly bool[] bits;
            public Assigned(int n) { bits = new bool[n]; }
            private Assigned(bool[] bits) { this.bits = bits; }
            public bool Get(int i) { return bits[i]; }
            public void Set(int i) { bits[i] = true; }
            public Assigned Clone()
            {
                bool[] c = new bool[bits.Length];
                Array.Copy(bits, c, bits.Length);
                return new Assigned(c);
            }
            public Assigned Intersect(Assigned other)
            {
                bool[] c = new bool[bits.Length];
                for (int i = 0; i < bits.Length; i++) c[i] = bits[i] && other.bits[i];
                return new Assigned(c);
            }
        }

        private sealed class RefCmp : IEqualityComparer<L3Node>
        {
            public static readonly RefCmp Instance = new RefCmp();
            public bool Equals(L3Node x, L3Node y) { return object.ReferenceEquals(x, y); }
            public int GetHashCode(L3Node obj) { return RuntimeHelpers.GetHashCode(obj); }
        }
    }
}
