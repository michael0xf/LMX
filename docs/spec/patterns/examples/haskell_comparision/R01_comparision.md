# R01. Merge an existing record and add a field

## Общий договор

Объединить width=2,height=3 с height=5,depth=7: получить 257; depth действительно отсутствует в исходной модели.

**Сопоставимость: аналогия.** Использован Map, а не запись с заранее объявленным depth. Map.union patch model сохраняет значение patch при совпадении ключа, добавляет новый ключ и не меняет исходные карты. Карта однородных значений не реализует типизированный исполняемый граф, DATA и parent структуры LMX; этот предел отмечен явно.

## LMX — процедурный

```lmx
RecordModel:
    int: width 2
    int: height 3

RecordPatch:
    int: height 5
    int: depth 7

MergeProbe:
    return: int
    run:
        @: result (merge(RecordModel; RecordPatch))
        return: result\width * 100 + result\height * 10 + result\depth
```

[Полный исходник](source/lmx/procedural/R01.lm3)
## LMX — функциональный

```lmx
RecordModel:
    int: width 2
    int: height 3

RecordPatch:
    int: height 5
    int: depth 7

MergeProbe:
    return: int
    run:
        @: result derive(RecordModel; RecordPatch)
        return: result\width * 100 + result\height * 10 + result\depth
```

[Полный исходник](source/lmx/R01.lm3)

## Haskell

```haskell
module R01 where

import qualified Data.Map.Strict as Map

model, patch, extended :: Map.Map String Int
model = Map.fromList [("width",2),("height",3)]
patch = Map.fromList [("height",5),("depth",7)]
extended = Map.union patch model

example :: Int
example = extended Map.! "width" * 100
        + extended Map.! "height" * 10 + extended Map.! "depth"
```

[Полный исходник](source/haskell/R01.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Объединить width=2,height=3 с height=5,depth=7: получить 257; depth действительно отсутствует в исходной модели. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [containers: Data.Map.Strict](https://hackage-content.haskell.org/package/containers-0.7/docs/Data-Map-Strict.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 184 | 11 |
| LMX — функциональный | 183 | 11 |
| Haskell | 293 | 9 |
