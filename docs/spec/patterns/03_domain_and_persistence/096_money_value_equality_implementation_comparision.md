# 096. Money value equality — implementation

Общий equals сравнивает значения через явную проекцию и единое равенство.

**Примеры использования:** [032. Value Object](032_value_object_comparision.md)

## Общий сценарий

Хранить read-only cents/currency и сравнить обе компоненты в указанном порядке. Defaults 100/840, альтернативная currency 978.

**Ожидаемое наблюдение:** Два независимо созданных Money(100,840) дают true; Money(100,978) даёт false. Прямая запись в компоненты не входит в разрешённый API.

**Граница сравнения:** Реализация библиотеки. LMX показывает общий алгоритм с фактическими типами и исходным контекстом. Контрольные реализации сохраняют явно указанный прикладной профиль. Сравнение одного профиля не означает одинакового охвата библиотек или скорости; для полной стоимости прибавляются общие зависимости и runtime каждого языка.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
FxEquals:
    private:
        @: first
        @: second
        @: projection 0
        @: same 0
    required: first second
    return: int
    equals:
        throws: copy(FxThrows\predicate)
        private: @: a FxProjectValue\get(first; projection)
        private: @: b FxProjectValue\get(second; projection)
        return: FxValueSame\test(a; b; same)
```

Точное текущее определение FxEquals извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

[Отдельный листинг](examples/lmx/096_money_value_equality_implementation.lm3)

## Python

```python
class Money(tuple):
    __slots__ = ()
    def __new__(cls, cents=100, currency=840):
        return tuple.__new__(cls, (cents, currency))
    @property
    def cents(self): return self[0]
    @property
    def currency(self): return self[1]

def same(left, right):
    return left.cents == right.cents and left.currency == right.currency
```

Полный money.py; только базовый tuple и собственное сравнение двух полей.

[Отдельный листинг](examples/python/096_money_value_equality_implementation.py)

## C#

```csharp
namespace ExampleLib {
    public readonly struct Money {
        public int Cents { get; }
        public int Currency { get; }
        public Money(int cents, int currency) { Cents = cents; Currency = currency; }
        public static Money Create(int cents = 100, int currency = 840) => new Money(cents, currency);
        public static bool Same(Money left, Money right) =>
            left.Cents == right.Cents && left.Currency == right.Currency;
    }
}
```

Полный ExampleLib.Money; readonly-компоненты и собственный Same, без record-generated equality.

[Отдельный листинг](examples/csharp/096_money_value_equality_implementation.cs)

## Разбор LMX

Точное текущее определение FxEquals извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

## Сопоставление

Python использует базовый immutable tuple, запрещает instance dictionary через __slots__ и предоставляет read-only properties; same написан вручную. C# использует readonly struct/get-only properties и ручной Same. LMX использует готовые immutable primitive records и ручной оператор. Вспомогательная библиотека равенства не импортируется собственной реализацией; dataclass/record equality не подменяют показанный алгоритм. Обобщённая версия 23-Nov сохранена [отдельно](extended_comparisons/096_money_value_equality_implementation_generalized_comparision.md); она не подменяет эту узкую задачу.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/096_money_value_equality_implementation_generalized_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>248</u></span> | 13 |
| Python | 268 | 10 |
| C# | 335 | 10 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Generic equals applies an explicit projection and the shared equality dispatch.

**Usage examples:** [032. Value Object](032_value_object_comparision.md)

**Scenario.** Store read-only cents/currency and compare both components in order. Defaults are 100/840, with alternative currency 978.

**Expected observation.** Two independently constructed Money(100,840) values compare true; Money(100,978) compares false. Direct component mutation is not an admitted operation.

**LMX.** The exact current FxEquals definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.

**Comparison.** Python uses a basic immutable tuple, removes the instance dictionary with __slots__, and exposes read-only properties; same is explicit. C# uses a readonly struct/get-only properties and explicit Same. LMX uses ready immutable primitive records and an explicit operand. No ready equality helper is imported by its own implementation; dataclass/record equality does not replace the shown algorithm. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

**Scope and limitations.** LMX shows the common algorithm with actual types and original context. Foreign implementations retain the stated application profile. A comparison for one profile does not establish equal library coverage or speed; complete cost includes shared dependencies and each runtime.

### Dependencies and execution boundaries

- **LMX:** The exact current FxEquals definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.
- **Python:** Complete money.py, using only a basic tuple and its own two-field comparison.
- **C#:** Complete ExampleLib.Money, with readonly components and explicit Same, without record-generated equality.

## Источники / Sources

- [Martin Fowler — Value Object](https://martinfowler.com/eaaCatalog/valueObject.html) — Определение и границы паттерна.
- [Python — immutable tuples](https://docs.python.org/3/library/stdtypes.html#tuples) — Базовое immutable-представление двух компонент.
- [Python — data model and slots](https://docs.python.org/3/reference/datamodel.html#slots) — Конструирование tuple subclass и отсутствие instance dictionary.
- [Microsoft — readonly struct](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/struct#readonly-struct) — Read-only поля и свойства структуры.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
