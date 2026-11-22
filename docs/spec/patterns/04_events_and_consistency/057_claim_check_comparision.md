# 057. Claim Check

Передать ссылку-квитанцию на большие данные, сохранив сами данные отдельно.

## Общий сценарий

Сохранить ASCII payload длиной 10000 и послать только ticket(key,length). Получатель проверяет полномочия своего store-порта, читает blob и сравнивает длину.

**Ожидаемое наблюдение:** Через очередь/HTTP идёт маленький DTO из двух чисел; обработчик получает исходный payload длиной 10000. Несовпадение длины выдаёт Payload.

**Граница сравнения:** Протокол и порты. ASCII фиксирует одинаковую длину в char/UTF-16/байтах. Длина не заменяет digest. Доступ, retention, cleanup сирот, повторное чтение и expiry токена задаются хранилищем; ticket сам не выдаёт полномочия.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
independent: TicketData:
    int: key 0
    int: size 0

SenderMessage:
    @: blobs
    @: transport
    []: char payload
    send:
        int: key blobs\put(payload)
        @: ticket (copy(TicketData))
        ticket\key := key
        ticket\size := length(payload)
        transport\publish(ticket := ticket)

ConsumerMessage:
    @: blobs
    @: consume
    @: ticket
    receivePayload:
        throws: Payload
        @: payload blobs\get(ticket\key)
        if: length(payload) != ticket\size
            throw: Payload()
        consume(payload := payload)
```

SenderMessage и ConsumerMessage — разные владельцы. blobs.put/get — явное внешнее blob-хранилище; transport.publish(ticket) использует Message/post либо описанный HTTP application/lmx. Key — переносимый идентификатор, не адрес арены. Полный payload не входит в Message. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E. TicketData имеет independent-корень; sender копирует готовые primitive leaves и явно записывает key/size до publish. Получатель получает значения, а не initializer, ссылающийся на завершившийся sender frame.

[Отдельный листинг](examples/lmx/057_claim_check.lm3)

## Java

```java
import java.util.function.Consumer;
record Ticket(int key,int size) {}
interface Blobs { int put(String payload); String get(int key); }
final class ClaimCheck {
    static void send(Blobs blobs,Consumer<Ticket> publish,String payload) {
        int key=blobs.put(payload);
        publish.accept(new Ticket(key,payload.length()));
    }
    static void receive(Blobs blobs,Consumer<String> consume,Ticket ticket) {
        String payload=blobs.get(ticket.key());
        if (payload.length()!=ticket.size()) throw new IllegalStateException("payload");
        consume.accept(payload);
    }
}
```

ASCII фиксирует одинаковую длину в char/UTF-16/байтах. Длина не заменяет digest. Доступ, retention, cleanup сирот, повторное чтение и expiry токена задаются хранилищем; ticket сам не выдаёт полномочия.

[Отдельный листинг](examples/java/057_claim_check.java)

## Go

```go
package patterns
import "fmt"
type Ticket struct { Key,Size int }
type Blobs interface { Put(string) (int,error); Get(int) (string,error) }
func Send(blobs Blobs,publish func(Ticket) error,payload string) error {
    key,err:=blobs.Put(payload); if err!=nil { return err }
    return publish(Ticket{key,len(payload)})
}
func Receive(blobs Blobs,consume func(string) error,ticket Ticket) error {
    payload,err:=blobs.Get(ticket.Key); if err!=nil { return err }
    if len(payload)!=ticket.Size { return fmt.Errorf("payload") }
    return consume(payload)
}
```

ASCII фиксирует одинаковую длину в char/UTF-16/байтах. Длина не заменяет digest. Доступ, retention, cleanup сирот, повторное чтение и expiry токена задаются хранилищем; ticket сам не выдаёт полномочия.

[Отдельный листинг](examples/go/057_claim_check.go)

## Разбор LMX

SenderMessage и ConsumerMessage — разные владельцы. blobs.put/get — явное внешнее blob-хранилище; transport.publish(ticket) использует Message/post либо описанный HTTP application/lmx. Key — переносимый идентификатор, не адрес арены. Полный payload не входит в Message. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E. TicketData имеет independent-корень; sender копирует готовые primitive leaves и явно записывает key/size до publish. Получатель получает значения, а не initializer, ссылающийся на завершившийся sender frame.

## Сопоставление

Во всех вариантах сначала завершается сохранение blob, затем публикуется ticket. Это согласуется с LMX HTTP-профилем, допускающим cursor/range для большого тела.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 388 | 23 |
| Java | 488 | 14 |
| Go | 476 | 13 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Send a compact claim ticket while retaining the large payload externally.

**Scenario.** Store 10000 ASCII characters and publish only ticket(key,length). The receiver uses its authorized store port to fetch and validate length.

**Expected observation.** The queue/HTTP carries two integers; the consumer obtains the original 10000-character payload. A length mismatch raises Payload.

**LMX.** SenderMessage and ConsumerMessage are separate owners. blobs.put/get is explicit external storage; publish uses Message/post or the documented application/lmx HTTP profile. Key is portable, never an arena address; the body is not in the Message. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity. TicketData has an independent root; the sender copies ready primitive leaves and explicitly writes key/size before publish. The receiver obtains values, not an initializer referring to an expired sender frame.

**Comparison.** All versions persist the blob before publishing the ticket. LMX HTTP also supports cursor/range bodies for this role.

**Scope and limitations.** ASCII makes length comparable across char, UTF-16 and byte representations. Length is not a digest. Authorization, retention, orphan cleanup and expiry remain store policy; a ticket grants no automatic authority.

### Dependencies and execution boundaries

- **LMX:** SenderMessage and ConsumerMessage are separate owners. blobs.put/get is explicit external storage; publish uses Message/post or the documented application/lmx HTTP profile. Key is portable, never an arena address; the body is not in the Message. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity. TicketData has an independent root; the sender copies ready primitive leaves and explicitly writes key/size before publish. The receiver obtains values, not an initializer referring to an expired sender frame.
- **Java:** ASCII makes length comparable across char, UTF-16 and byte representations. Length is not a digest. Authorization, retention, orphan cleanup and expiry remain store policy; a ticket grants no automatic authority.
- **Go:** ASCII makes length comparable across char, UTF-16 and byte representations. Length is not a digest. Authorization, retention, orphan cleanup and expiry remain store policy; a ticket grants no automatic authority.

## Источники / Sources

- [Microsoft Azure Architecture Center — Claim Check](https://learn.microsoft.com/en-us/azure/architecture/patterns/claim-check) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
