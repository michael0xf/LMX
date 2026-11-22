# V02 — CharacterRange: использование и полная реализация / use and implementation

## Что вынесено

`between` проверяет принадлежность символа включительному диапазону. Это собственная маленькая библиотека приложения, а не новый builtin. В клиенте остаются все правила билета: длина ровно пять символов, дефис на третьей позиции, две ASCII-буквы `A`–`Z`, затем две ASCII-цифры `0`–`9`. Библиотека не знает ни о билетах, ни о позициях в строке, ни о RegEx.

В LMX один пользовательский операнд заменяет повторяющиеся пары сравнений. Он копирует предоставленный `sys\OPERANDS_TEMPLATE` первым в DATA, получает готовые значения (`PASS_ARGS_AS_IS 0`), имеет стандартный приоритет сложения и собственный результат `int`. Приложение заключает каждое применение в скобки перед `&&`. Режим raw, `sys\eval` и собственный разборщик не нужны.

## Загрузка и граница

Существующий LMX-стенд подготавливает [CharacterRange.lm3](../libraries/lmx/CharacterRange.lm3) и [V02.lm3](../lmx/V02.lm3) в одном свежем исходном контексте. `import: CharacterRange` открывает доступный namespace и сохраняет DATA метода библиотеки; этот import сам не задаёт файловый загрузчик. Это обычные исходники `.lm3`, без добавленного `main` или DATA для R0.

Для Haskell модуль [CharacterRange.hs](../libraries/haskell/CharacterRange.hs) лежит в каталоге поиска `examples/libraries/haskell`. Отдельный клиент приведён в [V02TicketCode.hs](V02TicketCode.hs). Общие assertions доступны в `examples/haskell/Analogies.hs`; из корня архива:

```sh
runghc -iexamples/libraries/haskell examples/haskell/Analogies.hs
```

Эта команда — способ предполагаемого запуска, не отчёт об успешном исполнении. В этой проверке ядро LMX и GHC не запускались.

## Клиент LMX

```lmx
TicketCode:
    []: char candidate
    return: int
    accepts:
        throws: RangeArity
        import: CharacterRange
        if: length(candidate) != 5
            return: 0
        if: candidate[2] != '-'
            return: 0
        return: (candidate[0] between 'A' 'Z') && (candidate[1] between 'A' 'Z') && (candidate[3] between '0' '9') && (candidate[4] between '0' '9')
```

Проверка длины предшествует любому индексированию. Дефис проверяется отдельно; четыре последующих вызова чисты. `&&` сохраняет обычное короткое замыкание. Все ASCII-границы написаны у клиента.

## Полная реализация LMX

```lmx
CharacterRange:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    between:
        throws: RangeArity
        if: length(right) != 2
            throw: RangeArity()
        char: value \left
        char: lower \right[0]
        char: upper \right[1]
        return: lower <= value && value <= upper
```

Контракт: слева один готовый `char`; справа ровно две ссылки на готовые `char` в порядке lower, upper. `\left` и `\right[i]` читают значения. При другой длине `right` получается объявленный выход `RangeArity`, поэтому клиент также объявляет `throws: RangeArity`, хотя все четыре его записи корректны. Проверка длины идёт до индексирования. Перевёрнутый диапазон не нормализуется и даёт `0`. При корректных входах нет записей в граф, I/O, внешних портов или сохраняемых ссылок на кадр.

## Клиент Haskell

```haskell
module V02TicketCode (accepts) where

import CharacterRange (between)

accepts :: String -> Bool
accepts [a,b,'-',c,d] =
  all (\x -> x `between` ('A','Z')) [a,b] &&
  all (\x -> x `between` ('0','9')) [c,d]
accepts _ = False
```

## Полная реализация Haskell

```haskell
module CharacterRange (between) where

between :: Char -> (Char, Char) -> Bool
between value (lower, upper) = lower <= value && value <= upper
```

