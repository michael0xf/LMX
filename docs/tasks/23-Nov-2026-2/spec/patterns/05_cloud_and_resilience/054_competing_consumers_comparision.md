# 054. Competing Consumers

Несколько рабочих участников запрашивают работу у единственного владельца очереди.

## Общий сценарий

Очередь содержит 1,2,3. Два worker Message по очереди выполняют take до исчерпания.

**Ожидаемое наблюдение:** Каждое значение 1,2,3 выдаётся ровно одному worker в этом безаварийном прогоне; пустая очередь даёт −1.

**Граница сравнения:** Протокол и порты. Изъятие не равно durable acknowledgement. Сбой после take может потерять работу; для redelivery нужны leases/ack и идемпотентность. Глобальный порядок завершения не обещан.

## LMX

```lmx
JobQueueMessage:
    @: queue
    return: int
    take:
        if: queue\size() = 0
            return: -1
        return: queue\pop()

WorkerMessage:
    int: job
    @: queueOwner
    @: selfAddress
    @: process
    start:
        post:
            ask:
                queueOwner\take()
            answer:
                selfAddress\received
    ---
    received:
        if: job = -1
            return
        process(job)
        start()
```

queue.size/pop — FIFO одного JobQueueMessage. Хост создаёт два WorkerMessage, каждому явно передаёт queueOwner и selfAddress. Worker start и received посылают post и завершают turn; received вызывается следующим входом после результата take. Никакого блокирующего ожидания собственного answer внутри turn нет. process(int):void завершает работу и пишет в потокобезопасный sink. Go закрывает jobs channel; C# завершает ChannelWriter и запускает два Worker через Task.Run.

[Отдельный листинг](examples/lmx/054_competing_consumers.lm3)

## Go

```go
func Worker(jobs <-chan int, process func(int), done chan<- bool) {
    for job := range jobs { process(job) }
    done <- true
}
func Start(jobs <-chan int, process func(int)) {
    done := make(chan bool, 2)
    go Worker(jobs, process, done); go Worker(jobs, process, done)
    <-done; <-done
}
```

queue.size/pop — FIFO одного JobQueueMessage. Хост создаёт два WorkerMessage, каждому явно передаёт queueOwner и selfAddress. Worker start и received посылают post и завершают turn; received вызывается следующим входом после результата take. Никакого блокирующего ожидания собственного answer внутри turn нет. process(int):void завершает работу и пишет в потокобезопасный sink. Go закрывает jobs channel; C# завершает ChannelWriter и запускает два Worker через Task.Run.

[Отдельный листинг](examples/go/054_competing_consumers.go)

## C#

```csharp
static async System.Threading.Tasks.Task Worker(
    System.Threading.Channels.ChannelReader<int> jobs,
    System.Action<int> process) {
    await foreach (int job in jobs.ReadAllAsync()) process(job);
}
static System.Threading.Tasks.Task Start(
    System.Threading.Channels.ChannelReader<int> jobs,
    System.Action<int> process) =>
    System.Threading.Tasks.Task.WhenAll(
        System.Threading.Tasks.Task.Run(() => Worker(jobs, process)),
        System.Threading.Tasks.Task.Run(() => Worker(jobs, process)));
```

queue.size/pop — FIFO одного JobQueueMessage. Хост создаёт два WorkerMessage, каждому явно передаёт queueOwner и selfAddress. Worker start и received посылают post и завершают turn; received вызывается следующим входом после результата take. Никакого блокирующего ожидания собственного answer внутри turn нет. process(int):void завершает работу и пишет в потокобезопасный sink. Go закрывает jobs channel; C# завершает ChannelWriter и запускает два Worker через Task.Run.

[Отдельный листинг](examples/csharp/054_competing_consumers.cs)

## Разбор LMX

queue.size/pop — FIFO одного JobQueueMessage. Хост создаёт два WorkerMessage, каждому явно передаёт queueOwner и selfAddress. Worker start и received посылают post и завершают turn; received вызывается следующим входом после результата take. Никакого блокирующего ожидания собственного answer внутри turn нет. process(int):void завершает работу и пишет в потокобезопасный sink. Go закрывает jobs channel; C# завершает ChannelWriter и запускает два Worker через Task.Run.

## Сопоставление

Worker не конкурируют за выполнение одного LMX Thread: конкурируют запросы к QueueMessage, затем работа идёт в разных Message. Go channel и .NET Channel предоставляют собственную атомарную выдачу.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 242 | 24 | 242 |
| Go | 233 | 9 | — |
| C# | 445 | 11 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Several workers request work from a single queue owner.

**Scenario.** A queue contains 1,2,3. Two worker Messages repeatedly take jobs until exhausted.

**Expected observation.** Each of 1,2,3 is issued to one worker in this failure-free run; an empty queue yields -1.

**LMX.** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.

**Comparison.** Workers never concurrently execute one LMX Thread: take requests compete at QueueMessage, then work runs in distinct Messages. Go and .NET channels provide atomic dequeue.

**Scope and limitations.** Dequeue is not durable acknowledgement. Failure after take may lose work; redelivery requires leases/acks and idempotency. Global completion order is not promised.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.
- **Go:** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.
- **C#:** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.

## Источники / Sources

- [Microsoft Azure — Competing Consumers](https://learn.microsoft.com/en-us/azure/architecture/patterns/competing-consumers) — Несколько рабочих участников запрашивают работу у единственного владельца очереди.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
