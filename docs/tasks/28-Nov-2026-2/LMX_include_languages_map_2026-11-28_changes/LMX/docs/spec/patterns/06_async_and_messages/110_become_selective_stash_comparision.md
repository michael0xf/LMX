# 110. Become / Selective Stash

Изменение поведения откладывает только work; control, queries и replies сохраняют обслуживание.

## Общий сценарий

В paused phase принять work(1,2) и work(2,3), третий work отклонить из-за capacity=2. Между ними обслужить query и reply. become(1) запускает FIFO pump по одному элементу на turn; stop отменяет оставшийся stash.

**Ожидаемое наблюдение:** Query видит phase=0,count=2; reply доставлен сразу по своему handler. Принятые work дают 4 и 6 по FIFO, без повторного эффекта от лишнего pump. Stop не помещается в stash и оставляет count=0.

**Граница сравнения:** Протокол и порты. Нет durable mailbox, общей selective-receive политики или автоматического повторения всех сообщений. Capacity=2 выбрана для проверяемого сценария. Внешний host не закрывает вход Go до завершения stop; hard termination вне этого договора.

## LMX

```lmx
# DRAFT. Only work is deferred. Control, queries and replies keep their routes.
SelectiveMessage:
    int: requestId
    int: value
    int: mode
    @: selfAddress
    @: events
    private: int: phase 0
    private: int: head 0
    private: int: count 0
    private: []int: ids [0 0]
    private: []int: values [0 0]
    work:
        if: node\phase = 2
            events\rejected(requestId; 2)
            return
        if: node\phase = 1 && node\count = 0
            events\finished(requestId; value * 2)
            return
        if: node\count = 2
            events\rejected(requestId; 1)
            return
        private: int: index (node\head + node\count) % 2
        node\ids[index] := requestId
        node\values[index] := value
        node\count += 1
        if: node\phase = 1
            post:
                ask:
                    selfAddress\pump()
    become:
        if: node\phase = 2 || mode < 0 || mode > 1
            return
        node\phase := mode
        if: node\phase = 1 && node\count > 0
            post:
                ask:
                    selfAddress\pump()
    pump:
        if: node\phase != 1 || node\count = 0
            return
        private: int: id node\ids[node\head]
        private: int: nextValue node\values[node\head]
        node\head := (node\head + 1) % 2
        node\count -= 1
        events\finished(id; nextValue * 2)
        if: node\count > 0
            post:
                ask:
                    selfAddress\pump()
    reply:
        events\replySeen(requestId; value)
    query:
        events\status(node\phase; node\count)
    stop:
        if: node\phase = 2
            return
        node\phase := 2
        while: node\count > 0
            private: int: id node\ids[node\head]
            node\head := (node\head + 1) % 2
            node\count -= 1
            events\rejected(id; 2)
        events\stopped()
```

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. Кольцо из двух элементов полностью реализовано внутри LMX: ids,values,head,count. phase 0 paused, 1 running, 2 stopped. become меняет обычные данные поведения; это не встроенный scheduler opcode. pump удаляет item до эффекта и публикует лишь следующий обычный self Message. Control/query/reply ни в одной ветви не идут в очередь work. Stash содержит copied scalar values, не ссылки на умерший Frame.

[Отдельный листинг](examples/lmx/110_become_selective_stash.lm3)

## Go

```go
type StashEvent struct { Kind, ID, Value, Mode int }
func RunSelective(in <-chan StashEvent, emit func(string, int, int)) {
    phase := 0
    queue := make([]StashEvent, 0, 2)
    wake := make(chan struct{}, 1)
    pump := func() { select { case wake <- struct{}{}: default: } }
    for {
        select {
        case event, open := <-in:
            if !open { return }
            switch event.Kind {
            case 0:
                if phase == 2 { emit("rejected", event.ID, 2); continue }
                if phase == 1 && len(queue) == 0 {
                    emit("finished", event.ID, event.Value * 2); continue
                }
                if len(queue) == 2 { emit("rejected", event.ID, 1); continue }
                queue = append(queue, event)
                if phase == 1 { pump() }
            case 1:
                if phase != 2 && event.Mode >= 0 && event.Mode <= 1 {
                    phase = event.Mode
                    if phase == 1 && len(queue) > 0 { pump() }
                }
            case 2:
                emit("reply", event.ID, event.Value)
            case 3:
                emit("status", phase, len(queue))
            case 4:
                if phase == 2 { continue }
                phase = 2
                for _, item := range queue { emit("rejected", item.ID, 2) }
                queue = queue[:0]
                emit("stopped", 0, 0)
            }
        case <-wake:
            if phase != 1 || len(queue) == 0 { continue }
            item := queue[0]; queue = queue[1:]
            emit("finished", item.ID, item.Value * 2)
            if len(queue) > 0 { pump() }
        }
    }
}
```

Полный channel/select loop: Kind 0 work, 1 become, 2 reply, 3 query, 4 stop. emit — nonblocking observer. Host сохраняет input до завершения stop; wake объединяет только scheduling hints, не work items.

[Отдельный листинг](examples/go/110_become_selective_stash.go)

## Erlang

