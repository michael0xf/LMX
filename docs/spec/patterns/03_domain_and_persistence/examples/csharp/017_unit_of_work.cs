using System;
using System.Collections.Generic;
public interface IDb {
    void Upsert(int id, int cents);
    void Atomic(Action body);
}
public sealed class UnitOfWork(IDb db) {
    readonly Dictionary<int,int> dirty = new();
    public void Mark(int id, int cents) => dirty[id] = cents;
    public void Flush() {
        db.Atomic(() => { foreach (var row in dirty) db.Upsert(row.Key,row.Value); });
        dirty.Clear();
    }
}
