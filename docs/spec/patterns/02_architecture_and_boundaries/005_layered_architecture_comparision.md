# 005. Layered Architecture

Представление вызывает прикладной слой, а тот — слой данных.

## Общий сценарий

Вычислить стоимость трёх единиц товара с ценой 10 через три явно разделённых слоя.

**Ожидаемое наблюдение:** 30.

**Граница сравнения:** Ядро сценария. Физическое разделение по машинам не требуется. Отдельные модули/build rules нужны, чтобы запретить обход слоя на уровне проекта.

## LMX

```lmx
Data:
    return: int
    price:
        return: 10

Application:
    int: quantity
    return: int
    total:
        return: quantity * Data\price()

Presentation:
    int: quantity
    return: int
    handle:
        return: Application\total(quantity)
    demo:
        return: handle(3)
```

Вызов Presentation\demo(). Структуры задают слои и явные зависимости вниз.

[Отдельный листинг](examples/lmx/005_layered_architecture.lm3)

## Java

```java
class Example {
    static class Data { static int price() { return 10; } }
    static class Application {
        static int total(int quantity) { return quantity * Data.price(); }
    }
    static class Presentation {
        static int handle(int quantity) { return Application.total(quantity); }
    }
    static int demo() { return Presentation.handle(3); }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/005_layered_architecture.java)

## Go

```go
package main
func dataPrice() int { return 10 }
func applicationTotal(quantity int) int { return quantity * dataPrice() }
func presentationHandle(quantity int) int { return applicationTotal(quantity) }
func demo() int { return presentationHandle(3) }
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/005_layered_architecture.go)

## Разбор LMX

Вызов Presentation\demo(). Структуры задают слои и явные зависимости вниз.

## Сопоставление

Короткий пример показывает зависимость application от concrete data; это намеренно отличается от инверсии зависимостей следующих трёх паттернов.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 195 | 16 |
| Java | 274 | 10 |
| Go | 217 | 5 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Presentation calls the application layer, which calls the data layer.

**Scenario.** Compute the cost of three units priced at 10 through three explicit layers.

**Expected observation.** 30.

**LMX.** Call Presentation\demo(). Structures represent layers and explicit downward dependencies.

**Comparison.** The application intentionally depends on concrete data, unlike dependency inversion in the following three patterns.

**Scope and limitations.** Physical tiers are not required. Separate modules/build rules are needed to forbid layer bypasses project-wide.

### Dependencies and execution boundaries

- **LMX:** Call Presentation\demo(). Structures represent layers and explicit downward dependencies.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Microsoft — N-tier architecture style](https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/n-tier) — Различие логических слоёв и физических tiers.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
