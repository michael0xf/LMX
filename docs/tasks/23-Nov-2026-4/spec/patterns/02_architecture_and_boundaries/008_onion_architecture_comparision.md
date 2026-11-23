# 008. Onion Architecture

Доменная сущность находится в центре; прикладная операция использует внешний порт сохранения.

## Общий сценарий

Сохранить Order(quantity=3, price=10) через переданный репозиторий и получить доменный total.

**Ожидаемое наблюдение:** 30; сохранён именно переданный объект заказа.

**Граница сравнения:** Ядро сценария. In-memory сохранение не обеспечивает долговечность. В fixture quantity положительно, price неотрицательно; SQL mapping и транзакция вне примера.

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
        save()
        return: order\total()
    demo:
        return: submit(Order; Repository\save)
```

Вызов Application\demo(). Order не зависит от Repository; save(order:@) сохраняет ссылку в тестовом адаптере. Сокращение 23-Nov: The retained save callback receives the caller order by its declared same-name input.

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

Вызов Application\demo(). Order не зависит от Repository; save(order:@) сохраняет ссылку в тестовом адаптере. Сокращение 23-Nov: The retained save callback receives the caller order by its declared same-name input.

## Сопоставление

Сценарий подчёркивает entity-centric устройство Onion. Это близкий родственник Hexagonal/Clean, но отдельная исходная позиция сохранена.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 222 | 20 |
| Java | 363 | 13 |
| Go | 308 | 8 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

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

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
