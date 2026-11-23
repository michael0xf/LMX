using System.Collections.Generic;
public sealed record Row(int Quantity,int Price);
public sealed class OrderTable(IReadOnlyList<Row> rows) {
    public int Total() {
        int result=0;
        foreach (var row in rows) result += row.Quantity*row.Price;
        return result;
    }
}
