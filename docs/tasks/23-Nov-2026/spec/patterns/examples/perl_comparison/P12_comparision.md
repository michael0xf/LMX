# P12. Наложение настроек с сохранением полей

## Общий договор

Объединить плоские настройки со скалярными и строковыми значениями: patch заменяет одноимённые совместимые поля base, новые добавляются. Ноль — значение, остальные поля, включая width/height/theme, сохраняются. Входы не меняются.

Общий профиль — плоские совместимые data-поля. merge LMX копирует использованный граф общим отображением; Perl создаёт новый хеш. Для этого сценария сравниваются значения полей; идентичность вложенных изменяемых графов и композиция кода не объявлены одинаковыми.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    {
      "width": 80,
      "height": 24,
      "theme": "dark"
    },
    {
      "width": 120,
      "border": 0
    }
  ],
  "result": {
    "width": 120,
    "height": 24,
    "theme": "dark",
    "border": 0
  }
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 93 | 58 | 6 |
| Perl | 101 | 77 | 6 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P12.lm3).

```lmx
Example:
    @: base
    @: patch
    return: @
    run:
        return: derive(base; patch)
```

## Perl

[Исходник](source/perl/P12.pl).

```perl
use strict;
use warnings;
sub example {
    my ($base, $patch) = @_;
    return {%$base, %$patch};
}
```

## Отдельные реализации

- derive: [PI05](library_comparisons/PI05_comparision.md)

Штатные средства Perl: hash construction.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldata#List-value-constructors>
- <https://perldoc.perl.org/5.40.1/perldsc>
