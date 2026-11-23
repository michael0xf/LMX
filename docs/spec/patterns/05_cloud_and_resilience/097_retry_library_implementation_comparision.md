# 097. Retry Library — Implementation

Общий retry сохраняет фактический результат и использует явные retryOn/delay/limit.

**Примеры использования:** [039. Retry](039_retry_comparision.md), [045. Ambassador](045_ambassador_comparision.md)

## Общий сценарий

Первый клиент задаёт 3 попытки и записывающий delay: request возвращает 503,503,200. Второй клиент задаёт 2 попытки без delay: request возвращает 503,200. Также проверить немедленное завершение при 400 и отсутствие повторов при лимите 1.

**Ожидаемое наблюдение:** Первый клиент получает 200 после 3 вызовов и задержек [1,2]. Второй получает 200 после 2 вызовов без задержек. 400 возвращается после первого вызова; при лимите 1 ответ 503 возвращается без delay. Недопустимое число попыток отвергается до request.

**Граница сравнения:** Реализация библиотеки. LMX показывает общий алгоритм с фактическими типами и исходным контекстом. Контрольные реализации сохраняют явно указанный прикладной профиль. Сравнение одного профиля не означает одинакового охвата библиотек или скорости; для полной стоимости прибавляются общие зависимости и runtime каждого языка.

Это полная общая реализация для связанных клиентов всех трёх языков; её стоимость считается один раз отдельно и в суммарной цене компонента.

## LMX

```lmx
FxRetryValue:
    private:
        @: operation
        @: retryOn
        int: limit
        @: delay 0
        @: arguments ()
    required: operation retryOn limit
    return: @
    retry:
        throws: copy(FxThrows\call) FxArity FxPredicate FxRecordArity ReceiverIndex
        if: limit < 1
            throw: FxArity()
        private: int: attempt 1
        while: 1
            private: @: result FxApply\apply(operation; arguments)
            if: attempt = limit
                return: result
            private: @: retryArgs FxTwo\make(result; (attempt FxRecordOperands\record))
            if: FxSeqPredicate\truth(FxApply\apply(retryOn; retryArgs)) = 0
                return: result
            if: delay != 0
                FxApply\apply(delay; FxOne\make((attempt FxRecordOperands\record)))
            attempt += 1

Http503:
    int: status
    int: attempt
    return: int
    retryOn:
        return: status = 503
```

Точное текущее определение FxRetryValue извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся. Http503 — только профиль retryOn(status; attempt), а не второй цикл повторения.

[Отдельный листинг](examples/lmx/097_retry_library_implementation.lm3)

## Go

```go
package retryhelper
func Run(request func() int, attempts int, delay func(int)) int {
    if attempts < 1 || attempts > 31 { panic("attempts") }
    pause := 1
    for attempt := 0; attempt < attempts; attempt++ {
        status := request()
        if status != 503 { return status }
        if attempt + 1 < attempts && delay != nil {
            delay(pause)
            pause *= 2
        }
    }
    return 503
}
```

Полностью реализована собственная библиотечная политика: допускается 1..31 попытка; повторяется только статус 503; остальные статусы возвращаются сразу; delay необязателен и вызывается только между повторяемыми попытками с интервалами 1,2,4. Ограничение 31 сохраняет промежуточный pause в int32. request():int и delay(int):void — поставленные синхронные callbacks; сеть и таймер библиотека не реализует. Ни один callback не должен ждать ответа, для обработки которого нужен следующий turn занятого Message. Все attempt/pause/status являются локалами вызова, не общим mutable состоянием библиотеки. Код не исполнялся LMX runtime/компиляторами контрольных языков.

[Отдельный листинг](examples/go/097_retry_library_implementation.go)

## C#

```csharp
#nullable enable
namespace PatternHelpers {
    public static class RetryLibrary {
        public static int Run(System.Func<int> request, int attempts,
                              System.Action<int>? delay = null) {
            if (attempts < 1 || attempts > 31)
                throw new System.ArgumentOutOfRangeException(nameof(attempts));
            int pause = 1;
            for (int attempt = 0; attempt < attempts; attempt++) {
                int status = request();
                if (status != 503) return status;
                if (attempt + 1 < attempts && delay != null) {
                    delay(pause);
                    pause *= 2;
                }
            }
            return 503;
        }
    }
}
```

