# V02. Whole ASCII ticket-code predicate

## Общий договор

Complete whole-string predicate for exactly two ASCII uppercase letters, hyphen, two ASCII digits. The five-element list pattern enforces length; inRange checks ASCII endpoints. All eleven current fixtures agree, including NUL, non-ASCII letter and non-ASCII digit rejection. Haskell String and LMX char[] use their ordinary character-sequence representations; no locale-dependent character class is introduced.

Процедурный вариант перебирает позиции и проверяет ASCII-границы явно. Функциональный строит общий Pattern и применяет matches к полному byteText. Договор — ровно две ASCII-буквы, дефис и две ASCII-цифры.

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
            i += 1
        return: candidate[2] = '-'
```

[Полный исходник](../../lmx/procedural/V02.lm3)

## LMX — функциональный

```lmx
TicketCode:
    char[]: candidate
    return: int
    accepts:
        throws: copy(matches\throws)
        return: matches(byteText(candidate); (within("A"; "Z") times 2) then "-" then (asciiDigit times 2))
```

[Полный исходник](../../lmx/V02.lm3)

## Haskell

```haskell
import Data.Ix (inRange)

accepts :: String -> Bool
accepts [a,b,'-',c,d] =
  all (inRange ('A','Z')) [a,b]
    && all (inRange ('0','9')) [c,d]
accepts _ = False
```

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 223 | 18 |
| LMX — функциональный | 160 | 6 |
| Haskell | **132** | 6 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
