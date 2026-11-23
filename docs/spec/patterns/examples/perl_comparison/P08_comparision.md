# P08. Стабильная сортировка записей

## Общий наблюдаемый договор

Новый список записей по возрастанию priority; для равного priority сохранить прежний порядок. Все остальные поля, включая width, и идентичность записей сохраняются.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Компаратор LMX сравнивает, а не вычитает пользовательские ключи: сортировка не вводит переполнение разности. Общий домен ключей — согласованный полный порядок для сравниваемых >/< и иностранного порядка; специальные NaN/частичные порядки не приписываются этому компаратору. Тип записей и набор их полей не ограничиваются int.

## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 507 | 812 | 22 |
| LMX функциональный | 201 | 281 | 12 |
| Perl | 117 | 148 | 7 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: items
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws)
        @: info FxSeqInfo\get(items)
        @: out FxSeqAllocate\make(info\arrayType; length(items))
        int: i 0
        while: i < length(items)
            @: held FxSeqRead\read(items; i)
            @: value \held
            int: j i
            while: j > 0
                @: previous FxSeqRead\read(out; j - 1)
                @: item \previous
                if: (item\priority > value\priority) - (item\priority < value\priority) <= 0
                    break
                FxSeqStore\write(out; j; previous)
                j -= 1
            FxSeqStore\write(out; j; held)
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/P08.lm3). 507 непробельных символов; 22 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

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
        throws: copy(FxSort\sort\throws)
        return: sort(items; Order\compare)
```

[Полный исходник](source/lmx/P08.lm3). 201 непробельных символов; 12 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P08.pl).

```perl
use strict;
use warnings;
use sort 'stable';
sub example {
    my ($items) = @_;
    return [sort { $a->{priority} <=> $b->{priority} } @$items];
}
```

## Общие библиотечные реализации

- sort: [PI03](library_comparisons/PI03_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/sort>
- <https://perldoc.perl.org/5.40.1/sort>
