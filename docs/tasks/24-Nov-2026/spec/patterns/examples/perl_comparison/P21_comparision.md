# P21. Транслитерация алфавита ДНК

## Общий наблюдаемый договор

Вернуть новую строку с одновременной заменой A↔T и C↔G. Другие ASCII-символы и длина не меняются; уже заменённые символы повторно не обрабатываются.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Общий translate реализует буквальное одновременное соответствие алфавитов и сохраняет прочие символы. Его полное тело и зависимости учитываются отдельно; локального повторного цикла нет.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "ACGTN"
  ],
  "result": "TGCAN"
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 271 | 534 | 21 |
| LMX функциональный | 101 | 141 | 6 |
| Perl | 75 | 99 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    char[]: text
    return: char[]
    run:
        throws: copy(sys\resize\throws)
        char[]: from "ACGT"
        char[]: to "TGCA"
        char[]: out []
        sys\resize(out; length(text))
        int: i 0
        while: i < length(text)
            char: value text[i]
            int: j 0
            while: j < length(from)
                if: value = from[j]
                    value := to[j]
                    break
                j += 1
            out[i] := value
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/P21.lm3). 271 непробельных символов; 21 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    return: char[]
    run:
        throws: copy(translate\throws)
        return: translate(text; "ACGT"; "TGCA")
```

[Полный исходник](source/lmx/P21.lm3). 101 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P21.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return $text =~ tr/ACGT/TGCA/r;
}
```

## Общие библиотечные реализации

- translate: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardText.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#tr/SEARCHLIST/REPLACEMENTLIST/cdsr>
