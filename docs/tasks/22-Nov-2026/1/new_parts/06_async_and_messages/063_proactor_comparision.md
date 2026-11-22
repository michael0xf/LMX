# 063. Proactor

Операция чтения запускается заранее; обработчик получает уже завершённый результат.

## Общий сценарий

SubmitRead(fd=3,token=7) затем completion(7,2). Handler не вызывает дополнительное чтение.

**Ожидаемое наблюдение:** Ровно один submit и sink(2); completion с чужим token игнорируется.

**Граница сравнения:** Протокол и порты. Провайдер должен действительно поддерживать завершение операции: имитация чтения в handler была бы Reactor. Cancellation/completion races и lifetime буфера остаются обязанностями I/O-адаптера.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
ProactorMessage:
    int: token
    int: bytes
    @: io
    @: completionTarget
    @: sink
    begin:
        io\submitRead(3; 7; completionTarget)
    completed:
        if: token = 7
            sink\write(bytes)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. io.submitRead(fd:int,token:int,target:MessageAddress):void — supplied completion I/O provider, выполняющий чтение до отправки completed(token,bytes). Он удерживает буфер до завершения, а completionTarget — живой адрес именно ProactorMessage. sink.write(int):void получает byte count, −1 означает выбранную ошибку. Erlang Ref — тот же корреляционный token.

[Отдельный листинг](examples/lmx/063_proactor.lm3)

## Go

```go
type Completion struct { token, bytes int }
func Proactor(submit func(int, int, chan<- Completion), write func(int)) {
    completed := make(chan Completion, 1)
    submit(3, 7, completed)
    for c := range completed {
        if c.token == 7 { write(c.bytes); return }
    }
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. io.submitRead(fd:int,token:int,target:MessageAddress):void — supplied completion I/O provider, выполняющий чтение до отправки completed(token,bytes). Он удерживает буфер до завершения, а completionTarget — живой адрес именно ProactorMessage. sink.write(int):void получает byte count, −1 означает выбранную ошибку. Erlang Ref — тот же корреляционный token.

[Отдельный листинг](examples/go/063_proactor.go)

## Erlang

```erlang
proactor(Submit, Write) ->
    Ref = make_ref(), Submit(3, Ref, self()),
    receive {completed, Ref, Bytes} -> Write(Bytes) end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. io.submitRead(fd:int,token:int,target:MessageAddress):void — supplied completion I/O provider, выполняющий чтение до отправки completed(token,bytes). Он удерживает буфер до завершения, а completionTarget — живой адрес именно ProactorMessage. sink.write(int):void получает byte count, −1 означает выбранную ошибку. Erlang Ref — тот же корреляционный token.

[Отдельный листинг](examples/erlang/063_proactor.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. io.submitRead(fd:int,token:int,target:MessageAddress):void — supplied completion I/O provider, выполняющий чтение до отправки completed(token,bytes). Он удерживает буфер до завершения, а completionTarget — живой адрес именно ProactorMessage. sink.write(int):void получает byte count, −1 означает выбранную ошибку. Erlang Ref — тот же корреляционный token.

## Сопоставление

От Reactor отличается момент выполнения I/O и содержимое уведомления. Сообщение LMX само не превращает readiness provider в completion provider.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 140 | 11 |
| Go | 214 | 8 |
| Erlang | 106 | 3 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Reading is initiated in advance; the handler receives an already completed result.

**Scenario.** SubmitRead(fd=3,token=7), then completion(7,2). The handler does not perform another read.

**Expected observation.** Exactly one submit and sink(2); a completion with a different token is ignored.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. io.submitRead(fd:int,token:int,target:MessageAddress):void is a supplied completion I/O provider that performs the read before sending completed(token,bytes). It retains the buffer until completion; completionTarget is the live ProactorMessage address. sink.write(int):void receives byte count, with -1 denoting the fixture error. Erlang Ref is the correlation token.

**Comparison.** It differs from Reactor in when I/O happens and what the notification contains. An LMX Message does not itself turn a readiness provider into a completion provider.

**Scope and limitations.** The provider must genuinely complete the operation: reading inside the handler would be Reactor. Cancellation/completion races and buffer lifetime remain I/O-adapter obligations.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. io.submitRead(fd:int,token:int,target:MessageAddress):void is a supplied completion I/O provider that performs the read before sending completed(token,bytes). It retains the buffer until completion; completionTarget is the live ProactorMessage address. sink.write(int):void receives byte count, with -1 denoting the fixture error. Erlang Ref is the correlation token.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. io.submitRead(fd:int,token:int,target:MessageAddress):void is a supplied completion I/O provider that performs the read before sending completed(token,bytes). It retains the buffer until completion; completionTarget is the live ProactorMessage address. sink.write(int):void receives byte count, with -1 denoting the fixture error. Erlang Ref is the correlation token.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. io.submitRead(fd:int,token:int,target:MessageAddress):void is a supplied completion I/O provider that performs the read before sending completed(token,bytes). It retains the buffer until completion; completionTarget is the live ProactorMessage address. sink.write(int):void receives byte count, with -1 denoting the fixture error. Erlang Ref is the correlation token.

## Источники / Sources

- [Douglas Schmidt — Proactor and completion dispatch](https://www.dre.vanderbilt.edu/~schmidt/patterns-ace.html) — Операция чтения запускается заранее; обработчик получает уже завершённый результат.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
