# R06b. Graph copy preserving a cycle

## Общий договор

Копия self-cycle должна замыкаться на себя, а не на исходный Ring. После записи 8 исходный Ring остаётся 3: 83.

**Сопоставимость: аналогия.** Тот же GraphCopy заносит новый узел в memo до обхода его рёбер, поэтому цикл завершается и сохраняется. Проверяются self==copy, copy/=original и прежнее значение отдельного снимка 3. Снимок не объявляется реализацией LMX-группирующей структуры с собственными ячейками; этот графовый аспект остаётся за пределом модели.

## LMX — общая минимальная форма обоих стилей

Оба стиля обязаны сохранить и проверить цикл графа. copy, запись через self и чтение исходника — минимальные необходимые операции.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Ring:
    int: value 3
    @: self

CycleProbe:
    return: int
    run:
        Ring\self := Ring
        @: copied (copy(Ring))
        copied\self\value := 8
        return: copied\self\value * 10 + Ring\value
```

[Полный исходник](source/lmx/R06b.lm3)

## Haskell

```haskell
module R06b where

import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')
import GraphCopy (Node(..), copyGraph)

example :: IO (Int, Bool, Bool, Int)
example = do
  ring <- newIORef (Node 3 [])
  writeIORef ring (Node 3 [ring])
  copied <- copyGraph ring
  Node snapshotValue [self] <- readIORef copied
  modifyIORef' self (\(Node _ links) -> Node 8 links)
  Node value _ <- readIORef copied
  Node original _ <- readIORef ring
  pure (value * 10 + original, self == copied, copied /= ring, snapshotValue)
```

[Полный исходник](source/haskell/R06b.hs).
Обязательная пользовательская зависимость: [GraphCopy — полный код](library_comparisons/graphCopy.md), [исходник](source/haskell/GraphCopy.hs). Она входит в границу реализации; её нельзя считать стандартной библиотекой или скрывать при будущем подсчёте.


## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Копия self-cycle должна замыкаться на себя, а не на исходный Ring. После записи 8 исходный Ring остаётся 3: 83. | Наблюдения и пределы соответствия описаны выше |
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
| LMX — процедурный | 139 | 10 |
| LMX — функциональный | 139 | 10 |
| Haskell | 911 | 31 |

Включены зависимости: `haskell_comparision/source/haskell/GraphCopy.hs`.
