# Примеры LMX и аналоги Haskell: две полные стилевые записи

Все 24 исходных сценария имеют отдельные Haskell-реализации и страницы сравнения в [haskell_comparision](examples/haskell_comparision/README.md). Сохранены обе LMX-формы одного договора; одинаковый минимальный текст показан один раз. Граница полной пары или ограниченной аналогии указана у каждого сценария.

LMX запускается с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции примеров выполняются после старта по обычным правилам; Haskell Main относится только к контрольному тестовому harness. [Профили запуска](../LMX_semantics.en.md#source-entry-profiles).

Размеры пересчитаны по актуальным исходникам. Сравниваются обе полные LMX-формы и сопоставимый иностранный листинг, включая необходимые собственные helpers и Throws. Неполные аналогии не получают числового победителя.

<a id="h01"></a>
### H01. Replace and invoke a first-class callable

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

[Полный исходник](examples/haskell_comparision/source/lmx/H01.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/H01.hs).

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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | <span style="color:#176233"><u>191</u></span> | 14 |
| LMX — функциональный | <span style="color:#176233"><u>191</u></span> | 14 |
| Haskell | 256 | 10 |

<a id="h02"></a>
### H02. Named signature positions versus candidate names

## Общий договор

Различить порядок позиций сигнатуры a,b и собственные имена кандидата b,a. Упаковка двух вызовов: 2772.

**Сопоставимость: аналогия.** Haskell-код действительно вычисляет 27 и 72: два адаптера берут поля Arguments в разном порядке. Именованное связывание и проверка допуска LMX здесь представлены явно написанными адаптерами; это не встроенный Haskell-механизм именованных фактических аргументов. Поэтому числового рейтинга этой строки нет.

## LMX — процедурный

```lmx
PairOperation :: (int: a; int: b; return: int)

Candidate:
    int: b
    int: a
    return: int
    encode:
        return: b * 10 + a

SignatureProbe:
    return: int
    run:
        PairOperation@: selected Candidate\encode
        int: first selected(a := 2; b := 7)
        int: second Candidate\encode(a := 2; b := 7)
        return: first * 100 + second
```

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/H02.lm3)
## LMX — функциональный

```lmx
PairOperation :: (int: a; int: b; return: int)

Candidate:
    int: b
    int: a
    return: int
    encode:
        return: b * 10 + a

SignatureProbe:
    return: int
    run:
        PairOperation@: selected Candidate\encode
        return: selected(a := 2; b := 7) * 100 + Candidate\encode(a := 2; b := 7)
```

[Полный исходник](examples/haskell_comparision/source/lmx/H02.lm3)

## Haskell

```haskell
module H02 where

data Arguments = Arguments { a :: Int, b :: Int }

encode :: Int -> Int -> Int
encode bValue aValue = bValue * 10 + aValue

bySignatureNames, byCandidateNames :: Arguments -> Int
bySignatureNames args = encode (a args) (b args)
byCandidateNames args = encode (b args) (a args)

example :: Int
example = let args = Arguments { a = 2, b = 7 }
          in bySignatureNames args * 100 + byCandidateNames args
```

[Полный исходник](examples/haskell_comparision/source/haskell/H02.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Различить порядок позиций сигнатуры a,b и собственные имена кандидата b,a. Упаковка двух вызовов: 2772. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 245 | 14 |
| LMX — функциональный | 215 | 12 |
| Haskell | 332 | 10 |

<a id="h03"></a>
### H03. Independent bound prefixes and residual callable admission

## Общий договор

Независимые частичные применения 5 и 100; последовательность результатов 6,101,6.

**Сопоставимость: полная пара.** Haskell использует обычное частичное применение. Для сравнения результата тройка (a,b,c) упаковывается как a*1000000+b*1000+c, то есть 6101006. В LMX сохранённый actual не становится свободным остаточным параметром; Haskell не предоставляет одноимённого фактического аргумента для его переопределения. Отдельная диагностика допуска не объявлена одинаковой.

## LMX — процедурный

```lmx
CapturePrototype:
    int: saved 0
    @: binary 0
    inputs:
        int: second
        return: int
        apply:
            return: node\binary(node\saved; second)

Curry:
    @: binary
    int: first
    return: @
    capture:
        @: instance (copy(CapturePrototype))
        @: owner parent(instance\inputs)
        owner\saved := first
        owner\binary := binary
        return: instance\inputs\apply

Addition:
    int: first
    int: second
    return: int
    add:
        return: first + second

ClosureProbe:
    return: int
    run:
        @: add5 Curry\capture(Addition\add; 5)
        @: add100 Curry\capture(Addition\add; 100)
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/H03.lm3)
## LMX — функциональный

```lmx
Addition:
    int: first
    int: second
    return: int
    add:
        return: first + second

ClosureProbe:
    return: int
    run:
        throws: copy(partial\throws)
        @: add5 partial(Addition\add; (5))
        @: add100 partial(Addition\add; (100))
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

[Полный исходник](examples/haskell_comparision/source/lmx/H03.lm3)

## Haskell

```haskell
module H03 where

add :: Int -> Int -> Int
add first second = first + second

example :: (Int, Int, Int)
example = let add5 = add 5
              add100 = add 100
          in (add5 1, add100 1, add5 1)
```

[Полный исходник](examples/haskell_comparision/source/haskell/H03.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Независимые частичные применения 5 и 100; последовательность результатов 6,101,6. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 495 | 31 |
| LMX — функциональный | 239 | 14 |
| Haskell | <span style="color:#176233"><u>137</u></span> | 7 |

<a id="h04"></a>
### H04. Overrideable copied default

## Общий договор

Отсутствующий default, явные 25 и 0, затем снова отсутствующий default: 6,26,1,6.

**Сопоставимость: полная пара.** Maybe отличает отсутствие переопределения от значения 0. Четыре вызова включены в обе реализации. Список упаковывается как a*1000000+b*10000+c*100+d, результат 6260106. В отличие от прежнего обрывка после объявления функции, показанный Haskell-модуль самодостаточен.

## LMX — процедурный

```lmx
Addition:
    int: x
    int: y
    return: int
    add:
        return: x + y

DefaultProbe:
    return: int
    run:
        int: y 100
        @: fiveContext (merge(Addition; (int: y 5)))
        @: add5 fiveContext\add
        int: first add5(1)
        int: second add5(1; y := 25)
        int: third add5(1; y := 0)
        int: fourth add5(1)
        return: first * 1000000 + second * 10000 + third * 100 + fourth
```

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/H04.lm3)
## LMX — функциональный

```lmx
Addition:
    int: x
    int: y
    return: int
    add:
        return: x + y

DefaultProbe:
    return: int
    run:
        int: y 100
        @: fiveContext (merge(Addition; (int: y 5)))
        @: add5 fiveContext\add
        return: add5(1) * 1000000 + add5(1; y := 25) * 10000 + add5(1; y := 0) * 100 + add5(1)
```

[Полный исходник](examples/haskell_comparision/source/lmx/H04.lm3)

## Haskell

```haskell
module H04 where

addWithDefault :: Int -> Maybe Int -> Int
addWithDefault x supplied = x + maybe 5 id supplied

example :: [Int]
example = map (addWithDefault 1) [Nothing, Just 25, Just 0, Nothing]
```

[Полный исходник](examples/haskell_comparision/source/haskell/H04.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Отсутствующий default, явные 25 и 0, затем снова отсутствующий default: 6,26,1,6. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 265 | 17 |
| LMX — функциональный | 205 | 13 |
| Haskell | <span style="color:#176233"><u>162</u></span> | 5 |

<a id="h05"></a>
### H05. Dynamic and lexical binding after a graph copy

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

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/H05.lm3)
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

[Полный исходник](examples/haskell_comparision/source/lmx/H05.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/H05.hs).

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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 218 | 18 |
| LMX — функциональный | 206 | 16 |
| Haskell | 362 | 14 |

<a id="h06"></a>
### H06. Order of two composed computations

## Общий договор

next(twice(4))=9; twice(next(4))=10. Оба порядка обязательны.

**Сопоставимость: полная пара.** Оператор композиции Haskell задаёт те же две арифметические цепочки. Пара (a,b) нормализуется в LMX-упаковку a*100+b=910. Отдельный эффектный сценарий со счётчиками из старого Analogies.hs не подставляется вместо этого чистого договора.

## LMX — процедурный

```lmx
Functions:
    int: x
    return: int
    twice:
        return: x * 2
    next:
        return: x + 1

CompositionProbe:
    return: int
    run:
        int: first Functions\twice(4)
        first := Functions\next(first)
        int: second Functions\next(4)
        second := Functions\twice(second)
        return: first * 100 + second
```

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/H06.lm3)
## LMX — функциональный

```lmx
Functions:
    int: x
    return: int
    twice:
        return: x * 2
    next:
        return: x + 1

CompositionProbe:
    return: int
    run:
        return: Functions\next(Functions\twice(4)) * 100 + Functions\twice(Functions\next(4))
```

[Полный исходник](examples/haskell_comparision/source/lmx/H06.lm3)

## Haskell

```haskell
module H06 where

example :: (Int, Int)
example = (((+1) . (*2)) 4, ((*2) . (+1)) 4)
```

