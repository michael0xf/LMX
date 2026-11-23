# 093. Pipe — generic implementation

Реализовать обобщённую последовательную композицию без привязки к int.

**Примеры использования:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

## Общий сценарий

Скомпоновать A→B и B→C в A→C; вызвать этапы по одному разу и не выполнять второй при отказе первого.

**Ожидаемое наблюдение:** Пример с int возвращает7; string→length→Boolean тоже допустим; отказ первого этапа пропускает второй.

**Граница сравнения:** Реализация библиотеки. Это последовательная композиция, не stream scheduler. Асинхронные адресованные вызовы уже обеспечивает post; потоки внутри pipe изменили бы его договор. Общие adapter bridges учитываются как зависимости.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
FxCompositionState:
    @: outer 0
    @: inner 0

FxCompositionEngine:
    private:
        @: state
        @: frame
    return: @
    run:
        throws: copy(FxThrows\call)
        private: @: middle FxFrameApply\apply(frame)
        return: FxApply\apply(state\outer; FxOne\make(middle))

FxCompose:
    private:
        @: outer
        @: inner
    return: @
    compose:
        throws: copy(FxThrows\adapter)
        private: @: a FxKernel\signature(subject := outer)
        private: @: b FxKernel\signature(subject := inner)
        if: length(a\inputTypes) != 1 || b\hasResult = 0
            throw: FxArity()
        private: @: contract FxSignatures\make(b\inputTypes; a\resultType)
        private: @: state (copy(FxCompositionState))
        state\outer := outer
        state\inner := inner
        private: @: failures FxFailures\union(a\throws; b\throws)
        return: FxWrap\make(contract; FxCompositionEngine\run; state; failures; FxFullPolicy\make(inner))

FxPipe:
    private:
        @: first
        @: second
    return: @
    pipe:
        throws: copy(FxThrows\adapter)
        return: FxCompose\compose(outer := second; inner := first)
```

Точные тела FxCompose/FxPipe из исходников ядра. Общий typed-call/admission bridge указан в каталоге зависимостей; алгоритм композиции показан полностью.

[Отдельный листинг](examples/lmx/093_pipe_implementation.lm3)

## Java

```java
import java.util.Objects;
import java.util.function.Function;
public final class Pipe {
    private Pipe() {}
    public static <A,B,C> Function<A,C> pipe(
        Function<? super A,? extends B> first,
        Function<? super B,? extends C> second) {
        Objects.requireNonNull(first); Objects.requireNonNull(second);
        return value -> second.apply(first.apply(value));
    }
}
```

Самостоятельная реализация generic композиции; не вызывает andThen и не импортируется клиентом013. Исключения передаются вызывающему.

[Отдельный листинг](examples/java/093_pipe_implementation.java)

## Go

```go
package pipecomparison
func Pipe[A,B,C any](first func(A) B, second func(B) C) func(A) C {
    if first == nil || second == nil { panic("nil pipeline stage") }
    return func(value A) C { return second(first(value)) }
}
```

Самостоятельная generic композиция двух стадий; любое конечное число строится повторной композицией. panic стадии не скрывается.

[Отдельный листинг](examples/go/093_pipe_implementation.go)

## Разбор LMX

Точные тела FxCompose/FxPipe из исходников ядра. Общий typed-call/admission bridge указан в каталоге зависимостей; алгоритм композиции показан полностью.

## Сопоставление

Все три реализации хранят callable и явно компонуют обычные вызовы. LMX сохраняет исходные inputs и declared failures через общий адаптер; Java/Go используют generic-типы.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 839 | 37 |
| Java | 308 | 11 |
| Go | 178 | 5 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Implement generic ordered function composition without an int-only adapter.

**Usage examples:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

**Scenario.** Compose A→B and B→C to A→C, evaluate first then second exactly once, and relay failures without executing the second stage after first-stage failure.

**Expected observation.** The int fixture returns7; a heterogeneous string→length→Boolean fixture also works; a failure in the first stage skips the second.

**LMX.** Exact FxCompose/FxPipe core bodies. Common typed-call/admission bridges are identified separately; the composition algorithm is complete.

**Comparison.** All three implementations retain callable references and explicitly compose ordinary calls. LMX preserves its exact source input policy and declared failure set through the shared adapter mechanism. Java and Go use static generic parameters.

**Scope and limitations.** This is sequential composition, not a stream scheduler. Existing post already provides asynchronous addressed calls; adding threads inside pipe would change its ordered value contract. Core adapter bridges are shared dependencies, not omitted pipe algorithms.

### Dependencies and execution boundaries

- **LMX:** Exact FxCompose/FxPipe core bodies. Common typed-call/admission bridges are identified separately; the composition algorithm is complete.
- **Java:** Standalone generic composition; it neither calls andThen nor is imported by013. Exceptions propagate to the caller.
- **Go:** Standalone generic two-stage composition; repeated composition handles any finite chain. Stage panics are not hidden.

## Источники / Sources

- [Java Function composition](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/function/Function.html) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
