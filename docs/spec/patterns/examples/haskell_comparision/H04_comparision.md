# H04. Overrideable copied default

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

[Полный исходник](source/lmx/procedural/H04.lm3)
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

[Полный исходник](source/lmx/H04.lm3)

## Haskell

```haskell
module H04 where

addWithDefault :: Int -> Maybe Int -> Int
addWithDefault x supplied = x + maybe 5 id supplied

example :: [Int]
example = map (addWithDefault 1) [Nothing, Just 25, Just 0, Nothing]
```

[Полный исходник](source/haskell/H04.hs).

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

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 265 | 17 |
| LMX — функциональный | 205 | 13 |
| Haskell | <span style="color:#176233"><u>162</u></span> | 5 |
