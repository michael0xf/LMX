# 044. Sidecar

Служебная обработка выполняется рядом с приложением в отдельном процессе с общим жизненным циклом.

## Общий сценарий

Приложение посылает запись 7 локальному журналирующему sidecar, который записывает её в sink.

**Ожидаемое наблюдение:** Sink содержит одну запись 7. Завершение deployment закрывает и приложение, и sidecar.

**Граница сравнения:** Протокол и порты. Развёртывание и IPC-кодек заданы контрактом профиля и не реализованы листингом. Без отдельного процесса этот листинг описывает вспомогательный actor, а не полный Sidecar.

## LMX

```lmx
AppMessage:
    int: record
    @: sidecar
    run:
        post:
            ask:
                sidecar\append(record := record)

LogSidecarMessage:
    int: record
    @: sink
    append:
        sink\write(record)
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. sink.write(int): void — поставленный append-only sink. sendLocal/post создаёт письмо, декодируемое sidecar. В LMX sidecar является Message другого процесса и адресуется локальным HTTP endpoint. В Go channel и C# enumerable здесь адаптеры декодированного IPC-входа, а не доказательство отдельного процесса.

[Отдельный листинг](examples/lmx/044_sidecar.lm3)

## Go

```go
func App(record int, sendLocal func(int)) { sendLocal(record) }
func Sidecar(in <-chan int, write func(int)) {
    for record := range in { write(record) }
}
```

sink.write(int): void — поставленный append-only sink. sendLocal/post создаёт письмо, декодируемое sidecar. В LMX sidecar является Message другого процесса и адресуется локальным HTTP endpoint. В Go channel и C# enumerable здесь адаптеры декодированного IPC-входа, а не доказательство отдельного процесса. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/044_sidecar.go)

## C#

```csharp
static void App(int record, System.Action<int> sendLocal) => sendLocal(record);
static void Sidecar(System.Collections.Generic.IEnumerable<int> input,
                    System.Action<int> write) {
    foreach (int record in input) write(record);
}
```

sink.write(int): void — поставленный append-only sink. sendLocal/post создаёт письмо, декодируемое sidecar. В LMX sidecar является Message другого процесса и адресуется локальным HTTP endpoint. В Go channel и C# enumerable здесь адаптеры декодированного IPC-входа, а не доказательство отдельного процесса. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/044_sidecar.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. sink.write(int): void — поставленный append-only sink. sendLocal/post создаёт письмо, декодируемое sidecar. В LMX sidecar является Message другого процесса и адресуется локальным HTTP endpoint. В Go channel и C# enumerable здесь адаптеры декодированного IPC-входа, а не доказательство отдельного процесса.

## Сопоставление

Основной код мал во всех языках; определяющая часть Sidecar — deployment: два процесса/контейнера, общий lifecycle и endpoint. Локальный дочерний Message в одном процессе имеет более слабую изоляцию.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 132 | 12 | 132 |
| Go | 130 | 4 | — |
| C# | 204 | 5 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Auxiliary processing runs beside the application in a separate process with a shared deployment lifecycle.

**Scenario.** The application sends record 7 to a local logging sidecar, which writes it to a sink.

**Expected observation.** The sink contains one record 7. Deployment shutdown closes both app and sidecar.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. sink.write(int): void is a supplied append-only sink. sendLocal/post creates a letter decoded by the sidecar. In LMX the sidecar is a Message in a separate process reached through a local HTTP endpoint. Go channel and C# enumerable represent decoded IPC input, not proof of process isolation.

**Comparison.** The core is small in every language; Sidecar is primarily deployment: two processes/containers, one lifecycle and an endpoint. A child Message in the same process provides weaker isolation.

**Scope and limitations.** Deployment and the IPC codec are specified by the profile contract and are not implemented by the listing. Without a separate process the listing describes an auxiliary actor, not a full Sidecar.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. sink.write(int): void is a supplied append-only sink. sendLocal/post creates a letter decoded by the sidecar. In LMX the sidecar is a Message in a separate process reached through a local HTTP endpoint. Go channel and C# enumerable represent decoded IPC input, not proof of process isolation.
- **Go:** sink.write(int): void is a supplied append-only sink. sendLocal/post creates a letter decoded by the sidecar. In LMX the sidecar is a Message in a separate process reached through a local HTTP endpoint. Go channel and C# enumerable represent decoded IPC input, not proof of process isolation. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** sink.write(int): void is a supplied append-only sink. sendLocal/post creates a letter decoded by the sidecar. In LMX the sidecar is a Message in a separate process reached through a local HTTP endpoint. Go channel and C# enumerable represent decoded IPC input, not proof of process isolation. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Sidecar](https://learn.microsoft.com/en-us/azure/architecture/patterns/sidecar) — Служебная обработка выполняется рядом с приложением в отдельном процессе с общим жизненным циклом.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
