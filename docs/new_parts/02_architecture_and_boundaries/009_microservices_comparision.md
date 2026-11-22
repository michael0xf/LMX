# 009. Microservices

Сервисы имеют собственные границы развёртывания и общаются через транспортный контракт.

## Общий сценарий

Checkout запрашивает стоимость трёх единиц у Catalog по endpoint и route; fixture возвращает 30.

**Ожидаемое наблюдение:** Один запрос к https://catalog.example/quote, quantity=3; успешный semantic reply содержит 30.

**Граница сравнения:** Протокол и порты. Нужны два отдельно запускаемых сервиса, HTTP provider, codec/admission и response mapping. Эта таблица считает только ядро; физическая независимость, отказоустойчивость и версии wire-контракта не реализованы листингом.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

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

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 186 | 11 |
| Java | 241 | 7 |
| Go | 211 | 6 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Services have independent deployment boundaries and communicate through a transport contract.

**Scenario.** Checkout asks Catalog for three units through an endpoint and route; the fixture returns 30.

**Expected observation.** One request to https://catalog.example/quote with quantity=3; the successful semantic reply contains 30.

**LMX.** Call Checkout\buy(quantity := 3; exchange := suppliedAdapter). exchange(endpoint:Array<char>, route:Array<char>, quantity:int)→int forms a complete application/lmx document, performs HTTP exchange, and returns a successful semantic reply; failures follow the agreed ordinary exit. Catalog\quote executes in Catalog’s owning Message.

**Comparison.** LMX already has an HTTP transport profile. Java/Go Exchange is the same excluded adapter. A common external fixture supplies quantity=3, checks endpoint/route, and invokes catalog; this checks the business boundary, not network deployment.

**Scope and limitations.** Two separately launched services, an HTTP provider, codec/admission, and response mapping are required. Only the core is counted; deployment independence, resilience, and wire-versioning are not implemented by the listing.

### Dependencies and execution boundaries

- **LMX:** Call Checkout\buy(quantity := 3; exchange := suppliedAdapter). exchange(endpoint:Array<char>, route:Array<char>, quantity:int)→int forms a complete application/lmx document, performs HTTP exchange, and returns a successful semantic reply; failures follow the agreed ordinary exit. Catalog\quote executes in Catalog’s owning Message.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [James Lewis and Martin Fowler — Microservices](https://martinfowler.com/articles/microservices.html) — Независимое развёртывание и лёгкие транспортные границы.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
