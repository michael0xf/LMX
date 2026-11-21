static class Example {
    static int Handle(bool admitted, int route) {
        if (!admitted) return 403;
        if (route == 1) return 200;
        return 404;
    }
    public static int Demo() => Handle(true, 1);
}
