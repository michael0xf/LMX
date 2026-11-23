# P16. Именованные группы с явным отсутствием

## Общий договор

Разобрать всю строку key=value, где key — непустые ASCII-буквы, value — непустые ASCII-цифры. Вернуть [1,key,value] либо [0,"",""]. Ведущие нули значения сохраняются.

Схема использует уникальные имена групп. История всех повторных захватов LMX не сравнивается с одним значением %+.

## Вход и ожидаемый результат

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

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 515 | 396 | 315 | 11 |
| Perl | 180 | 144 | 144 | 7 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P16.lm3).

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        @: parsed wholeMatch(byteText(text); (then capture("key"; (asciiLetter atLeast 1)) "=" capture("value"; (asciiDigit atLeast 1))))
        if: parsed\present = 0
            return: (0; ""; "")
        @: key captureText(parsed\value; "key")
        @: value captureText(parsed\value; "value")
        return: (1; \key\value; \value\value)
```

## Perl

[Исходник](source/perl/P16.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return [0, '', ''] unless $text =~ /\A(?<key>[A-Za-z]+)=(?<value>[0-9]+)\z/;
    return [1, $+{key}, $+{value}];
}
```

## Отдельные реализации

- wholeMatch: [PI07](library_comparisons/PI07_comparision.md)
- captureText: [PI07](library_comparisons/PI07_comparision.md)

Штатные средства Perl: named captures, %+.

Построение Pattern/TextView: byteText, then, atLeast, capture, asciiLetter, asciiDigit. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre#Capture-groups>
