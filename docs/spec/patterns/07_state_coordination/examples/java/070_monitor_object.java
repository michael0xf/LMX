final class Account {
    private int balance = 10;
    synchronized boolean withdraw(int amount) {
        if (amount < 0 || balance < amount) return false;
        balance -= amount; return true;
    }
    synchronized int read() { return balance; }
}
