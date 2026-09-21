namespace Graph
{
    /// <summary>Physical shared role records. Dispatch only by object identity (ReferenceEquals).</summary>
    public sealed class L3Role
    {
        public static readonly L3Role CALLABLE = new L3Role();
        public static readonly L3Role RETURN = new L3Role();
        public static readonly L3Role SUBJECT_REF = new L3Role();
        public static readonly L3Role ARG = new L3Role();
        public static readonly L3Role INT_LITERAL = new L3Role();
        public static readonly L3Role FIELD_FOLLOW = new L3Role();
        public static readonly L3Role ADD = new L3Role();
        public static readonly L3Role IF = new L3Role();
        public static readonly L3Role SEQUENCE = new L3Role();
        public static readonly L3Role UNSUPPORTED = new L3Role();

        private L3Role() { }

        /// <summary>Test-only: distinct same-shaped role instance (not a singleton).</summary>
        public static L3Role DistinctForTest() { return new L3Role(); }
    }
}
