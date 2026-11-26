# P06. Перестановка экспортируемых полей вместе с метками

## Общий наблюдаемый договор

items и labels — две последовательности одинаковой длины: значения экспортируемых полей и их метки. Выбрать обе по одному списку допустимых индексов positions; вернуть пару новых внешних массивов. Порядок и повторы индексов существенны; повторная ссылка указывает на тот же исходный объект, вложенные поля не теряются. Пустые positions дают два пустых массива. Индексы 0..n-1 являются общим предусловием, входы не меняются.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Метки выбираются той же перестановкой, поэтому экспорт сохраняет связь названий со значениями. Процедурный SelectFields определён один раз и используется для обеих последовательностей; positions динамически видим в вызываемом методе.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    [
      "a",
      "b",
      "c"
    ],
    [
      "field0",
      "field1",
      "field2"
    ],
    [
      2,
      0,
      2
    ]
  ],
  "result": [
    [
      "c",
      "a",
      "c"
    ],
    [
      "field2",
      "field0",
      "field2"
    ]
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 481 | 651 | 20 |
| LMX функциональный | 133 | 186 | 8 |
| Perl | <span style="color:#176233"><u>122</u></span> | 147 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
SelectFields:
    @: items
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws)
        @: info FxSeqInfo\get(items)
        @: out FxSeqAllocate\make(info\arrayType; length(positions))
        int: i 0
        while: i < length(positions)
            FxSeqStore\write(out; i; FxSeqRead\read(items; positions[i]))
            i += 1
        return: out

Example:
    @: items
    @: labels
    []int: positions
    return: @
    run:
        throws: copy(SelectFields\run\throws)
        return: (SelectFields\run(items); SelectFields\run(labels))
```

[Полный исходник](source/lmx/procedural/P06.lm3). 481 непробельных символов; 20 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: items
    @: labels
    []int: positions
    return: @
    run:
        throws: copy(select\throws)
        return: (select(items; positions); select(labels; positions))
```

[Полный исходник](source/lmx/P06.lm3). 133 непробельных символов; 8 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P06.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items, $labels, $positions) = @_;
    return [[@$items[@$positions]], [@$labels[@$positions]]];
}
```

## Общие библиотечные реализации

- select: [PI02](library_comparisons/PI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldata#Slices>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[["a","b","c"],["field0","field1","field2"],[2,0,2]]` | `[["c","a","c"],["field2","field0","field2"]]` | — |
| 2 | `[[1,2],["field0","field1"],[]]` | `[[],[]]` | — |
| 3 | `[[],[],[]]` | `[[],[]]` | — |
| 4 | `[[{"id":"a","width":2},{"id":"b","width":4}],["left","right"],[1,0,1]]` | `[[{"id":"b","width":4},{"id":"a","width":2},{"id":"b","width":4}],["right","left","right"]]` | — |
