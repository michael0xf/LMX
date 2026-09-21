using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;

namespace Lmx
{
    /// <summary>Isolated CIL ABI for {node, len, data}. Store does not reparent.</summary>
    public sealed class LmxOccurrence
    {
        private LmxOccurrence node;
        private readonly object[] data;

        private LmxOccurrence(LmxOccurrence node, object[] data)
        {
            if (data == null) throw new ArgumentException("data");
            this.node = node;
            this.data = data;
        }

        private LmxOccurrence(int len)
        {
            this.node = null;
            this.data = new object[len];
        }

        public static LmxOccurrence Independent(params object[] fields)
        {
            return new LmxOccurrence(null, CopyFields(fields));
        }

        public static LmxOccurrence Nested(LmxOccurrence parent, params object[] fields)
        {
            if (parent == null) throw new ArgumentException("parent");
            return new LmxOccurrence(parent, CopyFields(fields));
        }

        public LmxOccurrence Node { get { return node; } }
        public int Len { get { return data.Length; } }

        public object Child(int index)
        {
            CheckBounds(index);
            return data[index];
        }

        public void SetChild(int index, object value)
        {
            CheckBounds(index);
            data[index] = value;
        }

        public static LmxOccurrence Merge(params LmxOccurrence[] parts)
        {
            if (parts == null || parts.Length == 0) throw new ArgumentException("parts");
            var map = new Dictionary<LmxOccurrence, LmxOccurrence>(ReferenceEqualityComparer.Instance);
            int n = 0;
            for (int p = 0; p < parts.Length; p++)
            {
                if (parts[p] == null) throw new ArgumentException("null part");
                n += parts[p].Len;
                for (int i = 0; i < parts[p].Len; i++)
                {
                    object c = parts[p].Child(i);
                    if (c is LmxOccurrence) Ensure((LmxOccurrence)c, map);
                }
            }
            FinishCopy(map);
            object[] fields = new object[n];
            LmxOccurrence root = new LmxOccurrence(null, fields);
            int k = 0;
            for (int p = 0; p < parts.Length; p++)
            {
                for (int i = 0; i < parts[p].Len; i++)
                    fields[k++] = MapRef(parts[p].Child(i), map);
            }
            return root;
        }

        private static void Ensure(LmxOccurrence src, Dictionary<LmxOccurrence, LmxOccurrence> map)
        {
            if (src == null || map.ContainsKey(src)) return;
            map[src] = new LmxOccurrence(src.Len);
            Ensure(src.node, map);
            for (int i = 0; i < src.Len; i++)
            {
                object c = src.Child(i);
                if (c is LmxOccurrence) Ensure((LmxOccurrence)c, map);
            }
        }

        private static void FinishCopy(Dictionary<LmxOccurrence, LmxOccurrence> map)
        {
            foreach (var e in map)
            {
                LmxOccurrence src = e.Key;
                LmxOccurrence dst = e.Value;
                if (src.node == null) dst.node = null;
                else
                {
                    LmxOccurrence mapped;
                    if (!map.TryGetValue(src.node, out mapped) || mapped == null)
                        throw new InvalidOperationException("ancestor missing from copy map");
                    dst.node = mapped;
                }
                for (int i = 0; i < src.Len; i++)
                    dst.data[i] = MapRef(src.Child(i), map);
            }
        }

        private static object MapRef(object value, Dictionary<LmxOccurrence, LmxOccurrence> map)
        {
            LmxOccurrence occ = value as LmxOccurrence;
            if (occ != null)
            {
                LmxOccurrence mapped;
                if (!map.TryGetValue(occ, out mapped) || mapped == null)
                    throw new InvalidOperationException("occurrence missing from copy map");
                return mapped;
            }
            return value;
        }

        private static object[] CopyFields(object[] fields)
        {
            if (fields == null) return new object[0];
            object[] copy = new object[fields.Length];
            Array.Copy(fields, copy, fields.Length);
            return copy;
        }

        private void CheckBounds(int index)
        {
            if (index < 0 || index >= data.Length)
                throw new IndexOutOfRangeException(
                    "LmxOccurrence index " + index + " not in [0," + data.Length + ")");
        }

        private sealed class ReferenceEqualityComparer : IEqualityComparer<LmxOccurrence>
        {
            public static readonly ReferenceEqualityComparer Instance = new ReferenceEqualityComparer();
            public bool Equals(LmxOccurrence x, LmxOccurrence y) { return object.ReferenceEquals(x, y); }
            public int GetHashCode(LmxOccurrence obj) { return RuntimeHelpers.GetHashCode(obj); }
        }
    }
}
