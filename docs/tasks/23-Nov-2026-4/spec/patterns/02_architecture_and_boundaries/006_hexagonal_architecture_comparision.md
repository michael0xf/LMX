# 006. Hexagonal Architecture (Ports and Adapters)

Прикладное ядро получает внешние зависимости через порты.

## Общий сценарий

Одно ядро вычисляет стоимость двух единиц с адаптерами цены 10 и 12.

**Ожидаемое наблюдение:** 20 + 24 = 44; ядро не меняется при замене адаптера.

**Граница сравнения:** Ядро сценария. Адаптеры in-memory. Реальный SQL/HTTP adapter должен выполнять тот же порт с явно выбранными ошибками и временем жизни.

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
        return: quote(2; Adapters\memory) + quote(2; Adapters\alternate)
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

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 181 | 14 |
| Java | 264 | 9 |
| Go | 183 | 5 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

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

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
