interface View { show(value: number): void; }
class Screen implements View {
    shown = 0;
    show(value: number) { this.shown = value; }
}
class Presenter {
    constructor(private model: {count: number}, private view: View) {}
    click(delta: number) {
        this.model.count += delta;
        this.view.show(this.model.count);
    }
}
function demo() {
    const model = {count: 5}, screen = new Screen();
    new Presenter(model, screen).click(2);
    return model.count * 10 + screen.shown;
}
