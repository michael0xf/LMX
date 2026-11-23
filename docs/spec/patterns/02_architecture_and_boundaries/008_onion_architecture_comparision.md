# 008. Onion Architecture

Доменная сущность находится в центре; прикладная операция использует внешний порт сохранения.

## Общий сценарий

Сохранить Order(quantity=3, price=10) через переданный репозиторий и получить доменный total.

**Ожидаемое наблюдение:** 30; сохранён именно переданный объект заказа.

**Граница сравнения:** Ядро сценария. In-memory сохранение не обеспечивает долговечность. В fixture quantity положительно, price неотрицательно; SQL mapping и транзакция вне примера.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Order:
    int: quantity 3
    int: price 10
    return: int
    total:
        return: quantity * price

Repository:
    @: last 0
    @: order
    save:
        node\last := order

Application:
    @: order
    @: save
    return: int
    submit:
        save(order := order)
        return: order\total()
    demo:
        return: submit(Order; Repository\save)
```

Вызов Application\demo(). Order не зависит от Repository; save(order:@) сохраняет ссылку в тестовом адаптере.

[Отдельный листинг](examples/lmx/008_onion_architecture.lm3)

## Java

```java
class Example {
    record Order(int quantity, int price) { int total() { return quantity * price; } }
    interface Repository { void save(Order order); }
    static class Memory implements Repository {
        Order last;
        public void save(Order order) { last = order; }
    }
    static int submit(Order order, Repository repository) {
        repository.save(order);
        return order.total();
    }
    static int demo() { return submit(new Order(3, 10), new Memory()); }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/008_onion_architecture.java)

## Go

```go
package main
type Order struct { Quantity, Price int }
func (o *Order) Total() int { return o.Quantity * o.Price }
type Repository interface { Save(*Order) }
type Memory struct { Last *Order }
func (m *Memory) Save(o *Order) { m.Last = o }
func submit(o *Order, r Repository) int { r.Save(o); return o.Total() }
func demo() int { return submit(&Order{3, 10}, &Memory{}) }
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/008_onion_architecture.go)

## Разбор LMX

Вызов Application\demo(). Order не зависит от Repository; save(order:@) сохраняет ссылку в тестовом адаптере.

## Сопоставление

Сценарий подчёркивает entity-centric устройство Onion. Это близкий родственник Hexagonal/Clean, но отдельная исходная позиция сохранена.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 234 | 20 |
| Java | 363 | 13 |
| Go | 308 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

<!-- reuse-review-01-05-2026-11-22 -->

## Предыдущий полный вариант LMX — вне основного подсчёта

Полный предыдущий листинг сохранён; в текущую статистику входит только основной, более короткий вариант. Все самописные вспомогательные определения остаются в основном листинге и учитываются целиком.

```lmx
Order:
    int: quantity 3
    int: price 10
    return: int
    total:
        return: quantity * price

Repository:
    @: last 0
    @: order
    save:
        node\last := order

Application:
    @: order
    @: save
    return: int
    submit:
        save(order := order)
        return: order\total()
    demo:
        return: submit(order := Order; save := Repository\save)
```

**Основание выбора / Selection:** Use the visible submit input order order, save. Keep the named order actual on the saved callback because Repository has last before order; identity and save-before-total behavior remain.

<!-- /reuse-review-01-05-2026-11-22 -->

## English explanation

A domain entity is central; application behavior uses an outer persistence port.

**Scenario.** Save Order(quantity=3, price=10) through an injected repository and obtain its domain total.

**Expected observation.** 30; the repository retains the supplied order object.

**LMX.** Call Application\demo(). Order has no repository dependency; the test adapter save(order:@) retains a reference.

**Comparison.** This highlights Onion’s entity-centered arrangement. It overlaps with Hexagonal/Clean but remains a separate original entry.

**Scope and limitations.** In-memory persistence is not durable. The fixture has positive quantity and nonnegative price; SQL mapping and transactions are outside scope.

### Dependencies and execution boundaries

- **LMX:** Call Application\demo(). Order has no repository dependency; the test adapter save(order:@) retains a reference.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Jeffrey Palermo — The Onion Architecture, part 1](https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/) — Авторское описание отделения инфраструктуры от домена.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
