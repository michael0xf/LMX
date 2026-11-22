class Model { count = 5; increment() { this.count++; } }
class View {
    constructor(private model: Model) {}
    render() { return this.model.count; }
}
class Controller {
    constructor(private model: Model) {}
    click() { this.model.increment(); }
}
function demo() {
    const model = new Model();
    new Controller(model).click();
    return new View(model).render();
}
