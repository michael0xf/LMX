# P14. Проверка строки импорта и пустых полей

## Общий наблюдаемый договор

Разделить ASCII-строку простого импорта по запятым и вернуть (поля, флаг числа полей=columns, число пустых полей). columns — положительное ожидаемое число колонок. Начальные, промежуточные и конечные пустые поля сохраняются; пустая строка означает одно пустое поле. Это явно простой формат без CSV-кавычек/экранирования; ввод не исправляется автоматически и не меняется.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Отчёт разделяет неправильное число колонок и пустые значения. Для пустого входа Perl имеет явную ветвь, обеспечивающую один пустой столбец. Процедурный код считает пустые поля в том же сканировании.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "a,,b,",
    4
  ],
  "result": [
    [
      "a",
      "",
      "b",
      ""
    ],
    1,
    2
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 402 | 782 | 25 |
| LMX функциональный | 255 | 349 | 13 |
| Perl | <span style="color:#176233"><u>170</u></span> | 220 | 7 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    char[]: text
    int: columns
    return: @
    run:
        throws: copy(sys\resize\throws) copy(FxSeqPush\append\throws) copy(record\throws)
        @[]: out []
        int: empty 0
        int: begin 0
        int: i 0
        while: 1
            if: i = length(text) || text[i] = ','
                if: i = begin
                    empty += 1
                char[]: part []
                sys\resize(part; i - begin)
                int: j 0
                while: j < length(part)
                    part[j] := text[begin + j]
                    j += 1
                FxSeqPush\append(out; (part record))
                if: i = length(text)
                    return: (out; length(out) = columns; empty)
                begin := i + 1
            i += 1
```

[Полный исходник](source/lmx/procedural/P14.lm3). 402 непробельных символов; 25 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Empty:
    char[]: text
    return: int
    test:
        return: length(text) = 0

Example:
    char[]: text
    int: columns
    return: @
    run:
        throws: copy(byteText\throws) copy(split\throws) copy(count\throws)
        @: fields split(byteText(text); ",")
        return: (fields; length(fields) = columns; count(fields; Empty\test))
```

[Полный исходник](source/lmx/P14.lm3). 255 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P14.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text, $columns) = @_;
    my @fields = length($text) ? split(/,/, $text, -1) : ('');
    return [\@fields, 0 + (@fields == $columns), scalar grep { $_ eq '' } @fields];
}
```

## Общие библиотечные реализации

- split: [PI07](library_comparisons/PI07_comparision.md)
- count: [полное тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/split>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `["a,,b,",4]` | `[["a","","b",""],1,2]` | — |
| 2 | `["",1]` | `[[""],1,1]` | — |
| 3 | `[",",1]` | `[["",""],0,2]` | — |
| 4 | `["a,b",3]` | `[["a","b"],0,0]` | — |
| 5 | `["",2]` | `[[""],0,1]` | — |