Оба клиента используют собственный показанный helper. Haskell представляет две границы типизированной парой, LMX получает их через массив правых аргументов общего операторного контракта. Поэтому неверное число границ в Haskell не соответствует этому типу, а в LMX проверяется телом и даёт `RangeArity`. Это реальное различие интерфейсов, не скрытая бесплатная LMX-проверка. На допустимых входах смысл включительных границ совпадает; `Bool` соответствует результатам LMX `0/1`.

## Проверяемые результаты

| Вход клиента | LMX | Haskell |
| --- | ---: | --- |
| `AB-09`, `QZ-70` | 1 | True |
| пустая строка, `AB-9`, `AB-090` | 0 | False |
| `ab-09`, `AB-0X`, `XAB-09Y` | 0 | False |
| пять символов `A, B, NUL, 0, 9` | 0 | False |
| `ÄB-09` с буквой U+00C4 | 0 | False |
| `AB-٠9` с цифрой U+0660 | 0 | False |

Контроль самого helper: `A` и `Z` внутри `A`–`Z`; `@` и `[` вне его; `A` вне перевёрнутого `Z`–`A`. В LMX отдельный стенд вызывает операнд с явно переданным массивом `right` длины 0, 1 и 3 и должен поймать `RangeArity`; поставленный клиент эти формы не использует. Неинициализированный левый вход, не-`char` и нарушения времени жизни остаются обычными ошибками приёма/чтения и не переименовываются в `RangeArity`.

## Размер и эффект выделения

Метрика — все непробельные символы и непустые строки конкретных файлов, включая module/import и стандартный заголовок операнда. Внутренности стандартной библиотеки языка в листинги не включены.

| Часть | LMX, символы / строки | Haskell, символы / строки |
| --- | ---: | ---: |
| Клиент | 263 / 11 | 186 / 7 |
| Полная собственная библиотека | 199 / 11 | 118 / 3 |
| Клиент + библиотека | 462 / 22 | 304 / 10 |

Прежний самостоятельный LMX-клиент занимал 301 символ; новый клиент — 263, на 38 меньше. С полной библиотекой получается 462 символа: отдельный этот пример в целом стал больше. Выигрыш — повторно используемое понятное имя диапазона и однократная подготовка исходного выражения `candidate[index]` для каждой проверки; ускорение исполнения не заявляется. Объём helper показан целиком и не считается нулевым.

## English: contract and comparison

The extracted application library implements only an inclusive character range. Ticket length, separator position and all ASCII bounds stay in the client. LMX uses the supplied header in prepared-value mode with its existing addition priority; each operator application is explicitly grouped before Boolean composition. No raw evaluation, hidden parser, I/O or Message protocol is introduced.

The complete implementation is shown for both languages. LMX validates exactly two right operands and propagates the named `RangeArity` exit through `accepts`. Haskell uses a statically typed pair of bounds, so malformed arity is a type-level mismatch rather than that runtime exit. Reversed bounds give false in both implementations. The required successful/unsuccessful ticket outcomes and the embedded-NUL negative fixture are retained. Unicode letters or digits outside the written ASCII ranges do not become accepted through a general character-class predicate.

Load the helper source before using the LMX client namespace. The Haskell module search path is given above. Counts separate clients from their full own libraries; the LMX client is shorter, but client plus library is larger than the former standalone validator. These are documentation-reviewed examples, not execution receipts or benchmarks.

## Основания / sources

- [LMX, пользовательские операнды и готовые значения](../../../LMX_semantics.en.md#operand-receiver), [профиль стандартного заголовка](../../OPERAND_USAGE_PROFILE.md): исходный DATA, `left/right`, режим 0 и приоритет.
- [LMX, объявленные выходы](../../../LMX_semantics.en.md#catch-common-model): обязанность обработать или распространить объявленный выход.
- [Haskell 2010 Report, глава 6](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html): `Char`, `String`, `Ord`, типы пар.
- [Haskell 2010 Report, глава 3](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html): применение именованной функции в инфиксной форме, tuple/list patterns и выражения.

Внешние первичные источники открыты и прочитаны 2026-11-21; листинги написаны для этого сравнения.
