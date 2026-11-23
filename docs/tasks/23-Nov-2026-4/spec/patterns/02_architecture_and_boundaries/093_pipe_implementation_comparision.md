# 093. Pipe — implementation

Общий pipe применяет стадии к значению; его фактический тип может меняться между стадиями.

**Примеры использования:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

## Общий сценарий

Получить начальный int и упорядоченный список callable int→int. Применить каждый один раз; при пустом списке вернуть исходное значение.

**Ожидаемое наблюдение:** Для -3 и стадий normalize,double,offset результаты 3,6,7; пустой список сохраняет -3.

**Граница сравнения:** Реализация библиотеки. LMX показывает общий алгоритм с фактическими типами и исходным контекстом. Контрольные реализации сохраняют явно указанный прикладной профиль. Сравнение одного профиля не означает одинакового охвата библиотек или скорости; для полной стоимости прибавляются общие зависимости и runtime каждого языка.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
FxPipe:
    private:
        @: value
        @: stages
    required: value stages
    return: @
    pipe:
        throws: copy(FxThrows\call) FxArity ReceiverIndex
        FxSeqInfo\get(stages)
        private: @: current value
        private: int: i 0
        while: i < length(stages)
            private: @: stage \FxSeqRead\read(stages; i)
            private: @: shape FxKernel\signature(stage)
            if: length(shape\inputTypes) != 1 || shape\hasResult = 0
                throw: FxArity()
            current := FxApply\apply(stage; FxOne\make(current))
            i += 1
        return: current
```

Точное текущее определение FxPipe извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

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

Точное текущее определение FxPipe извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

## Сопоставление

В LMX общий исполнитель формирует right, а библиотека явно выполняет обход. Java использует int-specialized functional interface, Go — обычные функции и variadic slice. Ни один вариант не импортирует готовый Pipe или готовый pipeline/fold для реализации самого Pipe. Обобщённая версия 23-Nov сохранена [отдельно](extended_comparisons/093_pipe_implementation_generalized_comparision.md); она не подменяет эту узкую задачу.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/093_pipe_implementation_generalized_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 399 | 19 |
| Java | 215 | 8 |
| Go | 111 | 5 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Generic pipe applies stages to a value whose actual type may change between stages.

**Usage examples:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

**Scenario.** Receive an int and an ordered list of int→int callables. Apply each once; return the input for an empty list.

**Expected observation.** For -3 with normalize,double,offset the intermediate values are 3,6,7; an empty list preserves -3.

**LMX.** The exact current FxPipe definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.

**Comparison.** The expression executor forms LMX right; the library explicitly iterates it. Java uses an int-specialized functional interface, Go ordinary functions and a variadic slice. None imports the ready Pipe or a ready pipeline/fold to implement Pipe. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

**Scope and limitations.** LMX shows the common algorithm with actual types and original context. Foreign implementations retain the stated application profile. A comparison for one profile does not establish equal library coverage or speed; complete cost includes shared dependencies and each runtime.

### Dependencies and execution boundaries

- **LMX:** The exact current FxPipe definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.
- **Java:** Complete examplelib/Pipe.java. IntUnaryOperator supplies the call contract only; iteration is implemented here.
- **Go:** Complete pipe/pipe.go in module example; Apply uses no ready pipeline function.

## Источники / Sources

- [Gregor Hohpe and Bobby Woolf — Pipes and Filters](https://www.enterpriseintegrationpatterns.com/patterns/messaging/PipesAndFilters.html) — Независимые стадии и соединяющие каналы.
- [Oracle — IntUnaryOperator](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/function/IntUnaryOperator.html) — Контракт int→int и прямой applyAsInt.
- [Go specification — variadic parameters](https://go.dev/ref/spec#Passing_arguments_to_..._parameters) — Передача вариадического списка как slice и его порядок.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
