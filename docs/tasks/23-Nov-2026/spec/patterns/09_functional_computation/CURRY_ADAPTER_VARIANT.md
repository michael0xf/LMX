# Curry: дополнительный общий механизм рядом с примером 085

Это исходники того же текущего ядра, а не ещё одна версия библиотеки. Клиент 085 выбирает две независимые ветви одного `curry(Addition\apply)` вместо двух `partial`; корректный partial-вариант сохранён рядом как другой способ построить callable.

## Сценарий и граница сравнения

Сохраняются add5, add100, переменная saved=1000, повторный вызов add5 и весь результат 6101006. Только способ построения двух closures заменён на общий поэтапный adapter. Haskell использует собственное каррированное применение, Scala — Function2.curried. Самописные generic-компоненты 099 показаны отдельно и не импортируются в этих клиентах; дополнительная универсальность LMX не объявляется тождественной по реализации.

| Допустимый LMX-клиент | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| [core_curry](examples/lmx/085_currying.lm3) | 292 | 23 |
| [core](examples/lmx/variants/085_currying_core.lm3) | 308 | 22 |

## Полные дополнительные тела

Общие policy, builder, capture и runtime уже приведены в [реестре](IMPLEMENTATION_DEPENDENCIES.md) и [пакете ресиверов](../LMX_Fn_Receivers/ADAPTER_IMPLEMENTATION.md). Ниже показаны все собственные тела curry. Они извлекаются непосредственно из действующего source, а не сокращаются до необъяснённого native вызова.

### FxCurryState

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx).

```lmx
FxCurryState:
    @: target 0
    @: info 0
    @: prefix 0
    @: stageBuilder 0
```

### FxLambdaMiddleEngine

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx).

```lmx
FxLambdaMiddleEngine:
    private:
        @: state
        @: frame
    return: @
    run:
        throws: copy(FxThrows\retry)
        private: int: k length(state\prefix)
        private: @: value FxFrameRead\read(frame; 0)
        private: @: captured FxCaptureOne\capture(state\info\inputTypes[k]; value)
        private: @: next FxAppend\append(state\prefix; FxOne\make(captured))
        return: state\stageBuilder(operation := state\target; info := state\info; prefix := next)
```

### FxLambdaStages

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx).

```lmx
FxLambdaStages:
    private:
        @: operation
        @: info
        @: prefix
    return: @
    build:
        throws: copy(FxThrows\adapter)
        private: @: inputs info\inputTypes
        private: int: n length(inputs)
        private: int: k length(prefix)
        if: k > n
            throw: FxArity()
        private: int: count 0
        if: k < n
            count := 1
        private: @: ownInputs FxSlice\slice(inputs; k; count)
        private: @: ownResult info\resultType
        private: @: engine FxForwardEngine\run
        private: @: failures info\throws
        if: k + 1 < n
            ownResult := FxKernel\normalizeType(token := FxTypeTokens\reference[0])
            engine := FxLambdaMiddleEngine\run
            failures := FxFailures\union(failures; FxStageFailures\names())
        private: @: contract FxSignatures\make(ownInputs; ownResult)
        private: @: state (copy(FxCurryState))
        state\target := operation
        state\info := info
        state\prefix := prefix
        state\stageBuilder := FxLambdaStages\build
        private: @: policy FxSourcePolicy\make(operation; FxIndices\make(k; count); FxIndices\make(0; k); prefix; FxIndices\make(k + count; n - k - count))
        return: FxWrap\make(contract; engine; state; failures; policy)
```

### FxLambda

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx).

```lmx
FxLambda:
    private: @: operation
    return: @
    lambda:
        throws: copy(FxThrows\adapter)
        private: @: info FxKernel\signature(subject := operation)
        return: FxLambdaStages\build(operation; info; (copy(())))
```

## Стоимость общих зависимостей

Полное транзитивное множество curry: **12576** непробельных символов / **654** непустых строк. Дополнительно к уже раскрытому closure partial из строки 099: **1791** символов / **73** строк. Эти числа не следует прибавлять к клиенту при каждом вызове: это стоимость общей реализации один раз. Интерфейсы FxKernel и реальный runtime остаются отдельной известной границей, а не имеют выдуманную нулевую стоимость.

| Дополнительное определение | Источник | Символы | Строки |
| --- | --- | ---: | ---: |
| `FxCurryState` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 53 | 5 |
| `FxFrameRead` | [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx) | 174 | 9 |
| `FxLambda` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 178 | 7 |
| `FxLambdaMiddleEngine` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 369 | 12 |
| `FxLambdaStages` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 920 | 32 |
| `FxOne` | [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx) | 97 | 8 |

## Проверка

Ни один LMX runtime здесь не запускался. Источник требует пяти обычных call-phase hooks, указанных в KERNEL_REQUIREMENTS, и полного A/B acceptance. Счётчики символов — воспроизводимая проверка публикации, не проверка семантики или скорости. Машинный реестр: [curry_dependencies.json](curry_dependencies.json). Для обновления после source changes: `python3 tools/curry_appendix.py`.
