# 012. Event Sourcing

Восстановить состояние из долговременной последовательности событий.

## Общий сценарий

Журнал содержит дельты 100,20,-5. Восстановить баланс, затем добавить 10 с ожидаемой версией 3 и восстановить заново.

**Ожидаемое наблюдение:** Баланс 115, затем 125. Append со старой версией отвергается; replay не отправляет повторные внешние платежи.

**Граница сравнения:** Протокол и порты. Листинг использует один поток событий без snapshots и schema evolution. Crash durability, checksums и transaction log реализует store. HTTP admission не означает durable append.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
EventMessage:
    @: store
    int: expected
    int: delta
    return: int
    balance:
        @: events node\store\read()
        int: result 0
        int: i 0
        while: i < length(events)
            result += events[i]
            i += 1
        return: result
    append:
        throws: Conflict
        if: !node\store\append(expected; delta)
            throw: Conflict()
        return: balance()
```

EventMessage владеет обработкой команд. store.read() возвращает упорядоченный массив int; append(expected,delta) атомарно проверяет версию и надёжно добавляет событие. Это явный event-store порт, не свойство арены.

[Отдельный листинг](examples/lmx/012_event_sourcing.lm3)

## Java

```java
interface EventStore {
    int[] read();
    boolean append(int expected,int delta);
}
final class EventAccount {
    private final EventStore store;
    EventAccount(EventStore store) { this.store=store; }
    int balance() {
        int result=0;
        for (int delta:store.read()) result+=delta;
        return result;
    }
    int append(int expected,int delta) {
        if (!store.append(expected,delta)) throw new IllegalStateException("conflict");
        return balance();
    }
}
```

Листинг использует один поток событий без snapshots и schema evolution. Crash durability, checksums и transaction log реализует store. HTTP admission не означает durable append.

[Отдельный листинг](examples/java/012_event_sourcing.java)

## Go

```go
package patterns
import "fmt"
type EventStore interface { Read() []int; Append(int,int) bool }
type EventAccount struct { Store EventStore }
func (a *EventAccount) Balance() int {
    result:=0
    for _,delta:=range a.Store.Read() { result+=delta }
    return result
}
func (a *EventAccount) Append(expected,delta int) (int,error) {
    if !a.Store.Append(expected,delta) { return 0,fmt.Errorf("conflict") }
    return a.Balance(),nil
}
```

Листинг использует один поток событий без snapshots и schema evolution. Crash durability, checksums и transaction log реализует store. HTTP admission не означает durable append.

[Отдельный листинг](examples/go/012_event_sourcing.go)

## Разбор LMX

EventMessage владеет обработкой команд. store.read() возвращает упорядоченный массив int; append(expected,delta) атомарно проверяет версию и надёжно добавляет событие. Это явный event-store порт, не свойство арены.

## Сопоставление

Во всех языках состояние является результатом одного fold над журналом. Message сериализует собственные обращения, а version check защищает журнал и от других клиентов.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 248 | 18 |
| Java | 372 | 17 |
| Go | 366 | 13 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Rebuild state from a durable ordered event sequence.

**Scenario.** The stream contains 100,20,-5. Replay, append 10 with expected version 3, and replay again.

**Expected observation.** Balances are 115 then 125. A stale append fails; replay performs no external payments.

**LMX.** EventMessage owns command handling. store.read returns ordered int deltas; append atomically checks version and durably appends. This explicit event-store contract is not an arena property.

**Comparison.** Every version folds the same journal. A serial Message orders its own commands; the version check also protects against other writers.

**Scope and limitations.** One stream only, without snapshots or schema evolution. The store provides durability, checksums and transaction logging. HTTP admission is not durable append.

### Dependencies and execution boundaries

- **LMX:** EventMessage owns command handling. store.read returns ordered int deltas; append atomically checks version and durably appends. This explicit event-store contract is not an arena property.
- **Java:** One stream only, without snapshots or schema evolution. The store provides durability, checksums and transaction logging. HTTP admission is not durable append.
- **Go:** One stream only, without snapshots or schema evolution. The store provides durability, checksums and transaction logging. HTTP admission is not durable append.

## Источники / Sources

- [Martin Fowler — Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
