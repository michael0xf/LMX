# P17. Глобальное извлечение слов

## Общий договор

Вернуть все максимальные неперекрывающиеся последовательности ASCII-букв слева направо. Цифры и знаки — разделители; отсутствие слов даёт пустой массив.

Perl собирает список встроенным /g; LMX использует итератор Stop. Обе стороны явно материализуют один и тот же конечный результат.

## Вход и ожидаемый результат

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

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 517 | 343 | 15 |
| Perl | 99 | 75 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P17.lm3).

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: FxRecordArity PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        @: next eachMatch(byteText(text); (asciiLetter atLeast 1))
        @[]: result []
        while: 1
            @: found next()
            catch: Stop ()
                break
            int: at length(result)
            sys\resize(result; at + 1)
            result[at] := (matchedText(found) record)
        return: result
```

## Perl

[Исходник](source/perl/P17.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text) = @_;
    return [$text =~ /[A-Za-z]+/g];
}
```

## Отдельные реализации

- eachMatch: [PI07](library_comparisons/PI07_comparision.md)
- matchedText: [PI07](library_comparisons/PI07_comparision.md)

Штатные средства Perl: regex /g in list context.

Построение Pattern/TextView: byteText, atLeast, asciiLetter. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#Regexp-Quote-Like-Operators>
