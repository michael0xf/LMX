function handle(admitted: boolean, route: number): number {
    if (!admitted) return 403;
    if (route === 1) return 200;
    return 404;
}
function demo() { return handle(true, 1); }
