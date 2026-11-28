# 112. External Blocking Adapter

Физический блокирующий вызов вынесен в native L2 worker; LMX получает обычный Message completion.

## Общий сценарий

Принять один native job, обслужить query, начать close, отклонить новые jobs. Native completion возвращает действительный ok/value после освобождения native holds; затем owner освобождает idle adapter и закрывается.

**Ожидаемое наблюдение:** Пока native call не завершён, active=1 и query обслуживается. beginClose не считает job завершённым. Один completion даёт один итог; stale token ничего не меняет; releaseIdle и close происходят только при active=0.

**Граница сравнения:** Протокол и порты. Один job и один owner. Hard worker crash требует отдельного failure completion либо явного unknown outcome от host; force-kill native thread и подтверждённая отмена не обещаны. В данном fixture call в итоге возвращает либо выдаёт перехваченный failure. Числовой value при ok=0 не считается успешным результатом.

## LMX

```lmx
# DRAFT. submit is nonblocking; the physical blocking call belongs to native L2.
BlockingClientMessage:
    int: value
    i64: token
    int: ok
    @: native
    @: selfAddress
    @: lifecycle
    @: events
    private: int: phase 0
    private: int: active 0
    private: i64: next 0
    private: i64: current 0
    submit:
        if: node\phase != 0 || node\active = 1
            events\rejected(1)
            return
        if: node\next = 9223372036854775807
            events\rejected(2)
            return
        node\next += 1
        node\current := node\next
        node\active := 1
        private: int: admitted native\submit(node\current; value; selfAddress)
        if: admitted != 1
            node\active := 0
            events\rejected(3)
    completed:
        if: node\active = 0 || token != node\current
            return
        node\active := 0
        events\finished(token; ok; value)
        if: node\phase = 1
            finishClose()
    beginClose:
        if: node\phase != 0
            return
        node\phase := 1
        if: node\active = 0
            finishClose()
    finishClose:
        if: node\phase != 1 || node\active != 0
            return
        native\releaseIdle()
        node\phase := 2
        events\closed()
        lifecycle\requestOwnerClose()
    query:
        events\status(node\phase; node\active)
```

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. native.submit(token,value,selfAddress):int — узкая L2/host граница: 1 означает admission, 0 отказ без запуска. Она копирует вход, удерживает ресурсы и немедленно возвращается; blocking I/O, C API locks и OS waits исполняются только вне Message owner в выбранном native executor/process. completed(token,ok,value) публикуется после возврата native call и освобождения его holds, не синхронным callback в submit. releaseIdle допустим лишь после последнего completion. c.* и физические synchronization primitives остаются L2. Успешная admission не является successful job result.

[Отдельный листинг](examples/lmx/112_external_blocking_adapter.lm3)

## Go

```go
type BlockingEvent struct { Kind, Value int }
type BlockingResult struct { Token int64; OK bool; Value int }
func RunBlocking(in <-chan BlockingEvent, call func(int) (int, error),
    emit func(string, int64, bool, int), releaseIdle func()) {
    done := make(chan BlockingResult, 1)
    var next int64
    active, closing := false, false
    finish := func() { releaseIdle(); emit("closed", 0, true, 0) }
    for {
        select {
        case e, open := <-in:
            if !open { in = nil; closing = true; if !active { finish(); return }; continue }
            switch e.Kind {
            case 0:
                if active || closing { emit("rejected", 0, false, 1); continue }
                if next == 9223372036854775807 { emit("rejected", 0, false, 2); continue }
                next++; active = true
                go func(token int64, value int) {
                    result := BlockingResult{Token: token}
                    defer func() { if recover() != nil { result.OK = false }; done <- result }()
                    v, err := call(value)
                    result.OK, result.Value = err == nil, v
                }(next, e.Value)
            case 1:
                closing = true
                if !active { finish(); return }
            case 2:
                emit("status", next, active, map[bool]int{false:0,true:1}[closing])
            }
        case result := <-done:
            if !active || result.Token != next { continue }
            active = false
            emit("finished", result.Token, result.OK, result.Value)
            if closing { finish(); return }
        }
    }
}
```

Полный owner loop и goroutine wrapper. call — действительная supplied blocking function, releaseIdle освобождает ресурс, emit не блокирует. Panic даёт failed completion. У done channel один slot для единственного принятого job. Компиляция и исполнение NOT_RUN.

[Отдельный листинг](examples/go/112_external_blocking_adapter.go)

## Erlang

```erlang
blocking_client(Call, ReleaseIdle, Observer) ->
    blocking_loop(Call, ReleaseIdle, Observer, 0, false, false).
blocking_loop(Call, ReleaseIdle, Observer, Token, Active, Closing) ->
    receive
        {submit, _} when Active; Closing ->
            Observer ! {rejected, 1},
            blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing);
        {submit, _} when Token =:= 9223372036854775807 ->
            Observer ! {rejected, 2},
            blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing);
        {submit, Value} ->
            Next = Token+1, Parent = self(),
            spawn(fun() ->
                Result = try Call(Value) of V -> {true,V}
                         catch _:_ -> {false,0} end,
                Parent ! {completed, Next, Result}
            end),
            blocking_loop(Call,ReleaseIdle,Observer,Next,true,Closing);
        {completed, Token, {OK, Value}} when Active ->
            Observer ! {finished, Token, OK, Value},
            case Closing of
                true -> ReleaseIdle(), Observer ! closed, ok;
                false -> blocking_loop(Call,ReleaseIdle,Observer,Token,false,false)
            end;
        begin_close when Active ->
            blocking_loop(Call,ReleaseIdle,Observer,Token,true,true);
        begin_close ->
            ReleaseIdle(), Observer ! closed, ok;
        query ->
            Observer ! {status, Closing, Active},
            blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing);
        _ -> blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing)
    end.
```

