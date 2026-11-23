# 067. Guarded Suspension

Запрос получает результат только после выполнения предиката готовности.

## Общий сценарий

Два клиента ждут значение; publish(7) делает его готовым и завершает оба ожидания.

**Ожидаемое наблюдение:** До publish ответов нет; после — оба клиента получают 7. LMX owner продолжает обслуживать publish, пока запросы ждут.

**Граница сравнения:** Протокол и порты. Отмена ожидания, исчезновение клиента и повторные publish требуют политики. Без неё список ожидающих может расти; это не автоматическое продление жизни исходного stack frame.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
ReadyMessage:
    int: requestId
    int: next
    int: ready 0
    int: value 0
    @: waiters
    @: replies
    reply:
        replies\send(requestId; node\value)
    awaitValue:
        if: node\ready = 1
            reply()
            return
        waiters\push(requestId)
    publish:
        node\value := next
        node\ready := 1
        while: waiters\size() > 0
            reply(waiters\pop())
```

Общий reply целиком показан и учтён: готовый запрос использует обычное автозаполнение requestId, а publish передаёт очередной ID из FIFO позиционно. Это не добавляет ожидания и не меняет правило повторной публикации.

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. waiters.push(int)/pop():int/size():int — owner-local FIFO логических ID запросов. replies.send(id:int,value:int):void — supplied reliable delivery конкретному живому ожидающему Message. ID — прикладной идентификатор этого явно выбранного deferred protocol, не замена корреляции штатного post. Нельзя блокировать owner на собственной очереди.

[Отдельный листинг](examples/lmx/067_guarded_suspension.lm3)

## Java

```java
final class Ready {
    private boolean ready;
    private int value;
    synchronized int awaitValue() throws InterruptedException {
        while (!ready) wait();
        return value;
    }
    synchronized void publish(int next) {
        value = next; ready = true; notifyAll();
    }
}
```

Фрагмент для Java 21; запускающий harness не включён. waiters.push(int)/pop():int/size():int — owner-local FIFO логических ID запросов. replies.send(id:int,value:int):void — supplied reliable delivery конкретному живому ожидающему Message. ID — прикладной идентификатор этого явно выбранного deferred protocol, не замена корреляции штатного post. Нельзя блокировать owner на собственной очереди.

[Отдельный листинг](examples/java/067_guarded_suspension.java)

## Rust

```rust
use std::sync::{Condvar, Mutex};
struct Ready { value: Mutex<Option<i32>>, changed: Condvar }
impl Ready {
    fn new() -> Self { Self { value: Mutex::new(None), changed: Condvar::new() } }
    fn wait(&self) -> i32 {
        let guard = self.value.lock().unwrap();
        let guard = self.changed.wait_while(guard, |v| v.is_none()).unwrap();
        guard.unwrap()
    }
    fn publish(&self, next: i32) {
        *self.value.lock().unwrap() = Some(next);
        self.changed.notify_all();
    }
}
```

Фрагмент Rust использует std; запускающий harness не включён. waiters.push(int)/pop():int/size():int — owner-local FIFO логических ID запросов. replies.send(id:int,value:int):void — supplied reliable delivery конкретному живому ожидающему Message. ID — прикладной идентификатор этого явно выбранного deferred protocol, не замена корреляции штатного post. Нельзя блокировать owner на собственной очереди.

[Отдельный листинг](examples/rust/067_guarded_suspension.rs)

## Разбор LMX

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. waiters.push(int)/pop():int/size():int — owner-local FIFO логических ID запросов. replies.send(id:int,value:int):void — supplied reliable delivery конкретному живому ожидающему Message. ID — прикладной идентификатор этого явно выбранного deferred protocol, не замена корреляции штатного post. Нельзя блокировать owner на собственной очереди.

## Сопоставление

Java/Rust освобождают lock во время ожидания и повторно проверяют predicate. LMX сохраняет запрос и завершает turn, позволяя publish дойти до владельца; это событийная форма guarded wait.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 253 | 19 |
| Java | 208 | 11 |
| Rust | 386 | 14 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

<!-- shared-method-reuse-review-2026-11-22 -->

## Предыдущий полный вариант LMX — вне основного подсчёта

Основной вариант повторно использует обычный метод, целиком включённый в тот же листинг. Предыдущая реализация сохранена без изменения.

```lmx
ReadyMessage:
    int: requestId
    int: next
    int: ready 0
    int: value 0
    @: waiters
    @: replies
    awaitValue:
        if: node\ready = 1
            replies\send(requestId; node\value)
            return
        waiters\push(requestId)
    publish:
        node\value := next
        node\ready := 1
        while: waiters\size() > 0
            replies\send(waiters\pop(); node\value)
```

**Основание выбора / Selection:** Share the complete reply method between an already-ready request and the publish drain. Normal DATA autofill carries requestId for the first case; each popped ID is positional for the second. publish can still run while earlier clients wait, and later publication is not changed into Future single assignment.

**Completeness:** The complete counted reply body is shared: an already-ready request uses ordinary requestId autofill, while publish supplies each FIFO ID positionally. This adds no wait and does not change republishing policy. All shown fields, effects, Message ownership and the documented HTTP/port boundary remain. This is source review; no LMX runtime execution is claimed.

## English explanation

A request receives its result only after a readiness predicate becomes true.

**Scenario.** Two clients wait for a value; publish(7) makes it ready and completes both waits.

**Expected observation.** No replies before publish; afterwards both clients receive 7. The LMX owner remains able to process publish while requests wait.

**LMX.** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. waiters.push(int)/pop():int/size():int is an owner-local FIFO of logical request IDs. replies.send(id:int,value:int):void is supplied reliable delivery to a specific live waiting Message. IDs belong to this explicitly selected deferred protocol, not a replacement for built-in post correlation. The owner must not block on its own queue.

**Comparison.** Java/Rust release the lock while waiting and recheck the predicate. LMX stores the request and ends its turn so publish can reach the owner: an event-driven guarded wait.

**Scope and limitations.** Cancellation, client death and repeated publish need policy. Without it waiters can accumulate; retaining a request does not automatically extend a source stack frame lifetime.

### Dependencies and execution boundaries

- **LMX:** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. waiters.push(int)/pop():int/size():int is an owner-local FIFO of logical request IDs. replies.send(id:int,value:int):void is supplied reliable delivery to a specific live waiting Message. IDs belong to this explicitly selected deferred protocol, not a replacement for built-in post correlation. The owner must not block on its own queue.
- **Java:** Java 21 fragment; the launching harness is not included. waiters.push(int)/pop():int/size():int is an owner-local FIFO of logical request IDs. replies.send(id:int,value:int):void is supplied reliable delivery to a specific live waiting Message. IDs belong to this explicitly selected deferred protocol, not a replacement for built-in post correlation. The owner must not block on its own queue.
- **Rust:** Rust fragment using std; the launching harness is not included. waiters.push(int)/pop():int/size():int is an owner-local FIFO of logical request IDs. replies.send(id:int,value:int):void is supplied reliable delivery to a specific live waiting Message. IDs belong to this explicitly selected deferred protocol, not a replacement for built-in post correlation. The owner must not block on its own queue.

## Источники / Sources

- [Java Language Specification — Wait Sets and Notification](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html) — Запрос получает результат только после выполнения предиката готовности.
- [Rust — Condvar](https://doc.rust-lang.org/std/sync/struct.Condvar.html) — Запрос получает результат только после выполнения предиката готовности.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
