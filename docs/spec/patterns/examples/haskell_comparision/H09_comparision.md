# H09. Finite iterator with a live declaration and body

## Общий договор

Конечный источник 1,2,3, удвоение в теле, сумма 12, четыре обращения к источнику и три исполнения тела.

**Сопоставимость: аналогия.** Общий iterateUntil ловит Stop только при получении следующего элемента; Stop из тела и другие исключения проходят наружу. Объявление item и живое присоединённое тело LMX представлены callback-функцией. Счётчики находятся во внешней фикстуре, а не искусственно утяжеляют сравниваемый алгоритм. Графовый механизм declaration-as-DATA остаётся различием.

## LMX — общая минимальная форма обоих стилей

Принятая декларация и тело работают в живом контексте. Stop источника поглощается, Stop тела распространяется под исходным именем. Существующий общий адаптер имеет иной failure-envelope API, поэтому корректная минимальная форма здесь общая.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()

Numbers:
    int: position 0
    return: int
    next:
        throws: Stop
        if: node\position >= 3
            throw: Stop()
        node\position += 1
        return: node\position
    demo:
        node\position := 0
        int: total 0
        Cycles\iterate: int: item Numbers\next()
            item *= 2
            total += item
        return: total
```

[Полный исходник](source/lmx/H09.lm3)

## Haskell

```haskell
module H09 where

import Control.Exception (Exception, catch, throwIO)
import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')

data Stop = Stop deriving Show
instance Exception Stop

iterateUntil :: IO a -> (a -> IO ()) -> IO ()
iterateUntil next body = do
  item <- (Just <$> next) `catch` (\Stop -> pure Nothing)
  case item of
    Nothing -> pure ()
    Just value -> body value >> iterateUntil next body

example :: IO Int
example = do
  position <- newIORef 0
  total <- newIORef 0
  let next = do
        value <- readIORef position
        if value >= 3 then throwIO Stop else do
          writeIORef position (value + 1)
          pure (value + 1)
  iterateUntil next (\item -> modifyIORef' total (+ (item * 2)))
  readIORef total
```

[Полный исходник](source/haskell/H09.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Конечный источник 1,2,3, удвоение в теле, сумма 12, четыре обращения к источнику и три исполнения тела. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html); [base: Control.Exception](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Control-Exception.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 285 | 25 |
| LMX — функциональный | 285 | 25 |
| Haskell | 569 | 22 |
