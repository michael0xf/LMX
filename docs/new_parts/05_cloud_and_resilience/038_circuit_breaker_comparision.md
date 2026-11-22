# 038. Circuit Breaker

После двух последовательных отказов владелец временно запрещает новые обращения и затем допускает пробу.

## Общий сценарий

Вызовы в моменты 0 и 1 завершаются отказом; вызов в 2 должен быть отклонён; проба в 6 успешна.

**Ожидаемое наблюдение:** Результаты 0, 0, −1, 1; провайдер вызывается три раза; после пробы счётчик отказов равен нулю.

**Граница сравнения:** Протокол и порты. Это минимальный breaker по последовательным отказам. Оконная статистика, конкурентные in-flight запросы, классификация ошибок и длительность самой попытки требуют отдельного профиля.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
BreakerMessage:
    int: now
    @: request
    int: failures 0
    int: until 0
    return: int
    invoke:
        if: now < node\until
            return: -1
        int: ok request()
        if: ok = 1
            node\failures := 0
            node\until := 0
            return: 1
        node\failures += 1
        if: node\failures >= 2
            node\until := now + 5
        return: 0
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. request(): int возвращает 1 только при семантическом успехе, 0 при отказе; now — монотонное время из хоста. Провайдер завершает одну попытку до возврата; тест подаёт последовательность 0,0,1. Все три реализации вызываются последовательно одним владельцем.

[Отдельный листинг](examples/lmx/038_circuit_breaker.lm3)

## Go

```go
type Breaker struct { failures, until int }
func (b *Breaker) Invoke(now int, request func() int) int {
    if now < b.until { return -1 }
    if request() == 1 { b.failures = 0; b.until = 0; return 1 }
    b.failures++
    if b.failures >= 2 { b.until = now + 5 }
    return 0
}
```

request(): int возвращает 1 только при семантическом успехе, 0 при отказе; now — монотонное время из хоста. Провайдер завершает одну попытку до возврата; тест подаёт последовательность 0,0,1. Все три реализации вызываются последовательно одним владельцем. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/038_circuit_breaker.go)

## C#

```csharp
sealed class Breaker {
    int failures, until;
    public int Invoke(int now, System.Func<int> request) {
        if (now < until) return -1;
        if (request() == 1) { failures = 0; until = 0; return 1; }
        failures++;
        if (failures >= 2) until = now + 5;
        return 0;
    }
}
```

request(): int возвращает 1 только при семантическом успехе, 0 при отказе; now — монотонное время из хоста. Провайдер завершает одну попытку до возврата; тест подаёт последовательность 0,0,1. Все три реализации вызываются последовательно одним владельцем. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/038_circuit_breaker.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. request(): int возвращает 1 только при семантическом успехе, 0 при отказе; now — монотонное время из хоста. Провайдер завершает одну попытку до возврата; тест подаёт последовательность 0,0,1. Все три реализации вызываются последовательно одним владельцем.

## Сопоставление

LMX выражает автомат состоянием Message; Go и C# используют состояние экземпляра. Единственная проба обеспечивается выбранным последовательным контрактом, а не атомарной проверкой общего флага.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 216 | 18 |
| Go | 205 | 8 |
| C# | 200 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

After two consecutive failures the owner temporarily rejects calls, then admits a recovery probe.

**Scenario.** Calls at times 0 and 1 fail; the call at 2 must be rejected; the probe at 6 succeeds.

**Expected observation.** Results are 0, 0, -1, 1; three provider calls; the successful probe resets the failure count.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. request(): int returns 1 only for semantic success and 0 for failure; now is host monotonic time. One attempt completes before return; the fixture supplies 0,0,1. All three implementations are called serially by one owner.

**Comparison.** LMX stores the machine in a Message; Go and C# use an instance. The serial contract, rather than a shared atomic flag, permits only one recovery probe at a time.

**Scope and limitations.** This is a consecutive-failure breaker. Windowed statistics, concurrent in-flight calls, error classification and per-attempt deadlines require an extended profile.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. request(): int returns 1 only for semantic success and 0 for failure; now is host monotonic time. One attempt completes before return; the fixture supplies 0,0,1. All three implementations are called serially by one owner.
- **Go:** request(): int returns 1 only for semantic success and 0 for failure; now is host monotonic time. One attempt completes before return; the fixture supplies 0,0,1. All three implementations are called serially by one owner. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** request(): int returns 1 only for semantic success and 0 for failure; now is host monotonic time. One attempt completes before return; the fixture supplies 0,0,1. All three implementations are called serially by one owner. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Circuit Breaker](https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker) — После двух последовательных отказов владелец временно запрещает новые обращения и затем допускает пробу.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
