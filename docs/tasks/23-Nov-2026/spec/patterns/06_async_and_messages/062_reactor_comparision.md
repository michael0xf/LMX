# 062. Reactor

Готовность дескриптора запускает обработчик, который сам выполняет неблокирующее чтение.

## Общий сценарий

Провайдер сообщает ready(fd=3); ReadReady(3) возвращает 2 байта, затем would-block=0.

**Ожидаемое наблюдение:** Первая готовность приводит к чтению и одному sink(2); would-block не завершает соединение.

**Граница сравнения:** Протокол и порты. Это не реализация epoll/kqueue и не zero-copy I/O. Буферы, edge-triggered drain, повторная регистрация и ошибки провайдера требуют расширения контракта.

## LMX

```lmx
ReactorMessage:
    int: fd
    @: io
    @: sink
    ready:
        int: n io\readReady(fd)
        if: n > 0
            sink\write(n)
        if: n < 0
            io\unregister(fd)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. io.readReady(fd:int):int — supplied nonblocking adapter: >0 количество байт, 0 would-block, −1 закрытие; unregister(fd):void отключает readiness. sink.write(int):void фиксирует число байт. Readiness demultiplexer принадлежит I/O-провайдеру и публикует письма owner, не запускает второй turn.

[Отдельный листинг](examples/lmx/062_reactor.lm3)

## Go

```go
func Reactor(ready <-chan int, readReady func(int) int,
             unregister func(int), write func(int)) {
    for fd := range ready {
        n := readReady(fd)
        if n > 0 { write(n) }
        if n < 0 { unregister(fd) }
    }
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. io.readReady(fd:int):int — supplied nonblocking adapter: >0 количество байт, 0 would-block, −1 закрытие; unregister(fd):void отключает readiness. sink.write(int):void фиксирует число байт. Readiness demultiplexer принадлежит I/O-провайдеру и публикует письма owner, не запускает второй turn.

[Отдельный листинг](examples/go/062_reactor.go)

## Erlang

```erlang
reactor(ReadReady, Unregister, Write) ->
    receive
        {ready, Fd} ->
            N = ReadReady(Fd),
            if N > 0 -> Write(N); N < 0 -> Unregister(Fd); true -> ok end,
            reactor(ReadReady, Unregister, Write);
        stop -> ok
    end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. io.readReady(fd:int):int — supplied nonblocking adapter: >0 количество байт, 0 would-block, −1 закрытие; unregister(fd):void отключает readiness. sink.write(int):void фиксирует число байт. Readiness demultiplexer принадлежит I/O-провайдеру и публикует письма owner, не запускает второй turn.

[Отдельный листинг](examples/erlang/062_reactor.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. io.readReady(fd:int):int — supplied nonblocking adapter: >0 количество байт, 0 would-block, −1 закрытие; unregister(fd):void отключает readiness. sink.write(int):void фиксирует число байт. Readiness demultiplexer принадлежит I/O-провайдеру и публикует письма owner, не запускает второй turn.

## Сопоставление

У LMX событие готовности становится Message. Существенный признак Reactor сохранён: реальные байты читает handler после уведомления. Go/Erlang loops показывают тот же adapter boundary.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 100 | 10 |
| Go | 157 | 8 |
| Erlang | 168 | 8 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Descriptor readiness triggers a handler that performs a nonblocking read itself.

**Scenario.** A provider reports ready(fd=3); ReadReady(3) returns 2 bytes, then would-block=0.

**Expected observation.** The first readiness event performs a read and emits sink(2); would-block does not close the connection.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. io.readReady(fd:int):int is a supplied nonblocking adapter: >0 byte count, 0 would-block, -1 closure; unregister(fd):void disables readiness. sink.write(int):void records the byte count. The I/O provider owns readiness demultiplexing and mails the owner without starting a second turn.

**Comparison.** An LMX readiness notification becomes a Message. The Reactor distinction is preserved: the handler reads actual bytes after notification. Go/Erlang loops show the same adapter boundary.

**Scope and limitations.** This does not implement epoll/kqueue or zero-copy I/O. Buffers, edge-triggered draining, rearming and provider errors require an extended contract.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. io.readReady(fd:int):int is a supplied nonblocking adapter: >0 byte count, 0 would-block, -1 closure; unregister(fd):void disables readiness. sink.write(int):void records the byte count. The I/O provider owns readiness demultiplexing and mails the owner without starting a second turn.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. io.readReady(fd:int):int is a supplied nonblocking adapter: >0 byte count, 0 would-block, -1 closure; unregister(fd):void disables readiness. sink.write(int):void records the byte count. The I/O provider owns readiness demultiplexing and mails the owner without starting a second turn.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. io.readReady(fd:int):int is a supplied nonblocking adapter: >0 byte count, 0 would-block, -1 closure; unregister(fd):void disables readiness. sink.write(int):void records the byte count. The I/O provider owns readiness demultiplexing and mails the owner without starting a second turn.

## Источники / Sources

- [Douglas Schmidt — Reactor](https://www.dre.vanderbilt.edu/~schmidt/patterns-ace.html) — Готовность дескриптора запускает обработчик, который сам выполняет неблокирующее чтение.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
