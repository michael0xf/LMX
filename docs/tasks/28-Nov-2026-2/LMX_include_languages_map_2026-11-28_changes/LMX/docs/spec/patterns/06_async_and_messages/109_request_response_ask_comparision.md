# 109. Request-Response / Ask

Запрос завершается поздним reply либо deadline; owner продолжает обслуживать сообщения.

## Общий сценарий

Один запрос с token=1 истекает. После этого начинается token=2. Поздний reply token=1 игнорируется; reply token=2 со значением 12 принимается. Query обслуживается при active=1.

**Ожидаемое наблюдение:** Для token=1 один terminal timeout, для token=2 один результат 12; повторный reply/deadline не создаёт нового результата. Busy и исчерпание i64 counter дают отдельный отказ.

**Граница сравнения:** Протокол и порты. Один in-flight request на экземпляр; durable retries, exactly-once effect, service cancellation и общий multiplexed pending map не обещаны. Token counter не переиспользуется; новая owner identity отделяет следующий запуск. Все значения примера малы и не переполняют арифметику service.

## LMX

```lmx
# DRAFT. One pending business request; ordinary post owns transport correlation.
AskReply:
    i64: token
    int: value

AskClientMessage:
    int: value
    i64: token
    @AskReply: response
    @: service
    @: timer
    @: selfAddress
    @: events
    private: int: active 0
    private: i64: next 0
    private: i64: current 0
    start:
        if: node\active = 1
            events\rejected(1)
            return
        if: node\next = 9223372036854775807
            events\rejected(2)
            return
        node\next += 1
        node\current := node\next
        node\active := 1
        timer\schedule(node\current; selfAddress)
        post:
            ask:
                service\compute(token := node\current; value := value)
            answer:
                selfAddress\received
    received:
        if: node\active = 0 || response\token != node\current
            return
        node\active := 0
        events\finished(response\token; 0; response\value)
    expire:
        if: node\active = 0 || token != node\current
            return
        node\active := 0
        events\finished(token; 1; 0)
    query:
        events\status(node\active; node\current)

AskServiceMessage:
    i64: token
    int: value
    return: @AskReply
    compute:
        private: @AskReply: result (copy(AskReply))
        result\token := token
        result\value := value * 2
        return: result
```

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. timer.schedule(token,selfAddress) только регистрирует поздний expire(token), не вызывает его внутри start. Service возвращает AskReply, answer выбирает received. Timeout переводит только локальный запрос в terminal state и не отменяет совершённый сервисом эффект. finished(token,status,value): status=0 success, status=1 timeout; при timeout value не является результатом. Host сохраняет ожидаемый failure route обычного post при transport rejection; здесь service/timer admission заранее принят.

[Отдельный листинг](examples/lmx/109_request_response_ask.lm3)

## Go

```go
type AskReply struct { Token int64; Value int }
type AskEvent struct { Kind int; Token int64; Value int; Reply AskReply }
type AskPorts struct {
    Compute func(int64, int)
    Schedule func(int64)
    Finished func(int64, bool, int)
    Rejected func(int)
    Status func(bool, int64)
}
func RunAsk(in <-chan AskEvent, p AskPorts) {
    var next, current int64
    active := false
    for event := range in {
        switch event.Kind {
        case 0:
            if active { p.Rejected(1); continue }
            if next == 9223372036854775807 { p.Rejected(2); continue }
            next++; current = next; active = true
            p.Schedule(current)
            p.Compute(current, event.Value)
        case 1:
            if active && event.Reply.Token == current {
                active = false
                p.Finished(current, false, event.Reply.Value)
            }
        case 2:
            if active && event.Token == current {
                active = false
                p.Finished(current, true, 0)
            }
        case 3:
            p.Status(active, current)
        }
    }
}
func DoubleReply(token int64, value int) AskReply {
    return AskReply{Token: token, Value: value * 2}
}
```

Полный channel loop. Compute ставит DoubleReply в отдельный service; Schedule публикует позднее событие Kind=2. Оба supplied ports возвращаются сразу. Finished/Rejected/Status — nonblocking observer. Host wiring и физический таймер перечислены отдельно.

[Отдельный листинг](examples/go/109_request_response_ask.go)

## Erlang

