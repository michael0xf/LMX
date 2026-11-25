# 071. Half-Sync / Half-Async

Асинхронный ввод отделён очередью от синхронной обработки и выдачи результата.

## Общий сценарий

Ввод доставляет frame 3 и 4; worker синхронно вычисляет квадрат; writer получает 9 и 16.

**Ожидаемое наблюдение:** Обработка не выполняется внутри I/O callback; результаты 9,16 переданы writer.

**Граница сравнения:** Протокол и порты. Сама арифметика намеренно коротка; полезность проявляется при blocking/CPU work. Capacity и backpressure должны быть согласованы, иначе очередь только переместит перегрузку.

## LMX

```lmx
IngressMessage:
    int: frame
    @: worker
    received:
        post:
            ask:
                worker\process(frame := frame)

WorkerMessage:
    int: frame
    @: writer
    process:
        int: result frame * frame
        post:
            ask:
                writer\write(value := result)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Входной I/O adapter посылает уже выделенный frame:int в IngressMessage и не выполняет process на I/O callback. writer.write(int):void — поставленный выходной adapter; в LMX это отдельный Message. Хост явно запускает ingress,worker,writer. Контрольные версии получают decoded frames и Write.

[Отдельный листинг](examples/lmx/071_half_sync_half_async.lm3)

## Go

```go
func HalfSync(frames <-chan int, write func(int)) {
    jobs := make(chan int, 2)
    done := make(chan struct{})
    go func() {
        for frame := range jobs { write(frame * frame) }
        close(done)
    }()
    for frame := range frames { jobs <- frame }
    close(jobs); <-done
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. Входной I/O adapter посылает уже выделенный frame:int в IngressMessage и не выполняет process на I/O callback. writer.write(int):void — поставленный выходной adapter; в LMX это отдельный Message. Хост явно запускает ingress,worker,writer. Контрольные версии получают decoded frames и Write.

[Отдельный листинг](examples/go/071_half_sync_half_async.go)

## Erlang

```erlang
half_sync(Frames, Write) ->
    Parent = self(),
    Worker = spawn(fun() -> sync_worker(Write, Parent) end),
    [Worker ! {frame,F} || F <- Frames], Worker ! stop,
    receive drained -> ok end.
sync_worker(Write, Parent) ->
    receive
        {frame,F} -> Write(F * F), sync_worker(Write, Parent);
        stop -> Parent ! drained
    end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. Входной I/O adapter посылает уже выделенный frame:int в IngressMessage и не выполняет process на I/O callback. writer.write(int):void — поставленный выходной adapter; в LMX это отдельный Message. Хост явно запускает ingress,worker,writer. Контрольные версии получают decoded frames и Write.

[Отдельный листинг](examples/erlang/071_half_sync_half_async.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Входной I/O adapter посылает уже выделенный frame:int в IngressMessage и не выполняет process на I/O callback. writer.write(int):void — поставленный выходной adapter; в LMX это отдельный Message. Хост явно запускает ingress,worker,writer. Контрольные версии получают decoded frames и Write.

## Сопоставление

Разделение ролей выражается самостоятельными Message и почтой. Go канал соединяет async-facing слой и sync worker; Erlang отделяет процесс worker от отправителя.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>174</u></span> | 15 |
| Go | 205 | 10 |
| Erlang | 259 | 10 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Asynchronous ingress is separated by a queue from synchronous processing and response delivery.

**Scenario.** Ingress delivers frames 3 and 4; a worker computes each square synchronously; the writer receives 9 and 16.

**Expected observation.** Processing does not run inside the I/O callback; the writer receives 9,16.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The ingress I/O adapter mails a framed int to IngressMessage without executing process on its I/O callback. writer.write(int):void is a supplied output adapter; in LMX it is another Message. The host explicitly launches ingress, worker and writer. Controls receive decoded frames and Write.

**Comparison.** Independent Messages and mail express the role separation. A Go channel connects the async-facing layer to a synchronous worker; Erlang separates the worker process from the sender.

**Scope and limitations.** Arithmetic is deliberately small; the pattern matters with blocking/CPU work. Capacity and backpressure must be coordinated or the queue merely relocates overload.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The ingress I/O adapter mails a framed int to IngressMessage without executing process on its I/O callback. writer.write(int):void is a supplied output adapter; in LMX it is another Message. The host explicitly launches ingress, worker and writer. Controls receive decoded frames and Write.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. The ingress I/O adapter mails a framed int to IngressMessage without executing process on its I/O callback. writer.write(int):void is a supplied output adapter; in LMX it is another Message. The host explicitly launches ingress, worker and writer. Controls receive decoded frames and Write.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. The ingress I/O adapter mails a framed int to IngressMessage without executing process on its I/O callback. writer.write(int):void is a supplied output adapter; in LMX it is another Message. The host explicitly launches ingress, worker and writer. Controls receive decoded frames and Write.

## Источники / Sources

- [Douglas Schmidt — Half-Sync/Half-Async](https://www.dre.vanderbilt.edu/~schmidt/patterns-ace.html) — Асинхронный ввод отделён очередью от синхронной обработки и выдачи результата.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
