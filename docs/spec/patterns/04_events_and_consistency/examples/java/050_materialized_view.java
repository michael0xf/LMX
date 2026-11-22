final class Projection {
    private int total,last;
    int apply(int seq,int delta) {
        if (seq<=last) return total;
        if (seq!=last+1) throw new IllegalStateException("gap");
        total+=delta;
        last=seq;
        return total;
    }
    int query() { return total; }
}
