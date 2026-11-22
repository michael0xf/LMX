class ViewModel {
    private count = 0;
    changed: (value: number) => void = () => {};
    get doubled() { return this.count * 2; }
    set(value: number) {
        this.count = value;
        this.changed(this.doubled);
    }
}
function demo() {
    const vm = new ViewModel();
    let shown = 0;
    vm.changed = value => { shown = value; };
    vm.set(6);
    return shown;
}
