# 040. Bulkhead

Разделение лимитов одновременно выполняемой работы между независимыми направлениями.

## Общий сценарий

У направлений A и B по одному разрешению. A занято; второй запрос A отвергается, первый B принимается.

**Ожидаемое наблюдение:** Для A результаты acquire: 1,0; для B: 1. Освобождение A снова разрешает работу.

**Граница сравнения:** Протокол и порты. Показана изоляция admission, не процессов и памяти. Для crash recovery нужны leases или reconciliation; повтор release не допускается договором примера.

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

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>113</u></span> | 11 |
| Go | 238 | 7 |
| C# | 196 | 6 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Partitioning concurrent work limits between independent destinations.

**Scenario.** Destinations A and B each have one permit. A is occupied; a second A request is rejected, while the first B request is admitted.

**Expected observation.** A acquire results: 1,0; B result: 1. Releasing A admits subsequent work.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once.

**Comparison.** LMX assigns permits to two owners; Go and C# use independent semaphores. A single Message executing both long operations would not isolate their delays.

**Scope and limitations.** This isolates admission, not processes or memory. Crash recovery needs leases or reconciliation; duplicate release is excluded by the example contract.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once.
- **Go:** The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** The host creates two distinct BulkheadMessages, one per destination. acquire/release are addressed mail calls. Long work runs in separate worker Messages; only a successful acquirer releases exactly once. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Bulkhead](https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead) — Разделение лимитов одновременно выполняемой работы между независимыми направлениями.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
