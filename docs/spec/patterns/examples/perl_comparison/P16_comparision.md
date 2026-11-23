# P16. Именованные группы с явным отсутствием

## Общий наблюдаемый договор

Разобрать всю строку key=value, где key — непустые ASCII-буквы, value — непустые ASCII-цифры. Вернуть [1,key,value] либо [0,"",""]. Ведущие нули значения сохраняются.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Схема использует уникальные имена групп. История всех повторных захватов LMX не сравнивается с одним значением %+.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "Port=0080"
  ],
  "result": [
    1,
    "Port",
    "0080"
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 549 | 944 | 33 |
| LMX функциональный | 508 | 626 | 11 |
| Perl | 144 | 180 | 7 |

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
    return: @
    run:
        throws: copy(sys\resize\throws)
        int: at 0
        while: at < length(text) && Ascii\letter(text[at]) != 0
            at += 1
        if: at = 0 || at = length(text) || text[at] != '='
            return: (0; ""; "")
        int: begin at + 1
        if: begin = length(text)
            return: (0; ""; "")
        char[]: key []
        char[]: value []
        sys\resize(key; at)
        sys\resize(value; length(text) - begin)
        int: i 0
        while: i < at
            key[i] := text[i]
            i += 1
        i := begin
        while: i < length(text)
            if: text[i] < '0' || text[i] > '9'
                return: (0; ""; "")
            value[i - begin] := text[i]
            i += 1
        return: (1; key; value)
```

[Полный исходник](source/lmx/procedural/P16.lm3). 549 непробельных символов; 33 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: copy(RxByteText\byteText\throws) copy(RxRepeatOperands\atLeast\throws) copy(RxCapture\capture\throws) copy(RxThenOperand\then\throws) copy(RxWholeMatch\wholeMatch\throws) copy(RxCaptureValue\captureValue\throws)
        @: parsed wholeMatch(byteText(text); (then capture("key"; (asciiLetter atLeast 1)) "=" capture("value"; (asciiDigit atLeast 1))))
        if: parsed\present = 0
            return: (0; ""; "")
        @: key captureValue(parsed\value; "key")
        @: value captureValue(parsed\value; "value")
        return: (1; \key\value; \value\value)
```

[Полный исходник](source/lmx/P16.lm3). 508 непробельных символов; 11 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P16.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return [0, '', ''] unless $text =~ /\A(?<key>[A-Za-z]+)=(?<value>[0-9]+)\z/;
    return [1, $+{key}, $+{value}];
}
```

## Общие библиотечные реализации

- wholeMatch: [PI07](library_comparisons/PI07_comparision.md)
- captureValue: [PI07](library_comparisons/PI07_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre#Capture-groups>
