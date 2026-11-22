class Example {
    static class Board { int raw = 4, normalized, result; }
    static int normalize(Board b) {
        if (b.normalized != 0) return 0;
        b.normalized = b.raw + 1;
        return 1;
    }
    static int derive(Board b) {
        if (b.normalized == 0 || b.result != 0) return 0;
        b.result = b.normalized * 2;
        return 1;
    }
    static int demo() {
        Board b = new Board(); int changed = 1;
        while (changed != 0) changed = derive(b) + normalize(b);
        return b.result;
    }
}
