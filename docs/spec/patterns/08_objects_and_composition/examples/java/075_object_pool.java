class Example {
    static class Resource { final int id = 7; }
    static class Pool {
        Resource free = new Resource();
        Resource take() { Resource result = free; free = null; return result; }
        void give(Resource item) { free = item; }
    }
    static int demo() {
        Pool pool = new Pool(); Resource first = pool.take();
        Resource busy = pool.take(); pool.give(first);
        Resource again = pool.take();
        return first == again && busy == null ? 1 : 0;
    }
}
