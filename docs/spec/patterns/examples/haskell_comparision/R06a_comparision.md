# R06a. Graph copy preserving shared targets

## Общий договор

При копировании два ребра на общий узел должны остаться двумя ребрами на один новый узел. Изменение копии на 21 видно через второе ребро; оригинал остаётся 7: 2107.

**Сопоставимость: аналогия.** Используется общий алгоритм GraphCopy с таблицей посещённых IORef, а не заранее изготовленная правильная пара. Фикстура проверяет равенство copied left/right и отличие от оригинала. Модель копирует узлы и рёбра явно заданного графа; правила DATA, parent и исполняемых узлов LMX в неё не включены.

## LMX — общая минимальная форма обоих стилей

Оба стиля должны выполнить настоящий graph copy и проверить сохранённую общую цель после записи. Числовая имитация или сборка новой записи не эквивалентна этому договору.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
SharedValue:
    int: value 7

SharedPair:
    @: left SharedValue
    @: right SharedValue

SharingProbe:
    return: int
    run:
        @: copied (copy(SharedPair))
        copied\left\value := 21
        return: copied\right\value * 100 + SharedValue\value
```

[Полный исходник](source/lmx/R06a.lm3)

## Haskell

```haskell
module R06a where

import Data.IORef (newIORef, readIORef, modifyIORef')
import GraphCopy (Node(..), copyGraph)

example :: IO (Int, Bool, Bool)
example = do
  shared <- newIORef (Node 7 [])
  pair <- newIORef (Node 0 [shared,shared])
  copied <- copyGraph pair
  Node _ [left,right] <- readIORef copied
  modifyIORef' left (\(Node _ links) -> Node 21 links)
  Node rightValue _ <- readIORef right
  Node originalValue _ <- readIORef shared
  pure (rightValue * 100 + originalValue, left == right, left /= shared)
```

[Полный исходник](source/haskell/R06a.hs).
Обязательная пользовательская зависимость: [GraphCopy — полный код](library_comparisons/graphCopy.md), [исходник](source/haskell/GraphCopy.hs). Она входит в границу реализации; её нельзя считать стандартной библиотекой или скрывать при будущем подсчёте.


## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | При копировании два ребра на общий узел должны остаться двумя ребрами на один новый узел. Изменение копии на 21 видно через второе ребро; оригинал остаётся 7: 2107. | Наблюдения и пределы соответствия описаны выше |
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
| LMX — процедурный | 189 | 11 |
| LMX — функциональный | 189 | 11 |
| Haskell | 909 | 31 |

Включены зависимости: `haskell_comparision/source/haskell/GraphCopy.hs`.
