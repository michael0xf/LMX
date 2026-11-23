# P19. Вычисляемая замена с сохранением ширины

## Общий договор

Каждую максимальную последовательность ASCII-цифр заменить таким же количеством звёздочек. Длина строки и прочие символы сохраняются; callback вызывается один раз на выбранное совпадение.

Ширина берётся из готового диапазона Match в byteText: повторного копирования matchedText не нужно. repeatText формирует ровно столько звёздочек, а replace вызывает Mask один раз на совпадение.

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

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 374 | 287 | 242 | 12 |
| Perl | 114 | 88 | 88 | 6 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P19.lm3).

```lmx
Mask:
    Match@: matched
    return: char[]
    make:
        throws: copy(FxThrows\sequence)
        return: repeatText("*"; matched\end - matched\begin)

Example:
    char[]: text
    return: char[]
    run:
        throws: copy(FxThrows\sequence) PatternArgument PatternEncoding PatternPosition
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
- repeatText: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardText.lmx); [транзитивные зависимости](library_comparisons/shared_dependencies.lmx). Отдельная Perl-пара этой операции не написана.

Штатные средства Perl: s///ger, string repetition x.

Построение Pattern/TextView: byteText, atLeast, asciiDigit. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer>
- <https://perldoc.perl.org/5.40.1/perlop#Multiplicative-Operators>
