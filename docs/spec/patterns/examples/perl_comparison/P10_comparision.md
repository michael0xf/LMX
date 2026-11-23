# P10. Частотная таблица с порядком первых вхождений

## Общий наблюдаемый договор

Для списка целых кодов вернуть пары [код,число вхождений], расположенные по первому появлению кода, а не по произвольному порядку хеша.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Общий identity сохраняет готовую запись ключа. map переводит готовые FxGroup в наблюдаемые пары; ручной второй обход и resize не повторяются. FxGroup принимается напрямую по действующему typed-value договору.

## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 315 | 541 | 18 |
| LMX функциональный | 205 | 275 | 11 |
| Perl | 166 | 237 | 11 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int[]: items
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(FxRecordOperands\record\throws)
        @[]: out []
        int: i 0
        while: i < length(items)
            int: j 0
            while: j < length(out) && \out[j]\[0] != items[i]
                j += 1
            if: j = length(out)
                FxSeqPush\append(out; ((items[i]; 0) record))
            @: row out[j]
            int: count \row[1]
            row[1] := ((count + 1) record)
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/P10.lm3). 315 непробельных символов; 18 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Frequency:
    FxGroup@: group
    return: @
    row:
        return: (\group\key; length(group\items))

Example:
    int[]: items
    return: @
    run:
        throws: copy(FxMap\map\throws) copy(FxGroupBy\groupBy\throws)
        return: map(groupBy(items); Frequency\row)
```

[Полный исходник](source/lmx/P10.lm3). 205 непробельных символов; 11 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P10.pl).

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

## Общие библиотечные реализации

- groupBy: [PI04](library_comparisons/PI04_comparision.md)
- map: [PI01](library_comparisons/PI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldsc#HASHES-OF-ARRAYS>
- <https://perldoc.perl.org/5.40.1/functions/exists>
