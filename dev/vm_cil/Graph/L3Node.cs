using System;

namespace Graph
{
    /// <summary>
    /// In-memory L3 node. After construction or successful seal, children are frozen.
    /// CALLABLE may be built via UnsealedCallable + Seal for physical self/mutual CALL cycles.
    /// </summary>
    public sealed class L3Node
    {
        public readonly L3Role Role;
        public readonly int IntPayload;
        private L3Node[] children;
        private bool sealedFlag;

        public L3Node(L3Role role, int intPayload, params L3Node[] children)
        {
            if (role == null) throw new ArgumentException("role");
            this.Role = role;
            this.IntPayload = intPayload;
            this.children = children == null ? new L3Node[0] : (L3Node[])children.Clone();
            this.sealedFlag = true;
        }

        private L3Node(bool unsealedMarker)
        {
            this.Role = L3Role.CALLABLE;
            this.IntPayload = 0;
            this.children = new L3Node[0];
            this.sealedFlag = false;
        }

        public static L3Node Of(L3Role role, params L3Node[] children)
        {
            return new L3Node(role, 0, children);
        }

        public static L3Node OfInt(L3Role role, int value)
        {
            return new L3Node(role, value);
        }

        public static L3Node UnsealedCallable()
        {
            return new L3Node(true);
        }

        public bool IsSealed { get { return sealedFlag; } }

        public int ChildCount { get { return children.Length; } }

        public L3Node Child(int index)
        {
            if (index < 0 || index >= children.Length)
                throw new IndexOutOfRangeException("child index " + index);
            return children[index];
        }

        public void Seal(L3Node returnBody)
        {
            if (!object.ReferenceEquals(Role, L3Role.CALLABLE))
                throw new InvalidOperationException("seal only on CALLABLE");
            if (sealedFlag)
                throw new InvalidOperationException("CALLABLE already sealed");
            if (returnBody == null || !object.ReferenceEquals(returnBody.Role, L3Role.RETURN))
                throw new ArgumentException("seal requires single RETURN body");
            this.children = new L3Node[] { returnBody };
            this.sealedFlag = true;
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
            this.sealedFlag = true;
        }
    }
}
