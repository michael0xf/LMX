# 053. Queue-Based Load Leveling

Буферная очередь отделяет быстрый приём запросов от ограниченной скорости обработки.

## Общий сценарий

В очередь сразу поступают 1,2,3. Каждый tick обрабатывает не более одного элемента.

**Ожидаемое наблюдение:** После первого tick обработан только 1; после трёх — 1,2,3, очередь пуста.

**Граница сравнения:** Протокол и порты. Очередь в памяти не переживает crash. Capacity, persistence, retry и dead-letter policy являются расширениями, одинаково необходимыми во всех языках.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
BufferMessage:
    int: job
    @: queue
    @: process
    accept:
        queue\push(job)
    tick:
        if: queue\size() > 0
            int: next queue\pop()
            process(next)
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. queue.push(int), size():int, pop():int — поставленная owner-local FIFO, pop требует непустую очередь; process(int):void — завершённая обработка. Хост посылает accept и tick владельцу; tick не запускается автоматически почтой. В Go/C# вызовы экземпляра также serial.

[Отдельный листинг](examples/lmx/053_queue_based_load_leveling.lm3)

## Go

```go
type Buffer struct { jobs []int }
func (b *Buffer) Accept(job int) { b.jobs = append(b.jobs, job) }
func (b *Buffer) Tick(process func(int)) {
    if len(b.jobs) == 0 { return }
    job := b.jobs[0]; b.jobs = b.jobs[1:]; process(job)
}
```

queue.push(int), size():int, pop():int — поставленная owner-local FIFO, pop требует непустую очередь; process(int):void — завершённая обработка. Хост посылает accept и tick владельцу; tick не запускается автоматически почтой. В Go/C# вызовы экземпляра также serial. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/053_queue_based_load_leveling.go)

## C#

```csharp
sealed class Buffer {
    readonly System.Collections.Generic.Queue<int> jobs = new();
    public void Accept(int job) => jobs.Enqueue(job);
    public void Tick(System.Action<int> process) {
        if (jobs.Count > 0) process(jobs.Dequeue());
    }
}
```

queue.push(int), size():int, pop():int — поставленная owner-local FIFO, pop требует непустую очередь; process(int):void — завершённая обработка. Хост посылает accept и tick владельцу; tick не запускается автоматически почтой. В Go/C# вызовы экземпляра также serial. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/053_queue_based_load_leveling.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. queue.push(int), size():int, pop():int — поставленная owner-local FIFO, pop требует непустую очередь; process(int):void — завершённая обработка. Хост посылает accept и tick владельцу; tick не запускается автоматически почтой. В Go/C# вызовы экземпляра также serial.

## Сопоставление

LMX inbox служит доставке, а прикладной буфер и темп обслуживания здесь заданы явно. Ни один листинг не маскирует unbounded очередь как backpressure.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 113 | 10 |
| Go | 189 | 6 |
| C# | 202 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A queue decouples burst admission from a limited processing rate.

**Scenario.** A burst enqueues 1,2,3. Each tick processes at most one item.

**Expected observation.** After one tick only 1 is processed; after three, 1,2,3 are processed and the queue is empty.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. queue.push(int), size():int, pop():int is a supplied owner-local FIFO; pop requires nonempty input. process(int):void completes processing. The host sends accept and tick to the owner; mail does not generate ticks. Go/C# instances are likewise serial.

**Comparison.** The LMX inbox provides delivery; the application buffer and processing rate are explicit. No listing misrepresents an unbounded queue as backpressure.

**Scope and limitations.** The in-memory queue does not survive a crash. Capacity, persistence, retry and dead-letter policy are extensions required in every language.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. queue.push(int), size():int, pop():int is a supplied owner-local FIFO; pop requires nonempty input. process(int):void completes processing. The host sends accept and tick to the owner; mail does not generate ticks. Go/C# instances are likewise serial.
- **Go:** queue.push(int), size():int, pop():int is a supplied owner-local FIFO; pop requires nonempty input. process(int):void completes processing. The host sends accept and tick to the owner; mail does not generate ticks. Go/C# instances are likewise serial. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** queue.push(int), size():int, pop():int is a supplied owner-local FIFO; pop requires nonempty input. process(int):void completes processing. The host sends accept and tick to the owner; mail does not generate ticks. Go/C# instances are likewise serial. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Queue-Based Load Leveling](https://learn.microsoft.com/en-us/azure/architecture/patterns/queue-based-load-leveling) — Буферная очередь отделяет быстрый приём запросов от ограниченной скорости обработки.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
