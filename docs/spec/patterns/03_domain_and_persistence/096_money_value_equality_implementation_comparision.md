# 096. EqualFields — value equality implementation

Реализовать общее упорядоченное равенство полей с явно переданным отношением.

**Примеры использования:** [032. Value Object](032_value_object_comparision.md)

## Общий сценарий

Сравнить произвольные конечные последовательности по длине и парам полей; Money сохраняет read-only cents/currency.

**Ожидаемое наблюдение:** Пустые равны. При разных длинах comparator не вызывается; при равных обход останавливается на первом различии. Money даёт10. Ошибки comparator передаются дальше.

**Граница сравнения:** Реализация библиотеки. Позиционное равенство с явным comparator: не graph identity, deep equality, сериализация или поиск имён. Изменения во время сравнения не допускаются. Hash показан только для целостности иностранных value types.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

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

Общий цикл работает с любыми длинами и типами, используя переданный comparator. Immutable Money является обычным механизмом языка и показан в032.

[Отдельный листинг](examples/lmx/096_money_value_equality_implementation.lm3)

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

Полный общий comparator и ручной immutable Money с ==, != и согласованным hash; не замена всей dataclasses.

[Отдельный листинг](examples/python/096_money_value_equality_implementation.py)

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

Общий A/B comparator и полный ручной immutable value type. Примитивный HashCode.Combine относится к платформе; не сравнивается реализация hash table.

[Отдельный листинг](examples/csharp/096_money_value_equality_implementation.cs)

## Разбор LMX

Общий цикл работает с любыми длинами и типами, используя переданный comparator. Immutable Money является обычным механизмом языка и показан в032.

## Сопоставление

Общий цикл generic во всех языках. Иностранные ручные Money дополнительно показывают storage/value contracts. LMX использует свой immutable structural механизм, не имитируя класс.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 427 | 23 |
| Python | 637 | 21 |
| C# | 1037 | 24 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Implement reusable ordered field equality with an explicitly supplied relation.

**Usage examples:** [032. Value Object](032_value_object_comparision.md)

**Scenario.** Compare arbitrary finite sequences by length and each pair of fields; the Money fixture keeps cents and currency as read-only values.

**Expected observation.** Empty equals empty. Different lengths call no comparator. Equal lengths stop at the first unequal pair; the original Money fixture gives10. Comparator failures propagate.

**LMX.** Generic loop handles arbitrary lengths and types through the supplied comparator. Immutable Money uses ordinary language machinery shown in032.

**Comparison.** The common loop is generic in every language. Foreign manual Money types additionally expose their required field/storage/value protocols. LMX reuses the existing immutable structural mechanism instead of emulating a generated class.

**Scope and limitations.** Positional field equality with an explicit comparator, not graph identity, recursive deep equality, serialization, or automatic field-name matching. No concurrent mutation during comparison. Hashing is outside the common loop and is shown only to complete foreign value-type conventions.

### Dependencies and execution boundaries

- **LMX:** Generic loop handles arbitrary lengths and types through the supplied comparator. Immutable Money uses ordinary language machinery shown in032.
- **Python:** Complete generic comparator and manual immutable Money with ==, != and consistent hashing; not a reimplementation of all dataclasses.
- **C#:** Generic A/B comparator and complete manual immutable value type. Primitive HashCode.Combine is a platform dependency, not a hash-table implementation comparison.

## Источники / Sources

- [Python dataclasses contract](https://docs.python.org/3/library/dataclasses.html) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