Полный process loop и worker invocation. Call обязан использовать внешний port или корректно dirty-scheduled NIF. Обычные exceptions превращаются в failure; неконтролируемая гибель процесса/VM требует отдельного host failure signal.

[Отдельный листинг](examples/erlang/112_external_blocking_adapter.erl)

## Разбор LMX

Исполняемые экземпляры создаются штатным R0/Message host profile. Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному deadline или поколению ресурса, не реализуют второй scheduler. events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. native.submit(token,value,selfAddress):int — узкая L2/host граница: 1 означает admission, 0 отказ без запуска. Она копирует вход, удерживает ресурсы и немедленно возвращается; blocking I/O, C API locks и OS waits исполняются только вне Message owner в выбранном native executor/process. completed(token,ok,value) публикуется после возврата native call и освобождения его holds, не синхронным callback в submit. releaseIdle допустим лишь после последнего completion. c.* и физические synchronization primitives остаются L2. Успешная admission не является successful job result.

## Сопоставление

Go запускает ровно одну goroutine с действительным supplied blocking function и bounded completion channel; Erlang запускает отдельный процесс, а native Call обязан быть port либо корректно dirty-scheduled NIF. Сам spawn не делает произвольный блокирующий NIF безопасным. LMX-автомат не маскирует отсутствие физического adapter.

### Асинхронная граница

Ошибки маршрута, deadline, stale generation и blanket stash относятся к прикладному протоколу. Они не означают deadlock механизма Message. Все handlers завершают текущий turn; результаты приходят штатными сообщениями, без LMX synchronized или ожидания потока.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 877 | 49 |
| Go | 1031 | 37 |
| Erlang | 1109 | 33 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A physically blocking call runs in a native L2 worker; LMX receives an ordinary Message completion.

**Scenario.** Admit one native job, serve query, begin close and reject new jobs. A native completion reports real ok/value after releasing native holds; then the owner releases the idle adapter and closes.

**Expected observation.** While the native call runs, active is one and query remains serviceable. beginClose does not mark the job complete. One completion yields one result; a stale token changes nothing. releaseIdle/close occur only when inactive.

**LMX.** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. native.submit(token,value,selfAddress):int is a narrow L2/host boundary: one admits and zero rejects without launching. It copies input, retains resources and returns immediately. Blocking I/O, C API locks and OS waits run outside the Message owner in the selected native executor/process. completed is posted after the native call returns and its holds are released, never as a reentrant submit callback. releaseIdle runs only after the last completion. c.* and physical synchronization remain L2. Admission is not job success.

**Comparison.** Go starts one goroutine with the supplied blocking function and a bounded completion channel. Erlang starts a process, but native Call must use a port or correctly dirty-scheduled NIF; spawn alone does not make an arbitrary blocking NIF safe. The LMX state machine does not hide its missing physical adapter.

**Scope and limitations.** One job and owner. Hard worker crash requires a separate failure completion or explicit unknown outcome; force-killing a native thread and confirmed cancellation are not promised. This fixture's call eventually returns or raises a captured failure. A value with ok=false is inactive.

Routing, deadline, stale-generation and blanket-stash mistakes are application protocol errors, not Message scheduling deadlocks. Handlers finish their turns and receive ordinary later messages; no LMX synchronized or thread wait is introduced.

### Dependencies and execution boundaries

- **LMX:** Executable instances use the ordinary R0/Message host profile. Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. post already binds addressed exchange and correlation. token/epoch are application deadline or resource-generation data, not a second scheduler. events is a nonblocking owner-local observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN. native.submit(token,value,selfAddress):int is a narrow L2/host boundary: one admits and zero rejects without launching. It copies input, retains resources and returns immediately. Blocking I/O, C API locks and OS waits run outside the Message owner in the selected native executor/process. completed is posted after the native call returns and its holds are released, never as a reentrant submit callback. releaseIdle runs only after the last completion. c.* and physical synchronization remain L2. Admission is not job success.
- **Go:** Complete owner loop and goroutine wrapper; call is the real supplied blocking function, releaseIdle is the resource finalizer, emit is a nonblocking observer. A panic becomes a failed completion. The buffered done channel has one slot for the single admitted job. Compiler/runtime NOT_RUN.
- **Erlang:** Complete ordinary process loop and worker invocation; Call must be an external port-backed operation or an appropriately scheduled dirty NIF. Normal exceptions become failure. An uncatchable process/VM termination is outside the bounded fixture and requires host failure signaling.

## Источники / Sources

- [Erlang native functions: dirty schedulers](https://www.erlang.org/doc/apps/erts/erl_nif.html) — Длительная native работа требует соответствующей physical execution boundary.
- [Erlang ports](https://www.erlang.org/doc/system/c_port.html) — Внешний процесс и framed native completion.
- [Go pipelines and cancellation](https://go.dev/blog/pipelines) — Завершение уже принятой работы и жизненный цикл producer/consumer.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