[Полный исходник](examples/haskell_comparision/source/haskell/H06.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | next(twice(4))=9; twice(next(4))=10. Оба порядка обязательны. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 223 | 15 |
| LMX — функциональный | 167 | 11 |
| Haskell | <span style="color:#176233"><u>67</u></span> | 3 |

<a id="h07"></a>
### H07. Prepared value versus raw source occurrence

## Общий договор

Два prepared-вызова дают 2 и 4 при двух вычислениях источника; два raw-вызова дают 3 и 7 при четырёх вычислениях.

**Сопоставимость: аналогия.** Реальная Haskell-реализация отдельно разделяет полученное значение и повторяет IO-действие. Она не принимает произвольное исходное вхождение программы и не исполняет сохранённый граф через sys\eval. Ленивость Haskell сама по себе не объявляется заменой PASS_ARGS_AS_IS.

## LMX — общая минимальная форма обоих стилей

Это проверка prepared/raw ролей и повторного вычисления исходного occurrence. Замена сохраняемого узла на lambda или заранее вычисленное значение изменила бы договор, поэтому минимальная запись общая.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
PreparedOps:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    twice:
        return: \left + \left

RawOps:
    merge: sys\OPERANDS_TEMPLATE (const: int: PASS_ARGS_AS_IS 1)
    return: int
    twice:
        return: sys\eval(left) + sys\eval(left)

Meter:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: node\calls

Evaluation:
    return: int
    prepared:
        return: (Meter\next() PreparedOps\twice 0)
    raw:
        return: (Meter\next() RawOps\twice 0)
```

[Полный исходник](examples/haskell_comparision/source/lmx/H07.lm3)

## Haskell

```haskell
module H07 where

import Control.Monad (replicateM)
import Data.IORef (newIORef, modifyIORef', readIORef)

example :: IO ((Int, Int, Int), (Int, Int, Int))
example = do
  preparedCount <- newIORef 0
  let preparedNext = modifyIORef' preparedCount (+1) >> readIORef preparedCount
  first <- (\value -> value + value) <$> preparedNext
  second <- (\value -> value + value) <$> preparedNext
  preparedCalls <- readIORef preparedCount
  rawCount <- newIORef 0
  let rawNext = modifyIORef' rawCount (+1) >> readIORef rawCount
  third <- sum <$> replicateM 2 rawNext
  fourth <- sum <$> replicateM 2 rawNext
  rawCalls <- readIORef rawCount
  pure ((first, second, preparedCalls), (third, fourth, rawCalls))
```

[Полный исходник](examples/haskell_comparision/source/haskell/H07.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Два prepared-вызова дают 2 и 4 при двух вычислениях источника; два raw-вызова дают 3 и 7 при четырёх вычислениях. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 354 | 22 |
| LMX — функциональный | 354 | 22 |
| Haskell | 582 | 16 |

<a id="h08"></a>
### H08. Owned formal copy versus caller place

## Общий договор

Один шаг +3; через собственную копию формального поля вызывающая ячейка остаётся 0, через общее место становится 3.

**Сопоставимость: аналогия.** freeStep содержит единственную реализацию изменения. ownStep создаёт отдельную ячейку и вызывает тот же шаг; stateProbe принимает произвольную операцию. Разница владения проверяется настоящими IORef, но передача ссылки в Haskell явная и не воспроизводит автоматическое динамическое связывание LMX.

## LMX — общая минимальная форма обоих стилей

Проверяемый эффект — изменение собственной ячейки формального параметра либо живого места вызывающего. Одно тело операции и runner необходимы в обоих стилях; дополнительная обвязка не меняет стиль наблюдаемой операции.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Free:
    step:
        y += 3

Own:
    int: y
    step:
        Free\step()

StateProbe:
    @: action
    return: int
    run:
        int: y 0
        action()
        return: y
```

[Полный исходник](examples/haskell_comparision/source/lmx/H08.lm3)

## Haskell

```haskell
module H08 where

import Data.IORef (IORef, newIORef, readIORef, modifyIORef')

freeStep, ownStep :: IORef Int -> IO ()
freeStep place = modifyIORef' place (+3)
ownStep caller = readIORef caller >>= newIORef >>= freeStep

stateProbe :: (IORef Int -> IO ()) -> IO Int
stateProbe action = do
  caller <- newIORef 0
  action caller
  readIORef caller
```

[Полный исходник](examples/haskell_comparision/source/haskell/H08.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Один шаг +3; через собственную копию формального поля вызывающая ячейка остаётся 0, через общее место становится 3. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 94 | 14 |
| LMX — функциональный | 94 | 14 |
| Haskell | 285 | 10 |

<a id="h09"></a>
### H09. Finite iterator with a live declaration and body

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

[Полный исходник](examples/haskell_comparision/source/lmx/H09.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/H09.hs).

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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html); [base: Control.Exception](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Control-Exception.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 285 | 25 |
| LMX — функциональный | 285 | 25 |
| Haskell | 569 | 22 |

<a id="r01"></a>
### R01. Merge an existing record and add a field

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

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/R01.lm3)
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

[Полный исходник](examples/haskell_comparision/source/lmx/R01.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/R01.hs).

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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [containers: Data.Map.Strict](https://hackage-content.haskell.org/package/containers-0.7/docs/Data-Map-Strict.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 184 | 11 |
| LMX — функциональный | 183 | 11 |
| Haskell | 293 | 9 |

<a id="r02"></a>
### R02. Copy a field stream into group assignment

## Общий договор

Получить из двух полей Pair упорядоченный поток 2,7 и разложить его на a,b; результат 27.

**Сопоставимость: аналогия.** fieldStream действительно извлекает поля, а pattern match распределяет их по двум переменным. В Haskell это специально определённое представление потока и проверка длины, не общий copy структур LMX и не группировщик Expression. Just 27 нормализуется в успешный результат 27; Nothing обозначает неподходящую длину.

## LMX — общая минимальная форма обоих стилей

Групповое присваивание принимает поток полей `copy(Pair)` напрямую; внешняя группа вокруг `copy` для этого списка мест не нужна. В обоих стилях сохранены позиционные записи a=2 и b=7, чтение всех правых значений до первой записи и результат 27. Минимальная форма общая.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Pair:
    int: first 2
    int: second 7

StreamProbe:
    return: int
    run:
        int: a 0
        int: b 0
        (a b) := copy(Pair)
        return: a * 10 + b
```

[Полный исходник](examples/haskell_comparision/source/lmx/R02.lm3)

## Haskell

```haskell
module R02 where

data Pair = Pair { first :: Int, second :: Int }

fieldStream :: Pair -> [Int]
fieldStream pair = [first pair, second pair]

example :: Maybe Int
example = case fieldStream (Pair 2 7) of
  [a,b] -> Just (a * 10 + b)
  _ -> Nothing
```

[Полный исходник](examples/haskell_comparision/source/haskell/R02.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Получить из двух полей Pair упорядоченный поток 2,7 и разложить его на a,b; результат 27. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 93 | 10 |
| LMX — функциональный | 93 | 10 |
| Haskell | 192 | 8 |

<a id="r03"></a>
### R03. Imported parent identity versus copied parent identity

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

[Полный исходник](examples/haskell_comparision/source/lmx/R03.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/R03.hs).

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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 226 | 15 |
| LMX — функциональный | 226 | 15 |
| Haskell | 568 | 19 |

<a id="r04"></a>
### R04. Computed initializer, local write and repeated activation

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

[Полный исходник](examples/haskell_comparision/source/lmx/R04.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/R04.hs).

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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 383 | 26 |
| LMX — функциональный | 383 | 26 |
| Haskell | 514 | 21 |

<a id="r06a"></a>
### R06a. Graph copy preserving shared targets

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

[Полный исходник](examples/haskell_comparision/source/lmx/R06a.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/R06a.hs).
Обязательная пользовательская зависимость: [GraphCopy — полный код](examples/haskell_comparision/library_comparisons/graphCopy.md), [исходник](examples/haskell_comparision/source/haskell/GraphCopy.hs). Она входит в границу реализации; её нельзя считать стандартной библиотекой или скрывать при будущем подсчёте.


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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 189 | 11 |
| LMX — функциональный | 189 | 11 |
| Haskell | 909 | 31 |

Включены зависимости: `haskell_comparision/source/haskell/GraphCopy.hs`.

<a id="r06b"></a>
### R06b. Graph copy preserving a cycle

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

[Полный исходник](examples/haskell_comparision/source/lmx/R06b.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/R06b.hs).
Обязательная пользовательская зависимость: [GraphCopy — полный код](examples/haskell_comparision/library_comparisons/graphCopy.md), [исходник](examples/haskell_comparision/source/haskell/GraphCopy.hs). Она входит в границу реализации; её нельзя считать стандартной библиотекой или скрывать при будущем подсчёте.


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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 139 | 10 |
| LMX — функциональный | 139 | 10 |
| Haskell | 911 | 31 |

Включены зависимости: `haskell_comparision/source/haskell/GraphCopy.hs`.

<a id="r07"></a>
### R07. User operand and preserved computation

## Общий договор

Одна сохранённая вычислительная форма (n+3)+n выполняется для 2 и 5; сумма 20.

**Сопоставимость: аналогия.** Haskell строит один явный AST и исполняет его общим eval с разными значениями переменной. Это не пользовательский операнд, встроенный в обычный парсер Haskell, и не гомоиконный граф LMX. Арифметика и повторное использование формы воспроизводятся, синтаксическая инфраструктура различается.

## LMX — общая минимальная форма обоих стилей

Это упражнение самого пользовательского операнда в обычном Expression, а не только вычисления числа20. Общий шаблон и форма вызова обязательны в обоих стилях.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Operands:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    add:
        return: \left + \right[0]
    Example:
        int: n
        return: int
        calculate:
            return: (n add 3) add n
        demo:
            return: calculate(2) + calculate(5)
```

[Полный исходник](examples/haskell_comparision/source/lmx/R07.lm3)

## Haskell

```haskell
module R07 where

data Expr = Number Int | Variable | Add Expr Expr

eval :: Int -> Expr -> Int
eval _ (Number n) = n
eval x Variable = x
eval x (Add a b) = eval x a + eval x b

tree :: Expr
tree = Add (Add Variable (Number 3)) Variable

example :: Int
example = eval 2 tree + eval 5 tree
```

[Полный исходник](examples/haskell_comparision/source/haskell/R07.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Одна сохранённая вычислительная форма (n+3)+n выполняется для 2 и 5; сумма 20. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 159 | 12 |
| LMX — функциональный | 159 | 12 |
| Haskell | 217 | 10 |

<a id="r09"></a>
### R09. Uninitialized payload and local versus graph write

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

[Полный исходник](examples/haskell_comparision/source/lmx/R09.lm3)

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

[Полный исходник](examples/haskell_comparision/source/haskell/R09.hs).

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

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 189 | 13 |
| LMX — функциональный | 189 | 13 |
| Haskell | 454 | 17 |

<a id="a01"></a>
### A01. Shared structural slots and replacement field identity

## Общий договор

Две ссылки выбирают одну структуру слотов; замена второго поля y на z сохраняет длину 2 и делает z=9 видимым через исходную ссылку: 209.

**Сопоставимость: аналогия.** Общий IORef списка Field передаёт изменение через обе ссылки. Заменяется целый Field, включая имя, а не только число. Это явная модель дескриптора с именами; она не приписывает обычным Haskell-record полям возможность менять их имена и не моделирует все правила идентичности примитивов LMX.

## LMX — общая минимальная форма обоих стилей

Проверяется замена структурной позиции с изменением видимого имени поля и сохранением общего descriptor. Нужна настоящая запись в слот; обе формы минимально совпадают.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Slots:
    int: x 1
    int: y 2

Replacement:
    int: z 9

SlotProbe:
    return: int
    run:
        @: same Slots
        same[1] := Replacement[0]
        return: length(Slots) * 100 + Slots\z
```

[Полный исходник](examples/haskell_comparision/source/lmx/A01.lm3)

## Haskell

```haskell
module A01 where

import Data.IORef (newIORef, readIORef, modifyIORef')

data Field = Field { name :: String, value :: Int } deriving (Eq, Show)

replaceAt :: Int -> a -> [a] -> [a]
replaceAt index replacement xs = take index xs ++ [replacement] ++ drop (index+1) xs

example :: IO (Int, [String])
example = do
  slots <- newIORef [Field "x" 1, Field "y" 2]
  let same = slots
      replacement = [Field "z" 9]
  modifyIORef' same (replaceAt 1 (head replacement))
  fields <- readIORef slots
  let Just z = lookup "z" [(name field,value field) | field <- fields]
  pure (length fields * 100 + z, map name fields)
```

[Полный исходник](examples/haskell_comparision/source/haskell/A01.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Две ссылки выбирают одну структуру слотов; замена второго поля y на z сохраняет длину 2 и делает z=9 видимым через исходную ссылку: 209. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 126 | 11 |
| LMX — функциональный | 126 | 11 |
| Haskell | 486 | 14 |

<a id="v02"></a>
### V02. Whole ASCII ticket-code predicate

## Общий договор

Принять всю строку ровно из двух ASCII A–Z, дефиса и двух ASCII 0–9. Проверяются одиннадцать входов, включая NUL и не-ASCII символы.

**Сопоставимость: полная пара.** Пятиэлементный pattern match задаёт точную длину; inRange проверяет ASCII-границы. Нет поиска подстроки, locale-зависимых классов или предварительной очистки входа. Bool нормализуется как False→0, True→1. Исходный процедурный LMX с проверенным разделителем --- сохранён без изменения.

## LMX — процедурный

```lmx
TicketCode:
    char[]: candidate
    return: int
    accepts:
        if: length(candidate) != 5
            return: 0
        int: i 0
        while: i < 5
            if: i != 2
                char: first '0'
                char: last '9'
                if: i < 2
                    first := 'A'
                    last := 'Z'
                if: candidate[i] < first || candidate[i] > last
                    return: 0
                ---
            i += 1
        return: candidate[2] = '-'
```

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/V02.lm3)
## LMX — функциональный

```lmx
TicketCode:
    char[]: candidate
    return: int
    accepts:
        throws: copy(matches\throws)
        return: matches(byteText(candidate); (within("A"; "Z") times 2) then "-" then (asciiDigit times 2))
```

[Полный исходник](examples/haskell_comparision/source/lmx/V02.lm3)

## Haskell

```haskell
module V02 where

import Data.Ix (inRange)

accepts :: String -> Bool
accepts [a,b,'-',c,d] =
  all (inRange ('A','Z')) [a,b]
    && all (inRange ('0','9')) [c,d]
accepts _ = False
```

[Полный исходник](examples/haskell_comparision/source/haskell/V02.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Принять всю строку ровно из двух ASCII A–Z, дефиса и двух ASCII 0–9. Проверяются одиннадцать входов, включая NUL и не-ASCII символы. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.Ix](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-Ix.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 226 | 19 |
| LMX — функциональный | 160 | 6 |
| Haskell | <span style="color:#176233"><u>146</u></span> | 7 |

<a id="v03"></a>
### V03. Inject a read dependency and check interaction counts

## Общий договор

Checker принимает произвольный кандидат, внедряет read, проверяет результат 28 и ровно одно чтение. Good: True/1, biased: False/1, readsTwice: False/2.

**Сопоставимость: полная пара.** В отличие от прежнего закрытого SampleVariant, checker получает функцию Candidate. Общая sample используется вариантами biased и readsTwice, повторный read действительно выполняется. Haskell передаёт gain и read явно; LMX связывает их через текущий контекст. Наблюдаемый договор checker и три отрицательных/положительных случая совпадают.

## LMX — процедурный

```lmx
Measurement:
    int: gain
    @: read
    return: int
    sample:
        return: read() * gain
    biased:
        return: sample() + 1
    readsTwice:
        int: discarded read()
        return: sample()

SamplingCheck:
    @: candidate
    int: calls 0
    return: int
    fixedRead:
        node\calls += 1
        return: 7
    check:
        node\calls := 0
        @: read fixedRead
        int: result candidate(gain := 4)
        if: result != 28
            return: 0
        return: node\calls = 1
```

[Полный исходник](examples/haskell_comparision/source/lmx/procedural/V03.lm3)
## LMX — функциональный

```lmx
Measurement:
    int: gain
    @: read
    return: int
    sample:
        return: read() * gain
    biased:
        return: sample() + 1
    readsTwice:
        int: discarded read()
        return: sample()

SamplingCheck:
    @: candidate
    int: calls 0
    return: int
    fixedRead:
        node\calls += 1
        return: 7
    check:
        node\calls := 0
        @: read fixedRead
        int: result candidate(gain := 4)
        return: result = 28 && node\calls = 1
```

[Полный исходник](examples/haskell_comparision/source/lmx/V03.lm3)

## Haskell

```haskell
module V03 where

import Data.IORef (newIORef, readIORef, modifyIORef')

type Candidate = Int -> IO Int -> IO Int

sample, biased, readsTwice :: Candidate
sample gain readSample = (*gain) <$> readSample
biased gain readSample = (+1) <$> sample gain readSample
readsTwice gain readSample = readSample >> sample gain readSample

check :: Candidate -> IO (Bool, Int)
check candidate = do
  calls <- newIORef 0
  let fixedRead = modifyIORef' calls (+1) >> pure 7
  result <- candidate 4 fixedRead
  count <- readIORef calls
  pure (result == 28 && count == 1, count)
```

[Полный исходник](examples/haskell_comparision/source/haskell/V03.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Checker принимает произвольный кандидат, внедряет read, проверяет результат 28 и ровно одно чтение. Good: True/1, biased: False/1, readsTwice: False/2. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 308 | 25 |
| LMX — функциональный | <span style="color:#176233"><u>298</u></span> | 23 |
| Haskell | 459 | 14 |

<a id="v04"></a>
### V04. Distinguish a named failure from a numeric result

## Общий договор

Распознать именно именованную ошибку NoSample; обычный числовой ноль ошибкой не считается.

**Сопоставимость: полная пара.** NoSample — отдельный тип Exception. catch обрабатывает только этот тип; zero успешно возвращает 0 и checker возвращает 0. Другая ошибка не поглощается. В сравнении показаны объявления исключения, throwIO и весь обработчик, без ручного сравнения строк имени ошибки.

## LMX — общая минимальная форма обоих стилей

Именованный catch отличает NoSample от нормального нулевого результата. Его минимальная прямая форма общая; универсальное recover изменило бы границу типов/ошибок.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
UnavailableSensor:
    return: int
    read:
        throws: NoSample
        throw: NoSample()
    zero:
        return: 0

FailureCheck:
    @: candidate
    return: int
    check:
        candidate()
        return: 0
        catch: NoSample ()
            return: 1
```

[Полный исходник](examples/haskell_comparision/source/lmx/V04.lm3)

## Haskell

```haskell
module V04 where

import Control.Exception (Exception, catch, throwIO)

data NoSample = NoSample deriving Show
instance Exception NoSample

unavailable, zero :: IO Int
unavailable = throwIO NoSample
zero = pure 0

check :: IO Int -> IO Int
check candidate = (candidate >> pure 0) `catch` (\NoSample -> pure 1)
```

[Полный исходник](examples/haskell_comparision/source/haskell/V04.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Распознать именно именованную ошибку NoSample; обычный числовой ноль ошибкой не считается. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Control.Exception](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Control-Exception.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | <span style="color:#176233"><u>160</u></span> | 15 |
| LMX — функциональный | <span style="color:#176233"><u>160</u></span> | 15 |
| Haskell | 257 | 9 |

<a id="v05"></a>
### V05. Command/read integration check and fault modes

## Общий договор

Два обязательных цикла set(1),observe,set(0),observe; при fault=0/1/2 ответы True/False/False. Всегда две записи, два чтения, trace=1202.

**Сопоставимость: полная пара.** Device хранит две произвольные операции. Общая cycleDevice выполняет set и observe; check сначала исполняет оба IO-цикла, затем применяет && к полученным Bool. Поэтому ошибка первого сравнения не отменяет выключение. State позволяет проверить commanded=0 и sensed=0/0/1. Сравнивается этот локальный контракт устройства; внутренние parent-адреса LMX не объявлены Haskell-адресами.

## LMX — общая минимальная форма обоих стилей

Оба цикла set/observe должны выполняться безусловно, в том числе после неуспешного первого. Замена на короткое замыкание пропустила бы off. Общие mark/cycle и обязательные эффекты сохраняются.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Indicator:
    int: command
    int: fault 0
    int: commanded 0
    int: sensed 0
    int: writes 0
    int: reads 0
    int: trace 0
    return: int
    mark:
        node\trace := node\trace * 10 + command
        return: 1
    set:
        node\commanded := command
        node\writes += 1
        mark()
        if: node\fault = 0
            node\sensed := command
        if: node\fault = 1
            node\sensed := 0
        if: node\fault = 2
            node\sensed := 1
        return: 1
    observe:
        node\reads += 1
        mark(2)
        return: node\sensed

Commissioning:
    @: candidate
    int: command
    return: int
    cycle:
        int: ack candidate\set(command := command)
        int: seen candidate\observe()
        return: ack = 1 && seen = command
    check:
        int: on cycle(command := 1)
        int: off cycle(command := 0)
        return: on && off
```

[Полный исходник](examples/haskell_comparision/source/lmx/V05.lm3)

## Haskell

```haskell
module V05 where

import Prelude hiding (reads)
import Data.IORef (IORef, newIORef, readIORef, modifyIORef')

data State = State
  { commanded :: Int, sensed :: Int, writes :: Int, reads :: Int, trace :: Int }
  deriving (Eq, Show)
data Device = Device { set :: Int -> IO Int, observe :: IO Int }

makeDevice :: Int -> IO (Device, IORef State)
makeDevice fault = do
  state <- newIORef (State 0 0 0 0 0)
  let mark event = modifyIORef' state (\s -> s { trace = trace s * 10 + event })
      setCommand command = do
        modifyIORef' state (\s -> s { commanded = command, writes = writes s + 1,
          sensed = case fault of { 0 -> command; 1 -> 0; 2 -> 1; _ -> sensed s } })
        mark command
        pure 1
      readSensor = do
        modifyIORef' state (\s -> s { reads = reads s + 1 })
        mark 2
        sensed <$> readIORef state
  pure (Device setCommand readSensor, state)

cycleDevice :: Device -> Int -> IO Bool
cycleDevice candidate command = do
  ack <- set candidate command
  seen <- observe candidate
  pure (ack == 1 && seen == command)

check :: Device -> IO Bool
check candidate = do
  on <- cycleDevice candidate 1
  off <- cycleDevice candidate 0
  pure (on && off)
```

[Полный исходник](examples/haskell_comparision/source/haskell/V05.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Два обязательных цикла set(1),observe,set(0),observe; при fault=0/1/2 ответы True/False/False. Всегда две записи, два чтения, trace=1202. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | <span style="color:#176233"><u>547</u></span> | 39 |
| LMX — функциональный | <span style="color:#176233"><u>547</u></span> | 39 |
| Haskell | 885 | 31 |

<a id="m01"></a>
### M01. Serial state updates at one Message owner

## Общий договор

Один владелец последовательно принимает два запроса +4 и +9 от разных отправителей. После обоих ответов чтение даёт 13 при любом порядке поступления.

**Сопоставимость: полная пара.** Chan и MVar — реальные средства base. В сравниваемом модуле целиком показан service loop, включая завершение; запуск потоков и проверка ответов находятся в одинаково исключённом из размера внешнем harness. Проверяются оба допустимых набора промежуточных ответов. HTTP и распределённая доставка не входят в эту локальную пару.

## LMX — общая минимальная форма обоих стилей

Сериализованное изменение состояния одного Message-owner — сам договор. Одна запись и вызов общего read являются минимальной формой в обоих стилях.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Counter:
    int: value 0
    int: delta
    return: int
    add:
        node\value += delta
        return: read()
    read:
        return: node\value
```

[Полный исходник](examples/haskell_comparision/source/lmx/M01.lm3)

## Haskell

```haskell
module M01 where

import Control.Concurrent (MVar, putMVar)
import Control.Concurrent.Chan (Chan, readChan)

data CounterRequest = AddBy Int (MVar Int) | ReadValue (MVar Int) | Stop (MVar ())

counterLoop :: Chan CounterRequest -> Int -> IO ()
counterLoop inbox value = do
  request <- readChan inbox
  case request of
    AddBy delta reply -> do
      let next = value + delta
      next `seq` putMVar reply next
      counterLoop inbox next
    ReadValue reply -> putMVar reply value >> counterLoop inbox value
    Stop ack -> putMVar ack ()
```

[Полный исходник](examples/haskell_comparision/source/haskell/M01.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Один владелец последовательно принимает два запроса +4 и +9 от разных отправителей. После обоих ответов чтение даёт 13 при любом порядке поступления. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Control.Concurrent.Chan](https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/Control-Concurrent-Chan.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | <span style="color:#176233"><u>93</u></span> | 9 |
| LMX — функциональный | <span style="color:#176233"><u>93</u></span> | 9 |
| Haskell | 425 | 14 |

<a id="m05"></a>
### M05. Void Message procedure without a fabricated reply

## Общий договор

Процедура set сохраняет состояние 1 и не имеет контракта прикладного ответа. Отсутствие результата не должно порождать фиктивный ACK.

**Сопоставимость: аналогия.** lampLoop читает команды без поля для reply и вызывает IO () setter. Nothing завершает внешний тестовый worker. Harness ожидает завершение потока отдельно; эта синхронизация не является ответом на set. Фикстура действительно наблюдает state=1. Отсутствие прикладного reply выражено типом и телом worker; HTTP/Message-доставку LMX и её счётчики этот локальный Haskell-код не исполняет.

## LMX — общая минимальная форма обоих стилей

Единственная операция — void-процедура Message с записью состояния и без выдуманного reply. Обе формы совпадают; возвращаемое значение не добавляется.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Lamp:
    int: state 0
    int: command
    set:
        node\state := command
```

[Полный исходник](examples/haskell_comparision/source/lmx/M05.lm3)

## Haskell

```haskell
module M05 where

import Control.Concurrent.Chan (Chan, readChan)
import Data.IORef (IORef, writeIORef)

set :: IORef Int -> Int -> IO ()
set = writeIORef

lampLoop :: Chan (Maybe Int) -> IORef Int -> IO ()
lampLoop inbox state = do
  request <- readChan inbox
  case request of
    Just command -> set state command >> lampLoop inbox state
    Nothing -> pure ()
```

[Полный исходник](examples/haskell_comparision/source/haskell/M05.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Процедура set сохраняет состояние 1 и не имеет контракта прикладного ответа. Отсутствие результата не должно порождать фиктивный ACK. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](examples/haskell_comparision/validation/fixtures.json), [исполнимый Haskell harness](examples/haskell_comparision/validation/Main.hs), [команда проверки](examples/haskell_comparision/README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html); [base: Control.Concurrent.Chan](https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/Control-Concurrent-Chan.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 49 | 5 |
| LMX — функциональный | 49 | 5 |
| Haskell | 289 | 11 |

## Дополнительные главы и пояснения к примерам LMX

Эти главы сохраняют все 18 дополнительных фикстур, общие правила, навигацию и пояснения исходного руководства. Они не добавляются к 96 клиентским договорам четырёх наборов examples; вместе с четырьмя функциональными клиентами 082–085 и девятью сценариями групп 10–11 сравнение охватывает 109 договоров и 218 полных LMX-форм. Полные сравниваемые листинги публикуются в основном руководстве; одинаковые тела здесь повторно не приводятся.


Редакция: 23 ноября 2026 года. Дополнительные главы исходного руководства сохранены и согласованы с текущей нормой. Для Михаила и проверки реализации Fable.

Здесь собраны заново записанные примеры из обсуждения: функции высшего порядка, `makeAdder`, варианты `add5`, композиция, отложенное вычисление, состояние, обобщённость, код как граф, операнды, массивы, `satisfies`/`test`/`catch`, mock и интеграционная проверка, Message и обмен результатами. В конце — соответствие всем 23 шаблонам проектирования и прежнему регрессионному корпусу.

Это изложение текущей редакции языка. В частности, здесь уже действуют `copy` для одного принятого источника, потоковые результаты `copy`/`merge`/`import`, обычные CODE-аргументы этих трёх ресиверов и сохранение исходного графа. Старые формы с исполняемым `fn`, одноисточниковым копированием под именем `merge` и неявным захватом локального кадра не переносятся в новые листинги.

**Как читать проверки.** Числа после примеров — ожидаемые результаты, выведенные из действующих правил, для запуска Fable. Это не журнал исполнения LMX или GHC. Листинги с пометкой «самостоятельный пример» имеют все показанные пользовательские определения; ядро и явно оговорённый профиль предоставляет обычная среда. «Сценарий стенда» задаёт конкретные исходные данные, действия и проверяемый результат там, где проверяется физическая идентичность, транспорт или окружение Message. Такая запись не вводит новый синтаксис языка.

**Правило двух форм.** Каждый сравниваемый функциональный клиент имеет полные процедурную и функциональную LMX-формы одного наблюдаемого договора. Обе участвуют в сравнении, даже если одна длиннее. При обоснованной одинаковой минимальной форме хранится один исходник с двумя равными записями метрик. Локальные helpers входят в полный размер; общие библиотечные тела и зависимости не размножаются по стилям. Обёртка FxCallFailure не считается равнозначной распространению исходного именованного отказа. Haskell-клиенты используют настоящие библиотеки и обычные операции языка.

**Throws и длина кода.** На мой взгляд, явные списки ошибок — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий Throws и `throws: copy(Throws)` сохраняют эту ясность. При копировании договора выбирается фактически вызываемый метод либо явное конечное объединение применимых ветвей. Обе формы считаются полностью: заголовки, все имена ошибок, ссылки copy, вспомогательные методы и обработчики. Аргументы Throws из статистики не удаляются. В PDF/XLSX зелёный фон и подчёркивание числа получают все равные минимумы сопоставимой строки; неполная аналогия победителя не получает.

## Навигация

| Раздел | Что проверяется |
| --- | --- |
| [Основа](#basis) | Структура, роли CODE/DATA, namespace, вызов и именованные сигнатуры |
| [Haskell → LMX](#haskell-to-lmx) | `apply`, `makeAdder`, default, композиция, отложенность, состояние, обобщённость |
| [LMX → Haskell](#lmx-to-haskell) | Графовая композиция, потоки, импорт, редактирование кода, собственные операнды |
| [Массивы](#arrays) | Общие слоты, числовое хранение, индексация, рост, операции |
| [Проверки](#validation) | Пригодность, валидатор строк, mock, `catch`, самопроверка устройства |
| [Message](#messages) | Владелец состояния, fan-out, время, доставка, контексты, перенос владения |
| [Все 23 шаблона](#patterns) | Точные входы, результаты и место полного листинга |
| [Карта покрытия](#coverage) | Связь с английским корпусом и минимальная последовательность проверки |


<a id="basis"></a>
## 1. На чём построены примеры

### 1.1. Источники и приоритет

Основная норма — [семантика](../LMX_semantics.en.md), [грамматика](../LMX_grammar.en.md) и [L2](../L2_spec_en.md). Правила о полном графе, `uninit` и присваивании графу — в разделах [представление программы](../LMX_semantics.en.md#program-representation), [`uninit` без полезной нагрузки](../LMX_semantics.en.md#uninit-zero-payload) и [присваивание в граф](../LMX_semantics.en.md#graph-fragment-assignment); они имеют приоритет в этих вопросах. Правила потоков полей import/copy/merge — в разделе [композиция](../LMX_semantics.en.md#composition). Все принятые дополнения включены в эти документы и не образуют набора альтернативных версий.

Упоминания Haskell опираются на [Haskell 2010 Report: выражения](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html), [типы и объявления](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html), [I/O](https://www.haskell.org/onlinereport/haskell2010/haskellch7.html) и [Data.Array](https://www.haskell.org/onlinereport/haskell2010/haskellch14.html). Примеры ниже написаны для этого сравнения. Haskell-код показывает наблюдаемое поведение; он не объявляется представлением внутреннего устройства LMX.

### 1.2. Шесть правил, которые существенно меняют чтение

| Запись или понятие | Текущее значение |
| --- | --- |
| `Context: ... method: ...` в DATA | `method` — обычная Structure. При её вызове DATA берётся из её фактического `parent`, здесь `Context`; та же головная форма в CODE является обычным вызовом |
| `Unary :: (int: x; return: int)` | Именованное описание позиционной сигнатуры; исполняемого тела здесь нет |
| `@: p Context\method` | Ссылка на существующую Structure без вызова; `p(...)` — отдельный вызов |
| `copy(A)` / `merge(A B)` | Потоки скопированных / объединённых полей. Один структурный результат записывается `(copy(A))` / `(merge(A B))` |
| Свободное `x` / `node\x` | У свободного имени участвует динамическое связывание. `node\` явно выбирает лексический источник; это не «подняться на одного родителя» |
| Присваивание локальному месту | Меняет значение текущей активации. Оно не заменяет своим результатом исходный инициализатор и не создаёт новое поле |

Основание: [вызовы и сигнатуры](../LMX_semantics.en.md#callables), [связывание](../LMX_semantics.en.md#binding-places), [активации](../LMX_semantics.en.md#call-frame-20261115), [потоки](../LMX_semantics.en.md#composition).

### 1.3. Почему здесь по-прежнему один граф

Чистый граф полностью отражает написанную программу: ресиверы, выражения, вложенные структуры, объявления, границы групп и конечные примитивные листья. Примитивный лист уже лежит в своём виде `{type value}` по адресу, на который указывает ячейка структуры `Lmx`. `for`, `if`, `merge`, `copy` и `import` сохраняются как написанные ресиверы вместе со своими аргументами. Их выполнение не заменяет эти записи вычисленными результатами.

Прочтение графа создаёт текущие значения и связи в namespace. Например, `int: i findValue()` сохраняет вычисляемое объявление; присваивание текущему `i` не превращает его исходный вызов в число. У неинициализированного примитива `{uninit_int}` размер value равен нулю: будущей ячейки `int` в нём нет. Явное присваивание графу заменяет выбранный фрагмент новым — например, `{uninit_int}` на `{int 5}`. Таким же способом можно заменить структуры, содержащие исполняемые ресиверы; для требуемого обновления машинного исполнения используется описанная компиляция и граница `endturn`. См. [полный граф](../LMX_semantics.en.md#program-representation), [`uninit` без полезной нагрузки](../LMX_semantics.en.md#uninit-zero-payload), [присваивание в граф](../LMX_semantics.en.md#graph-fragment-assignment) и R09–R10 ниже.

Namespace не требует ещё одной постоянной Structure со спрятанными полями программы. Это механизм текущего прочтения и связывания; native-исполнитель может держать обычные локальные значения в своём кадре и регистрах. Таким образом сохраняются и полный интерпретируемый код, и обычные локальные переменные, и возможность компиляции. Удаление протокола `load`/`dirty`/`flush` не означает повторного вычисления уже полученного локального значения при каждом чтении. См. [активации](../LMX_semantics.en.md#call-frame-20261115) и [действующее правило кадра вызова](../LMX_semantics.en.md#call-frame-20261115).

Других скрытых частей программы к этому не добавляется. `parent` и `length` чистого графа определяются логически из исходника; содержимое структуры `Lmx` лежит в массиве указателей. Рядом находится бинарник с откомпилированными нативными методами — в нём только методы. R0 представляет собой обычный C-метод с **локальным указателем на граф R0**. Интерпретируемое исполнение тоже работает с бинарником и имеет бинарный R0. Это устройство не требует скрытых данных программы в C, отдельного callable-графа или иной модели корня для интерпретатора. [Основание](../LMX_semantics.en.md#graph-and-methods-binary).

**Удаление рабочего графа — требование № 1.** Оно относится и к устройству реализации: нельзя восстановить второй граф программы под именем namespace, развёртки, временной копии исполняемого тела или скрытого набора данных. Локальное значение в кадре не требует копии исходного узла; временность второй копии программы тоже не делает её допустимой. Явный `copy`, написанный самим приложением, сохраняет свой обычный смысл и не оправдывает автоматическое создание рабочего графа на каждом входе. [Основание](../LMX_semantics.en.md#no-working-graph).

Например, `private:` уже присутствует в чистом графе. Интерпретатор определяет его действие по этой записи, транслятор учитывает её в генерируемом методе. Отдельный граф меток `private` в бинарнике был бы возвращением рабочего графа. Полнота исходного графа проверяется в том числе этим простым случаем. [Основание](../LMX_semantics.en.md#private-without-marked-graph).

Программа всегда начинает выполнение с R0 как обычного L3 Thread под родительской заглушкой, без DATA и пользовательских actuals. Пропускается только отсутствующий входной проход; локальные переменные, произвольные обычные вызовы, диспетчеризация и выходы сохраняются. Заглушка может отправить свои значения корню обычным сообщением. Именованные вызовы в пояснениях выполняются уже запущенным корнем или обработчиком и не заменяют startup. Фрагмент DATA получает свою роль только от существующего принимающего договора, без отдельного DATA-load/Main профиля. [Норма запуска](../LMX_semantics.en.md#root-entry).

В листингах пустая физическая строка завершает открытые блоки до корня текущего документа. Внутри продолжающейся структуры используются допустимые отступы и, при необходимости, `---`. Полнота показанных пользовательских определений не превращает фрагмент DATA в самостоятельный альтернативный способ запуска программы.


<a id="haskell-to-lmx"></a>
## 2. Haskell → LMX


<a id="h10"></a>
### H10. Обобщённость и стабильные типовые связи

Haskell:

```haskell
identity :: a -> a
identity x = x

double :: Num a => a -> a
double x = x + x
```
Здесь `a` — переменная полиморфного типа; отдельные употребления могут получать разные допустимые типы. У LMX структурная обобщённость часто означает, что потребитель требует только используемые им поля и операции. Отдельное символическое имя типа, если оно используется для связи нескольких позиций, фиксируется **на Message**, а не заново на каждом вызове. Это разные правила, и перевод `a -> a` одной строкой без контекста был бы неточным. [Haskell: типы](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html); [LMX: контекст Message](../LMX_semantics.en.md#conversion-context).

Конкретный сценарий стенда:

| Подготовка | Проверка |
| --- | --- |
| Message A явно получает связь `a → int` | Все входные и выходные употребления `a` в A используют эту связь |
| Два вызова в A пытаются трактовать `a` по-разному | Второй вызов не создаёт независимую новую инстанциацию `a` |
| Message B явно получает `a → char[]` | B имеет свою согласованную связь |
| В B не передали таблицу A | Родство или доставка письма не устанавливают её автоматически |

Для структурного потребителя, которому нужен только `x`, кандидат с полями `x, note, extra` допустим при соблюдении остальных требований. Если же явно передана полная модель с `x` и `check`, то наличие обоих требований обязательно, даже когда ближайшее тело читает лишь `x`. Физический порядок полей кандидата может отличаться: строится соответствие, а не копия в «правильном» порядке. Это T01/T03/T04/T07 английского корпуса.


<a id="h11"></a>
### H11. Обратный адаптер: `int → string → int`

Из старого обсуждения сохраняем задачу: вызвать действие над строкой через потребителя числа, если текущий контекст явно допускает нужные преобразования.

В Haskell маршрут виден в программе:

```haskell
appendOne :: String -> String
appendOne s = s ++ "1"

adapted :: Int -> Int
adapted = read . appendOne . show
-- adapted 10 == 101
```
Сценарий LMX: потребитель передаёт `int 10`; кандидат принимает строку, добавляет символ `1` и возвращает строку; результат потребителю нужен как `int`. В контексте Message заданы обе конкретные конверсии: десятичное число в текст и текст в число. Ожидается **101**. `satisfies` проверяет доступность и пригодность маршрутов без их исполнения; фактическое потребление исполняет каждую нужную конверсию отдельно.

Контрпримеры обязательны: нет обратной конверсии — нет скрытого поиска по процессу; результат `"10x"` — ошибка формата; значение за диапазоном назначения — ошибка диапазона. Этот пример не означает, что произвольные отличающиеся контракты именованных сигнатур всегда взаимозаменяемы: сравнение конкретной сигнатуры и разрешённые конверсии подчиняются текущему требованию потребителя. [Основание](../LMX_semantics.en.md#descriptions), [конверсии при потреблении](../LMX_semantics.en.md#conversion-context).


<a id="h12"></a>
### H12. Варианты данных, чистота и эффекты

Haskell может выразить закрытые варианты непосредственно:

```haskell
data Event = Sample Int | Finished

eventValue :: Event -> Int
eventValue (Sample x) = x
eventValue Finished = 0
```
В LMX описания вариантов можно организовать обычными структурами и потребителями. Если профиль выбирает явные поля `kind` и `value`, он обязан проверить допустимые сочетания: само наличие двух числовых полей не устанавливает инвариант варианта. Если выбирает разные структурные требования и диспетчеризацию по ним, проверяются именно эти требования. Не следует называть любую пару полей автоматически алгебраическим типом Haskell; не следует и добавлять новый встроенный `enum` только для этого примера.

Аналогично, наличие `return: int` не доказывает чистоту тела. Оно может читать устройство или менять явно доступное состояние. Для чистого вычисления LMX применяет выбранный pure-профиль с допустимыми операциями; для эффекта — обычные правила действий и владения. В Haskell порядок I/O выражается композициями действий типа `IO a`. Эти контракты позволяют решать сходные задачи, но не являются одним и тем же правилом типизации. [LMX: чистые профили](../LMX_semantics.en.md#mathematics), [Haskell: I/O](https://www.haskell.org/onlinereport/haskell2010/haskellch7.html).

Действие LMX без описания результата не обязано возвращать скрытый `unit` или ACK. Это особенно заметно в Message: обычный процедурный вызов не становится запросом, который должен дождаться отсутствующего ответа.


<a id="lmx-to-haskell"></a>
## 3. Обратные аналоги: начать с возможности LMX

Здесь исходная задача задаётся LMX: взять структуру программы, прочитать её, скопировать, объединить, передать или исполнить. Затем рассматривается, как выразить ту же задачу средствами Haskell. Совпадение числового результата само по себе ещё не воспроизводит доступность графа и его связей.


<a id="r05"></a>
### R05. Один интерпретируемый граф и native-реализация

Сценарий стенда: метод получает `x=7` и имеет тело `return: x + 1`. Ожидаемый результат **8**. Создать копию с тем же телом и корректными скопированными данными — результат также **8**; пригодная reusable native-связь сохраняется по общему контракту, само копирование не запускает компилятор и не регистрирует новую реализацию автоматически.

Затем организованно изменить тело на `x + 3`, выполнить явную компиляцию/обновление соответствующей единицы и перейти через `endturn`. Новый вход должен дать **10**. Обычная запись в граф не заменяет этот протокол автоматической инвалидизацией или dirty-наблюдением.

| Вызывающий → вызываемый | Что сравнить после нужной подготовки |
| --- | --- |
| Интерпретатор → интерпретатор | Значение, логические места, объявленные выходы |
| Интерпретатор → native | Те же наблюдения; вызов использует native при наличии пригодной записи |
| Native → интерпретатор | Общий контракт аргументов и локалей при переходе |
| Native → native | Прямой машинный путь не добавляет другой семантики |

Явное чтение графа и его интерпретация видят выполненную запись сразу. Обновление нативной реализации имеет отдельную границу: старая пригодная машинная реализация не заменяется автоматически после записи в граф, а новый native-вход проверяется после явной компиляции и endturn. В чистом графе остаётся полное тело для интерпретации и последующей генерации кода.

Это также отвечает на вопрос о «компилируемости»: генерация C с последующей машинной компиляцией остаётся компиляцией программы. Способ получения машинного кода надо отличать от наличия исходного графа, выбора пути конкретного вызова и момента явного обновления. Здесь сравниваются именно эти три свойства. [Основание](../LMX_semantics.en.md#explicit-compilation), [L2: реализации вызовов](../L2_spec_en.md).


<a id="r06"></a>
### R06. Общая цель и цикл внутри копии

[R06a](#r06a) показывает общую цель двух ссылок; полный листинг находится в основном руководстве.

<!-- example: R06a -->

Результат **2107**. Две ссылки в результате указывают на одну соответствующую копию узла; исходный изменяемый узел остаётся со значением `7`. Сохранение отношения «обе ссылки на одну цель» не означает сохранение физической ссылки на исходную изменяемую цель.

[R06b](#r06b) показывает цикл; полный листинг находится в основном руководстве.

<!-- example: R06b -->

Результат **83**. Цикл замыкается внутри копии и не вызывает бесконечного копирования. Явная внешняя группа, собравшая поток, — отдельная структура со своим дескриптором и своими ячейками. Поэтому запись идёт через `copied\self`: она выбирает именно копию `Ring`, содержащую цикл. Её поле меняется на `8`, а отдельная ячейка `copied\value` внешнего контейнера остаётся со значением `3`. Группа не выполняет ещё одно глубокое копирование и не переназначает лексические связи.

Отдельная проверка исключения: допустимая ветвь `independent: immutable` с требуемыми квалификациями может сохранить исходную физическую ссылку. Обычные изменяемые узлы, только `independent` или только `immutable` этого исключения не получают. Дополнительный `const` не отменяет уже выполненных условий. [Основание](../LMX_semantics.en.md#eternal), [общая карта](../LMX_semantics.en.md#composition).


Действующие полные формы R06 представлены в [R06a](#r06a) и [R06b](#r06b); одинаковые тела здесь повторно не приводятся.

<a id="r08"></a>
### R08. Сериализовать, восстановить и продолжить работу с графом

Сценарий стенда: взять комбинацию R04 и R06, добавить массив и сериализовать выбранный граф через `sys\toLmx`, затем восстановить через `sys\fromLmx`.

| Материал | После восстановления |
| --- | --- |
| Явно записанное хранимое значение `21` | Сохраняется `21` |
| Неизменённый вычисляемый инициализатор | Остаётся вычисляемой исходной формой |
| Две ссылки на один изменяемый узел | Обозначают одну восстановленную цель |
| Цикл | Замыкается в восстановленном графе |
| Массив | Сохраняет порядок, длину и тип элементов |
| Записи `import`, `copy`, `merge` и группы | Сохраняются как написанные формы, а не заменяются прежним результатом namespace |
| Локальное `value := 99` из завершённой активации R04 | Не подменяет исходное объявление |

Сравниваются значения и отношения идентичности, а не равенство числовых адресов между процессами. Для сохраняемых native-таблиц выбранного Thread используется отдельный предусмотренный контракт платформы и модулей. Файловый дескриптор или адрес временной C-переменной не становится переносимым ресурсом оттого, что его число попало в текст. [Основание](../LMX_semantics.en.md#source-codec).

Haskell-обратный аналог для показанного `Expr` — сериализация своего AST и повторная интерпретация. Сериализация произвольной функции вместе с её внутренностями — уже другая задача, не эквивалентная стандартному `show` над `Expr`.


<a id="r10"></a>
### R10. Все ресиверы видны в графе и доступны для замены

Для этого сценария не нужен второй язык описания AST. Используются уже написанные программы: H09 с `for`, V02 с `if`, R01 с `merge`, R02 с `copy` и R03 с `import`.

| Наблюдение | Ожидается |
| --- | --- |
| Построить граф без исполнения программы | Каждый написанный ресивер, его аргументы и вложенные структуры присутствуют |
| Найти конечный примитивный лист | Ячейка `Lmx` указывает на его `{type value}`; это часть того же исходного графа |
| Выполнить соответствующий пример | Обычное вычисление не стирает `for`/`if`/`merge`/`copy`/`import` и не подставляет результат на место исходной записи |
| Явно заменить выбранную структуру другим фрагментом | В графе находится именно замена; прежний вид ресивера не даёт ей особой защиты |
| Для изменённого исполняемого тела выполнить требуемую компиляцию и `endturn` | Следующий вход использует подготовленную новую реализацию |
| Проверить граф и полученный бинарник | Содержимое программы находится в полном графе; бинарник содержит нативные методы, а R0 использует локальный указатель на граф R0 |
| Выбрать интерпретируемое исполнение | Бинарник и бинарный R0 остаются; дополнительной скрытой модели программы не появляется |
| Проследить выполнение в интерпретаторе и native | Второй рабочий граф не строится, в том числе под именем namespace или временной копии тела |
| Проверить написанный `private:` | Оба исполнителя соблюдают правило по исходной записи; бинарник не содержит отдельного графа меток доступа |

Конкретный контроль результата уже задан в R05: тело `return: x + 1` при `x = 7` даёт **8**; после замены на `return: x + 3`, явной компиляции и границы `endturn` следующий вход даёт **10**. Для остальных ресиверов стенд меняет выбранный фрагмент на заведомо различимое допустимое выражение и проверяет его результат после того же предусмотренного обновления. Проверка должна читать фактический граф, а не реконструированный текст из другого скрытого представления.

Основание: [полнота исходного графа](../LMX_semantics.en.md#complete-source-graph), [замена исполняемых структур](../LMX_semantics.en.md#receiver-replacement), [компиляция и `endturn`](../LMX_semantics.en.md#explicit-compilation).


<a id="arrays"></a>
## 4. Массивы и структуры

Тип и все его постфиксы находятся слева от двоеточия: `Model@: p`, `int@: left`,
`Model[]: arr`, `int[]: values`. Явная квадратная инициализация допускает имя
либо безымянное значение: `Model[]: arr [Model Model]`, `Model[]: [Model Model]`,
`int[]: values [1 2 3]`, `int[]: [1 2 3]`. Сочетания ссылок и массивов сохраняют
порядок постфиксов и обычный тип элементов. `@: value expression` остаётся
объявлением общей ссылки на значение, а не способом записать тип после имени.
[Полные формы и различающие проверки](../TYPE_DECLARATION_FORMS.md).


<a id="a02"></a>
### A02. Числовой массив не превращается в массив указателей

Сценарий стенда: плотный `int[]` с элементами `10,20,30`; две обычные ссылки на этот массив. Записать `27` во второй элемент через первую ссылку — через вторую читается `27`, длина остаётся `3`. Переназначение первой локальной ссылки на другой массив не переназначает вторую.

Отдельное графовое копирование создаёт независимое backing: изменение копии не меняет исходные числовые элементы. Но никакое структурное представление не позволяет трактовать машинные числа `10,20,30` как физические адреса трёх полей. Общий дескриптор контейнера и общие операции длины не отменяют тип хранения элементов. [Основание](../LMX_semantics.en.md#arrays).

Haskell `Data.Array` из Report — неизменяемый массив: `(//)` возвращает новое значение с обновлениями. Для разделяемых изменяемых ячеек выбирается соответствующий механизм эффектов; это надо оговаривать, а не приписывать обычному неизменяемому массиву поведение LMX-ссылок.


<a id="a03"></a>
### A03. Прямоугольный массив: проверяется итоговый линейный индекс

Исходные данные: прямоугольный массив элементов `int` формы `2 × 3`, row-major значения `10,11,12,13,14,15`. Размеры/strides известны из описания; backing — единый прямоугольный блок.

| Доступ | Линейный индекс | Ожидается |
| --- | ---: | --- |
| `[0][0]` | 0 | `10` |
| `[1][0]` | 3 | `13` |
| `[0][3]` | 3 | `13`, тот же элемент |
| `[1][2]` | 5 | `15` |
| `[2][0]` | 6 | L3-отказ `interpreter` |
| Координаты с переполнением машинного расчёта индекса | Математически вне допустимого диапазона | Отказ; переполнение не возвращает индекс в разрешённый диапазон |

`length` здесь равно **6**, не `2`. Промежуточный `matrix[i]` не требует нового дескриптора строки. Массив ссылок на массивы — другая организация: каждый следующий доступ тогда идёт к реальному другому массиву.

Для Haskell `Array (Int,Int) Int` обычная проверка индекса выполняется относительно заданных границ индекса. Поэтому `[0][3] → [1][0]` из LMX нельзя автоматически переносить на Haskell-массив пар индексов. [LMX: индексация](../LMX_semantics.en.md#arrays); [Haskell: границы](https://www.haskell.org/onlinereport/haskell2010/haskellch14.html).


<a id="a04"></a>
### A04. Рост backing и сохранённая ссылка на элемент

Сценарий: длина массива `3`, удерживается L3-ссылка на элемент с индексом `1`. `sys\reserve` увеличивает capacity так, что backing перемещается. Дескриптор остаётся прежним; запись `27` через удерживаемую ссылку меняет элемент `1` нового backing. Сама операция reserve длину не меняет.

Затем `sys\resize` уменьшает длину до `1`. Удерживаемая ссылка на индекс `1` больше не обозначает допустимый элемент и должна получить обычный L3-отказ. Проверяются и чтение, и запись.

Такое поведение обеспечивается L3-ссылкой «дескриптор + индекс». Ранее полученный сырой L2-адрес в backing этим обещанием не охвачен. В одном тесте нельзя подменять один вид ссылки другим. Таблица capacity хранится по обычному контракту арены, без нового семейства `DynamicArray`. [Основание](../LMX_semantics.en.md#l3-array-reference).


<a id="a05"></a>
### A05. `map`, `filter`, `foldl`, `scanl` и математические операции

Конкретные входы для математического профиля LMX:

| Операция | Вход | Ожидаемый результат |
| --- | --- | --- |
| Чистый `map` удвоения | `1,2,3,4` | `2,4,6,8` |
| `filter` чётных | `1,2,3,4` | `2,4` |
| Библиотечный `foldl` суммы | Structure `(1;2;3;4)`, seed `0` | Запись результата `10` |
| Библиотечный `scanl` суммы | Structure `(1;2;3;4)`, seed `0` | Structure `(0;1;3;6;10)` — seed включён |
| Упорядоченная сумма математического `reduce` | `1,2,3,4`, identity `0` | `10` |
| Inclusive `scan` суммы | `1,2,3,4` | `1,3,6,10` |
| Поэлементное `*` | `1,2,3` и `4,5,6` | `4,10,18` |
| `dot` тех же векторов | `1,2,3` и `4,5,6` | `32` |
| `filter` без совпадений | `1,3`, чётность | Новый массив длины `0` |

`foldl` и `scanl` — общие операции текущего ядра с обычной и операндной формами. Показанный контейнер — обычная Structure, взаимозаменяемая с `@[]`; общий контракт также принимает допустимые обычные Arrays через их действительный тип элементов, без дополнительного `items`. `scanl` возвращает начальный seed и все промежуточные значения, поэтому не совпадает с прежним inclusive `scan` математического профиля: тот же ряд без seed указан отдельно. `reduce`/inclusive `scan` не переименовываются молча в другой контракт. Общая библиотека обходится последовательно; возможная векторизация математического профиля не обещает параллельного исполнения эффектных callback.

Haskell-аналоги на списках:

```haskell
-- map (*2) [1,2,3,4]                   == [2,4,6,8]
-- filter even [1,2,3,4]                == [2,4]
-- foldl (+) 0 [1,2,3,4]                == 10
-- scanl (+) 0 [1,2,3,4]                 == [0,1,3,6,10]
-- tail (scanl (+) 0 [1,2,3,4])          == [1,3,6,10]
-- zipWith (*) [1,2,3] [4,5,6]           == [4,10,18]
-- sum (zipWith (*) [1,2,3] [4,5,6])     == 32
```
Выбраны целые числа без переполнения, чтобы результат не зависел от порядка округления. Для вещественных reduce отдельно фиксируются порядок и числовой контекст. Чистый `map` допускает реализацию с векторизацией или параллельным вычислением без изменения результата; эффектный обход требует оговорённого порядка. Обычный `*` не становится матричным умножением. [Основание](../LMX_semantics.en.md#array-operations).


<a id="a06"></a>
### A06. Пустая структура, пустой поток, отсутствующее значение

Три теста должны различаться:

1. `copy(Empty)` — один допустимый источник и ноль выходных полей.
2. `(copy(Empty))` — одно структурное значение с нулём полей.
3. Неинициализированная ссылка или явно переданный `nil` — соответствующее состояние/значение ссылки, а не автоматически пустая структура.

У числа `0` также нет значения «аргумент не передали». Это уже проверено H04. Нельзя заменять эти случаи одним false-like состоянием ради удобства реализации. [Основание](../LMX_semantics.en.md#stream-or-group), T05/G07 английского корпуса.


<a id="validation"></a>
## 5. `satisfies`, `test`, `catch` и проверка настоящего кандидата


<a id="v01"></a>
### V01. Проверка интерфейса плюс проверка поведения

Вопрос из обсуждения «как лучше проверить пригодность, чем интерфейсом и тестами?» получает здесь конкретное разделение обязанностей:

| Этап | Пример того, что устанавливается | Чего для этого не выполняют |
| --- | --- | --- |
| Структурная проверка или проверка именованной сигнатуры | Кандидат допускает нужный вызов и соответствующие типы/выходы | Тело кандидата, вычисляемые default и конвертеры ради перебора кандидатов |
| Явно требуемый `test` потребителя | Конкретный вызов даёт нужное число, строку, отказ или обратную связь | Неизвестное будущее поведение не объявляется доказанным одним совпадением интерфейса |
| Рабочий вызов | Выполняется выбранная операция с её действительными аргументами | Не создаётся новый специальный «почтовый» или «тестовый» язык вызовов |

`test` принадлежит принимающему требованию/Consumer. Кандидат не может подставить вместо него свой более мягкий тест. Проверяющее действие получает настоящего кандидата; если нужны mock-зависимости, они передаются ему обычным способом, как в V03.

`test: operation Check\check` — связь обычного принимающего места и обычной проверяющей Structure. Её присутствие глубоко внутри непотреблённого DATA не запускает скрытый поиск тестов по дереву. При выполнении проверок `1` означает успех, `0` — отказ; после первого `0` последующие проверки не исполняются. Повторно встретить то же незавершённое допущение — не получить готовый успех рекурсии.

Фазы проверки реализации фиксируются отдельно:

| Сценарий | Наблюдение |
| --- | --- |
| Построить чистый граф с тестами | Ноль исполнений тел тестов на этом этапе |
| Достичь одного теста в предкомпиляционной интерпретаторной фазе | Одно исполнение; отказ препятствует приёмке сборки и последующей C-компиляции |
| Исполнить подготовленный native-вызов без явно написанного `satisfies` | Нет добавленной автоматической runtime-проверки `satisfies` |
| Достичь вызова в интерпретаторе | Используется общий `satisfies`, без предварительного обхода недостигнутых ветвей |
| Явно вызвать checker дважды | Два обычных вызова и их предусмотренные эффекты |
| Checker внутри интерпретаторной фазы вызывает пригодный native-метод | Обычный dispatch сохраняется; интерпретаторная внешняя фаза не превращает все вложенные вызовы в walker |

Тестирование интерпретатором само по себе не изолирует устройство и не откатывает эффекты. Ограниченность теста определяется его алгоритмом, явно предоставленными зависимостями и правами. [Основание](../LMX_semantics.en.md#admission), [контракт test](../LMX_semantics.en.md#test-receiver-contract).


<a id="messages"></a>
## 6. Message: те же вызовы в условиях владения и доставки

Message — изолированный граф с владением. Исполняющий объект создаётся как Thread; обычное письмо не превращается в поток автоматически. У исполняющего владельца одновременно активен не более чем один turn; разные владельцы могут работать параллельно. Наличие всех этих механизмов не означает отдельного OS-потока для каждого Message. [Основание](../LMX_semantics.en.md#messages).

В следующих сценариях **адреса владельцев и маршрут транспорта задаются стендом через существующий API**. Локальные тела показаны на LMX. Таблицы `ask/answer` описывают конкретные маршруты и наблюдения, не изобретают ещё один синтаксис почтовых адресов.


<a id="m02"></a>
### M02. `ask` и fan-out: три запроса не превращаются в девять вычислений

Пусть настоящий `getPixel(x,y)` у источника увеличивает счётчик вызовов и возвращает уникальный для `(x,y)` цвет. Каждый из трёх приёмников результата увеличивает свой счётчик и сохраняет полученные координаты/цвет по подготовленному маршруту.

| Настройка `post` | Исполнений `getPixel` | Исходных результатов | Доставок результатов |
| --- | ---: | ---: | ---: |
| 1 `ask`, 3 `answer` | 1 | 1 | 3 |
| 2 `ask`, 3 `answer` | 2 | 2 | 6 |
| 3 `ask`, 3 `answer` | 3 | 3 | 9 |

Конкретная серия: запросы Q1=`getPixel(1,10)`, Q2=`getPixel(2,20)`, Q3=`getPixel(3,30)`; ответы адресованы `Display`, `Archive`, `Inspector`. Стенд организует поступление ответов в порядке Q3, Q1, Q2 до их допуска в соответствующий inbox; уже принятую почту он не переставляет. Каждый маршрут должен получить три соответствующих результата с сохранением установленного FIFO-порядка, а исходный счётчик равен **3**.

Корреляция идёт по исходным письмам; пользователю не требуется добавлять номера ответов. Ряды `ask` и `answer` не сопоставляются по позиции. Подготовленные маршруты допускаются до отправки; при получении результата не начинается новый поиск «какой обработчик похож по типу». [Основание](../LMX_semantics.en.md#thread-message-api), [транспорт T10–T12](../LMX_semantics.en.md#thread-message-observations).


<a id="m03"></a>
### M03. `undelivered`, `unanswered` и `catch` обозначают разные события

Используем Q2 из M02 и независимые свежие запуски:

| Событие | Ожидаемый обработчик и данные | Проверка |
| --- | --- | --- |
| Письмо отказано до исполнения у получателя | `undelivered`, исходный адрес и уже сформированные `(2,20)` | `getPixel` для Q2 не исполнился |
| Вызов объявленно выбросил `axisOutOfBound` | Соответствующий `catch` и payload | Не подменять исключение нормальным цветом или доставочным отказом |
| Истёк срок ожидания | `unanswered`, исходные данные и состояние ожидания | Источник мог уже исполняться; его работа не отменяется автоматически |
| Ответ вычислен, но один маршрут доставки ответа отказан | Событие доставки этого ответа | Исходный успешный вызов не становится недоставленным запросом |

Другие Q1 и Q3 продолжают по своим явно заданным маршрутам. Отказ одного письма не задаёт скрытый общий abort или барьер всей группы. [Основание](../LMX_semantics.en.md#thread-message-api).


<a id="m04"></a>
### M04. Таймаут считается от отправки; аргументы не вычисляются заново

Подготовка Q2 исполняет `nextX()` и `nextY()` по одному разу, получая `(2,20)`. После отправки исходные локали отправителя меняются на `(99,99)`. Задана форма `timeout: ms: int: time 500`; путь настройки — `timeout\ms\time`, без дополнительного узла `int`.

Стенд удерживает ответ до **512 ms** после исходной отправки. Проверяются отдельно исходные аргументы `(2,20)`, неизменная настройка `timeout\ms\time = 500` и фактическое время, переданное обработчику `unanswered`. Истечение может быть обслужено уже после достижения `500 ms`; само удержание ответа до `512 ms` не предписывает точного времени запуска обработчика. В детерминированном варианте стенд впервые обслуживает это ожидание при `512 ms`, и тогда наблюдаемое время равно `512`, а настройка по-прежнему `500`. Счётчики производителей остаются по **1**. Подготовка описания до отправки не является началом этого интервала.

Обработчик только записывает диагностику. Затем приходит запоздавший результат. Он всё ещё проходит подготовленный маршрут ответа: логирование таймаута не отменило действие и не удалило ожидание автоматически. Если приложению нужна отмена, дедупликация или запрет позднего результата, это должно быть явно определено его протоколом. [Основание](../LMX_semantics.en.md#thread-message-api), T13/T15–T20 транспортного дополнения.


<a id="m06"></a>
### M06. Копирование, ссылка и передача владения

| Операция стенда | Проверяемое отношение |
| --- | --- |
| Передать обычную ссылку внутри допустимого владельца | Тот же объект; никакой скрытой независимой копии |
| Создать новый исполняющий Message из явно заданного шаблона | Отдельная арена и копии обычного изменяемого графа по общей карте |
| Передать явно допустимую eternal-ветвь | Сохранение ссылки только при выполнении общего квалификационного исключения |
| Передать storage неисполняемого письма принимающему владельцу | Адреса могут остаться прежними; ответственность освобождения переходит получателю |
| Перенести supervision работающего дочернего Thread | Меняется управляющий родитель; это не копирование и не усыновление остановленного storage |
| Сериализовать для другой машины | Переносимое описание связей; сырые локальные адреса не становятся удалёнными адресами |

Для копирования взять R06: общая цель внутри нового владельца остаётся общей копией, исходный изменяемый узел не разделяется. Для передачи storage проверить, что прежний владелец больше не освобождает переданные chunks. Операция приёма не меняет автоматически лексический `parent` принятого корня: прикладное присоединение задаётся явно.

Типовой контекст нового Message тоже передаётся явно, как H10/H11. Нельзя заодно скопировать весь живой контекст родителя «для удобства». [Основание](../LMX_semantics.en.md#delivery), [контекст](../LMX_semantics.en.md#conversion-context).


<a id="m07"></a>
### M07. Параллельность владельцев и последовательность одного владельца

Создать два исполняющих владельца A и B, каждому явно передать независимую копию Counter. Послать каждому свою серию приращений. Проверить:

1. У A никогда не пересекаются два активных turn; то же у B.
2. A и B могут продвигаться одновременно, не меняя чужой граф.
3. За один turn один владелец исполняется на одном OS-потоке; перенос между worker допустим между turns.
4. Режим отдельного OS-потока и пошаговое обслуживание родителем дают одинаковые допустимые значения и порядок уже принятой FIFO-почты.
5. Обычное получение письма как данных не запускает его содержимое; запуск отдельного дочернего Thread явный.

Это проверка runtime-модели. Отсутствие пользовательских mutex в таком приложении не означает отсутствия механизма координации доставки внутри runtime. [Основание](../LMX_semantics.en.md#messages), [общий mailbox L2](../L2_spec_en.md#mailbox).


<a id="m08"></a>
### M08. Граница turn: исходящие письма, сбой и завершение

Сценарий A: обработчик меняет своё хранимое поле на `5`, подготавливает исходящее письмо, затем завершается с отказом до успешной публикации. Ожидается: ещё не опубликованное письмо из staging не выдаётся получателю; уже выполненная запись `5` не откатывается автоматически.

Сценарий B: обработчик готовит финальное письмо и явно устанавливает `success := 1`. На успешной границе финальная исходящая почта публикуется по обычному правилу, а главный алгоритм не получает нового turn.

Сценарий C: mailbox пуст, но `success` не установлен. Пустая очередь не означает завершение background-работы. Дочерние участники обслуживаются через предусмотренный единственный `Thread.children`; ещё один глобальный реестр или отдельная очередь членства не нужны.

Сценарий D: ручной `receive` и протокольная обработка `post` конкурируют за одно письмо. Письмо может быть принято только одним маршрутом, поскольку используется один inbox и общий механизм владения. [Основание](../LMX_semantics.en.md#lifecycle), [публикация](../LMX_semantics.en.md#delivery), [post](../LMX_semantics.en.md#thread-message-api).


<a id="patterns"></a>
## 7. Все 23 ранее разобранных шаблона

Полные русские объяснения и листинги уже входят в архив. Здесь они сведены в одну карту с обычными вызовами сценариев после запуска R0 и результатами **показанных сравнительных программ**. Это позволяет проверять их вместе с новыми аналогиями.

| № и полный листинг | Вход LMX | Результат | Возможный приём для аналога на Haskell |
| --- | --- | ---: | --- |
| [01 Iterator](01_iterator_comparison.md) | `numbers\demo()` | 12 | Список/генератор и свёртка; H09 |
| [02 Strategy](02_strategy_comparison.md) | `strategy\demo()` | 25 | Передать функцию; H01 |
| [03 Factory Method](03_factory_method_node_prototype_comparison.md) | `add1\demo()` | 32 | Функция, создающая значение или замыкание; H03 |
| [04 Adapter](04_adapter_comparison.md) | `adapter\demo()` | 5 | Явная функция преобразования интерфейса; H11 |
| [05 Observer](05_observer_comparison.md) | `observer\demo()` | 11 | Список действий/получателей в выбранном эффектном контексте |
| [06 Decorator](06_decorator_comparison.md) | `transform\demo()` | 63 | Композиция/обёртка функции; H06 |
| [07 Command](07_command_comparison.md) | `commands\demo()` | 4 | Значения действий или явные преобразования состояния; H08 |
| [08 Template Method](08_template_method_comparison.md) | `pipeline\demo()` | 35 | Функция высшего порядка с переданными стадиями |
| [09 Visitor](09_visitor_comparison.md) | `Actions\demo()` | 12 | Сопоставление вариантов/переданная алгебра обхода; H12/R07 |
| [10 State](10_state_comparison.md) | `machine\demo()` | 1 | Явное состояние и функция перехода |
| [11 Chain of Responsibility](11_chain_of_responsibility_comparison.md) | `chain\demo()` | 5 | Последовательность обработчиков с результатом вроде `Maybe` |
| [12 Composite](12_composite_comparison.md) | `Pair\demo()` | 10 | Рекурсивный тип и рекурсивный потребитель |
| [13 Proxy](13_proxy_comparison.md) | `requests\demo()` | 8 | Функция-обёртка с явно выбранным хранением/кешем |
| [14 Facade](14_facade_comparison.md) | `checkout\demo()` | 39 | Функция, вызывающая нужные операции подсистем |
| [15 Builder](15_builder_comparison.md) | `Rectangle\demo()` | 22 | Последовательные преобразования записи |
| [16 Prototype](16_prototype_comparison.md) | `Point\demo()` | 153 | Обновление известного значения; для изменяемого графа явное копирование |
| [17 Memento](17_memento_comparison.md) | `Editor\demo()` | 59 | Сохранить прежнее значение состояния; графовые отношения — R06/R08 |
| [18 Bridge](18_bridge_comparison.md) | `bridge\demo()` | 45 | Независимо передать управляющую и исполнительную функции |
| [19 Singleton](19_singleton_comparison.md) | `Demo\run()` | 7 | Явно передать одну общую зависимость в нужный контекст |
| [20 Abstract Factory](20_abstract_factory_comparison.md) | `Client\demo()` | 33 | Запись согласованных фабричных функций |
| [21 Flyweight](21_flyweight_comparison.md) | `glyphs\drawing\demo()` | 81 | Разделять допустимые неизменяемые значения |
| [22 Mediator](22_mediator_comparison.md) | `Demo\run()` | 10 | Явный координирующий потребитель/владелец состояния; M01 |
| [23 Interpreter](23_interpreter_comparison.md) | `operands\example\demo()` | 20 | Явный AST и `eval`; R07 |

Это карта способов выразить задачу, а не утверждение, что Haskell обязан воспроизводить классы других языков. Проверка семантики должна сохранять границы конкретного сценария: число эффектов, место хранения и результат, а при работе с графом также его доступность и отношения идентичности.

В английском [регрессионном корпусе](LMX_regression_examples.to_fable.en.md#patterns) P01–P23 имеют **свои** тестовые данные и результаты. Например, основной Iterator выше даёт `12`, а отдельный P01 может задавать другой набор значений. Не следует заменять ожидаемые значения одной серии числами из другой только из-за одинакового названия шаблона.


<a id="coverage"></a>
## 8. Карта покрытия и порядок проверки

### 8.1. Где находится каждый обсуждавшийся вопрос

| Тема | Здесь | Подробные различающие варианты корпуса |
| --- | --- | --- |
| Ссылка на callable, `apply`, смена стратегии | H01–H02 | B-09–B-12, T02, P02 |
| `makeAdder`, возврат вложенного метода | H03 | G12, P03 |
| Default и явный `add5(1; y := 25)` | H04 | B-01 |
| Свободный динамический вход и `node\` | H05, H08 | B-02–B-06 |
| Композиция функций | H06 | P06, P08, P18 |
| Выражение, значение, отложенность, повтор эффектов | H07 | OP03–OP05, OP10–OP12 |
| Присваивание, CODE-локаль, отсутствие dirty-публикации | H08, R04 | B-07–B-08, G01–G02, N01 |
| Итератор с декларацией и генератор | H09 | D-01–D-03, P01 |
| Структурная обобщённость, типы и преобразования | H10–H12 | T01–T07 |
| Полная модель и малый используемый интерфейс | H02, H10, V01 | T03–T04 |
| Merge модели, добавление и замена поля | R01 | G05, P12, P20 |
| Поток, группа, W/E, пустой результат | R02, A06 | B-13, OP13–OP17, stream-варианты G05 |
| Импорт имён и сохранение DATA/parent | R03 | B-09, D-04 |
| Native, явная компиляция и граница turn | R05 | N01–N06 |
| Общая цель, цикл и eternal-исключение | R06 | G03–G06 |
| DSL, пользовательские операнды, приоритеты | R07, H07 | OP01–OP18, P23 |
| Сериализация текущего полного графа | R08 | G10–G11 |
| Нулевой payload `uninit`, локальная запись и замена графа | R09 | G13 |
| Сохранность и замена всех написанных ресиверов | R10, R05 | G13, N01–N06 |
| Structure/Array и сырые слоты | A01–A02 | G07 |
| Многомерный индекс и relocation | A03–A04 | G08–G09 |
| Математические операции массивов | A05 | Семантика §§18–19 |
| RegEx-подобная валидация | V02 | V01 |
| Mock, проверка числа вызовов | V03 | V02 |
| Ожидаемый отказ, соседний `catch` | V04 | V03 |
| Интеграционный тест устройства | V05 | V04 |
| Когда вызывается `test` | V01 | V05, Q01 |
| Message: целая операция у владельца | M01, M07 | M01, L3 §§24–25 |
| Fan-out, late reply, stored actuals | M02–M05 | M02–M03, transport T01–T26 |
| Перенос storage, создание Thread, завершение | M06–M08 | M04, L3 §§24–28 |

Дополнительные binding-проверки, которые важно не потерять за основными аналогиями:

- **Цепочка A → B → C.** Допустимый динамический источник остаётся достижимым, даже если B сам не читает имя. Это не превращает всякий транзитивно найденный источник в прозрачный alias: в B-04 retained fallback даёт C собственную рабочую копию и оставляет у A `5`; если B уже установил прозрачную связь, C пишет в то же место и у A получается `8`. Отдельное фиктивное объявление в каждом посреднике не требуется.
- **`private` в обе стороны.** Проверяются и недоступность источника для неявного связывания, и запрет динамической подмены защищённого принимающего места. Явные допустимые пути и явно переданные actuals сохраняют свой контракт.
- **Порядок actuals.** Выражения исполняются один раз в написанном порядке; именованная передача сопоставляет формалы, но не переставляет эффекты вычисления. Имена, совпавшие с ожидаемой позицией, и именованный переход к другой позиции проверяются раздельно.
- **Присваивание внутри actual.** Это обычная операция над выбранным местом активации, а не новое объявление или безусловно второй именованный аргумент. Приём готовой формы объявления имеет отдельный явно описанный контракт.
- **Обязательное значение.** `required` проверяет выбранное место после установленного связывания. Готовый `0`, отсутствие default и явный `nil` должны различаться.

### 8.2. Что лежит рядом с документом

В [examples/lmx](examples/README.ru.md) вынесены самостоятельные LMX-блоки из этого текста. Каждый fixture получает отдельный свежий контекст обычной запущенной программы; его указанный вызов выполняется после старта R0. Одинаковые имена вроде `Counter` или `Provider` не объединяются в один общий исходник.

В [expected_results.json](examples/expected_results.json) перечислены обычные вызовы сценариев, ожидаемые числа, отказы, счётчики и условия подготовки. JSON — данные для существующего стенда Fable, не новый runtime или формат программы LMX. Сценарии, которым нужен транспорт, адресная идентичность или типизированный массив, сохраняют явный статус fixture.

[Analogies.hs](examples/haskell_comparision/Analogies.hs) содержит Haskell-аналоги и проверки числовых результатов, AST, неизменяемого массива, mock, счётчика-владельца и fan-out. Его можно запускать из каталога `spec/patterns` распакованного комплекта командой:

```sh
runghc examples/haskell_comparision/Analogies.hs
```
Интерфейсы библиотечных примеров сверены с официальными [Control.Concurrent](https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/Control-Concurrent.html), [Chan](https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/Control-Concurrent-Chan.html) и [IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html). В этой редакционной проверке GHC не запускался.

### 8.3. Минимальная последовательность для Fable

1. Разобрать сохранённые исходные формы, группы, пустые строки и `---`; убедиться, что построение графа не исполняет источники `import/copy/merge`.
2. Пройти H01–H06 и R01–R03: именно они различают ссылку/вызов, фактический DATA, default, динамический источник, копию и поток.
3. Проверить H07–H09/R04 не только по числам, но и по количеству исполнений, месту записи и неизменности исходных форм.
4. Проверить типовой и структурный допуск, затем реальные checker-вызовы V01–V05; не смешивать их счётчики с фазой построения графа.
5. Пройти графовые/массивные fixtures R06/R08–R10/A01–A06: отдельные отрицательные тесты должны ловить shallow copy, лишнюю копию общей цели, выдуманный payload у `uninit`, порчу исходных ресиверов, неверную распаковку и старый backing.
6. Для подготовленных единиц сравнить предусмотренные native/interpreter пути и обновление после явной компиляции/`endturn`.
7. Пройти M01–M08, отдельно считая исходные исполнения, исходные ответы, доставки, события таймаута и явные изменения состояния.

Если устаревшая формулировка однозначно исправляется действующим требованием, её надо исправить. **Вопрос Михаилу нужен при явном противоречии действующих требований, для которого приоритет источников не определяет решение.** Ранее выделенный вопрос о физическом представлении `uninit` закрыт прямым уточнением автора и отражён в R09–R10. Результаты проверки документов приведены в [отчёте](LMX_consistency_review.ru.md). Ни один ожидаемый результат этого документа не следует выдавать за уже выполненный runtime-тест.

## Дополнительные пояснения к сравниваемым сценариям

Текущие листинги выше сохраняют обе полные стилевые записи. Пояснения ниже описывают наблюдаемые договоры; прежние решения о выборе единственного короткого варианта больше не применяются.


### Пояснения к H01


Прямое применение динамической ссылки chosen вызывает тот же выбранный метод без промежуточной библиотеки. Смена chosen не исполняет цель. Поля и методы Arithmetic, последовательность вызовов и результат1408 сохранены; искусственный аналог класса/статического делегата не вводится. Второй результат сразу входит в return: смена chosen и оба вызова остаются на своих местах.

**Ожидается:** ApplyProbe\run() → 1408 (14 и8).


Общий apply принимает готовую конечную последовательность actuals, включая Structure/`@[]` и плотный Array, с обычным доступом по действительному типу элементов. `args := (7)` передаёт контейнер целиком, без дополнительного items. Результат — запись с реальным типом; клиент явно читает её через разыменование. Число и типы аргументов не зашиты в библиотеку. Произвольный объявленный отказ целевой функции передаётся как FxCallFailure с исходным именем и payload внутри.

[Отдельное сравнение реализаций](examples/library_comparisons/h01_apply_comparision.md).

**Граница сравнения.** Haskell использует обычную аппликацию; LMX выбранный метод вызывает напрямую либо передаёт в generic apply. Оба пути сохраняют динамический выбор метода; тела реализации apply сравниваются отдельно.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [H01](#h01).


### Пояснения к H02


Именованное требование объявлено через PairOperation :: DATA. Публичное a обозначает первую позицию, которая у кандидата называется b; второй вызов использует собственные имена кандидата. Поэтому получаются27 и72. Старого объявления fn больше нет.

**Ожидается:** SignatureProbe\run() → 2772 (27 и72).


Конструктор `->` принимает полные TYPE-токены в едином порядке: входы, затем результат. Обычная форма — `` `->`(T0; T1; R) ``, общая операндная — `T0 -> T1 R`; `` `->`(R) `` описывает отсутствие входов. Это не прежнее размещение результата слева. Построенные публичные метки `p0/p1` отображаются на реальные позиции кандидата; тип токена как записи не превращает описываемый им вход в int. Отражение уже существующего callable выполняет `signature(operation := F)`.

В `T0 -> (T1 R)` справа остаётся один целый контейнер, а не два TYPE-аргумента. Группировщик сохраняет эту границу в плане для левого токена T0; адаптер применения передаёт один правый элемент и не раскрывает его повторно. В групповых случаях левый участок и правый поток сначала определяются по дереву, а затем адаптер отдельно упаковывает левый участок в один actual и правые элементы в массив ссылок. Прежние результаты для anonymous LEFT и единственной anonymous RIGHT — следствие этих фаз, а не самостоятельный проход раскрытия. P0 сохраняет исходные группы. Готовое значение в принимающей роли VALUE/TYPE/DATA не становится CODE автоматически. В Expression атом-ссылка по графу на Structure образует группу только вне роли операнда. Трансляция отклоняет неоднозначные чтения до эффектов. Для остальных достигнутых Structure действует правило имени и фактического parent. Для группового случая исходный parent сохраняется и вызов не вводится. Группировщик получает граф без скобок. `PairOperation :: (int: a; int: b; return: int)` имеет справа один DATA-контейнер; все аргументы `::` потребляются в DATA, а собственное действие ресивера объявляет имя. Полные правила конструктора и обеих форм приведены в [общих операциях](../GENERIC_OPERATIONS.md).

**Граница сравнения.** Контроль использует встроенную функциональную сигнатуру и позиционное применение. Name::DATA и -> описывают такое же семантическое требование; создание типового описания не скрывает вычисление значения или предметный алгоритм.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [H02](#h02).


### Пояснения к H03


Общий partial связывает K готовых actuals у callable с N входными позициями и возвращает обычный callable с оставшимися N−K позициями и точным исходным результатом. Требования, defaults, required/private и autofill оставшихся входов следуют реальным объявлениям источника; всем входам не приписываются автоматически новые required/private. K=0 и K=N допустимы; полный префикс даёт отложенный nullary-callable, не запускающий цель при создании. Примитив захватывается по значению, ссылка сохраняет идентичность цели. У полученного add5 публичный вход p0, а saved по-прежнему неизвестен. Исходный Addition не изменяется. Три вызова сохранены в прежнем порядке, промежуточные имена результата не требуются.

**Ожидается:** ClosureProbe\run() → 6101006 (6,101,6).


Процедурная форма явно сохраняет механизм копирования: CapturePrototype и Curry — обычные пользовательские структуры текущего языка. Фабрика копирует owner, сохраняет binary и first, возвращает вложенный метод. Состояние и идентичности не удалены ради размера. Здесь нет загрузки старого ядра или альтернативной библиотечной версии. Три вызова сохранены в прежнем порядке, промежуточные имена результата не требуются.

[Отдельное сравнение реализаций](examples/library_comparisons/h03_capture_comparision.md).

**Граница сравнения.** Haskell использует родную каррированную аппликацию (+) n, без самописного partial в клиенте. LMX использует core partial; сравнение обобщённых реализаций вынесено отдельно.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [H03](#h03).


### Пояснения к H04


Прямой merge меняет готовый default y в копии DATA, сохраняя его входную позицию. Поэтому1 даёт6, явный y=25 даёт26, y=0 даёт1, следующий вызов снова6. Это переопределяемый default, а не необратимо связанный префикс.

**Ожидается:** DefaultProbe\run() → 6260106 (6,26,1,6).

**Связь двух форм.** Обе текущие записи сохраняют прямой merge: процедурная явно хранит результаты четырёх вызовов, функциональная сразу собирает их в возвращаемое значение. `bindFields(Addition\add; (int: y 5))` — дополнительный общий способ объединить создание копии и выбор метода; для пояснения этой замены третья копия всей программы не нужна.

**Граница сравнения.** Обычный merge создаёт копию с готовым y=5; явные y=25 и y=0 заменяют default только в соответствующем вызове. Имена, четыре вызова и результат сохранены; тонкий bindFields описан одной заменой, без повторной программы.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [H04](#h04).


### Пояснения к H05


На свежем источнике результат — **2606**: динамический вариант получает `25`, лексический — скопированное `5`. Оригинал уже содержит `8`. `copy` не отключает динамический приоритет; `merge` также не вводит особого связывания.

У динамического метода `y` свободно, поэтому `dynamic(1; y := 25)` не превращается в допустимую явную передачу несуществующего формала. Оно может прийти обычным динамическим связыванием, но это другой механизм.

Удобная Haskell-модель такого динамического источника — явно передаваемое окружение `Env -> Int -> Int`; для лексического варианта — функция, созданная с конкретным `Env`. Это способ представить зависимость, а не утверждение, что Haskell сам использует неявное динамическое связывание. [Основание](../LMX_semantics.en.md#binding-caller-place).

Решение аудита: copy, изменение оригинала и две формы чтения оставлены рядом. Обёртка могла бы добавить вызывающий контекст и тем самым изменить именно проверяемое динамическое связывание; оператор не требуется.

Полные действующие листинги и обе стилевые метрики: [H05](#h05).


### Пояснения к H06


Функциональная форма выражает порядок стадий вложенными обычными вызовами; процедурная сохраняет промежуточные значения и явно выполняет следующие стадии. Обе сохраняют Functions.x, методы, их тела, число исполнений и порядок эффектов. Две известные стадии не требуют отдельного обхода; общие операции композиции и передачи значения остаются доступны в том же ядре.

**Ожидается:** CompositionProbe\run() → 910 (9 и10). Журнал эффектов: twice,next,next,twice.


`compose(outer := second; inner := first)` создаёт callable, сохраняя реальные входные договоры first и точный результат second. Построение не исполняет стадии; промежуточные типы могут различаться. `pipe(value; stages)` и его операндная форма `value pipe first second` выполняют другой договор: передают уже заданное значение через стадии и возвращают фактический конечный результат. `pipe` больше не является именем фабрики композиции. Эти общие реализации показаны отдельно от двух компактных клиентов H06.

[Отдельное сравнение реализаций](examples/library_comparisons/h06_pipe_comparision.md).

**Граница сравнения.** Haskell использует композицию (.) и Control.Monad.foldM для списка эффектных стадий. Две текущие LMX-формы используют обычные вызовы с явными промежуточными значениями либо вложенной записью. Общие compose и value pipe имеют отдельные реализации. Во всех сопоставимых вариантах сохраняются стадии, типы и порядок эффектов.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [H06](#h06).


### Пояснения к H07


Оба прежних операнда полностью показаны в этом же исходнике. PreparedOps дважды читает одно готовое значение; RawOps дважды исполняет occurrence через sys\eval. Все поля протокола left/right и режимы сохранены. Это локальные определения в том же текущем ядре, а не его старая версия. Общий заголовок получен из явно предоставленного fixture DATA-фрагмента sys\OPERANDS_TEMPLATE: copy сохраняет prepared-режим, merge меняет только PASS_ARGS_AS_IS на 1. Само структурное требование такого объекта не создаёт; [профиль](OPERAND_USAGE_PROFILE.md) показывает его определение. return:int остаётся собственным результатом операнда; шаблон не содержит return. Повторное sys\eval намеренно остаётся двумя исполнениями одного occurrence.

**Ожидается:** После сброса Meter\calls две prepared-активации дают2,4 при2 вызовах next; две raw-активации дают3,7 при4 вызовах next.


lazy создаёт типизированный nullary-callable и кеширует первый успешный результат. В каждом prepared создаётся новый delayed; первый delayed() исполняет next, второй читает сохранённое. В raw явно исполняются два обычных вызова. Числа и счётчики совпадают с проверяемым сценарием, но сама обработка raw-occurrences этим приёмом не проверяется. LazyCycle — объявленный отказ повторного входа. Состояние принадлежит одному Message.

[Отдельное сравнение реализаций](examples/library_comparisons/h07_evaluation_modes_comparision.md).

**Граница сравнения.** Полный смысл H07 включает реальные raw-occurrences и их исполнение через sys\eval, а не только итоговые числа. Lazy и два обычных вызова — полезный дополнительный приём того же ядра, но он не сохраняет raw-контракт; поэтому не подменяет ни одну из двух записей этого raw-сценария; здесь обоснована одна общая минимальная форма с двумя равными метриками. Haskell IO-аналог сравнивает эффекты и не выдаётся за доступ к LMX AST.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [H07](#h07).


### Пояснения к H08


`StateProbe\run(Own\step)` → **0**. Объявленный `Own.y` — собственное место вызова, первоначально заполненное копией `0`. `StateProbe\run(Free\step)` → **3**. У `Free\step` собственного `y` нет, и текущая норма разрешает прозрачную связь со свободным именем в непосредственном вызывающем контексте.

Это существенное изменение относительно раннего обсуждения, где любое внешнее имя трактовалось как локальная копия. Сейчас надо учитывать наличие собственного объявления. `node\y` дополнительно обозначает явный лексический доступ и имеет свой смысл.

У Haskell чистый переход состояния можно записать `step y = y + 3` и передать новое значение дальше. Действие с общей изменяемой ячейкой потребует явно выбранного механизма состояния, например `IORef` внутри `IO`. LMX допускает обе организации, но точное место записи определяется его правилами связывания.

Дополнительный отрицательный случай: внутри той же активации создать новое `int: y` без RHS во вложенном inline-блоке. Оно затеняет внешнее `y`, но не создаёт нового caller; при отсутствии `y` у реального caller новое место остаётся `uninit:int`. `required: y` должно обнаружить это, внешнее значение не меняется. [Основание](../LMX_semantics.en.md#shadowing-levels).

Тело `y += 3` записано один раз в `Free\step`. При вызове через `Own\step` оно получает место `y` текущей активации Own, уже заполненное копией значения runner; запись остаётся внутри Own. При прямом вызове оно получает место самого runner. Единый `StateProbe\run` показывает оба случая без повторения проверочного тела. Отрицательная проверка inline-shadowing сохранена.

Полные действующие листинги и обе стилевые метрики: [H08](#h08).


### Пояснения к H09

Haskell-выражения `sum (map (*2) [1,2,3])` и `sum (take 3 (map (*2) [1..]))` дают **12**. Чтобы честно показать механизм пользовательской библиотеки, рядом теперь приведены [оба полных цикла LMX/Haskell](examples/library_comparisons/h09_iterator_comparision.md), а не только готовый список.

[H09.lm3](examples/haskell_comparision/source/lmx/H09.lm3) снова содержит полный короткий `Cycles\iterate` из 22-Nov. Декларация и связанное тело исполняются обычными вызовами; это прямо описанный авторский пример [текущей нормы](../LMX_semantics.en.md#declaration-arguments). `catch: Stop` относится только к источнику; отказ тела не перехватывается и не переименовывается. Отдельный adapter `iterateUntilStop` с `FxCallFailure` остаётся [показан рядом](examples/library_comparisons/h09_iterator_comparision.md), но его другой API отказов не требуется этому сценарию и не получает приоритета только из-за размещения в ядре.


`Numbers\demo()` → **12**. next вызывается **четыре** раза: три значения и один Stop. Тело исполняется **три** раза. Форма `int: item Numbers\next()` сохранена; очередной шаг исполняет её в принимающем корневом namespace, а тело использует полученное место item. Повторного вычисления инициализатора только ради входа в тело нет.

Нулевой элемент тоже является элементом. Отдельная серия **−2, 0, 4, Stop**, где тело прибавляет **3** и дважды читает item, даёт **22**, три исполнения тела и четыре вызова шага. Это D-01 из [корпуса](LMX_regression_examples.to_fable.en.md); условие сохранено; локальная реализация цикла полностью включена в общий листинг обеих совпадающих минимальных форм и в каждую из их равных метрик.

Haskell использует whileJust_ из настоящего пакета monad-loops. В Analogies.hs iteratorCase создаёт изменяемый источник, действие тела и счётчики; проверяются (12,4,3) и (22,4,3). Самописный StepIterator находится только в сравнении реализаций. Haskell передаёт значение callback-у явно и не получает механизма объявления переменной в чужом namespace.

Операнд здесь не добавлен: предмет проверки — переданное объявление и его принимающий контекст. Замена на prepared-вызов изменила бы момент вычисления шага; raw-заголовок добавил бы новый слой без сокращения цикла. Ленивый список и stateful-источник дают общий конечный результат, но устроены по-разному. [Контракт деклараций](../LMX_semantics.en.md#declaration-arguments); [исходное сравнение Iterator](01_iterator_comparison.md).

Полные действующие листинги и обе стилевые метрики: [H09](#h09).


### Пояснения к R01


Функциональная форма использует `derive`, возвращающий одно собранное значение обычного merge; процедурная явно собирает поток `(merge(...))`. Обе полные записи сохраняют алгоритм, поля и одну карту копирования. Общее тонкое тело derive показано рядом и не дублируется ради двух стилевых строк.

**Ожидается:** MergeProbe\run() → 257; width=2, height=5, depth=7. Оба исходных значения сохранены.

Результат **257**. `height` занимает соответствующий слот модели с новым значением `5`; `depth` добавляется. Поля обоих источников не изменены. Вариант с подходящими методами использует тот же контракт копирования и связывания, а не особую операцию над классами.

Haskell выражает обновление заранее известной записи в [полном сравнении R01](#r01).


Здесь поле `depth` заранее входит в `Size`. Чтобы добавлять произвольные именованные узлы вместе с исполняемым содержимым, потребуется выбранное представление данных: словарь, AST, граф или другая явная модель и её операции. Обычное значение типа `Int -> Int` само по себе не даёт API перечисления и замены внутренних узлов функции. Это граница рассматриваемого аналога, а не запрет решить задачу на Haskell. [Haskell: записи и объявления](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html); [LMX: композиция](../LMX_semantics.en.md#composition).

Если затем приложение явно переназначит ссылку на `result`, оно будет использовать новую ветвь. Независимо сохранённая другая копия автоматически не обновится. «Изменение структуры» и «глобальная синхронизация всех когда-либо созданных копий» — разные обязательства.

**Связь двух форм.** `derive(RecordModel; RecordPatch)` и `(merge(RecordModel; RecordPatch))` выражают одну композицию. Обе полные клиентские записи и их отдельные размеры опубликованы в R01; справочное тело общего helper хранится один раз.

[Отдельное сравнение реализаций](examples/library_comparisons/r01_derive_comparision.md).

**Граница сравнения.** derive — показанный рядом тонкий вызов обычного merge, а не скрытый алгоритм специально для RecordModel. Сохранены все три поля, соответствующие позиции модели, добавленное поле, самостоятельный результат и одна карта композиции. Контроль Haskell использует встроенное обновление записи. Разница в динамической структуре LMX и заранее известном типе Haskell сохранена и объяснена; ширина не удалена.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [R01](#r01).


### Пояснения к R02

Полный пример группового присваивания опубликован в [R02](#r02).


Результат **27**. Вход `copy` один, выходных полей два. Имена `first/second` справа не переставляют соответствие `a/b`: присваивание позиционное. Все правые значения читаются до первой записи.

Краткая запись `(a b) := copy(Pair)` и `(a b) := (copy(Pair))` здесь эквивалентны: группировщик задаёт левый участок a, b и правый поток двух скопированных полей. Отдельный адаптер применения упаковывает левый участок в один actual и строит справа массив двух ссылок. Поэтому исходник использует первую форму. Это не устраняет границу контейнерного значения в скалярном присваивании `ptr := (copy(Model))`. Три соседние правые группы в `(a b c) := (f g h) (f g h) (f g h)` дают три элемента, а не девять; допуск этих целых групп к типам целевых мест проверяется отдельно.

| Форма | Что получает окружающий потребитель |
| --- | --- |
| `copy(Pair)` | Два поля потоком |
| `(copy(Pair))` | Одна явно собранная Structure с двумя полями |
| `f(copy(Pair))` | Поток на границе аргументов `f` |
| `f((copy(Pair)))` | Сначала одну группу; далее обычный выбор W/E у `f` |
| `f(arg0 := (copy(Pair)))` | Целую группу конкретному существующему формалу `arg0`, без E |
| `copy(Empty)` | Ноль выходных полей из одного пустого источника |
| `(copy(Empty))` | Один пустой структурный результат |

**Скобки сохраняют группу, но не отменяют обычный выбор аргументов следующего ресивера.** Если целая структура подходит как W и её поля подходят как E, результатом является неоднозначность. Нельзя всегда предпочитать W из-за скобок или E из-за нескольких полей.

Важный отрицательный тест для оптимизации: один написанный `merge(S)` не обязательно означает один принятый источник. Если `S` содержит два допустимых структурных источника и единственное подходящее чтение — E, `merge` получает два источника. Написанную арность нельзя проверять до выбора W/E. Для `copy` принятых источников должно быть ровно один, для `import` — один или несколько.

При `(c b d a) := (a b c d)` из `1,2,3,4` получаем `a=4, b=2, c=1, d=3`. При несовпадении числа мест и значений запись ни в одно левое место не начинается. Это правило не обещает откат эффектов вычисления правой стороны. [Основание: присваивание группы](../LMX_semantics.en.md#group-assign).

Haskell-ближайший аналог позиционного обмена — новая привязка кортежа из старых значений. LMX-поток при этом не нужно объявлять Haskell-кортежем: у него свой способ передачи обычному namespace-потребителю.

Полные действующие листинги и обе стилевые метрики: [R02](#r02).


### Пояснения к R03


Ожидается **712**. `import` делает доступным имя исходного метода `read`, сохраняя его фактического родителя `Provider`. Готовое собственное значение `7` не вытесняется вызывающим `99`. У копии явно выбран фактический DATA метода: `parent(copied\read)`. Этот скопированный родитель и контейнер, собравший поток, — разные структуры с разными ячейками. Замена поля `value` у выбранного родителя даёт методу `12`; ячейка `copied\value` в контейнере остаётся со значением `7`. `Provider\value` тоже остаётся `7`.

| Операция | Что оказывается в потоке | DATA и лексический владелец метода |
| --- | --- | --- |
| `import` | Ссылки на подходящие исходные const-объявления | Исходный владелец; идентичность метода и его связей сохранена |
| `copy` | Глубоко скопированный граф одного принятого источника, выдаваемый полями | Соответствующий скопированный владелец |
| `merge` | Глубоко скопированная композиция принятых источников по общей карте операции | Соответствующий скопированный владелец с результатом композиции |

Явная группа в каждом случае имеет собственные ячейки. Она собирает ссылки на выданный материал, не становится лексическим владельцем метода и не делает ещё одно глубокое копирование. Общая вложенная цель при этом остаётся общей: если два пути через разные контейнеры приходят в одну `child`, то запись в её `child\x` выбирает одну и ту же внутреннюю ячейку. Различаются ячейки внешних контейнеров, а связи внутри результата сохраняются по карте операции.

Само изменяемое поле `Provider.value` не импортируется. Пользовательская Structure `read` имеет константное имя по природе объявления; это не обещание неизменяемости всех её достижимых данных. Имя, объявленное через `Name :: DATA`, также импортируется как подходящее константное объявление; сам оператор `::` от этого не импортируется и публичного ресивера `fn` нет.

Три дополнительных проверки:

1. `Struct: merge(A B)` объединяет только `A` и `B`. Уже написанное `Struct.x` не становится модельным слотом операции.
2. Два самостоятельных `merge` в одном DATA имеют две карты копирования. Приём второго потока — обычный приём объявлений, а не скрытый `merge` с накопленным получателем.
3. `f(import(A B))` отдаёт поток `f`; побочного дополнительного импорта в caller нет. `Producer()` внутри источников исполняется при потреблении по обычному CODE-контракту и в DATA, и в CODE. Построение P0 его не исполняет.

Основание: [import](../LMX_semantics.en.md#import-receiver) и [композиция](../LMX_semantics.en.md#composition).

Полные действующие листинги и обе стилевые метрики: [R03](#r03).


### Пояснения к R04


`LocalProbe\run()` → **4142**, два вызова источника. `LocalProbe\explicitInitialization()` → **44**, один вызов источника. Исходная форма вычисляемого объявления остаётся в графе. Локальные `99` и `44` не публикуются обратно в её место.

Из внешнего чтения исходного пути не следует исполнение `ReadSource\next()`. Если требуется адрес исходной записи, он не становится адресом результата будущего вызова. Если требуется обычная текущая локаль, используется её собственное логическое место; native-исполнитель не обязан создавать для неё отдельный аренный узел с заголовком перед C-переменной.

Контрпример: убрать `int: i`, не оставив никакого допустимого собственного, caller- или fallback-места. Присваивание должно быть отклонено; оно не объявляет поле. Другой контрпример: не читать вычисляемый default либо явно заменить его входным аргументом. Невостребованный источник должен исполниться **ноль** раз.

Сравнивать надо исходную запись и её операции. Полная сериализация всех достижимых узлов может закономерно измениться из-за явно изменяемого `ReadSource.calls`; это не порча исходного кода. [Основание](../LMX_semantics.en.md#path-reads-no-execution), [локальные объявления](../LMX_semantics.en.md#shadowing-levels).

Полные действующие листинги и обе стилевые метрики: [R04](#r04).


### Пояснения к R07

В [R07](#r07) сохраняется само LMX-выражение; полный листинг не требует отдельного AST приложения.


`Operands\Example\demo()` → **20**, то есть `7 + 13`. Один записанный граф выражения исполняется с двумя входами. Операнд находится по обычному имени метода и структурному DATA-контракту; отдельной регистрации в словаре операторов нет.

`copy: sys\OPERANDS_TEMPLATE` стоит первым в DATA операнда и поставляет в namespace `left`, `right`, `PASS_ARGS_AS_IS 0` и приоритет сложения. Этот конкретный DATA-фрагмент явно предоставляет [профиль сравнительного fixture](OPERAND_USAGE_PROFILE.md); он не возникает из одного соответствия структурному требованию OPERANDS_TEMPLATE и не объявляется новым обязательным системным объектом. Написанный copy остаётся в исходном графе; `return` в предоставленном фрагменте нет, поэтому результат объявлен в реализации. Библиотечные операции используют собственный обычный общий фрагмент [FxPreparedOperands](LMX_Fn_Receivers/PUBLICATION_CONTRACT.md#prepared-operand-data) и явные приоритеты. Тело add показано полностью.

Вложенный `Example` остаётся собственным фактическим DATA методов `calculate` и `demo`; поля заголовка из внешнего `Operands` не добавляются к их позиционным входам. Контракт данного fixture — бинарное применение `add`: один левый и ровно один правый `int`. Проверка произвольной арности и вариадический обход в этот сценарий не входят.

Обычный Haskell-аналог вычисления — `calculate x = (x + 3) + x`. Если нужно также *осматривать и преобразовывать узлы*, можно явно выбрать AST, как в [полном сравнении R07](#r07).


Этот Haskell-код уже содержит представление дерева и его интерпретатор. Он решает расширенную задачу, поэтому сравнивать его длину только с `calculate` без оговорённой границы задачи было бы некорректно. В LMX исходное исполняемое представление уже принадлежит общей модели языка.

Проверки операндов: `30 subtract 4 * 3` при приоритете `+` должно дать **18**; `30 subtract 4 subtract 3` — **23**; массив из 17 элементов, переданный одним правым occurrence, остаётся одним правым аргументом, а не 17. `PASS_ARGS_AS_IS 1` позволяет написать управляющий операнд, который исполнит только выбранную ветвь через `sys\eval`; непрочитанная ветвь не производит эффектов. Полные OP01–OP18 — в [корпусе](LMX_regression_examples.to_fable.en.md#operands).

Полные действующие листинги и обе стилевые метрики: [R07](#r07).


### Пояснения к R09

Полный пример расположен в [R09](#r09).


На свежем графе `UninitializedGraph\number` представлен записью `{uninit_int}`. **`sizeof(value) = 0`**: есть код типа, а хранилища под будущий `int` нет. Для `reference` тоже выбран соответствующий неинициализированный тип без payload. Для сравнения `ReadyValues` содержит готовый числовой ноль и готовую нулевую ссылку. `nil` в текущей спецификации обозначает типизированное отсутствие, поэтому его нельзя использовать здесь как готовую нулевую ссылку.

Последовательность проверки:

1. Инспектор графа подтверждает код `uninit_int` и нулевой размер value. Он не читает выдуманное неинициализированное число из зарезервированного места.
2. `UninitializedGraph\localWrite()` возвращает **5**. После выхода исходный `number` по-прежнему `{uninit_int}`. Повторный вход снова получает исходное отсутствие значения, прежде чем выполнит своё локальное присваивание.
3. `UninitializedGraph\graphWrite()` возвращает **5**. Теперь выбранная ячейка структуры указывает на `{int 5}`: выполнена явная замена фрагмента графа.
4. Инспектор проверяет новое содержимое именно по структурному месту. Равенство прежнего и нового сырых адресов записи или value не является условием успешности.

Если две ссылки выбирают одну и ту же структуру и один слот, обе увидят замену. Если два разных слота только ссылались на один прежний примитив, это не превращает их в один слот: замена одного не распространяется автоматически на другой. Отсюда явный выбор владельца в H03, R03 и R06.

Основание: [`uninit` без полезной нагрузки](../LMX_semantics.en.md#uninit-zero-payload) и [присваивание в кадре и в граф](../LMX_semantics.en.md#frame-and-graph-assignment); подробная проверка G13 находится в [корпусе](LMX_regression_examples.to_fable.en.md#uninit-graph).

Полные действующие листинги и обе стилевые метрики: [R09](#r09).


### Пояснения к A01

Полный [пример A01](#a01) показывает именованный и индексный доступ к одной структуре.


На свежем графе результат **209**. `same` и `Slots` обозначают тот же дескриптор. Индексная запись заменила ссылку во втором слоте; она не сохранила для нового содержимого прежнее имя `y` или прежний контракт слота. Последующий структурный доступ интерпретирует текущее содержимое, поэтому доступно `z` со значением `9`. Сам новый узел не был скопирован или переподчинён из-за записи указателя.

Дополнительный сценарий стенда: предоставить тот же дескриптор как `@[]` и как Structure. Длина, слоты и изменённая ссылка совпадают; конверсия не выделяет второй контейнер или backing. Это и есть важная унификация «массива void-ссылок» и структуры. Поле, *содержащее ссылку* на массив, остаётся отдельным содержащим полем.

В Haskell запись и `Data.Array` являются разными объявленными типами; можно написать явное представление графа поверх массива ссылок, но обычная запись от этого сама не получает индексного API `Array`. [LMX](../LMX_semantics.en.md#structure-index); [Haskell Data.Array](https://www.haskell.org/onlinereport/haskell2010/haskellch14.html).

Полные действующие листинги и обе стилевые метрики: [A01](#a01).


### Пояснения к V02


Процедурная форма явно проверяет длину, проходит позиции циклом и сравнивает ASCII-границы; функциональная строит общий Pattern и выполняет matches над byteText. Обе сохраняют разделитель, длину и точные диапазоны ASCII. Операнд between с подготовленными аргументами остаётся общей операцией для включительных границ, а его реализация и соответствующий Haskell helper показаны отдельно. Контрольный Haskell-клиент использует Data.Ix.inRange.

**Ожидается:** AB-09 и QZ-70 принимаются; неверная длина, разделитель, NUL и символы вне ASCII-диапазонов отклоняются. Все 11 исходных случаев сохранены.

| Вход для `TicketCode\accepts(...)` | Результат |
| --- | ---: |
| `"AB-09"`, `"QZ-70"` | 1 |
| `""`, `"AB-9"`, `"AB-090"` | 0 |
| `"ab-09"`, `"AB-0X"`, `"XAB-09Y"` | 0 |

Процедурный checker сначала проверяет длину, затем элементы. Функциональный matches требует полного сопоставления Pattern с byteText; поиска подстроки нет. Все эти значения могут иметь одинаковый интерфейс массива символов; различие содержимого устанавливает исполняемый checker. Его можно использовать как требуемую проверку при допуске, а можно вызвать напрямую, как здесь.

Haskell-эквивалент проверки приведён в [полном сравнении V02](#v02).


Этот пример не претендует на полную реализацию синтаксиса регулярных выражений. Он показывает, как требование к содержимому становится обычным проверяющим кодом рядом с интерфейсом. [Основание](../LMX_semantics.en.md#graph-tests).

В отдельном сравнении реализации between включительные границы и перевёрнутый диапазон обрабатываются одинаково. Haskell фиксирует пару типом, а LMX between проверяет ровно два правых аргумента и сообщает RangeArity. Это договор общего helper, а не дополнительные обязательные отказы процедурного клиента V02.


Функциональная запись использует обычный общий операнд then для последовательности Patterns, within с границами "A"/"Z" и asciiDigit. Повторения times сохраняют требуемую группировку. Сопоставление охватывает весь byteText. Then обобщён на допустимые последовательностные Patterns; монадическая операция называется bind. Публичный matches копирует полный договор фактически выбранного обработчика, и эта ссылка входит в размер. LMX runtime не запускался.

[Отдельное сравнение реализаций](examples/library_comparisons/v02_character_range_comparision.md).

**Граница сравнения.** Процедурный цикл и функциональный Pattern проверяют один договор TicketCode; обе формы и все 11 исходных случаев сохранены. Контроль использует готовый Data.Ix.inRange. Сравнение реализаций between остаётся отдельной границей: полный matcher не объявляется алгоритмом проверки одного включительного интервала.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [V02](#v02).


### Пояснения к V03


sample уже реализует чтение и умножение. biased вызывает его один раз и добавляет 1. readsTwice сохраняет первый read(), затем вызывает sample() для второго чтения. При sample() собственные незаполненные gain и read получают значения из исполняемого кандидата; новых DATA-полей, сохранённого состояния и интерфейсных входов нет.

**Ожидается:** sample даёт вердикт 1 при одном чтении; biased — 0 при одном чтении; readsTwice — 0 при двух чтениях. Повторная проверка сбрасывает счётчик.

| Вызов | Вердикт | Число чтений |
| --- | ---: | ---: |
| `SamplingCheck\check(candidate := Measurement\sample)` | 1 | 1 |
| `SamplingCheck\check(candidate := Measurement\biased)` | 0 | 1 |
| `SamplingCheck\check(candidate := Measurement\readsTwice)` | 0 | 2 |

Выполняется настоящий кандидат. Подменена его зависимость `read`, а не весь проверяемый алгоритм. Собственное незаполненное `read` кандидата получает обычную локальную ссылку checker через autofill; `gain` передан явно. Счётчик mock расположен в явно доступном лексическом состоянии.

Последний кандидат специально возвращает правильное число `28`, но делает два чтения. Проверка только результата пропустила бы дефект. Haskell-аналог — параметр `readSample :: IO Int` у `sample`, с тестовым действием, которое возвращает `7` и увеличивает `IORef`. Подмена зависимости не требует отдельного языка тестов ни в одном варианте.

Контрольный повтор первого вызова опять даёт `1` и ровно одно чтение: checker явно сбрасывает свой счётчик. [Основание](../LMX_semantics.en.md#binding-autofill); V02 английского корпуса.

**Вместо повторного листинга.** В biased строка sample() + 1 соответствует read() * gain + 1; в readsTwice второй вызов sample() соответствует read() * gain. Сохранён вариант с повторным использованием существующего метода; отдельного алгоритма в дублирующем листинге нет.

**Граница сравнения.** Оба варианта содержат весь прикладной код и используют один текущий механизм динамического вызова. biased и readsTwice повторно используют локальный sample; gain и read остаются входами прежнего DATA Measurement, а число и порядок вызовов read сохраняются. Никакая проверка или самописный helper не вынесены из подсчёта.

[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.

Полные действующие листинги и обе стилевые метрики: [V03](#v03).


### Пояснения к V04


`FailureCheck\check(candidate := UnavailableSensor\read)` → **1**. С `UnavailableSensor\zero` получается **0**. Нормальный нулевой результат не является ожидаемым отказом. Другой объявленный `throw` не считается автоматически успехом проверки.

Haskell можно дать явный результат `Either Failure Int` и сопоставить `Left NoSample`, либо выбрать механизм исключений для `IO`. Это альтернативные интерфейсы результата. В LMX здесь проверяется именно объявленный выход `NoSample` и обычный `catch`, расположенный рядом с вызывающим кодом. Обёртка `try` для этого примера не вводится. [Основание](../LMX_semantics.en.md#catch-common-model).

Полные действующие листинги и обе стилевые метрики: [V04](#v04).


### Пояснения к V05

Из обсуждения автомобиля берём одну законченно определённую процедуру: включить индикатор, прочитать обратную связь, выключить, снова прочитать. ACK команды и состояние датчика проверяются отдельно.


Для каждой строки стенд создаёт свежую копию `device = (merge(Indicator; (int: fault F)))`, подставляя конкретное значение `F`, и вызывает `Commissioning\check(candidate := device)`. Это запись подготовки стенда; присваивание без объявления новой переменной не предлагается.

Счётчики `writes`, `reads`, `trace` и конечные `commanded/sensed` стенд наблюдает у фактического скопированного владельца `parent(device\set)`; `parent(device\observe)` должен указывать на того же владельца. Внешний группирующий контейнер `device` имеет собственные ячейки, поэтому чтение `device\writes` само по себе не заменяет наблюдение состояния, которое меняет `node\writes` в методе. Это следует из [контракта копирования](../LMX_semantics.en.md#composition).

| `fault` | Обратная связь | Вердикт | Конечное commanded / sensed | Writes / reads | Trace |
| ---: | --- | ---: | --- | --- | ---: |
| 0 | Следует команде | 1 | `0 / 0` | `2 / 2` | 1202 |
| 1 | Всегда выключено | 0 | `0 / 0` | `2 / 2` | 1202 |
| 2 | Всегда включено | 0 | `0 / 1` | `2 / 2` | 1202 |

Оба дефектных устройства отвечают `1` на обе команды. Проверка всё равно их отвергает. Последнее выключение выполняется и после неверного первого наблюдения: `check` безусловно вызывает общий `cycle` сначала с 1, затем с 0, и только после обоих вызовов вычисляет итоговый вердикт. В `cycle` один раз записана пара set → observe; в `mark` один раз записан шаг журнала. При выброшенном исключении действуют обычные правила выходов и обработки; из этого листинга нельзя вывести несуществующий автоматический rollback.

Чтобы проверить подключённое устройство, checker получает его действительные `set` и `observe` с тем же требуемым контрактом. Чтобы проверить алгоритм стенда воспроизводимо, он получает показанный `Indicator`. Различие задаётся переданной зависимостью. Если `observe` читает только программный регистр команды, это проверка регистра; физическую лампочку за него язык не наблюдает.

В этом и смысл интеграционной интерпретации: тест может быть реальным действием системы с явно выбранной последовательностью и проверкой результата. Автоматическое клонирование внешних ресурсов, подавление всех эффектов или восстановление прежнего состояния не следуют из слова `test`. [Основание](../LMX_semantics.en.md#graph-tests), [пригодность внешнего ресурса](../LMX_semantics.en.md#admission-case-14).

Полные действующие листинги и обе стилевые метрики: [V05](#v05).


### Пояснения к M01


Стенд размещает `Counter` у одного исполняющего владельца. Два отправителя адресуют ему обычные вызовы `add(delta := 4)` и `add(delta := 9)`. Именованная передача нужна здесь потому, что в DATA перед `delta` объявлено поле `value`. Начальное значение `0`. После обоих вызовов `read()` возвращает **13** при любом порядке поступления. Промежуточные ответы могут быть `(4,13)` или `(9,13)` по порядку исполнения, но ни один update не теряется.

Контрпример: начальное `10`; оба отправителя отдельно читают `10`, затем каждый присылает запись `11`. Итог **11** допустим при таком протоколе. Последовательные turns не объединяют несколько отдельных сообщений в одну транзакцию. Исправление задачи — отправлять целиком `add(delta := 1)`, а не добавлять mutex вокруг чужого графа. [Основание](../LMX_semantics.en.md#delivery).

На Haskell аналог владельца можно построить обычным циклом обработки `Chan Request`, запущенным через `forkIO`, и возвращать результат через `MVar`. В таком варианте счётчик передаётся следующей итерации цикла как обычное число. Это библиотечная реализация модели владения, а не автоматическое свойство любого Haskell-объекта. Полный пример находится в [Analogies.hs](examples/haskell_comparision/Analogies.hs).

Для удалённого варианта стенд использует уже описанный [HTTP-профиль](../LMX_semantics.en.md#transport): endpoint + route, документ `application/lmx`, decoder и admission. Синхронный профиль может вернуть семантический результат в HTTP-ответе; асинхронный — подтвердить admission и доставить результат через `replyTo` с `correlation`. Финальный `read()` проверяется после завершения обоих add, а не только после двух подтверждений приёма. Операторная или библиотечная обёртка здесь не заменяет Message, отдельные turns и корреляцию результатов.

Полные действующие листинги и обе стилевые метрики: [M01](#m01).


### Пояснения к M05

Самостоятельное локальное тело опубликовано в [M05](#m05).


У `Lamp\set` нет описания `return`. Локальный или транспортируемый вызов с `command=1` меняет явное состояние и не создаёт прикладной ответ только ради транспортной схемы. Отсутствие такого ответа само по себе не становится `unanswered`. Успешная доставка письма и подтверждённое приложением исполнение команды — разные сведения.

Для подтверждения фактического состояния приложение выбирает явный интерфейс с результатом или отдельное наблюдение, как V05. В Haskell `IO ()` явно описывает результат действия как unit; здесь важно не перенести его механически в несуществующую LMX-декларацию результата. [Основание](../LMX_semantics.en.md#thread-message-observations), T26.

При HTTP-доставке это не запрещает предусмотренный профилем статус транспорта или подтверждение admission. Они не являются прикладным результатом `Lamp\set` и не создают отсутствующее описание `return`. Условия fixture по-прежнему требуют ноль прикладных ответов и не подменяют фактическую обратную связь HTTP-успехом.

Полные действующие листинги и обе стилевые метрики: [M05](#m05).
