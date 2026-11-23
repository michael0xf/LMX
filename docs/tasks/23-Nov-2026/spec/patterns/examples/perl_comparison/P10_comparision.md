# P10. Частотная таблица с порядком первых вхождений

## Общий договор

Для списка целых кодов вернуть пары [код,число вхождений], расположенные по первому появлению кода, а не по произвольному порядку хеша.



## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      2,
      1,
      2,
      3,
      1,
      2
    ]
  ],
  "result": [
    [
      2,
      3
    ],
    [
      1,
      2
    ],
    [
      3,
      1
    ]
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 625 | 413 | 25 |
| Perl | 237 | 166 | 11 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P10.lm3).

```lmx
Identity:
    int: value
    return: int
    key:
        return: value

Same:
    int: first
    int: second
    return: int
    test:
        return: first = second

Example:
    int[]: items
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        @: groups groupBy(items; Identity\key; Same\test)
        @[]: result []
        sys\resize(result; length(groups))
        int: i 0
        while: i < length(groups)
            @: group groups[i]
            result[i] := (\group\key; length(group\items))
            i += 1
        return: result
```

## Perl

[Исходник](source/perl/P10.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items) = @_;
    my (%count, @order);
    for (@$items) {
        push @order, $_ unless exists $count{$_};
        ++$count{$_};
    }
    return [map { [0 + $_, $count{$_}] } @order];
}
```

## Отдельные реализации

- groupBy: [PI04](library_comparisons/PI04_comparision.md)

Штатные средства Perl: hash, CORE::exists, CORE::push, CORE::map.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldsc#HASHES-OF-ARRAYS>
- <https://perldoc.perl.org/5.40.1/functions/exists>
