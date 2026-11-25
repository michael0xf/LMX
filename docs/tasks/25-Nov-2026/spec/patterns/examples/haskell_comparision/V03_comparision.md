# V03. Inject a read dependency and check interaction counts

## Общий договор

Checker принимает произвольный кандидат, внедряет read, проверяет результат 28 и ровно одно чтение. Good: True/1, biased: False/1, readsTwice: False/2.

**Сопоставимость: полная пара.** В отличие от прежнего закрытого SampleVariant, checker получает функцию Candidate. Общая sample используется вариантами biased и readsTwice, повторный read действительно выполняется. Haskell передаёт gain и read явно; LMX связывает их через текущий контекст. Наблюдаемый договор checker и три отрицательных/положительных случая совпадают.

## LMX — процедурный

```lmx
Measurement:
    int: gain
    @: read
    return: int
    sample:
        return: read() * gain
    biased:
        return: sample() + 1
    readsTwice:
        int: discarded read()
        return: sample()

SamplingCheck:
    @: candidate
    int: calls 0
    return: int
    fixedRead:
        node\calls += 1
        return: 7
    check:
        node\calls := 0
        @: read fixedRead
        int: result candidate(gain := 4)
        if: result != 28
            return: 0
        return: node\calls = 1
```

[Полный исходник](source/lmx/procedural/V03.lm3)
## LMX — функциональный

```lmx
Measurement:
    int: gain
    @: read
    return: int
    sample:
        return: read() * gain
    biased:
        return: sample() + 1
    readsTwice:
        int: discarded read()
        return: sample()

SamplingCheck:
    @: candidate
    int: calls 0
    return: int
    fixedRead:
        node\calls += 1
        return: 7
    check:
        node\calls := 0
        @: read fixedRead
        int: result candidate(gain := 4)
        return: result = 28 && node\calls = 1
```

[Полный исходник](source/lmx/V03.lm3)

## Haskell

```haskell
module V03 where

import Data.IORef (newIORef, readIORef, modifyIORef')

type Candidate = Int -> IO Int -> IO Int

sample, biased, readsTwice :: Candidate
sample gain readSample = (*gain) <$> readSample
biased gain readSample = (+1) <$> sample gain readSample
readsTwice gain readSample = readSample >> sample gain readSample

check :: Candidate -> IO (Bool, Int)
check candidate = do
  calls <- newIORef 0
  let fixedRead = modifyIORef' calls (+1) >> pure 7
  result <- candidate 4 fixedRead
  count <- readIORef calls
  pure (result == 28 && count == 1, count)
```

[Полный исходник](source/haskell/V03.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Checker принимает произвольный кандидат, внедряет read, проверяет результат 28 и ровно одно чтение. Good: True/1, biased: False/1, readsTwice: False/2. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 308 | 25 |
| LMX — функциональный | <span style="color:#176233"><u>298</u></span> | 23 |
| Haskell | 459 | 14 |

