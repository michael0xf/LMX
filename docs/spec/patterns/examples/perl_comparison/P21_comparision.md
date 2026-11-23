# P21. Транслитерация алфавита ДНК

## Общий договор

Вернуть новую строку с одновременной заменой A↔T и C↔G. Другие ASCII-символы и длина не меняются; уже заменённые символы повторно не обрабатываются.

LMX здесь использует обычный граф, копирование и индексы. Отдельный библиотечный ресивер ради одного фиксированного алфавита не вводится.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    "ACGTN"
  ],
  "result": "TGCAN"
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 432 | 219 | 17 |
| Perl | 99 | 75 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P21.lm3).

```lmx
Example:
    char[]: text
    return: char[]
    run:
        char[]: source "ACGT"
        char[]: target "TGCA"
        char[]: result [copy(text)]
        int: i 0
        while: i < length(text)
            int: j 0
            while: j < length(source)
                if: text[i] = source[j]
                    result[i] := target[j]
                    break
                j += 1
            i += 1
        return: result
```

## Perl

[Исходник](source/perl/P21.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return $text =~ tr/ACGT/TGCA/r;
}
```

## Отдельные реализации

Только базовые средства языка и определения предметного объекта примера; отдельного библиотечного импорта нет.

Штатные средства Perl: tr///r.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#tr/SEARCHLIST/REPLACEMENTLIST/cdsr>
