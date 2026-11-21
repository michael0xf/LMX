# 066. Double-Checked Locking

Безопасная однократная ленивая инициализация при конкурентных обращениях.

## Общий сценарий

Два клиента одновременно запрашивают ресурс; factory строит значение 42 и считает вызовы.

**Ожидаемое наблюдение:** Оба получают 42; factory вызывается один раз. Java использует volatile+DCL, Rust — OnceLock, LMX — единственного владельца.

**Граница сравнения:** Протокол и порты. Не обещается одинаковая цена быстрого пути: LMX клиент отправляет запрос. Reentrant factory, failure/retry и асинхронная инициализация требуют явного состояния initializing и отдельной политики.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
LazyMessage:
    @: build
    int: ready 0
    int: value 0
    return: int
    get:
        if: node\ready = 0
            node\value := build()
            node\ready := 1
        return: node\value
```

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. build():int / IntSupplier / FnOnce — предоставленная синхронная factory, успешно возвращающая 42. Инициализация завершается в одном owner turn; factory не ждёт письма этому же занятому владельцу.

[Отдельный листинг](examples/lmx/066_double_checked_locking.lm3)

## Java

```java
final class Lazy {
    private volatile Integer value;
    private final java.util.function.IntSupplier build;
    Lazy(java.util.function.IntSupplier build) { this.build = build; }
    int get() {
        Integer result = value;
        if (result == null) {
            synchronized (this) {
                result = value;
                if (result == null) value = result = build.getAsInt();
            }
        }
        return result;
    }
}
```

Фрагмент для Java 21; запускающий harness не включён. build():int / IntSupplier / FnOnce — предоставленная синхронная factory, успешно возвращающая 42. Инициализация завершается в одном owner turn; factory не ждёт письма этому же занятому владельцу.

[Отдельный листинг](examples/java/066_double_checked_locking.java)

## Rust

```rust
use std::sync::OnceLock;
struct Lazy { value: OnceLock<i32> }
impl Lazy {
    fn new() -> Self { Self { value: OnceLock::new() } }
    fn get(&self, build: impl FnOnce() -> i32) -> i32 {
        *self.value.get_or_init(build)
    }
}
```

Фрагмент Rust использует std; запускающий harness не включён. build():int / IntSupplier / FnOnce — предоставленная синхронная factory, успешно возвращающая 42. Инициализация завершается в одном owner turn; factory не ждёт письма этому же занятому владельцу.

[Отдельный листинг](examples/rust/066_double_checked_locking.rs)

## Разбор LMX

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. build():int / IntSupplier / FnOnce — предоставленная синхронная factory, успешно возвращающая 42. Инициализация завершается в одном owner turn; factory не ждёт письма этому же занятому владельцу.

## Сопоставление

У LMX отсутствует необходимость двойной проверки, потому что конкурентные клиенты сериализованы у owner. Это смена механизма при той же цели once-only. В Java volatile обязателен для выбранного DCL; Rust использует готовую корректную примитиву.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 117 | 10 |
| Java | 292 | 15 |
| Rust | 179 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Safe once-only lazy initialization under concurrent access.

**Scenario.** Two clients concurrently request a resource; the factory builds 42 and counts invocations.

**Expected observation.** Both receive 42; one factory invocation. Java uses volatile+DCL, Rust OnceLock, and LMX one owner.

**LMX.** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. build():int / IntSupplier / FnOnce is a supplied synchronous factory successfully returning 42. Initialization completes within one owner turn; the factory does not wait for mail to that busy owner.

**Comparison.** LMX needs no double check because concurrent clients serialize at the owner. The mechanism changes while retaining the once-only goal. Java requires volatile for this DCL; Rust uses an established primitive.

**Scope and limitations.** Fast-path costs differ: an LMX client sends a request. Reentrant factories, failure/retry and asynchronous initialization require an explicit initializing state and policy.

### Dependencies and execution boundaries

- **LMX:** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. build():int / IntSupplier / FnOnce is a supplied synchronous factory successfully returning 42. Initialization completes within one owner turn; the factory does not wait for mail to that busy owner.
- **Java:** Java 21 fragment; the launching harness is not included. build():int / IntSupplier / FnOnce is a supplied synchronous factory successfully returning 42. Initialization completes within one owner turn; the factory does not wait for mail to that busy owner.
- **Rust:** Rust fragment using std; the launching harness is not included. build():int / IntSupplier / FnOnce is a supplied synchronous factory successfully returning 42. Initialization completes within one owner turn; the factory does not wait for mail to that busy owner.

## Источники / Sources

- [Java Language Specification — threads and memory model](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html) — Безопасная однократная ленивая инициализация при конкурентных обращениях.
- [Rust — OnceLock](https://doc.rust-lang.org/std/sync/struct.OnceLock.html) — Безопасная однократная ленивая инициализация при конкурентных обращениях.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
