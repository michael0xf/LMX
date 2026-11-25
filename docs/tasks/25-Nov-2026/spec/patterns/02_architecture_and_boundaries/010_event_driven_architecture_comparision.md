# 010. Event-Driven Architecture

Издатель сообщает о факте, а подписчики независимо обрабатывают событие.

## Общий сценарий

Событие quantity=3 направить в Audit и Stock через две Message-доставки.

**Ожидаемое наблюдение:** Каждый адрес получает одно событие 3; completion одного обработчика не означает completion другого.

**Граница сравнения:** Протокол и порты. Доставка, публикация и обработка — разные события. Долговечный брокер, replay, deduplication и exactly-once effects не следуют из двух send-вызовов.

## LMX

```lmx
Publisher:
    @: audit
    @: stock
    @: sendEvent
    int: quantity
    publish:
        sendEvent(destination := audit; quantity := quantity)
        sendEvent(destination := stock; quantity := quantity)

Consumer:
    int: total 0
    int: quantity
    receiveEvent:
        node\total += quantity
```

sendEvent(destination:Message-ref,quantity:int)→без результата — supplied адаптер существующего Message send/post; он создаёт отдельное письмо с сформированными аргументами и доставляет receiveEvent в последовательный turn адресата. Audit и Stock — два отдельно созданных исполняемых Message из Consumer.

[Отдельный листинг](examples/lmx/010_event_driven_architecture.lm3)

## Java

```java
class Example {
    interface Delivery { void send(String destination, int quantity); }
    static void publish(int quantity, Delivery delivery) {
        delivery.send("audit", quantity);
        delivery.send("stock", quantity);
    }
    static class Consumer {
        int total;
        void receiveEvent(int quantity) { total += quantity; }
    }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/010_event_driven_architecture.java)

## Go

```go
package main
type Delivery func(destination string, quantity int)
func publish(quantity int, delivery Delivery) {
    delivery("audit", quantity)
    delivery("stock", quantity)
}
type Consumer struct { Total int }
func (c *Consumer) ReceiveEvent(quantity int) { c.Total += quantity }
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/010_event_driven_architecture.go)

## Разбор LMX

sendEvent(destination:Message-ref,quantity:int)→без результата — supplied адаптер существующего Message send/post; он создаёт отдельное письмо с сформированными аргументами и доставляет receiveEvent в последовательный turn адресата. Audit и Stock — два отдельно созданных исполняемых Message из Consumer.

## Сопоставление

Явные адресаты делают пример детерминированным; каталог подписок можно вынести в отдельный router Message. Java/Go Delivery обязаны обеспечивать такие же раздельные delivery lanes.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>215</u></span> | 13 |
| Java | 263 | 11 |
| Go | 241 | 8 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A publisher reports a fact and independent subscribers process the event.

**Scenario.** Deliver an event carrying quantity=3 to Audit and Stock as two Message deliveries.

**Expected observation.** Each address receives one event carrying 3; one handler’s completion does not imply the other’s completion.

**LMX.** sendEvent(destination:Message-ref,quantity:int)→no result is a supplied adapter of existing Message send/post. It forms a separate letter and invokes receiveEvent on the recipient’s serial turn. Audit and Stock are separately created executing Messages based on Consumer.

**Comparison.** Explicit recipients make the example deterministic; a subscription catalog can live in a router Message. Java/Go Delivery must provide equivalent separate delivery lanes.

**Scope and limitations.** Sending, publication, and handling are distinct events. A durable broker, replay, deduplication, and exactly-once effects do not follow from two sends.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** sendEvent(destination:Message-ref,quantity:int)→no result is a supplied adapter of existing Message send/post. It forms a separate letter and invokes receiveEvent on the recipient’s serial turn. Audit and Stock are separately created executing Messages based on Consumer.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Microsoft — Event-driven architecture style](https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/event-driven) — Производители, каналы и независимые потребители.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
