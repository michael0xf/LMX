# H01. Replace and invoke a first-class callable

## Общий договор

Complete for the current successful fixture: store twice, read and invoke it with 7, replace the same callable cell by plusOne, read and invoke it with 7; packed result 1408. IORef is a real base facility. The Haskell IO wrapper expresses the two writes/reads explicitly; no claim about the full LMX callable ABI is made.

Сценарий наблюдает две записи и два чтения одной callable-ячейки. Эти эффекты обязательны в обоих стилях; прямой вызов выбранной функции уже является минимальной композицией.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

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

[Полный исходник](../../lmx/H01.lm3)

## Haskell

```haskell
import Data.IORef (newIORef, readIORef)
import qualified Data.IORef as Ref

applicationExample :: IO Int
applicationExample = do
  chosen <- newIORef ((*2) :: Int -> Int)
  firstOperation <- readIORef chosen
  let first = firstOperation 7
  Ref.writeIORef chosen (+1)
  secondOperation <- readIORef chosen
  let second = secondOperation 7
  pure (first * 100 + second)
```

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **191** | 14 |
| LMX — функциональный | **191** | 14 |
| Haskell | 303 | 11 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
