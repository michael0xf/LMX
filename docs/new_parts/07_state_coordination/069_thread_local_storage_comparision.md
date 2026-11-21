# 069. Thread-Local Storage

Изоляция счётчика внутри конкретного исполнителя.

## Общий сценарий

Участник A вызывает next дважды, участник B один раз.

**Ожидаемое наблюдение:** A получает 1,2; B получает 1. В LMX участник — Message; в Java/Rust — OS/Java thread.

**Граница сравнения:** Протокол и порты. Нельзя переносить обещание OS-thread affinity на Message. В Java значение принадлежит потоку, а не автоматически HTTP запросу; в Rust ссылка LocalKey не должна покидать свой контракт жизни.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
CounterMessage:
    int: count 0
    return: int
    next:
        node\count += 1
        return: node\count
```

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Хост создаёт два независимых CounterMessage. Он не использует node-предка как глобальное хранилище. Контрольный harness запускает A и B на разных threads; Java clear вызывается при завершении ограниченного request scope, если поток переиспользуется.

[Отдельный листинг](examples/lmx/069_thread_local_storage.lm3)

## Java

```java
final class LocalCounter {
    private static final ThreadLocal<Integer> count = ThreadLocal.withInitial(() -> 0);
    static int next() {
        int value = count.get() + 1; count.set(value); return value;
    }
    static void clear() { count.remove(); }
}
```

Фрагмент для Java 21; запускающий harness не включён. Хост создаёт два независимых CounterMessage. Он не использует node-предка как глобальное хранилище. Контрольный harness запускает A и B на разных threads; Java clear вызывается при завершении ограниченного request scope, если поток переиспользуется.

[Отдельный листинг](examples/java/069_thread_local_storage.java)

## Rust

```rust
use std::cell::Cell;
thread_local! { static COUNT: Cell<i32> = const { Cell::new(0) }; }
fn next() -> i32 {
    COUNT.with(|count| { let value = count.get() + 1; count.set(value); value })
}
```

Фрагмент Rust использует std; запускающий harness не включён. Хост создаёт два независимых CounterMessage. Он не использует node-предка как глобальное хранилище. Контрольный harness запускает A и B на разных threads; Java clear вызывается при завершении ограниченного request scope, если поток переиспользуется.

[Отдельный листинг](examples/rust/069_thread_local_storage.rs)

## Разбор LMX

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Хост создаёт два независимых CounterMessage. Он не использует node-предка как глобальное хранилище. Контрольный harness запускает A и B на разных threads; Java clear вызывается при завершении ограниченного request scope, если поток переиспользуется.

## Сопоставление

Message-local state сохраняется при миграции turn на другой OS worker. Это полезная альтернатива task/actor-local state, но не тождество TLS: для thread-affine native ресурса нужна именно политика привязки к OS thread.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 70 | 6 |
| Java | 202 | 7 |
| Rust | 157 | 5 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Isolating a counter within one execution participant.

**Scenario.** Participant A calls next twice; participant B calls it once.

**Expected observation.** A receives 1,2; B receives 1. In LMX the participant is a Message; in Java/Rust it is a thread.

**LMX.** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. The host creates two independent CounterMessages; it does not use a lexical ancestor as global storage. The control harness runs A and B on separate threads; Java clear is used at request-scope completion when a worker thread is reused.

**Comparison.** Message-local state survives migration to another OS worker between turns. It is a useful task/actor-local alternative, not literal TLS: thread-affine native resources need an OS-thread-affinity policy.

**Scope and limitations.** OS-thread affinity cannot be inferred for Message. Java values belong to a thread, not automatically an HTTP request; Rust LocalKey references must obey their lifetime contract.

### Dependencies and execution boundaries

- **LMX:** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. The host creates two independent CounterMessages; it does not use a lexical ancestor as global storage. The control harness runs A and B on separate threads; Java clear is used at request-scope completion when a worker thread is reused.
- **Java:** Java 21 fragment; the launching harness is not included. The host creates two independent CounterMessages; it does not use a lexical ancestor as global storage. The control harness runs A and B on separate threads; Java clear is used at request-scope completion when a worker thread is reused.
- **Rust:** Rust fragment using std; the launching harness is not included. The host creates two independent CounterMessages; it does not use a lexical ancestor as global storage. The control harness runs A and B on separate threads; Java clear is used at request-scope completion when a worker thread is reused.

## Источники / Sources

- [Rust — LocalKey](https://doc.rust-lang.org/std/thread/struct.LocalKey.html) — Изоляция счётчика внутри конкретного исполнителя.
- [Java — ThreadLocal](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ThreadLocal.html) — Изоляция счётчика внутри конкретного исполнителя.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
