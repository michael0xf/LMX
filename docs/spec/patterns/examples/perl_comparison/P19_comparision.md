# P19. Вычисляемая замена с сохранением ширины

## Общий наблюдаемый договор

Каждую максимальную последовательность ASCII-цифр заменить таким же количеством звёздочек. Длина строки и прочие символы сохраняются; callback вызывается один раз на выбранное совпадение.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Ширина берётся из готового диапазона Match в byteText: повторного копирования matchedValue не нужно. cycle формирует ровно столько звёздочек, а replace вызывает Mask один раз на совпадение.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    "card 1234 / 09"
  ],
  "result": "card **** / **"
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 390 | 754 | 31 |
| LMX функциональный | 304 | 391 | 12 |
| Perl | 88 | 114 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Mask:
    char[]: target
    int: begin
    int: end
    apply:
        int: i begin
        while: i < end
            target[i] := '*'
            i += 1


Example:
    char[]: text
    return: char[]
    run:
        throws: copy(sys\resize\throws)
        char[]: out []
        sys\resize(out; length(text))
        int: i 0
        while: i < length(text)
            out[i] := text[i]
            i += 1
        i := 0
        while: i < length(text)
            if: text[i] >= '0' && text[i] <= '9'
                int: begin i
                while: i < length(text) && text[i] >= '0' && text[i] <= '9'
                    i += 1
                Mask\apply(out; begin; i)
            else:
                i += 1
        ---
        return: out
```

[Полный исходник](source/lmx/procedural/P19.lm3). 390 непробельных символов; 31 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Mask:
    Match@: matched
    return: char[]
    make:
        throws: copy(FxTextCycle\cycle\throws)
        return: cycle("*"; matched\end - matched\begin)

Example:
    char[]: text
    return: char[]
    run:
        throws: copy(byteText\throws) copy(atLeast\throws) copy(replace\throws) copy(Mask\make\throws)
        return: replace(byteText(text); (asciiDigit atLeast 1); Mask\make)
```

[Полный исходник](source/lmx/P19.lm3). 304 непробельных символов; 12 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P19.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return $text =~ s/[0-9]+/'*' x length($&)/ger;
}
```

## Общие библиотечные реализации

- replace: [PI07](library_comparisons/PI07_comparision.md)
- cycle: [полное тело ядра](../../LMX_Fn_Receivers/src/sequence_profiles.lmx); [общие зависимости](library_comparisons/shared_dependencies.lmx).

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer>
- <https://perldoc.perl.org/5.40.1/perlop#Multiplicative-Operators>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `["card 1234 / 09"]` | `"card **** / **"` | — |
| 2 | `["a0b"]` | `"a*b"` | — |
| 3 | `["abc"]` | `"abc"` | — |
