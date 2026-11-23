# 013. Pipe and Filter

Независимые преобразования соединяются в упорядоченный поток данных.

**Реализация используемого компонента:** [093. Pipe — implementation](093_pipe_implementation_comparision.md)

## Общий сценарий

Для одного элемента -3 выполнить нормализацию знака, удвоение и смещение +1.

**Ожидаемое наблюдение:** 7; промежуточные значения 3 и 6.

**Граница сравнения:** Использование библиотеки. Один int-поток в одном последовательном контексте; выбранный вход не переполняется. Стадии имеют один int-вход, int-результат и не объявляют recoverable failures. Очереди, backpressure и планировщик не включены. Тело Pipe не входит в клиентский размер, но полностью показано и измерено отдельно для всех трёх языков.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

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
        import: PipeLibrary
        return: value pipe normalize double offset
    demo:
        return: pipeline(value := -3)
```

Вызов Filters\demo(). PipeLibrary — прикладной модуль с полной реализацией в соседнем сравнении; это не новый builtin. import делает доступным pipe. Унаследованы готовые PASS_ARGS_AS_IS=0 и PRIORITY=sys\priority("+") из sys\OPERANDS_TEMPLATE; copy не переобъявляет эти const-поля. В value pipe normalize double offset один левый int и три правые ссылки на методы int→int. Подготовка ссылок не вызывает методы. Библиотека явно обходит right по порядку и вызывает каждую стадию один раз. Пустой правый список означает тождественное преобразование; автоматического fold нет. Всё выполняется в одном Message; параллельные стадии требуют отдельных Message и доставки.

[Отдельный листинг](examples/lmx/013_pipe_and_filter.lm3)

## Java

```java
import examplelib.Pipe;
class Example {
    static int normalize(int value) { return Math.abs(value); }
    static int twice(int value) { return value * 2; }
    static int offset(int value) { return value + 1; }
    static int pipeline(int value) {
        return Pipe.apply(value, Example::normalize, Example::twice, Example::offset);
    }
    static int demo() { return pipeline(-3); }
}
```

Импорт examplelib.Pipe соответствует показанному companion. При сборке его public class находится в examplelib/Pipe.java; внешний вызов Example.demo().

[Отдельный листинг](examples/java/013_pipe_and_filter.java)

## Go

```go
package main
import "example/pipe"
func normalize(value int) int { if value < 0 { return -value }; return value }
func twice(value int) int { return value * 2 }
func offset(value int) int { return value + 1 }
func pipeline(value int) int { return pipe.Apply(value, normalize, twice, offset) }
func demo() int { return pipeline(-3) }
```

Импорт example/pipe — локальный модуль example с показанным companion в pipe/pipe.go. Это не внешний пакет, который предлагается скачать. Внешний вызов demo().

[Отдельный листинг](examples/go/013_pipe_and_filter.go)

## Разбор LMX

Вызов Filters\demo(). PipeLibrary — прикладной модуль с полной реализацией в соседнем сравнении; это не новый builtin. import делает доступным pipe. Унаследованы готовые PASS_ARGS_AS_IS=0 и PRIORITY=sys\priority("+") из sys\OPERANDS_TEMPLATE; copy не переобъявляет эти const-поля. В value pipe normalize double offset один левый int и три правые ссылки на методы int→int. Подготовка ссылок не вызывает методы. Библиотека явно обходит right по порядку и вызывает каждую стадию один раз. Пустой правый список означает тождественное преобразование; автоматического fold нет. Всё выполняется в одном Message; параллельные стадии требуют отдельных Message и доставки.

## Сопоставление

Все три клиента импортируют готовый Pipe, сохраняя определения нормализации, удвоения, смещения и их порядок. LMX показывает этот порядок слева направо в выражении; Java и Go передают тот же список callable. Соседнее сравнение отдельно учитывает явный цикл реализации во всех трёх языках; небольшой клиент не объявляется полной реализацией конвейера.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 209 | 16 |
| Java | 308 | 10 |
| Go | 275 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Independent transformations are connected in an ordered data flow.

**Implementation of the supplied component:** [093. Pipe — implementation](093_pipe_implementation_comparision.md)

**Scenario.** For one item -3, normalize its sign, double it, then add 1.

**Expected observation.** 7; intermediate values are 3 and 6.

**LMX.** Call Filters\demo(). PipeLibrary is an application module fully implemented in the companion comparison, not a new builtin. import exposes pipe. copy inherits ready PASS_ARGS_AS_IS=0 and PRIORITY=sys\priority("+") from sys\OPERANDS_TEMPLATE without redeclaring the const fields. The expression has one left int and three right int→int method references; preparing those references does not invoke them. The library explicitly visits right in order and calls each stage once. An empty right list returns the input; no automatic fold is assumed. Execution stays in one Message; parallel stages need separate Messages and delivery.

**Comparison.** All three clients import a ready Pipe while retaining normalization, doubling, offset, and their order. LMX writes that order left to right; Java and Go pass the same callable list. The companion separately counts the explicit implementation loop in all three languages; client size is not presented as the full pipeline implementation.

**Scope and limitations.** One int flow in one sequential context; the fixture does not overflow. Stages have one int input and result and declare no recoverable failures. Queues, backpressure, and scheduling are excluded. Pipe implementation is excluded from client size but shown and measured separately for every language.

### Dependencies and execution boundaries

- **LMX:** Call Filters\demo(). PipeLibrary is an application module fully implemented in the companion comparison, not a new builtin. import exposes pipe. copy inherits ready PASS_ARGS_AS_IS=0 and PRIORITY=sys\priority("+") from sys\OPERANDS_TEMPLATE without redeclaring the const fields. The expression has one left int and three right int→int method references; preparing those references does not invoke them. The library explicitly visits right in order and calls each stage once. An empty right list returns the input; no automatic fold is assumed. Execution stays in one Message; parallel stages need separate Messages and delivery.
- **Java:** The examplelib.Pipe import refers to the shown companion; place its public class in examplelib/Pipe.java. Call Example.demo().
- **Go:** example/pipe is the local example module with the shown companion in pipe/pipe.go, not an external download. Call demo().

## Источники / Sources

- [Gregor Hohpe and Bobby Woolf — Pipes and Filters](https://www.enterpriseintegrationpatterns.com/patterns/messaging/PipesAndFilters.html) — Независимые стадии и соединяющие каналы.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
