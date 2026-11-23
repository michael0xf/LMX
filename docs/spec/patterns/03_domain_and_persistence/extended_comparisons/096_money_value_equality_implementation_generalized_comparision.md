# 096. EqualFields — value equality implementation: отдельный расширенный договор

Сохранена самостоятельная обобщённая реализация 23-Nov. Она решает более широкую задачу, чем восстановленная основная пара 22-Nov, и не участвует в её сумме или выборе кратчайшего листинга.

## Договор

Сравнить произвольные конечные последовательности по длине и парам полей; Money сохраняет read-only cents/currency.

Пустые равны. При разных длинах comparator не вызывается; при равных обход останавливается на первом различии. Money даёт10. Ошибки comparator передаются дальше.

Позиционное равенство с явным comparator: не graph identity, deep equality, сериализация или поиск имён. Изменения во время сравнения не допускаются. Hash показан только для целостности иностранных value types.

## LMX

```lmx
FxEqualFields:
    private:
        @: first
        @: second
        @: same
    required: first second same
    return: int
    equalFields:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(first)
        FxSeqInfo\get(second)
        private: int: count length(first)
        if: count != length(second)
            return: 0
        private: int: i 0
        while: i < count
            private: @: a FxSeqRead\read(first; i)
            private: @: b FxSeqRead\read(second; i)
            private: @: accepted FxApply\apply(same; FxTwo\make(a; b))
            if: FxSeqPredicate\truth(accepted) = 0
                return: 0
            i += 1
        return: 1
```

[Исходник](source/lmx/096_money_value_equality_implementation_generalized.lm3)

Общий цикл работает с любыми длинами и типами, используя переданный comparator. Immutable Money является обычным механизмом языка и показан в032.

## Python

```python
def equal_fields(first, second, same):
    if not callable(same): raise TypeError("same must be callable")
    if len(first) != len(second): return False
    for index in range(len(first)):
        if not same(first[index], second[index]): return False
    return True

class Money(tuple):
    __slots__ = ()
    def __new__(cls, cents=100, currency=840):
        return tuple.__new__(cls, (cents, currency))
    @property
    def cents(self): return self[0]
    @property
    def currency(self): return self[1]
    def __eq__(self, other):
        if type(other) is not Money: return NotImplemented
        return equal_fields(self, other, lambda a,b: a == b)
    def __ne__(self, other):
        equal = self.__eq__(other)
        return NotImplemented if equal is NotImplemented else not equal
    __hash__ = tuple.__hash__
```

[Исходник](source/python/096_money_value_equality_implementation_generalized.py)

Полный общий comparator и ручной immutable Money с ==, != и согласованным hash; не замена всей dataclasses.

## C#

```csharp
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
```

[Исходник](source/csharp/096_money_value_equality_implementation_generalized.cs)

Общий A/B comparator и полный ручной immutable value type. Примитивный HashCode.Combine относится к платформе; не сравнивается реализация hash table.

## Измерение отдельной реализации

| Язык | Непробельные символы |
| --- | ---: |
| LMX | 427 |
| Python | 637 |
| C# | 1037 |

[Основная узкая пара](../096_money_value_equality_implementation_comparision.md). [Норма LMX](../../../LMX_semantics.en.md).

LMX здесь не выполнялся. Это сохранение исходников и их договора, а не новый отчёт о runtime-проверке.
