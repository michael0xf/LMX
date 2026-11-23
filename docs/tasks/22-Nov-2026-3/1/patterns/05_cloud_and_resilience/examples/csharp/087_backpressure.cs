sealed class Producer(System.Action<int> send) {
    int credit;
    public int Grant() => ++credit;
    public bool Offer(int value) {
        if (credit == 0) return false;
        credit--; send(value); return true;
    }
}
