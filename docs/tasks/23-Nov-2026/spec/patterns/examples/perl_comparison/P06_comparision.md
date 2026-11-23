# P06. Срез с перестановкой и повторением

## Общий договор

Выбрать элементы по списку допустимых нулевых индексов; порядок индексов и повторы существенны. Результат — новый внешний массив, вложенные ссылки сохраняются.

Контракт клиента ограничивает индексы диапазоном 0..n-1. Отрицательные и выходящие за массив индексы Perl имеют другую семантику; отдельно проверяемая общая реализация отвергает их явно.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      "a",
      "b",
      "c"
    ],
    [
      2,
      0,
      2
    ]
  ],
  "result": [
    "c",
    "a",
    "c"
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 178 | 130 | 7 |
| Perl | 111 | 88 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P06.lm3).

```lmx
Example:
    @: items
    int[]: positions
    return: @
    run:
        throws: FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: select(items; positions)
```

## Perl

[Исходник](source/perl/P06.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items, $positions) = @_;
    return [@$items[@$positions]];
}
```

## Отдельные реализации

- select: [PI02](library_comparisons/PI02_comparision.md)

Штатные средства Perl: array slice.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldata#Slices>
