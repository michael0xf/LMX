# P23. Ленивый итератор, в котором ноль не означает конец

## Общий наблюдаемый договор

Итератор выдаёт квадраты 0..limit−1 по одному и завершается отдельно от значения. Собрать его в список; limit неотрицателен. Нулевой первый элемент нельзя потерять как false.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

merge задаёт limit в модельном слоте отдельного скопированного владельца генератора. collect завершает обход только по Stop источника и сохраняет 0 как элемент; другие объявленные отказы producer сохраняются в FxCallFailure. Результат — массив полных записей значений; плотный int[] не требуется общим договором. Фонового потока или продления activation не добавлено.

## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 390 | 657 | 24 |
| LMX функциональный | 260 | 458 | 19 |
| Perl | 242 | 346 | 16 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

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
        throws: copy(Squares\Next\next\throws) copy(FxSeqPush\append\throws) copy(FxRecordOperands\record\throws)
        @: source (merge(Squares; (int: limit limit)))
        @[]: out []
        while: 1
            int: value source\Next\next()
            FxSeqPush\append(out; (value record))
        catch: Stop()
            return: out
```

[Полный исходник](source/lmx/procedural/P23.lm3). 390 непробельных символов; 24 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

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
        throws: copy(FxStdCollect\collect\throws)
        @: source (merge(Squares; (int: limit limit)))
        return: collect(source\Next\next)
```

[Полный исходник](source/lmx/P23.lm3). 260 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P23.pl).

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

## Общие библиотечные реализации

- collect: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlref#Anonymous-Subroutines>
- <https://perldoc.perl.org/5.40.1/functions/defined>
