type Action = {type: "add"; delta: number};
function reduce(state: number, action: Action) { return state + action.delta; }
class Store {
    private state = 0;
    dispatch(action: Action) { this.state = reduce(this.state, action); }
    getState() { return this.state; }
}
function demo() {
    const store = new Store();
    store.dispatch({type: "add", delta: 2});
    const previous = store.getState();
    store.dispatch({type: "add", delta: 3});
    return previous * 10 + store.getState();
}
