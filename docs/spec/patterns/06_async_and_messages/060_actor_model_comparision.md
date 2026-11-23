# 060. Actor Model

Владелец изолированного состояния принимает целые операции через сообщения.

## Общий сценарий

Два клиента отправляют add(2) и add(5) в один счётчик из состояния 0.

**Ожидаемое наблюдение:** После подтверждённого выполнения обеих операций read возвращает 7 при любом порядке их admission.

**Граница сравнения:** Протокол и порты. Нет общего sender-clock порядка, exactly-once delivery или автоматического rollback. Повтор add после потерянного ответа может удвоить эффект.

## LMX

```lmx
CounterMessage:
    int: delta
    int: total 0
    return: int
    add:
        node\total += delta
        return: read()
    read:
        return: node\total
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. LMX создаёт один CounterMessage; add/read — обычные методы в адресованных post requests. Общий sender ожидает два семантических результата перед read. В Go каждая команда содержит отдельный reply channel; в Erlang From/Ref коррелируют ответы. После обновления add вызывает уже показанный read: это обычный локальный вызов того же владельца, без нового письма.

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

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. LMX создаёт один CounterMessage; add/read — обычные методы в адресованных post requests. Общий sender ожидает два семантических результата перед read. В Go каждая команда содержит отдельный reply channel; в Erlang From/Ref коррелируют ответы. После обновления add вызывает уже показанный read: это обычный локальный вызов того же владельца, без нового письма.

## Сопоставление

Message непосредственно соответствует выбранной actor-модели: один владелец mutable graph и последовательное исполнение. Структурный callable и транспорт не создают общего mutable heap между владельцами.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 100 | 9 | 100 |
| Go | 141 | 8 | — |
| Erlang | 144 | 7 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

An isolated state owner receives complete operations through messages.

**Scenario.** Two clients send add(2) and add(5) to one counter initially at zero.

**Expected observation.** After both operations are confirmed complete, read returns 7 in either admission order.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses. After the update, add reuses the included read method: an ordinary local call on the same owner, with no new letter.

**Comparison.** Message directly realizes this actor model: one mutable-graph owner and serial execution. Structural callables and transport do not create a shared mutable heap across owners.

**Scope and limitations.** There is no global sender-clock ordering, exactly-once delivery or automatic rollback. Retrying add after a lost reply may duplicate the effect.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses. After the update, add reuses the included read method: an ordinary local call on the same owner, with no new letter.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. LMX creates one CounterMessage; add/read are ordinary methods in addressed post requests. The harness waits for both semantic replies before read. Go commands use separate reply channels; Erlang From/Ref correlate responses.

## Источники / Sources

- [Erlang — Concurrent Programming](https://www.erlang.org/doc/system/conc_prog.html) — Владелец изолированного состояния принимает целые операции через сообщения.
- [Go — Effective Go concurrency](https://go.dev/doc/effective_go) — Владелец изолированного состояния принимает целые операции через сообщения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
