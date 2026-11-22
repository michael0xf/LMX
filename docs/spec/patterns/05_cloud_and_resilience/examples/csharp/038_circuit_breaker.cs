sealed class Breaker {
    int failures, until;
    public int Invoke(int now, System.Func<int> request) {
        if (now < until) return -1;
        if (request() == 1) { failures = 0; until = 0; return 1; }
        failures++;
        if (failures >= 2) until = now + 5;
        return 0;
    }
}
