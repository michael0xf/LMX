# 064. Future / Promise

Однократно завершённый результат доступен всем ожидающим и поздним читателям.

## Общий сценарий

Два клиента запрашивают результат до resolve(7), третий — после. Повтор resolve(9) отклоняется.

**Ожидаемое наблюдение:** Три клиента получают 7; resolve принимает только первое значение.

**Граница сравнения:** Протокол и порты. Ошибка, cancellation, срок жизни, удаление потерянных клиентов и распределённая доставка — отдельные расширения. «Отклоняется» в сценарии означает отсутствие изменения, без отдельного error reply.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
FutureMessage:
    int: requestId
    int: next
    int: ready 0
    int: value 0
    @: waiters
    @: replies
    get:
        if: node\ready = 1
            replies\send(requestId; node\value)
            return
        waiters\push(requestId)
    resolve:
        if: node\ready = 1
            return
        node\value := next
        node\ready := 1
        while: waiters\size() > 0
            replies\send(waiters\pop(); node\value)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. waiters — supplied owner-local FIFO ID; replies.send(id,value):void доставляет ответ живому клиентскому Message. Это явно выбранный future protocol, не встроенный тип Future LMX; callback не ссылается на завершённый кадр. Повтор resolve игнорируется без изменения результата во всех трёх версиях.

[Отдельный листинг](examples/lmx/064_future_promise.lm3)

## Go

```go
import "sync"
type Future struct { once sync.Once; done chan struct{}; value int }
func NewFuture() *Future { return &Future{done: make(chan struct{})} }
func (f *Future) Resolve(value int) {
    f.once.Do(func() { f.value = value; close(f.done) })
}
func (f *Future) Get() int { <-f.done; return f.value }
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. waiters — supplied owner-local FIFO ID; replies.send(id,value):void доставляет ответ живому клиентскому Message. Это явно выбранный future protocol, не встроенный тип Future LMX; callback не ссылается на завершённый кадр. Повтор resolve игнорируется без изменения результата во всех трёх версиях.

[Отдельный листинг](examples/go/064_future_promise.go)

## Erlang

```erlang
future(pending, Waiters) ->
    receive
        {get, From, Ref} -> future(pending, [{From,Ref}|Waiters]);
        {resolve, Value} ->
            [P ! {R,Value} || {P,R} <- Waiters], future({ready,Value}, [])
    end;
future({ready,Value}, []) ->
    receive
        {get, From, Ref} -> From ! {Ref,Value}, future({ready,Value}, []);
        {resolve, _} -> future({ready,Value}, [])
    end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. waiters — supplied owner-local FIFO ID; replies.send(id,value):void доставляет ответ живому клиентскому Message. Это явно выбранный future protocol, не встроенный тип Future LMX; callback не ссылается на завершённый кадр. Повтор resolve игнорируется без изменения результата во всех трёх версиях.

[Отдельный листинг](examples/erlang/064_future_promise.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. waiters — supplied owner-local FIFO ID; replies.send(id,value):void доставляет ответ живому клиентскому Message. Это явно выбранный future protocol, не встроенный тип Future LMX; callback не ссылается на завершённый кадр. Повтор resolve игнорируется без изменения результата во всех трёх версиях.

## Сопоставление

LMX/Erlang сохраняют ожидающих у владельца. Go close(done) одновременно публикует значение и разблокирует читателей по контракту каналов; это не polling.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 273 | 19 |
| Go | 256 | 7 |
| Erlang | 292 | 11 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A once-completed result is available to current waiters and later readers.

**Scenario.** Two clients request the result before resolve(7), and a third after it. A second resolve(9) is rejected.

**Expected observation.** All three clients receive 7; resolve accepts only the first value.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions.

**Comparison.** LMX/Erlang retain waiters at the owner. Go close(done) publishes the value and releases readers under channel synchronization; it is not polling.

**Scope and limitations.** Error, cancellation, lifetime, dead-client removal and remote delivery are extensions. Rejected in the scenario means no state change, without a separate error reply.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions.

## Источники / Sources

- [Go — Effective Go concurrency](https://go.dev/doc/effective_go) — Однократно завершённый результат доступен всем ожидающим и поздним читателям.
- [Erlang — Concurrent Programming](https://www.erlang.org/doc/system/conc_prog.html) — Однократно завершённый результат доступен всем ожидающим и поздним читателям.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
