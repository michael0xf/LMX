# P18. Буквальная замена всех совпадений

## Общий наблюдаемый договор

Заменить все неперекрывающиеся буквальные вхождения needle на replacement в ASCII-строке; исходная строка не меняется. Метасимволы needle не становятся regex. Пустой needle вставляет между символами и на концах.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Строка replacement вставляется как значение переменной: содержащиеся в ней $ и обратные ссылки повторно не интерпретируются. Не захватывающая группа делает runtime-pattern непустым даже для пустого needle и исключает зависимость от предыдущего успешного regex вызывающего кода. Строка в позиции Pattern уже означает буквальную последовательность; обёртка literal здесь избыточна.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "a.b aXb a.b",
    "a.b",
    "$x"
  ],
  "result": "$x aXb $x"
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 478 | 911 | 29 |
| LMX функциональный | 185 | 238 | 8 |
| Perl | 115 | 141 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    char[]: text
    char[]: needle
    char[]: replacement
    return: char[]
    run:
        throws: copy(FxSeqPush\append\throws) copy(FxRecordOperands\record\throws)
        char[]: out []
        int: i 0
        while: 1
            int: same length(needle) <= length(text) - i
            int: j 0
            while: same != 0 && j < length(needle)
                if: text[i + j] != needle[j]
                    same := 0
                j += 1
            if: same != 0
                j := 0
                while: j < length(replacement)
                    FxSeqPush\append(out; (replacement[j] record))
                    j += 1
                if: length(needle) != 0
                    i += length(needle)
                    continue
            ---
            if: i = length(text)
                return: out
            FxSeqPush\append(out; (text[i] record))
            i += 1
```

[Полный исходник](source/lmx/procedural/P18.lm3). 478 непробельных символов; 29 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    char[]: needle
    char[]: replacement
    return: char[]
    run:
        throws: copy(RxByteText\byteText\throws) copy(RxReplace\replace\throws)
        return: replace(byteText(text); needle; replacement)
```

[Полный исходник](source/lmx/P18.lm3). 185 непробельных символов; 8 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P18.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text, $needle, $replacement) = @_;
    return $text =~ s/(?:\Q$needle\E)/$replacement/gr;
}
```

## Общие библиотечные реализации

- replace: [PI07](library_comparisons/PI07_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer>
