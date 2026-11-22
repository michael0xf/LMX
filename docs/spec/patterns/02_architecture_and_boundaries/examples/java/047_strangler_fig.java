class Example {
    static class Router {
        boolean migrated;
        int legacy(int route) { return 100 + route; }
        int modern(int route) { return 200 + route; }
        int handle(int route) {
            return route == 1 && migrated ? modern(route) : legacy(route);
        }
    }
    static int demo() {
        Router r = new Router(); int before = r.handle(1);
        r.migrated = true;
        return before + r.handle(1) + r.handle(2);
    }
}
