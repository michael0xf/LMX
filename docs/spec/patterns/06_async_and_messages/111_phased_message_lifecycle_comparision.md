# 111. Phased Message Lifecycle

Живой parent сначала завершает работу детей, затем закрывает их, затем закрывается сам.

## Общий сценарий

Два текущих ребёнка получают drain. Каждый запускает native flush и продолжает query; flushed освобождает завершённый native ресурс и посылает drained. После двух drained parent запрашивает закрытие children, после двух stopped публикует итог и закрывает себя.

**Ожидаемое наблюдение:** Порядок phase parent: 0→1→2→3; duplicate и чужое epoch ничего не уменьшают. Query работает в phases 1 и 2. Итог ровно один, и нет запроса или ожидания из уже остановленного parent/poststop.

**Граница сравнения:** Протокол и порты. Ограниченный graceful fixture: оба ребёнка живы при beginStop, все native flush завершаются, host сообщает actual stopped. Неожиданный hard crash, watchdog и restart — дополнительные сценарии 089/host provider, не фиктивный успешный drain. Flush failure передаётся как failed итог после корректного освобождения ресурса.

## LMX

```lmx
# DRAFT. A live parent drains, requests child close, then closes itself.
PhasedParentMessage:
    int: childId
    i64: epoch
    int: ok
    @: first
    @: second
    @: lifecycle
    @: events
    private: i64: generation 1
    private: int: phase 0
    private: int: failed 0
    private: int: pendingDrain 2
    private: int: pendingStop 2
    private: []int: drainedSeen [0 0]
    private: []int: stoppedSeen [0 0]
    beginStop:
        if: node\phase != 0
            return
        node\phase := 1
        post:
            ask:
                first\drain(epoch := node\generation)
                second\drain(epoch := node\generation)
    drained:
        if: node\phase != 1 || epoch != node\generation || childId < 0 || childId > 1
            return
        if: node\drainedSeen[childId] = 1
            return
        node\drainedSeen[childId] := 1
        if: ok != 1
            node\failed := 1
        node\pendingDrain -= 1
        if: node\pendingDrain = 0
            node\phase := 2
            lifecycle\requestChildrenClose(node\generation)
    stopped:
        if: node\phase != 2 || epoch != node\generation || childId < 0 || childId > 1
            return
        if: node\stoppedSeen[childId] = 1
            return
        node\stoppedSeen[childId] := 1
        node\pendingStop -= 1
        if: node\pendingStop = 0
            node\phase := 3
            events\finished(1 - node\failed)
            lifecycle\requestOwnerClose()
    query:
        events\status(node\phase; node\pendingDrain; node\pendingStop)

PhasedChildMessage:
    i64: epoch
    int: ok
    int: value
    @: parentAddress
    @: selfAddress
    @: native
    @: events
    private: int: childId
    private: i64: generation 1
    private: int: phase 0
    work:
        if: node\phase != 0
            events\rejected()
            return
        events\value(value * 2)
    drain:
        if: node\phase != 0 || epoch != node\generation
            return
        node\phase := 1
        native\beginFlush(node\generation; selfAddress)
    flushed:
        if: node\phase != 1 || epoch != node\generation
            return
        native\releaseCompleted()
        node\phase := 2
        post:
            ask:
                parentAddress\drained(childId := node\childId; epoch := node\generation; ok := ok)
    query:
        events\childStatus(node\childId; node\phase)
```

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. lifecycle.requestChildrenClose(epoch) только инициирует штатное закрытие двух прямых Thread.children; stopped(id,epoch) доставляется после действительной остановки и cleanup. Прикладные first/second являются адресатами drain, не вторым membership registry. requestOwnerClose инициируется в живом handler только после всех stopped. native.beginFlush возвращает admission сразу и позже посылает flushed(epoch,ok); releaseCompleted не ждёт будущего callback. childId 0/1 и generation задаёт host при создании отдельных экземпляров.

[Отдельный листинг](examples/lmx/111_phased_message_lifecycle.lm3)

## Go

