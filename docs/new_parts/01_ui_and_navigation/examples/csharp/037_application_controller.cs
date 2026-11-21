static class Example {
    sealed class Navigation {
        int screen = 1;
        public int Submit(bool valid) {
            if (screen == 1 && valid) screen = 2;
            return screen;
        }
    }
    public static int Demo() => new Navigation().Submit(true);
}
