using System.Collections.Generic;
using System.Linq;
public sealed record Account(int Id, int Cents);
public sealed class Repository(IReadOnlyList<Account> rows) {
    public Account? Find(int id) => rows.FirstOrDefault(row => row.Id == id);
}
