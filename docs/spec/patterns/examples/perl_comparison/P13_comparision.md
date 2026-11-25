# P13. Пакетная загрузка с сохранением размеров пакетов

## Общий наблюдаемый договор

Объединить один уровень конечной последовательности пакетов rows и вернуть (плоская последовательность элементов, последовательность исходных размеров пакетов). Пустые пакеты сохраняются в отчёте размеров как 0; пустой внешний список даёт ([],[]). Глубже одного уровня ничего не раскрывается: вложенный массив остаётся отдельным элементом и сохраняет ссылку. Входы не меняются. Размеры во второй последовательности — обычные целые значения в общем протоколе результатов.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Вторая последовательность позволяет восстановить границы исходных пакетов, включая пустые. Она не является длиной единственного готового результата: пример сохраняет распределение элементов по всем входным пакетам.

## Вход и ожидаемое наблюдение

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
    [
      1,
      2,
      3
    ],
    [
      2,
      0,
      1
    ]
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 834 | 1373 | 41 |
| LMX функциональный | 106 | 147 | 6 |
| Perl | 125 | 173 | 8 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: rows
    return: @
    run:
        throws: copy(record\throws) copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(sys\resize\throws) SequenceSize
        FxSeqInfo\get(rows)
        int: kind @[]
        int: uniform 1
        bigint: count 0
        @: sizes FxSeqAllocate\make(@[]; length(rows))
        int: i 0
        while: i < length(rows)
            @: part FxSeqRead\read(rows; i)
            @: info FxSeqInfo\get(part)
            if: i = 0
                kind := info\arrayType
            if: info\dense = 0 || info\arrayType != kind
                uniform := 0
            int: partSize length(part)
            sizes[i] := (partSize record)
            count += partSize
            i += 1
        if: uniform = 0
            kind := @[]
        @: out FxSeqAllocate\make(kind; 0)
        @: info FxSeqInfo\get(out)
        if: count > info\maxLength
            throw: SequenceSize()
        int: size count
        sys\resize(out; size)
        int: at 0
        i := 0
        while: i < length(rows)
            @: part FxSeqRead\read(rows; i)
            int: j 0
            while: j < length(part)
                FxSeqStore\write(out; at; FxSeqRead\read(part; j))
                at += 1
                j += 1
            i += 1
        return: (out; sizes)
```

[Полный исходник](source/lmx/procedural/P13.lm3). 834 непробельных символов; 41 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: rows
    return: @
    run:
        throws: copy(concat\throws) copy(map\throws)
        return: (concat(rows); map(rows; length))
```

[Полный исходник](source/lmx/P13.lm3). 106 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P13.pl).

```perl
use strict;
use warnings;
sub example {
    my ($rows) = @_;
    my @items = map { @$_ } @$rows;
    my @sizes = map { scalar @$_ } @$rows;
    return [\@items, \@sizes];
}
```

## Общие библиотечные реализации

- concat: [полное тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).
- map: [PI01](library_comparisons/PI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/map>
- <https://perldoc.perl.org/5.40.1/perllol>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[[[1,2],[],[3]]]` | `[[1,2,3],[2,0,1]]` | — |
| 2 | `[[]]` | `[[],[]]` | — |
| 3 | `[[[1,[2]],[[3]]]]` | `[[1,[2],[3]],[2,1]]` | — |
| 4 | `[[[],[0],[]]]` | `[[0],[0,1,0]]` | — |
