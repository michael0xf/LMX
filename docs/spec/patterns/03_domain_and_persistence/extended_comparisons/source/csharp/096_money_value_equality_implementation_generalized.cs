#nullable enable
using System;
using System.Collections.Generic;
public static class FieldEquality {
    public static bool EqualFields<A,B>(IReadOnlyList<A> first, IReadOnlyList<B> second, Func<A,B,bool> same) {
        ArgumentNullException.ThrowIfNull(first); ArgumentNullException.ThrowIfNull(second);
        ArgumentNullException.ThrowIfNull(same);
        if (first.Count != second.Count) return false;
        for (int i=0; i<first.Count; i++) if (!same(first[i],second[i])) return false;
        return true;
    }
}
public readonly struct Money : IEquatable<Money> {
    public int Cents { get; }
    public int Currency { get; }
    public Money(int cents, int currency) { Cents=cents; Currency=currency; }
    public static Money Create(int cents=100, int currency=840) => new(cents,currency);
    public bool Equals(Money other) => FieldEquality.EqualFields(
        new[]{Cents,Currency}, new[]{other.Cents,other.Currency}, (a,b)=>a==b);
    public override bool Equals(object? other) => other is Money money && Equals(money);
    public override int GetHashCode() => HashCode.Combine(Cents,Currency);
    public static bool operator ==(Money a, Money b) => a.Equals(b);
    public static bool operator !=(Money a, Money b) => !a.Equals(b);
}
