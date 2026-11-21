public interface IDao { int ReadBalance(int id); }
public interface IDb { int Scalar(string sql,int id); }
public sealed class DbDao(IDb db) : IDao {
    public int ReadBalance(int id) => db.Scalar("SELECT cents FROM account WHERE id = ?",id);
}
public sealed class FixedDao : IDao {
    public int ReadBalance(int id) => 25;
}
public static class Service {
    public static int Read(IDao dao,int id) => dao.ReadBalance(id);
}
