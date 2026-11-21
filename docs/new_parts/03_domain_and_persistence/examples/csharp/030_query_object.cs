using System;
public interface IDb { object Query(string sql,int minimum,int maximum); }
public sealed record RangeQuery(int Minimum,int Maximum) {
    public object Execute(IDb db) {
        if (Minimum>Maximum) throw new ArgumentException("range");
        return db.Query("SELECT id,cents FROM account WHERE cents BETWEEN ? AND ?",Minimum,Maximum);
    }
}
