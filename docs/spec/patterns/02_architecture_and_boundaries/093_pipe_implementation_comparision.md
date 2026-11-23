# 093. Pipe — implementation

Реализовать импортируемую последовательную передачу значения по списку стадий.

**Примеры использования:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

## Общий сценарий

Получить начальный int и упорядоченный список callable int→int. Применить каждый один раз; при пустом списке вернуть исходное значение.

**Ожидаемое наблюдение:** Для -3 и стадий normalize,double,offset результаты 3,6,7; пустой список сохраняет -3.

**Граница сравнения:** Реализация библиотеки. Показана прикладная библиотека для int, а не асинхронный stream framework. Политика ошибок, отмена и многопоточность не добавлены. Все три реализации используют только базовые вызовы и циклы; native/LMX исполнение здесь не заявлено.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
PipeLibrary:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    pipe:
        int: value \left
        int: i 0
        while: i < length(right)
            @: stage \right[i]
            value := stage(value)
            i += 1
        return: value
```

copy: sys\OPERANDS_TEMPLATE явно предоставляет left, right и готовые свойства режима 0 / приоритета +. pipe — намеренно вариадический операнд: один левый int, ноль или больше правых callable int→int. int: value \left получает подготовленное значение; \right[i] получает сохранённую ссылку на стадию, а stage(value) уже вызывает её. Цикл, порядок, промежуточное значение и поведение пустого списка показаны полностью. Метод не сохраняет указатели на временные операндные ячейки.

[Отдельный листинг](examples/lmx/093_pipe_implementation.lm3)

## Java

```java
package examplelib;
import java.util.function.IntUnaryOperator;
public final class Pipe {
    public static int apply(int value, IntUnaryOperator... stages) {
        for (IntUnaryOperator stage : stages) value = stage.applyAsInt(value);
        return value;
    }
}
```

Полный examplelib/Pipe.java. IntUnaryOperator задаёт только контракт вызова; обход реализован здесь.

[Отдельный листинг](examples/java/093_pipe_implementation.java)

## Go

```go
package pipe
func Apply(value int, stages ...func(int) int) int {
    for _, stage := range stages { value = stage(value) }
    return value
}
```

Полный pipe/pipe.go в модуле example; Apply не использует готовую функцию конвейера.

[Отдельный листинг](examples/go/093_pipe_implementation.go)

## Разбор LMX

copy: sys\OPERANDS_TEMPLATE явно предоставляет left, right и готовые свойства режима 0 / приоритета +. pipe — намеренно вариадический операнд: один левый int, ноль или больше правых callable int→int. int: value \left получает подготовленное значение; \right[i] получает сохранённую ссылку на стадию, а stage(value) уже вызывает её. Цикл, порядок, промежуточное значение и поведение пустого списка показаны полностью. Метод не сохраняет указатели на временные операндные ячейки.

## Сопоставление

В LMX общий исполнитель формирует right, а библиотека явно выполняет обход. Java использует int-specialized functional interface, Go — обычные функции и variadic slice. Ни один вариант не импортирует готовый Pipe или готовый pipeline/fold для реализации самого Pipe. Обобщённая версия 23-Nov сохранена [отдельно](extended_comparisons/093_pipe_implementation_generalized_comparision.md); она не подменяет эту узкую задачу.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/093_pipe_implementation_generalized_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 145 | 11 | 145 |
| Java | 215 | 8 | — |
| Go | 111 | 5 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Implement the imported sequential handoff through a stage list.

**Usage examples:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

**Scenario.** Receive an int and an ordered list of int→int callables. Apply each once; return the input for an empty list.

**Expected observation.** For -3 with normalize,double,offset the intermediate values are 3,6,7; an empty list preserves -3.

**LMX.** copy: sys\OPERANDS_TEMPLATE provides left/right and ready mode 0 / additive priority. pipe is deliberately variadic: one left int and zero or more right int→int callables. int: value \left reads the prepared value; \right[i] yields the stored stage reference, and stage(value) invokes it. The loop, order, intermediate value, and empty-list behavior are explicit. No temporary operand-cell pointer escapes.

**Comparison.** The expression executor forms LMX right; the library explicitly iterates it. Java uses an int-specialized functional interface, Go ordinary functions and a variadic slice. None imports the ready Pipe or a ready pipeline/fold to implement Pipe. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

**Scope and limitations.** This is an int application library, not an asynchronous stream framework. Error policy, cancellation, and concurrency are not added. All implementations use basic calls and loops; no native or LMX execution is claimed.

### Dependencies and execution boundaries

- **LMX:** copy: sys\OPERANDS_TEMPLATE provides left/right and ready mode 0 / additive priority. pipe is deliberately variadic: one left int and zero or more right int→int callables. int: value \left reads the prepared value; \right[i] yields the stored stage reference, and stage(value) invokes it. The loop, order, intermediate value, and empty-list behavior are explicit. No temporary operand-cell pointer escapes.
- **Java:** Complete examplelib/Pipe.java. IntUnaryOperator supplies the call contract only; iteration is implemented here.
- **Go:** Complete pipe/pipe.go in module example; Apply uses no ready pipeline function.

## Источники / Sources

- [Gregor Hohpe and Bobby Woolf — Pipes and Filters](https://www.enterpriseintegrationpatterns.com/patterns/messaging/PipesAndFilters.html) — Независимые стадии и соединяющие каналы.
- [Oracle — IntUnaryOperator](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/function/IntUnaryOperator.html) — Контракт int→int и прямой applyAsInt.
- [Go specification — variadic parameters](https://go.dev/ref/spec#Passing_arguments_to_..._parameters) — Передача вариадического списка как slice и его порядок.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
