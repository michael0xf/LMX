# 056. Health Endpoint Monitoring

Раздельные проверки показывают живость процесса и готовность обслуживать запросы.

## Общий сценарий

Процесс отвечает, но обязательная БД недоступна. Затем БД восстанавливается.

**Ожидаемое наблюдение:** liveness=200 всегда при достижении handler; readiness меняется с 503 на 200.

**Граница сравнения:** Протокол и порты. Если owner заблокирован и handler недостижим, liveness не возвращает 200: внешний deadline обнаружит отказ. Необязательные зависимости не следует включать в readiness без причины.

## LMX

```lmx
HealthMessage:
    @: database
    return: int
    live:
        return: 200
    ready:
        if: database\probe() = 1
            return: 200
        return: 503
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. database.probe():int возвращает 1/0 и имеет ограниченный deadline у провайдера. HTTP route Table связывает /live и /ready с этими методами, а scalar result отображает в HTTP status. Проверяющий монитор — внешний потребитель.

[Отдельный листинг](examples/lmx/056_health_endpoint_monitoring.lm3)

## Go

```go
func Live() int { return 200 }
func Ready(probe func() bool) int {
    if probe() { return 200 }
    return 503
}
```

database.probe():int возвращает 1/0 и имеет ограниченный deadline у провайдера. HTTP route Table связывает /live и /ready с этими методами, а scalar result отображает в HTTP status. Проверяющий монитор — внешний потребитель. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/056_health_endpoint_monitoring.go)

## C#

```csharp
static int Live() => 200;
static int Ready(System.Func<bool> probe) => probe() ? 200 : 503;
```

database.probe():int возвращает 1/0 и имеет ограниченный deadline у провайдера. HTTP route Table связывает /live и /ready с этими методами, а scalar result отображает в HTTP status. Проверяющий монитор — внешний потребитель. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/056_health_endpoint_monitoring.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. database.probe():int возвращает 1/0 и имеет ограниченный deadline у провайдера. HTTP route Table связывает /live и /ready с этими методами, а scalar result отображает в HTTP status. Проверяющий монитор — внешний потребитель.

## Сопоставление

LMX HTTP-профиль уже отделяет admission и семантический ответ, поэтому readiness берётся из результата handler. Один факт принятия письма не делает сервис готовым.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 96 | 9 |
| Go | 84 | 5 |
| C# | <span style="color:#176233"><u>77</u></span> | 2 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Separate checks report process liveness and readiness to serve requests.

**Scenario.** The process responds but its required database is unavailable; the database then recovers.

**Expected observation.** Liveness is 200 when the handler is reached; readiness changes from 503 to 200.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. database.probe():int returns 1/0 under a provider deadline. The HTTP route Table binds /live and /ready to these methods and maps the scalar result to HTTP status. The monitor is an external consumer.

**Comparison.** The existing LMX HTTP profile separates admission from semantic response, so readiness comes from the handler result. Mail acceptance alone does not make the service ready.

**Scope and limitations.** If the owner is blocked and the handler cannot run, liveness does not return 200: the external deadline detects failure. Optional dependencies should not automatically determine readiness.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. database.probe():int returns 1/0 under a provider deadline. The HTTP route Table binds /live and /ready to these methods and maps the scalar result to HTTP status. The monitor is an external consumer.
- **Go:** database.probe():int returns 1/0 under a provider deadline. The HTTP route Table binds /live and /ready to these methods and maps the scalar result to HTTP status. The monitor is an external consumer. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** database.probe():int returns 1/0 under a provider deadline. The HTTP route Table binds /live and /ready to these methods and maps the scalar result to HTTP status. The monitor is an external consumer. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Health Endpoint Monitoring](https://learn.microsoft.com/en-us/azure/architecture/patterns/health-endpoint-monitoring) — Раздельные проверки показывают живость процесса и готовность обслуживать запросы.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
