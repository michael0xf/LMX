# P05. Короткое замыкание any и all

## Общий наблюдаемый договор

Вернуть два булевых int: существует ли отрицательный элемент; все ли элементы меньше 10. На пустом списке результат [0,1].

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Одно тело Below читает динамический threshold текущего вызова; any/all сохраняют своё короткое замыкание. Число не захватывается в отдельную closure-структуру.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    [
      -1,
      20
    ]
  ],
  "result": [
    1,
    0
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 194 | 425 | 19 |
| LMX функциональный | 239 | 345 | 14 |
| Perl | 123 | 166 | 7 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int[]: items
    return: @
    run:
        int: negative 0
        int: below 1
        int: i 0
        while: i < length(items)
            if: items[i] < 0
                negative := 1
                break
            i += 1
        i := 0
        while: i < length(items)
            if: items[i] >= 10
                below := 0
                break
            i += 1
        return: (negative; below)
```

[Полный исходник](source/lmx/procedural/P05.lm3). 194 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Below:
    int: value
    return: int
    test:
        return: value < threshold

Example:
    int[]: items
    return: @
    run:
        throws: copy(FxSeqAny\any\throws) copy(FxSeqAll\all\throws)
        int: threshold 0
        int: negative any(items; Below\test)
        threshold := 10
        return: (negative; all(items; Below\test))
```

[Полный исходник](source/lmx/P05.lm3). 239 непробельных символов; 14 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P05.pl).

```perl
use strict;
use warnings;
use List::Util qw(any all);
sub example {
    my ($items) = @_;
    return [0 + (any { $_ < 0 } @$items), 0 + (all { $_ < 10 } @$items)];
}
```

## Общие библиотечные реализации

- any: [PI01](library_comparisons/PI01_comparision.md)
- all: [PI01](library_comparisons/PI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/List::Util#any>
- <https://perldoc.perl.org/5.40.1/List::Util#all>
