# 046. Anti-Corruption Layer (ACL)

Переводчик сохраняет смысл доменной модели при обращении к чужой системе.

## Общий сценарий

Legacy возвращает цену 12 в целых долларах; новый домен ожидает центы. Для quantity=2 получить 2400.

**Ожидаемое наблюдение:** 2400; 12 превращается в 1200 ровно на ACL-границе.

**Граница сравнения:** Ядро сценария. Одна валюта и целое число долларов без overflow. Обменный курс, дробные доллары, rounding, schema migration и ошибки legacy требуют дополнительных правил.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Legacy:
    return: int
    dollars:
        return: 12

ACL:
    return: int
    cents:
        return: Legacy\dollars() * 100

Checkout:
    int: quantity
    return: int
    total:
        return: quantity * ACL\cents()
    demo:
        return: total(quantity := 2)
```

Вызов Checkout\demo(). Преобразование единиц написано явно; исходный primitive int не несёт автоматического знания о валюте.

[Отдельный листинг](examples/lmx/046_anti_corruption_layer.lm3)

## Java

```java
class Example {
    static int legacyDollars() { return 12; }
    static int cents() { return legacyDollars() * 100; }
    static int total(int quantity) { return quantity * cents(); }
    static int demo() { return total(2); }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/046_anti_corruption_layer.java)

## Go

```go
package main
func legacyDollars() int { return 12 }
func cents() int { return legacyDollars() * 100 }
func total(quantity int) int { return quantity * cents() }
func demo() int { return total(2) }
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/046_anti_corruption_layer.go)

## Разбор LMX

Вызов Checkout\demo(). Преобразование единиц написано явно; исходный primitive int не несёт автоматического знания о валюте.

## Сопоставление

ACL отвечает за смысловые различия, а не только переименование метода. Перенос Legacy за HTTP не меняет эту обязанность; transport adapter работает отдельно.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 175 | 15 |
| Java | 177 | 6 |
| Go | 162 | 5 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A translation boundary preserves domain meaning when accessing another system.

**Scenario.** Legacy returns a price of 12 whole dollars; the new domain expects cents. For quantity=2 obtain 2400.

**Expected observation.** 2400; 12 becomes 1200 exactly at the ACL boundary.

**LMX.** Call Checkout\demo(). Unit translation is explicit; a primitive int does not automatically know its currency.

**Comparison.** The ACL translates semantics, not just method names. Moving Legacy behind HTTP does not remove that responsibility; the transport adapter remains separate.

**Scope and limitations.** One currency and integral dollars without overflow. Exchange rates, fractions, rounding, schema migration, and legacy errors need extra rules.

### Dependencies and execution boundaries

- **LMX:** Call Checkout\demo(). Unit translation is explicit; a primitive int does not automatically know its currency.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Microsoft — Anti-Corruption Layer](https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer) — Изоляция различных семантических моделей.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
