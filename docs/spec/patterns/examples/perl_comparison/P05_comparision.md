# P05. Короткое замыкание any и all

## Общий договор

Вернуть два булевых int: существует ли отрицательный элемент; все ли элементы меньше 10. На пустом списке результат [0,1].

Одно тело Below читает динамический threshold текущего вызова; any/all сохраняют своё короткое замыкание. Число не захватывается в отдельную closure-структуру.

## Вход и ожидаемый результат

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

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 318 | 213 | 213 | 14 |
| Perl | 166 | 123 | 123 | 7 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P05.lm3).

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
        throws: copy(FxThrows\predicate)
        int: threshold 0
        int: negative any(items; Below\test)
        threshold := 10
        return: (negative; all(items; Below\test))
```

## Perl

[Исходник](source/perl/P05.pl).

```perl
use strict;
use warnings;
use List::Util qw(any all);
sub example {
    my ($items) = @_;
    return [0 + (any { $_ < 0 } @$items), 0 + (all { $_ < 10 } @$items)];
}
```

## Отдельные реализации

- any: [PI01](library_comparisons/PI01_comparision.md)
- all: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: List::Util::any, List::Util::all.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/List::Util#any>
- <https://perldoc.perl.org/5.40.1/List::Util#all>