Полностью реализована собственная библиотечная политика: допускается 1..31 попытка; повторяется только статус 503; остальные статусы возвращаются сразу; delay необязателен и вызывается только между повторяемыми попытками с интервалами 1,2,4. Ограничение 31 сохраняет промежуточный pause в int32. request():int и delay(int):void — поставленные синхронные callbacks; сеть и таймер библиотека не реализует. Ни один callback не должен ждать ответа, для обработки которого нужен следующий turn занятого Message. Все attempt/pause/status являются локалами вызова, не общим mutable состоянием библиотеки. Код не исполнялся LMX runtime/компиляторами контрольных языков.

[Отдельный листинг](examples/csharp/097_retry_library_implementation.cs)

## Разбор LMX

Точное текущее определение FxRetryValue извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся. Http503 — только профиль retryOn(status; attempt), а не второй цикл повторения.

## Сопоставление

Сравниваются полные собственные реализации одного API, а не импортированный retry с одной стороны и ручной цикл с другой. LMX использует обычный операнд, Go — экспортированную функцию пакета, C# — статический метод. Для двух клиентов библиотека поставляется один раз. Размер клиентов и размер реализации показываются отдельно; их сумма не объявляется меньше исходных автономных листингов. Обобщённая версия 23-Nov сохранена [отдельно](extended_comparisons/097_retry_library_implementation_generalized_comparision.md); она не подменяет эту узкую задачу.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/097_retry_library_implementation_generalized_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 608 | 30 |
| Go | 276 | 14 |
| C# | 420 | 20 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Generic retry preserves the actual result and uses explicit retryOn/delay/limit policies.

**Usage examples:** [039. Retry](039_retry_comparision.md), [045. Ambassador](045_ambassador_comparision.md)

**Scenario.** The first client chooses 3 attempts and a recording delay: request returns 503,503,200. The second chooses 2 attempts without delay: request returns 503,200. Also check immediate completion on 400 and no retry when the limit is 1.

**Expected observation.** The first client receives 200 after 3 calls and delays [1,2]. The second receives 200 after 2 calls without delays. A 400 returns after one call; limit 1 returns 503 without delay. An invalid attempt limit is rejected before request.

**LMX.** The exact current FxRetryValue definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed. Http503 is only the retryOn(status; attempt) profile, not a second retry loop.

**Comparison.** These are complete application implementations of the same API, not an imported retry on one side versus a handwritten loop on another. LMX uses an ordinary operand, Go an exported package function, and C# a static method. The two clients share one library implementation. Client and implementation sizes are reported separately; their sum is not claimed to be smaller than the original standalone listings. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

**Scope and limitations.** LMX shows the common algorithm with actual types and original context. Foreign implementations retain the stated application profile. A comparison for one profile does not establish equal library coverage or speed; complete cost includes shared dependencies and each runtime.

### Dependencies and execution boundaries

- **LMX:** The exact current FxRetryValue definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed. Http503 is only the retryOn(status; attempt) profile, not a second retry loop.
- **Go:** The application-library policy is fully implemented: 1..31 attempts are admitted; only 503 is retried; other statuses return immediately; delay is optional and runs only between retried attempts with intervals 1,2,4. The limit of 31 keeps intermediate pause within int32. request():int and delay(int):void are supplied synchronous callbacks; the library implements neither networking nor a timer. Neither callback may wait for a reply that requires the busy Message to run another turn. All attempt/pause/status values are invocation locals, not shared mutable library state. The code has not been executed by an LMX runtime or control-language compilers.
- **C#:** The application-library policy is fully implemented: 1..31 attempts are admitted; only 503 is retried; other statuses return immediately; delay is optional and runs only between retried attempts with intervals 1,2,4. The limit of 31 keeps intermediate pause within int32. request():int and delay(int):void are supplied synchronous callbacks; the library implements neither networking nor a timer. Neither callback may wait for a reply that requires the busy Message to run another turn. All attempt/pause/status values are invocation locals, not shared mutable library state. The code has not been executed by an LMX runtime or control-language compilers.

## Источники / Sources

- [Microsoft Azure — Retry](https://learn.microsoft.com/en-us/azure/architecture/patterns/retry) — Ограниченный повтор временного отказа с задержкой между попытками.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
