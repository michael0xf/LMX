# 045. Ambassador

Локальный сетевой посредник скрывает внешний endpoint и политику повторов от клиента.

**Отдельное сравнение реализации:** [097. Retry Library — Implementation](097_retry_library_implementation_comparision.md)

## Общий сценарий

Клиент просит получить каталог. Ambassador обращается к заданному endpoint: первый результат 503, второй 200.

**Ожидаемое наблюдение:** Клиент получает 200; внешний провайдер вызван дважды, с одним и тем же endpoint/route.

**Граница сравнения:** Использование библиотеки. Пример повторяет только безопасное чтение. TLS не реализуется вручную; auth, backoff и метрики — обязательства выбранного провайдера/политики.

Все клиенты этой узкой пары используют полностью показанный общий компонент из связанной строки реализации. Он учитывается один раз отдельно; асинхронный библиотечный клиент имеет собственный договор.

## LMX

```lmx
AmbassadorMessage:
    @: http
    return: int
    read:
        return: node\http\post("https://catalog.example"; "/catalog/read")
    catalog:
        throws: copy(FxThrows\call) FxArity FxPredicate FxRecordArity ReceiverIndex
        return: retry(read; Http503\retryOn; 2)
```

retry использует общий алгоритм с Http503 как явной политикой и двумя попытками. Endpoint и route остаются в read; отсутствие delay передано обычным пропуском аргумента. read получает установленный provider через node\http, поэтому промежуточные вызовы не подменяют его. Результат сохраняет фактический int-профиль клиента. Асинхронный retryPost остаётся другой операцией с Message job и отдельным жизненным циклом.

[Отдельный листинг](examples/lmx/045_ambassador.lm3)

## Go

```go
import "example/retryhelper"
func Ambassador(post func(string, string) int) int {
    read := func() int { return post("https://catalog.example", "/catalog/read") }
    return retryhelper.Run(read, 2, nil)
}
```

http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Module path example/retryhelper — заданное в сборке имя показанного package retryhelper; это не внешняя скрытая зависимость. Приложение сохраняет endpoint/route в read, выбирает две попытки и отсутствие delay. read вызывается библиотекой; удалённая операция остаётся синхронным семантическим HTTP-ответом, не ожиданием собственного mailbox.

[Отдельный листинг](examples/go/045_ambassador.go)

## C#

```csharp
using PatternHelpers;
static int Ambassador(System.Func<string,string,int> post) {
    int Read() => post("https://catalog.example", "/catalog/read");
    return RetryLibrary.Run(Read, 2);
}
```

http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Namespace PatternHelpers содержит показанный рядом статический RetryLibrary; клиентское приложение включает эту реализацию. Приложение сохраняет endpoint/route в read, выбирает две попытки и отсутствие delay. read вызывается библиотекой; удалённая операция остаётся синхронным семантическим HTTP-ответом, не ожиданием собственного mailbox.

[Отдельный листинг](examples/csharp/045_ambassador.cs)

## Разбор LMX

retry использует общий алгоритм с Http503 как явной политикой и двумя попытками. Endpoint и route остаются в read; отсутствие delay передано обычным пропуском аргумента. read получает установленный provider через node\http, поэтому промежуточные вызовы не подменяют его. Результат сохраняет фактический int-профиль клиента. Асинхронный retryPost остаётся другой операцией с Message job и отдельным жизненным циклом.

## Сопоставление

Синхронный договор 22-Nov: конечные завершённые callbacks, retry только по статусу 503. Все три клиента используют полностью показанный helper 097. Его реализация считается один раз отдельно. Асинхронные retryPost/Polly/backoff примеры 23-Nov сохранены отдельно и не смешиваются с этим договором. [Асинхронная пара](extended_comparisons/045_ambassador_async_comparision.md). Реализация LMX общая и обобщённая; контрольный клиент сохраняет оговорённый прикладной профиль. Это не утверждение равного полного охвата стандартных библиотек.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/045_ambassador_async_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 217 | 8 |
| Go | 177 | 5 |
| C# | <span style="color:#176233"><u>167</u></span> | 5 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A local network proxy hides the remote endpoint and retry policy from its client.

**Separate implementation comparison:** [097. Retry Library — Implementation](097_retry_library_implementation_comparision.md)

**Scenario.** The client requests a catalog. The ambassador calls its configured endpoint: first status 503, then 200.

**Expected observation.** The client receives 200; the remote provider is called twice with the same endpoint and route.

**LMX.** retry uses the common algorithm with an explicit Http503 policy and two attempts. Endpoint and route remain in read; delay is omitted by ordinary argument rules. read accesses the installed provider through node\http across intermediate calls. The client's actual int result profile is preserved. Asynchronous retryPost remains a different Message job operation.

**Comparison.** The synchronous 22-Nov contract retries completed callbacks only on status 503. All clients use the complete helper in 097, counted once separately. The wider asynchronous 23-Nov comparison is retained separately. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

**Scope and limitations.** Only a safe read is retried. TLS is not hand-implemented; authentication, backoff and metrics belong to the selected provider and policy.

### Dependencies and execution boundaries

- **LMX:** retry uses the common algorithm with an explicit Http503 policy and two attempts. Endpoint and route remain in read; delay is omitted by ordinary argument rules. read accesses the installed provider through node\http across intermediate calls. The client's actual int result profile is preserved. Asynchronous retryPost remains a different Message job operation.
- **Go:** http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Module path example/retryhelper is the build-assigned path of the shown retryhelper package, not a hidden external dependency. The application keeps endpoint/route in read and chooses two attempts with no delay. The library invokes read; the remote operation remains a synchronous semantic HTTP reply, not a wait on the owner mailbox.
- **C#:** http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. This C# fragment uses supplied delegates; namespace and test entry are shared harness. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Namespace PatternHelpers contains the adjacent static RetryLibrary implementation, included by the client application. The application keeps endpoint/route in read and chooses two attempts with no delay. The library invokes read; the remote operation remains a synchronous semantic HTTP reply, not a wait on the owner mailbox.

## Источники / Sources

- [Microsoft Azure — Ambassador](https://learn.microsoft.com/en-us/azure/architecture/patterns/ambassador) — Локальный сетевой посредник скрывает внешний endpoint и политику повторов от клиента.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
