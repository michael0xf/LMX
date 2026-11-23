# P23. Ленивый итератор, в котором ноль не означает конец

## Общий договор

Итератор выдаёт квадраты 0..limit−1 по одному и завершается отдельно от значения. Собрать его в список; limit неотрицателен. Нулевой первый элемент нельзя потерять как false.

merge задаёт limit в модельном слоте отдельного скопированного владельца генератора. collect завершает обход только по Stop источника и сохраняет 0 как элемент; другие объявленные отказы producer сохраняются в FxCallFailure. Результат — массив полных записей значений; плотный int[] не требуется общим договором. Фонового потока или продления activation не добавлено.

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

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 462 | 263 | 250 | 19 |
| Perl | 346 | 242 | 242 | 16 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

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
        throws: copy(FxThrows\mutation) FxCallFailure
        @: source (merge(Squares; (int: limit limit)))
        return: collect(source\Next\next)
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

- collect: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx); [транзитивные зависимости](library_comparisons/shared_dependencies.lmx). Отдельная Perl-пара этой операции не написана.

Штатные средства Perl: closure iterator, CORE::defined.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlref#Anonymous-Subroutines>
- <https://perldoc.perl.org/5.40.1/functions/defined>
