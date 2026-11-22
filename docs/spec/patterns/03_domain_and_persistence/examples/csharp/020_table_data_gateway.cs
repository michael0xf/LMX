public interface IDb {
    int Scalar(string sql,int id);
    int Execute(string sql,int cents,int id);
}
public sealed class Accounts(IDb db) {
    public int Balance(int id) => db.Scalar("SELECT cents FROM account WHERE id = ?",id);
    public int Update(int id,int cents) => db.Execute("UPDATE account SET cents = ? WHERE id = ?",cents,id);
}
