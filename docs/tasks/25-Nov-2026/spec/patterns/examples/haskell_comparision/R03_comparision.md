# R03. Imported parent identity versus copied parent identity

## Общий договор

Импортированный read сохраняет владельца со значением 7; копия получает собственного владельца, запись в него даёт 12, результат 712.

**Сопоставимость: аналогия.** Provider хранит реальную ячейку владельца и closure для чтения. Импорт моделируется сохранением этого closure, copyProvider создаёт новую ячейку и новый closure; исходная ячейка остаётся 7. Это явно написанная модель owner/copy, а не реализация общего import, parent или группирующего контейнера LMX.

## LMX — общая минимальная форма обоих стилей

Обязательны import исходного владельца, copy графа и запись в владельца копии. Эти наблюдаемые операции одинаковы; искусственная функциональная обвязка не вводится.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Provider:
    int: value 7
    return: int
    read:
        return: value

ImportProbe:
    return: int
    run:
        import: Provider
        int: value 99
        int: original read()
        @: copied (copy(Provider))
        @: copiedOwner parent(copied\read)
        copiedOwner\value := 12
        return: original * 100 + copied\read()
```

[Полный исходник](source/lmx/R03.lm3)

## Haskell

```haskell
module R03 where

import Data.IORef (IORef, newIORef, readIORef, writeIORef)

data Provider = Provider { owner :: IORef Int, readValue :: IO Int }

makeProvider :: Int -> IO Provider
makeProvider value = do
  cell <- newIORef value
  pure (Provider cell (readIORef cell))

copyProvider :: Provider -> IO Provider
copyProvider provider = readValue provider >>= makeProvider

example :: IO (Int, Int, Int)
example = do
  provider <- makeProvider 7
  let imported = readValue provider
  original <- imported
  copied <- copyProvider provider
  writeIORef (owner copied) 12
  result <- readValue copied
  originalAfter <- readValue provider
  pure (original * 100 + result, originalAfter, result)
```

[Полный исходник](source/haskell/R03.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Импортированный read сохраняет владельца со значением 7; копия получает собственного владельца, запись в него даёт 12, результат 712. | Наблюдения и пределы соответствия описаны выше |
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
| LMX — процедурный | 226 | 15 |
| LMX — функциональный | 226 | 15 |
| Haskell | 568 | 19 |

