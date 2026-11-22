class Example {
    static class Settings { int value; }
    static class Registry {
        final Settings first = new Settings(), second = new Settings();
        Settings get(int key) { return key == 0 ? first : second; }
    }
    static int demo() {
        Registry r = new Registry();
        Settings a = r.get(0), b = r.get(0), c = r.get(1);
        a.value = 7;
        return b.value * 10 + c.value;
    }
}
