# P19. Вычисляемая замена с сохранением ширины

## Общий договор

Каждую максимальную последовательность ASCII-цифр заменить таким же количеством звёздочек. Длина строки и прочие символы сохраняются; callback вызывается один раз на выбранное совпадение.

Здесь ширина совпадения — часть задачи, поэтому более короткая замена каждого числа единственным символом была бы другой программой.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    "card 1234 / 09"
  ],
  "result": "card **** / **"
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 652 | 474 | 19 |
| Perl | 114 | 88 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P19.lm3).

```lmx
Mask:
    Match@: matched
    return: char[]
    make:
        throws: PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        char[]: text matchedText(matched)
        char[]: result []
        sys\resize(result; length(text))
        int: i 0
        while: i < length(text)
            result[i] := '*'
            i += 1
        return: result

Example:
    char[]: text
    return: char[]
    run:
        throws: PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: replace(byteText(text); (asciiDigit atLeast 1); Mask\make)
```

## Perl

[Исходник](source/perl/P19.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return $text =~ s/[0-9]+/'*' x length($&)/ger;
}
```

## Отдельные реализации

- replace: [PI07](library_comparisons/PI07_comparision.md)
- matchedText: [PI07](library_comparisons/PI07_comparision.md)

Штатные средства Perl: s///ger, string repetition x.

Построение Pattern/TextView: byteText, atLeast, asciiDigit. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer>
- <https://perldoc.perl.org/5.40.1/perlop#Multiplicative-Operators>
