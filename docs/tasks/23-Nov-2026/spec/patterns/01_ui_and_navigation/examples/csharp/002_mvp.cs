static class Example {
    interface IView { void Show(int value); }
    sealed class Model { public int Count = 5; }
    sealed class Screen : IView {
        public int Shown;
        public void Show(int value) { Shown = value; }
    }
    sealed class Presenter {
        readonly Model model; readonly IView view;
        public Presenter(Model m, IView v) { model = m; view = v; }
        public void Click(int delta) {
            model.Count += delta;
            view.Show(model.Count);
        }
    }
    public static int Demo() {
        var model = new Model(); var screen = new Screen();
        new Presenter(model, screen).Click(2);
        return model.Count * 10 + screen.Shown;
    }
}
