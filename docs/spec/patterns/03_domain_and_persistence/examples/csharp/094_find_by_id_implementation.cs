#nullable enable
using System.Collections.Generic;
namespace ExampleLib {
    public interface IIdentified { int Id { get; } }
    public static class Records {
        public static T? FindById<T>(IEnumerable<T> rows, int id) where T : class, IIdentified {
            foreach (T row in rows) {
                if (row.Id == id) return row;
            }
            return null;
        }
    }
}
