# 064. Future / Promise

Однократно завершённый результат доступен всем ожидающим и поздним читателям.

## Общий сценарий

Два клиента запрашивают результат до resolve(7), третий — после. Повтор resolve(9) отклоняется.

**Ожидаемое наблюдение:** Три клиента получают 7; resolve принимает только первое значение.

**Граница сравнения:** Протокол и порты. Ошибка, cancellation, срок жизни, удаление потерянных клиентов и распределённая доставка — отдельные расширения. «Отклоняется» в сценарии означает отсутствие изменения, без отдельного error reply.

## LMX

```lmx
FutureMessage:
    int: requestId
    int: next
    int: ready 0
    int: value 0
    @: waiters
    @: replies
    reply:
        replies\send(requestId; node\value)
    get:
        if: node\ready = 1
            reply()
            return
        waiters\push(requestId)
    resolve:
        if: node\ready = 1
            return
        node\value := next
        node\ready := 1
        while: waiters\size() > 0
            reply(waiters\pop())
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. waiters — supplied owner-local FIFO ID; replies.send(id,value):void доставляет ответ живому клиентскому Message. Это явно выбранный future protocol, не встроенный тип Future LMX; callback не ссылается на завершённый кадр. Повтор resolve игнорируется без изменения результата во всех трёх версиях. Общий reply полностью включён в листинг и подсчёт. reply() получает requestId по обычному автозаполнению DATA, а reply(waiters\pop()) получает очередной ID позиционно; оба читают текущее node\value.

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

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. waiters — supplied owner-local FIFO ID; replies.send(id,value):void доставляет ответ живому клиентскому Message. Это явно выбранный future protocol, не встроенный тип Future LMX; callback не ссылается на завершённый кадр. Повтор resolve игнорируется без изменения результата во всех трёх версиях. Общий reply полностью включён в листинг и подсчёт. reply() получает requestId по обычному автозаполнению DATA, а reply(waiters\pop()) получает очередной ID позиционно; оба читают текущее node\value.

## Сопоставление

LMX/Erlang сохраняют ожидающих у владельца. Go close(done) одновременно публикует значение и разблокирует читателей по контракту каналов; это не polling.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 268 | 21 |
| Go | <span style="color:#176233"><u>256</u></span> | 7 |
| Erlang | 292 | 11 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A once-completed result is available to current waiters and later readers.

**Scenario.** Two clients request the result before resolve(7), and a third after it. A second resolve(9) is rejected.

**Expected observation.** All three clients receive 7; resolve accepts only the first value.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions. The shared reply body is included and counted. reply() receives requestId through ordinary DATA autofill, while reply(waiters\pop()) receives the next ID positionally; both read the current node\value.

**Comparison.** LMX/Erlang retain waiters at the owner. Go close(done) publishes the value and releases readers under channel synchronization; it is not polling.

**Scope and limitations.** Error, cancellation, lifetime, dead-client removal and remote delivery are extensions. Rejected in the scenario means no state change, without a separate error reply.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions. The shared reply body is included and counted. reply() receives requestId through ordinary DATA autofill, while reply(waiters\pop()) receives the next ID positionally; both read the current node\value.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. waiters is a supplied owner-local FIFO of IDs; replies.send(id,value):void delivers to a live client Message. This is an explicit future protocol, not a built-in LMX Future type; callbacks do not refer to ended frames. Repeated resolve is ignored without changing the result in all versions.

## Источники / Sources

- [Go — Effective Go concurrency](https://go.dev/doc/effective_go) — Однократно завершённый результат доступен всем ожидающим и поздним читателям.
- [Erlang — Concurrent Programming](https://www.erlang.org/doc/system/conc_prog.html) — Однократно завершённый результат доступен всем ожидающим и поздним читателям.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
