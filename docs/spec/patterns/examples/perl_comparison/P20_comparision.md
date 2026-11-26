# P20. Исправление повторённого слова в списке строк

## Общий наблюдаемый договор

Из списка ASCII-строк выбрать те, что целиком состоят ровно из двух одинаковых непустых слов [A-Za-z]+ с одним пробелом; заменить каждую принятую строку одним экземпляром слова. Вернуть (исправленные слова в исходном порядке, число отклонённых строк). Сравнение чувствительно к регистру, лишние пробелы и конечный перевод строки запрещены. Пустой список даёт ([],0), вход не меняется.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Результат содержит сами исправленные слова, а не только boolean-проверку регулярного выражения. filterMap использует существующий Maybe-контракт captureValue; процедурный вариант проверяет символы и копирует первую половину строки. Общий Ascii\letter определён один раз в source/lmx/common/ascii.lm3 и включён в полный процедурный листинг и метрику; entry-файл загружается вместе с ним.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    [
      "cat cat",
      "cat dog",
      "Cat cat",
      "x x",
      "x x ",
      ""
    ]
  ],
  "result": [
    [
      "cat",
      "x"
    ],
    4
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 724 | 1242 | 40 |
| LMX функциональный | 526 | 670 | 16 |
| Perl | <span style="color:#176233"><u>153</u></span> | 195 | 7 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Ascii:
    char: value
    return: int
    letter:
        return: (value >= 'A' && value <= 'Z') || (value >= 'a' && value <= 'z')

WordPair:
    []char: text
    return: int
    test:
        int: at 0
        while: at < length(text) && Ascii\letter(text[at]) != 0
            at += 1
        if: at = 0 || at = length(text) || text[at] != ' ' || length(text) - at - 1 != at
            return: 0
        int: i 0
        while: i < at
            if: text[i] != text[at + 1 + i]
                return: 0
            i += 1
        return: 1

Example:
    @: lines
    return: @
    run:
        throws: copy(FxSeqRead\read\throws) copy(sys\resize\throws) copy(FxSeqPush\append\throws) copy(record\throws)
        []@: out []
        int: i 0
        while: i < length(lines)
            @: value FxSeqRead\read(lines; i)
            []char: text \value
            if: WordPair\test(text) != 0
                []char: word []
                sys\resize(word; (length(text) - 1) / 2)
                int: j 0
                while: j < length(word)
                    word[j] := text[j]
                    j += 1
                FxSeqPush\append(out; (word record))
            i += 1
        return: (out; length(lines) - length(out))
```

Канонические части полного исходника: [ascii.lm3](source/lmx/common/ascii.lm3), [P20.lm3](source/lmx/procedural/P20.lm3). 724 непробельных символов; 40 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
RepeatedWord:
    []char: text
    return: @FxMaybe
    parse:
        throws: copy(byteText\throws) copy(atLeast\throws) copy(capture\throws) copy(sameAs\throws) copy(RxThenOperand\then\throws) copy(wholeMatch\throws) copy(captureValue\throws)
        @: parsed wholeMatch(byteText(text); (then capture("word"; (asciiLetter atLeast 1)) " " sameAs("word")))
        if: parsed\present = 0
            return: none()
        return: captureValue(parsed\value; "word")

Example:
    @: lines
    return: @
    run:
        throws: copy(filterMap\throws)
        @: repaired filterMap(lines; RepeatedWord\parse)
        return: (repaired; length(lines) - length(repaired))
```

[Полный исходник](source/lmx/P20.lm3). 526 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P20.pl).

```perl
use strict;
use warnings;
sub example {
    my ($lines) = @_;
    my @repaired = map { /\A([A-Za-z]+) \1\z/ ? ($1) : () } @$lines;
    return [\@repaired, scalar(@$lines) - scalar(@repaired)];
}
```

## Общие библиотечные реализации

- wholeMatch: [PI07](library_comparisons/PI07_comparision.md)
- captureValue: [PI07](library_comparisons/PI07_comparision.md)
- filterMap: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre#Capture-groups>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[["cat cat","cat dog","Cat cat","x x","x x ",""]]` | `[["cat","x"],4]` | — |
| 2 | `[["cat cat"]]` | `[["cat"],0]` | — |
| 3 | `[["cat dog"]]` | `[[],1]` | — |
| 4 | `[["Cat cat"]]` | `[[],1]` | — |
| 5 | `[["x x "]]` | `[[],1]` | — |
| 6 | `[[""]]` | `[[],1]` | — |
| 7 | `[[]]` | `[[],0]` | — |
