# P11. Автовивификация групп записей

## Общий наблюдаемый договор

Сгруппировать целые записи по целому kind. Порядок групп — первое появление kind, порядок записей внутри группы — исходный. Никакие поля записи не удаляются.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

После общей группировки map меняет только внешний формат наблюдения; группы и все поля событий сохраняются, без второго самописного цикла.

## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 430 | 713 | 22 |
| LMX функциональный | 225 | 325 | 16 |
| Perl | 218 | 305 | 12 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: items
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqRead\read\throws) copy(FxSeqPush\append\throws) copy(record\throws)
        FxSeqInfo\get(items)
        @[]: out []
        int: i 0
        while: i < length(items)
            @: held FxSeqRead\read(items; i)
            @: event \held
            int: key event\kind
            int: j 0
            while: j < length(out) && \out[j]\[0] != key
                j += 1
            if: j = length(out)
                @: group (copy(()))
                FxSeqPush\append(out; ((key; group) record))
            @: group \out[j]\[1]
            FxSeqPush\append(group; held)
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/P11.lm3). 430 непробельных символов; 22 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Key:
    @: event
    return: int
    get:
        return: event\kind

GroupRow:
    FxGroup@: group
    return: @
    row:
        return: (\group\key; group\items)

Example:
    @: items
    return: @
    run:
        throws: copy(map\throws) copy(groupBy\throws)
        return: map(groupBy(items; Key\get); GroupRow\row)
```

[Полный исходник](source/lmx/P11.lm3). 225 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P11.pl).

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

## Общие библиотечные реализации

- groupBy: [PI04](library_comparisons/PI04_comparision.md)
- map: [PI01](library_comparisons/PI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldsc#HASHES-OF-ARRAYS>
- <https://perldoc.perl.org/5.40.1/perlref>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[[{"kind":2,"text":"a","width":8},{"kind":1,"text":"b","width":4},{"kind":2,"text":"c","width":12}]]` | `[[2,[{"kind":2,"text":"a","width":8},{"kind":2,"text":"c","width":12}]],[1,[{"kind":1,"text":"b","width":4}]]]` | — |
| 2 | `[[]]` | `[]` | — |
| 3 | `[[{"kind":2,"text":"a","width":8}]]` | `[[2,[{"kind":2,"text":"a","width":8}]]]` | — |