```go
type PhaseEvent struct { Kind, Child, Value int; Epoch int64; OK bool }
type ParentPorts struct {
    Drain func(int, int64)
    CloseChildren func(int64)
    CloseOwner func()
    Finished func(bool)
    Status func(int, int, int)
}
func RunPhaseParent(in <-chan PhaseEvent, epoch int64, p ParentPorts) {
    phase, drain, stop := 0, 2, 2
    failed := false
    var drained, stopped [2]bool
    for e := range in {
        switch e.Kind {
        case 0:
            if phase != 0 { continue }
            phase = 1; p.Drain(0, epoch); p.Drain(1, epoch)
        case 1:
            if phase != 1 || e.Epoch != epoch || e.Child < 0 || e.Child > 1 || drained[e.Child] { continue }
            drained[e.Child] = true; failed = failed || !e.OK; drain--
            if drain == 0 { phase = 2; p.CloseChildren(epoch) }
        case 2:
            if phase != 2 || e.Epoch != epoch || e.Child < 0 || e.Child > 1 || stopped[e.Child] { continue }
            stopped[e.Child] = true; stop--
            if stop == 0 { phase = 3; p.Finished(!failed); p.CloseOwner() }
        case 3:
            p.Status(phase, drain, stop)
        }
    }
}
type ChildPorts struct {
    Flush func(int64)
    ReleaseCompleted func()
    Drained func(int, int64, bool)
    Value func(int)
    Rejected func()
    Status func(int, int)
}
func RunPhaseChild(in <-chan PhaseEvent, id int, epoch int64, p ChildPorts) {
    phase := 0
    for e := range in {
        switch e.Kind {
        case 0:
            if phase != 0 { p.Rejected() } else { p.Value(e.Value * 2) }
        case 1:
            if phase == 0 && e.Epoch == epoch { phase = 1; p.Flush(epoch) }
        case 2:
            if phase == 1 && e.Epoch == epoch {
                p.ReleaseCompleted(); phase = 2; p.Drained(id, epoch, e.OK)
            }
        case 3:
            p.Status(id, phase)
        }
    }
}
```

Полные parent/child handlers. Ports асинхронно маршрутизируют Drain, Flush, Drained и actual stopped. CloseChildren/CloseOwner инициируют lifecycle без join в handler. Host задаёт generation и два child IDs.

[Отдельный листинг](examples/go/111_phased_message_lifecycle.go)

## Erlang

```erlang
phase_parent(A, B, Observer) ->
    RA = monitor(process, A), RB = monitor(process, B),
    phase_loop(A, B, RA, RB, Observer, 1, 0, #{}, #{}, false).
phase_loop(A, B, RA, RB, Observer, Gen, Phase, Drained, Stopped, Failed) ->
    receive
        begin_stop when Phase =:= 0 ->
            A ! {drain, self(), Gen}, B ! {drain, self(), Gen},
            phase_loop(A,B,RA,RB,Observer,Gen,1,Drained,Stopped,Failed);
        {drained, Id, Gen, _} when Phase =:= 1, is_map_key(Id, Drained) ->
            phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,Stopped,Failed);
        {drained, Id, Gen, OK} when Phase =:= 1, Id >= 0, Id =< 1 ->
            D = Drained#{Id => true}, F = Failed orelse not OK,
            P = case map_size(D) of
                2 -> A ! stop, B ! stop, 2;
                _ -> 1
            end,
            phase_loop(A,B,RA,RB,Observer,Gen,P,D,Stopped,F);
        {'DOWN', Ref, process, Pid, _} when Phase =:= 2,
              ((Ref =:= RA andalso Pid =:= A) orelse
               (Ref =:= RB andalso Pid =:= B)) ->
            S = Stopped#{Ref => true},
            case map_size(S) of
                2 -> Observer ! {finished, not Failed}, ok;
                _ -> phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,S,Failed)
            end;
        query ->
            Observer ! {status, Phase, 2-map_size(Drained), 2-map_size(Stopped)},
            phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,Stopped,Failed);
        _ -> phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,Stopped,Failed)
    end.
phase_child(Id, Gen, Observer, Flush, Release) ->
    phase_child_loop(Id,Gen,Observer,Flush,Release,0,undefined).
phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent) ->
    receive
        {work, Value} when Phase =:= 0 ->
            Observer ! {value, Value*2},
            phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent);
        {work, _} ->
            Observer ! rejected,
            phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent);
        {drain, From, Gen} when Phase =:= 0 ->
            Flush(Gen, self()),
            phase_child_loop(Id,Gen,Observer,Flush,Release,1,From);
        {flushed, Gen, OK} when Phase =:= 1 ->
            Release(), Parent ! {drained, Id, Gen, OK},
            phase_child_loop(Id,Gen,Observer,Flush,Release,2,Parent);
        query ->
            Observer ! {child_status,Id,Phase},
            phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent);
        stop when Phase =:= 2 -> ok;
        _ -> phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent)
    end.
```

