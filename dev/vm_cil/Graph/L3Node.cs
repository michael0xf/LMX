using System;

namespace Graph
{
    /// <summary>In-memory L3 node; children frozen after construction (defensive copy).</summary>
    public sealed class L3Node
    {
        public readonly L3Role Role;
        public readonly int IntPayload;
        private readonly L3Node[] children;

        public L3Node(L3Role role, int intPayload, params L3Node[] children)
        {
            if (role == null) throw new ArgumentException("role");
            this.Role = role;
            this.IntPayload = intPayload;
            this.children = children == null ? new L3Node[0] : (L3Node[])children.Clone();
        }

        public static L3Node Of(L3Role role, params L3Node[] children)
        {
            return new L3Node(role, 0, children);
        }

        public static L3Node OfInt(L3Role role, int value)
        {
            return new L3Node(role, value);
        }

        public int ChildCount { get { return children.Length; } }

        public L3Node Child(int index)
        {
            if (index < 0 || index >= children.Length)
                throw new IndexOutOfRangeException("child index " + index);
            return children[index];
        }

        public static L3Node AdoptChildrenForTest(L3Role role, L3Node[] children)
        {
            if (role == null || children == null) throw new ArgumentException("adoptChildrenForTest");
            return new L3Node(role, 0, children, true);
        }

        private L3Node(L3Role role, int intPayload, L3Node[] children, bool adopt)
        {
            this.Role = role;
            this.IntPayload = intPayload;
            this.children = adopt ? children : (L3Node[])children.Clone();
        }
    }
}
