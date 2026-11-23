# 032. Value Object

Равенство определяется значением, а не адресом экземпляра.

**Отдельное сравнение реализации:** [096. EqualFields — value equality implementation](096_money_value_equality_implementation_comparision.md)

## Общий сценарий

Сравнить отдельно созданные Money(100,840) и Money(100,840), затем Money(100,978). Currency — числовой код валюты.

**Ожидаемое наблюдение:** Первые два значения равны, третье отличается. demo кодирует эти две проверки как 10; идентичность объектов для равенства не требуется.

**Граница сравнения:** Использование библиотеки. Read-only cents/currency с исходными100/840 и альтернативой978. Равенство позиционное по двум полям модели. Currency arithmetic и универсальный schema generator не заявляются.

LMX вызывает операции единого ядра. Иностранные клиенты используют настоящие средства языка или установленную библиотеку; показанные рядом самостоятельные реализации в них не импортируются.

## LMX

```lmx
immutable: Money:
    int: cents 100
    int: currency 840

NumberEquality:
    int: first
    int: second
    return: int
    same:
        return: first = second

Demo:
    return: int
    run:
        throws: copy(FxThrows\predicate)
        @: first (copy(Money))
        @: second (copy(Money))
        @: third (merge(Money; immutable: (int: currency 978)))
        return: equalFields(first; second; NumberEquality\same) * 10 + equalFields(first; third; NumberEquality\same)
```

Money остаётся прикладной immutable Structure с cents и currency. В ядро входит только общий equalFields с явным scalar comparator.

[Отдельный листинг](examples/lmx/032_value_object.lm3)

## Python

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Money:
    cents: int = 100
    currency: int = 840

def demo():
    first, second, third = Money(), Money(), Money(currency=978)
    return int(first == second) * 10 + int(first == third)
```

Реальный frozen dataclass и сгенерированное value equality; money.py не импортируется.

[Отдельный листинг](examples/python/032_value_object.py)

## C#

```csharp
public sealed record Money(int Cents = 100, int Currency = 840);
public static class Example {
    public static int Demo() {
        Money first = new(), second = new(), third = new(Currency: 978);
        return (first == second ? 10 : 0) + (first == third ? 1 : 0);
    }
}
```

Настоящий record class; оба поля и компонентное равенство сохранены.

[Отдельный листинг](examples/csharp/032_value_object.cs)

## Разбор LMX

Money остаётся прикладной immutable Structure с cents и currency. В ядро входит только общий equalFields с явным scalar comparator.

## Сопоставление

Клиенты используют настоящие средства immutable/value. LMX явно задаёт comparator полей; Python/C# генерируют его. Money не становится builtin. Общий цикл и ручные модели хранения сравниваются в096.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 351 | 17 |
| Python | 213 | 8 |
| C# | 203 | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Equality follows component values rather than object identity.

**Separate implementation comparison:** [096. EqualFields — value equality implementation](096_money_value_equality_implementation_comparision.md)

**Scenario.** Compare distinct Money(100,840) values, then compare with Money(100,978). Currency is an integer code.

**Expected observation.** The first pair is equal and the third value differs. demo encodes the two checks as 10; equality does not require object identity.

**LMX.** Money remains an application immutable Structure with cents and currency. Only generic equalFields with an explicit scalar comparator belongs to the core.

**Comparison.** The clients use actual immutable/value facilities. LMX states its field comparator explicitly; Python and C# generate it from the record fields. Money is never promoted into a language builtin. The reusable equality loop and manual storage counterparts are in096.

**Scope and limitations.** Read-only cents and currency, with original 100/840 defaults and978 alternative. Equality is positional over this explicit two-field model. Hashing, currency arithmetic, and a universal reflection-based schema generator are not claimed.

### Dependencies and execution boundaries

- **LMX:** Money remains an application immutable Structure with cents and currency. Only generic equalFields with an explicit scalar comparator belongs to the core.
- **Python:** Real frozen dataclass and generated value equality; no money.py import.
- **C#:** Real record class; both fields and component equality are preserved.

## Источники / Sources

- [Python dataclasses](https://docs.python.org/3/library/dataclasses.html) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [C# records](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/types/records) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
