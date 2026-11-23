# P05. Короткое замыкание any и all

## Общий договор

Вернуть два булевых int: существует ли отрицательный элемент; все ли элементы меньше 10. На пустом списке результат [0,1].



## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      -1,
      20
    ]
  ],
  "result": [
    1,
    0
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 357 | 250 | 16 |
| Perl | 166 | 123 | 7 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P05.lm3).

```lmx
Negative:
    int: value
    return: int
    run:
        return: value < 0

BelowTen:
    int: value
    return: int
    run:
        return: value < 10

Example:
    int[]: items
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxPredicate FxTypeToken ReceiverIndex
        return: (any(items; Negative\run); all(items; BelowTen\run))
```

## Perl

[Исходник](source/perl/P05.pl).

```perl
use strict;
use warnings;
use List::Util qw(any all);
sub example {
    my ($items) = @_;
    return [0 + (any { $_ < 0 } @$items), 0 + (all { $_ < 10 } @$items)];
}
```

## Отдельные реализации

- any: [PI01](library_comparisons/PI01_comparision.md)
- all: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: List::Util::any, List::Util::all.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/List::Util#any>
- <https://perldoc.perl.org/5.40.1/List::Util#all>
