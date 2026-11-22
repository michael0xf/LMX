static class Example {
    readonly record struct Add(int Delta);
    static int Reduce(int state, Add action) => state + action.Delta;
    sealed class Store {
        public int State { get; private set; }
        public void Dispatch(Add action) { State = Reduce(State, action); }
    }
    public static int Demo() {
        var store = new Store();
        store.Dispatch(new Add(2)); int previous = store.State;
        store.Dispatch(new Add(3));
        return previous * 10 + store.State;
    }
}
