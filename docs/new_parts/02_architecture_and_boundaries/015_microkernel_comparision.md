# 015. Microkernel / Plug-in

Стабильное ядро предоставляет точку расширения с заменяемой реализацией.

## Общий сценарий

Установить plugin x*2, выполнить 5; затем установить x*3 и повторить без изменения ядра.

**Ожидаемое наблюдение:** 10 + 15 = 25.

**Граница сравнения:** Ядро сценария. Динамическая загрузка DLL/JAR, sandbox, ABI/version negotiation и выгрузка модулей не реализованы. Паттерн microkernel шире показанного in-process ядра.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Plugins:
    int: value
    return: int
    twice:
        return: value * 2
    thrice:
        return: value * 3

Kernel:
    @: extension Plugins\twice
    @: implementation
    int: value
    return: int
    install:
        node\extension := implementation
        return: 1
    execute:
        return: node\extension(value := value)
    demo:
        install(implementation := Plugins\twice)
        int: first execute(value := 5)
        install(implementation := Plugins\thrice)
        return: first + execute(value := 5)
```

Вызов Kernel\demo(). Изменяется ссылка extension на уже существующий метод. Это не редактирование исполняемого тела и не скрытая компиляция.

[Отдельный листинг](examples/lmx/015_microkernel.lm3)

## Java

```java
import java.util.function.IntUnaryOperator;
class Example {
    static class Kernel {
        IntUnaryOperator extension = x -> x * 2;
        void install(IntUnaryOperator implementation) { extension = implementation; }
        int execute(int value) { return extension.applyAsInt(value); }
    }
    static int demo() {
        Kernel kernel = new Kernel();
        int first = kernel.execute(5);
        kernel.install(x -> x * 3);
        return first + kernel.execute(5);
    }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/015_microkernel.java)

## Go

```go
package main
type Kernel struct { extension func(int) int }
func (k *Kernel) Install(implementation func(int) int) { k.extension = implementation }
func (k *Kernel) Execute(value int) int { return k.extension(value) }
func demo() int {
    k := &Kernel{extension: func(x int) int { return x * 2 }}
    first := k.Execute(5)
    k.Install(func(x int) int { return x * 3 })
    return first + k.Execute(5)
}
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/015_microkernel.go)

## Разбор LMX

Вызов Kernel\demo(). Изменяется ссылка extension на уже существующий метод. Это не редактирование исполняемого тела и не скрытая компиляция.

## Сопоставление

Сравнивается минимальная extension point; registry множества имён и discovery не нужны для одной точки. Все реализации используют заменяемое поведение.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 361 | 22 |
| Java | 356 | 14 |
| Go | 326 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A stable core provides an extension point with replaceable implementation.

**Scenario.** Install an x*2 plugin and run 5; then install x*3 and repeat without changing the core.

**Expected observation.** 10 + 15 = 25.

**LMX.** Call Kernel\demo(). extension changes to an existing method. This neither edits a method body nor triggers hidden compilation.

**Comparison.** This compares one minimal extension point. A multi-name registry and discovery are unnecessary for this single point; every implementation has replaceable behavior.

**Scope and limitations.** DLL/JAR loading, sandboxing, ABI/version negotiation, and unloading are not implemented. Microkernel is broader than this in-process core.

### Dependencies and execution boundaries

- **LMX:** Call Kernel\demo(). extension changes to an existing method. This neither edits a method body nor triggers hidden compilation.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Eclipse — Notes on the Plug-in Architecture](https://www.eclipse.org/articles/Article-Plug-in-architecture/plugin_architecture.html) — Практическое устройство ядра и extension points.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
