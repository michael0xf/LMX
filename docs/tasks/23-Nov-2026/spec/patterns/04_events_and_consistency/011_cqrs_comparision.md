# 011. CQRS

Разделить модель команды и модель чтения.

## Общий сценарий

WriteMessage принимает add(5). Пока событие не доставлено, ReadMessage возвращает 0. После доставки проекции она возвращает 5.

**Ожидаемое наблюдение:** Команда меняет write-state и отправляет snapshot=5; query до доставки даёт 0, после доставки — 5. Query не вызывает командный метод.

**Граница сравнения:** Протокол и порты. В примере один писатель и FIFO-доставка без потерь/дубликатов. Durable outbox, восстановление и версия проекции нужны отдельно для crash-safe развёртывания; отдельные методы GET/POST при общей модели сами по себе ещё не CQRS.

## LMX

```lmx
WriteMessage:
    int: balance 0
    int: amount
    @: transport
    add:
        throws: Amount
        if: amount < 0
            throw: Amount()
        node\balance += amount
        node\transport\publish(node\balance)

ReadMessage:
    int: visible 0
    int: snapshot
    return: int
    apply:
        node\visible := snapshot
        return: query()
    query:
        return: node\visible
```

WriteMessage и ReadMessage — шаблоны двух отдельных исполняемых Message. transport.publish(snapshot) — явный адаптер к post/Message, с единственным получателем проекции. Он может использовать HTTP §32 с application/lmx и корреляцией; это не отсутствующая в LMX возможность.

[Отдельный листинг](examples/lmx/011_cqrs.lm3)

## Java

```java
import java.util.function.IntConsumer;
final class WriteModel {
    private int balance;
    private final IntConsumer publish;
    WriteModel(IntConsumer publish) { this.publish=publish; }
    void add(int amount) {
        if (amount<0) throw new IllegalArgumentException("amount");
        balance+=amount;
        publish.accept(balance);
    }
}
final class ReadModel {
    private int visible;
    int apply(int snapshot) { visible=snapshot; return visible; }
    int query() { return visible; }
}
```

В примере один писатель и FIFO-доставка без потерь/дубликатов. Durable outbox, восстановление и версия проекции нужны отдельно для crash-safe развёртывания; отдельные методы GET/POST при общей модели сами по себе ещё не CQRS.

[Отдельный листинг](examples/java/011_cqrs.java)

## Go

```go
package patterns
import "fmt"
type WriteModel struct { Balance int; Publish func(int) }
func (w *WriteModel) Add(amount int) error {
    if amount < 0 { return fmt.Errorf("amount") }
    w.Balance += amount
    w.Publish(w.Balance)
    return nil
}
type ReadModel struct { Visible int }
func (r *ReadModel) Apply(snapshot int) int { r.Visible=snapshot; return r.Visible }
func (r *ReadModel) Query() int { return r.Visible }
```

В примере один писатель и FIFO-доставка без потерь/дубликатов. Durable outbox, восстановление и версия проекции нужны отдельно для crash-safe развёртывания; отдельные методы GET/POST при общей модели сами по себе ещё не CQRS.

[Отдельный листинг](examples/go/011_cqrs.go)

## Разбор LMX

WriteMessage и ReadMessage — шаблоны двух отдельных исполняемых Message. transport.publish(snapshot) — явный адаптер к post/Message, с единственным получателем проекции. Он может использовать HTTP §32 с application/lmx и корреляцией; это не отсутствующая в LMX возможность.

## Сопоставление

Все листинги показывают обработчики двух последовательных владельцев и порт доставки; runtime запуска/сеть не входят в длину. CQRS допускает синхронную проекцию, но здесь специально показано окно eventual consistency.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 257 | 19 |
| Java | 395 | 16 |
| Go | 347 | 12 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Separate the command model from the read model.

**Scenario.** WriteMessage accepts add(5). ReadMessage returns 0 before projection delivery and 5 after delivery.

**Expected observation.** The command updates write-state and emits snapshot 5; queries observe 0 then 5 without calling command behavior.

**LMX.** The two templates are launched as separate executing Messages. transport.publish is an explicit post/Message adapter to the projection. It can use the existing HTTP application/lmx profile and correlation.

**Comparison.** Every listing contains two serial owners and a delivery port, excluding runtime startup and networking. The example deliberately exposes an eventual-consistency window.

**Scope and limitations.** One writer and FIFO delivery without loss/duplicates are assumed. Durable outbox, recovery and projection versioning are separate requirements; separate GET/POST methods over one model do not alone establish CQRS.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** The two templates are launched as separate executing Messages. transport.publish is an explicit post/Message adapter to the projection. It can use the existing HTTP application/lmx profile and correlation.
- **Java:** One writer and FIFO delivery without loss/duplicates are assumed. Durable outbox, recovery and projection versioning are separate requirements; separate GET/POST methods over one model do not alone establish CQRS.
- **Go:** One writer and FIFO delivery without loss/duplicates are assumed. Durable outbox, recovery and projection versioning are separate requirements; separate GET/POST methods over one model do not alone establish CQRS.

## Источники / Sources

- [Martin Fowler — CQRS](https://martinfowler.com/bliki/CQRS.html) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
