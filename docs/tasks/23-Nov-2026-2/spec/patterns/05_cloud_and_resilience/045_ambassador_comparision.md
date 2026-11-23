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
        throws: Attempts
        import: RetryLibrary
        return: read retry 2
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Сборка включает определение RetryLibrary в доступный граф, после чего обычный import делает retry видимым в методе клиента. Операнд использует готовый sys\OPERANDS_TEMPLATE, режим 0: left ссылается на готовую callable-ссылку, right — на число попыток и необязательную callable-ссылку таймера. Передача request/read/delay не вызывает их; библиотека явно вызывает callbacks. Приложение сохраняет endpoint/route в read, выбирает две попытки и отсутствие delay. read вызывается библиотекой; удалённая операция остаётся синхронным семантическим HTTP-ответом, не ожиданием собственного mailbox. Клиент распространяет объявленный выход Attempts через собственный throws: даже при константном допустимом лимите 3/2 обычный контракт вызова требует catch либо throws; входной harness обрабатывает этот выход. Хост заранее устанавливает готовый provider в AmbassadorMessage\http. read обращается к нему через node\http, поэтому вызов callback из RetryLibrary не зависит от временного http в активации catalog.

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

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int — поставленный провайдер HTTPS с фиксированным идемпотентным read-телом application/lmx. Возврат — статус семантического ответа. Ambassador развёрнут отдельно от клиента на том же хосте; это указано в общем deployment profile. RetryLibrary — собственная прикладная библиотека из сопутствующего примера реализации, не native builtin и не новая гарантия Message. В клиентский подсчёт входит import и использование, а полный код общей библиотеки учитывается отдельно и один раз для двух пользователей. Сборка включает определение RetryLibrary в доступный граф, после чего обычный import делает retry видимым в методе клиента. Операнд использует готовый sys\OPERANDS_TEMPLATE, режим 0: left ссылается на готовую callable-ссылку, right — на число попыток и необязательную callable-ссылку таймера. Передача request/read/delay не вызывает их; библиотека явно вызывает callbacks. Приложение сохраняет endpoint/route в read, выбирает две попытки и отсутствие delay. read вызывается библиотекой; удалённая операция остаётся синхронным семантическим HTTP-ответом, не ожиданием собственного mailbox. Клиент распространяет объявленный выход Attempts через собственный throws: даже при константном допустимом лимите 3/2 обычный контракт вызова требует catch либо throws; входной harness обрабатывает этот выход. Хост заранее устанавливает готовый provider в AmbassadorMessage\http. read обращается к нему через node\http, поэтому вызов callback из RetryLibrary не зависит от временного http в активации catalog.

## Сопоставление

Синхронный договор 22-Nov: конечные завершённые callbacks, retry только по статусу 503. Все три клиента используют полностью показанный helper 097. Его реализация считается один раз отдельно. Асинхронные retryPost/Polly/backoff примеры 23-Nov сохранены отдельно и не смешиваются с этим договором. [Асинхронная пара](extended_comparisons/045_ambassador_async_comparision.md).

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/045_ambassador_async_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 162 | 9 | 162 |
| Go | 177 | 5 | — |
| C# | 167 | 5 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

A local network proxy hides the remote endpoint and retry policy from its client.

**Separate implementation comparison:** [097. Retry Library — Implementation](097_retry_library_implementation_comparision.md)

**Scenario.** The client requests a catalog. The ambassador calls its configured endpoint: first status 503, then 200.

**Expected observation.** The client receives 200; the remote provider is called twice with the same endpoint and route.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. The build includes RetryLibrary in the accessible graph, then ordinary import makes retry visible in the client method. The operand uses the supplied sys\OPERANDS_TEMPLATE in mode 0: left refers to a prepared callable reference; right holds the attempt count and an optional prepared timer callable reference. Passing request/read/delay does not invoke them; the library explicitly calls the callbacks. The application keeps endpoint/route in read and chooses two attempts with no delay. The library invokes read; the remote operation remains a synchronous semantic HTTP reply, not a wait on the owner mailbox. The client propagates the declared Attempts exit through its own throws: even for the valid constant limit 3/2, the ordinary call contract requires catch or throws; the entry harness handles this exit. The host installs the prepared provider in AmbassadorMessage\http beforehand. read uses node\http, so calling the callback from RetryLibrary does not depend on a temporary http in the catalog activation.

**Comparison.** The synchronous 22-Nov contract retries completed callbacks only on status 503. All clients use the complete helper in 097, counted once separately. The wider asynchronous 23-Nov comparison is retained separately.

**Scope and limitations.** Only a safe read is retried. TLS is not hand-implemented; authentication, backoff and metrics belong to the selected provider and policy.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. The build includes RetryLibrary in the accessible graph, then ordinary import makes retry visible in the client method. The operand uses the supplied sys\OPERANDS_TEMPLATE in mode 0: left refers to a prepared callable reference; right holds the attempt count and an optional prepared timer callable reference. Passing request/read/delay does not invoke them; the library explicitly calls the callbacks. The application keeps endpoint/route in read and chooses two attempts with no delay. The library invokes read; the remote operation remains a synchronous semantic HTTP reply, not a wait on the owner mailbox. The client propagates the declared Attempts exit through its own throws: even for the valid constant limit 3/2, the ordinary call contract requires catch or throws; the entry harness handles this exit. The host installs the prepared provider in AmbassadorMessage\http beforehand. read uses node\http, so calling the callback from RetryLibrary does not depend on a temporary http in the catalog activation.
- **Go:** http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Module path example/retryhelper is the build-assigned path of the shown retryhelper package, not a hidden external dependency. The application keeps endpoint/route in read and chooses two attempts with no delay. The library invokes read; the remote operation remains a synchronous semantic HTTP reply, not a wait on the owner mailbox.
- **C#:** http.post(endpoint,route): int is a supplied HTTPS provider carrying a fixed idempotent application/lmx read body. It returns semantic-response status. The ambassador is deployed separately from its client on the same host, as specified by the shared deployment profile. This C# fragment uses supplied delegates; namespace and test entry are shared harness. RetryLibrary is an application library implemented in the companion example, not a native builtin or a new Message guarantee. Client counts include import and use; the complete shared library is counted separately and once for its two consumers. Namespace PatternHelpers contains the adjacent static RetryLibrary implementation, included by the client application. The application keeps endpoint/route in read and chooses two attempts with no delay. The library invokes read; the remote operation remains a synchronous semantic HTTP reply, not a wait on the owner mailbox.

## Источники / Sources

- [Microsoft Azure — Ambassador](https://learn.microsoft.com/en-us/azure/architecture/patterns/ambassador) — Локальный сетевой посредник скрывает внешний endpoint и политику повторов от клиента.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
