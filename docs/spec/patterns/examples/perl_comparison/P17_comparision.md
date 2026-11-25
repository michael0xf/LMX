# P17. Слова журнала с порогом длины

## Общий наблюдаемый договор

Из ASCII-текста журнала извлечь максимальные последовательности букв [A-Za-z]+, оставить слова длины не меньше неотрицательного minimum и вернуть (принятые слова, число отброшенных коротких слов). Порядок и регистр сохраняются; цифры и знаки — разделители. При отсутствии слов результат ([],0), minimum=0 оставляет все найденные слова. Вход не меняется.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Порог длины имеет обычное динамическое связывание в LongWord; подготовка фабрики и копирование текстового шаблона не требуются. Цепочка возвращает полезный отобранный материал и статистику пропуска. Общий Ascii\letter определён один раз в source/lmx/common/ascii.lm3 и включён в полный процедурный листинг и метрику; entry-файл загружается вместе с ним.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "ab12CODE, useful",
    3
  ],
  "result": [
    [
      "CODE",
      "useful"
    ],
    1
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 577 | 1022 | 32 |
| LMX функциональный | 421 | 532 | 14 |
| Perl | 182 | 232 | 8 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Ascii:
    char: value
    return: int
    letter:
        return: (value >= 'A' && value <= 'Z') || (value >= 'a' && value <= 'z')

Example:
    char[]: text
    int: minimum
    return: @
    run:
        throws: copy(sys\resize\throws) copy(FxSeqPush\append\throws) copy(record\throws)
        @[]: out []
        int: skipped 0
        int: i 0
        while: i < length(text)
            while: i < length(text) && Ascii\letter(text[i]) = 0
                i += 1
            int: begin i
            while: i < length(text) && Ascii\letter(text[i]) != 0
                i += 1
            if: i > begin && i - begin < minimum
                skipped += 1
            if: i > begin && i - begin >= minimum
                char[]: word []
                sys\resize(word; i - begin)
                int: j 0
                while: j < length(word)
                    word[j] := text[begin + j]
                    j += 1
                FxSeqPush\append(out; (word record))
        ---
        return: (out; skipped)
```

Канонические части полного исходника: [ascii.lm3](source/lmx/common/ascii.lm3), [P17.lm3](source/lmx/procedural/P17.lm3). 577 непробельных символов; 32 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
LongWord:
    char[]: word
    return: int
    test:
        return: length(word) >= minimum

Example:
    char[]: text
    int: minimum
    return: @
    run:
        throws: copy(byteText\throws) copy(atLeast\throws) copy(eachMatch\throws) copy(collect\throws) copy(map\throws) copy(matchedValue\throws) copy(filter\throws)
        @: words map(collect(eachMatch(byteText(text); (asciiLetter atLeast 1))); matchedValue)
        @: selected filter(words; LongWord\test)
        return: (selected; length(words) - length(selected))
```

[Полный исходник](source/lmx/P17.lm3). 421 непробельных символов; 14 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P17.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text, $minimum) = @_;
    my @words = $text =~ /[A-Za-z]+/g;
    my @selected = grep { length($_) >= $minimum } @words;
    return [\@selected, scalar(@words) - scalar(@selected)];
}
```

## Общие библиотечные реализации

- eachMatch: [PI07](library_comparisons/PI07_comparision.md)
- collect: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).
- map: [PI01](library_comparisons/PI01_comparision.md)
- filter: [PI01](library_comparisons/PI01_comparision.md)
- matchedValue: [PI07](library_comparisons/PI07_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#Regexp-Quote-Like-Operators>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `["ab12CODE, useful",3]` | `[["CODE","useful"],1]` | — |
| 2 | `["ab12CD, ef",2]` | `[["ab","CD","ef"],0]` | — |
| 3 | `["123",2]` | `[[],0]` | — |
| 4 | `["",2]` | `[[],0]` | — |
| 5 | `["a ab",0]` | `[["a","ab"],0]` | — |
