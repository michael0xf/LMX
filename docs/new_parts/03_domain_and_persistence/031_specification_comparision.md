# 031. Specification

Комбинировать предикаты, отделённые от проверяемого значения.

**Реализация используемого компонента:** [095. Specification combinator — implementation](095_specification_combinator_implementation_comparision.md)

## Общий сценарий

Соединить nonnegative и below100 через AND; проверить -1,50,100.

**Ожидаемое наблюдение:** Результаты false,true,false. Правый предикат не вызывается, если левый дал false.

**Граница сравнения:** Использование библиотеки. Показаны только int-предикаты без объявленных failure при проверке значения. build не выполняет проверки заранее. Генерация SQL, сериализация и subsumption не включены. Это исполняемая Specification, не implements. Короткий клиент и полный код combinator измеряются отдельно.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

```lmx
Predicates:
    int: value
    return: int
    nonnegative:
        return: value >= 0
    below100:
        return: value < 100

SpecificationExample:
    return: @
    build:
        throws: OperandArity
        import: SpecificationLibrary\Operators
        return: Predicates\nonnegative both Predicates\below100
```

Клиент импортирует готовый both из SpecificationLibrary\Operators; его полный исходник находится в соседнем сравнении. Внешний driver получает predicate := SpecificationExample\build(), затем вызывает predicate(-1), predicate(50), predicate(100). Оператор бинарный: одна левая ссылка на callable и ровно одна правая; helper явно проверяет length(right)=1 и объявляет OperandArity, build распространяет этот failure. Унаследованы PASS_ARGS_AS_IS=0 и приоритет +; подготовка ссылок не исполняет предикаты. Результат — сохраняемый callable; && и сохранение ссылок показаны в реализации, а не предполагаются встроенной возможностью.

[Отдельный листинг](examples/lmx/031_specification.lm3)

## Python

```python
from specification import both

def nonnegative(value): return value >= 0
def below100(value): return value < 100

def build():
    return both(nonnegative, below100)
```

Модуль specification.py полностью показан в companion. build() возвращает callable; внешний driver проверяет три значения.

[Отдельный листинг](examples/python/031_specification.py)

## C#

```csharp
using System;
using ExampleLib;
public static class Specifications {
    public static bool Nonnegative(int value) => value >= 0;
    public static bool Below100(int value) => value < 100;
    public static Func<int,bool> Build() => Specification.Both(Nonnegative, Below100);
}
```

ExampleLib.Specification полностью показан в companion; внешняя точка входа Specifications.Build().

[Отдельный листинг](examples/csharp/031_specification.cs)

## Разбор LMX

Клиент импортирует готовый both из SpecificationLibrary\Operators; его полный исходник находится в соседнем сравнении. Внешний driver получает predicate := SpecificationExample\build(), затем вызывает predicate(-1), predicate(50), predicate(100). Оператор бинарный: одна левая ссылка на callable и ровно одна правая; helper явно проверяет length(right)=1 и объявляет OperandArity, build распространяет этот failure. Унаследованы PASS_ARGS_AS_IS=0 и приоритет +; подготовка ссылок не исполняет предикаты. Результат — сохраняемый callable; && и сохранение ссылок показаны в реализации, а не предполагаются встроенной возможностью.

## Сопоставление

Все три клиента определяют конкретные nonnegative/below100 и импортируют готовый combinator для построения reusable-предиката. В LMX запись A both B делает композицию выражением; Python и C# используют вызов фабрики. Соседняя реализация сохраняет проверку значения и короткое замыкание явно во всех трёх языках.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 225 | 13 |
| Python | 140 | 5 |
| C# | 231 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Compose predicates independently of their candidate values.

**Implementation of the supplied component:** [095. Specification combinator — implementation](095_specification_combinator_implementation_comparision.md)

**Scenario.** Combine nonnegative and below100 with AND; test -1,50,100.

**Expected observation.** Results are false,true,false; the right predicate is skipped when the left is false.

**LMX.** The client imports ready both from SpecificationLibrary\Operators; the companion shows its full source. An external driver obtains predicate := SpecificationExample\build(), then invokes it for -1,50,100. The operator is binary: one left callable and exactly one right callable. The helper checks right length and declares OperandArity; build propagates it. It inherits mode 0 and additive priority; preparing references does not run predicates. The result is a reusable callable; the implementation explicitly shows reference retention and && rather than assuming a builtin combinator.

**Comparison.** Each client defines concrete nonnegative/below100 predicates and imports the combinator that builds a reusable predicate. LMX makes composition an A both B expression; Python and C# call a factory. The companion explicitly implements evaluation and short-circuiting in all three languages.

**Scope and limitations.** Only int predicates without declared evaluation failures are included. build does not evaluate them early. SQL generation, serialization, and subsumption are excluded. Executable Specification is distinct from implements. Client and complete combinator implementation are measured separately.

### Dependencies and execution boundaries

- **LMX:** The client imports ready both from SpecificationLibrary\Operators; the companion shows its full source. An external driver obtains predicate := SpecificationExample\build(), then invokes it for -1,50,100. The operator is binary: one left callable and exactly one right callable. The helper checks right length and declares OperandArity; build propagates it. It inherits mode 0 and additive priority; preparing references does not run predicates. The result is a reusable callable; the implementation explicitly shows reference retention and && rather than assuming a builtin combinator.
- **Python:** The companion fully defines specification.py. build() returns a callable; the external driver checks three values.
- **C#:** The companion fully defines ExampleLib.Specification; call Specifications.Build().

## Источники / Sources

- [Eric Evans and Martin Fowler — Specifications](https://martinfowler.com/apsupp/spec.pdf) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
