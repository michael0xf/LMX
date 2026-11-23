# 032. Value Object

Равенство определяется значением, а не адресом экземпляра.

**Реализация используемого компонента:** [096. Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

## Общий сценарий

Сравнить отдельно созданные Money(100,840) и Money(100,840), затем Money(100,978). Currency — числовой код валюты.

**Ожидаемое наблюдение:** Первые два значения равны, третье отличается. demo кодирует эти две проверки как 10; идентичность объектов для равенства не требуется.

**Граница сравнения:** Использование библиотеки. Сравниваются только cents и currency двух уже допустимых Money-значений. Компоненты неизменяемы; низкоуровневая замена графовых фрагментов не является API компонента. Арифметика валют, хеширование и округление не включены. Клиент и полная реализация учитываются раздельно; типы и правила хранения языков не приравниваются.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

```lmx
Demo:
    return: int
    run:
        throws: OperandArity
        import: MoneyLibrary\Equality
        @: first (copy(MoneyLibrary\immutable\Money))
        @: second (copy(MoneyLibrary\immutable\Money))
        @: third (merge(MoneyLibrary\immutable\Money; immutable: (int: currency 978)))
        return: (first equals second) * 10 + (first equals third)
```

Demo\run() возвращает 10: истина для first/second и ложь для first/third. Все клиенты используют готовый конкретный Money; его полная реализация и сравнение двух компонентов даны рядом. В исходном графе Money находится под сохранённым immutable, поэтому явные пути включают MoneyLibrary\immutable\Money. Внутри Money поля cents/currency — прямые terminal int; квалификация всего прототипа делает их значения immutable. copy создаёт отдельные контейнеры из этих полей. В merge второй источник — вызов immutable с одним анонимным контейнером (int: currency 978): результат имеет прямое immutable-поле currency и совместим с моделью. Это создание нового значения, без изменения существующего. equals наследует mode 0 и приоритет +, проверяет бинарную арность; скобки отделяют сравнения от арифметики. Встроенное сравнение ссылок не переопределяется.

[Отдельный листинг](examples/lmx/032_value_object.lm3)

## Python

```python
from money import Money, same

def demo():
    first = Money()
    second = Money()
    third = Money(currency=978)
    return int(same(first, second)) * 10 + int(same(first, third))
```

money.py дан целиком в companion. Money() создаёт новый tuple-subclass экземпляр; same сравнивает поля явно.

[Отдельный листинг](examples/python/032_value_object.py)

## C#

```csharp
using ExampleLib;
public static class Example {
    public static int Demo() {
        Money first = Money.Create();
        Money second = Money.Create();
        Money third = Money.Create(currency: 978);
        return (Money.Same(first, second) ? 10 : 0) + (Money.Same(first, third) ? 1 : 0);
    }
}
```

ExampleLib.Money дан целиком в companion. Create устраняет неоднозначность zero-initialized default struct и задаёт defaults 100/840 явно.

[Отдельный листинг](examples/csharp/032_value_object.cs)

## Разбор LMX

Demo\run() возвращает 10: истина для first/second и ложь для first/third. Все клиенты используют готовый конкретный Money; его полная реализация и сравнение двух компонентов даны рядом. В исходном графе Money находится под сохранённым immutable, поэтому явные пути включают MoneyLibrary\immutable\Money. Внутри Money поля cents/currency — прямые terminal int; квалификация всего прототипа делает их значения immutable. copy создаёт отдельные контейнеры из этих полей. В merge второй источник — вызов immutable с одним анонимным контейнером (int: currency 978): результат имеет прямое immutable-поле currency и совместим с моделью. Это создание нового значения, без изменения существующего. equals наследует mode 0 и приоритет +, проверяет бинарную арность; скобки отделяют сравнения от арифметики. Встроенное сравнение ссылок не переопределяется.

## Сопоставление

Все три клиента создают два значения с одинаковыми компонентами и третье с другой currency, затем вызывают готовое равенство. Реализация вынесена симметрично и показана рядом: LMX — явный equals-операнд, Python — tuple-based Money и явный same, C# — readonly struct и явный Same. Ни размер клиента, ни размер реализации не выдаётся за стоимость универсального dataclass/record generator.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 273 | 9 |
| Python | 142 | 6 |
| C# | 224 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Equality follows component values rather than object identity.

**Implementation of the supplied component:** [096. Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

**Scenario.** Compare distinct Money(100,840) values, then compare with Money(100,978). Currency is an integer code.

**Expected observation.** The first pair is equal and the third value differs. demo encodes the two checks as 10; equality does not require object identity.

**LMX.** Demo\run() returns 10: true for first/second, false for first/third. All clients use the ready concrete Money whose full two-component implementation is shown beside them. Money is under a retained immutable receiver, so explicit source paths include MoneyLibrary\immutable\Money. Its cents/currency children are direct terminal int declarations; qualifying the whole prototype makes their values immutable. copy constructs distinct containing Structures from those fields. The second merge source calls immutable with one anonymous Structure (int: currency 978); its result has a direct immutable currency field matching the model. This constructs a new value without mutating an existing one. equals inherits mode 0 and additive priority and checks binary arity; groups separate comparison from arithmetic. Built-in reference comparison is not overridden.

**Comparison.** All clients create two equal component values and a third with another currency, then call ready value equality. Implementation is separated symmetrically and shown alongside: an explicit LMX equals operand, tuple-based Python Money with same, and a C# readonly struct with Same. Neither client nor implementation size represents a universal dataclass/record generator.

**Scope and limitations.** Only cents and currency of already admissible Money values are compared. Components are read-only; low-level graph-fragment replacement is not part of the component API. Currency arithmetic, hashing, and rounding are excluded. Client and full implementation are counted separately; language type and storage guarantees are not equated.

### Dependencies and execution boundaries

- **LMX:** Demo\run() returns 10: true for first/second, false for first/third. All clients use the ready concrete Money whose full two-component implementation is shown beside them. Money is under a retained immutable receiver, so explicit source paths include MoneyLibrary\immutable\Money. Its cents/currency children are direct terminal int declarations; qualifying the whole prototype makes their values immutable. copy constructs distinct containing Structures from those fields. The second merge source calls immutable with one anonymous Structure (int: currency 978); its result has a direct immutable currency field matching the model. This constructs a new value without mutating an existing one. equals inherits mode 0 and additive priority and checks binary arity; groups separate comparison from arithmetic. Built-in reference comparison is not overridden.
- **Python:** The companion supplies complete money.py. Money() constructs a new tuple-subclass instance; same explicitly compares components.
- **C#:** The companion fully supplies ExampleLib.Money. Create avoids the zero-initialized default-struct case and explicitly supplies defaults 100/840.

## Источники / Sources

- [Martin Fowler — Value Object](https://martinfowler.com/eaaCatalog/valueObject.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
