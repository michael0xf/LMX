# P08. Ограниченный приоритетный пакет и суммарная ширина

## Общий наблюдаемый договор

Отсортировать ссылки на записи по возрастанию priority, сохранить исходный порядок равных ключей, взять первые min(limit,n) записей и вернуть (выбранные записи, сумма их width). limit — неотрицательное целое; каждый width — неотрицательное целое, сумма представима. Все поля и идентичность исходных записей сохраняются, вход не меняется. limit=0 и пустой вход дают ([],0). Общий домен priority имеет полный согласованный порядок без NaN.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Фильтрация по limit выполняется после стабильной сортировки. Дополнительная сумма использует настоящее поле width каждой выбранной записи; поле не удалено ради краткости. Функциональная форма берёт sort/take/map/sum из одного общего ядра; процедурная показывает вставки и явный проход выбранного префикса.

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
    ],
    2
  ],
  "result": [
    [
      {
        "priority": 1,
        "id": "b",
        "width": 4
      },
      {
        "priority": 2,
        "id": "a",
        "width": 8
      }
    ],
    12
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 704 | 1160 | 34 |
| LMX функциональный | 357 | 489 | 19 |
| Perl | 242 | 301 | 10 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: items
    int: limit
    return: @
    run:
        throws: copy(sys\resize\throws) copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws)
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
        int: count length(out)
        if: limit < count
            count := limit
        int: total 0
        i := 0
        while: i < count
            @: record FxSeqRead\read(out; i)
            @: item \record
            total += item\width
            i += 1
        sys\resize(out; count)
        return: (out; total)
```

[Полный исходник](source/lmx/procedural/P08.lm3). 704 непробельных символов; 34 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Order:
    @: first
    @: second
    return: int
    compare:
        return: (first\priority > second\priority) - (first\priority < second\priority)

Width:
    @: item
    return: int
    get:
        return: item\width

Example:
    @: items
    int: limit
    return: @
    run:
        throws: copy(sort\throws) copy(take\throws) copy(map\throws) copy(sum\throws)
        @: selected take(sort(items; Order\compare); limit)
        return: (selected; \sum(map(selected; Width\get)))
```

[Полный исходник](source/lmx/P08.lm3). 357 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P08.pl).

```perl
use strict;
use warnings;
use sort 'stable';
use List::Util qw(sum0);
sub example {
    my ($items, $limit) = @_;
    my @selected = sort { $a->{priority} <=> $b->{priority} } @$items;
    splice @selected, $limit if @selected > $limit;
    return [\@selected, sum0(map { $_->{width} } @selected)];
}
```

## Общие библиотечные реализации

- sort: [PI03](library_comparisons/PI03_comparision.md)
- take: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).
- map: [PI01](library_comparisons/PI01_comparision.md)
- sum: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardNumeric.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/sort>
- <https://perldoc.perl.org/5.40.1/sort>
- <https://perldoc.perl.org/5.40.1/List::Util#sum0>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[[{"priority":2,"id":"a","width":8},{"priority":1,"id":"b","width":4},{"priority":2,"id":"c","width":12}],2]` | `[[{"priority":1,"id":"b","width":4},{"priority":2,"id":"a","width":8}],12]` | — |
| 2 | `[[],2]` | `[[],0]` | — |
| 3 | `[[{"priority":2,"id":"a","width":8}],2]` | `[[{"priority":2,"id":"a","width":8}],8]` | — |
| 4 | `[[{"priority":2,"id":"a","width":8},{"priority":2,"id":"b","width":4}],0]` | `[[],0]` | — |
| 5 | `[[{"priority":2,"id":"a","width":8},{"priority":2,"id":"b","width":4}],8]` | `[[{"priority":2,"id":"a","width":8},{"priority":2,"id":"b","width":4}],12]` | — |
