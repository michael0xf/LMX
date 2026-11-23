# P22. Независимые замыкания со своим счётчиком

## Общий договор

Создать два независимых счётчика: первый стартует с initial, второй со 100. Последовательно прибавить первому 1 и 3, второму 2, первому −2; вернуть все четыре результата.

make_counter — определение предметного объекта этого примера, не импорт сравниваемой библиотеки. Два состояния изолированы; неподвижное число 100 — второй тестовый старт, не ограничение механизма.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    10
  ],
  "result": [
    11,
    14,
    102,
    12
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 593 | 365 | 24 |
| Perl | 288 | 224 | 12 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P22.lm3).

```lmx
Counter:
    int: value 0
    Add:
        int: delta
        return: int
        add:
            @: owner parent(node)
            owner\value += delta
            return: owner\value

Example:
    int: initial
    return: @
    run:
        @: first (copy(Counter))
        first := parent(first\Add)
        @: second (copy(Counter))
        second := parent(second\Add)
        first\value := initial
        second\value := 100
        int: a first\Add\add(1)
        int: b first\Add\add(3)
        int: c second\Add\add(2)
        int: d first\Add\add(-2)
        return: (a; b; c; d)
```

## Perl

[Исходник](source/perl/P22.pl).

```perl
use strict;
use warnings;
sub make_counter {
    my ($value) = @_;
    return sub { $value += shift };
}
sub example {
    my ($initial) = @_;
    my $first = make_counter($initial);
    my $second = make_counter(100);
    return [$first->(1), $first->(3), $second->(2), $first->(-2)];
}
```

## Отдельные реализации

Только базовые средства языка и определения предметного объекта примера; отдельного библиотечного импорта нет.

Штатные средства Perl: lexical closure, anonymous subroutine.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlref#Anonymous-Subroutines>
- <https://perldoc.perl.org/5.40.1/perlsub#Persistent-Private-Variables>
