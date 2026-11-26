# P21. Обратная комплементарная последовательность ДНК

## Общий наблюдаемый договор

Вернуть reverse-complement ASCII-последовательности: одновременно заменить A↔T и C↔G, затем развернуть весь результат. Длина сохраняется; N, дефис, строчные буквы и прочие неуказанные символы только меняют позицию, но не транслитерируются. Это явно профиль uppercase ACGT, а не полная таблица IUPAC. Пустая строка остаётся пустой, вход не меняется.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Два стандартных действия образуют обычный биоинформатический сценарий. Процедурный код сразу пишет комплементарный символ в зеркальную позицию; функциональный использует translate и generic reverse. Perl reverse принудительно вызывается в scalar context.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "ACGTN"
  ],
  "result": "NACGT"
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 286 | 553 | 21 |
| LMX функциональный | 131 | 172 | 6 |
| Perl | <span style="color:#176233"><u>90</u></span> | 115 | 6 |

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
            out[length(text) - 1 - i] := value
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/P21.lm3). 286 непробельных символов; 21 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    return: char[]
    run:
        throws: copy(translate\throws) copy(reverse\throws)
        return: \reverse(translate(text; "ACGT"; "TGCA"))
```

[Полный исходник](source/lmx/P21.lm3). 131 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P21.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return scalar reverse($text =~ tr/ACGT/TGCA/r);
}
```

## Общие библиотечные реализации

- translate: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardText.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).
- reverse: [полное тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#tr/SEARCHLIST/REPLACEMENTLIST/cdsr>
- <https://perldoc.perl.org/5.40.1/functions/reverse>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `["ACGTN"]` | `"NACGT"` | — |
| 2 | `["AAAA"]` | `"TTTT"` | — |
| 3 | `[""]` | `""` | — |
| 4 | `["AAGC"]` | `"GCTT"` | — |
| 5 | `["A-N"]` | `"N-T"` | — |
