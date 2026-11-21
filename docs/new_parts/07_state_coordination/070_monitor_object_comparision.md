# 070. Monitor Object

Объект защищает инвариант всей операции над своим состоянием.

## Общий сценарий

Баланс равен 10. Два клиента запрашивают withdraw(7); проверка и списание должны быть одной операцией.

**Ожидаемое наблюдение:** Ровно один запрос успешен; итоговый баланс 3. Отдельные read+write этим свойством не обладают.

**Граница сравнения:** Протокол и порты. Переполнение целого, durability и многосчётный перевод вне сценария. Ошибка после изменения графа не означает автоматический rollback.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
AccountMessage:
    int: amount
    int: balance 10
    return: int
    withdraw:
        if: amount < 0
            return: 0
        if: node\balance < amount
            return: 0
        node\balance -= amount
        return: 1
    read:
        return: node\balance
```

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Один AccountMessage получает оба withdraw через обычную почту. Инвариант полностью находится внутри handler, без ожидания внешнего ответа между проверкой и записью. Контрольные версии защищают весь метод одним монитором/Mutex.

[Отдельный листинг](examples/lmx/070_monitor_object.lm3)

## Java

```java
final class Account {
    private int balance = 10;
    synchronized boolean withdraw(int amount) {
        if (amount < 0 || balance < amount) return false;
        balance -= amount; return true;
    }
    synchronized int read() { return balance; }
}
```

Фрагмент для Java 21; запускающий harness не включён. Один AccountMessage получает оба withdraw через обычную почту. Инвариант полностью находится внутри handler, без ожидания внешнего ответа между проверкой и записью. Контрольные версии защищают весь метод одним монитором/Mutex.

[Отдельный листинг](examples/java/070_monitor_object.java)

## Rust

```rust
use std::sync::Mutex;
struct Account { balance: Mutex<i32> }
impl Account {
    fn new() -> Self { Self { balance: Mutex::new(10) } }
    fn withdraw(&self, amount: i32) -> bool {
        let mut balance = self.balance.lock().unwrap();
        if amount < 0 || *balance < amount { return false; }
        *balance -= amount; true
    }
    fn read(&self) -> i32 { *self.balance.lock().unwrap() }
}
```

Фрагмент Rust использует std; запускающий harness не включён. Один AccountMessage получает оба withdraw через обычную почту. Инвариант полностью находится внутри handler, без ожидания внешнего ответа между проверкой и записью. Контрольные версии защищают весь метод одним монитором/Mutex.

[Отдельный листинг](examples/rust/070_monitor_object.rs)

## Разбор LMX

LMX реализует координацию через отдельный Message-владелец; методы вызываются адресованными письмами, mutable state меняется только на его полосе. Шаблон явно создаётся хостом как исполняемый Thread со своей ареной. MESSAGE_HTTP_PROFILE.md описывает запуск и общий post/HTTP контур; листинги являются ядрами протоколов, а не полными серверами. Один AccountMessage получает оба withdraw через обычную почту. Инвариант полностью находится внутри handler, без ожидания внешнего ответа между проверкой и записью. Контрольные версии защищают весь метод одним монитором/Mutex.

## Сопоставление

Последовательный turn позволяет выражать владельца-инвариант без пользовательского lock на L3. Это не распределённая транзакция: другой владелец не включается в ту же атомарную операцию автоматически.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 158 | 13 |
| Java | 184 | 8 |
| Rust | 299 | 11 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

An object protects an invariant across a complete operation on its state.

**Scenario.** Balance is 10. Two clients request withdraw(7); checking and decrementing must be one operation.

**Expected observation.** Exactly one request succeeds; final balance is 3. Separate read+write requests do not have this property.

**LMX.** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. One AccountMessage receives both withdraw requests through ordinary mail. The entire invariant lives inside one handler with no external wait between check and write. Controls protect the whole method using a monitor/Mutex.

**Comparison.** A serial turn expresses an invariant-owning object without an application L3 lock. It is not a distributed transaction: another owner does not automatically join the atomic operation.

**Scope and limitations.** Integer overflow, durability and multi-account transfer are outside this scenario. Failure after graph mutation does not imply automatic rollback.

### Dependencies and execution boundaries

- **LMX:** LMX coordinates through a separate owner Message; methods are invoked by addressed mail and mutate state only on its lane. The host explicitly creates an executable Thread with its own arena. MESSAGE_HTTP_PROFILE.md describes launch and shared post/HTTP integration; listings are protocol cores, not complete servers. One AccountMessage receives both withdraw requests through ordinary mail. The entire invariant lives inside one handler with no external wait between check and write. Controls protect the whole method using a monitor/Mutex.
- **Java:** Java 21 fragment; the launching harness is not included. One AccountMessage receives both withdraw requests through ordinary mail. The entire invariant lives inside one handler with no external wait between check and write. Controls protect the whole method using a monitor/Mutex.
- **Rust:** Rust fragment using std; the launching harness is not included. One AccountMessage receives both withdraw requests through ordinary mail. The entire invariant lives inside one handler with no external wait between check and write. Controls protect the whole method using a monitor/Mutex.

## Источники / Sources

- [Java Language Specification — monitors](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html) — Объект защищает инвариант всей операции над своим состоянием.
- [Rust — synchronization primitives](https://doc.rust-lang.org/std/sync/) — Объект защищает инвариант всей операции над своим состоянием.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
