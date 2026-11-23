# P17. Глобальное извлечение слов

## Общий договор

Вернуть все максимальные неперекрывающиеся последовательности ASCII-букв слева направо. Цифры и знаки — разделители; отсутствие слов даёт пустой массив.

Perl собирает список встроенным /g. LMX материализует источник Stop общим collect, затем читает тексты общим map; оба результата конечны и упорядочены. Нулевое/пустое значение не используется как признак завершения. Общий collect сохраняет остальные объявленные отказы источника в FxCallFailure; фактический пример сравнивает успешные ASCII-входы.

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

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 238 | 193 | 148 | 6 |
| Perl | 99 | 75 | 75 | 6 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P17.lm3).

```lmx
Example:
    char[]: text
    return: @
    run:
        throws: copy(FxThrows\sequencefixture) PatternArgument PatternEncoding PatternPosition
        return: map(collect(eachMatch(byteText(text); (asciiLetter atLeast 1))); matchedText)
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
- collect: [полное тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx); [транзитивные зависимости](library_comparisons/shared_dependencies.lmx). Отдельная Perl-пара этой операции не написана.
- map: [PI01](library_comparisons/PI01_comparision.md)

Штатные средства Perl: regex /g in list context.

Построение Pattern/TextView: byteText, atLeast, asciiLetter. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#Regexp-Quote-Like-Operators>
