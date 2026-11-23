# 009. Microservices

Сервисы имеют собственные границы развёртывания и общаются через транспортный контракт.

## Общий сценарий

Checkout запрашивает стоимость трёх единиц у Catalog по endpoint и route; fixture возвращает 30.

**Ожидаемое наблюдение:** Один запрос к https://catalog.example/quote, quantity=3; успешный semantic reply содержит 30.

**Граница сравнения:** Протокол и порты. Нужны два отдельно запускаемых сервиса, HTTP provider, codec/admission и response mapping. Эта таблица считает только ядро; физическая независимость, отказоустойчивость и версии wire-контракта не реализованы листингом.

## LMX

```lmx
Catalog:
    int: quantity
    return: int
    quote:
        return: quantity * 10

Checkout:
    int: quantity
    @: exchange
    return: int
    buy:
        return: exchange(endpoint := "https://catalog.example"; route := "/quote"; quantity := quantity)
```

Checkout\buy(quantity := 3; exchange := suppliedAdapter). Порт exchange(endpoint:Array<char>, route:Array<char>, quantity:int)→int формирует полный LMX-документ application/lmx, выполняет HTTP exchange, затем возвращает успешный semantic reply; failure передаёт обычным согласованным выходом. Catalog\quote выполняется в Message владельца Catalog.

[Отдельный листинг](examples/lmx/009_microservices.lm3)

## Java

```java
class Example {
    interface Exchange { int quote(String endpoint, String route, int quantity); }
    static int catalog(int quantity) { return quantity * 10; }
    static int buy(int quantity, Exchange exchange) {
        return exchange.quote("https://catalog.example", "/quote", quantity);
    }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/009_microservices.java)

## Go

```go
package main
type Exchange func(endpoint, route string, quantity int) int
func catalog(quantity int) int { return quantity * 10 }
func buy(quantity int, exchange Exchange) int {
    return exchange("https://catalog.example", "/quote", quantity)
}
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/009_microservices.go)

## Разбор LMX

Checkout\buy(quantity := 3; exchange := suppliedAdapter). Порт exchange(endpoint:Array<char>, route:Array<char>, quantity:int)→int формирует полный LMX-документ application/lmx, выполняет HTTP exchange, затем возвращает успешный semantic reply; failure передаёт обычным согласованным выходом. Catalog\quote выполняется в Message владельца Catalog.

## Сопоставление

LMX уже имеет HTTP transport profile. Java/Go Exchange — тот же явно исключённый адаптер. Общий внешний fixture передаёт quantity=3, проверяет endpoint/route и вызывает catalog; это проверка бизнес-границы, не доказательство сетевого развёртывания.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 186 | 11 |
| Java | 241 | 7 |
| Go | 211 | 6 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Services have independent deployment boundaries and communicate through a transport contract.

**Scenario.** Checkout asks Catalog for three units through an endpoint and route; the fixture returns 30.

**Expected observation.** One request to https://catalog.example/quote with quantity=3; the successful semantic reply contains 30.

**LMX.** Call Checkout\buy(quantity := 3; exchange := suppliedAdapter). exchange(endpoint:Array<char>, route:Array<char>, quantity:int)→int forms a complete application/lmx document, performs HTTP exchange, and returns a successful semantic reply; failures follow the agreed ordinary exit. Catalog\quote executes in Catalog’s owning Message.

**Comparison.** LMX already has an HTTP transport profile. Java/Go Exchange is the same excluded adapter. A common external fixture supplies quantity=3, checks endpoint/route, and invokes catalog; this checks the business boundary, not network deployment.

**Scope and limitations.** Two separately launched services, an HTTP provider, codec/admission, and response mapping are required. Only the core is counted; deployment independence, resilience, and wire-versioning are not implemented by the listing.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** Call Checkout\buy(quantity := 3; exchange := suppliedAdapter). exchange(endpoint:Array<char>, route:Array<char>, quantity:int)→int forms a complete application/lmx document, performs HTTP exchange, and returns a successful semantic reply; failures follow the agreed ordinary exit. Catalog\quote executes in Catalog’s owning Message.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [James Lewis and Martin Fowler — Microservices](https://martinfowler.com/articles/microservices.html) — Независимое развёртывание и лёгкие транспортные границы.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
