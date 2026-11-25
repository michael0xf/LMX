# P15. Отбор допустимых имён и число отклонений

## Общий наблюдаемый договор

Обработать список ASCII-строк как предложенные имена: принять только целые строки вида [A-Za-z][A-Za-z0-9_]*; вернуть (принятые имена в исходном порядке, число отклонённых). Повторные корректные имена сохраняются. Пустая строка, ведущая цифра и конечный перевод строки недопустимы. Пустой список даёт ([],0), входные строки не меняются.

Обе формы решают полный прикладной сценарий. Процедурная показывает алгоритм циклами и ветвлениями, функциональная использует общие операции; все поля, порядок, ошибки и полезный результат сохраняются.

Один и тот же предикат применяется к произвольному списку имён, а число отказов позволяет сформировать отчёт импорта. Используются строгие границы \A и \z; проверка не ослаблена до поиска подстроки. Общий Ascii\letter определён один раз в source/lmx/common/ascii.lm3 и включён в полный процедурный листинг и метрику; entry-файл загружается вместе с ним.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": [
    [
      "user_21",
      "7user",
      "name\n",
      "",
      "Abc",
      "user_21"
    ]
  ],
  "result": [
    [
      "user_21",
      "Abc",
      "user_21"
    ],
    3
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 669 | 1025 | 32 |
| LMX функциональный | 343 | 443 | 13 |
| Perl | 154 | 191 | 7 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Ascii:
    char: value
    return: int
    letter:
        return: (value >= 'A' && value <= 'Z') || (value >= 'a' && value <= 'z')

Identifier:
    char[]: text
    return: int
    test:
        if: length(text) = 0 || Ascii\letter(text[0]) = 0
            return: 0
        int: i 1
        while: i < length(text)
            char: value text[i]
            if: Ascii\letter(value) = 0 && (value < '0' || value > '9') && value != '_'
                return: 0
            i += 1
        return: 1

Example:
    @: items
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqPush\append\throws)
        @: info FxSeqInfo\get(items)
        @: out FxSeqAllocate\make(info\arrayType; 0)
        int: i 0
        while: i < length(items)
            @: value FxSeqRead\read(items; i)
            if: Identifier\test(\value) != 0
                FxSeqPush\append(out; value)
            i += 1
        return: (out; length(items) - length(out))
```

Канонические части полного исходника: [ascii.lm3](source/lmx/common/ascii.lm3), [P15.lm3](source/lmx/procedural/P15.lm3). 669 непробельных символов; 32 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Identifier:
    char[]: text
    return: int
    test:
        throws: copy(byteText\throws) copy(atLeast\throws) copy(RxThenOperand\then\throws) copy(matches\throws)
        return: matches(byteText(text); (then asciiLetter (asciiWord atLeast 0)))

Example:
    @: items
    return: @
    run:
        throws: copy(filter\throws)
        @: accepted filter(items; Identifier\test)
        return: (accepted; length(items) - length(accepted))
```

[Полный исходник](source/lmx/P15.lm3). 343 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P15.pl).

```perl
use strict;
use warnings;
sub example {
    my ($items) = @_;
    my @accepted = grep { /\A[A-Za-z][A-Za-z0-9_]*\z/ } @$items;
    return [\@accepted, scalar(@$items) - scalar(@accepted)];
}
```

## Общие библиотечные реализации

- matches: [PI07](library_comparisons/PI07_comparision.md)
- filter: [PI01](library_comparisons/PI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[["user_21","7user","name\n","","Abc","user_21"]]` | `[["user_21","Abc","user_21"],3]` | — |
| 2 | `[["user_21"]]` | `[["user_21"],0]` | — |
| 3 | `[["7user"]]` | `[[],1]` | — |
| 4 | `[["name\n"]]` | `[[],1]` | — |
| 5 | `[[""]]` | `[[],1]` | — |
| 6 | `[[]]` | `[[],0]` | — |
