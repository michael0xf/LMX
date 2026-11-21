# 010. Event-Driven Architecture

Издатель сообщает о факте, а подписчики независимо обрабатывают событие.

## Общий сценарий

Событие quantity=3 направить в Audit и Stock через две Message-доставки.

**Ожидаемое наблюдение:** Каждый адрес получает одно событие 3; completion одного обработчика не означает completion другого.

**Граница сравнения:** Протокол и порты. Доставка, публикация и обработка — разные события. Долговечный брокер, replay, deduplication и exactly-once effects не следуют из двух send-вызовов.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

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

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 215 | 13 |
| Java | 263 | 11 |
| Go | 241 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A publisher reports a fact and independent subscribers process the event.

**Scenario.** Deliver an event carrying quantity=3 to Audit and Stock as two Message deliveries.

**Expected observation.** Each address receives one event carrying 3; one handler’s completion does not imply the other’s completion.

**LMX.** sendEvent(destination:Message-ref,quantity:int)→no result is a supplied adapter of existing Message send/post. It forms a separate letter and invokes receiveEvent on the recipient’s serial turn. Audit and Stock are separately created executing Messages based on Consumer.

**Comparison.** Explicit recipients make the example deterministic; a subscription catalog can live in a router Message. Java/Go Delivery must provide equivalent separate delivery lanes.

**Scope and limitations.** Sending, publication, and handling are distinct events. A durable broker, replay, deduplication, and exactly-once effects do not follow from two sends.

### Dependencies and execution boundaries

- **LMX:** sendEvent(destination:Message-ref,quantity:int)→no result is a supplied adapter of existing Message send/post. It forms a separate letter and invokes receiveEvent on the recipient’s serial turn. Audit and Stock are separately created executing Messages based on Consumer.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Microsoft — Event-driven architecture style](https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/event-driven) — Производители, каналы и независимые потребители.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
