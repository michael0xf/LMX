# V02. Whole ASCII ticket-code predicate

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

[Полный исходник](source/lmx/procedural/V02.lm3)
## LMX — функциональный

```lmx
TicketCode:
    char[]: candidate
    return: int
    accepts:
        throws: copy(matches\throws)
        return: matches(byteText(candidate); (within("A"; "Z") times 2) then "-" then (asciiDigit times 2))
```

[Полный исходник](source/lmx/V02.lm3)

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

[Полный исходник](source/haskell/V02.hs).

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

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.Ix](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-Ix.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 226 | 19 |
| LMX — функциональный | 160 | 6 |
| Haskell | <span style="color:#176233"><u>146</u></span> | 7 |

