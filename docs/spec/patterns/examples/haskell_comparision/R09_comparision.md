# R09. Uninitialized payload and local versus graph write

## Общий договор

Различить отсутствие инициализации и готовый ноль; локальная запись даёт 5 без изменения источника, графовая запись заменяет исходное состояние на Ready 5.

**Сопоставимость: аналогия.** Payload моделирует тег состояния: Uninitialized отличается от Ready 0 и Ready Nothing. Копия IORef используется для локальной записи, исходный IORef — для graphWrite. Конструктор Uninitialized не означает физический нулевой payload LMX; ни размер памяти, ни адресная идентичность представлены этим сравнением не полностью.

## LMX — общая минимальная форма обоих стилей

Неинициализированные поля и отдельные пути локальной/графовой записи нельзя заменить значениями-константами. Минимальная форма одинакова.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
UninitializedGraph:
    int: number
    @: reference
    return: int
    localWrite:
        number := 5
        return: number
    graphWrite:
        UninitializedGraph\number := 5
        return: UninitializedGraph\number

ReadyValues:
    int: number 0
    @: reference 0
```

[Полный исходник](source/lmx/R09.lm3)

## Haskell

```haskell
module R09 where

import Data.IORef (IORef, newIORef, readIORef, writeIORef)

data Payload a = Uninitialized | Ready a deriving (Eq, Show)

localWrite, graphWrite :: IORef (Payload Int) -> IO Int
localWrite source = do
  local <- readIORef source >>= newIORef
  writeIORef local (Ready 5)
  Ready value <- readIORef local
  pure value
graphWrite source = do
  writeIORef source (Ready 5)
  Ready value <- readIORef source
  pure value

readyNumber :: Payload Int
readyNumber = Ready 0

readyReference :: Payload (Maybe Int)
readyReference = Ready Nothing
```

[Полный исходник](source/haskell/R09.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Различить отсутствие инициализации и готовый ноль; локальная запись даёт 5 без изменения источника, графовая запись заменяет исходное состояние на Ready 5. | Наблюдения и пределы соответствия описаны выше |
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
| LMX — процедурный | 189 | 13 |
| LMX — функциональный | 189 | 13 |
| Haskell | 454 | 17 |
