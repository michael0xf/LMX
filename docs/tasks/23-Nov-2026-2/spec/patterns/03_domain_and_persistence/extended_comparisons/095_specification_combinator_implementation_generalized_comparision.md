# 095. AllOf — predicate conjunction implementation: отдельный расширенный договор

Сохранена самостоятельная обобщённая реализация 23-Nov. Она решает более широкую задачу, чем восстановленная основная пара 22-Nov, и не участвует в её сумме или выборе кратчайшего листинга.

## Договор

Сохранить снимок ссылок callable и построить predicate, который вызывает их по порядку до false; пустой набор истинен.

Для исходных проверок: -1→false,50→true,100→false. После false/отказа последующие predicate не вызываются. Пустой набор истинен при известной сигнатуре.

При построении predicate не исполняются; ссылки должны оставаться живыми. Это conjunction, не purity/SQL/новый overload resolver. LMX использует input policy первого predicate либо явного contract.

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

[Исходник](source/lmx/095_specification_combinator_implementation_generalized.lm3)

Полный factory и engine ядра; оригинальные places передаются лениво, без снимка всех аргументов.

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

[Исходник](source/python/095_specification_combinator_implementation_generalized.py)

Произвольное число predicates и аргументов; пустой набор возвращает True. Исходная коллекция снимается один раз.

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

[Исходник](source/csharp/095_specification_combinator_implementation_generalized.cs)

Любой T, в том числе tuple/product аргументов; пустой список корректен, поскольку T задан статически. Никакого LINQ All внутри реализации.

## Измерение отдельной реализации

| Язык | Непробельные символы |
| --- | ---: |
| LMX | 2056 |
| Python | 246 |
| C# | 417 |

[Основная узкая пара](../095_specification_combinator_implementation_comparision.md). [Норма LMX](../../../LMX_semantics.en.md).

LMX здесь не выполнялся. Это сохранение исходников и их договора, а не новый отчёт о runtime-проверке.
