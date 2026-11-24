# Curry: общая реализация функционального клиента085
Процедурный клиент полностью показывает сохранённые окружения; функциональный строит две независимые ветви общего curry. Оба клиента считаются полностью и сравниваются с короткими Haskell/Scala программами того же договора. Одно ядро обслуживает функциональную форму; второй реализации curry ради стиля нет.
## Полные клиенты
| Стиль | Символы | Строки |
| --- | ---: | ---: |
| [procedural](examples/lmx/procedural/085_currying.lm3) | 493 | 31 |
| [functional](examples/lmx/085_currying.lm3) | 205 | 13 |

Все объявления и Throws входят в размер. В функциональной форме add5 сохраняется для двух вызовов, а одноразовая ветвь записана add(100)(1). Неиспользуемый saved удалён из функционального LMX и контрольных Haskell/Scala. Процедурная форма сохраняет свой saved как явную проверку независимости захваченного окружения. Ожидаемый результат обеих форм — 6101006.

Дополнительный [вариант с partial](examples/lmx/variants/085_currying_core.lm3) сохранён отдельно. Он не заменяет ни одну из двух сравниваемых форм и не входит в их размеры.

## Полные общие тела
Общие policy, builder, capture и runtime указаны в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Ниже извлечены точные тела того же ядра.

### FxCurryState

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx)

```lmx
FxCurryState:
    @: target 0
    @: info 0
    @: prefix 0
    @: stageBuilder 0
```

### FxLambdaMiddleEngine

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx)

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

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx)

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

[Источник](../LMX_Fn_Receivers/src/generic_functions.lmx)

```lmx
FxLambda:
    private: @: operation
    return: @
    lambda:
        throws: copy(FxThrows\adapter)
        private: @: info FxKernel\signature(subject := operation)
        return: FxLambdaStages\build(operation; info; (copy(())))
```

## Полная стоимость зависимостей

Уникальное транзитивное множество curry: **16906** символов. Дополнительно к partial из099: **1694** символов. Общие определения считаются один раз; стоимость native FxKernel и runtime не объявляется нулевой.

| Дополнительное определение | Источник | Символы | Строки |
| --- | --- | ---: | ---: |
| `FxCurryState` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 53 | 5 |
| `FxFrameRead` | [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx) | 174 | 9 |
| `FxLambda` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 178 | 7 |
| `FxLambdaMiddleEngine` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 369 | 12 |
| `FxLambdaStages` | [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx) | 920 | 32 |

## Проверка

Это проверка наличия исходников и их полного размера. Runtime LMX: NOT_RUN. [Машинный реестр](curry_dependencies.json).
