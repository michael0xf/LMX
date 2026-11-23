# P04. Все промежуточные остатки счёта

## Общий договор

Из начального остатка и списка изменений получить начальный остаток и все последующие суммы, в том числе начальный элемент для пустого списка.



## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      5,
      -3,
      8
    ],
    100
  ],
  "result": [
    100,
    105,
    102,
    110
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 314 | 225 | 161 | 13 |
| Perl | 162 | 129 | 129 | 7 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P04.lm3).

```lmx
Add:
    int: total
    int: delta
    return: int
    run:
        return: total + delta

Example:
    int[]: deltas
    int: initial
    return: @
    run:
        throws: FxRecordArity FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: scanl(deltas; (initial record); Add\run)
```

## Perl

[Исходник](source/perl/P04.pl).

```perl
use strict;
use warnings;
use List::Util qw(reductions);
sub example {
    my ($deltas, $initial) = @_;
    return [reductions { $a + $b } $initial, @$deltas];
}
```

## Отдельные реализации

- scanl: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: List::Util::reductions.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/List::Util#reductions>
