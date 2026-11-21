# 039. Retry

Ограниченный повтор временного отказа с задержкой между попытками.

## Общий сценарий

Идемпотентное чтение возвращает 503,503,200. Разрешены три попытки и задержки 1,2 единицы.

**Ожидаемое наблюдение:** Итог 200; три обращения и две задержки. Статус 400 прекращает повторы сразу.

**Граница сравнения:** Протокол и порты. Дедлайн, jitter, Retry-After и защита неидемпотентных операций не реализованы. Повтор после timeout может дублировать уже выполненный эффект.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
RetryMessage:
    @: request
    @: delay
    return: int
    run:
        int: attempt 0
        int: pause 1
        while: attempt < 3
            int: status request()
            if: status != 503
                return: status
            attempt += 1
            if: attempt < 3
                delay(pause)
                pause *= 2
        return: 503
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. request(): int — одна завершённая синхронная HTTP попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца. Для post request/reply применяется событийный автомат с отдельным answer turn, как в P54; данный sync provider не ждёт собственного mailbox.

[Отдельный листинг](examples/lmx/039_retry.lm3)

## Go

```go
func Retry(request func() int, delay func(int)) int {
    pause := 1
    for attempt := 0; attempt < 3; attempt++ {
        status := request()
        if status != 503 { return status }
        if attempt < 2 { delay(pause); pause *= 2 }
    }
    return 503
}
```

request(): int — одна завершённая синхронная HTTP попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой. Для post request/reply применяется событийный автомат с отдельным answer turn, как в P54; данный sync provider не ждёт собственного mailbox.

[Отдельный листинг](examples/go/039_retry.go)

## C#

```csharp
static int Retry(System.Func<int> request, System.Action<int> delay) {
    int pause = 1;
    for (int attempt = 0; attempt < 3; attempt++) {
        int status = request();
        if (status != 503) return status;
        if (attempt < 2) { delay(pause); pause *= 2; }
    }
    return 503;
}
```

request(): int — одна завершённая синхронная HTTP попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой. Для post request/reply применяется событийный автомат с отдельным answer turn, как в P54; данный sync provider не ждёт собственного mailbox.

[Отдельный листинг](examples/csharp/039_retry.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. request(): int — одна завершённая HTTP/Message попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца.

## Сопоставление

Алгоритм почти одинаков: собственная почта LMX не добавляет автоматический retry. Задержки и предел явно заданы приложением.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 178 | 16 |
| Go | 177 | 9 |
| C# | 210 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Bounded retry of a transient failure with delay between attempts.

**Scenario.** An idempotent read returns 503,503,200. Allow three attempts and delays of 1 and 2 units.

**Expected observation.** Final status 200; three calls and two delays. Status 400 stops retries immediately.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. request(): int is one completed HTTP/Message attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn.

**Comparison.** The algorithm is nearly identical: LMX mail does not add automatic retry. Delays and attempt limits are application policy.

**Scope and limitations.** Deadline, jitter, Retry-After and non-idempotent-operation protection are outside this core. Retrying after timeout may duplicate an already completed effect.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox.
- **Go:** request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox.
- **C#:** request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. This C# fragment uses supplied delegates; namespace and test entry are shared harness. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox.

## Источники / Sources

- [Microsoft Azure — Retry](https://learn.microsoft.com/en-us/azure/architecture/patterns/retry) — Ограниченный повтор временного отказа с задержкой между попытками.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
