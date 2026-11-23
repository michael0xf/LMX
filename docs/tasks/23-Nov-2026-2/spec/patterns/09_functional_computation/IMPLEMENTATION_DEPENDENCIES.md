# Стоимость общих зависимостей функциональных примеров

Редакция 2026-11-23. Текущие общие тела ядра 091/092/098/099 извлечены непосредственно из [пакета ресиверов](../LMX_Fn_Receivers/README.md). Пример использования не оплачивает библиотеку при каждом обращении; сама библиотека также не объявляется бесплатной.

## Что входит в числа

Первичная таблица сравнения содержит клиент или собственное тело компонента. Эта таблица добавляет транзитивно вызываемые LMX-определения. Каждое определение считается целиком один раз внутри своей строки: Unicode-символы без пробелов и непустые строки; комментарии внутри определения включены. Между строками общие определения пересекаются, поэтому складывать столбец зависимостей без устранения повторов нельзя.

| ID | Основное тело, символы / строки | Общие LMX-зависимости, символы / строки | Сумма внутри компонента | Без сложного Throws: тело + зависимости |
| ---: | ---: | ---: | ---: | ---: |
| 091 | 390 / 27 | 2003 / 160 | 2393 / 187 | 390 + 1124 |
| 092 | 591 / 33 | 1906 / 152 | 2497 / 185 | 565 + 1027 |
| 098 | 316 / 16 | 3893 / 254 | 4209 / 270 | 316 + 2967 |
| 099 | 533 / 17 | 12336 / 646 | 12869 / 663 | 533 + 11270 |
| 085 | 1520 / 56 | 11962 / 634 | 13482 / 690 | 1520 + 10863 |

Все перечисленные реализации, включая companion curry для 085, с устранением повторов: **16334 непробельных символов / 832 непустых строк**. Это исходники выбранного набора определений, не размер бинарника или всего runtime.

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основная цена включает их полностью. Дополнительная колонка оставляет заголовок и первый написанный аргумент списка; copy/ссылка сохраняется целиком, общий банк учитывается один раз с первым аргументом. Это только другой подсчёт, не сокращение исходника или контракта.

Дополнительная цена всего уникального множества без сложного Throws: **15209** символов.

## Публичный набор имён

- [src/public.lmx](../LMX_Fn_Receivers/src/public.lmx): 6165 символов / 219 строк. Общая таблица открывает все публичные имена; её следует считать один раз при загрузке полного набора.

## Интерфейсы ядра и границы обобщения

