# 087. Backpressure

Производитель передаёт элементы только в пределах явно выданного потребителем кредита.

## Общий сценарий

Выдан один credit. Производитель пробует отправить 7 и 8, затем получает новый credit и повторяет 8.

**Ожидаемое наблюдение:** Первый 7 отправлен, первая попытка 8 возвращает 0 без отправки, повтор 8 отправлен. In-flight не превышает 1.

**Граница сравнения:** Протокол и порты. Это минимальный credit protocol, не полная реализация Reactive Streams. Для remote reconnect нужны epoch/sequence и восстановление кредита; иные очереди пути тоже должны иметь предел.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
ProducerMessage:
    int: value
    int: credit 0
    @: consumer
    return: int
    grant:
        node\credit += 1
        return: node\credit
    offer:
        if: node\credit = 0
            return: 0
        node\credit -= 1
        post:
            ask:
                consumer\accept(value := value)
        return: 1
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. grant — запрос потребителя после освобождения одного места, offer — запрос upstream; оба проходят serial owner. consumer.accept(int)/send(int):void принимает ровно один элемент. Grant не дублируется в выбранном надёжном локальном сценарии; после завершения обработки потребитель выдаёт следующий credit.

[Отдельный листинг](examples/lmx/087_backpressure.lm3)

## Go

```go
type Producer struct { credit int; send func(int) }
func (p *Producer) Grant() int { p.credit++; return p.credit }
func (p *Producer) Offer(value int) bool {
    if p.credit == 0 { return false }
    p.credit--; p.send(value); return true
}
```

grant — запрос потребителя после освобождения одного места, offer — запрос upstream; оба проходят serial owner. consumer.accept(int)/send(int):void принимает ровно один элемент. Grant не дублируется в выбранном надёжном локальном сценарии; после завершения обработки потребитель выдаёт следующий credit. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/087_backpressure.go)

## C#

```csharp
sealed class Producer(System.Action<int> send) {
    int credit;
    public int Grant() => ++credit;
    public bool Offer(int value) {
        if (credit == 0) return false;
        credit--; send(value); return true;
    }
}
```

grant — запрос потребителя после освобождения одного места, offer — запрос upstream; оба проходят serial owner. consumer.accept(int)/send(int):void принимает ровно один элемент. Grant не дублируется в выбранном надёжном локальном сценарии; после завершения обработки потребитель выдаёт следующий credit. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/087_backpressure.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. grant — запрос потребителя после освобождения одного места, offer — запрос upstream; оба проходят serial owner. consumer.accept(int)/send(int):void принимает ровно один элемент. Grant не дублируется в выбранном надёжном локальном сценарии; после завершения обработки потребитель выдаёт следующий credit.

## Сопоставление

Кредит ограничивает передачу до заполнения downstream, а не только отказывает после перегрузки. Mailbox LMX сам по себе такого контракта не даёт; он реализован приложением.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 184 | 16 |
| Go | 194 | 6 |
| C# | 166 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A producer sends items only within explicit consumer-issued credit.

**Scenario.** One credit is granted. The producer attempts 7 and 8, receives another credit, and retries 8.

**Expected observation.** 7 is sent; the first attempt at 8 returns 0 without sending; retrying 8 sends it. In-flight stays at most 1.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. grant is sent by the consumer after freeing one slot; offer comes from upstream; both run on the serial owner. consumer.accept(int)/send(int):void admits one item. Credits are not duplicated in this reliable local scenario; completing processing grants the next credit.

**Comparison.** Credit limits sending before downstream fills, rather than rejecting only after overload. The LMX mailbox does not supply this policy automatically; the application implements it.

**Scope and limitations.** This is a minimal credit protocol, not a complete Reactive Streams implementation. Remote reconnect requires epochs/sequences and credit recovery; other queues along the path must also be bounded.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. grant is sent by the consumer after freeing one slot; offer comes from upstream; both run on the serial owner. consumer.accept(int)/send(int):void admits one item. Credits are not duplicated in this reliable local scenario; completing processing grants the next credit.
- **Go:** grant is sent by the consumer after freeing one slot; offer comes from upstream; both run on the serial owner. consumer.accept(int)/send(int):void admits one item. Credits are not duplicated in this reliable local scenario; completing processing grants the next credit. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** grant is sent by the consumer after freeing one slot; offer comes from upstream; both run on the serial owner. consumer.accept(int)/send(int):void admits one item. Credits are not duplicated in this reliable local scenario; completing processing grants the next credit. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Reactive Streams — asynchronous backpressure](https://www.reactive-streams.org/) — Производитель передаёт элементы только в пределах явно выданного потребителем кредита.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
