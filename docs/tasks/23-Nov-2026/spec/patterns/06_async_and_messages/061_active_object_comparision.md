# 061. Active Object

Вызов ставит операцию в очередь владельца и отделён от её исполнения.

## Общий сценарий

Клиент отправляет compute(6); отдельный исполнитель вычисляет удвоение и доставляет 12.

**Ожидаемое наблюдение:** Submit не исполняет compute на полосе клиента; получен один результат 12.

**Граница сравнения:** Протокол и порты. Отмена, timeout и прекращение service требуют lifecycle policy. Завершение scope клиента не должно оставлять callback на умерший стек; destination здесь долгоживущий Message.

## LMX

```lmx
ClientMessage:
    @: service
    @: sink
    start:
        post:
            ask:
                service\compute(value := 6)
            answer:
                sink\accept

ServiceMessage:
    int: value
    return: int
    compute:
        return: value * 2
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. sink.accept(int):void — supplied destination, заранее привязанный в answer. service — отдельно созданный Message. post дерево выведено из нормативного ask/answer контракта; буквального parser fixture в исходной документации нет. В Go Submit может ждать admission в unbuffered queue, но не завершения compute.

[Отдельный листинг](examples/lmx/061_active_object.lm3)

## Go

```go
type Request struct { value int; reply chan int }
type Active chan Request
func NewActive() Active {
    a := make(Active)
    go func() { for r := range a { r.reply <- r.value * 2 } }()
    return a
}
func (a Active) Submit(value int) <-chan int {
    reply := make(chan int, 1)
    a <- Request{value, reply}; return reply
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. sink.accept(int):void — supplied destination, заранее привязанный в answer. service — отдельно созданный Message. post дерево выведено из нормативного ask/answer контракта; буквального parser fixture в исходной документации нет. В Go Submit может ждать admission в unbuffered queue, но не завершения compute.

[Отдельный листинг](examples/go/061_active_object.go)

## Erlang

```erlang
active() ->
    receive
        {compute, Value, From, Ref} ->
            From ! {Ref, Value * 2}, active();
        stop -> ok
    end.
submit(Pid, Value) ->
    Ref = make_ref(), Pid ! {compute, Value, self(), Ref}, Ref.
result(Ref) -> receive {Ref, Value} -> Value end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. sink.accept(int):void — supplied destination, заранее привязанный в answer. service — отдельно созданный Message. post дерево выведено из нормативного ask/answer контракта; буквального parser fixture в исходной документации нет. В Go Submit может ждать admission в unbuffered queue, но не завершения compute.

[Отдельный листинг](examples/erlang/061_active_object.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. sink.accept(int):void — supplied destination, заранее привязанный в answer. service — отдельно созданный Message. post дерево выведено из нормативного ask/answer контракта; буквального parser fixture в исходной документации нет. В Go Submit может ждать admission в unbuffered queue, но не завершения compute.

## Сопоставление

В LMX транспорт обычного вызова уже описан через post. Go выделяет request/reply object; Erlang использует envelope с Ref. Методы результата не выбираются заново по списку слушателей.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 143 | 14 |
| Go | 247 | 11 |
| Erlang | 194 | 9 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Invocation queues an operation for its owner and is separated from execution.

**Scenario.** The client submits compute(6); a separate executor doubles it and delivers 12.

**Expected observation.** Submit does not execute compute on the client lane; one result 12 is delivered.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. sink.accept(int):void is a supplied destination bound before sending. service is a separately created Message. The post tree follows the normative ask/answer contract; the source documentation contains no literal parser fixture. Go Submit may wait for unbuffered queue admission, but not compute completion.

**Comparison.** LMX already specifies transport of ordinary calls through post. Go uses a request/reply object; Erlang uses an envelope with Ref. Result destinations are not rediscovered through listener enumeration.

**Scope and limitations.** Cancellation, timeouts and service shutdown require lifecycle policy. Client scope exit must not leave a callback into a dead stack; the destination here is a long-lived Message.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. sink.accept(int):void is a supplied destination bound before sending. service is a separately created Message. The post tree follows the normative ask/answer contract; the source documentation contains no literal parser fixture. Go Submit may wait for unbuffered queue admission, but not compute completion.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. sink.accept(int):void is a supplied destination bound before sending. service is a separately created Message. The post tree follows the normative ask/answer contract; the source documentation contains no literal parser fixture. Go Submit may wait for unbuffered queue admission, but not compute completion.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. sink.accept(int):void is a supplied destination bound before sending. service is a separately created Message. The post tree follows the normative ask/answer contract; the source documentation contains no literal parser fixture. Go Submit may wait for unbuffered queue admission, but not compute completion.

## Источники / Sources

- [Douglas Schmidt — Active Object and concurrency patterns](https://www.dre.vanderbilt.edu/~schmidt/patterns-ace.html) — Вызов ставит операцию в очередь владельца и отделён от её исполнения.
- [Erlang — gen_server behaviour](https://www.erlang.org/doc/system/gen_server_concepts.html) — Вызов ставит операцию в очередь владельца и отделён от её исполнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
