# 059. Producer-Consumer

Производитель и потребитель связываются очередью, сохраняя порядок одного отправителя.

## Общий сценарий

Один producer отправляет 1,2,3, затем finish. Consumer суммирует значения.

**Ожидаемое наблюдение:** После finish получен 6; каждый элемент принят один раз в данном безаварийном локальном сценарии.

**Граница сравнения:** Протокол и порты. Одинаков итог, но не поведение перегрузки: для ограниченного LMX/Erlang пути нужен credit/capacity protocol, показанный отдельно в 87.

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

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 225 | 17 | 225 |
| Go | 154 | 7 | — |
| Erlang | 276 | 11 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

A producer and consumer communicate through a queue while preserving one sender order.

**Scenario.** One producer sends 1,2,3 and then finish. The consumer sums the values.

**Expected observation.** After finish the result is 6; each item is consumed once in this failure-free local scenario.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.

**Comparison.** LMX and Erlang make the consumer an owner of state; Go uses a channel between producer and caller goroutines. The Go buffer is bounded at two; the base mailbox does not acquire that limit automatically.

**Scope and limitations.** The result matches, but overload behavior differs: bounded LMX/Erlang delivery needs the credit/capacity protocol shown separately in 87.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. sink.write(int):void is a supplied result sink. The host launches two Messages and binds consumer. All four letters go from one sender to one recipient; publication/admission preserve their order. Across senders, finish needs an explicit barrier.

## Источники / Sources

- [Go — Pipelines and cancellation](https://go.dev/blog/pipelines) — Производитель и потребитель связываются очередью, сохраняя порядок одного отправителя.
- [Erlang — Concurrent Programming](https://www.erlang.org/doc/system/conc_prog.html) — Производитель и потребитель связываются очередью, сохраняя порядок одного отправителя.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
