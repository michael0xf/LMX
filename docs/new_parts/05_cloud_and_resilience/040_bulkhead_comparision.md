# 040. Bulkhead

Разделение лимитов одновременно выполняемой работы между независимыми направлениями.

## Общий сценарий

У направлений A и B по одному разрешению. A занято; второй запрос A отвергается, первый B принимается.

**Ожидаемое наблюдение:** Для A результаты acquire: 1,0; для B: 1. Освобождение A снова разрешает работу.

**Граница сравнения:** Протокол и порты. Показана изоляция admission, не процессов и памяти. Для crash recovery нужны leases или reconciliation; повтор release не допускается договором примера.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
BulkheadMessage:
    int: used 0
    return: int
    acquire:
        if: node\used = 1
            return: 0
        node\used := 1
        return: 1
    release:
        node\used := 0
        return: 1
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. Хост создаёт два разных BulkheadMessage, по одному на направление. acquire/release адресуются их почте. Длительная работа идёт в отдельных рабочих Message; только получивший разрешение освобождает его ровно один раз.

[Отдельный листинг](examples/lmx/040_bulkhead.lm3)

## Go

```go
type Bulkhead chan struct{}
func NewBulkhead() Bulkhead { return make(chan struct{}, 1) }
func (b Bulkhead) Acquire() bool {
    select { case b <- struct{}{}: return true; default: return false }
}
func (b Bulkhead) Release() int { <-b; return 1 }
// a := NewBulkhead(); b := NewBulkhead()
```

Хост создаёт два разных BulkheadMessage, по одному на направление. acquire/release адресуются их почте. Длительная работа идёт в отдельных рабочих Message; только получивший разрешение освобождает его ровно один раз. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/040_bulkhead.go)

## C#

```csharp
sealed class Bulkhead {
    readonly System.Threading.SemaphoreSlim permit = new(1, 1);
    public bool Acquire() => permit.Wait(0);
    public int Release() { permit.Release(); return 1; }
}
// var a = new Bulkhead(); var b = new Bulkhead();
```

Хост создаёт два разных BulkheadMessage, по одному на направление. acquire/release адресуются их почте. Длительная работа идёт в отдельных рабочих Message; только получивший разрешение освобождает его ровно один раз. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/040_bulkhead.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. Хост создаёт два разных BulkheadMessage, по одному на направление. acquire/release адресуются их почте. Длительная работа идёт в отдельных рабочих Message; только получивший разрешение освобождает его ровно один раз.

## Сопоставление

LMX переносит владение разрешением к двум владельцам; Go и C# используют два независимых семафора. Один общий Message, исполняющий обе долгие операции, не обеспечил бы изоляции задержек.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 113 | 11 |
| Go | 238 | 7 |
| C# | 196 | 6 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Partitioning concurrent work limits between independent destinations.

**Scenario.** Destinations A and B each have one permit. A is occupied; a second A request is rejected, while the first B request is admitted.

**Expected observation.** A acquire results: 1,0; B result: 1. Releasing A admits subsequent work.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once.

**Comparison.** LMX assigns permits to two owners; Go and C# use independent semaphores. A single Message executing both long operations would not isolate their delays.

**Scope and limitations.** This isolates admission, not processes or memory. Crash recovery needs leases or reconciliation; duplicate release is excluded by the example contract.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once.
- **Go:** The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Bulkhead](https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead) — Разделение лимитов одновременно выполняемой работы между независимыми направлениями.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
