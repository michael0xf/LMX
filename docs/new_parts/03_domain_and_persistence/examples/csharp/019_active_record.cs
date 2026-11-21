using System;
public interface IDb { void Upsert(int id,int cents); }
public sealed class Account(IDb db,int id=7,int cents=100) {
    public int Cents { get; private set; } = cents;
    public void Debit(int amount) {
        if (amount < 0 || amount > Cents) throw new InvalidOperationException("funds");
        Cents -= amount;
    }
    public void Save() => db.Upsert(id,Cents);
}
