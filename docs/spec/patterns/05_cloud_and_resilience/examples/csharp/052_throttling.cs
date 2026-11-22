sealed class Throttle {
    int window = -1, count;
    public bool Allow(int now) {
        int current = now / 10;
        if (current != window) { window = current; count = 0; }
        if (count >= 2) return false;
        count++; return true;
    }
}
