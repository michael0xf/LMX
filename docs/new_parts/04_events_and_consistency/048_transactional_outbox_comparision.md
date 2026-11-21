# 048. Transactional Outbox

Сохранить бизнес-изменение и исходящее событие одной локальной транзакцией.

## Общий сценарий

Команда меняет счёт 7 на 120 и создаёт событие id=51. Relay отправляет событие; в контрольном сбое процесс падает после publish и до markSent.

**Ожидаемое наблюдение:** При rollback нет ни изменения, ни outbox-строки. После commit оба существуют. После контрольного сбоя relay повторно отправляет id=51: потребитель должен уметь подавить дубль.

**Граница сравнения:** Протокол и порты. Один relay, упорядоченный pending batch и уникальный event-id. Параллельные relay требуют claim/lease. Broker ack, retries и idempotent consumer задаются инфраструктурой; exactly-once доставка не обещается.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
OutboxMessage:
    @: db
    int: accountId
    int: cents
    int: eventId
    write:
        db\updateAccount(accountId; cents)
        db\insertOutbox(eventId; accountId; cents)
    execute:
        db\atomic(body := write)

RelayMessage:
    @: db
    @: transport
    relay:
        @: batch node\db\pending()
        int: i 0
        while: i < length(batch)
            @: event batch[i]
            node\transport\publish(event := event)
            node\db\markSent(event\id)
            i += 1
```

OutboxMessage и RelayMessage — отдельные владельцы. db.atomic(write) синхронно вызывает write; бизнес-строка и outbox находятся в одной транзакционной БД. transport.publish — адаптер к Message/post либо HTTP-профилю; его успешный возврат означает оговорённое подтверждение брокера, а не исполнение потребителем. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

[Отдельный листинг](examples/lmx/048_transactional_outbox.lm3)

## Java

```java
import java.util.List;
record Event(int id,int accountId,int cents) {}
interface OutboxDb {
    void atomic(Runnable body);
    void updateAccount(int id,int cents);
    void insertOutbox(int eventId,int accountId,int cents);
    List<Event> pending();
    void markSent(int eventId);
}
interface Publisher { void publish(Event event); }
final class Outbox {
    static void execute(OutboxDb db,int id,int cents,int eventId) {
        db.atomic(() -> { db.updateAccount(id,cents); db.insertOutbox(eventId,id,cents); });
    }
    static void relay(OutboxDb db,Publisher publisher) {
        for (Event event:db.pending()) {
            publisher.publish(event);
            db.markSent(event.id());
        }
    }
}
```

Один relay, упорядоченный pending batch и уникальный event-id. Параллельные relay требуют claim/lease. Broker ack, retries и idempotent consumer задаются инфраструктурой; exactly-once доставка не обещается.

[Отдельный листинг](examples/java/048_transactional_outbox.java)

## Go

```go
package patterns
type Event struct { ID,AccountID,Cents int }
type OutboxDB interface {
    Atomic(func() error) error
    UpdateAccount(int,int) error
    InsertOutbox(int,int,int) error
    Pending() ([]Event,error)
    MarkSent(int) error
}
func Execute(db OutboxDB,id,cents,eventID int) error {
    return db.Atomic(func() error {
        if err:=db.UpdateAccount(id,cents); err!=nil { return err }
        return db.InsertOutbox(eventID,id,cents)
    })
}
func Relay(db OutboxDB,publish func(Event) error) error {
    batch,err:=db.Pending(); if err!=nil { return err }
    for _,event:=range batch {
        if err=publish(event); err!=nil { return err }
        if err=db.MarkSent(event.ID); err!=nil { return err }
    }
    return nil
}
```

Один relay, упорядоченный pending batch и уникальный event-id. Параллельные relay требуют claim/lease. Broker ack, retries и idempotent consumer задаются инфраструктурой; exactly-once доставка не обещается.

[Отдельный листинг](examples/go/048_transactional_outbox.go)

## Разбор LMX

OutboxMessage и RelayMessage — отдельные владельцы. db.atomic(write) синхронно вызывает write; бизнес-строка и outbox находятся в одной транзакционной БД. transport.publish — адаптер к Message/post либо HTTP-профилю; его успешный возврат означает оговорённое подтверждение брокера, а не исполнение потребителем. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

## Сопоставление

Все версии явно делают запись в outbox до commit и markSent после публикации. Сама по себе очередь исходящих Message в конце turn не равна durable outbox БД.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 326 | 21 |
| Java | 563 | 21 |
| Go | 588 | 23 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Commit the business change and outgoing event in one local database transaction.

**Scenario.** Update account 7 to 120 and create event 51. Relay publishes; inject a crash after publish but before markSent.

**Expected observation.** Rollback leaves neither change nor outbox row. Commit persists both. The crash causes event 51 to be published again, so consumption must be idempotent.

**LMX.** OutboxMessage and RelayMessage are separate owners. db.atomic invokes write synchronously; both rows share a transaction. The transport port uses Message/post or HTTP; successful publish means the chosen broker acknowledgement, not consumer execution. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.

**Comparison.** Every version inserts before commit and marks sent only after publication. End-of-turn Message staging is not a durable database outbox.

**Scope and limitations.** One relay, ordered batches and unique event IDs are assumed. Parallel relays need claims/leases. No exactly-once delivery is promised.

### Dependencies and execution boundaries

- **LMX:** OutboxMessage and RelayMessage are separate owners. db.atomic invokes write synchronously; both rows share a transaction. The transport port uses Message/post or HTTP; successful publish means the chosen broker acknowledgement, not consumer execution. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.
- **Java:** One relay, ordered batches and unique event IDs are assumed. Parallel relays need claims/leases. No exactly-once delivery is promised.
- **Go:** One relay, ordered batches and unique event IDs are assumed. Parallel relays need claims/leases. No exactly-once delivery is promised.

## Источники / Sources

- [Chris Richardson — Transactional Outbox](https://microservices.io/patterns/data/transactional-outbox.html) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
