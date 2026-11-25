# P22. Независимые замыкания со своим счётчиком

## Общий наблюдаемый договор

Создать два независимых счётчика: первый стартует с initial, второй со 100. Последовательно прибавить первому 1 и 3, второму 2, первому −2; вернуть все четыре результата.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

make_counter — определение предметного объекта примера. Каждое merge использует свою карту копирования и задаёт начальное value в модельном слоте реального скопированного владельца. Вызовы в return выполняются в записанном порядке; состояния независимы.

## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 522 | 777 | 26 |
| LMX функциональный | 290 | 436 | 16 |
| Perl | 224 | 288 | 12 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

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
        throws: copy(FxSeqPush\append\throws) copy(record\throws)
        @: first (merge(Counter; (int: value initial)))
        @: second (merge(Counter; (int: value 100)))
        @[]: out []
        int: value first\Add\add(1)
        FxSeqPush\append(out; (value record))
        value := first\Add\add(3)
        FxSeqPush\append(out; (value record))
        value := second\Add\add(2)
        FxSeqPush\append(out; (value record))
        value := first\Add\add(-2)
        FxSeqPush\append(out; (value record))
        return: out
```

[Полный исходник](source/lmx/procedural/P22.lm3). 522 непробельных символов; 26 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

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
        @: first (merge(Counter; (int: value initial)))
        @: second (merge(Counter; (int: value 100)))
        return: (first\Add\add(1); first\Add\add(3); second\Add\add(2); first\Add\add(-2))
```

[Полный исходник](source/lmx/P22.lm3). 290 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P22.pl).

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

## Общие библиотечные реализации

Используются базовые операции языка; предметные определения приведены целиком.

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlref#Anonymous-Subroutines>
- <https://perldoc.perl.org/5.40.1/perlsub#Persistent-Private-Variables>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[10]` | `[11,14,102,12]` | — |
| 2 | `[0]` | `[1,4,102,2]` | — |
| 3 | `[-5]` | `[-4,-1,102,-3]` | — |
