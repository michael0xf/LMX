# 065. Read-Write Lock

Чтение согласованного снимка при исключении пересечения с изменением.

## Общий сценарий

Начальное значение 10. Прочитать, записать 20, прочитать снова; затем рассмотреть одновременно пришедшие чтения.

**Ожидаемое наблюдение:** Последовательный сценарий даёт 10,20. Java/Rust допускают параллельных читателей; LMX owner обслуживает их последовательно.

**Граница сравнения:** Протокол и порты. Нельзя объявлять одинаковую пропускную способность или гарантию параллельных readers. Fairness, starvation и poison policy отличаются; Rust unwrap выбран только для безаварийного сценария.

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
        return: read()
```

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Все операции выполняются над одним владельцем. В LMX read/write — атомарные относительно других turns обращения к value; возвращается скалярная копия, а не mutable ссылка в чужую арену. В контрольных вариантах методы могут вызываться из разных потоков. write возвращает результат уже показанного read после записи; оба вызова остаются в одном turn владельца.

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

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Все операции выполняются над одним владельцем. В LMX read/write — атомарные относительно других turns обращения к value; возвращается скалярная копия, а не mutable ссылка в чужую арену. В контрольных вариантах методы могут вызываться из разных потоков. write возвращает результат уже показанного read после записи; оба вызова остаются в одном turn владельца.

## Сопоставление

Это функциональная альтернатива для согласованных скалярных чтений, а не реализация самого RW-lock на L3. Параллельный доступ к большому неизменяемому снимку можно вынести в отдельный протокол.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 107 | 9 | 107 |
| Java | 348 | 14 | — |
| Rust | 239 | 10 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Reading a consistent snapshot without overlapping a mutation.

**Scenario.** Start at 10. Read, write 20, read again; then consider concurrent read requests.

**Expected observation.** The sequential trace returns 10,20. Java/Rust permit concurrent readers; the LMX owner serves them serially.

**LMX.** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads. write returns the included read result after the write; both calls remain in the same owner turn.

**Comparison.** This is a functional alternative for consistent scalar reads, not an implementation of an L3 RW-lock. Parallel access to a large immutable snapshot requires a separate protocol.

**Scope and limitations.** Equal throughput or parallel-reader guarantees cannot be claimed. Fairness, starvation and poisoning policies differ; Rust unwrap is selected only for the failure-free fixture.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads. write returns the included read result after the write; both calls remain in the same owner turn.
- **Java:** Java 21 fragment; the launching harness is not included. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads.
- **Rust:** Rust fragment using std; the launching harness is not included. All operations address one owner. LMX read/write are atomic relative to other turns; results are scalar copies, not mutable references into a foreign arena. Control methods may be invoked from different threads.

## Источники / Sources

- [Java — ReentrantReadWriteLock](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantReadWriteLock.html) — Чтение согласованного снимка при исключении пересечения с изменением.
- [Rust — RwLock](https://doc.rust-lang.org/std/sync/struct.RwLock.html) — Чтение согласованного снимка при исключении пересечения с изменением.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
