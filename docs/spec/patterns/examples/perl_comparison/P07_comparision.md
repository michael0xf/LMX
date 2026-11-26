# P07. Изменение массива с возвратом удалённых

## Общий наблюдаемый договор

Заменить диапазон [begin,end) и вернуть [тот же изменённый массив, новый список удалённых элементов]. Вставляемые значения читаются до изменения; пустые вставка и удаление допустимы. Общий домен диапазона: 0 <= begin <= end <= length(items); отрицательные и выходящие за границы Perl-индексы не сравниваются с этим договором.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

В Perl третий параметр — длина, в LMX — исключённый конец. Это преобразование видно в исходнике и входит в подсчёт.

## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 1029 | 1520 | 38 |
| LMX функциональный | <span style="color:#176233"><u>138</u></span> | 209 | 10 |
| Perl | 146 | 186 | 7 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: items
    int: begin
    int: end
    @: values
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(FxSeqBounds\count\throws) copy(FxSeqSize\sum\throws) copy(FxKernel\arrayWrite\throws) copy(sys\resize\throws)
        int: removedCount FxSeqBounds\count(items; begin; end)
        @: info FxSeqInfo\get(items)
        FxSeqInfo\get(values)
        int: oldSize length(items)
        int: newSize FxSeqSize\sum(oldSize - removedCount; length(values); info\maxLength)
        @: removed FxSeqAllocate\make(info\arrayType; removedCount)
        @: staged FxSeqAllocate\make(info\arrayType; newSize)
        int: i 0
        while: i < removedCount
            FxSeqStore\write(removed; i; FxSeqRead\read(items; begin + i))
            i += 1
        i := 0
        while: i < newSize
            @: value
            if: i < begin
                value := FxSeqRead\read(items; i)
            else:
                if: i - begin < length(values)
                    value := FxSeqRead\read(values; i - begin)
                else:
                    value := FxSeqRead\read(items; end + (i - begin - length(values)))
            ---
            FxSeqStore\write(staged; i; value)
            i += 1
        sys\resize(items; newSize)
        i := 0
        while: i < newSize
            FxKernel\arrayWrite(items; i; FxSeqRead\read(staged; i))
            i += 1
        return: (items; removed)
```

[Полный исходник](source/lmx/procedural/P07.lm3). 1029 непробельных символов; 38 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: items
    int: begin
    int: end
    @: values
    return: @
    run:
        throws: copy(splice\throws)
        @: removed splice(items; begin; end; values)
        return: (items; removed)
```

[Полный исходник](source/lmx/P07.lm3). 138 непробельных символов; 10 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P07.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items, $begin, $end, $values) = @_;
    my @removed = splice @$items, $begin, $end - $begin, @$values;
    return [$items, \@removed];
}
```

## Общие библиотечные реализации

- splice: [PI02](library_comparisons/PI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/splice>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[[1,2,3,4],1,3,[8,9,10]]` | `[[1,8,9,10,4],[2,3]]` | — |
| 2 | `[[1],1,1,[2]]` | `[[1,2],[]]` | — |
| 3 | `[[1,2],0,2,[]]` | `[[],[1,2]]` | — |