```erlang
selective(Observer) -> selective_loop(Observer, 0, []).
selective_loop(Observer, Phase, Queue) ->
    receive
        {work, Id, _} when Phase =:= 2 ->
            Observer ! {rejected, Id, 2},
            selective_loop(Observer, Phase, Queue);
        {work, Id, Value} when Phase =:= 1, Queue =:= [] ->
            Observer ! {finished, Id, Value * 2},
            selective_loop(Observer, Phase, Queue);
        {work, Id, _} when length(Queue) =:= 2 ->
            Observer ! {rejected, Id, 1},
            selective_loop(Observer, Phase, Queue);
        {work, Id, Value} ->
            case Phase of 1 -> self() ! pump; _ -> ok end,
            selective_loop(Observer, Phase, Queue ++ [{Id, Value}]);
        {become, Mode} when Phase =/= 2, (Mode =:= 0 orelse Mode =:= 1) ->
            case {Mode, Queue} of {1, [_|_]} -> self() ! pump; _ -> ok end,
            selective_loop(Observer, Mode, Queue);
        pump when Phase =:= 1, Queue =/= [] ->
            [{Id, Value}|Rest] = Queue,
            Observer ! {finished, Id, Value * 2},
            case Rest of [] -> ok; _ -> self() ! pump end,
            selective_loop(Observer, Phase, Rest);
        {reply, Id, Value} ->
            Observer ! {reply_seen, Id, Value},
            selective_loop(Observer, Phase, Queue);
        query ->
            Observer ! {status, Phase, length(Queue)},
            selective_loop(Observer, Phase, Queue);
        stop when Phase =/= 2 ->
            [Observer ! {rejected, Id, 2} || {Id, _} <- Queue],
            Observer ! stopped,
            selective_loop(Observer, 2, []);
        terminate -> ok;
        _ -> selective_loop(Observer, Phase, Queue)
    end.
```

Обычный process loop с полной bounded queue. Только work помещается в stash. После stop query/reply остаются доступными до отдельного terminate от harness; module/export и launcher вне листинга.

[Отдельный листинг](examples/erlang/110_become_selective_stash.erl)

## Разбор LMX

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. Кольцо из двух элементов полностью реализовано внутри LMX: ids,values,head,count. phase 0 paused, 1 running, 2 stopped. become меняет обычные данные поведения; это не встроенный scheduler opcode. pump удаляет item до эффекта и публикует лишь следующий обычный self Message. Control/query/reply ни в одной ветви не идут в очередь work. Stash содержит copied scalar values, не ссылки на умерший Frame.

## Сопоставление

Go использует ограниченный slice и отдельный wake channel; Erlang — bounded list и self message. gen_statem postpone служит концептуальным аналогом, но здесь список явно ограничен и отложены только work. Полный небольшой FIFO включён во все листинги.

### Асинхронная граница

Ошибки маршрута, deadline, stale generation и blanket stash относятся к прикладному протоколу. Они не означают deadlock механизма Message. Все handlers завершают текущий turn; результаты приходят штатными сообщениями, без LMX synchronized или ожидания потока.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 1144 | 64 |
| Go | 936 | 43 |
| Erlang | 1120 | 36 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A behavior change defers only work; control, queries and replies remain serviceable.

**Scenario.** While paused, accept work(1,2) and work(2,3), reject the third work at capacity two, and serve query/reply. become(1) pumps FIFO work one item per turn; stop rejects any remainder.

**Expected observation.** Query observes phase 0/count 2 and reply runs through its own handler. Accepted work yields 4 then 6, with no repeated effect from extra pumps. Stop is never stashed and leaves count zero.

**LMX.** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. The two-item ring is entirely implemented in LMX using ids/values/head/count. Phases are paused 0, running 1, stopped 2. become changes ordinary behavior data, not a scheduler opcode. pump removes the item before its effect and posts only the next ordinary self Message. Control/query/reply never enter the work queue; stored values are scalars, not references to a dead Frame.

**Comparison.** Go uses a bounded slice and a separate wake channel; Erlang a bounded list and self message. gen_statem postpone is the conceptual analogue, but this queue is explicitly bounded and only work is deferred. Each listing includes its complete small FIFO.

**Scope and limitations.** No durable mailbox, general selective-receive policy or automatic replay of all messages. Capacity two makes the fixture bounded. The Go host keeps input open until stop completes; hard termination is outside this contract.

Routing, deadline, stale-generation and blanket-stash mistakes are application protocol errors, not Message scheduling deadlocks. Handlers finish their turns and receive ordinary later messages; no LMX synchronized or thread wait is introduced.

### Dependencies and execution boundaries

- **LMX:** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. The two-item ring is entirely implemented in LMX using ids/values/head/count. Phases are paused 0, running 1, stopped 2. become changes ordinary behavior data, not a scheduler opcode. pump removes the item before its effect and posts only the next ordinary self Message. Control/query/reply never enter the work queue; stored values are scalars, not references to a dead Frame.
- **Go:** Complete channel/select owner loop. Kind 0 work, 1 become, 2 reply, 3 query, 4 stop. emit is a nonblocking observer; the host keeps the input channel live through stop. The wake channel coalesces scheduling hints, not work items.
- **Erlang:** Ordinary process functions, with module/export and launcher outside the fragment. Only work tuples enter the bounded queue. The process keeps answering query/reply after stop until the harness sends terminate.

## Источники / Sources

- [Erlang gen_statem behavior](https://www.erlang.org/doc/system/statem.html) — Изменение состояния, postpone и сохранение системного обслуживания.
- [Go specification: select](https://go.dev/ref/spec) — Независимое обслуживание control и wake channels.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
