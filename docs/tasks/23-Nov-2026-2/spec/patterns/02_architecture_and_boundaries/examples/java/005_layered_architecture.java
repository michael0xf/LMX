class Example {
    static class Data { static int price() { return 10; } }
    static class Application {
        static int total(int quantity) { return quantity * Data.price(); }
    }
    static class Presentation {
        static int handle(int quantity) { return Application.total(quantity); }
    }
    static int demo() { return Presentation.handle(3); }
}
