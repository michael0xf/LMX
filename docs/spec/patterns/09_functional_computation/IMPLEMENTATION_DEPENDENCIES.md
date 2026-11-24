# Полная стоимость общих зависимостей функциональных примеров
Клиенты082–085 имеют две стилевые записи. Каждая общая реализация091/092/098/099 сохраняет одно точное LMX-тело. Здесь подсчитаны полные транзитивные определения ядра; объявления и Throws не исключаются.
| ID | Основное тело | Общие зависимости | Полная сумма компонента |
| --- | ---: | ---: | ---: |
| 091 | 444 | 9187 | 9631 |
| 092 | 613 | 8493 | 9106 |
| 098 | 316 | 4070 | 4386 |
| 099 | 533 | 15857 | 16390 |
| 085 | 1520 | 15386 | 16906 |

Все уникальные необходимые определения: **20151** символов / **1025** непустых строк. Между компонентами зависимости пересекаются: их нельзя повторно суммировать как разные реализации.

## Публичная публикация

- [src/public.lmx](../LMX_Fn_Receivers/src/public.lmx): 5951 символов. Общая таблица экспортов считается один раз.

## Реальная граница ядра

[KERNEL_REQUIREMENTS](../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [контракты](../LMX_Fn_Receivers/src/kernel_contracts.lmx) описывают отражение сигнатур, построение обычного DATA/CODE, подготовку вызова и выбранных мест без eager capture, lifetime результата и передачу failures. Native реализация этих мостов не объявляется работающей или бесплатной.
Структуры используются непосредственно как последовательности ссылок на фактические типизированные записи. Плотный Array<T> читается через настоящий typed access и не переинтерпретируется как массив указателей. Служебные int для индексов/длин/флагов не ограничивают тип полезных данных.
В099 все реализации поддерживают произвольный типизированный префикс, включая пустой/полный и void/Unit. Haskell использует Args/Callable, Scala — Tuple/Callable. LMX дополнительно сохраняет DATA/defaults и действующий binding-контекст; полная эквивалентность разных систем типов не заявляется.
Функциональный клиент085 использует curry. [Его дополнительные тела](CURRY_ADAPTER_VARIANT.md) и зависимости явно подсчитаны один раз; процедурный клиент полностью показывает собственное окружение.

## Точные источники

### 091
- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxBind` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 231 символов / 13 строк.
- `FxBindChain` — [src/monadic_forms.lmx](../LMX_Fn_Receivers/src/monadic_forms.lmx), 300 символов / 19 строк.
- `FxBindOperandTail` — [src/monadic_forms.lmx](../LMX_Fn_Receivers/src/monadic_forms.lmx), 110 символов / 5 строк.
- `FxBuild` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 389 символов / 16 строк.
- `FxCaptureFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 105 символов / 7 строк.
- `FxCaptureOne` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 193 символов / 9 строк.
- `FxConcat` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 157 символов / 9 строк.
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 136 символов / 8 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxFormat` — [src/coreStandardText.lmx](../LMX_Fn_Receivers/src/coreStandardText.lmx), 589 символов / 28 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxMaybe` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 28 символов / 3 строк.
- `FxMaybeActive` — [src/monadic_forms.lmx](../LMX_Fn_Receivers/src/monadic_forms.lmx), 87 символов / 6 строк.
- `FxMaybeBindOperand` — [src/monadic_forms.lmx](../LMX_Fn_Receivers/src/monadic_forms.lmx), 197 символов / 8 строк.
- `FxNone` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 49 символов / 4 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxPreparedOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 68 символов / 5 строк.
- `FxRecordAdapter` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 987 символов / 33 строк.
- `FxRecordAdapterState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 62 символов / 3 строк.
- `FxRecordConstructor` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 39 символов / 1 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 179 символов / 10 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqReverse` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 351 символов / 15 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxSome` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 136 символов / 9 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1706 символов / 147 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
Внешние границы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.
### 092
- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxBounce` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 33 символов / 4 строк.
- `FxBuild` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 389 символов / 16 строк.
- `FxCaptureFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 105 символов / 7 строк.
- `FxCaptureOne` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 193 символов / 9 строк.
- `FxConcat` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 157 символов / 9 строк.
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 136 символов / 8 строк.
- `FxDone` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 135 символов / 9 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxFormat` — [src/coreStandardText.lmx](../LMX_Fn_Receivers/src/coreStandardText.lmx), 589 символов / 28 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxMore` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 232 символов / 11 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxPreparedOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 68 символов / 5 строк.
- `FxRecordAdapter` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 987 символов / 33 строк.
- `FxRecordAdapterState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 62 символов / 3 строк.
- `FxRecordConstructor` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 39 символов / 1 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 179 символов / 10 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqReverse` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 351 символов / 15 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1706 символов / 147 строк.
- `FxTrampoline` — [src/containers.lmx](../LMX_Fn_Receivers/src/containers.lmx), 213 символов / 10 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
Внешние границы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.
### 098
- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxAround` — [src/generic_wrappers.lmx](../LMX_Fn_Receivers/src/generic_wrappers.lmx), 316 символов / 16 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1706 символов / 147 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.
Внешние границы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.
### 099
- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxBooleanToken` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 24 символов / 2 строк.
- `FxBuild` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 389 символов / 16 строк.
- `FxCaptureFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 105 символов / 7 строк.
- `FxCaptureOne` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 193 символов / 9 строк.
- `FxCapturePrefix` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 331 символов / 16 строк.
- `FxConcat` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 157 символов / 9 строк.
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 136 символов / 8 строк.
- `FxEngineState` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 33 символов / 3 строк.
- `FxEqualFields` — [src/coreComparisonGroups.lmx](../LMX_Fn_Receivers/src/coreComparisonGroups.lmx), 293 символов / 19 строк.
- `FxEqualityTypes` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 30 символов / 3 строк.
- `FxFailureFilter` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 299 символов / 18 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxFormat` — [src/coreStandardText.lmx](../LMX_Fn_Receivers/src/coreStandardText.lmx), 589 символов / 28 строк.
- `FxForwardEngine` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 108 символов / 8 строк.
- `FxFrameApply` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 177 символов / 9 строк.
- `FxFrameAttempt` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 117 символов / 6 строк.
- `FxFullPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 239 символов / 8 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxPartial` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 533 символов / 17 строк.
- `FxPredicate` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 425 символов / 11 строк.
- `FxPredicateEngine` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 191 символов / 10 строк.
- `FxPredicateState` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 29 символов / 2 строк.
- `FxPrefixPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 314 символов / 13 строк.
- `FxPreparedOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 68 символов / 5 строк.
- `FxRecordAdapter` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 987 символов / 33 строк.
- `FxRecordAdapterState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 62 символов / 3 строк.
- `FxRecordConstructor` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 39 символов / 1 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 179 символов / 10 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqBounds` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 228 символов / 13 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqPredicate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 193 символов / 11 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqReverse` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 351 символов / 15 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxSeqSlice` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 390 символов / 18 строк.
- `FxSequenceDifference` — [src/coreStandardLisp.lmx](../LMX_Fn_Receivers/src/coreStandardLisp.lmx), 574 символов / 30 строк.
- `FxSignatures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 233 символов / 11 строк.
- `FxSlice` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 258 символов / 13 строк.
- `FxSourcePolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 1055 символов / 48 строк.
- `FxStageFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 183 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1706 символов / 147 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.
- `FxTwo` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 119 символов / 11 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
- `FxValueSame` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 520 символов / 24 строк.
- `FxWrap` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 1001 символов / 25 строк.
Внешние границы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.
### 085
- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxBooleanToken` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 24 символов / 2 строк.
- `FxBuild` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 389 символов / 16 строк.
- `FxCaptureFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 105 символов / 7 строк.
- `FxCaptureOne` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 193 символов / 9 строк.
- `FxConcat` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 157 символов / 9 строк.
- `FxCurryState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 53 символов / 5 строк.
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 136 символов / 8 строк.
- `FxEngineState` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 33 символов / 3 строк.
- `FxEqualFields` — [src/coreComparisonGroups.lmx](../LMX_Fn_Receivers/src/coreComparisonGroups.lmx), 293 символов / 19 строк.
- `FxEqualityTypes` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 30 символов / 3 строк.
- `FxFailureFilter` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 299 символов / 18 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxFormat` — [src/coreStandardText.lmx](../LMX_Fn_Receivers/src/coreStandardText.lmx), 589 символов / 28 строк.
- `FxForwardEngine` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 108 символов / 8 строк.
- `FxFrameApply` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 177 символов / 9 строк.
- `FxFrameAttempt` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 117 символов / 6 строк.
- `FxFrameRead` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 174 символов / 9 строк.
- `FxFullPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 239 символов / 8 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxLambda` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 178 символов / 7 строк.
- `FxLambdaMiddleEngine` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 369 символов / 12 строк.
- `FxLambdaStages` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 920 символов / 32 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxPredicate` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 425 символов / 11 строк.
- `FxPredicateEngine` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 191 символов / 10 строк.
- `FxPredicateState` — [src/generic_combinators.lmx](../LMX_Fn_Receivers/src/generic_combinators.lmx), 29 символов / 2 строк.
- `FxPreparedOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 68 символов / 5 строк.
- `FxRecordAdapter` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 987 символов / 33 строк.
- `FxRecordAdapterState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 62 символов / 3 строк.
- `FxRecordConstructor` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 39 символов / 1 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 179 символов / 10 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqBounds` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 228 символов / 13 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqPredicate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 193 символов / 11 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqReverse` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 351 символов / 15 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxSeqSlice` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 390 символов / 18 строк.
- `FxSequenceDifference` — [src/coreStandardLisp.lmx](../LMX_Fn_Receivers/src/coreStandardLisp.lmx), 574 символов / 30 строк.
- `FxSignatures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 233 символов / 11 строк.
- `FxSlice` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 258 символов / 13 строк.
- `FxSourcePolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 1055 символов / 48 строк.
- `FxStageFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 183 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1706 символов / 147 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.
- `FxTwo` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 119 символов / 11 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
- `FxValueSame` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 520 символов / 24 строк.
- `FxWrap` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 1001 символов / 25 строк.
Внешние границы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

## Воспроизведение

`python3 tools/sync_receiver_bodies.py` извлекает точные тела; `select_shortest.py` сохраняет обе клиентские формы, `regenerate_publication.py` обновляет публикацию. [Машинный реестр](implementation_dependencies.json). LMX runtime: NOT_RUN.
