# R04. Computed initializer, local write and repeated activation

## Общий договор

Повторные активации вычисляемого initializer дают 41 и 42, несмотря на локальную запись 99: 4142 и два вызова. Отдельная явная инициализация даёт 44 и один вызов.

**Сопоставимость: аналогия.** initializer здесь настоящий IO action; каждая активация вызывает его заново и меняет только отдельный local IORef. Счётчик источника общий. Haskell-модель не хранит само вычисляемое объявление в исходном графе программы, поэтому сравнение остаётся семантической аналогией.

## LMX — общая минимальная форма обоих стилей

Инициализатор с побочным эффектом и различие локальной/графовой записи являются предметом проверки. Их порядок, число вызовов и два отдельных entry сохраняются одинаково.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
ReadSource:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: 40 + node\calls

ComputedInput:
    int: value ReadSource\next()
    return: int
    changeLocal:
        int: seen value
        value := 99
        return: seen

LocalProbe:
    return: int
    run:
        ReadSource\calls := 0
        int: first ComputedInput\changeLocal()
        int: second ComputedInput\changeLocal()
        return: first * 100 + second
    explicitInitialization:
        ReadSource\calls := 0
        int: i
        i := ReadSource\next()
        i += 3
        return: i
```

[Полный исходник](source/lmx/R04.lm3)

## Haskell

```haskell
module R04 where

import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')

changeLocal :: IO Int -> IO Int
changeLocal initializer = do
  local <- initializer >>= newIORef
  seen <- readIORef local
  writeIORef local 99
  pure seen

example :: IO ((Int, Int), (Int, Int))
example = do
  calls <- newIORef 0
  let next = modifyIORef' calls (+1) >> ((40+) <$> readIORef calls)
  first <- changeLocal next
  second <- changeLocal next
  twice <- readIORef calls
  writeIORef calls 0
  i <- next >>= newIORef
  modifyIORef' i (+3)
  explicit <- readIORef i
  once <- readIORef calls
  pure ((first * 100 + second, twice), (explicit, once))
```

[Полный исходник](source/haskell/R04.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Повторные активации вычисляемого initializer дают 41 и 42, несмотря на локальную запись 99: 4142 и два вызова. Отдельная явная инициализация даёт 44 и один вызов. | Наблюдения и пределы соответствия описаны выше |
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
| LMX — процедурный | 383 | 26 |
| LMX — функциональный | 383 | 26 |
| Haskell | 514 | 21 |

