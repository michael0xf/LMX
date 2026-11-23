# P03. Сумма с нейтральным значением

## Общий договор

Сумма конечного списка целых чисел; пустой список даёт 0. Примеры не выходят за диапазон машинного int LMX.



## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      7,
      -2,
      0,
      4
    ]
  ],
  "result": 9
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 279 | 197 | 12 |
| Perl | 115 | 90 | 7 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P03.lm3).

```lmx
Add:
    int: total
    int: value
    return: int
    run:
        return: total + value

Example:
    int[]: items
    return: int
    run:
        throws: FxRecordArity FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex
        return: \foldl(items; (0 record); Add\run)
```

## Perl

[Исходник](source/perl/P03.pl).

```perl
use strict;
use warnings;
use List::Util qw(sum0);
sub example {
    my ($items) = @_;
    return sum0(@$items);
}
```

## Отдельные реализации

- foldl: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: List::Util::sum0.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/List::Util#sum0>
