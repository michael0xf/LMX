# 086. Idempotent Consumer / Transactional Inbox

Подавить повторное бизнес-действие по устойчивому идентификатору доставки.

## Общий сценарий

Дважды доставить subscriber=7,event=51,delta=5 при исходном balance=100. Первый commit проходит, но ACK теряется, поэтому broker повторяет доставку.

**Ожидаемое наблюдение:** После обеих доставок balance=105 и ровно одна inbox-запись (7,51). Обе успешные обработки могут ACK. При сбое транзакции ни метка, ни изменение не остаются, ACK не посылается.

**Граница сравнения:** Протокол и порты. Добавленный пункт 86. Инвариант ограничен одной транзакционной БД; внешний платёж не становится exactly-once от записи inbox. Retention ключей, повтор с тем же id и другим payload, poison messages и retries требуют явного контракта.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
InboxMessage:
    @: db
    @: broker
    int: subscriber
    int: eventId
    int: delta
    apply:
        if: db\tryInsert(subscriber; eventId)
            db\addBalance(delta)
    receiveEvent:
        db\atomic(body := apply)
        broker\ack(eventId)
```

InboxMessage — единственный владелец обработчика, но дедупликация хранится в БД. tryInsert(subscriber,event) использует unique key и возвращает false при уже committed записи; изменение баланса и вставка входят в один db.atomic. ack — явный broker-порт после commit. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

[Отдельный листинг](examples/lmx/086_idempotent_consumer_inbox.lm3)

## Java

```java
interface InboxDb {
    void atomic(Runnable body);
    boolean tryInsert(int subscriber,int eventId);
    void addBalance(int delta);
}
interface Broker { void ack(int eventId); }
final class Inbox {
    static void receive(InboxDb db,Broker broker,int subscriber,int eventId,int delta) {
        db.atomic(() -> {
            if (db.tryInsert(subscriber,eventId)) db.addBalance(delta);
        });
        broker.ack(eventId);
    }
}
```

Добавленный пункт 86. Инвариант ограничен одной транзакционной БД; внешний платёж не становится exactly-once от записи inbox. Retention ключей, повтор с тем же id и другим payload, poison messages и retries требуют явного контракта.

[Отдельный листинг](examples/java/086_idempotent_consumer_inbox.java)

## Go

```go
package patterns
type InboxDB interface {
    Atomic(func() error) error
    TryInsert(int,int) (bool,error)
    AddBalance(int) error
}
type Broker interface { Ack(int) error }
func Receive(db InboxDB,broker Broker,subscriber,eventID,delta int) error {
    err:=db.Atomic(func() error {
        inserted,err:=db.TryInsert(subscriber,eventID)
        if err!=nil { return err }
        if !inserted { return nil }
        return db.AddBalance(delta)
    })
    if err!=nil { return err }
    return broker.Ack(eventID)
}
```

Добавленный пункт 86. Инвариант ограничен одной транзакционной БД; внешний платёж не становится exactly-once от записи inbox. Retention ключей, повтор с тем же id и другим payload, poison messages и retries требуют явного контракта.

[Отдельный листинг](examples/go/086_idempotent_consumer_inbox.go)

## Разбор LMX

InboxMessage — единственный владелец обработчика, но дедупликация хранится в БД. tryInsert(subscriber,event) использует unique key и возвращает false при уже committed записи; изменение баланса и вставка входят в один db.atomic. ack — явный broker-порт после commit. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

## Сопоставление

Все варианты связывают durable marker с бизнес-изменением одной транзакцией. Обычный set в памяти годится для окна жизни одного процесса, но не эквивалентен transactional inbox после рестарта.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 174 | 12 |
| Java | 337 | 14 |
| Go | 405 | 17 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Suppress repeated business effects using a durable delivery identity.

**Scenario.** Deliver subscriber 7,event 51,delta 5 twice from balance 100. The first commit succeeds but its ACK is lost.

**Expected observation.** Balance ends at 105 with one inbox row (7,51). Both successful deliveries may ACK. A failed transaction leaves neither marker nor effect and sends no ACK.

**LMX.** InboxMessage owns the handler, while deduplication lives in the database. tryInsert uses a unique key and reports a committed duplicate; marker and balance update share db.atomic. Broker ACK happens after commit. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.

**Comparison.** Every implementation commits the durable marker and business effect together. An in-memory set protects only its lifetime and is not a transactional inbox across restarts.

**Scope and limitations.** Added pattern 86. The guarantee covers one database transaction; external payments are not automatically exactly-once. Key retention, conflicting duplicate payloads, poison messages and retries need explicit policy.

### Dependencies and execution boundaries

- **LMX:** InboxMessage owns the handler, while deduplication lives in the database. tryInsert uses a unique key and reports a committed duplicate; marker and balance update share db.atomic. Broker ACK happens after commit. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.
- **Java:** Added pattern 86. The guarantee covers one database transaction; external payments are not automatically exactly-once. Key retention, conflicting duplicate payloads, poison messages and retries need explicit policy.
- **Go:** Added pattern 86. The guarantee covers one database transaction; external payments are not automatically exactly-once. Key retention, conflicting duplicate payloads, poison messages and retries need explicit policy.

## Источники / Sources

- [Chris Richardson — Idempotent Consumer](https://microservices.io/patterns/communication-style/idempotent-consumer.html) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
