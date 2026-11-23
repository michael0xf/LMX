# 093. Pipe — generic implementation: отдельный расширенный договор

Сохранена самостоятельная обобщённая реализация 23-Nov. Она решает более широкую задачу, чем восстановленная основная пара 22-Nov, и не участвует в её сумме или выборе кратчайшего листинга.

## Договор

Скомпоновать A→B и B→C в A→C; вызвать этапы по одному разу и не выполнять второй при отказе первого.

Пример с int возвращает7; string→length→Boolean тоже допустим; отказ первого этапа пропускает второй.

Это последовательная композиция, не stream scheduler. Асинхронные адресованные вызовы уже обеспечивает post; потоки внутри pipe изменили бы его договор. Общие adapter bridges учитываются как зависимости.

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

[Исходник](source/lmx/093_pipe_implementation_generalized.lm3)

Точные тела FxCompose/FxPipe из исходников ядра. Общий typed-call/admission bridge указан в каталоге зависимостей; алгоритм композиции показан полностью.

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

[Исходник](source/java/093_pipe_implementation_generalized.java)

Самостоятельная реализация generic композиции; не вызывает andThen и не импортируется клиентом013. Исключения передаются вызывающему.

## Go

```go
package pipecomparison
func Pipe[A,B,C any](first func(A) B, second func(B) C) func(A) C {
    if first == nil || second == nil { panic("nil pipeline stage") }
    return func(value A) C { return second(first(value)) }
}
```

[Исходник](source/go/093_pipe_implementation_generalized.go)

Самостоятельная generic композиция двух стадий; любое конечное число строится повторной композицией. panic стадии не скрывается.

## Измерение отдельной реализации

| Язык | Непробельные символы |
| --- | ---: |
| LMX | 839 |
| Java | 308 |
| Go | 178 |

[Основная узкая пара](../093_pipe_implementation_comparision.md). [Норма LMX](../../../LMX_semantics.en.md).

LMX здесь не выполнялся. Это сохранение исходников и их договора, а не новый отчёт о runtime-проверке.
