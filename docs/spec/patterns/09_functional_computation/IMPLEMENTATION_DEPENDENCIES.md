# Стоимость общих зависимостей функциональных примеров

Редакция 2026-11-22. Текущие общие тела ядра 091/092/098/099 извлечены непосредственно из [пакета ресиверов](../LMX_Fn_Receivers/README.md). Пример использования не оплачивает библиотеку при каждом обращении; сама библиотека также не объявляется бесплатной.

## Что входит в числа

Первичная таблица сравнения содержит клиент или собственное тело компонента. Эта таблица добавляет транзитивно вызываемые LMX-определения. Каждое определение считается целиком один раз внутри своей строки: Unicode-символы без пробелов и непустые строки; комментарии внутри определения включены. Между строками общие определения пересекаются, поэтому складывать столбец зависимостей без устранения повторов нельзя.

| ID | Основное тело, символы / строки | Общие LMX-зависимости, символы / строки | Сумма внутри компонента |
| ---: | ---: | ---: | ---: |
| 091 | 390 / 27 | 1975 / 157 | 2365 / 184 |
| 092 | 591 / 33 | 1878 / 149 | 2469 / 182 |
| 098 | 359 / 17 | 3967 / 259 | 4326 / 276 |
| 099 | 533 / 17 | 11407 / 607 | 11940 / 624 |
| 085 | 1520 / 56 | 11033 / 595 | 12553 / 651 |

Все перечисленные реализации, включая companion curry для 085, с устранением повторов: **15453 непробельных символов / 794 непустых строк**. Это исходники выбранного набора определений, не размер бинарника или всего runtime.

## Публичный набор имён

- [src/public.lmx](../LMX_Fn_Receivers/src/public.lmx): 3292 символов / 122 строк. Общая таблица открывает все публичные имена; её следует считать один раз при загрузке полного набора.

## Интерфейсы ядра и границы обобщения

[KERNEL_REQUIREMENTS](../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [контракты](../LMX_Fn_Receivers/src/kernel_contracts.lmx) описывают требуемое семантическое отражение, построение обычного DATA/CODE, обычную подготовку вызова и выбранных мест без eager capture, время жизни результата и передачу failures. Реализация этих интерфейсов не приложена в виде работающего ядра и не получает фиктивный нулевой размер. Подсчёт выше включает алгоритмы, действительно написанные на LMX; для полного системного сравнения добавляется реализация provider и runtime каждого языка.

Структуры используются непосредственно как Array<@>: префикс partial, actuals, списки и последовательности результатов не требуют отдельного поля items. Плотный Array<T> принимается через фактический typed access; он не переинтерпретируется как вектор указателей. Метки состояния контейнеров, индексы и коды типов закономерно имеют тип int; полезные типы и арность этим не ограничены.

В Haskell и Scala обычные вызовы, lambda, generic-типы и исключения являются инфраструктурой языка; их компиляторы и runtime также не входят в размеры листингов. У 099 общий проверяемый случай — A×B→R с привязкой первого аргумента. LMX реализует более широкий произвольный префикс N входов, включая k=0,k=N и void; один итоговый коэффициент «выигрыша» для этих неодинаковых возможностей не строится.

Сценарий 085 также имеет допустимый короткий вариант curry. Его полные тела и отдельный реестр дополнительных зависимостей приведены в [CURRY_ADAPTER_VARIANT.md](CURRY_ADAPTER_VARIANT.md); они не скрыты внутри цены одного partial.

## Точные определения и ссылки

### 091

Основное тело: `FxMaybe`, `FxSome`, `FxNone`, `FxBind`.

- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1496 символов / 129 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 183 символов / 9 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

### 092

Основное тело: `FxBounce`, `FxDone`, `FxMore`, `FxTrampoline`.

- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1496 символов / 129 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 183 символов / 9 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

### 098

Основное тело: `FxAround`.

- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 127 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1496 символов / 129 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 183 символов / 9 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

### 099

Основное тело: `FxPartial`.

- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxBuild` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 389 символов / 16 строк.
- `FxCaptureFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 105 символов / 7 строк.
- `FxCaptureOne` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 734 символов / 19 строк.
- `FxCapturePrefix` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 331 символов / 16 строк.
- `FxCaptureState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 24 символов / 2 строк.
- `FxConcat` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 157 символов / 9 строк.
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 394 символов / 26 строк.
- `FxEngineState` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 33 символов / 3 строк.
- `FxFailureFilter` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 289 символов / 18 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxForwardEngine` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 108 символов / 8 строк.
- `FxFrameApply` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 177 символов / 9 строк.
- `FxFrameAttempt` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 122 символов / 6 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxPrefixPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 314 символов / 13 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 147 символов / 9 строк.
- `FxSameText` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 176 символов / 14 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqBounds` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 228 символов / 13 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 127 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxSeqSlice` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 390 символов / 18 строк.
- `FxSignatures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 233 символов / 11 строк.
- `FxSlice` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 258 символов / 13 строк.
- `FxSourcePolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 1055 символов / 48 строк.
- `FxStageFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 183 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1496 символов / 129 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
- `FxWrap` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 1001 символов / 25 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

### 085

Основное тело: `FxCurryState`, `FxLambdaMiddleEngine`, `FxLambdaStages`, `FxLambda`.

- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxBuild` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 389 символов / 16 строк.
- `FxCaptureFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 105 символов / 7 строк.
- `FxCaptureOne` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 734 символов / 19 строк.
- `FxCaptureState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 24 символов / 2 строк.
- `FxConcat` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 157 символов / 9 строк.
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 394 символов / 26 строк.
- `FxEngineState` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 33 символов / 3 строк.
- `FxFailureFilter` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 289 символов / 18 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxForwardEngine` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 108 символов / 8 строк.
- `FxFrameApply` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 177 символов / 9 строк.
- `FxFrameAttempt` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 122 символов / 6 строк.
- `FxFrameRead` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 174 символов / 9 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 147 символов / 9 строк.
- `FxSameText` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 176 символов / 14 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqBounds` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 228 символов / 13 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 127 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxSeqSlice` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 390 символов / 18 строк.
- `FxSignatures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 233 символов / 11 строк.
- `FxSlice` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 258 символов / 13 строк.
- `FxSourcePolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 1055 символов / 48 строк.
- `FxStageFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 183 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1496 символов / 129 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
- `FxWrap` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 1001 символов / 25 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

## Воспроизводимость

`python3 tools/sync_receiver_bodies.py` извлекает тела и строит этот реестр; `python3 tools/select_shortest.py` выбирает короткий допустимый алгоритм текущего контракта; `python3 tools/regenerate_publication.py` синхронизирует тексты и показатели. Полный машинный отчёт со SHA-256 каждого определения: [implementation_dependencies.json](implementation_dependencies.json). Ни один из этих инструментов не исполняет LMX.
