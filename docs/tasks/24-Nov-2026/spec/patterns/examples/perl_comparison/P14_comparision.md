# P14. Разделение строки без потери пустых полей

## Общий наблюдаемый договор

Разделить ASCII-строку по запятым; сохранить начальные, промежуточные и конечные пустые поля. Пустая строка означает одно пустое поле.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Для пустого входа split Perl обычно возвращает пустой список; ветка в клиенте обеспечивает общий договор и входит в измеряемый код.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "a,,b,"
  ],
  "result": [
    "a",
    "",
    "b",
    ""
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 335 | 651 | 21 |
| LMX функциональный | 109 | 149 | 6 |
| Perl | 92 | 121 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: copy(sys\resize\throws) copy(FxSeqPush\append\throws) copy(record\throws)
        @[]: out []
        int: begin 0
        int: i 0
        while: 1
            if: i = length(text) || text[i] = ','
                char[]: part []
                sys\resize(part; i - begin)
                int: j 0
                while: j < length(part)
                    part[j] := text[begin + j]
                    j += 1
                FxSeqPush\append(out; (part record))
                if: i = length(text)
                    return: out
                begin := i + 1
            i += 1
```

[Полный исходник](source/lmx/procedural/P14.lm3). 335 непробельных символов; 21 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: copy(byteText\throws) copy(split\throws)
        return: split(byteText(text); ",")
```

[Полный исходник](source/lmx/P14.lm3). 109 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P14.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return length($text) ? [split /,/, $text, -1] : [''];
}
```

## Общие библиотечные реализации

- split: [PI07](library_comparisons/PI07_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/split>
