using System;
public interface IDb {
    int ReadLocked(int id);
    void Write(int id,int value);
    void Atomic(Action body);
}
public static class Transfers {
    public static void Transfer(IDb db,int fromId,int toId,int amount) {
        db.Atomic(() => {
            int a=db.ReadLocked(fromId), b=db.ReadLocked(toId);
            if (amount<0 || fromId==toId || a<amount) throw new InvalidOperationException("funds");
            db.Write(fromId,a-amount);
            db.Write(toId,b+amount);
        });
    }
}
