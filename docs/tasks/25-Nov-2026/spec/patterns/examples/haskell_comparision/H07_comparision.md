# H07. Prepared value versus raw source occurrence

## Общий договор

Два prepared-вызова дают 2 и 4 при двух вычислениях источника; два raw-вызова дают 3 и 7 при четырёх вычислениях.

**Сопоставимость: аналогия.** Реальная Haskell-реализация отдельно разделяет полученное значение и повторяет IO-действие. Она не принимает произвольное исходное вхождение программы и не исполняет сохранённый граф через sys\eval. Ленивость Haskell сама по себе не объявляется заменой PASS_ARGS_AS_IS.

## LMX — общая минимальная форма обоих стилей

Это проверка prepared/raw ролей и повторного вычисления исходного occurrence. Замена сохраняемого узла на lambda или заранее вычисленное значение изменила бы договор, поэтому минимальная запись общая.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
PreparedOps:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    twice:
        return: \left + \left

RawOps:
    merge: sys\OPERANDS_TEMPLATE (const: int: PASS_ARGS_AS_IS 1)
    return: int
    twice:
        return: sys\eval(left) + sys\eval(left)

Meter:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: node\calls

Evaluation:
    return: int
    prepared:
        return: (Meter\next() PreparedOps\twice 0)
    raw:
        return: (Meter\next() RawOps\twice 0)
```

[Полный исходник](source/lmx/H07.lm3)

## Haskell

```haskell
module H07 where

import Control.Monad (replicateM)
import Data.IORef (newIORef, modifyIORef', readIORef)

example :: IO ((Int, Int, Int), (Int, Int, Int))
example = do
  preparedCount <- newIORef 0
  let preparedNext = modifyIORef' preparedCount (+1) >> readIORef preparedCount
  first <- (\value -> value + value) <$> preparedNext
  second <- (\value -> value + value) <$> preparedNext
  preparedCalls <- readIORef preparedCount
  rawCount <- newIORef 0
  let rawNext = modifyIORef' rawCount (+1) >> readIORef rawCount
  third <- sum <$> replicateM 2 rawNext
  fourth <- sum <$> replicateM 2 rawNext
  rawCalls <- readIORef rawCount
  pure ((first, second, preparedCalls), (third, fourth, rawCalls))
```

[Полный исходник](source/haskell/H07.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Два prepared-вызова дают 2 и 4 при двух вычислениях источника; два raw-вызова дают 3 и 7 при четырёх вычислениях. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
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
| LMX — процедурный | 354 | 22 |
| LMX — функциональный | 354 | 22 |
| Haskell | 582 | 16 |

