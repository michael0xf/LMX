# H01. Replace and invoke a first-class callable

## Общий договор

Сохранить callable, вызвать его с 7, заменить в той же ячейке и снова вызвать с 7. Наблюдение: 1408.

**Сопоставимость: полная пара.** Обе записи содержат настоящую изменяемую ячейку с функцией. В Haskell это IORef из base; первая функция удваивает, вторая прибавляет единицу. Конкретный ABI callable LMX в предмет сравнения не входит.

## LMX — общая минимальная форма обоих стилей

Сценарий наблюдает две записи и два чтения одной callable-ячейки. Эти эффекты обязательны в обоих стилях; прямой вызов выбранной функции уже является минимальной композицией.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Arithmetic:
    int: value
    return: int
    twice:
        return: value * 2
    plusOne:
        return: value + 1

ApplyProbe:
    return: int
    run:
        @: chosen Arithmetic\twice
        int: first chosen(7)
        chosen := Arithmetic\plusOne
        return: first * 100 + chosen(7)
```

[Полный исходник](source/lmx/H01.lm3)

## Haskell

```haskell
module H01 where

import Data.IORef (newIORef, readIORef, writeIORef)

example :: IO Int
example = do
  chosen <- newIORef ((*2) :: Int -> Int)
  firstOperation <- readIORef chosen
  let first = firstOperation 7
  writeIORef chosen (+1)
  secondOperation <- readIORef chosen
  pure (first * 100 + secondOperation 7)
```

[Полный исходник](source/haskell/H01.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Сохранить callable, вызвать его с 7, заменить в той же ячейке и снова вызвать с 7. Наблюдение: 1408. | Наблюдения и пределы соответствия описаны выше |
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
| LMX — процедурный | <span style="color:#176233"><u>191</u></span> | 14 |
| LMX — функциональный | <span style="color:#176233"><u>191</u></span> | 14 |
| Haskell | 256 | 10 |

