# P13. Map с выдачей нескольких элементов

## Общий договор

Сплющить ровно один уровень списка списков, сохранив порядок. Пустые внутренние списки ничего не добавляют; более глубокие массивы остаются отдельными элементами.



## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      [
        1,
        2
      ],
      [],
      [
        3
      ]
    ]
  ],
  "result": [
    1,
    2,
    3
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 234 | 162 | 11 |
| Perl | 96 | 70 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P13.lm3).

```lmx
Row:
    @: values
    return: @
    get:
        return: values

Example:
    @: rows
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: flatMap(rows; Row\get)
```

## Perl

[Исходник](source/perl/P13.pl).

```perl
use strict;
use warnings;
sub example {
    my ($rows) = @_;
    return [map { @$_ } @$rows];
}
```

## Отдельные реализации

- flatMap: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: CORE::map.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/map>
- <https://perldoc.perl.org/5.40.1/perllol>
