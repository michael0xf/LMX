# 065. Read-Write Lock

Чтение согласованного снимка при исключении пересечения с изменением.

## Общий сценарий

Начальное значение 10. Прочитать, записать 20, прочитать снова; затем рассмотреть одновременно пришедшие чтения.

**Ожидаемое наблюдение:** Последовательный сценарий даёт 10,20. Java/Rust допускают параллельных читателей; LMX owner обслуживает их последовательно.

**Граница сравнения:** Протокол и порты. Нельзя объявлять одинаковую пропускную способность или гарантию параллельных readers. Fairness, starvation и poison policy отличаются; Rust unwrap выбран только для безаварийного сценария.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
ValueMessage:
    int: newValue
    int: value 10
    return: int
    read:
        return: node\value
    write:
        node\value := newValue
        return: node\value
```

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Все операции выполняются над одним владельцем. В LMX read/write — атомарные относительно других turns обращения к value; возвращается скалярная копия, а не mutable ссылка в чужую арену. В контрольных вариантах методы могут вызываться из разных потоков.

[Отдельный листинг](examples/lmx/065_read_write_lock.lm3)

## Java

```java
final class Value {
    private final java.util.concurrent.locks.ReentrantReadWriteLock lock =
        new java.util.concurrent.locks.ReentrantReadWriteLock();
    private int value = 10;
    int read() {
        lock.readLock().lock();
        try { return value; } finally { lock.readLock().unlock(); }
    }
    int write(int next) {
        lock.writeLock().lock();
        try { value = next; return value; }
        finally { lock.writeLock().unlock(); }
    }
}
```

Фрагмент для Java 21; запускающий harness не включён. Все операции выполняются над одним владельцем. В LMX read/write — атомарные относительно других turns обращения к value; возвращается скалярная копия, а не mutable ссылка в чужую арену. В контрольных вариантах методы могут вызываться из разных потоков.

[Отдельный листинг](examples/java/065_read_write_lock.java)

## Rust

```rust
use std::sync::RwLock;
struct Value { value: RwLock<i32> }
impl Value {
    fn new() -> Self { Self { value: RwLock::new(10) } }
    fn read(&self) -> i32 { *self.value.read().unwrap() }
    fn write(&self, next: i32) -> i32 {
        let mut value = self.value.write().unwrap();
        *value = next; *value
    }
}
```

Фрагмент Rust использует std; запускающий harness не включён. Все операции выполняются над одним владельцем. В LMX read/write — атомарные относительно других turns обращения к value; возвращается скалярная копия, а не mutable ссылка в чужую арену. В контрольных вариантах методы могут вызываться из разных потоков.

[Отдельный листинг](examples/rust/065_read_write_lock.rs)

## Разбор LMX

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Все операции выполняются над одним владельцем. В LMX read/write — атомарные относительно других turns обращения к value; возвращается скалярная копия, а не mutable ссылка в чужую арену. В контрольных вариантах методы могут вызываться из разных потоков.

## Сопоставление

Это функциональная альтернатива для согласованных скалярных чтений, а не реализация самого RW-lock на L3. Параллельный доступ к большому неизменяемому снимку можно вынести в отдельный протокол.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 111 | 9 |
| Java | 348 | 14 |
| Rust | 239 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Reading a consistent snapshot without overlapping a mutation.

**Scenario.** Start at 10. Read, write 20, read again; then consider concurrent read requests.

**Expected observation.** The sequential trace returns 10,20. Java/Rust permit concurrent readers; the LMX owner serves them serially.

**LMX.** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads.

**Comparison.** This is a functional alternative for consistent scalar reads, not an implementation of an L3 RW-lock. Parallel access to a large immutable snapshot requires a separate protocol.

**Scope and limitations.** Equal throughput or parallel-reader guarantees cannot be claimed. Fairness, starvation and poisoning policies differ; Rust unwrap is selected only for the failure-free fixture.

### Dependencies and execution boundaries

- **LMX:** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads.
- **Java:** Java 21 fragment; the launching harness is not included. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads.
- **Rust:** Rust fragment using std; the launching harness is not included. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads.

## Источники / Sources

- [Java — ReentrantReadWriteLock](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantReadWriteLock.html) — Чтение согласованного снимка при исключении пересечения с изменением.
- [Rust — RwLock](https://doc.rust-lang.org/std/sync/struct.RwLock.html) — Чтение согласованного снимка при исключении пересечения с изменением.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
