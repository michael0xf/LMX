# P18. Буквальная замена с отчётом о числе изменений

## Общий наблюдаемый договор

Заменить все неперекрывающиеся буквальные вхождения needle на replacement в ASCII-строке и вернуть (новая строка, число выбранных замен). Исходный текст не меняется; regex-метасимволы needle и доллар/backslash в replacement остаются буквальными. Пустой needle вставляет между символами и на концах, давая length(text)+1 замен; предыдущее regex-состояние Perl не влияет. Вставленный replacement повторно не просматривается.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Функциональный replacement-callback увеличивает changed ровно один раз на выбранное Match; текст замены остаётся строковым значением. В Perl непустая оболочка (?:...) сохраняет корректность пустого needle даже после ранее успешного regex.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "a.b aXb a.b",
    "a.b",
    "$x"
  ],
  "result": [
    "$x aXb $x",
    2
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 488 | 952 | 31 |
| LMX функциональный | 285 | 401 | 16 |
| Perl | <span style="color:#176233"><u>155</u></span> | 200 | 8 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    char[]: text
    char[]: needle
    char[]: replacement
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(record\throws)
        char[]: out []
        int: changed 0
        int: i 0
        while: 1
            int: same length(needle) <= length(text) - i
            int: j 0
            while: same != 0 && j < length(needle)
                if: text[i + j] != needle[j]
                    same := 0
                j += 1
            if: same != 0
                changed += 1
                j := 0
                while: j < length(replacement)
                    FxSeqPush\append(out; (replacement[j] record))
                    j += 1
                if: length(needle) != 0
                    i += length(needle)
                    continue
            ---
            if: i = length(text)
                return: (out; changed)
            FxSeqPush\append(out; (text[i] record))
            i += 1
```

[Полный исходник](source/lmx/procedural/P18.lm3). 488 непробельных символов; 31 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
CountedReplacement:
    Match@: matched
    return: char[]
    make:
        changed += 1
        return: replacement

Example:
    char[]: text
    char[]: needle
    char[]: replacement
    return: @
    run:
        throws: copy(byteText\throws) copy(replace\throws)
        int: changed 0
        char[]: out replace(byteText(text); needle; CountedReplacement\make)
        return: (out; changed)
```

[Полный исходник](source/lmx/P18.lm3). 285 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P18.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text, $needle, $replacement) = @_;
    my $out = $text;
    my $changed = $out =~ s/(?:\Q$needle\E)/$replacement/g;
    return [$out, 0 + $changed];
}
```

## Общие библиотечные реализации

- replace: [PI07](library_comparisons/PI07_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `["a.b aXb a.b","a.b","$x"]` | `["$x aXb $x",2]` | — |
| 2 | `["ab","","-"]` | `["-a-b-",3]` | — |
| 3 | `["abc","z","!"]` | `["abc",0]` | — |
| 4 | `["ab","","-"]` | `["-a-b-",3]` | prime_empty_pattern |
| 5 | `["a a a","a","aa"]` | `["aa aa aa",3]` | — |
