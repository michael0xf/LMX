public interface ILocks {
    int Reserve(int id,int session);
    int Release(int id,int session,int token);
}
public interface IDb { int WriteWithLease(int id,int session,int token,int cents); }
public sealed class Edit(ILocks locks,IDb db) {
    public int Acquire(int id,int session) => locks.Reserve(id,session);
    public int Save(int id,int session,int token,int cents) => db.WriteWithLease(id,session,token,cents);
    public int Release(int id,int session,int token) => locks.Release(id,session,token);
}
