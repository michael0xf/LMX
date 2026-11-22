sealed class Bulkhead {
    readonly System.Threading.SemaphoreSlim permit = new(1, 1);
    public bool Acquire() => permit.Wait(0);
    public int Release() { permit.Release(); return 1; }
}
// var a = new Bulkhead(); var b = new Bulkhead();
