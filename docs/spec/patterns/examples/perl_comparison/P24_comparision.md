# P24. Освобождение ресурса при успехе и исключении

## Общий наблюдаемый договор

Ресурс содержит value=42 и width=8. Журнал: 1 acquire, 2 action, 3 release. mode=0 возвращает [50,123], mode=1 — отказ action и [0,123], mode=2 — отказ acquire и [0,1]. Release после успешного acquire выполняется ровно один раз.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Процедурный вариант непосредственно вызывает acquire/action и освобождает ресурс через finally внутри Use, до чтения итогового журнала. Функциональный использует bracket. Оба сохраняют исходные события, однократное освобождение и три исхода режима; копии throws взяты у действительных вызываемых методов.

## Вход и ожидаемое наблюдение

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

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 755 | 1245 | 53 |
| LMX функциональный | 633 | 1058 | 45 |
| Perl | <span style="color:#176233"><u>365</u></span> | 521 | 18 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

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
            throws: copy(Trace\code\throws)
            int: x 1
            code(2)
        return: Resource
    Action:
        @: resource
        return: int
        use:
            throws: copy(Trace\code\throws)
            int: x 2
            code(1)
        return: resource\value + resource\width
    Release:
        @: resource
        close:
            int: x 3
            eval()


Use:
    return: int
    run:
        throws: copy(Trace\Acquire\open\throws) copy(Trace\Action\use\throws)
        @: resource Trace\Acquire\open()
        finally:
            Trace\Release\close(resource)
        return: Trace\Action\use(resource)


Example:
    int: mode
    return: @
    run:
        throws: copy(Use\run\throws)
        Trace\mode := mode
        Trace\events := 0
        int: value Use\run()
        return: (value; Trace\events)
        catch: ResourceFailure()
            return: (0; Trace\events)
```

[Полный исходник](source/lmx/procedural/P24.lm3). 755 непробельных символов; 53 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

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
            throws: copy(Trace\code\throws)
            int: x 1
            code(2)
        return: Resource
    Action:
        @: resource
        return: int
        use:
            throws: copy(Trace\code\throws)
            int: x 2
            code(1)
        return: resource\value + resource\width
    Release:
        @: resource
        close:
            int: x 3
            eval()

Example:
    int: mode
    return: @
    run:
        throws: copy(bracket\throws)
        Trace\mode := mode
        Trace\events := 0
        int: value \bracket(Trace\Acquire\open; Trace\Release\close; Trace\Action\use)
        return: (value; Trace\events)
        catch: FxCallFailure (@: failure)
            return: (0; Trace\events)
```

[Полный исходник](source/lmx/P24.lm3). 633 непробельных символов; 45 непустых строк. Все объявления и Throws включены.

## Perl

[Полный исходник](source/perl/P24.pl).

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

## Общие библиотечные реализации

- bracket: [PI06](library_comparisons/PI06_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlsyn#defer-blocks>
- <https://perldoc.perl.org/5.40.1/functions/eval>

## Все проверочные входы

Каждый случай проверяет полный результат и отсутствие изменения входов. prime_empty_pattern дополнительно создаёт ранее успешное regex-состояние Perl.

| Случай | Аргументы | Результат | Дополнительное условие |
| --- | --- | --- | --- |
| 1 | `[0]` | `[50,123]` | — |
| 2 | `[1]` | `[0,123]` | — |
| 3 | `[2]` | `[0,1]` | — |
