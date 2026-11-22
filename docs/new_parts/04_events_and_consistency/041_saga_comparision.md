# 041. Saga

Координировать локальные действия и явную компенсацию при отказе.

## Общий сценарий

Заказ посылает Reserve, получает Reserved(true), посылает Charge, получает Charged(false), посылает Release и получает Released(true). Повторить каждый ответ.

**Ожидаемое наблюдение:** Состояния 0→1→2→3→4; действия reserve,charge,release,failed выполняются по одному разу. Дубликаты уже обработанных фаз не порождают действия. Успешный Charge переводит в 5 и даёт done.

**Граница сравнения:** Протокол и порты. Показан детерминированный протокольный core без сбоев процесса. Для production состояние и outgoing action сохраняются атомарно, участники идемпотентны, таймауты/повторы/ошибка компенсации требуют политики. HTTP-профиль переносит те же Messages.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
SagaMessage:
    int: phase 0
    int: kind
    int: ok
    @: transport
    handle:
        int: action 0
        if: kind = 0 && node\phase = 0
            node\phase := 1
            action := 1
        if: kind = 1 && node\phase = 1
            if: ok
                node\phase := 2
                action := 2
            else:
                node\phase := 4
                action := 4
        if: kind = 2 && node\phase = 2
            if: ok
                node\phase := 5
                action := 5
            else:
                node\phase := 3
                action := 3
        if: kind = 3 && node\phase = 3 && ok
            node\phase := 4
            action := 4
        if: action != 0
            node\transport\publish(action)
```

SagaMessage — отдельный владелец. kind=0 start,1 reserved,2 charged,3 released; ok=0/1. transport.publish(action) посылает обычный Message с saga-id и командой участнику. Номера действий описаны в общей фикстуре: 1 reserve,2 charge,3 release,4 failed,5 done.

[Отдельный листинг](examples/lmx/041_saga.lm3)

## Java

```java
import java.util.function.IntConsumer;
final class Saga {
    private int phase;
    private final IntConsumer publish;
    Saga(IntConsumer publish) { this.publish=publish; }
    void handle(int kind,boolean ok) {
        int action=0;
        if (kind==0 && phase==0) { phase=1; action=1; }
        if (kind==1 && phase==1) {
            if (ok) { phase=2; action=2; } else { phase=4; action=4; }
        }
        if (kind==2 && phase==2) {
            if (ok) { phase=5; action=5; } else { phase=3; action=3; }
        }
        if (kind==3 && phase==3 && ok) { phase=4; action=4; }
        if (action!=0) publish.accept(action);
    }
}
```

Показан детерминированный протокольный core без сбоев процесса. Для production состояние и outgoing action сохраняются атомарно, участники идемпотентны, таймауты/повторы/ошибка компенсации требуют политики. HTTP-профиль переносит те же Messages.

[Отдельный листинг](examples/java/041_saga.java)

## Go

```go
package patterns
type Saga struct { Phase int; Publish func(int) }
func (s *Saga) Handle(kind int,ok bool) {
    action:=0
    if kind==0 && s.Phase==0 { s.Phase=1; action=1 }
    if kind==1 && s.Phase==1 {
        if ok { s.Phase=2; action=2 } else { s.Phase=4; action=4 }
    }
    if kind==2 && s.Phase==2 {
        if ok { s.Phase=5; action=5 } else { s.Phase=3; action=3 }
    }
    if kind==3 && s.Phase==3 && ok { s.Phase=4; action=4 }
    if action!=0 { s.Publish(action) }
}
```

Показан детерминированный протокольный core без сбоев процесса. Для production состояние и outgoing action сохраняются атомарно, участники идемпотентны, таймауты/повторы/ошибка компенсации требуют политики. HTTP-профиль переносит те же Messages.

[Отдельный листинг](examples/go/041_saga.go)

## Разбор LMX

SagaMessage — отдельный владелец. kind=0 start,1 reserved,2 charged,3 released; ok=0/1. transport.publish(action) посылает обычный Message с saga-id и командой участнику. Номера действий описаны в общей фикстуре: 1 reserve,2 charge,3 release,4 failed,5 done.

## Сопоставление

Во всех трёх листингах одинаковый конечный автомат, работающий в последовательной полосе владельца. Компенсация — отдельное бизнес-действие, а не автоматический rollback графа или distributed transaction.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 355 | 29 |
| Java | 452 | 18 |
| Go | 359 | 14 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Coordinate local actions and an explicit compensating action.

**Scenario.** Start, Reserved(true), Charged(false), Released(true), duplicating each reply. A separate successful charge path is also tested.

**Expected observation.** States are 0→1→2→3→4 and actions reserve,charge,release,failed each occur once. Duplicates produce no action. Successful charge reaches state 5 and emits done.

**LMX.** SagaMessage is one owner. kind 0/1/2/3 means start/reserved/charged/released; ok is 0/1. The explicit transport port sends a Message containing saga-id and action: 1 reserve,2 charge,3 release,4 failed,5 done.

**Comparison.** All listings implement the same serial finite-state machine. Compensation is a separate business action, not graph rollback or a distributed transaction.

**Scope and limitations.** This deterministic protocol core excludes process crashes. Production requires atomic persistence of state/outgoing action, idempotent participants, retry/timeouts and compensation-failure policy. The existing HTTP profile carries the same Messages.

### Dependencies and execution boundaries

- **LMX:** SagaMessage is one owner. kind 0/1/2/3 means start/reserved/charged/released; ok is 0/1. The explicit transport port sends a Message containing saga-id and action: 1 reserve,2 charge,3 release,4 failed,5 done.
- **Java:** This deterministic protocol core excludes process crashes. Production requires atomic persistence of state/outgoing action, idempotent participants, retry/timeouts and compensation-failure policy. The existing HTTP profile carries the same Messages.
- **Go:** This deterministic protocol core excludes process crashes. Production requires atomic persistence of state/outgoing action, idempotent participants, retry/timeouts and compensation-failure policy. The existing HTTP profile carries the same Messages.

## Источники / Sources

- [Chris Richardson — Saga](https://microservices.io/patterns/data/saga.html) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
