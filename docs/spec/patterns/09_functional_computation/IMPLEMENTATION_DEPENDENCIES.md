# Стоимость общих зависимостей функциональных примеров

Редакция 2026-11-22. Текущие общие тела ядра 091/092/098/099 извлечены непосредственно из [пакета ресиверов](../LMX_Fn_Receivers/README.md). Пример использования не оплачивает библиотеку при каждом обращении; сама библиотека также не объявляется бесплатной.

## Что входит в числа

Первичная таблица сравнения содержит клиент или собственное тело компонента. Эта таблица добавляет транзитивно вызываемые LMX-определения. Каждое определение считается целиком один раз внутри своей строки: Unicode-символы без пробелов и непустые строки; комментарии внутри определения включены. Между строками общие определения пересекаются, поэтому складывать столбец зависимостей без устранения повторов нельзя.

| ID | Основное тело, символы / строки | Общие LMX-зависимости, символы / строки | Сумма внутри компонента |
| ---: | ---: | ---: | ---: |
| 091 | 411 / 30 | 499 / 33 | 910 / 63 |
| 092 | 611 / 39 | 402 / 25 | 1013 / 64 |
| 098 | 374 / 20 | 739 / 51 | 1113 / 71 |
| 099 | 605 / 24 | 4270 / 241 | 4875 / 265 |

Все четыре реализации вместе с устранением повторов: **7010 непробельных символов / 405 непустых строк**. Это исходники выбранного набора определений, не размер бинарника или всего runtime.

## Публичный набор имён

- [src/public.lmx](../LMX_Fn_Receivers/src/public.lmx): 1751 символов / 68 строк. Общая таблица открывает все публичные имена; её следует считать один раз при загрузке полного набора.

## Интерфейсы ядра и границы обобщения

[KERNEL_REQUIREMENTS](../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [контракты](../LMX_Fn_Receivers/src/kernel_contracts.lmx) описывают требуемое семантическое отражение, построение обычного DATA/CODE, вызов через вектор типизированных записей, время жизни результата и передачу failures. Реализация этих интерфейсов не приложена в виде работающего ядра и не получает фиктивный нулевой размер. Подсчёт выше включает алгоритмы, действительно написанные на LMX; для полного системного сравнения добавляется реализация provider и runtime каждого языка.

Структуры используются непосредственно как Array<@>: префикс partial, actuals, списки и последовательности результатов не требуют отдельного поля items. Плотный Array<T> остаётся самостоятельным значением, не переинтерпретируется как вектор указателей. Метки состояния контейнеров, индексы и коды типов закономерно имеют тип int; полезные типы и арность этим не ограничены.

В Haskell и Scala обычные вызовы, lambda, generic-типы и исключения являются инфраструктурой языка; их компиляторы и runtime также не входят в размеры листингов. У 099 общий проверяемый случай — A×B→R с привязкой первого аргумента. LMX реализует более широкий произвольный префикс N входов, включая k=0,k=N и void; один итоговый коэффициент «выигрыша» для этих неодинаковых возможностей не строится.

## Точные определения и ссылки

### 091

Основное тело: `FxMaybe`, `FxSome`, `FxNone`, `FxBind`.

- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 219 символов / 14 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 183 символов / 11 строк.

Внешние интерфейсы и имена failures: `FxCallFailure`, `FxKernel`, `FxKernelFailure`, `FxTypeToken`.

### 092

Основное тело: `FxBounce`, `FxDone`, `FxMore`, `FxTrampoline`.

- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 219 символов / 14 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 183 символов / 11 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxCallFailure`, `FxKernel`, `FxKernelFailure`, `FxTypeToken`.

### 098

Основное тело: `FxAround`.

- `FxAppend` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 240 символов / 18 строк.
- `FxApply` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 219 символов / 14 строк.
- `FxOne` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 97 символов / 8 строк.
- `FxTry` — [src/generic_runtime.lmx](../LMX_Fn_Receivers/src/generic_runtime.lmx), 183 символов / 11 строк.

Внешние интерфейсы и имена failures: `FxCallFailure`, `FxKernel`, `FxKernelFailure`, `FxTypeToken`.

### 099

Основное тело: `FxPartial`.

- `FxBuild` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 267 символов / 14 строк.
- `FxCallState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 78 символов / 7 строк.
- `FxCaptureFailures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 105 символов / 7 строк.
- `FxCaptureOne` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 709 символов / 23 строк.
- `FxCapturePrefix` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 347 символов / 21 строк.
- `FxCaptureState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 24 символов / 2 строк.
- `FxConcat` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 254 символов / 19 строк.
- `FxDecimal` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 395 символов / 27 строк.
- `FxLabels` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 214 символов / 15 строк.
- `FxNewState` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 305 символов / 18 строк.
- `FxRecordOperands` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 147 символов / 10 строк.
- `FxSignatures` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 242 символов / 14 строк.
- `FxSlice` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 278 символов / 20 строк.
- `FxTargetCallText` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 875 символов / 41 строк.
- `FxTypeTokens` — [src/generic_functions.lmx](../LMX_Fn_Receivers/src/generic_functions.lmx), 30 символов / 3 строк.

Внешние интерфейсы и имена failures: `FxArity`, `FxIndex`, `FxKernel`, `FxKernelFailure`, `FxRecordArity`, `FxTypeToken`.

## Воспроизводимость

`python3 tools/sync_receiver_bodies.py` извлекает тела и строит этот реестр; `python3 tools/select_shortest.py` выбирает короткий допустимый алгоритм текущего контракта; `python3 tools/regenerate_publication.py` синхронизирует тексты и показатели. Полный машинный отчёт со SHA-256 каждого определения: [implementation_dependencies.json](implementation_dependencies.json). Ни один из этих инструментов не исполняет LMX.
