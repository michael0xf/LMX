using System;
public sealed class Account(int balance=100) {
    public int Balance { get; private set; } = balance;
    public int Debit(int amount) {
        if (amount < 0 || amount > Balance) throw new InvalidOperationException("funds");
        Balance -= amount;
        return Balance;
    }
}
