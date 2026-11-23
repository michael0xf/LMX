# P17. Глобальное извлечение слов

## Общий наблюдаемый договор

Вернуть все максимальные неперекрывающиеся последовательности ASCII-букв слева направо. Цифры и знаки — разделители; отсутствие слов даёт пустой массив.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Perl собирает список встроенным /g. LMX материализует источник Stop общим collect, затем читает тексты общим map; оба результата конечны и упорядочены. Нулевое/пустое значение не используется как признак завершения. Общий collect сохраняет остальные объявленные отказы источника в FxCallFailure; фактический пример сравнивает успешные ASCII-входы.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "ab12CD, ef"
  ],
  "result": [
    "ab",
    "CD",
    "ef"
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 506 | 887 | 28 |
| LMX функциональный | 317 | 364 | 6 |
| Perl | 75 | 99 | 6 |

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
    return: @
    run:
        throws: copy(sys\resize\throws) copy(FxSeqPush\append\throws) copy(FxRecordOperands\record\throws)
        @[]: out []
        int: i 0
        while: i < length(text)
            while: i < length(text) && Ascii\letter(text[i]) = 0
                i += 1
            int: begin i
            while: i < length(text) && Ascii\letter(text[i]) != 0
                i += 1
            if: i > begin
                char[]: word []
                sys\resize(word; i - begin)
                int: j 0
                while: j < length(word)
                    word[j] := text[begin + j]
                    j += 1
                FxSeqPush\append(out; (word record))
        ---
        return: out
```

[Полный исходник](source/lmx/procedural/P17.lm3). 506 непробельных символов; 28 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: copy(RxByteText\byteText\throws) copy(RxRepeatOperands\atLeast\throws) copy(RxEachMatch\eachMatch\throws) copy(FxStdCollect\collect\throws) copy(FxMap\map\throws) copy(RxMatchedValue\matchedValue\throws)
        return: map(collect(eachMatch(byteText(text); (asciiLetter atLeast 1))); matchedValue)
```

[Полный исходник](source/lmx/P17.lm3). 317 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P17.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return [$text =~ /[A-Za-z]+/g];
}
```

## Общие библиотечные реализации

- eachMatch: [PI07](library_comparisons/PI07_comparision.md)
- matchedValue: [PI07](library_comparisons/PI07_comparision.md)
- collect: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).
- map: [PI01](library_comparisons/PI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#Regexp-Quote-Like-Operators>
