# 052. Throttling

Admission ограничивает число запросов в фиксированном временном окне.

## Общий сценарий

Лимит два запроса на окно длиной 10. Запросы приходят в моменты 0,1,2,10.

**Ожидаемое наблюдение:** Результаты allow: 1,1,0,1.

**Граница сравнения:** Протокол и порты. Fixed window допускает всплеск на границе соседних окон. Это не token bucket, скользящее окно или распределённая квота.

## LMX

```lmx
ThrottleMessage:
    int: now
    int: window -1
    int: count 0
    return: int
    allow:
        int: current now / 10
        if: current != node\window
            node\window := current
            node\count := 0
        if: node\count >= 2
            return: 0
        node\count += 1
        return: 1
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. now:int — неубывающее целое время; целочисленное деление. Вызовы последовательны в одном владельце. HTTP-профиль отображает allow=0 в выбранный admission отказ, например 429, и не исполняет бизнес-операцию.

[Отдельный листинг](examples/lmx/052_throttling.lm3)

## Go

```go
type Throttle struct { window, count int }
func (t *Throttle) Allow(now int) bool {
    current := now / 10
    if current != t.window { t.window = current; t.count = 0 }
    if t.count >= 2 { return false }
    t.count++; return true
}
```

now:int — неубывающее целое время; целочисленное деление. Вызовы последовательны в одном владельце. HTTP-профиль отображает allow=0 в выбранный admission отказ, например 429, и не исполняет бизнес-операцию. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/052_throttling.go)

## C#

```csharp
sealed class Throttle {
    int window = -1, count;
    public bool Allow(int now) {
        int current = now / 10;
        if (current != window) { window = current; count = 0; }
        if (count >= 2) return false;
        count++; return true;
    }
}
```

now:int — неубывающее целое время; целочисленное деление. Вызовы последовательны в одном владельце. HTTP-профиль отображает allow=0 в выбранный admission отказ, например 429, и не исполняет бизнес-операцию. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/052_throttling.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. now:int — неубывающее целое время; целочисленное деление. Вызовы последовательны в одном владельце. HTTP-профиль отображает allow=0 в выбранный admission отказ, например 429, и не исполняет бизнес-операцию.

## Сопоставление

Алгоритм и состояние совпадают; Message устраняет конкурентную модификацию счётчика внутри данного владельца. Разные владельцы не делят один глобальный лимит автоматически.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 179 | 14 |
| Go | 177 | 7 |
| C# | <span style="color:#176233"><u>170</u></span> | 9 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Admission limits requests within a fixed time window.

**Scenario.** Limit two requests per window of length 10. Requests arrive at times 0,1,2,10.

**Expected observation.** allow results: 1,1,0,1.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation.

**Comparison.** Algorithm and state are the same; a Message removes concurrent mutation within that owner. Different owners do not automatically share a global quota.

**Scope and limitations.** A fixed window permits a burst across adjacent window boundaries. This is not a token bucket, sliding window or distributed quota.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation.
- **Go:** now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Throttling](https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling) — Admission ограничивает число запросов в фиксированном временном окне.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
