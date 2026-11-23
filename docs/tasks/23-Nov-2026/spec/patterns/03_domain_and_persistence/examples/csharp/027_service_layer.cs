using System;
public interface IAccount { void Debit(int amount); }
public interface IRepository {
    IAccount Load(int id);
    void Save(IAccount account);
}
public interface IDb { void Atomic(Action body); }
public static class Checkout {
    public static void Execute(IDb db,IRepository repository,int accountId,int amount) {
        db.Atomic(() => {
            IAccount account=repository.Load(accountId);
            account.Debit(amount);
            repository.Save(account);
        });
    }
}
