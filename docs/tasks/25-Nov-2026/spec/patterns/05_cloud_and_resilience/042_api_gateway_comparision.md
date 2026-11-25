# 042. API Gateway

Один HTTP endpoint выбирает явный маршрут к одному из внутренних сервисов.

## Общий сценарий

Декодер входа преобразует /orders в route=1, /stock в route=2. Неизвестный путь получает 404.

**Ожидаемое наблюдение:** Маршруты 1 и 2 вызывают соответственно /orders/get и /stock/get; неизвестный маршрут не вызывает провайдера.

**Граница сравнения:** Протокол и порты. Не показаны TLS, авторизация, копирование тела и потоковая передача. Они остаются обязательствами HTTP-провайдера и admission во всех трёх реализациях.

## LMX

```lmx
GatewayMessage:
    int: route
    @: http
    return: int
    dispatch:
        if: route = 1
            return: http\post("https://orders.example"; "/orders/get")
        if: route = 2
            return: http\post("https://stock.example"; "/stock/get")
        return: 404
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. http.post(endpoint: string, route: string): int — поставленный HTTP-провайдер: кодирует фиксированное тело LMX как application/lmx и возвращает статус синхронного семантического ответа. Декодирование URI и explicit route Table находятся в общем профиле, а не в магическом поиске методов.

[Отдельный листинг](examples/lmx/042_api_gateway.lm3)

## Go

```go
func Route(id int, post func(string, string) int) int {
    routes := map[int][2]string{
        1: {"https://orders.example", "/orders/get"},
        2: {"https://stock.example", "/stock/get"},
    }
    target, ok := routes[id]
    if !ok { return 404 }
    return post(target[0], target[1])
}
```

http.post(endpoint: string, route: string): int — поставленный HTTP-провайдер: кодирует фиксированное тело LMX как application/lmx и возвращает статус синхронного семантического ответа. Декодирование URI и explicit route Table находятся в общем профиле, а не в магическом поиске методов. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/042_api_gateway.go)

## C#

```csharp
static int Route(int id, System.Func<string,string,int> post) {
    return id switch {
        1 => post("https://orders.example", "/orders/get"),
        2 => post("https://stock.example", "/stock/get"),
        _ => 404
    };
}
```

http.post(endpoint: string, route: string): int — поставленный HTTP-провайдер: кодирует фиксированное тело LMX как application/lmx и возвращает статус синхронного семантического ответа. Декодирование URI и explicit route Table находятся в общем профиле, а не в магическом поиске методов. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/042_api_gateway.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. http.post(endpoint: string, route: string): int — поставленный HTTP-провайдер: кодирует фиксированное тело LMX как application/lmx и возвращает статус синхронного семантического ответа. Декодирование URI и explicit route Table находятся в общем профиле, а не в магическом поиске методов.

## Сопоставление

У LMX уже есть HTTP-профиль и admission; прикладная таблица маршрутов всё равно нужна. Контрольные листинги используют тот же контракт транспорта.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 189 | 10 |
| Go | 227 | 9 |
| C# | <span style="color:#176233"><u>175</u></span> | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

One HTTP endpoint selects an explicit route to an internal service.

**Scenario.** Ingress maps /orders to route=1 and /stock to route=2. An unknown path receives 404.

**Expected observation.** Routes 1 and 2 invoke /orders/get and /stock/get respectively; an unknown route never invokes the provider.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. http.post(endpoint: string, route: string): int is a supplied provider that encodes the fixed LMX body as application/lmx and returns the synchronous semantic-response status. URI decoding and the explicit route Table belong to the shared profile, not magical method lookup.

**Comparison.** LMX already supplies the HTTP profile and admission model; an application route table is still needed. Control listings use the same transport contract.

**Scope and limitations.** TLS, authorization, body forwarding and streaming are not shown. They remain HTTP-provider and admission obligations in all three implementations.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. http.post(endpoint: string, route: string): int is a supplied provider that encodes the fixed LMX body as application/lmx and returns the synchronous semantic-response status. URI decoding and the explicit route Table belong to the shared profile, not magical method lookup.
- **Go:** http.post(endpoint: string, route: string): int is a supplied provider that encodes the fixed LMX body as application/lmx and returns the synchronous semantic-response status. URI decoding and the explicit route Table belong to the shared profile, not magical method lookup. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** http.post(endpoint: string, route: string): int is a supplied provider that encodes the fixed LMX body as application/lmx and returns the synchronous semantic-response status. URI decoding and the explicit route Table belong to the shared profile, not magical method lookup. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Gateway Routing](https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-routing) — Один HTTP endpoint выбирает явный маршрут к одному из внутренних сервисов.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
