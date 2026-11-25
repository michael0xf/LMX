# H03. Independent bound prefixes and residual callable admission

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

[Полный исходник](source/lmx/procedural/H03.lm3)
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

[Полный исходник](source/lmx/H03.lm3)

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

[Полный исходник](source/haskell/H03.hs).

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

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 495 | 31 |
| LMX — функциональный | 239 | 14 |
| Haskell | <span style="color:#176233"><u>137</u></span> | 7 |