```erlang
ask_client(Service, Observer, Delay) ->
    ask_loop(Service, Observer, Delay, 0, 0, false).
ask_loop(Service, Observer, Delay, Next, Current, Active) ->
    receive
        {start, _} when Active ->
            Observer ! {rejected, 1},
            ask_loop(Service, Observer, Delay, Next, Current, Active);
        {start, _} when Next =:= 9223372036854775807 ->
            Observer ! {rejected, 2},
            ask_loop(Service, Observer, Delay, Next, Current, Active);
        {start, Value} ->
            Token = Next + 1,
            erlang:send_after(Delay, self(), {expire, Token}),
            Service ! {compute, self(), Token, Value},
            ask_loop(Service, Observer, Delay, Token, Token, true);
        {computed, Current, Value} when Active ->
            Observer ! {finished, Current, false, Value},
            ask_loop(Service, Observer, Delay, Next, Current, false);
        {expire, Current} when Active ->
            Observer ! {finished, Current, true, 0},
            ask_loop(Service, Observer, Delay, Next, Current, false);
        query ->
            Observer ! {status, Active, Current},
            ask_loop(Service, Observer, Delay, Next, Current, Active);
        stop -> ok;
        _ -> ask_loop(Service, Observer, Delay, Next, Current, Active)
    end.
ask_service() ->
    receive
        {compute, From, Token, Value} ->
            From ! {computed, Token, Value * 2}, ask_service();
        stop -> ok
    end.
```

Функции одного обычного модуля; module/export и launcher вне фрагмента. Service и client — разные процессы; send_after — настоящий timer. Fixture задаёт порядок событий; timeout не доказывает отсутствие эффекта сервиса.

[Отдельный листинг](examples/erlang/109_request_response_ask.erl)

## Разбор LMX

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. timer.schedule(token,selfAddress) только регистрирует поздний expire(token), не вызывает его внутри start. Service возвращает AskReply, answer выбирает received. Timeout переводит только локальный запрос в terminal state и не отменяет совершённый сервисом эффект. finished(token,status,value): status=0 success, status=1 timeout; при timeout value не является результатом. Host сохраняет ожидаемый failure route обычного post при transport rejection; здесь service/timer admission заранее принят.

## Сопоставление

LMX показывает post/answer и owner state; Go — тот же автомат в channel loop с явными nonblocking Compute/Schedule ports; Erlang — process receive и send_after. Это прикладное управление deadline, а не новый блокирующий ask primitive.

### Асинхронная граница

Ошибки маршрута, deadline, stale generation и blanket stash относятся к прикладному протоколу. Они не означают deadlock механизма Message. Все handlers завершают текущий turn; результаты приходят штатными сообщениями, без LMX synchronized или ожидания потока.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 930 | 52 |
| Go | 799 | 38 |
| Erlang | 1024 | 33 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A request finishes through a later reply or deadline while its owner continues serving messages.

**Scenario.** Request token 1 expires, then token 2 starts. A late reply for token 1 is ignored; token 2 accepts value 12. Query remains serviceable while active.

**Expected observation.** Token 1 has one terminal timeout and token 2 one result 12; repeated replies/deadlines create no further result. Busy and i64 counter exhaustion are separate rejections.

**LMX.** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. timer.schedule(token,selfAddress) registers a later expire(token), never reenters start. The service returns AskReply and answer selects received. Timeout ends only the local request and does not undo a service effect. finished status 0 means success and 1 timeout; the timeout value is inactive. The ordinary post failure route handles transport rejection; this fixture pre-admits service/timer delivery.

**Comparison.** LMX shows post/answer and owner state, Go the same state machine in a channel loop with nonblocking Compute/Schedule ports, and Erlang receive/send_after. This is application deadline policy, not a new blocking ask primitive.

**Scope and limitations.** One in-flight request per instance. No durable retry, exactly-once effect, service cancellation or general multiplexed pending map. Tokens are not reused; a new owner identity separates restarts. Fixture values do not overflow service arithmetic.

Routing, deadline, stale-generation and blanket-stash mistakes are application protocol errors, not Message scheduling deadlocks. Handlers finish their turns and receive ordinary later messages; no LMX synchronized or thread wait is introduced.

### Dependencies and execution boundaries

- **LMX:** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. timer.schedule(token,selfAddress) registers a later expire(token), never reenters start. The service returns AskReply and answer selects received. Timeout ends only the local request and does not undo a service effect. finished status 0 means success and 1 timeout; the timeout value is inactive. The ordinary post failure route handles transport rejection; this fixture pre-admits service/timer delivery.
- **Go:** Go channel loop is complete; Compute queues DoubleReply on a separate service, Schedule queues a later Kind=2 event. Both supplied ports return immediately. Finished/Rejected/Status are nonblocking observers. Host wiring and timer implementation are outside the measured listing.
- **Erlang:** Functions belong to one ordinary Erlang module; module/export and launcher are outside the fragment. The service and client are separate processes. send_after is an actual timer. The fixture injects controlled completion order; it does not assert a timed-out operation never ran.

## Источники / Sources

- [Go specification: channel and select](https://go.dev/ref/spec) — Channel loop и порядок событий.
- [Erlang gen_statem: asynchronous requests](https://www.erlang.org/doc/apps/stdlib/gen_statem.html) — Поздний reply и явный request identity.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
