# H05. Dynamic and lexical binding after a graph copy

## Общий договор

Скопировать исходное значение 5, изменить источник на 8, затем прочитать динамическое окружение 25 и лексическую копию 5 с аргументом 1: 26 и 6.

**Сопоставимость: аналогия.** Haskell создаёт две разные ячейки, действительно меняет источник и передаёт окружение явно. Третий результат проверяет источник после изменения: 8. Это модель выбора окружения, а не копирование исполняемого графа или native dynamic lookup LMX; parent и граф методов Haskell-код не воспроизводит.

## LMX — процедурный

```lmx
Source:
    int: y 5
    methods:
        int: x
        return: int
        dynamic:
            return: x + y
        lexical:
            return: x + node\y

BindingProbe:
    return: int
    run:
        @: copied (copy(Source))
        Source\y := 8
        int: y 25
        int: a copied\methods\dynamic(1)
        int: b copied\methods\lexical(1)
        return: a * 100 + b
```

[Полный исходник](source/lmx/procedural/H05.lm3)
## LMX — функциональный

```lmx
Source:
    int: y 5
    methods:
        int: x
        return: int
        dynamic:
            return: x + y
        lexical:
            return: x + node\y

BindingProbe:
    return: int
    run:
        @: copied (copy(Source))
        Source\y := 8
        int: y 25
        return: copied\methods\dynamic(1) * 100 + copied\methods\lexical(1)
```

[Полный исходник](source/lmx/H05.lm3)

## Haskell

```haskell
module H05 where

import Data.IORef (IORef, newIORef, readIORef, writeIORef)

addIn :: IORef Int -> Int -> IO Int
addIn environment x = (+x) <$> readIORef environment

example :: IO (Int, Int, Int)
example = do
  source <- newIORef 5
  copied <- readIORef source >>= newIORef
  writeIORef source 8
  caller <- newIORef 25
  dynamic <- addIn caller 1
  lexical <- addIn copied 1
  sourceAfter <- readIORef source
  pure (dynamic, lexical, sourceAfter)
```

[Полный исходник](source/haskell/H05.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Скопировать исходное значение 5, изменить источник на 8, затем прочитать динамическое окружение 25 и лексическую копию 5 с аргументом 1: 26 и 6. | Наблюдения и пределы соответствия описаны выше |
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
| LMX — процедурный | 218 | 18 |
| LMX — функциональный | 206 | 16 |
| Haskell | 362 | 14 |
