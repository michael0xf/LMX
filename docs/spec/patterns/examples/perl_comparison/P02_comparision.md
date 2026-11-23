# P02. Отбор элементов через grep

## Общий договор

Сохранить только чётные целые числа, включая ноль и отрицательные; сохранить исходный порядок и повторы.



## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      -3,
      -2,
      0,
      1,
      2,
      2
    ]
  ],
  "result": [
    -2,
    0,
    2,
    2
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 251 | 175 | 11 |
| Perl | 107 | 77 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P02.lm3).

```lmx
Even:
    int: value
    return: int
    run:
        return: value % 2 = 0

Example:
    int[]: items
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: filter(items; Even\run)
```

## Perl

[Исходник](source/perl/P02.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items) = @_;
    return [grep { $_ % 2 == 0 } @$items];
}
```

## Отдельные реализации

- filter: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: CORE::grep.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/grep>
