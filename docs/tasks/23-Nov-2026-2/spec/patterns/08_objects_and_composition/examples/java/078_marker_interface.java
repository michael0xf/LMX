class Example {
    interface Auditable {}
    static class Marked implements Auditable {}
    static class Unmarked { int value = 7; }
    static int accepts(Object item) { return item instanceof Auditable ? 1 : 0; }
    static int demo() { return accepts(new Marked()) * 10 + accepts(new Unmarked()); }
}
