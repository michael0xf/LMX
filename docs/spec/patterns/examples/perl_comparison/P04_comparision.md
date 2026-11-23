# P04. Все промежуточные остатки счёта

## Общий наблюдаемый договор

Из начального остатка и списка изменений получить начальный остаток и все последующие суммы, в том числе начальный элемент для пустого списка.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.



## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 268 | 414 | 15 |
| LMX функциональный | 150 | 198 | 7 |
| Perl | 129 | 162 | 7 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int[]: deltas
    int: initial
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(FxRecordOperands\record\throws)
        @[]: out []
        int: total initial
        FxSeqPush\append(out; (total record))
        int: i 0
        while: i < length(deltas)
            total += deltas[i]
            FxSeqPush\append(out; (total record))
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/P04.lm3). 268 непробельных символов; 15 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: deltas
    int: initial
    return: @
    run:
        throws: copy(FxScan\scan\throws) copy(FxRecordOperands\record\throws)
        return: scanl(deltas; (initial record); `+`)
```

[Полный исходник](source/lmx/P04.lm3). 150 непробельных символов; 7 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P04.pl).

```perl
use strict;
use warnings;
use List::Util qw(reductions);
sub example {
    my ($deltas, $initial) = @_;
    return [reductions { $a + $b } $initial, @$deltas];
}
```

## Общие библиотечные реализации

- scanl: [PI01](library_comparisons/PI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/List::Util#reductions>
