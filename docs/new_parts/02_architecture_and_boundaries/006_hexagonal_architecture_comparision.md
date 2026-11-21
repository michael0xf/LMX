# 006. Hexagonal Architecture (Ports and Adapters)

Прикладное ядро получает внешние зависимости через порты.

## Общий сценарий

Одно ядро вычисляет стоимость двух единиц с адаптерами цены 10 и 12.

**Ожидаемое наблюдение:** 20 + 24 = 44; ядро не меняется при замене адаптера.

**Граница сравнения:** Ядро сценария. Адаптеры in-memory. Реальный SQL/HTTP adapter должен выполнять тот же порт с явно выбранными ошибками и временем жизни.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Adapters:
    return: int
    memory:
        return: 10
    alternate:
        return: 12

Core:
    int: quantity
    @: price
    return: int
    quote:
        return: quantity * price()
    demo:
        return: quote(quantity := 2; price := Adapters\memory) + quote(quantity := 2; price := Adapters\alternate)
```

Вызов Core\demo(). price — явно supplied callable; ни глобального service locator, ни поиска реализации по имени нет.

[Отдельный листинг](examples/lmx/006_hexagonal_architecture.lm3)

## Java

```java
import java.util.function.IntSupplier;
class Example {
    static int quote(int quantity, IntSupplier price) {
        return quantity * price.getAsInt();
    }
    static int memory() { return 10; }
    static int alternate() { return 12; }
    static int demo() { return quote(2, Example::memory) + quote(2, Example::alternate); }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/006_hexagonal_architecture.java)

## Go

```go
package main
func quote(quantity int, price func() int) int { return quantity * price() }
func memory() int { return 10 }
func alternate() int { return 12 }
func demo() int { return quote(2, memory) + quote(2, alternate) }
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/006_hexagonal_architecture.go)

## Разбор LMX

Вызов Core\demo(). price — явно supplied callable; ни глобального service locator, ни поиска реализации по имени нет.

## Сопоставление

Во всех языках порт имеет контракт ()→int и вызывается один раз. Функционального порта достаточно; отдельный класс адаптера здесь необязателен.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 215 | 14 |
| Java | 264 | 9 |
| Go | 183 | 5 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

The application core receives external dependencies through ports.

**Scenario.** Use one core to price two units with adapters returning 10 and 12.

**Expected observation.** 20 + 24 = 44; replacing the adapter does not change the core.

**LMX.** Call Core\demo(). price is an explicitly supplied callable, not a global service locator or hidden name search.

**Comparison.** The port is ()→int and is called once in every language. A function is sufficient; a separate adapter class is optional.

**Scope and limitations.** These are in-memory adapters. A real SQL/HTTP adapter must implement the same port with explicit failure and lifetime rules.

### Dependencies and execution boundaries

- **LMX:** Call Core\demo(). price is an explicitly supplied callable, not a global service locator or hidden name search.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Alistair Cockburn — Hexagonal architecture](https://alistair.cockburn.us/hexagonal-architecture) — Исходная статья автора о портах и адаптерах.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
