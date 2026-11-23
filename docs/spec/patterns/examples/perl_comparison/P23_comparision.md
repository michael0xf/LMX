# P23. Ленивый итератор, в котором ноль не означает конец

## Общий договор

Итератор выдаёт квадраты 0..limit−1 по одному и завершается отдельно от значения. Собрать его в список; limit неотрицателен. Нулевой первый элемент нельзя потерять как false.

Stop LMX и undef Perl служат отдельным окончанием. Это синхронная ленивость; фонового потока или обещания асинхронности здесь нет.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    4
  ],
  "result": [
    0,
    1,
    4,
    9
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 696 | 364 | 29 |
| Perl | 346 | 242 | 16 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P23.lm3).

```lmx
Squares:
    int: limit 0
    Next:
        return: int
        next:
            throws: Stop
            @: owner parent(node)
            int: i 0
            while: i < owner\limit
                yield: i * i
                i += 1
            throw: Stop()

Example:
    int: limit
    return: @
    run:
        @: source (copy(Squares))
        source := parent(source\Next)
        source\limit := limit
        @: next source\Next\next
        int[]: result []
        while: 1
            int: value next()
            catch: Stop ()
                break
            int: at length(result)
            sys\resize(result; at + 1)
            result[at] := value
        return: result
```

## Perl

[Исходник](source/perl/P23.pl).

```perl
use strict;
use warnings;
sub squares {
    my ($limit) = @_;
    my $i = 0;
    return sub { return undef if $i >= $limit; my $n = $i++; return $n * $n };
}
sub example {
    my ($limit) = @_;
    my $next = squares($limit);
    my @result;
    while (defined(my $value = $next->())) {
        push @result, $value;
    }
    return \@result;
}
```

## Отдельные реализации

Только базовые средства языка и определения предметного объекта примера; отдельного библиотечного импорта нет.

Штатные средства Perl: closure iterator, CORE::defined.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlref#Anonymous-Subroutines>
- <https://perldoc.perl.org/5.40.1/functions/defined>
