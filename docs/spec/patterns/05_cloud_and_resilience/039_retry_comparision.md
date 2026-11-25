# 039. Retry

Ограниченный повтор временного отказа с задержкой между попытками.

**Отдельное сравнение реализации:** [097. Retry Library — Implementation](097_retry_library_implementation_comparision.md)

## Общий сценарий

Идемпотентное чтение возвращает 503,503,200. Разрешены три попытки и задержки 1,2 единицы.

**Ожидаемое наблюдение:** Итог 200; три обращения и две задержки. Статус 400 прекращает повторы сразу.

**Граница сравнения:** Использование библиотеки. Дедлайн, jitter, Retry-After и защита неидемпотентных операций не реализованы. Повтор после timeout может дублировать уже выполненный эффект.

Все клиенты этой узкой пары используют полностью показанный общий компонент из связанной строки реализации. Он учитывается один раз отдельно; асинхронный библиотечный клиент имеет собственный договор.

## LMX

```lmx
RetryMessage:
    @: request
    @: delay
    return: int
    Wait:
        int: attempt
        pause:
            delay(1 << (attempt - 1))
    ---
    run:
        throws: copy(FxThrows\call) FxArity FxPredicate FxRecordArity ReceiverIndex
        return: retry(request; Http503\retryOn; 3; delay := Wait\pause)
```

Общий retry принимает callback, предикат повторения, предел и необязательную задержку. Http503 задаёт только доменное условие status = 503; Wait переводит номер завершённой попытки в прежние интервалы 1, 2. Проход, сохранение фактического результата и остановка находятся в ядре. request/read/delay не выполняются при передаче ссылок. Синхронный provider вызывается в отдельном Message и не ждёт собственного mailbox. Это тот же профиль идемпотентного HTTP-чтения, не новая гарантия таймера или scheduler.

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

Общий retry принимает callback, предикат повторения, предел и необязательную задержку. Http503 задаёт только доменное условие status = 503; Wait переводит номер завершённой попытки в прежние интервалы 1, 2. Проход, сохранение фактического результата и остановка находятся в ядре. request/read/delay не выполняются при передаче ссылок. Синхронный provider вызывается в отдельном Message и не ждёт собственного mailbox. Это тот же профиль идемпотентного HTTP-чтения, не новая гарантия таймера или scheduler.

## Сопоставление

Синхронный договор 22-Nov: конечные завершённые callbacks, retry только по статусу 503. Все три клиента используют полностью показанный helper 097. Его реализация считается один раз отдельно. Асинхронные retryPost/Polly/backoff примеры 23-Nov сохранены отдельно и не смешиваются с этим договором. [Асинхронная пара](extended_comparisons/039_retry_async_comparision.md). Реализация LMX общая и обобщённая; контрольный клиент сохраняет оговорённый прикладной профиль. Это не утверждение равного полного охвата стандартных библиотек.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/039_retry_async_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 216 | 12 |
| Go | <span style="color:#176233"><u>112</u></span> | 4 |
| C# | 125 | 4 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Bounded retry of a transient failure with delay between attempts.

**Separate implementation comparison:** [097. Retry Library — Implementation](097_retry_library_implementation_comparision.md)

**Scenario.** An idempotent read returns 503,503,200. Allow three attempts and delays of 1 and 2 units.

**Expected observation.** Final status 200; three calls and two delays. Status 400 stops retries immediately.

**LMX.** Generic retry takes an operation, a retry predicate, a limit and an optional delay. Http503 supplies only status = 503; Wait maps the completed attempt number to the original delays 1 and 2. Traversal, exact result handling and termination belong to the core. Passing callbacks does not execute them. The synchronous provider operates in a separate Message without waiting on its own mailbox; the HTTP idempotent-read boundary is unchanged.

**Comparison.** The synchronous 22-Nov contract retries completed callbacks only on status 503. All clients use the complete helper in 097, counted once separately. The wider asynchronous 23-Nov comparison is retained separately. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

**Scope and limitations.** Deadline, jitter, Retry-After and non-idempotent-operation protection are outside this core. Retrying after timeout may duplicate an already completed effect.

### Dependencies and execution boundaries

- **LMX:** Generic retry takes an operation, a retry predicate, a limit and an optional delay. Http503 supplies only status = 503; Wait maps the completed attempt number to the original delays 1 and 2. Traversal, exact result handling and termination belong to the core. Passing callbacks does not execute them. The synchronous provider operates in a separate Message without waiting on its own mailbox; the HTTP idempotent-read boundary is unchanged.
- **Go:** request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Module path example/retryhelper is the build-assigned path of the shown retryhelper package, not a hidden external dependency. The application chooses three attempts and supplies delay; the shared policy retries only 503 and calls delay with 1, then 2.
- **C#:** request(): int is one completed synchronous HTTP attempt of an idempotent read; delay(int): void is a host timer. The test records delays. In LMX this runs in a separate Message; waiting never starts an overlapping owner turn. This C# fragment uses supplied delegates; namespace and test entry are shared harness. post request/reply requires an event machine with a later answer turn, as in P54; this synchronous provider does not await its own mailbox. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Namespace PatternHelpers contains the adjacent static RetryLibrary implementation, included by the client application. The application chooses three attempts and supplies delay; the shared policy retries only 503 and calls delay with 1, then 2.

## Источники / Sources

- [Microsoft Azure — Retry](https://learn.microsoft.com/en-us/azure/architecture/patterns/retry) — Ограниченный повтор временного отказа с задержкой между попытками.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
