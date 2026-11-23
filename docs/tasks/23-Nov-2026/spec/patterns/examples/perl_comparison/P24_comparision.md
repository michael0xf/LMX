# P24. Освобождение ресурса при успехе и исключении

## Общий договор

Ресурс содержит value=42 и width=8. Журнал: 1 acquire, 2 action, 3 release. mode=0 возвращает [50,123], mode=1 — отказ action и [0,123], mode=2 — отказ acquire и [0,1]. Release после успешного acquire выполняется ровно один раз.

Perl 5.40.1 поддерживает defer, но помечает его experimental; включение и предупреждение учтены в коде. Клиент использует штатный defer, не сравнительный bracket. Release клиента не бросает; отдельная реализация bracket дополнительно определяет случай отказа release. Все действия синхронны в текущем Message; post всего owner-метода достаточен для запуска всей операции асинхронно, но post отдельного action не продлевает жизнь ресурса.

## Вход и ожидаемый результат

```json
{
  "arguments": [
    0
  ],
  "result": [
    50,
    123
  ]
}
```

Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.

## Размер выбранного варианта

| Источник | Все символы | Без пробельных | Непустые строки |
|---|---:|---:|---:|
| LMX | 1083 | 673 | 40 |
| Perl | 521 | 365 | 18 |

Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.

## LMX

[Исходник](source/lmx/P24.lm3).

```lmx
Resource:
    int: value 42
    int: width 8
Trace:
    int: mode 0
    int: events 0
    Acquire:
        return: @
        open:
            throws: ResourceFailure
            Trace\events := Trace\events * 10 + 1
            if: Trace\mode = 2
                throw: ResourceFailure()
            return: Resource
    ---
    Action:
        @: resource
        return: int
        use:
            throws: ResourceFailure
            Trace\events := Trace\events * 10 + 2
            if: Trace\mode = 1
                throw: ResourceFailure()
            return: resource\value + resource\width
    ---
    Release:
        @: resource
        close:
            Trace\events := Trace\events * 10 + 3

Example:
    int: mode
    return: @
    run:
        throws: FxKernelFailure FxTypeToken ReceiverIndex SequenceSize
        Trace\mode := mode
        Trace\events := 0
        int: value \bracket(Trace\Acquire\open; Trace\Release\close; Trace\Action\use)
        return: (value; Trace\events)
        catch: FxCallFailure (@: failure)
            return: (0; Trace\events)
```

## Perl

[Исходник](source/perl/P24.pl).

```perl
use strict;
use warnings;
use feature 'defer';
no warnings 'experimental::defer';
sub example {
    my ($mode) = @_;
    my ($events, $value) = (0, 0);
    eval {
        $events = $events * 10 + 1;
        die "ResourceFailure\n" if $mode == 2;
        my $resource = {value => 42, width => 8};
        defer { $events = $events * 10 + 3 }
        $events = $events * 10 + 2;
        die "ResourceFailure\n" if $mode == 1;
        $value = $resource->{value} + $resource->{width};
    };
    return [$value, $events];
}
```

## Отдельные реализации

- bracket: [PI06](library_comparisons/PI06_comparision.md)

Штатные средства Perl: feature defer, CORE::eval, CORE::die.

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlsyn#defer-blocks>
- <https://perldoc.perl.org/5.40.1/functions/eval>
