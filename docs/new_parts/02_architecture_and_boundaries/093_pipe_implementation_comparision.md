# 093. Pipe — implementation

Реализовать импортируемую последовательную передачу значения по списку стадий.

**Примеры использования:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

## Общий сценарий

Получить начальный int и упорядоченный список callable int→int. Применить каждый один раз; при пустом списке вернуть исходное значение.

**Ожидаемое наблюдение:** Для -3 и стадий normalize,double,offset результаты 3,6,7; пустой список сохраняет -3.

**Граница сравнения:** Реализация библиотеки. Показана прикладная библиотека для int, а не асинхронный stream framework. Политика ошибок, отмена и многопоточность не добавлены. Все три реализации используют только базовые вызовы и циклы; native/LMX исполнение здесь не заявлено.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

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

В LMX общий исполнитель формирует right, а библиотека явно выполняет обход. Java использует int-specialized functional interface, Go — обычные функции и variadic slice. Ни один вариант не импортирует готовый Pipe или готовый pipeline/fold для реализации самого Pipe.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 145 | 11 |
| Java | 215 | 8 |
| Go | 111 | 5 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Implement the imported sequential handoff through a stage list.

**Usage examples:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

**Scenario.** Receive an int and an ordered list of int→int callables. Apply each once; return the input for an empty list.

**Expected observation.** For -3 with normalize,double,offset the intermediate values are 3,6,7; an empty list preserves -3.

**LMX.** copy: sys\OPERANDS_TEMPLATE provides left/right and ready mode 0 / additive priority. pipe is deliberately variadic: one left int and zero or more right int→int callables. int: value \left reads the prepared value; \right[i] yields the stored stage reference, and stage(value) invokes it. The loop, order, intermediate value, and empty-list behavior are explicit. No temporary operand-cell pointer escapes.

**Comparison.** The expression executor forms LMX right; the library explicitly iterates it. Java uses an int-specialized functional interface, Go ordinary functions and a variadic slice. None imports the ready Pipe or a ready pipeline/fold to implement Pipe.

**Scope and limitations.** This is an int application library, not an asynchronous stream framework. Error policy, cancellation, and concurrency are not added. All implementations use basic calls and loops; no native or LMX execution is claimed.

### Dependencies and execution boundaries

- **LMX:** copy: sys\OPERANDS_TEMPLATE provides left/right and ready mode 0 / additive priority. pipe is deliberately variadic: one left int and zero or more right int→int callables. int: value \left reads the prepared value; \right[i] yields the stored stage reference, and stage(value) invokes it. The loop, order, intermediate value, and empty-list behavior are explicit. No temporary operand-cell pointer escapes.
- **Java:** Complete examplelib/Pipe.java. IntUnaryOperator supplies the call contract only; iteration is implemented here.
- **Go:** Complete pipe/pipe.go in module example; Apply uses no ready pipeline function.

## Источники / Sources

- [Gregor Hohpe and Bobby Woolf — Pipes and Filters](https://www.enterpriseintegrationpatterns.com/patterns/messaging/PipesAndFilters.html) — Независимые стадии и соединяющие каналы.
- [Oracle — IntUnaryOperator](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/function/IntUnaryOperator.html) — Контракт int→int и прямой applyAsInt.
- [Go specification — variadic parameters](https://go.dev/ref/spec#Passing_arguments_to_..._parameters) — Передача вариадического списка как slice и его порядок.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
