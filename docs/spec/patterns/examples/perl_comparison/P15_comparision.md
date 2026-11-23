# P15. Проверка полного ASCII-идентификатора

## Общий договор

Принять целиком строку вида [A-Za-z][A-Za-z0-9_]* и вернуть 0/1. Пустая строка и конечный перевод строки не допускаются.

Используются именно \A и \z; проверка не ослаблена до поиска подстроки или до конца перед последним переводом строки.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    "user_21"
  ],
  "result": 1
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 252 | 203 | 122 | 6 |
| Perl | 118 | 92 | 92 | 6 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P15.lm3).

```lmx
Example:
    char[]: text
    return: int
    run:
        throws: PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: matches(byteText(text); (then asciiLetter (asciiWord atLeast 0)))
```

## Perl

[Исходник](source/perl/P15.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return 0 + ($text =~ /\A[A-Za-z][A-Za-z0-9_]*\z/);
}
```

## Отдельные реализации

- matches: [PI07](library_comparisons/PI07_comparision.md)

Штатные средства Perl: regex anchors, regex character classes.

Построение Pattern/TextView: byteText, then, atLeast, asciiLetter, asciiWord. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre>