Parent и children — отдельные процессы. Parent использует настоящие monitors и сверяет monitor reference вместе с PID. Flush — явно поставленный async native adapter; Release вызывается после completion. Child не вызывает блокирующий stop своего supervisor.

[Отдельный листинг](examples/erlang/111_phased_message_lifecycle.erl)

## Разбор LMX

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. lifecycle.requestChildrenClose(epoch) только инициирует штатное закрытие двух прямых Thread.children; stopped(id,epoch) доставляется после действительной остановки и cleanup. Прикладные first/second являются адресатами drain, не вторым membership registry. requestOwnerClose инициируется в живом handler только после всех stopped. native.beginFlush возвращает admission сразу и позже посылает flushed(epoch,ok); releaseCompleted не ждёт будущего callback. childId 0/1 и generation задаёт host при создании отдельных экземпляров.

## Сопоставление

Это дополнение к 089 Supervision Tree: рестарт и его budget остаются отдельной политикой. Go явно хранит phases и seen arrays, Erlang подтверждает остановку monitor references/DOWN, LMX использует штатный lifecycle provider. Фаза остановки не переносится в poststop.

### Асинхронная граница

Ошибки маршрута, deadline, stale generation и blanket stash относятся к прикладному протоколу. Они не означают deadlock механизма Message. Все handlers завершают текущий turn; результаты приходят штатными сообщениями, без LMX synchronized или ожидания потока.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 1562 | 80 |
| Go | 1233 | 55 |
| Erlang | 1858 | 52 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A live parent drains children, then closes them, then closes itself.

**Scenario.** Two current children receive drain. Each starts native flush and keeps serving query; flushed releases the completed native resource and sends drained. After both drained events the parent requests child close; after both stopped events it publishes the result and closes itself.

**Expected observation.** Parent phases progress 0→1→2→3; duplicates and foreign epochs do not decrement counts. Query works in phases 1 and 2. Exactly one result is published, with no request or wait from a stopped parent/poststop.

**LMX.** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. requestChildrenClose(epoch) only initiates ordinary close of the two direct Thread.children; stopped arrives after actual termination and cleanup. first/second are drain destinations, not another membership registry. requestOwnerClose starts from the live handler after all stopped events. beginFlush admits immediately and later sends flushed; releaseCompleted never waits for another callback. The host binds childId 0/1 and the generation when creating distinct instances.

**Comparison.** This complements 089 Supervision Tree; restart and its budget remain separate policy. Go stores phases/seen arrays, Erlang confirms termination through monitor references/DOWN, and LMX uses its ordinary lifecycle provider. Shutdown coordination never moves into poststop.

**Scope and limitations.** Bounded graceful fixture: both children are alive at beginStop, native flushes complete, and the host reports actual stopped. Hard crash, watchdog and restart remain separate 089/host scenarios, never a fabricated successful drain. A flush failure yields a failed result after resources are released.

Routing, deadline, stale-generation and blanket-stash mistakes are application protocol errors, not Message scheduling deadlocks. Handlers finish their turns and receive ordinary later messages; no LMX synchronized or thread wait is introduced.

### Dependencies and execution boundaries

- **LMX:** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. requestChildrenClose(epoch) only initiates ordinary close of the two direct Thread.children; stopped arrives after actual termination and cleanup. first/second are drain destinations, not another membership registry. requestOwnerClose starts from the live handler after all stopped events. beginFlush admits immediately and later sends flushed; releaseCompleted never waits for another callback. The host binds childId 0/1 and the generation when creating distinct instances.
- **Go:** Complete parent/child channel handlers; ports asynchronously route Drain, Flush, Drained and actual stopped events. CloseChildren/CloseOwner initiate lifecycle requests without joining a goroutine inside a handler. The host supplies generation and two child IDs.
- **Erlang:** Parent and children are separate ordinary processes. Parent uses real process monitors and matches both monitor reference and PID. Flush is an explicitly supplied asynchronous native adapter, Release returns after completed flush cleanup. No child calls a blocking parent supervisor stop.

## Источники / Sources

- [Erlang supervisor behavior](https://www.erlang.org/doc/system/sup_princ.html) — Shutdown является фазой жизненного цикла, restart — отдельная стратегия.
- [Go pipelines and cancellation](https://go.dev/blog/pipelines) — Прекращение admission отличается от завершения уже запущенной работы.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
