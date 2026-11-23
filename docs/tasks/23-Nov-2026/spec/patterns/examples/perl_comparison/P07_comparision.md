# P07. Изменение массива с возвратом удалённых

## Общий договор

Заменить диапазон [begin,end) и вернуть [тот же изменённый массив, новый список удалённых элементов]. Вставляемые значения читаются до изменения; пустые вставка и удаление допустимы.

В Perl третий параметр — длина, в LMX — исключённый конец. Это преобразование видно в исходнике и входит в подсчёт.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      1,
      2,
      3,
      4
    ],
    1,
    3,
    [
      8,
      9,
      10
    ]
  ],
  "result": [
    [
      1,
      8,
      9,
      10,
      4
    ],
    [
      2,
      3
    ]
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 260 | 185 | 10 |
| Perl | 186 | 146 | 7 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P07.lm3).

```lmx
Example:
    @: items
    int: begin
    int: end
    @: values
    return: @
    run:
        throws: FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        @: removed splice(items; begin; end; values)
        return: (items; removed)
```

## Perl

[Исходник](source/perl/P07.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items, $begin, $end, $values) = @_;
    my @removed = splice @$items, $begin, $end - $begin, @$values;
    return [$items, \@removed];
}
```

## Отдельные реализации

- splice: [PI02](library_comparisons/PI02_comparision.md)

Штатные средства Perl: CORE::splice.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/splice>
