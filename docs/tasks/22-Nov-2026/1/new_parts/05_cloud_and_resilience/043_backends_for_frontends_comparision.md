# 043. Backends for Frontends

Разные фронтенды получают отдельные операции агрегации поверх общего backend.

## Общий сценарий

Backend даёт цену 12 и доставку 3. Мобильный экран показывает цену; web checkout — итог с доставкой.

**Ожидаемое наблюдение:** Mobile возвращает 12 с одним обращением; Web возвращает 15 с двумя.

**Граница сравнения:** Протокол и порты. Денежные единицы в примере — целые условные единицы. Кэш, независимые версии контрактов и частичные сбои двух backend-вызовов не показаны.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
MobileBffMessage:
    @: backend
    return: int
    show:
        return: backend\price()

WebBffMessage:
    @: backend
    return: int
    checkout:
        return: backend\price() + backend\shipping()
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. backend.price(): int и backend.shipping(): int — поставленный клиент общего сервиса; HTTP-профиль завершает семантический ответ перед возвратом. Хост публикует разные frontend routes и развёртывает два BFF Message; схема ответа здесь скалярная.

[Отдельный листинг](examples/lmx/043_backends_for_frontends.lm3)

## Go

```go
type Catalog interface { Price() int; Shipping() int }
func Mobile(c Catalog) int { return c.Price() }
func Web(c Catalog) int { return c.Price() + c.Shipping() }
```

backend.price(): int и backend.shipping(): int — поставленный клиент общего сервиса; HTTP-профиль завершает семантический ответ перед возвратом. Хост публикует разные frontend routes и развёртывает два BFF Message; схема ответа здесь скалярная. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/043_backends_for_frontends.go)

## C#

```csharp
interface ICatalog { int Price(); int Shipping(); }
static int Mobile(ICatalog c) => c.Price();
static int Web(ICatalog c) => c.Price() + c.Shipping();
```

backend.price(): int и backend.shipping(): int — поставленный клиент общего сервиса; HTTP-профиль завершает семантический ответ перед возвратом. Хост публикует разные frontend routes и развёртывает два BFF Message; схема ответа здесь скалярная. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/043_backends_for_frontends.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. backend.price(): int и backend.shipping(): int — поставленный клиент общего сервиса; HTTP-профиль завершает семантический ответ перед возвратом. Хост публикует разные frontend routes и развёртывает два BFF Message; схема ответа здесь скалярная.

## Сопоставление

Различие находится в frontend-specific агрегировании и независимых границах развёртывания. Ни Message, ни короткая функция сами по себе не создают полноценный BFF.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 146 | 10 |
| Go | 136 | 3 |
| C# | 130 | 3 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Different frontends receive separate aggregation operations over a shared backend.

**Scenario.** The backend returns price 12 and shipping 3. Mobile shows the price; web checkout shows the delivered total.

**Expected observation.** Mobile returns 12 after one backend call; Web returns 15 after two.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses.

**Comparison.** The difference is frontend-specific aggregation and independent deployment boundaries. Neither a Message nor a short function alone creates a complete BFF.

**Scope and limitations.** Amounts are integer fixture units. Caching, independently versioned contracts and partial failure across the two backend calls are outside this core.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses.
- **Go:** backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Backends for Frontends](https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends) — Разные фронтенды получают отдельные операции агрегации поверх общего backend.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
