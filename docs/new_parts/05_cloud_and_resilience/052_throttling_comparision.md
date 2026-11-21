# 052. Throttling

Admission ограничивает число запросов в фиксированном временном окне.

## Общий сценарий

Лимит два запроса на окно длиной 10. Запросы приходят в моменты 0,1,2,10.

**Ожидаемое наблюдение:** Результаты allow: 1,1,0,1.

**Граница сравнения:** Протокол и порты. Fixed window допускает всплеск на границе соседних окон. Это не token bucket, скользящее окно или распределённая квота.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

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

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 179 | 14 |
| Go | 177 | 7 |
| C# | 170 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Admission limits requests within a fixed time window.

**Scenario.** Limit two requests per window of length 10. Requests arrive at times 0,1,2,10.

**Expected observation.** allow results: 1,1,0,1.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation.

**Comparison.** Algorithm and state are the same; a Message removes concurrent mutation within that owner. Different owners do not automatically share a global quota.

**Scope and limitations.** A fixed window permits a burst across adjacent window boundaries. This is not a token bucket, sliding window or distributed quota.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation.
- **Go:** now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** now:int is nondecreasing integer time; division is integer division. Calls are serial in one owner. The HTTP profile maps allow=0 to an admission refusal such as 429 and does not execute the business operation. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Throttling](https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling) — Admission ограничивает число запросов в фиксированном временном окне.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
