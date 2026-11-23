# P08. Стабильная сортировка записей

## Общий договор

Новый список записей по возрастанию priority; для равного priority сохранить прежний порядок. Все остальные поля, включая width, и идентичность записей сохраняются.

Компаратор LMX сравнивает, а не вычитает пользовательские ключи: сортировка не вводит переполнение разности.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      {
        "priority": 2,
        "id": "a",
        "width": 8
      },
      {
        "priority": 1,
        "id": "b",
        "width": 4
      },
      {
        "priority": 2,
        "id": "c",
        "width": 12
      }
    ]
  ],
  "result": [
    {
      "priority": 1,
      "id": "b",
      "width": 4
    },
    {
      "priority": 2,
      "id": "a",
      "width": 8
    },
    {
      "priority": 2,
      "id": "c",
      "width": 12
    }
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 341 | 256 | 190 | 12 |
| Perl | 148 | 117 | 117 | 7 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P08.lm3).

```lmx
Order:
    @: first
    @: second
    return: int
    compare:
        return: (first\priority > second\priority) - (first\priority < second\priority)

Example:
    @: items
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        return: sort(items; Order\compare)
```

## Perl

[Исходник](source/perl/P08.pl).

```perl
use strict;
use warnings;
use sort 'stable';
sub example {
    my ($items) = @_;
    return [sort { $a->{priority} <=> $b->{priority} } @$items];
}
```

## Отдельные реализации

- sort: [PI03](library_comparisons/PI03_comparision.md)

Штатные средства Perl: CORE::sort, sort pragma.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/sort>
- <https://perldoc.perl.org/5.40.1/sort>
