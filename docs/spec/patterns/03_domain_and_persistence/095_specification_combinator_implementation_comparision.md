# 095. Specification combinator — implementation

Общий allOf строит callable произвольной совместимой сигнатуры с коротким замыканием.

**Примеры использования:** [031. Specification](031_specification_comparision.md)

## Общий сценарий

Сохранить две callable-ссылки и вернуть новый int-предикат. При каждом вызове проверить левую часть; правую вызывать только после true.

**Ожидаемое наблюдение:** nonnegative both below100 даёт false,true,false для -1,50,100. При false слева счётчик правых вызовов не растёт. Повторный вызов использует сохранённые ссылки.

**Граница сравнения:** Реализация библиотеки. LMX показывает общий алгоритм с фактическими типами и исходным контекстом. Контрольные реализации сохраняют явно указанный прикладной профиль. Сравнение одного профиля не означает одинакового охвата библиотек или скорости; для полной стоимости прибавляются общие зависимости и runtime каждого языка.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
FxAllOfTypeToken:
    integer:
        int: value

FxAllOfState:
    @: predicates 0

FxAllOfEngine:
    private:
        @: state
        @: frame
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxPredicate FxRecordArity FxTypeToken ReceiverIndex
        private: int: i 0
        while: i < length(state\predicates)
            private: @: predicate \state\predicates[i]
            private: @: flag FxApplyPlaces\apply(predicate; frame)
            if: FxSeqPredicate\truth(flag) = 0
                return: (0 FxRecordOperands\record)
            i += 1
        return: (1 FxRecordOperands\record)

FxAllOf:
    private:
        @: predicates
        @: contract 0
    required: predicates
    return: @
    allOf:
        throws: copy(FxThrows\adapter)
        private: @: values FxSeqRecords\make(source := predicates)
        private: @: selected contract
        private: @: integerType FxKernel\normalizeType(FxAllOfTypeToken\integer[0])
        private: @: policy 0
        if: selected = 0
            if: length(values) = 0
                throw: FxArity()
            private: @: first \values[0]
            private: @: info FxKernel\signature(first)
            selected := FxSignatures\make(info\inputTypes; integerType)
            policy := FxFullPolicy\make(first)
        else:
            policy := FxOwnPolicy\make(selected)
        private: @: shape FxKernel\signature(selected)
        if: shape\hasResult = 0
            throw: FxTypeToken()
        if: \shape\resultType != \integerType
            throw: FxTypeToken()
        private: @: failures (copy(()))
        private: int: i 0
        while: i < length(values)
            private: @: operation \values[i]
            private: @: info FxKernel\signature(operation)
            if: info\hasResult = 0 || length(info\inputTypes) != length(shape\inputTypes)
                throw: FxTypeToken()
            if: \info\resultType != \integerType
                throw: FxTypeToken()
            private: int: position 0
            while: position < length(shape\inputTypes)
                if: \info\inputTypes[position] != \shape\inputTypes[position]
                    throw: FxTypeToken()
                position += 1
            failures := FxFailures\union(failures; info\throws)
            i += 1
        private: @: state (copy(FxAllOfState))
        state\predicates := values
        return: FxWrap\make(selected; FxAllOfEngine\run; state; failures; policy)
```

Точное текущее определение FxAllOfTypeToken, FxAllOfState, FxAllOfEngine, FxAllOf извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

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

Точное текущее определение FxAllOfTypeToken, FxAllOfState, FxAllOfEngine, FxAllOf извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

## Сопоставление

LMX явно строит сохраняемый граф и выбирает владельца; Python closure и C# lambda сохраняют ссылки средствами языка. Все три тела показывают собственный AND через &&/and и не вызывают готовый both. Ни SQL-expression builder, ни скрытый AST evaluator не используется. Обобщённая версия 23-Nov сохранена [отдельно](extended_comparisons/095_specification_combinator_implementation_generalized_comparision.md); она не подменяет эту узкую задачу.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/095_specification_combinator_implementation_generalized_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 1673 | 65 |
| Python | 83 | 4 |
| C# | 176 | 8 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Generic allOf builds a short-circuit callable with the actual compatible signature.

**Usage examples:** [031. Specification](031_specification_comparision.md)

**Scenario.** Retain two callable references and return a new int predicate. At each invocation evaluate the left side, then the right side only after true.

**Expected observation.** nonnegative both below100 yields false,true,false for -1,50,100. A false left result does not increment a right-call counter. Repeated calls reuse the retained references.

**LMX.** The exact current FxAllOfTypeToken, FxAllOfState, FxAllOfEngine, FxAllOf definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.

**Comparison.** LMX explicitly constructs the retained graph and selects its owner; Python closures and C# lambdas retain references through language facilities. All three implement their own AND using &&/and, without calling a ready both. No SQL expression builder or hidden AST evaluator is used. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

**Scope and limitations.** LMX shows the common algorithm with actual types and original context. Foreign implementations retain the stated application profile. A comparison for one profile does not establish equal library coverage or speed; complete cost includes shared dependencies and each runtime.

### Dependencies and execution boundaries

- **LMX:** The exact current FxAllOfTypeToken, FxAllOfState, FxAllOfEngine, FxAllOf definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.
- **Python:** Complete specification.py; an ordinary closure retains two references, and implements short-circuiting.
- **C#:** Complete ExampleLib.Specification; Func is only the callable type, and Both is implemented here.

## Источники / Sources

- [Eric Evans and Martin Fowler — Specifications](https://martinfowler.com/apsupp/spec.pdf) — Определение и границы паттерна.
- [Python — Boolean operations](https://docs.python.org/3/library/stdtypes.html#boolean-operations-and-or-not) — Правый операнд and вызывается по необходимости.
- [Microsoft — conditional logical operators](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/boolean-logical-operators) — Короткое замыкание встроенного &&.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
