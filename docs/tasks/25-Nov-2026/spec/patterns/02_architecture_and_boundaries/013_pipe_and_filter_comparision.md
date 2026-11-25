# 013. Pipe and Filter

Независимые преобразования соединяются в упорядоченный поток данных.

**Отдельное сравнение реализации:** [093. Pipe — implementation](093_pipe_implementation_comparision.md)

## Общий сценарий

Для одного элемента -3 выполнить нормализацию знака, удвоение и смещение +1.

**Ожидаемое наблюдение:** 7; промежуточные значения 3 и 6.

**Граница сравнения:** Использование библиотеки. Один int-поток в одном последовательном контексте; выбранный вход не переполняется. Стадии имеют один int-вход, int-результат и не объявляют recoverable failures. Очереди, backpressure и планировщик не включены. Тело Pipe не входит в клиентский размер, но полностью показано и измерено отдельно для всех трёх языков.

LMX использует существующие средства ядра или явно названную компактную группу, определённую в связанном сравнении реализации. Иностранные клиенты используют настоящие средства языка или установленную библиотеку.

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
        throws: copy(FxThrows\call) FxArity FxRecordArity ReceiverIndex
        return: value pipe normalize double offset
    demo:
        throws: copy(FxThrows\call) FxArity FxRecordArity ReceiverIndex
        return: pipeline(-3)
```

pipe применяет стадии к фактическому значению и сохраняет точный результат последней стадии; его операндная и обычная формы используют один алгоритм ядра. Стадии normalize/double/offset в данном доменном примере принимают int, но общий проход этим типом не ограничен. Каждая стадия вызывается один раз по порядку; неизвестные свободные имена сохраняют обычную динамическую связь. compose отдельно строит функцию. Подготовленный вход и полный договор ошибок отражены в throws.

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

pipe применяет стадии к фактическому значению и сохраняет точный результат последней стадии; его операндная и обычная формы используют один алгоритм ядра. Стадии normalize/double/offset в данном доменном примере принимают int, но общий проход этим типом не ограничен. Каждая стадия вызывается один раз по порядку; неизвестные свободные имена сохраняют обычную динамическую связь. compose отдельно строит функцию. Подготовленный вход и полный договор ошибок отражены в throws.

## Сопоставление

Восстановлен исходный конечный договор 22-Nov и короткий LMX-клиент. Контрольные языки сохраняют естественные стандартные средства из 23-Nov. Узкая реализация LMX показана отдельно; более общий алгоритм 23-Nov имеет отдельный договор. Реализация LMX общая и обобщённая; контрольный клиент сохраняет оговорённый прикладной профиль. Это не утверждение равного полного охвата стандартных библиотек.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 302 | 17 |
| Java | 374 | 11 |
| Go | <span style="color:#176233"><u>246</u></span> | 6 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Independent transformations are connected in an ordered data flow.

**Separate implementation comparison:** [093. Pipe — implementation](093_pipe_implementation_comparision.md)

**Scenario.** For one item -3, normalize its sign, double it, then add 1.

**Expected observation.** 7; intermediate values are 3 and 6.

**LMX.** pipe applies stages to the actual typed value and preserves the final stage's result requirement. Its receiver and operand forms share the core algorithm. These three application stages use int, while the common traversal is generic. Each stage is reached once in order and dynamic binding is preserved. compose separately constructs a callable; the complete reached failures are declared.

**Comparison.** The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

**Scope and limitations.** One int flow in one sequential context; the fixture does not overflow. Stages have one int input and result and declare no recoverable failures. Queues, backpressure, and scheduling are excluded. Pipe implementation is excluded from client size but shown and measured separately for every language.

### Dependencies and execution boundaries

- **LMX:** pipe applies stages to the actual typed value and preserves the final stage's result requirement. Its receiver and operand forms share the core algorithm. These three application stages use int, while the common traversal is generic. Each stage is reached once in order and dynamic binding is preserved. compose separately constructs a callable; the complete reached failures are declared.
- **Java:** Uses the real java.util.function.IntUnaryOperator.andThen. The implementation in093 is not imported here.
- **Go:** Ordinary nested calls express this fixed pipeline; no custom pipe package is imported.

## Источники / Sources

- [Java IntUnaryOperator](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/function/IntUnaryOperator.html) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
