# 093. Compose — generic implementation: общий договор

Действующие общие определения извлечены из единого ядра. Эта отдельная пара сохраняет свой договор; её размер не подменяет размер клиентского вызова.

## Договор

Скомпоновать A→B и B→C в A→C; вызвать этапы по одному разу и не выполнять второй при отказе первого.

Пример с int возвращает7; string→length→Boolean тоже допустим; отказ первого этапа пропускает второй.

Композиция строится без выполнения стадий. inner получает исходные входы, outer принимает один результат; итоговый тип и контекст сохраняются. Сравнение не является stream scheduler.

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
```

[Исходник](source/lmx/093_pipe_implementation_generalized.lm3)

Точные общие определения FxCompositionState, FxCompositionEngine, FxCompose из текущего ядра. Общий договор сохраняет явно указанные типы, контекст вызова и отказы. Копия обновляется из единственного исходника; runtime LMX — NOT_RUN.

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
| LMX | 715 |
| Java | 308 |
| Go | 178 |

Полный текст каждого листинга включает все объявления, заголовки Throws, аргументы и ссылки; исключений из подсчёта нет.

[Основная пара](../093_pipe_implementation_comparision.md). [Единые формы](../../UNIFIED_OPERATIONS.md).

Результаты языкового выполнения изменённых исходников не заявлены.
