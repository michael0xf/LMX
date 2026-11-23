# P09. Уникальные значения в порядке появления

## Общий договор

Удалить последующие повторы канонических целых чисел; сохранить первое вхождение и порядок. Вход не меняется.

Сравнение клиента ограничено каноническими целыми, поскольку uniq Perl не принимает same и сравнивает строковые представления с отдельным случаем undef. Реализационная пара рядом поддерживает произвольный явный same на обеих сторонах.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      0,
      1,
      0,
      -1,
      1
    ]
  ],
  "result": [
    0,
    1,
    -1
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 298 | 216 | 139 | 12 |
| Perl | 116 | 90 | 90 | 7 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P09.lm3).

```lmx
Same:
    int: first
    int: second
    return: int
    test:
        return: first = second

Example:
    int[]: items
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxPredicate FxTypeToken ReceiverIndex SequenceElement SequenceSize
        return: unique(items; Same\test)
```

## Perl

[Исходник](source/perl/P09.pl).

```perl
use strict;
use warnings;
use List::Util qw(uniq);
sub example {
    my ($items) = @_;
    return [uniq @$items];
}
```

## Отдельные реализации

- unique: [PI03](library_comparisons/PI03_comparision.md)

Штатные средства Perl: List::Util::uniq.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/List::Util#uniq>
