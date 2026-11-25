# 043. Backends for Frontends

Разные фронтенды получают отдельные операции агрегации поверх общего backend.

## Общий сценарий

Backend даёт цену 12 и доставку 3. Мобильный экран показывает цену; web checkout — итог с доставкой.

**Ожидаемое наблюдение:** Mobile возвращает 12 с одним обращением; Web возвращает 15 с двумя.

**Граница сравнения:** Протокол и порты. Денежные единицы в примере — целые условные единицы. Кэш, независимые версии контрактов и частичные сбои двух backend-вызовов не показаны.

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

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 146 | 10 |
| Go | 136 | 3 |
| C# | <span style="color:#176233"><u>130</u></span> | 3 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Different frontends receive separate aggregation operations over a shared backend.

**Scenario.** The backend returns price 12 and shipping 3. Mobile shows the price; web checkout shows the delivered total.

**Expected observation.** Mobile returns 12 after one backend call; Web returns 15 after two.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses.

**Comparison.** The difference is frontend-specific aggregation and independent deployment boundaries. Neither a Message nor a short function alone creates a complete BFF.

**Scope and limitations.** Amounts are integer fixture units. Caching, independently versioned contracts and partial failure across the two backend calls are outside this core.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses.
- **Go:** backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** backend.price(): int and backend.shipping(): int are supplied clients of the shared service; the HTTP profile completes the semantic reply before return. The host publishes separate frontend routes and deploys two BFF Messages; this example uses scalar responses. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Backends for Frontends](https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends) — Разные фронтенды получают отдельные операции агрегации поверх общего backend.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
