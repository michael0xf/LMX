# 060. Actor Model

Владелец изолированного состояния принимает целые операции через сообщения.

## Общий сценарий

Два клиента отправляют add(2) и add(5) в один счётчик из состояния 0.

**Ожидаемое наблюдение:** После подтверждённого выполнения обеих операций read возвращает 7 при любом порядке их admission.

**Граница сравнения:** Протокол и порты. Нет общего sender-clock порядка, exactly-once delivery или автоматического rollback. Повтор add после потерянного ответа может удвоить эффект.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
CounterMessage:
    int: delta
    int: total 0
    return: int
    add:
        node\total += delta
        return: node\total
    read:
        return: node\total
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. LMX создаёт один CounterMessage; add/read — обычные методы в адресованных post requests. Общий sender ожидает два семантических результата перед read. В Go каждая команда содержит отдельный reply channel; в Erlang From/Ref коррелируют ответы.

[Отдельный листинг](examples/lmx/060_actor_model.lm3)

## Go

```go
type Command struct { delta int; read bool; reply chan int }
func Counter(in <-chan Command) {
    total := 0
    for c := range in {
        if !c.read { total += c.delta }
        c.reply <- total
    }
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. LMX создаёт один CounterMessage; add/read — обычные методы в адресованных post requests. Общий sender ожидает два семантических результата перед read. В Go каждая команда содержит отдельный reply channel; в Erlang From/Ref коррелируют ответы.

[Отдельный листинг](examples/go/060_actor_model.go)

## Erlang

```erlang
counter(Total) ->
    receive
        {add, Delta, From, Ref} ->
            Next = Total + Delta, From ! {Ref, Next}, counter(Next);
        {read, From, Ref} ->
            From ! {Ref, Total}, counter(Total)
    end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. LMX создаёт один CounterMessage; add/read — обычные методы в адресованных post requests. Общий sender ожидает два семантических результата перед read. В Go каждая команда содержит отдельный reply channel; в Erlang From/Ref коррелируют ответы.

[Отдельный листинг](examples/erlang/060_actor_model.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. LMX создаёт один CounterMessage; add/read — обычные методы в адресованных post requests. Общий sender ожидает два семантических результата перед read. В Go каждая команда содержит отдельный reply channel; в Erlang From/Ref коррелируют ответы.

## Сопоставление

Message непосредственно соответствует выбранной actor-модели: один владелец mutable graph и последовательное исполнение. Структурный callable и транспорт не создают общего mutable heap между владельцами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 104 | 9 |
| Go | 141 | 8 |
| Erlang | 144 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

An isolated state owner receives complete operations through messages.

**Scenario.** Two clients send add(2) and add(5) to one counter initially at zero.

**Expected observation.** After both operations are confirmed complete, read returns 7 in either admission order.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses.

**Comparison.** Message directly realizes this actor model: one mutable-graph owner and serial execution. Structural callables and transport do not create a shared mutable heap across owners.

**Scope and limitations.** There is no global sender-clock ordering, exactly-once delivery or automatic rollback. Retrying add after a lost reply may duplicate the effect.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses.

## Источники / Sources

- [Erlang — Concurrent Programming](https://www.erlang.org/doc/system/conc_prog.html) — Владелец изолированного состояния принимает целые операции через сообщения.
- [Go — Effective Go concurrency](https://go.dev/doc/effective_go) — Владелец изолированного состояния принимает целые операции через сообщения.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
