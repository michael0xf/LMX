# M01. Serial state updates at one Message owner

## Общий договор

Complete local-owner fixture: one owner, two sender threads submit additions 4 and 9, each accepted request has one serialized update, final read occurs after both responses and returns 13 for either arrival order. The counted Haskell service uses actual Chan/MVar facilities and includes its owner loop and existing Stop acknowledgement branch. counterExample launches/sends/observes/stops it only as an external verification harness and is excluded from this service-to-service count, just as the LMX sender/owner launcher is outside Counter. The LMX fixture relies on the existing Message owner launcher. Neither side of this local comparison is credited with a complete HTTP or distributed-delivery stack; the separate HTTP profile remains outside this ratio.

Сериализованное изменение состояния одного Message-owner — сам договор. Одна запись и вызов общего read являются минимальной формой в обоих стилях.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
Counter:
    int: value 0
    int: delta
    return: int
    add:
        node\value += delta
        return: read()
    read:
        return: node\value
```

[Полный исходник](../../lmx/M01.lm3)

## Haskell

```haskell
import Control.Concurrent (MVar, putMVar)
import Control.Concurrent.Chan (Chan, readChan)

data CounterRequest = AddBy Int (MVar Int) | ReadValue (MVar Int) | Stop (MVar ())

counterLoop :: Chan CounterRequest -> Int -> IO ()
counterLoop inbox value = do
  request <- readChan inbox
  case request of
    AddBy delta reply -> do
      let next = value + delta
      next `seq` putMVar reply next
      counterLoop inbox next
    ReadValue reply -> do
      putMVar reply value
      counterLoop inbox value
    Stop ack -> putMVar ack ()
```

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **93** | 9 |
| LMX — функциональный | **93** | 9 |
| Haskell | 411 | 15 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
