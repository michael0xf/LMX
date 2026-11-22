# 097. Retry Library — Implementation

Собственная общая реализация ограниченного повтора HTTP 503 для клиентов Retry и Ambassador.

**Примеры использования:** [039. Retry](039_retry_comparision.md) · [045. Ambassador](045_ambassador_comparision.md)

## Общий сценарий

Первый клиент задаёт 3 попытки и записывающий delay: request возвращает 503,503,200. Второй клиент задаёт 2 попытки без delay: request возвращает 503,200. Также проверить немедленное завершение при 400 и отсутствие повторов при лимите 1.

**Ожидаемое наблюдение:** Первый клиент получает 200 после 3 вызовов и задержек [1,2]. Второй получает 200 после 2 вызовов без задержек. 400 возвращается после первого вызова; при лимите 1 ответ 503 возвращается без delay. Недопустимое число попыток отвергается до request.

**Граница сравнения:** Реализация библиотеки. Это последовательная retry-политика над завершёнными sync callbacks. Нет async post/answer автомата, jitter, общего дедлайна, Retry-After, автоматической идемпотентности, исключений как статусов или устойчивого журнала попыток. Повтор эффекта после неопределённого сетевого исхода остаётся ответственностью приложения.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

## LMX

```lmx
RetryLibrary:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    retry:
        throws: Attempts
        if: length(right) < 1 || length(right) > 2
            throw: Attempts()
        int: limit \right[0]
        if: limit < 1 || limit > 31
            throw: Attempts()
        @: request \left
        int: attempt 0
        int: pause 1
        while: attempt < limit
            int: status request()
            if: status != 503
                return: status
            attempt += 1
            if: attempt < limit && length(right) = 2
                @: wait \right[1]
                wait(pause)
                pause *= 2
        return: 503
```

Полностью реализована собственная библиотечная политика: допускается 1..31 попытка; повторяется только статус 503; остальные статусы возвращаются сразу; delay необязателен и вызывается только между повторяемыми попытками с интервалами 1,2,4. Ограничение 31 сохраняет промежуточный pause в int32. request():int и delay(int):void — поставленные синхронные callbacks; сеть и таймер библиотека не реализует. Ни один callback не должен ждать ответа, для обработки которого нужен следующий turn занятого Message. Все attempt/pause/status являются локалами вызова, не общим mutable состоянием библиотеки. Код не исполнялся LMX runtime/компиляторами контрольных языков. В LMX библиотека копирует предоставленный заголовок sys\OPERANDS_TEMPLATE без повторного объявления его const-полей. Режим 0 передаёт готовые значения: left ссылается на callable-ссылку request; right содержит ссылку на int limit и необязательную callable-ссылку delay. Проверка длины right явная. \left и \right[i] читают готовые значения; последующие request()/wait(pause) выполняют вызовы. sys\eval и режим 1 не нужны. Операнд использует приоритет + из шаблона, конкретный return:int объявлен один раз.

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

Полностью реализована собственная библиотечная политика: допускается 1..31 попытка; повторяется только статус 503; остальные статусы возвращаются сразу; delay необязателен и вызывается только между повторяемыми попытками с интервалами 1,2,4. Ограничение 31 сохраняет промежуточный pause в int32. request():int и delay(int):void — поставленные синхронные callbacks; сеть и таймер библиотека не реализует. Ни один callback не должен ждать ответа, для обработки которого нужен следующий turn занятого Message. Все attempt/pause/status являются локалами вызова, не общим mutable состоянием библиотеки. Код не исполнялся LMX runtime/компиляторами контрольных языков. В LMX библиотека копирует предоставленный заголовок sys\OPERANDS_TEMPLATE без повторного объявления его const-полей. Режим 0 передаёт готовые значения: left ссылается на callable-ссылку request; right содержит ссылку на int limit и необязательную callable-ссылку delay. Проверка длины right явная. \left и \right[i] читают готовые значения; последующие request()/wait(pause) выполняют вызовы. sys\eval и режим 1 не нужны. Операнд использует приоритет + из шаблона, конкретный return:int объявлен один раз.

## Сопоставление

Сравниваются полные собственные реализации одного API, а не импортированный retry с одной стороны и ручной цикл с другой. LMX использует обычный операнд, Go — экспортированную функцию пакета, C# — статический метод. Для двух клиентов библиотека поставляется один раз. Размер клиентов и размер реализации показываются отдельно; их сумма не объявляется меньше исходных автономных листингов.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 363 | 23 |
| Go | 276 | 14 |
| C# | 420 | 20 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A shared application implementation of bounded HTTP-503 retry for the Retry and Ambassador clients.

