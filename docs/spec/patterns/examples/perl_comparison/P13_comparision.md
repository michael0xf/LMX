# P13. Map с выдачей нескольких элементов

## Общий наблюдаемый договор

Сплющить ровно один уровень списка списков, сохранив порядок. Пустые внутренние списки ничего не добавляют; более глубокие массивы остаются отдельными элементами.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Задача требует только одного разворачивания готовых частей. Общий concat заменяет identity-callback и bind, сохраняя вложенные элементы.

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
    1,
    2,
    3
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 718 | 1212 | 38 |
| LMX функциональный | 71 | 109 | 6 |
| Perl | 70 | 96 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: rows
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(sys\resize\throws) SequenceSize
        FxSeqInfo\get(rows)
        int: kind @[]
        int: uniform 1
        bigint: count 0
        int: i 0
        while: i < length(rows)
            @: part FxSeqRead\read(rows; i)
            @: info FxSeqInfo\get(part)
            if: i = 0
                kind := info\arrayType
            if: info\dense = 0 || info\arrayType != kind
                uniform := 0
            count += length(part)
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
        return: out
```

[Полный исходник](source/lmx/procedural/P13.lm3). 718 непробельных символов; 38 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: rows
    return: @
    run:
        throws: copy(concat\throws)
        return: concat(rows)
```

[Полный исходник](source/lmx/P13.lm3). 71 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P13.pl).

```perl
use strict;
use warnings;
sub example {
    my ($rows) = @_;
    return [map { @$_ } @$rows];
}
```

## Общие библиотечные реализации

- concat: [полное тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/map>
- <https://perldoc.perl.org/5.40.1/perllol>
