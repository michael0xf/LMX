# P01. Преобразование списка через map

## Общий договор

Вернуть новый список, умножив каждое целое число на 3; порядок и нули сохраняются. Вход не меняется.



## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      -2,
      0,
      3
    ]
  ],
  "result": [
    -6,
    0,
    9
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 246 | 172 | 11 |
| Perl | 101 | 73 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P01.lm3).

```lmx
Scale:
    int: value
    return: int
    run:
        return: value * 3

Example:
    int[]: items
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: map(items; Scale\run)
```

## Perl

[Исходник](source/perl/P01.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items) = @_;
    return [map { $_ * 3 } @$items];
}
```

## Отдельные реализации

- map: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: CORE::map.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/map>
