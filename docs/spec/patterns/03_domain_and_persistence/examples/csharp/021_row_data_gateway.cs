public interface IDb { int Execute(string sql,int cents,int id); }
public sealed class RowGateway(IDb db,int id,int cents) {
    public int Cents { get; set; } = cents;
    public int Update() => db.Execute("UPDATE account SET cents = ? WHERE id = ?",Cents,id);
}