**Usage examples:** [039. Retry](039_retry_comparision.md) · [045. Ambassador](045_ambassador_comparision.md)

**Scenario.** The first client chooses 3 attempts and a recording delay: request returns 503,503,200. The second chooses 2 attempts without delay: request returns 503,200. Also check immediate completion on 400 and no retry when the limit is 1.

**Expected observation.** The first client receives 200 after 3 calls and delays [1,2]. The second receives 200 after 2 calls without delays. A 400 returns after one call; limit 1 returns 503 without delay. An invalid attempt limit is rejected before request.

**LMX.** The application-library policy is fully implemented: 1..31 attempts are admitted; only 503 is retried; other statuses return immediately; delay is optional and runs only between retried attempts with intervals 1,2,4. The limit of 31 keeps intermediate pause within int32. request():int and delay(int):void are supplied synchronous callbacks; the library implements neither networking nor a timer. Neither callback may wait for a reply that requires the busy Message to run another turn. All attempt/pause/status values are invocation locals, not shared mutable library state. The code has not been executed by an LMX runtime or control-language compilers. LMX copies the supplied sys\OPERANDS_TEMPLATE header without redeclaring its const properties. Mode 0 supplies prepared values: left refers to the request callable reference; right contains a reference to int limit and optionally a delay callable reference. The right-length check is explicit. \left and \right[i] read prepared values; subsequent request()/wait(pause) perform calls. sys\eval and mode 1 are unnecessary. The operand retains the template addition precedence and declares its concrete return:int once.

**Comparison.** These are complete application implementations of the same API, not an imported retry on one side versus a handwritten loop on another. LMX uses an ordinary operand, Go an exported package function, and C# a static method. The two clients share one library implementation. Client and implementation sizes are reported separately; their sum is not claimed to be smaller than the original standalone listings.

**Scope and limitations.** This is a sequential retry policy over completed synchronous callbacks. It provides no asynchronous post/answer state machine, jitter, total deadline, Retry-After, automatic idempotency, exception-to-status conversion or durable attempt log. Retrying an effect after an uncertain network outcome remains application policy.

### Dependencies and execution boundaries

- **LMX:** The application-library policy is fully implemented: 1..31 attempts are admitted; only 503 is retried; other statuses return immediately; delay is optional and runs only between retried attempts with intervals 1,2,4. The limit of 31 keeps intermediate pause within int32. request():int and delay(int):void are supplied synchronous callbacks; the library implements neither networking nor a timer. Neither callback may wait for a reply that requires the busy Message to run another turn. All attempt/pause/status values are invocation locals, not shared mutable library state. The code has not been executed by an LMX runtime or control-language compilers. LMX copies the supplied sys\OPERANDS_TEMPLATE header without redeclaring its const properties. Mode 0 supplies prepared values: left refers to the request callable reference; right contains a reference to int limit and optionally a delay callable reference. The right-length check is explicit. \left and \right[i] read prepared values; subsequent request()/wait(pause) perform calls. sys\eval and mode 1 are unnecessary. The operand retains the template addition precedence and declares its concrete return:int once.
- **Go:** The application-library policy is fully implemented: 1..31 attempts are admitted; only 503 is retried; other statuses return immediately; delay is optional and runs only between retried attempts with intervals 1,2,4. The limit of 31 keeps intermediate pause within int32. request():int and delay(int):void are supplied synchronous callbacks; the library implements neither networking nor a timer. Neither callback may wait for a reply that requires the busy Message to run another turn. All attempt/pause/status values are invocation locals, not shared mutable library state. The code has not been executed by an LMX runtime or control-language compilers.
- **C#:** The application-library policy is fully implemented: 1..31 attempts are admitted; only 503 is retried; other statuses return immediately; delay is optional and runs only between retried attempts with intervals 1,2,4. The limit of 31 keeps intermediate pause within int32. request():int and delay(int):void are supplied synchronous callbacks; the library implements neither networking nor a timer. Neither callback may wait for a reply that requires the busy Message to run another turn. All attempt/pause/status values are invocation locals, not shared mutable library state. The code has not been executed by an LMX runtime or control-language compilers.

## Источники / Sources

- [Microsoft Azure — Retry](https://learn.microsoft.com/en-us/azure/architecture/patterns/retry) — Ограниченный повтор временного отказа с задержкой между попытками.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
