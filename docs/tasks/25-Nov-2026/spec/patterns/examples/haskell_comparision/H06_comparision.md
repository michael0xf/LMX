# H06. Order of two composed computations

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

[Полный исходник](source/lmx/procedural/H06.lm3)
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

[Полный исходник](source/lmx/H06.lm3)

## Haskell

```haskell
module H06 where

example :: (Int, Int)
example = (((+1) . (*2)) 4, ((*2) . (+1)) 4)
```

[Полный исходник](source/haskell/H06.hs).

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

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 223 | 15 |
| LMX — функциональный | 167 | 11 |
| Haskell | <span style="color:#176233"><u>67</u></span> | 3 |

