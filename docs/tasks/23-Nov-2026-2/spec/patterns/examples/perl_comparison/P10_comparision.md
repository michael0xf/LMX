# P10. Частотная таблица с порядком первых вхождений

## Общий договор

Для списка целых кодов вернуть пары [код,число вхождений], расположенные по первому появлению кода, а не по произвольному порядку хеша.

Общий identity сохраняет готовую запись ключа. map переводит готовые FxGroup в наблюдаемые пары; ручной второй обход и resize не повторяются. FxGroup принимается напрямую по действующему typed-value договору.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    [
      2,
      1,
      2,
      3,
      1,
      2
    ]
  ],
  "result": [
    [
      2,
      3
    ],
    [
      1,
      2
    ],
    [
      3,
      1
    ]
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 378 | 269 | 254 | 17 |
| Perl | 237 | 166 | 166 | 11 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P10.lm3).

```lmx
Same:
    int: first
    int: second
    return: int
    test:
        return: first = second

Frequency:
    FxGroup@: group
    return: @
    row:
        return: (\group\key; length(group\items))

Example:
    int[]: items
    return: @
    run:
        throws: copy(FxThrows\traversal) SequenceElement
        return: map(groupBy(items; identity; Same\test); Frequency\row)
```

## Perl

[Исходник](source/perl/P10.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items) = @_;
    my (%count, @order);
    for (@$items) {
        push @order, $_ unless exists $count{$_};
        ++$count{$_};
    }
    return [map { [0 + $_, $count{$_}] } @order];
}
```

## Отдельные реализации

- groupBy: [PI04](library_comparisons/PI04_comparision.md)
- identity: [полное тело ядра](../../LMX_Fn_Receivers/src/generic_combinators.lmx); [транзитивные зависимости](library_comparisons/shared_dependencies.lmx). Отдельная Perl-пара этой операции не написана.
- map: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: hash, CORE::exists, CORE::push, CORE::map.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldsc#HASHES-OF-ARRAYS>
- <https://perldoc.perl.org/5.40.1/functions/exists>
