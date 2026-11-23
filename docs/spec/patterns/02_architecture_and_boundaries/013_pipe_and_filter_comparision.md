# 013. Pipe and Filter

Независимые преобразования соединяются в упорядоченный поток данных.

**Отдельное сравнение реализации:** [093. Pipe — generic implementation](093_pipe_implementation_comparision.md)

## Общий сценарий

Для одного элемента -3 выполнить нормализацию знака, удвоение и смещение +1.

**Ожидаемое наблюдение:** 7; промежуточные значения 3 и 6.

**Граница сравнения:** Использование библиотеки. Сохраняется последовательный сценарий -3→3→6→7. Асинхронный stream/backpressure не подразумеваются: они рассматриваются в Message-примерах. Обобщённая композиция093 допускает разные промежуточные типы.

LMX вызывает операции единого ядра. Иностранные клиенты используют настоящие средства языка или установленную библиотеку; показанные рядом самостоятельные реализации в них не импортируются.

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
        throws: copy(FxThrows\adapter)
        @: stages pipe(pipe(normalize; double); offset)
        return: stages(value)
    demo:
        throws: copy(FxThrows\adapter)
        return: pipeline(-3)
```

Прямой core receiver pipe создаёт обычный callable; дополнительного PipeLibrary/import нет. Каждый этап вызывается один раз.

[Отдельный листинг](examples/lmx/013_pipe_and_filter.lm3)

## Java

```java
import java.util.function.IntUnaryOperator;
class Example {
    static int normalize(int value) { return Math.abs(value); }
    static int twice(int value) { return value * 2; }
    static int offset(int value) { return value + 1; }
    static int pipeline(int value) {
        IntUnaryOperator first = Example::normalize;
        return first.andThen(Example::twice).andThen(Example::offset).applyAsInt(value);
    }
    static int demo() { return pipeline(-3); }
}
```

Используется настоящий java.util.function.IntUnaryOperator.andThen. Реализация из093 здесь не подключается.

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

Для фиксированного конвейера достаточно обычных вложенных вызовов; самописный package pipe не подключается.

[Отдельный листинг](examples/go/013_pipe_and_filter.go)

## Разбор LMX

Прямой core receiver pipe создаёт обычный callable; дополнительного PipeLibrary/import нет. Каждый этап вызывается один раз.

## Сопоставление

LMX использует обобщённую композицию ядра, Java — настоящий andThen, Go — обычные вызовы. Сравнение093 не является зависимостью иностранных клиентов.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 268 | 18 |
| Java | 374 | 11 |
| Go | 246 | 6 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Independent transformations are connected in an ordered data flow.

**Separate implementation comparison:** [093. Pipe — generic implementation](093_pipe_implementation_comparision.md)

**Scenario.** For one item -3, normalize its sign, double it, then add 1.

**Expected observation.** 7; intermediate values are 3 and 6.

**LMX.** The direct core receiver pipe constructs an ordinary callable. There is no PipeLibrary/import; each stage runs once.

**Comparison.** LMX uses its direct generic core composition, Java its real andThen method, and Go ordinary calls. Implementation093 is a separate implementation comparison, not a dependency of the foreign usage examples.

**Scope and limitations.** The fixture is the same sequential -3→3→6→7 transformation. No asynchronous stream scheduling or backpressure is implied; those belong to the Message examples. The generic composition in093 also permits different intermediate types.

### Dependencies and execution boundaries

- **LMX:** The direct core receiver pipe constructs an ordinary callable. There is no PipeLibrary/import; each stage runs once.
- **Java:** Uses the real java.util.function.IntUnaryOperator.andThen. The implementation in093 is not imported here.
- **Go:** Ordinary nested calls express this fixed pipeline; no custom pipe package is imported.

## Источники / Sources

- [Java IntUnaryOperator](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/function/IntUnaryOperator.html) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
