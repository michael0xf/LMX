# P06. Срез с перестановкой и повторением

## Общий наблюдаемый договор

Выбрать элементы по списку допустимых нулевых индексов; порядок индексов и повторы существенны. Результат — новый внешний массив, вложенные ссылки сохраняются.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Контракт клиента ограничивает индексы диапазоном 0..n-1. Отрицательные и выходящие за массив индексы Perl имеют другую семантику; отдельно проверяемая общая реализация отвергает их явно.

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 348 | 472 | 13 |
| LMX функциональный | 98 | 143 | 7 |
| Perl | 88 | 111 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: items
    int[]: positions
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
```

[Полный исходник](source/lmx/procedural/P06.lm3). 348 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: items
    int[]: positions
    return: @
    run:
        throws: copy(select\throws)
        return: select(items; positions)
```

[Полный исходник](source/lmx/P06.lm3). 98 непробельных символов; 7 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P06.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items, $positions) = @_;
    return [@$items[@$positions]];
}
```

## Общие библиотечные реализации

- select: [PI02](library_comparisons/PI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldata#Slices>
