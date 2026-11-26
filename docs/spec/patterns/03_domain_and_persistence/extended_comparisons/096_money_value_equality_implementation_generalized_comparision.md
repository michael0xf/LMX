# 096. EqualFields — value equality implementation: общий договор

Действующие общие определения извлечены из единого ядра. Эта отдельная пара сохраняет свой договор; её размер не подменяет размер клиентского вызова.

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
        @: same 0
    required: first second
    return: int
    equalFields:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(first)
        FxSeqInfo\get(second)
        if: length(first) != length(second)
            return: 0
        return: FxSequenceDifference\find(
            first := first;
            second := second;
            same := same;
            count := length(first)
        ) < 0
```

[Исходник](source/lmx/096_money_value_equality_implementation_generalized.lm3)

Точные общие определения FxEqualFields из текущего ядра. Общий договор сохраняет явно указанные типы, контекст вызова и отказы. Копия обновляется из единственного исходника; runtime LMX — NOT_RUN.

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
        []new{Cents,Currency}, []new{other.Cents,other.Currency}, (a,b)=>a==b);
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
| LMX | 293 |
| Python | 637 |
| C# | 1037 |

Полный текст каждого листинга включает все объявления, заголовки Throws, аргументы и ссылки; исключений из подсчёта нет.

[Основная пара](../096_money_value_equality_implementation_comparision.md). [Единые формы](../../UNIFIED_OPERATIONS.md).

Результаты языкового выполнения изменённых исходников не заявлены.
