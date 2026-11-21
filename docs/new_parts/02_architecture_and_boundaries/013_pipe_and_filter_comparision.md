# 013. Pipe and Filter

Независимые преобразования соединяются в упорядоченный поток данных.

## Общий сценарий

Для одного элемента -3 выполнить нормализацию знака, удвоение и смещение +1.

**Ожидаемое наблюдение:** 7; промежуточные значения 3 и 6.

**Граница сравнения:** Ядро сценария. Один целый элемент, без overflow на выбранном входе. Потоковая очередь, backpressure и параллельное исполнение в этот листинг не входят.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Filters:
    int: value
    return: int
    normalize:
        if: value < 0
            return: -value
        return: value
    double:
        return: value * 2
    offset:
        return: value + 1
    pipeline:
        return: offset(value := double(value := normalize(value := value)))
    demo:
        return: pipeline(value := -3)
```

Вызов Filters\demo(). Здесь pipe — передача результата следующей стадии в одном Message. Для параллельных стадий те же фильтры помещаются в разные Message и соединяются доставкой.

[Отдельный листинг](examples/lmx/013_pipe_and_filter.lm3)

## Java

```java
class Example {
    static int normalize(int value) { return Math.abs(value); }
    static int twice(int value) { return value * 2; }
    static int offset(int value) { return value + 1; }
    static int pipeline(int value) { return offset(twice(normalize(value))); }
    static int demo() { return pipeline(-3); }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/013_pipe_and_filter.java)

## Go

```go
package main
func normalize(value int) int { if value < 0 { return -value }; return value }
func twice(value int) int { return value * 2 }
func offset(value int) int { return value + 1 }
func pipeline(value int) int { return offset(twice(normalize(value))) }
func demo() int { return pipeline(-3) }
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/013_pipe_and_filter.go)

## Разбор LMX

Вызов Filters\demo(). Здесь pipe — передача результата следующей стадии в одном Message. Для параллельных стадий те же фильтры помещаются в разные Message и соединяются доставкой.

## Сопоставление

Одинаковое синхронное ядро отделяет преобразования от политики buffering/scheduling. Не требуется объектная иерархия каждого фильтра.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 214 | 15 |
| Java | 250 | 7 |
| Go | 246 | 6 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Independent transformations are connected in an ordered data flow.

**Scenario.** For one item -3, normalize its sign, double it, then add 1.

**Expected observation.** 7; intermediate values are 3 and 6.

**LMX.** Call Filters\demo(). Here a pipe is value handoff inside one Message. Parallel stages use separate Messages connected by delivery.

**Comparison.** The same synchronous core separates transformations from buffering/scheduling policy. No class hierarchy is needed for each filter.

**Scope and limitations.** One integer item with no overflow for the fixture. Queues, backpressure, and concurrent execution are outside this listing.

### Dependencies and execution boundaries

- **LMX:** Call Filters\demo(). Here a pipe is value handoff inside one Message. Parallel stages use separate Messages connected by delivery.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Gregor Hohpe and Bobby Woolf — Pipes and Filters](https://www.enterpriseintegrationpatterns.com/patterns/messaging/PipesAndFilters.html) — Независимые стадии и соединяющие каналы.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
