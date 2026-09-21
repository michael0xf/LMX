namespace Graph
{
    /// <summary>Smoke-only probe counter (evaluate-once proofs).</summary>
    public static class EvalCounter
    {
        private static int count;
        public static void Reset() { count = 0; }
        public static int Get() { return count; }
        public static int Tick() { return ++count; }
    }
}
