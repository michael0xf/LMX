# P15. Проверка полного ASCII-идентификатора

## Общий наблюдаемый договор

Принять целиком строку вида [A-Za-z][A-Za-z0-9_]* и вернуть 0/1. Пустая строка и конечный перевод строки не допускаются.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Используются именно \A и \z; проверка не ослаблена до поиска подстроки или до конца перед последним переводом строки.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "user_21"
  ],
  "result": 1
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 296 | 497 | 18 |
| LMX функциональный | 199 | 245 | 6 |
| Perl | 92 | 118 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Ascii:
    char: value
    return: int
    letter:
        return: (value >= 'A' && value <= 'Z') || (value >= 'a' && value <= 'z')


Example:
    char[]: text
    return: int
    run:
        if: length(text) = 0 || Ascii\letter(text[0]) = 0
            return: 0
        int: i 1
        while: i < length(text)
            char: value text[i]
            if: Ascii\letter(value) = 0 && (value < '0' || value > '9') && value != '_'
                return: 0
            i += 1
        return: 1
```

[Полный исходник](source/lmx/procedural/P15.lm3). 296 непробельных символов; 18 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    return: int
    run:
        throws: copy(byteText\throws) copy(atLeast\throws) copy(RxThenOperand\then\throws) copy(matches\throws)
        return: matches(byteText(text); (then asciiLetter (asciiWord atLeast 0)))
```

[Полный исходник](source/lmx/P15.lm3). 199 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P15.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return 0 + ($text =~ /\A[A-Za-z][A-Za-z0-9_]*\z/);
}
```

## Общие библиотечные реализации

- matches: [PI07](library_comparisons/PI07_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre>
