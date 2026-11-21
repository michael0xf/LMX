# 058. Thread Pool

Ограниченный набор исполнителей переиспользуется для последовательности заданий.

## Общий сценарий

Два worker обрабатывают четыре задания 1,2,3,4, вычисляя квадрат.

**Ожидаемое наблюдение:** Получено множество результатов {1,4,9,16}; одновременно активны не более двух worker. Порядок ответов не задан.

**Граница сравнения:** Протокол и порты. Показан пул задач, а не доказательство двух OS threads. Размер почты/буфера и fairness задаются отдельно; round-robin LMX не является work stealing.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
PoolMessage:
    int: job
    int: next 0
    @: worker0
    @: worker1
    submit:
        @: selected worker0
        if: node\next = 1
            selected := worker1
        node\next := 1 - node\next
        post:
            ask:
                selected\work(job := job)

WorkerMessage:
    int: job
    @: collector
    work:
        post:
            ask:
                collector\accept(value := job * job)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост создаёт ровно два WorkerMessage и один PoolMessage, явно передавая ссылки worker0/worker1/collector. collector.accept(int):void собирает четыре результата и используется как barrier. Pool хранит только прикладные адресаты; runtime membership остаётся Thread.children. Завершение работников после drain выполняет lifecycle harness.

[Отдельный листинг](examples/lmx/058_thread_pool.lm3)

## Go

```go
func Pool(input []int) []int {
    jobs := make(chan int, len(input))
    results := make(chan int, len(input))
    for worker := 0; worker < 2; worker++ {
        go func() { for job := range jobs { results <- job * job } }()
    }
    for _, job := range input { jobs <- job }; close(jobs)
    out := make([]int, 0, len(input))
    for range input { out = append(out, <-results) }
    return out
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. Хост создаёт ровно два WorkerMessage и один PoolMessage, явно передавая ссылки worker0/worker1/collector. collector.accept(int):void собирает четыре результата и используется как barrier. Pool хранит только прикладные адресаты; runtime membership остаётся Thread.children. Завершение работников после drain выполняет lifecycle harness.

[Отдельный листинг](examples/go/058_thread_pool.go)

## Erlang

```erlang
pool(Input) ->
    Parent = self(),
    A = spawn(fun() -> worker(Parent) end),
    B = spawn(fun() -> worker(Parent) end),
    distribute(Input, A, B),
    A ! stop, B ! stop,
    [receive {result, V} -> V end || _ <- Input].
distribute([], _, _) -> ok;
distribute([X | Xs], A, B) -> A ! {job, X}, distribute(Xs, B, A).
worker(Parent) ->
    receive
        {job, X} -> Parent ! {result, X * X}, worker(Parent);
        stop -> ok
    end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. Хост создаёт ровно два WorkerMessage и один PoolMessage, явно передавая ссылки worker0/worker1/collector. collector.accept(int):void собирает четыре результата и используется как barrier. Pool хранит только прикладные адресаты; runtime membership остаётся Thread.children. Завершение работников после drain выполняет lifecycle harness.

[Отдельный листинг](examples/erlang/058_thread_pool.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост создаёт ровно два WorkerMessage и один PoolMessage, явно передавая ссылки worker0/worker1/collector. collector.accept(int):void собирает четыре результата и используется как barrier. Pool хранит только прикладные адресаты; runtime membership остаётся Thread.children. Завершение работников после drain выполняет lifecycle harness.

## Сопоставление

LMX ограничивает количество логических исполнителей; отображение на OS threads определяется штатным Thread scheduler. Go goroutine и Erlang process также не равны одному выделенному OS thread.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 233 | 20 |
| Go | 290 | 11 |
| Erlang | 322 | 14 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A bounded set of workers is reused for a sequence of jobs.

**Scenario.** Two workers process four jobs 1,2,3,4, computing their squares.

**Expected observation.** The result multiset is {1,4,9,16}; no more than two workers are active. Reply order is unspecified.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host creates exactly two WorkerMessages and one PoolMessage, explicitly passing worker0/worker1/collector. collector.accept(int):void collects four results as a barrier. Pool stores application destinations; runtime membership remains Thread.children. The lifecycle harness closes workers after drain.

**Comparison.** LMX bounds logical workers; the ordinary Thread scheduler determines OS-thread mapping. Go goroutines and Erlang processes likewise are not dedicated OS threads.

**Scope and limitations.** This is a task pool, not proof of two OS threads. Mail/buffer capacity and fairness are separate; LMX round-robin is not work stealing.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host creates exactly two WorkerMessages and one PoolMessage, explicitly passing worker0/worker1/collector. collector.accept(int):void collects four results as a barrier. Pool stores application destinations; runtime membership remains Thread.children. The lifecycle harness closes workers after drain.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. The host creates exactly two WorkerMessages and one PoolMessage, explicitly passing worker0/worker1/collector. collector.accept(int):void collects four results as a barrier. Pool stores application destinations; runtime membership remains Thread.children. The lifecycle harness closes workers after drain.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. The host creates exactly two WorkerMessages and one PoolMessage, explicitly passing worker0/worker1/collector. collector.accept(int):void collects four results as a barrier. Pool stores application destinations; runtime membership remains Thread.children. The lifecycle harness closes workers after drain.

## Источники / Sources

- [Go — Effective Go concurrency](https://go.dev/doc/effective_go) — Ограниченный набор исполнителей переиспользуется для последовательности заданий.
- [Erlang — Concurrent Programming](https://www.erlang.org/doc/system/conc_prog.html) — Ограниченный набор исполнителей переиспользуется для последовательности заданий.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
