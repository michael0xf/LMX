using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Reflection.Emit;
using Graph;
using Lmx;

namespace Emitter
{
    /// <summary>
    /// Validates an L3 CALLABLE graph then emits a PE assembly with static Eval(LmxOccurrence)-&gt;int
    /// via Reflection.Emit. Invalid graphs throw before any assembly is saved.
    /// </summary>
    public static class L3CilEmitter
    {
        public const string EvalMethodName = "Eval";
        public const string GeneratedTypeName = "L3Gen.EvalHost";

        public static string EmitCallableToPe(L3Node entry, string pePath)
        {
            if (pePath == null) throw new ArgumentException("pePath");
            ValidateEntry(entry);
            if (File.Exists(pePath)) File.Delete(pePath);

            string fullPath = Path.GetFullPath(pePath);
            string dir = Path.GetDirectoryName(fullPath);
            string fileName = Path.GetFileName(fullPath);
            // Unique assembly name per emit — LoadFrom caches by simple name.
            string unique = "L3CilGen_" + Guid.NewGuid().ToString("N");
            AssemblyName an = new AssemblyName(unique);
            AssemblyBuilder ab = AppDomain.CurrentDomain.DefineDynamicAssembly(
                an, AssemblyBuilderAccess.Save, dir);
            ModuleBuilder mb = ab.DefineDynamicModule(fileName, fileName);
            TypeBuilder tb = mb.DefineType(
                GeneratedTypeName,
                TypeAttributes.Public | TypeAttributes.Sealed | TypeAttributes.Abstract);
            MethodBuilder meth = tb.DefineMethod(
                EvalMethodName,
                MethodAttributes.Public | MethodAttributes.Static,
                typeof(int),
                new Type[] { typeof(LmxOccurrence) });
            ILGenerator il = meth.GetILGenerator();
            EmitReturnBody(il, entry.Child(0));
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

        private static void ValidateEntry(L3Node entry)
        {
            if (entry == null) throw new ArgumentException("entry");
            if (!object.ReferenceEquals(entry.Role, L3Role.CALLABLE))
                throw new ArgumentException("expected CALLABLE root");
            if (entry.ChildCount != 1 || entry.Child(0) == null)
                throw new ArgumentException("CALLABLE body must be a single RETURN");
            if (!object.ReferenceEquals(entry.Child(0).Role, L3Role.RETURN))
                throw new ArgumentException("CALLABLE body must be a single RETURN");
            var gray = new Dictionary<L3Node, bool>(RefCmp.Instance);
            var black = new Dictionary<L3Node, bool>(RefCmp.Instance);
            ValidateExpr(entry.Child(0), gray, black);
        }

        private static void ValidateExpr(L3Node expr, Dictionary<L3Node, bool> gray, Dictionary<L3Node, bool> black)
        {
            if (expr == null) throw new ArgumentException("null child");
            if (black.ContainsKey(expr)) return;
            if (gray.ContainsKey(expr))
                throw new ArgumentException("ownership cycle: gray back-edge");
            gray[expr] = true;
            try
            {
                L3Role r = expr.Role;
                if (object.ReferenceEquals(r, L3Role.RETURN))
                {
                    if (expr.ChildCount != 1) throw new ArgumentException("RETURN arity");
                    ValidateExpr(expr.Child(0), gray, black);
                }
                else if (object.ReferenceEquals(r, L3Role.INT_LITERAL))
                {
                    if (expr.ChildCount != 0) throw new ArgumentException("INT_LITERAL arity");
                }
                else if (object.ReferenceEquals(r, L3Role.SUBJECT_REF))
                {
                    if (expr.ChildCount != 0) throw new ArgumentException("SUBJECT_REF arity");
                    throw new ArgumentException("SUBJECT_REF is not an int expression");
                }
                else if (object.ReferenceEquals(r, L3Role.ARG))
                {
                    if (expr.ChildCount != 0) throw new ArgumentException("ARG arity");
                    if (expr.IntPayload != 0)
                        throw new ArgumentException("ARG out of range for int context (need subject 0 only in baseline)");
                    throw new ArgumentException("ARG(0) is not an int expression");
                }
                else if (object.ReferenceEquals(r, L3Role.FIELD_FOLLOW))
                {
                    if (expr.ChildCount != 1) throw new ArgumentException("FIELD_FOLLOW arity");
                    if (expr.Child(0) == null) throw new ArgumentException("null child");
                    ValidateOccurrenceBase(expr.Child(0));
                }
                else if (object.ReferenceEquals(r, L3Role.ADD))
                {
                    if (expr.ChildCount != 2) throw new ArgumentException("ADD arity");
                    ValidateExpr(expr.Child(0), gray, black);
                    ValidateExpr(expr.Child(1), gray, black);
                }
                else if (object.ReferenceEquals(r, L3Role.IF))
                {
                    if (expr.ChildCount != 3) throw new ArgumentException("IF arity");
                    ValidateExpr(expr.Child(0), gray, black);
                    ValidateStmtOrExpr(expr.Child(1), gray, black);
                    ValidateStmtOrExpr(expr.Child(2), gray, black);
                }
                else if (object.ReferenceEquals(r, L3Role.SEQUENCE))
                {
                    if (expr.ChildCount < 1) throw new ArgumentException("SEQUENCE arity");
                    for (int i = 0; i < expr.ChildCount - 1; i++)
                        ValidateStmtOrExpr(expr.Child(i), gray, black);
                    ValidateExpr(expr.Child(expr.ChildCount - 1), gray, black);
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
            finally
            {
                gray.Remove(expr);
                black[expr] = true;
            }
        }

        private static void ValidateStmtOrExpr(L3Node n, Dictionary<L3Node, bool> gray, Dictionary<L3Node, bool> black)
        {
            if (n == null) throw new ArgumentException("null child");
            if (object.ReferenceEquals(n.Role, L3Role.RETURN))
            {
                if (n.ChildCount != 1) throw new ArgumentException("RETURN arity");
                ValidateExpr(n.Child(0), gray, black);
                return;
            }
            ValidateExpr(n, gray, black);
        }

        private static void ValidateOccurrenceBase(L3Node n)
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

        private static void EmitReturnBody(ILGenerator il, L3Node retNode)
        {
            EmitValue(il, retNode.Child(0));
            il.Emit(OpCodes.Ret);
        }

        private static void EmitValue(ILGenerator il, L3Node expr)
        {
            L3Role r = expr.Role;
            if (object.ReferenceEquals(r, L3Role.INT_LITERAL))
            {
                il.Emit(OpCodes.Ldc_I4, expr.IntPayload);
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
                EmitValue(il, expr.Child(0));
                EmitValue(il, expr.Child(1));
                il.Emit(OpCodes.Add);
            }
            else if (object.ReferenceEquals(r, L3Role.IF))
            {
                bool thenRet = object.ReferenceEquals(expr.Child(1).Role, L3Role.RETURN);
                bool elseRet = object.ReferenceEquals(expr.Child(2).Role, L3Role.RETURN);
                Label elseL = il.DefineLabel();
                Label endL = il.DefineLabel();
                EmitValue(il, expr.Child(0));
                il.Emit(OpCodes.Brfalse, elseL);
                EmitStmtOrValue(il, expr.Child(1));
                if (!thenRet) il.Emit(OpCodes.Br, endL);
                il.MarkLabel(elseL);
                EmitStmtOrValue(il, expr.Child(2));
                if (!thenRet || !elseRet) il.MarkLabel(endL);
            }
            else if (object.ReferenceEquals(r, L3Role.SEQUENCE))
            {
                for (int i = 0; i < expr.ChildCount - 1; i++)
                {
                    L3Node ch = expr.Child(i);
                    EmitStmtOrValue(il, ch);
                    if (object.ReferenceEquals(ch.Role, L3Role.RETURN))
                        return;
                    if (object.ReferenceEquals(ch.Role, L3Role.IF)
                        && object.ReferenceEquals(ch.Child(1).Role, L3Role.RETURN)
                        && object.ReferenceEquals(ch.Child(2).Role, L3Role.RETURN))
                        return;
                    il.Emit(OpCodes.Pop);
                }
                EmitValue(il, expr.Child(expr.ChildCount - 1));
            }
            else if (object.ReferenceEquals(r, L3Role.RETURN))
            {
                EmitValue(il, expr.Child(0));
                il.Emit(OpCodes.Ret);
            }
            else
            {
                throw new ArgumentException("unsupported role at emit");
            }
        }

        private static void EmitStmtOrValue(ILGenerator il, L3Node n)
        {
            if (object.ReferenceEquals(n.Role, L3Role.RETURN))
            {
                EmitValue(il, n.Child(0));
                il.Emit(OpCodes.Ret);
                return;
            }
            EmitValue(il, n);
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

        private sealed class RefCmp : IEqualityComparer<L3Node>
        {
            public static readonly RefCmp Instance = new RefCmp();
            public bool Equals(L3Node x, L3Node y) { return object.ReferenceEquals(x, y); }
            public int GetHashCode(L3Node obj) { return RuntimeHelpersHash(obj); }
            private static int RuntimeHelpersHash(object o)
            {
                return System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(o);
            }
        }
    }
}
