static class Example {
    sealed class Model {
        public int Count = 5;
        public void Increment() { Count++; }
    }
    sealed class View {
        readonly Model model;
        public View(Model model) { this.model = model; }
        public int Render() => model.Count;
    }
    sealed class Controller {
        readonly Model model;
        public Controller(Model model) { this.model = model; }
        public void Click() { model.Increment(); }
    }
    public static int Demo() {
        var model = new Model();
        new Controller(model).Click();
        return new View(model).Render();
    }
}
