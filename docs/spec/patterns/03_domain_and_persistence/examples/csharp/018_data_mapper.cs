public sealed record Account(int Id, int Cents);
public interface IRows {
    int[] Read(int id);
    void Write(int id, int cents);
}
public sealed class Mapper(IRows rows) {
    public Account Load(int id) {
        int[] row = rows.Read(id);
        return new Account(row[0],row[1]);
    }
    public Account Save(Account value) {
        rows.Write(value.Id,value.Cents);
        return value;
    }
}
