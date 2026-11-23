# 095. AllOf — predicate conjunction implementation

Построить упорядоченную short-circuit conjunction произвольного конечного набора predicates.

**Примеры использования:** [031. Specification](031_specification_comparision.md)

## Общий сценарий

Сохранить снимок ссылок callable и построить predicate, который вызывает их по порядку до false; пустой набор истинен.

**Ожидаемое наблюдение:** Для исходных проверок: -1→false,50→true,100→false. После false/отказа последующие predicate не вызываются. Пустой набор истинен при известной сигнатуре.

**Граница сравнения:** Реализация библиотеки. При построении predicate не исполняются; ссылки должны оставаться живыми. Это conjunction, не purity/SQL/новый overload resolver. LMX использует input policy первого predicate либо явного contract.

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

# Arbitrary finite count and arity. A written contract is mandatory only for
# the empty predicate sequence, since there is then no callable to infer from.
# Without it, the first predicate supplies the actual external input policy;
# with it, the chosen contract supplies that policy. All predicates must accept
# the same ordered type signature and return int truth. Forwarded places stay
# lazy; a skipped predicate receives no call and demands no default.
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

Полный factory и engine ядра; оригинальные places передаются лениво, без снимка всех аргументов.

[Отдельный листинг](examples/lmx/095_specification_combinator_implementation.lm3)

## Python

```python
def all_of(predicates):
    checks = tuple(predicates)
    for predicate in checks:
        if not callable(predicate): raise TypeError("predicate must be callable")
    def accepts(*args, **kwargs):
        for predicate in checks:
            if not predicate(*args, **kwargs): return False
        return True
    return accepts
```

Произвольное число predicates и аргументов; пустой набор возвращает True. Исходная коллекция снимается один раз.

[Отдельный листинг](examples/python/095_specification_combinator_implementation.py)

## C#

```csharp
using System;
using System.Collections.Generic;
public static class PredicateSet {
    public static Func<T,bool> AllOf<T>(IEnumerable<Func<T,bool>> predicates) {
        ArgumentNullException.ThrowIfNull(predicates);
        var checks = new List<Func<T,bool>>();
        foreach (var predicate in predicates) {
            ArgumentNullException.ThrowIfNull(predicate);
            checks.Add(predicate);
        }
        return value => {
            foreach (var predicate in checks) if (!predicate(value)) return false;
            return true;
        };
    }
}
```

Любой T, в том числе tuple/product аргументов; пустой список корректен, поскольку T задан статически. Никакого LINQ All внутри реализации.

[Отдельный листинг](examples/csharp/095_specification_combinator_implementation.cs)

## Разбор LMX

Полный factory и engine ядра; оригинальные places передаются лениво, без снимка всех аргументов.

## Сопоставление

LMX сохраняет точную многопозиционную сигнатуру; Python передаёт args/kwargs; C# выражает вход как generic T, при необходимости tuple. Все снимают коллекцию callable один раз и сохраняют short-circuit.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 2056 | 71 |
| Python | 246 | 9 |
| C# | 417 | 16 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Build an ordered short-circuit conjunction over a finite predicate sequence.

**Usage examples:** [031. Specification](031_specification_comparision.md)

**Scenario.** Retain a snapshot of callable references and construct a new predicate. Each invocation evaluates in order until false; an empty set is true.

**Expected observation.** For the two int checks: -1→false,50→true,100→false. Later predicates do not run after false or failure. Empty sets are true under an explicitly known signature.

**LMX.** Complete core factory and engine; original places are forwarded lazily without snapshotting all arguments.

**Comparison.** LMX supports exact multi-position callable signatures; Python forwards args/kwargs; C# carries the input shape as generic T (a tuple when needed). Every implementation copies the callable collection once and preserves short circuit.

**Scope and limitations.** No predicate is executed by construction. Callable references must remain valid. This is conjunction, not static purity analysis, SQL translation, or a new overload resolver. LMX uses the first source input policy unless the caller supplies an explicit contract.

### Dependencies and execution boundaries

- **LMX:** Complete core factory and engine; original places are forwarded lazily without snapshotting all arguments.
- **Python:** Arbitrary predicate and argument counts; an empty collection returns True. The input collection is snapshotted once.
- **C#:** Any T, including an argument tuple/product; empty input is valid because T is statically known. The implementation does not call LINQ All.

## Источники / Sources

- [Python all contract](https://docs.python.org/3/library/functions.html#all) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
