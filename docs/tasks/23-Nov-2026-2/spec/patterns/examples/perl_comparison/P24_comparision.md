# P24. Освобождение ресурса при успехе и исключении

## Общий договор

Ресурс содержит value=42 и width=8. Журнал: 1 acquire, 2 action, 3 release. mode=0 возвращает [50,123], mode=1 — отказ action и [0,123], mode=2 — отказ acquire и [0,1]. Release после успешного acquire выполняется ровно один раз.

Общий Trace\eval обновляет журнал один раз; Trace\code объединяет наблюдение и проверку режима. Основным выбран кратчайший полный вариант по nonwhitespace. Локальный Around ловит исходный ResourceFailure; общий bracket возвращает FxCallFailure. В данном сценарии все отказы acquire/action — ResourceFailure, release не бросает. Оба варианта и Perl defer освобождают только успешно приобретённый ресурс; полный local helper входит в размер.

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

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 1064 | 629 | 629 | 46 |
| Perl | 521 | 365 | 365 | 18 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

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
    eval:
        Trace\events := events * 10 + x
    code:
        throws: ResourceFailure
        eval()
        if: Trace\mode = mode
            throw: ResourceFailure()
    end: code
    Acquire:
        return: @
        open:
            throws: ResourceFailure
            int: x 1
            code(2)
        return: Resource
    Action:
        @: resource
        return: int
        use:
            throws: ResourceFailure
            int: x 2
            code(1)
        return: resource\value + resource\width
    Release:
        @: resource
        close:
            int: x 3
            eval()
        end: close

Example:
    int: mode
    return: @
    run:
        throws: copy(FxThrows\sequence)
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

## Другой подход: Обычные вызовы и локальный Around

Полный вариант: 750 символов без пробельных; без сложного Throws: 750. Локальный helper и весь сценарий входят в счёт.

```lmx
Around:
    @: acquire
    @: release
    @: action
    return: int
    use:
        throws: ResourceFailure
        @: resource acquire()
        finally:
            release(resource := resource)
        return: action(resource := resource)

Resource:
    int: value 42
    int: width 8

Trace:
    int: mode 0
    int: events 0
    eval:
        Trace\events := events * 10 + x
    code:
        throws: ResourceFailure
        eval()
        if: Trace\mode = mode
            throw: ResourceFailure()
    end: code
    Acquire:
        return: @
        open:
            throws: ResourceFailure
            int: x 1
            code(2)
        return: Resource
    Action:
        @: resource
        return: int
        use:
            throws: ResourceFailure
            int: x 2
            code(1)
        return: resource\value + resource\width
    Release:
        @: resource
        close:
            int: x 3
            eval()
        end: close

Example:
    int: mode
    return: @
    run:
        Trace\mode := mode
        Trace\events := 0
        int: value Around\use(Trace\Acquire\open; Trace\Release\close; Trace\Action\use)
        return: (value; Trace\events)
        catch: ResourceFailure ()
            return: (0; Trace\events)
```

## Проверка

Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlsyn#defer-blocks>
- <https://perldoc.perl.org/5.40.1/functions/eval>
