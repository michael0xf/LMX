class Example {
    static class Host {
        int value = 7; Report extension;
        void install(Report addon) { extension = addon; }
        Report query() { return extension; }
    }
    record Report(Host target) { int render() { return target.value * 2; } }
    static int demo() {
        Host host = new Host(); host.install(new Report(host));
        return host.query().render();
    }
}
