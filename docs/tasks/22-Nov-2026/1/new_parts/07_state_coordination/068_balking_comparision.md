# 068. Balking

Если действие уже началось, повторный запрос сразу отказывается от выполнения.

## Общий сценарий

Начать сохранение, повторить start до finish, завершить, затем снова start.

**Ожидаемое наблюдение:** Результаты start: 1,0,1. Второй запрос не создаёт дополнительной работы.

**Граница сравнения:** Протокол и порты. Флаг не является durable lock и не публикует произвольную память между Message. Потерянный finish после crash требует recovery; дубли finish запрещены контрактом.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
SaveMessage:
    int: busy 0
    return: int
    start:
        if: node\busy = 1
            return: 0
        node\busy := 1
        return: 1
    finish:
        node\busy := 0
        return: 1
```

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Листинг реализует admission gate; actual save запускает caller только после start=1 и вызывает finish ровно один раз после окончания. LMX длинная работа выполняется отдельным Message, а SaveMessage остаётся доступен для повторных запросов.

[Отдельный листинг](examples/lmx/068_balking.lm3)

## Java

```java
final class Save {
    private final java.util.concurrent.atomic.AtomicBoolean busy =
        new java.util.concurrent.atomic.AtomicBoolean();
    boolean start() { return busy.compareAndSet(false, true); }
    int finish() { busy.set(false); return 1; }
}
```

Фрагмент для Java 21; запускающий harness не включён. Листинг реализует admission gate; actual save запускает caller только после start=1 и вызывает finish ровно один раз после окончания. LMX длинная работа выполняется отдельным Message, а SaveMessage остаётся доступен для повторных запросов.

[Отдельный листинг](examples/java/068_balking.java)

## Rust

```rust
use std::sync::atomic::{AtomicBool, Ordering};
struct Save { busy: AtomicBool }
impl Save {
    fn new() -> Self { Self { busy: AtomicBool::new(false) } }
    fn start(&self) -> bool {
        self.busy.compare_exchange(false, true, Ordering::AcqRel, Ordering::Acquire).is_ok()
    }
    fn finish(&self) -> i32 { self.busy.store(false, Ordering::Release); 1 }
}
```

Фрагмент Rust использует std; запускающий harness не включён. Листинг реализует admission gate; actual save запускает caller только после start=1 и вызывает finish ровно один раз после окончания. LMX длинная работа выполняется отдельным Message, а SaveMessage остаётся доступен для повторных запросов.

[Отдельный листинг](examples/rust/068_balking.rs)

## Разбор LMX

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Листинг реализует admission gate; actual save запускает caller только после start=1 и вызывает finish ровно один раз после окончания. LMX длинная работа выполняется отдельным Message, а SaveMessage остаётся доступен для повторных запросов.

## Сопоставление

Balking возвращает отказ, тогда как Guarded Suspension сохраняет ожидание. LMX делает проверку и изменение флага в одном turn; Java/Rust используют atomic compare-and-set.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 106 | 11 |
| Java | 211 | 6 |
| Rust | 296 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

If an action is already underway, another request immediately declines to execute it.

**Scenario.** Start a save, repeat start before finish, finish it, then start again.

**Expected observation.** start results: 1,0,1. The second request creates no extra work.

**LMX.** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. The listing implements an admission gate; the caller launches actual saving only after start succeeds and invokes finish exactly once on completion. LMX long work runs in another Message, leaving SaveMessage available for later requests.

**Comparison.** Balking refuses rather than retaining a waiter as Guarded Suspension does. LMX checks and changes its flag in one turn; Java/Rust use atomic compare-and-set.

**Scope and limitations.** The flag is not a durable lock and does not publish arbitrary memory across Messages. A lost finish after a crash requires recovery; duplicate finishes are excluded by the contract.

### Dependencies and execution boundaries

- **LMX:** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. The listing implements an admission gate; the caller launches actual saving only after start succeeds and invokes finish exactly once on completion. LMX long work runs in another Message, leaving SaveMessage available for later requests.
- **Java:** Java 21 fragment; the launching harness is not included. The listing implements an admission gate; the caller launches actual saving only after start succeeds and invokes finish exactly once on completion. LMX long work runs in another Message, leaving SaveMessage available for later requests.
- **Rust:** Rust fragment using std; the launching harness is not included. The listing implements an admission gate; the caller launches actual saving only after start succeeds and invokes finish exactly once on completion. LMX long work runs in another Message, leaving SaveMessage available for later requests.

## Источники / Sources

- [Java Language Specification — synchronization and memory model](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html) — Если действие уже началось, повторный запрос сразу отказывается от выполнения.
- [Rust — synchronization primitives](https://doc.rust-lang.org/std/sync/) — Если действие уже началось, повторный запрос сразу отказывается от выполнения.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
