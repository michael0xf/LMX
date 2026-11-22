interface IStore { int Read(); void Write(int value); }
sealed class Cache(IStore store) {
    bool ready; int value;
    public int Get() {
        if (!ready) { value = store.Read(); ready = true; }
        return value;
    }
    public int Put(int v) { store.Write(v); ready = false; return v; }
}
