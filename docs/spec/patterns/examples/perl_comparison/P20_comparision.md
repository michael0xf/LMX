# P20. Обратная ссылка на одинаковое слово

## Общий договор

Принять ровно два одинаковых непустых ASCII-слова, разделённых одним пробелом; сравнение чувствительно к регистру, вся строка должна совпасть.



## Вход и ожидаемый результат

```json
{
  "arguments": [
    "cat cat"
  ],
  "result": 1
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 278 | 226 | 145 | 6 |
| Perl | 124 | 97 | 97 | 6 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P20.lm3).

```lmx
Example:
    char[]: text
    return: int
    run:
        throws: PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: matches(byteText(text); (then capture("word"; (asciiLetter atLeast 1)) " " sameAs("word")))
```

## Perl

[Исходник](source/perl/P20.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return 0 + ($text =~ /\A(?<word>[A-Za-z]+) \k<word>\z/);
}
```

## Отдельные реализации

- matches: [PI07](library_comparisons/PI07_comparision.md)

Штатные средства Perl: named backreference.

Построение Pattern/TextView: byteText, then, atLeast, capture, sameAs, asciiLetter. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre#Capture-groups>
