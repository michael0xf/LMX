class Navigation {
    private screen = 1;
    submit(valid: boolean) {
        if (this.screen === 1 && valid) this.screen = 2;
        return this.screen;
    }
}
function demo() { return new Navigation().submit(true); }
