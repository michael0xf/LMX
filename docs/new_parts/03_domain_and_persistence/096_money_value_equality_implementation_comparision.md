# 096. Money value equality — implementation

Полностью показать конкретный двухкомпонентный Money и его импортируемое равенство.

**Примеры использования:** [032. Value Object](032_value_object_comparision.md)

## Общий сценарий

Хранить read-only cents/currency и сравнить обе компоненты в указанном порядке. Defaults 100/840, альтернативная currency 978.

**Ожидаемое наблюдение:** Два независимо созданных Money(100,840) дают true; Money(100,978) даёт false. Прямая запись в компоненты не входит в разрешённый API.

**Граница сравнения:** Реализация библиотеки. Это библиотека одного типа с двумя int-компонентами, не реализация Python dataclasses, C# records или универсального schema compiler. Принимаются корректные Money-значения; произвольные неверные типы и метапрограммное изменение классов/графа не сравниваются. В LMX защищены значения полей, как и в исходном примере; отдельная ретроактивная заморозка внешнего контейнера не добавлена.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

## LMX

```lmx
MoneyLibrary:
    immutable: Money:
        int: cents 100
        int: currency 840
    Equality:
        copy: sys\OPERANDS_TEMPLATE
        return: int
        equals:
            throws: OperandArity
            if: length(right) != 1
                throw: OperandArity()
            @: a \left
            @: b \right[0]
            return: a\cents = b\cents && a\currency = b\currency
```

Money — конкретный immutable-прототип с двумя готовыми прямыми int-полями. Внешняя запись immutable остаётся в исходном графе; она включена в явные пути клиента. Внутри квалифицированного Money нет дополнительных modifier-записей между ним и cents/currency, поэтому a\cents и a\currency обращаются к нужным полям скопированного результата. copy/merge создают контейнеры с immutable-компонентами; существующее mutable-значение не переквалифицируется. Equality ставит sys\OPERANDS_TEMPLATE первым, получает подготовленные значения ссылок и проверяет ровно один правый аргумент. Универсальная генерация равенства произвольных структур не заявляется; внешний контейнер результата не объявляется immutable только из-за immutable-компонентов.

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

Money — конкретный immutable-прототип с двумя готовыми прямыми int-полями. Внешняя запись immutable остаётся в исходном графе; она включена в явные пути клиента. Внутри квалифицированного Money нет дополнительных modifier-записей между ним и cents/currency, поэтому a\cents и a\currency обращаются к нужным полям скопированного результата. copy/merge создают контейнеры с immutable-компонентами; существующее mutable-значение не переквалифицируется. Equality ставит sys\OPERANDS_TEMPLATE первым, получает подготовленные значения ссылок и проверяет ровно один правый аргумент. Универсальная генерация равенства произвольных структур не заявляется; внешний контейнер результата не объявляется immutable только из-за immutable-компонентов.

## Сопоставление

Python использует базовый immutable tuple, запрещает instance dictionary через __slots__ и предоставляет read-only properties; same написан вручную. C# использует readonly struct/get-only properties и ручной Same. LMX использует готовые immutable primitive records и ручной оператор. Вспомогательная библиотека равенства не импортируется собственной реализацией; dataclass/record equality не подменяют показанный алгоритм.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 231 | 14 |
| Python | 268 | 10 |
| C# | 335 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Fully show the concrete two-component Money representation and imported equality.

**Usage examples:** [032. Value Object](032_value_object_comparision.md)

**Scenario.** Store read-only cents/currency and compare both components in order. Defaults are 100/840, with alternative currency 978.

**Expected observation.** Two independently constructed Money(100,840) values compare true; Money(100,978) compares false. Direct component mutation is not an admitted operation.

**LMX.** Money is a concrete immutable prototype with two ready direct int fields. The enclosing immutable receiver remains in the source graph and appears in explicit client paths. Within qualified Money no additional modifier record separates cents/currency from their parent, so a\cents and a\currency reach the copied result fields. copy/merge construct containing Structures with immutable components; no existing mutable value is requalified. Equality places sys\OPERANDS_TEMPLATE first, receives prepared reference values and requires exactly one right argument. This is not universal automatic equality for arbitrary Structures, nor a claim that the outer result container is immutable merely because its components are.

**Comparison.** Python uses a basic immutable tuple, removes the instance dictionary with __slots__, and exposes read-only properties; same is explicit. C# uses a readonly struct/get-only properties and explicit Same. LMX uses ready immutable primitive records and an explicit operand. No ready equality helper is imported by its own implementation; dataclass/record equality does not replace the shown algorithm.

**Scope and limitations.** This implements one type with two int components, not Python dataclasses, C# records, or a universal schema compiler. Inputs are valid Money values; invalid foreign types and metaprogrammatic class/graph mutation are outside scope. LMX protects field values as in the original example; no retroactive freezing of the outer container is added.

### Dependencies and execution boundaries

- **LMX:** Money is a concrete immutable prototype with two ready direct int fields. The enclosing immutable receiver remains in the source graph and appears in explicit client paths. Within qualified Money no additional modifier record separates cents/currency from their parent, so a\cents and a\currency reach the copied result fields. copy/merge construct containing Structures with immutable components; no existing mutable value is requalified. Equality places sys\OPERANDS_TEMPLATE first, receives prepared reference values and requires exactly one right argument. This is not universal automatic equality for arbitrary Structures, nor a claim that the outer result container is immutable merely because its components are.
- **Python:** Complete money.py, using only a basic tuple and its own two-field comparison.
- **C#:** Complete ExampleLib.Money, with readonly components and explicit Same, without record-generated equality.

## Источники / Sources

- [Martin Fowler — Value Object](https://martinfowler.com/eaaCatalog/valueObject.html) — Определение и границы паттерна.
- [Python — immutable tuples](https://docs.python.org/3/library/stdtypes.html#tuples) — Базовое immutable-представление двух компонент.
- [Python — data model and slots](https://docs.python.org/3/reference/datamodel.html#slots) — Конструирование tuple subclass и отсутствие instance dictionary.
- [Microsoft — readonly struct](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/struct#readonly-struct) — Read-only поля и свойства структуры.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
