static int Live() => 200;
static int Ready(System.Func<bool> probe) => probe() ? 200 : 503;
