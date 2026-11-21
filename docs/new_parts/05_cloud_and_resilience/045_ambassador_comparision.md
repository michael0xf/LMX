# 045. Ambassador

Локальный сетевой посредник скрывает внешний endpoint и политику повторов от клиента.

## Общий сценарий

Клиент просит получить каталог. Ambassador обращается к заданному endpoint: первый результат 503, второй 200.

**Ожидаемое наблюдение:** Клиент получает 200; внешний провайдер вызван дважды, с одним и тем же endpoint/route.

**Граница сравнения:** Протокол и порты. Пример повторяет только безопасное чтение. TLS не реализуется вручную; auth, backoff и метрики — обязательства выбранного провайдера/политики.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
AmbassadorMessage:
    @: http
    return: int
    catalog:
        int: status http\post("https://catalog.example"; "/catalog/read")
        if: status = 503
            return: http\post("https://catalog.example"; "/catalog/read")
        return: status
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile.

[Отдельный листинг](examples/lmx/045_ambassador.lm3)

## Go

```go
func Ambassador(post func(string, string) int) int {
    const endpoint = "https://catalog.example"
    const route = "/catalog/read"
    status := post(endpoint, route)
    if status == 503 { return post(endpoint, route) }
    return status
}
```

http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/045_ambassador.go)

## C#

```csharp
static int Ambassador(System.Func<string,string,int> post) {
    const string endpoint = "https://catalog.example", route = "/catalog/read";
    int status = post(endpoint, route);
    return status == 503 ? post(endpoint, route) : status;
}
```

http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/045_ambassador.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile.

## Сопоставление

Message задаёт границу состояния посредника; HTTP остаётся штатным транспортным профилем LMX. В контрольных языках такая же граница создаётся хостом.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 189 | 8 |
| Go | 193 | 7 |
| C# | 202 | 5 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A local network proxy hides the remote endpoint and retry policy from its client.

**Scenario.** The client requests a catalog. The ambassador calls its configured endpoint: first status 503, then 200.

**Expected observation.** The client receives 200; the remote provider is called twice with the same endpoint and route.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile.

**Comparison.** A Message defines proxy state ownership; HTTP remains an existing LMX transport profile. The host creates the equivalent boundary for control languages.

**Scope and limitations.** Only a safe read is retried. TLS is not hand-implemented; authentication, backoff and metrics belong to the selected provider and policy.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile.
- **Go:** http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Ambassador](https://learn.microsoft.com/en-us/azure/architecture/patterns/ambassador) — Локальный сетевой посредник скрывает внешний endpoint и политику повторов от клиента.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
