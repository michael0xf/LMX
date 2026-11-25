# M01. Serial state updates at one Message owner

## Общий договор

Один владелец последовательно принимает два запроса +4 и +9 от разных отправителей. После обоих ответов чтение даёт 13 при любом порядке поступления.

**Сопоставимость: полная пара.** Chan и MVar — реальные средства base. В сравниваемом модуле целиком показан service loop, включая завершение; запуск потоков и проверка ответов находятся в одинаково исключённом из размера внешнем harness. Проверяются оба допустимых набора промежуточных ответов. HTTP и распределённая доставка не входят в эту локальную пару.

## LMX — общая минимальная форма обоих стилей

Сериализованное изменение состояния одного Message-owner — сам договор. Одна запись и вызов общего read являются минимальной формой в обоих стилях.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

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

[Полный исходник](source/lmx/M01.lm3)

## Haskell

```haskell
module M01 where

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
    ReadValue reply -> putMVar reply value >> counterLoop inbox value
    Stop ack -> putMVar ack ()
```

[Полный исходник](source/haskell/M01.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Один владелец последовательно принимает два запроса +4 и +9 от разных отправителей. После обоих ответов чтение даёт 13 при любом порядке поступления. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Control.Concurrent.Chan](https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/Control-Concurrent-Chan.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | <span style="color:#176233"><u>93</u></span> | 9 |
| LMX — функциональный | <span style="color:#176233"><u>93</u></span> | 9 |
| Haskell | 425 | 14 |
