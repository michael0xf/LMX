# 095. Specification combinator — implementation

Реализовать импортируемую бинарную композицию двух предикатов с коротким замыканием.

**Примеры использования:** [031. Specification](031_specification_comparision.md)

## Общий сценарий

Сохранить две callable-ссылки и вернуть новый int-предикат. При каждом вызове проверить левую часть; правую вызывать только после true.

**Ожидаемое наблюдение:** nonnegative both below100 даёт false,true,false для -1,50,100. При false слева счётчик правых вызовов не растёт. Повторный вызов использует сохранённые ссылки.

**Граница сравнения:** Реализация библиотеки. Только одна целочисленная аргументная позиция и два предиката. Ссылки должны оставаться допустимыми в одном Message/контексте; raw occurrences и сохранение завершённых активаций не применяются. В LMX лишние правые операнды дают OperandArity; это не автоматический fold.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

## LMX

```lmx
SpecificationLibrary:
    independent: AndData:
        @: first 0
        @: second 0
        inputs:
            int: value
            return: int
            accepts:
                return: node\first(value) && node\second(value)
    Operators:
        copy: sys\OPERANDS_TEMPLATE
        return: @
        both:
            throws: OperandArity
            if: length(right) != 1
                throw: OperandArity()
            @: instance (copy(AndData))
            @: owner parent(instance\inputs)
            owner\first := \left
            owner\second := \right[0]
            return: instance\inputs\accepts
```

Шаблон AndData independent, чтобы копирование не захватывало внешнюю лексическую цепочку. После (copy(...)) owner выбирается как фактический parent скопированного inputs; внешний контейнер группы не считается владельцем. В owner сохраняются значения ссылок на предикаты, не адреса временных left/right ячеек. Вернувшийся accepts имеет DATA=inputs с единственным int-входом, читает сохранённые callable через node и не удерживает frame фабрики. Поэтому результат можно снова использовать и передавать в следующий both. Шаблон операнда даёт режим 0 и приоритет +; арность проверяется до сохранения ссылок. AndData выбирается обычным лексическим именем: explicit-путь к его исходной записи проходил бы через сохранённый independent.

[Отдельный листинг](examples/lmx/095_specification_combinator_implementation.lm3)

## Python

```python
def both(left, right):
    def accepts(value):
        return left(value) and right(value)
    return accepts
```

Полный specification.py; обычная closure сохраняет две ссылки, and реализует короткое замыкание.

[Отдельный листинг](examples/python/095_specification_combinator_implementation.py)

## C#

```csharp
using System;
namespace ExampleLib {
    public static class Specification {
        public static Func<int,bool> Both(Func<int,bool> left, Func<int,bool> right) {
            return value => left(value) && right(value);
        }
    }
}
```

Полный компонент ExampleLib.Specification; Func — только тип callable, Both реализован здесь.

[Отдельный листинг](examples/csharp/095_specification_combinator_implementation.cs)

## Разбор LMX

Шаблон AndData independent, чтобы копирование не захватывало внешнюю лексическую цепочку. После (copy(...)) owner выбирается как фактический parent скопированного inputs; внешний контейнер группы не считается владельцем. В owner сохраняются значения ссылок на предикаты, не адреса временных left/right ячеек. Вернувшийся accepts имеет DATA=inputs с единственным int-входом, читает сохранённые callable через node и не удерживает frame фабрики. Поэтому результат можно снова использовать и передавать в следующий both. Шаблон операнда даёт режим 0 и приоритет +; арность проверяется до сохранения ссылок. AndData выбирается обычным лексическим именем: explicit-путь к его исходной записи проходил бы через сохранённый independent.

## Сопоставление

LMX явно строит сохраняемый граф и выбирает владельца; Python closure и C# lambda сохраняют ссылки средствами языка. Все три тела показывают собственный AND через &&/and и не вызывают готовый both. Ни SQL-expression builder, ни скрытый AST evaluator не используется.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 369 | 21 |
| Python | 83 | 4 |
| C# | 176 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Implement imported binary predicate composition with short-circuiting.

**Usage examples:** [031. Specification](031_specification_comparision.md)

**Scenario.** Retain two callable references and return a new int predicate. At each invocation evaluate the left side, then the right side only after true.

**Expected observation.** nonnegative both below100 yields false,true,false for -1,50,100. A false left result does not increment a right-call counter. Repeated calls reuse the retained references.

**LMX.** AndData is independent so copying does not capture an external lexical chain. After grouped copy, owner is the actual parent of the copied inputs; the receiving group is not assumed to own it. The owner stores predicate reference values, not temporary left/right-cell addresses. Returned accepts has inputs as DATA with one int formal, reads stored callables through node, and retains no factory frame. It can therefore be reused or supplied to another both. The operand template supplies mode 0 and additive priority; arity is checked before storing references. AndData is selected by ordinary lexical name; an explicit source-graph path would pass through its retained independent receiver.

**Comparison.** LMX explicitly constructs the retained graph and selects its owner; Python closures and C# lambdas retain references through language facilities. All three implement their own AND using &&/and, without calling a ready both. No SQL expression builder or hidden AST evaluator is used.

**Scope and limitations.** There is one integer argument position and two predicates. References must remain valid in one Message/context; raw occurrences and retention of finished activations are not used. Extra right operands cause OperandArity in LMX; there is no automatic fold.

### Dependencies and execution boundaries

- **LMX:** AndData is independent so copying does not capture an external lexical chain. After grouped copy, owner is the actual parent of the copied inputs; the receiving group is not assumed to own it. The owner stores predicate reference values, not temporary left/right-cell addresses. Returned accepts has inputs as DATA with one int formal, reads stored callables through node, and retains no factory frame. It can therefore be reused or supplied to another both. The operand template supplies mode 0 and additive priority; arity is checked before storing references. AndData is selected by ordinary lexical name; an explicit source-graph path would pass through its retained independent receiver.
- **Python:** Complete specification.py; an ordinary closure retains two references, and implements short-circuiting.
- **C#:** Complete ExampleLib.Specification; Func is only the callable type, and Both is implemented here.

## Источники / Sources

- [Eric Evans and Martin Fowler — Specifications](https://martinfowler.com/apsupp/spec.pdf) — Определение и границы паттерна.
- [Python — Boolean operations](https://docs.python.org/3/library/stdtypes.html#boolean-operations-and-or-not) — Правый операнд and вызывается по необходимости.
- [Microsoft — conditional logical operators](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/boolean-logical-operators) — Короткое замыкание встроенного &&.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
