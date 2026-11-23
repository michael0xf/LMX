using System;
public interface IDb { int CompareAndSet(int id,int version,int cents); }
public static class Saves {
    public static void Save(IDb db,int id,int version,int cents) {
        if (db.CompareAndSet(id,version,cents)!=1) throw new InvalidOperationException("conflict");
    }
}
