# 032. Value Object

Равенство определяется значением, а не адресом экземпляра.

**Отдельное сравнение реализации:** [096. Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

## Общий сценарий

Сравнить отдельно созданные Money(100,840) и Money(100,840), затем Money(100,978). Currency — числовой код валюты.

**Ожидаемое наблюдение:** Первые два значения равны, третье отличается. demo кодирует эти две проверки как 10; идентичность объектов для равенства не требуется.

**Граница сравнения:** Использование библиотеки. Сравниваются только cents и currency двух уже допустимых Money-значений. Компоненты неизменяемы; низкоуровневая замена графовых фрагментов не является API компонента. Арифметика валют, хеширование и округление не включены. Клиент и полная реализация учитываются раздельно; типы и правила хранения языков не приравниваются.

LMX использует существующие средства ядра или явно названную компактную группу, определённую в связанном сравнении реализации. Иностранные клиенты используют настоящие средства языка или установленную библиотеку.

## LMX

```lmx
MoneyLibrary:
    immutable: Money:
        int: cents 100
        int: currency 840

MoneyFields:
    @: value
    return: @
    select:
        return: (value\cents; value\currency)

Demo:
    return: int
    run:
        throws: copy(FxThrows\predicate) FxRecordArity
        @: money MoneyLibrary\immutable\Money
        @: first (copy(money))
        @: second (copy(money))
        @: third (merge(money; immutable: (int: currency 978)))
        return: equals(first; second; MoneyFields\select) * 10 + equals(first; third; MoneyFields\select)
```

equals использует единственный общий выбор равенства и явно переданную проекцию MoneyFields. Проекция выбирает только cents/currency, вычисляется один раз для каждого достигнутого значения и возвращает целые поля. Общее equalFields не применяется ко всей Money-структуре вместо предметного отношения. run возвращает 10, как раньше; copy/merge создают новые значения и не меняют существующие. Профиль Money является частью клиента, алгоритм равенства — частью ядра.

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

equals использует единственный общий выбор равенства и явно переданную проекцию MoneyFields. Проекция выбирает только cents/currency, вычисляется один раз для каждого достигнутого значения и возвращает целые поля. Общее equalFields не применяется ко всей Money-структуре вместо предметного отношения. run возвращает 10, как раньше; copy/merge создают новые значения и не меняют существующие. Профиль Money является частью клиента, алгоритм равенства — частью ядра.

## Сопоставление

Восстановлен исходный конечный договор 22-Nov и короткий LMX-клиент. Контрольные языки сохраняют естественные стандартные средства из 23-Nov. Узкая реализация LMX показана отдельно; более общий алгоритм 23-Nov имеет отдельный договор. Реализация LMX общая и обобщённая; контрольный клиент сохраняет оговорённый прикладной профиль. Это не утверждение равного полного охвата стандартных библиотек.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 401 | 18 |
| Python | 213 | 8 |
| C# | <span style="color:#176233"><u>203</u></span> | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Equality follows component values rather than object identity.

**Separate implementation comparison:** [096. Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

**Scenario.** Compare distinct Money(100,840) values, then compare with Money(100,978). Currency is an integer code.

**Expected observation.** The first pair is equal and the third value differs. demo encodes the two checks as 10; equality does not require object identity.

**LMX.** equals reuses the common equality dispatch with an explicit MoneyFields projection, evaluated once per reached value. The projection selects only cents and currency; equality over every physical Money field is not substituted for this domain relation. run still yields 10. copy/merge construct new values without changing the originals; Money is the client profile and the equality algorithm belongs to the core.

**Comparison.** The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

**Scope and limitations.** Only cents and currency of already admissible Money values are compared. Components are read-only; low-level graph-fragment replacement is not part of the component API. Currency arithmetic, hashing, and rounding are excluded. Client and full implementation are counted separately; language type and storage guarantees are not equated.

### Dependencies and execution boundaries

- **LMX:** equals reuses the common equality dispatch with an explicit MoneyFields projection, evaluated once per reached value. The projection selects only cents and currency; equality over every physical Money field is not substituted for this domain relation. run still yields 10. copy/merge construct new values without changing the originals; Money is the client profile and the equality algorithm belongs to the core.
- **Python:** Real frozen dataclass and generated value equality; no money.py import.
- **C#:** Real record class; both fields and component equality are preserved.

## Источники / Sources

- [Python dataclasses](https://docs.python.org/3/library/dataclasses.html) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [C# records](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/types/records) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
