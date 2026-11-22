using System.Collections.Generic;
using ExampleLib;
public sealed record Account(int Id, int Cents) : IIdentified;
public sealed class Repository(IReadOnlyList<Account> rows) {
    public Account? Find(int id) => Records.FindById(rows, id);
}