[KERNEL_REQUIREMENTS](../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [контракты](../LMX_Fn_Receivers/src/kernel_contracts.lmx) описывают требуемое семантическое отражение, построение обычного DATA/CODE, обычную подготовку вызова и выбранных мест без eager capture, время жизни результата и передачу failures. Реализация этих интерфейсов не приложена в виде работающего ядра и не получает фиктивный нулевой размер. Подсчёт выше включает алгоритмы, действительно написанные на LMX; для полного системного сравнения добавляется реализация provider и runtime каждого языка.

Структуры используются непосредственно как Array<@>: префикс partial, actuals, списки и последовательности результатов не требуют отдельного поля items. Плотный Array<T> принимается через фактический typed access; он не переинтерпретируется как вектор указателей. Метки состояния контейнеров, индексы и коды типов закономерно имеют тип int; полезные типы и арность этим не ограничены.

В Haskell и Scala обычные вызовы, lambda, generic-типы и исключения являются инфраструктурой языка; их компиляторы и runtime также не входят в размеры листингов. В 099 все три реализации поддерживают произвольный типизированный префикс N входов, включая k=0,k=N и void/Unit. Haskell использует Args/Callable, Scala — Tuple/Callable. LMX дополнительно сохраняет обычный DATA/defaults/binding существующего callable; эти возможности не объявляются тождественными статическому векторному API.

Сценарий 085 также имеет допустимый короткий вариант curry. Его полные тела и отдельный реестр дополнительных зависимостей приведены в [CURRY_ADAPTER_VARIANT.md](CURRY_ADAPTER_VARIANT.md); они не скрыты внутри цены одного partial.

## Точные определения и ссылки

### 091

Основное тело: `FxMaybe`, `FxSome`, `FxNone`, `FxBind`.

- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1529 символов / 132 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

### 092

Основное тело: `FxBounce`, `FxDone`, `FxMore`, `FxTrampoline`.

- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1529 символов / 132 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

### 098

Основное тело: `FxAround`.

- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 156 символов / 9 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 199 символов / 11 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1529 символов / 132 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 178 символов / 9 строк.

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
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 142 символов / 8 строк.
- `FxEngineState` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 33 символов / 3 строк.
- `FxFailureFilter` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 289 символов / 18 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxFormatInt` — [src/coreStandardText.lmx](../LMX_Fn_Receivers/src/coreStandardText.lmx), 595 символов / 28 строк.
- `FxForwardEngine` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 108 символов / 8 строк.
- `FxFrameApply` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 177 символов / 9 строк.
- `FxFrameAttempt` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 117 символов / 6 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxPrefixPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 314 символов / 13 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 147 символов / 9 строк.
- `FxSameText` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 169 символов / 11 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqBounds` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 228 символов / 13 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqReverse` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 351 символов / 15 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxSeqSlice` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 390 символов / 18 строк.
- `FxSignatures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 233 символов / 11 строк.
- `FxSlice` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 258 символов / 13 строк.
- `FxSourcePolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 1055 символов / 48 строк.
- `FxStageFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 183 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1529 символов / 132 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
- `FxUnitRange` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 219 символов / 14 строк.
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
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 142 символов / 8 строк.
- `FxEngineState` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 33 символов / 3 строк.
- `FxFailureFilter` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 289 символов / 18 строк.
- `FxFailures` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 177 символов / 9 строк.
- `FxFormatInt` — [src/coreStandardText.lmx](../LMX_Fn_Receivers/src/coreStandardText.lmx), 595 символов / 28 строк.
- `FxForwardEngine` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 108 символов / 8 строк.
- `FxFrameApply` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 177 символов / 9 строк.
- `FxFrameAttempt` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 117 символов / 6 строк.
- `FxFrameRead` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 174 символов / 9 строк.
- `FxIndices` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 197 символов / 16 строк.
- `FxInputPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 102 символов / 7 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 231 символов / 14 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxOwnPolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 334 символов / 13 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 147 символов / 9 строк.
- `FxSameText` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 169 символов / 11 строк.
- `FxSeqAllocate` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 288 символов / 16 строк.
- `FxSeqBounds` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 228 символов / 13 строк.
- `FxSeqConcat` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 1047 символов / 47 строк.
- `FxSeqInfo` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 122 символов / 7 строк.
- `FxSeqRead` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 168 символов / 9 строк.
- `FxSeqReverse` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 351 символов / 15 строк.
- `FxSeqSize` — [src/sequences_core.lmx](../LMX_Fn_Receivers/src/sequences_core.lmx), 206 символов / 14 строк.
- `FxSeqSlice` — [src/sequences.lmx](../LMX_Fn_Receivers/src/sequences.lmx), 390 символов / 18 строк.
- `FxSignatures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 233 символов / 11 строк.
- `FxSlice` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 258 символов / 13 строк.
- `FxSourcePolicy` — [src/adapter_frames.lmx](../LMX_Fn_Receivers/src/adapter_frames.lmx), 1055 символов / 48 строк.
- `FxStageFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 183 символов / 11 строк.
- `FxThrows` — [src/failures.lmx](../LMX_Fn_Receivers/src/failures.lmx), 1529 символов / 132 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.
- `FxUnitRange` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 219 символов / 14 строк.
- `FxWrap` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 1001 символов / 25 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxLazyCycle`, `FxRecordArity`, `FxShape`, `FxTypeToken`.

## Воспроизводимость

`python3 tools/sync_receiver_bodies.py` извлекает тела и строит этот реестр; `python3 tools/select_shortest.py` выбирает короткий допустимый алгоритм текущего контракта; `python3 tools/regenerate_publication.py` синхронизирует тексты и показатели. Полный машинный отчёт со SHA-256 каждого определения: [implementation_dependencies.json](implementation_dependencies.json). Ни один из этих инструментов не исполняет LMX.
