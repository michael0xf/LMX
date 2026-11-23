# P20. Обратная ссылка на одинаковое слово

## Общий наблюдаемый договор

Принять ровно два одинаковых непустых ASCII-слова, разделённых одним пробелом; сравнение чувствительно к регистру, вся строка должна совпасть.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.



## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "cat cat"
  ],
  "result": 1
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 312 | 545 | 20 |
| LMX функциональный | 318 | 369 | 6 |
| Perl | 97 | 124 | 6 |

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
        int: at 0
        while: at < length(text) && Ascii\letter(text[at]) != 0
            at += 1
        if: at = 0 || at = length(text) || text[at] != ' ' || length(text) - at - 1 != at
            return: 0
        int: i 0
        while: i < at
            if: text[i] != text[at + 1 + i]
                return: 0
            i += 1
        return: 1
```

[Полный исходник](source/lmx/procedural/P20.lm3). 312 непробельных символов; 20 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    return: int
    run:
        throws: copy(RxByteText\byteText\throws) copy(RxRepeatOperands\atLeast\throws) copy(RxCapture\capture\throws) copy(RxSameAs\sameAs\throws) copy(RxThenOperand\then\throws) copy(RxMatches\matches\throws)
        return: matches(byteText(text); (then capture("word"; (asciiLetter atLeast 1)) " " sameAs("word")))
```

[Полный исходник](source/lmx/P20.lm3). 318 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P20.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return 0 + ($text =~ /\A(?<word>[A-Za-z]+) \k<word>\z/);
}
```

## Общие библиотечные реализации

- matches: [PI07](library_comparisons/PI07_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre#Capture-groups>
