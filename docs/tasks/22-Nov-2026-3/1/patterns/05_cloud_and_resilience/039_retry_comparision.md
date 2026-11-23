# 039. Retry

Ограниченный повтор временного отказа с задержкой между попытками.

**Реализация используемого компонента:** [097. Retry Library — Implementation](097_retry_library_implementation_comparision.md)

## Общий сценарий

Идемпотентное чтение возвращает 503,503,200. Разрешены три попытки и задержки 1,2 единицы.

**Ожидаемое наблюдение:** Итог 200; три обращения и две задержки. Статус 400 прекращает повторы сразу.

**Граница сравнения:** Использование библиотеки. Дедлайн, jitter, Retry-After и защита неидемпотентных операций не реализованы. Повтор после timeout может дублировать уже выполненный эффект.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

```lmx
RetryMessage:
    @: request
    @: delay
    return: int
    run:
        throws: Attempts
        import: RetryLibrary
        return: request retry 3 delay
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. request(): int — одна завершённая синхронная HTTP попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца. Для post request/reply применяется событийный автомат с отдельным answer turn, как в P54; данный sync provider не ждёт собственного mailbox. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Сборка включает определение RetryLibrary в доступный граф, после чего обычный import делает retry видимым в методе клиента. Операнд использует готовый sys\OPERANDS_TEMPLATE, режим 0: left ссылается на готовую callable-ссылку, right — на число попыток и необязательную callable-ссылку таймера. Передача request/read/delay не вызывает их; библиотека явно вызывает callbacks. Приложение выбирает три попытки и supplied delay; общая политика повторяет только 503 и вызывает delay с 1, затем 2. Клиент распространяет объявленный выход Attempts через собственный throws: даже при константном допустимом лимите 3/2 обычный контракт вызова требует catch либо throws; входной harness обрабатывает этот выход.

[Отдельный листинг](examples/lmx/039_retry.lm3)

## Go

```go
import "example/retryhelper"
func Retry(request func() int, delay func(int)) int {
    return retryhelper.Run(request, 3, delay)
}
```

request(): int — одна завершённая синхронная HTTP попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой. Для post request/reply применяется событийный автомат с отдельным answer turn, как в P54; данный sync provider не ждёт собственного mailbox. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Module path example/retryhelper — заданное в сборке имя показанного package retryhelper; это не внешняя скрытая зависимость. Приложение выбирает три попытки и supplied delay; общая политика повторяет только 503 и вызывает delay с 1, затем 2.

[Отдельный листинг](examples/go/039_retry.go)

## C#

```csharp
using PatternHelpers;
static int Retry(System.Func<int> request, System.Action<int> delay) {
    return RetryLibrary.Run(request, 3, delay);
}
```

request(): int — одна завершённая синхронная HTTP попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой. Для post request/reply применяется событийный автомат с отдельным answer turn, как в P54; данный sync provider не ждёт собственного mailbox. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Namespace PatternHelpers содержит показанный рядом статический RetryLibrary; клиентское приложение включает эту реализацию. Приложение выбирает три попытки и supplied delay; общая политика повторяет только 503 и вызывает delay с 1, затем 2.

[Отдельный листинг](examples/csharp/039_retry.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. request(): int — одна завершённая синхронная HTTP попытка идемпотентного чтения, возвращающая статус; delay(int): void — хостовый таймер. В тесте delay записывает интервалы. В LMX работа выполняется отдельным Message, ожидание не запускает параллельный turn того же владельца. Для post request/reply применяется событийный автомат с отдельным answer turn, как в P54; данный sync provider не ждёт собственного mailbox. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Сборка включает определение RetryLibrary в доступный граф, после чего обычный import делает retry видимым в методе клиента. Операнд использует готовый sys\OPERANDS_TEMPLATE, режим 0: left ссылается на готовую callable-ссылку, right — на число попыток и необязательную callable-ссылку таймера. Передача request/read/delay не вызывает их; библиотека явно вызывает callbacks. Приложение выбирает три попытки и supplied delay; общая политика повторяет только 503 и вызывает delay с 1, затем 2. Клиент распространяет объявленный выход Attempts через собственный throws: даже при константном допустимом лимите 3/2 обычный контракт вызова требует catch либо throws; входной harness обрабатывает этот выход.

## Сопоставление

Во всех трёх языках это клиент одного и того же готового helper: приложение задаёт операцию, три попытки и таймер. LMX выражает применение обычным пользовательским операндом с подготовленными ссылками, Go/C# — вызовом функции. Полный цикл и backoff вынесены в отдельный сравниваемый пример реализации общей библиотеки; собственная почта LMX не добавляет автоматический retry.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 102 | 8 |
| Go | 112 | 4 |
| C# | 125 | 4 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Bounded retry of a transient failure with delay between attempts.

**Implementation of the supplied component:** [097. Retry Library — Implementation](097_retry_library_implementation_comparision.md)

**Scenario.** An idempotent read returns 503,503,200. Allow three attempts and delays of 1 and 2 units.

**Expected observation.** Final status 200; three calls and two delays. Status 400 stops retries immediately.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. The build includes RetryLibrary in the accessible graph, then ordinary import makes retry visible in the client method. The operand uses the supplied sys\OPERANDS_TEMPLATE in mode 0: left refers to a prepared callable reference; right holds the attempt count and an optional prepared timer callable reference. Passing request/read/delay does not invoke them; the library explicitly calls the callbacks. The application chooses three attempts and supplies delay; the shared policy retries only 503 and calls delay with 1, then 2. The client propagates the declared Attempts exit through its own throws: even for the valid constant limit 3/2, the ordinary call contract requires catch or throws; the entry harness handles this exit.

**Comparison.** All three languages show clients of the same ready helper: the application selects the operation, three attempts and timer. LMX uses an ordinary user operand with prepared references; Go/C# use a function call. The complete loop and backoff appear in a separately compared shared-library implementation; LMX mail does not add automatic retry.

**Scope and limitations.** Deadline, jitter, Retry-After and non-idempotent-operation protection are outside this core. Retrying after timeout may duplicate an already completed effect.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. The build includes RetryLibrary in the accessible graph, then ordinary import makes retry visible in the client method. The operand uses the supplied sys\OPERANDS_TEMPLATE in mode 0: left refers to a prepared callable reference; right holds the attempt count and an optional prepared timer callable reference. Passing request/read/delay does not invoke them; the library explicitly calls the callbacks. The application chooses three attempts and supplies delay; the shared policy retries only 503 and calls delay with 1, then 2. The client propagates the declared Attempts exit through its own throws: even for the valid constant limit 3/2, the ordinary call contract requires catch or throws; the entry harness handles this exit.
- **Go:** request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Module path example/retryhelper is the build-assigned path of the shown retryhelper package, not a hidden external dependency. The application chooses three attempts and supplies delay; the shared policy retries only 503 and calls delay with 1, then 2.
- **C#:** request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. This C# fragment uses supplied delegates; namespace and test entry are shared harness. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Namespace PatternHelpers contains the adjacent static RetryLibrary implementation, included by the client application. The application chooses three attempts and supplies delay; the shared policy retries only 503 and calls delay with 1, then 2.

## Источники / Sources

- [Microsoft Azure — Retry](https://learn.microsoft.com/en-us/azure/architecture/patterns/retry) — Ограниченный повтор временного отказа с задержкой между попытками.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
