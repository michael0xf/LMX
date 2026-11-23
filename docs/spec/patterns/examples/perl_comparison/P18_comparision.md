# P18. Буквальная замена всех совпадений

## Общий договор

Заменить все неперекрывающиеся буквальные вхождения needle на replacement в ASCII-строке; исходная строка не меняется. Метасимволы needle не становятся regex. Пустой needle вставляет между символами и на концах.

Строка replacement вставляется как значение переменной: содержащиеся в ней $ и обратные ссылки повторно не интерпретируются. Не захватывающая группа делает runtime-pattern непустым даже для пустого needle и исключает зависимость от предыдущего успешного regex вызывающего кода. Строка в позиции Pattern уже означает буквальную последовательность; обёртка literal здесь избыточна.

## Вход и ожидаемый результат

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

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 277 | 219 | 138 | 8 |
| Perl | 141 | 115 | 115 | 6 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P18.lm3).

```lmx
Example:
    char[]: text
    char[]: needle
    char[]: replacement
    return: char[]
    run:
        throws: PatternArgument PatternEncoding PatternPosition FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        return: replace(byteText(text); needle; replacement)
```

## Perl

[Исходник](source/perl/P18.pl).

```perl
use strict;
use warnings;
sub example {
    my ($text, $needle, $replacement) = @_;
    return $text =~ s/(?:\Q$needle\E)/$replacement/gr;
}
```

## Отдельные реализации

- replace: [PI07](library_comparisons/PI07_comparision.md)

Штатные средства Perl: s///gr, \Q...\E.

Построение Pattern/TextView: byteText, literal. Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlop#s/PATTERN/REPLACEMENT/msixpodualngcer>
