# P14. Разделение строки без потери пустых полей

## Общий договор

Разделить ASCII-строку по запятым; сохранить начальные, промежуточные и конечные пустые поля. Пустая строка означает одно пустое поле.

Для пустого входа split Perl обычно возвращает пустой список; ветка в клиенте обеспечивает общий договор и входит в измеряемый код.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    "a,,b,"
  ],
  "result": [
    "a",
    "",
    "b",
    ""
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 211 | 166 | 6 |
| Perl | 121 | 92 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P14.lm3).

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: split(byteText(text); ",")
```

## Perl

[Исходник](source/perl/P14.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return length($text) ? [split /,/, $text, -1] : [''];
}
```

## Отдельные реализации

- split: [PI07](library_comparisons/PI07_comparision.md)

Штатные средства Perl: CORE::split.

Построение Pattern/TextView: byteText, literal pattern. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/split>
