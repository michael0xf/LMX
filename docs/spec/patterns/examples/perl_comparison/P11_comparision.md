# P11. Автовивификация групп записей

## Общий договор

Сгруппировать целые записи по целому kind. Порядок групп — первое появление kind, порядок записей внутри группы — исходный. Никакие поля записи не удаляются.

После общей группировки map меняет только внешний формат наблюдения; группы и все поля событий сохраняются, без второго самописного цикла.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      {
        "kind": 2,
        "text": "a",
        "width": 8
      },
      {
        "kind": 1,
        "text": "b",
        "width": 4
      },
      {
        "kind": 2,
        "text": "c",
        "width": 12
      }
    ]
  ],
  "result": [
    [
      2,
      [
        {
          "kind": 2,
          "text": "a",
          "width": 8
        },
        {
          "kind": 2,
          "text": "c",
          "width": 12
        }
      ]
    ],
    [
      1,
      [
        {
          "kind": 1,
          "text": "b",
          "width": 4
        }
      ]
    ]
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 434 | 296 | 281 | 22 |
| Perl | 305 | 218 | 218 | 12 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P11.lm3).

```lmx
Key:
    @: event
    return: int
    get:
        return: event\kind

Same:
    int: first
    int: second
    return: int
    test:
        return: first = second

GroupRow:
    FxGroup@: group
    return: @
    row:
        return: (\group\key; group\items)

Example:
    @: items
    return: @
    run:
        throws: copy(FxThrows\traversal) SequenceElement
        return: map(groupBy(items; Key\get; Same\test); GroupRow\row)
```

## Perl

[Исходник](source/perl/P11.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items) = @_;
    my (%groups, @order);
    for my $event (@$items) {
        my $key = $event->{kind};
        push @order, $key unless exists $groups{$key};
        push @{$groups{$key}}, $event;
    }
    return [map { [0 + $_, $groups{$_}] } @order];
}
```

## Отдельные реализации

- groupBy: [PI04](library_comparisons/PI04_comparision.md)
- map: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: hash autovivification, CORE::push, CORE::map.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldsc#HASHES-OF-ARRAYS>
- <https://perldoc.perl.org/5.40.1/perlref>
