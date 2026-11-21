# 054. Competing Consumers

Несколько рабочих участников запрашивают работу у единственного владельца очереди.

## Общий сценарий

Очередь содержит 1,2,3. Два worker Message по очереди выполняют take до исчерпания.

**Ожидаемое наблюдение:** Каждое значение 1,2,3 выдаётся ровно одному worker в этом безаварийном прогоне; пустая очередь даёт −1.

**Граница сравнения:** Протокол и порты. Изъятие не равно durable acknowledgement. Сбой после take может потерять работу; для redelivery нужны leases/ack и идемпотентность. Глобальный порядок завершения не обещан.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

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
    received:
        if: job = -1
            return
        process(job)
        post:
            ask:
                queueOwner\take()
            answer:
                selfAddress\received
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

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 285 | 27 |
| Go | 233 | 9 |
| C# | 445 | 11 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Several workers request work from a single queue owner.

**Scenario.** A queue contains 1,2,3. Two worker Messages repeatedly take jobs until exhausted.

**Expected observation.** Each of 1,2,3 is issued to one worker in this failure-free run; an empty queue yields -1.

**LMX.** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.

**Comparison.** Workers never concurrently execute one LMX Thread: take requests compete at QueueMessage, then work runs in distinct Messages. Go and .NET channels provide atomic dequeue.

**Scope and limitations.** Dequeue is not durable acknowledgement. Failure after take may lose work; redelivery requires leases/acks and idempotency. Global completion order is not promised.

### Dependencies and execution boundaries

- **LMX:** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.
- **Go:** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.
- **C#:** queue.size/pop is a FIFO of one JobQueueMessage. The host creates two WorkerMessages and explicitly supplies queueOwner and selfAddress. Worker start and received send post and end their turn; received is entered on a later input when take completes. No turn blocks awaiting its own answer handler. process(int):void completes work and writes to a thread-safe sink. Go closes jobs; C# completes ChannelWriter and starts both workers with Task.Run.

## Источники / Sources

- [Microsoft Azure — Competing Consumers](https://learn.microsoft.com/en-us/azure/architecture/patterns/competing-consumers) — Несколько рабочих участников запрашивают работу у единственного владельца очереди.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
