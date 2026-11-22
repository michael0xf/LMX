# 059. Producer-Consumer

Производитель и потребитель связываются очередью, сохраняя порядок одного отправителя.

## Общий сценарий

Один producer отправляет 1,2,3, затем finish. Consumer суммирует значения.

**Ожидаемое наблюдение:** После finish получен 6; каждый элемент принят один раз в данном безаварийном локальном сценарии.

**Граница сравнения:** Протокол и порты. Одинаков итог, но не поведение перегрузки: для ограниченного LMX/Erlang пути нужен credit/capacity protocol, показанный отдельно в 87.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
ProducerMessage:
    @: consumer
    run:
        post:
            ask:
                consumer\accept(value := 1)
                consumer\accept(value := 2)
                consumer\accept(value := 3)
                consumer\finish()

ConsumerMessage:
    int: value
    int: total 0
    @: sink
    accept:
        node\total += value
    finish:
        sink\write(node\total)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. sink.write(int):void — supplied result sink. Хост запускает два Message и связывает consumer. Все четыре письма идут от одного отправителя к одному получателю; публикация и admission сохраняют их порядок. Между разными отправителями finish требует явного barrier.

[Отдельный листинг](examples/lmx/059_producer_consumer.lm3)

## Go

```go
func ProducerConsumer() int {
    items := make(chan int, 2)
    go func() { for _, v := range []int{1, 2, 3} { items <- v }; close(items) }()
    total := 0
    for v := range items { total += v }
    return total
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. sink.write(int):void — supplied result sink. Хост запускает два Message и связывает consumer. Все четыре письма идут от одного отправителя к одному получателю; публикация и admission сохраняют их порядок. Между разными отправителями finish требует явного barrier.

[Отдельный листинг](examples/go/059_producer_consumer.go)

## Erlang

```erlang
producer_consumer() ->
    Parent = self(),
    Consumer = spawn(fun() -> consume(0, Parent) end),
    Consumer ! {item, 1}, Consumer ! {item, 2}, Consumer ! {item, 3},
    Consumer ! finish,
    receive {total, Total} -> Total end.
consume(Total, Parent) ->
    receive
        {item, V} -> consume(Total + V, Parent);
        finish -> Parent ! {total, Total}
    end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. sink.write(int):void — supplied result sink. Хост запускает два Message и связывает consumer. Все четыре письма идут от одного отправителя к одному получателю; публикация и admission сохраняют их порядок. Между разными отправителями finish требует явного barrier.

[Отдельный листинг](examples/erlang/059_producer_consumer.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. sink.write(int):void — supplied result sink. Хост запускает два Message и связывает consumer. Все четыре письма идут от одного отправителя к одному получателю; публикация и admission сохраняют их порядок. Между разными отправителями finish требует явного barrier.

## Сопоставление

LMX и Erlang выражают consumer владельцем состояния; Go показывает канал между producer goroutine и вызывающей goroutine. Буфер Go ограничен двумя; базовый mailbox не получает такой предел автоматически.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 225 | 17 |
| Go | 154 | 7 |
| Erlang | 276 | 11 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A producer and consumer communicate through a queue while preserving one sender order.

**Scenario.** One producer sends 1,2,3 and then finish. The consumer sums the values.

**Expected observation.** After finish the result is 6; each item is consumed once in this failure-free local scenario.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.

**Comparison.** LMX and Erlang make the consumer an owner of state; Go uses a channel between producer and caller goroutines. The Go buffer is bounded at two; the base mailbox does not acquire that limit automatically.

**Scope and limitations.** The result matches, but overload behavior differs: bounded LMX/Erlang delivery needs the credit/capacity protocol shown separately in 87.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.

## Источники / Sources

- [Go — Pipelines and cancellation](https://go.dev/blog/pipelines) — Производитель и потребитель связываются очередью, сохраняя порядок одного отправителя.
- [Erlang — Concurrent Programming](https://www.erlang.org/doc/system/conc_prog.html) — Производитель и потребитель связываются очередью, сохраняя порядок одного отправителя.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
