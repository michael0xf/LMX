# 092. Trampoline container and runner implementation

Обобщённый Bounce хранит запись произвольного результата либо nullary thunk; runner не знает тип результата или исходную арность шага.

**Клиенты готовых средств:** [083. Trampoline](083_trampoline_comparision.md). Они не подключают показанные здесь foreign-реализации.

## Общий сценарий

Реализовать done(record), more(thunk) и trampoline(bounce). more сохраняет функцию без вызова; runner вызывает её ровно один раз на итерацию и возвращает результат done. Частичное связывание аргументов вынесено в общий partial.

**Ожидаемое наблюдение:** trampoline(done(record)) возвращает ту же запись результата без вызова continuation. Каждый more запускает сохранённый thunk один раз. Пример чётности даёт 1,0,0 в LMX и true,false,false в контролях, не накапливая рекурсивный стек шагов.

**Граница сравнения.** Полные реализации заявленного компонента сопоставлены отдельно от его использования. Они не заявляются исходниками всего пакета стандартной библиотеки.

## LMX — прямой API ядра

```lmx
FxBounce:
    int: done 0
    @: value 0
    @: next 0

FxDone:
    private: @: value
    return: @
    done:
        private: @: result (copy(FxBounce))
        result\done := 1
        result\value := value
        return: result

FxMore:
    private: @: thunk
    return: @
    more:
        throws: FxArity FxKernelFailure FxTypeToken
        private: @: shape FxKernel\signature(subject := thunk)
        if: length(shape\inputTypes) != 0
            throw: FxArity()
        private: @: result (copy(FxBounce))
        result\next := thunk
        return: result

FxTrampoline:
    private: FxBounce@: current
    return: @
    trampoline:
        throws: copy(FxThrows\call)
        private: @: empty (copy(()))
        while: current\done = 0
            private: @: record FxApply\apply(current\next; empty)
            current := \record
        return: current\value
```

Основной листинг — точные определения FxBounce, FxDone, FxMore, FxTrampoline из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

[Исходник](examples/lmx/092_trampoline_container_and_runner_implementation.lm3)

## Haskell — самостоятельная реализация

```haskell
module Bounce (Bounce, done, more, run) where

data Bounce a = Done a | More (() -> Bounce a)

done :: a -> Bounce a
done = Done

more :: (() -> Bounce a) -> Bounce a
more = More

run :: Bounce a -> a
run (Done answer) = answer
run (More next) = run (next ())
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/haskell/092_trampoline_container_and_runner_implementation.hs)

## Scala — самостоятельная реализация

```scala
object Bounce {
  enum Value[+A] {
    case Done(answer: A)
    case More(next: () => Value[A])
  }
  def done[A](answer: A): Value[A] = Value.Done(answer)
  def more[A](next: () => Value[A]): Value[A] = Value.More(next)
  @annotation.tailrec
  def run[A](current: Value[A]): A = current match {
    case Value.Done(answer) => answer
    case Value.More(next) => run(next())
  }
}
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/scala/092_trampoline_container_and_runner_implementation.scala)

## Подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 591 | 33 |
| Haskell | 198 | 9 |
| Scala | 303 | 13 |

Считается только `listings[].code`, включая импорты, объявления и throws. Альтернативный подход не прибавляется к основному. [Выбор](variant_selection.json) сравнивает допустимые варианты одной границы. [Зависимости реализации](IMPLEMENTATION_DEPENDENCIES.md) показывают общие LMX-тела отдельно.

## Удалённые малозначимые повторы

Удалены полные повторы, отличавшиеся импортом, написанием вызова, повторением общего тела либо специализацией на int. Эти отличия не образуют отдельного текущего алгоритма; исходная редакция сохраняется в базе diff.

## Семантические границы

Контейнер обобщён по результату, но протокол шага намеренно nullary→Bounce. Это математическая форма батута, а не случайная специализация на одном int-аргументе. У произвольной исходной функции аргументы связывает partial с произвольной сигнатурой. Полный заявленный API здесь — конструкторы/bind либо done/more/runner; весь набор методов Maybe, Option, Free или TailCalls не заявлен.

[Политика очистки, ошибок и Message/post](FAILURE_BOUNDARIES.md).

## English explanation

Generic Bounce holds an arbitrary result record or a nullary thunk; the runner does not know the result type or the original step arity.

**Scenario.** Implement done(record), more(thunk) and trampoline(bounce). more stores the function without calling it; the runner calls it exactly once per iteration and returns the done result. Argument binding belongs to generic partial.

**Expected.** trampoline(done(record)) returns that result record without invoking a continuation. Each more invokes the retained thunk once. Parity yields 1,0,0 in LMX and true,false,false in the controls without accumulating a recursive step stack.

**Limits.** The result is generic, while the step protocol intentionally remains nullary→Bounce. That is the trampoline protocol, not accidental specialization to one int argument. partial binds arguments of an arbitrary original signature. The scoped API is the complete constructor/bind or done/more/runner component shown here, not every method of Maybe, Option, Free or TailCalls.

Usage clients call the real language/library facility. Adjacent foreign implementations are independent comparison subjects and are not imported by usage clients. Only genuinely different approaches remain. The source listings have not been executed by an LMX/Haskell/Scala runtime in this workspace.

## Источники / Sources

- [Scala TailCalls API](https://www.scala-lang.org/api/current/scala/util/control/TailCalls%24.html)
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html)
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html)
- [Scala tailrec annotation](https://www.scala-lang.org/api/current/scala/annotation/tailrec.html)

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [источники ядра](../LMX_Fn_Receivers/README.md).

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) сверяет данные, исходники, отсутствие подмены библиотечных клиентов и границы подсчёта. [Acceptance matrix](acceptance_cases.json) отделяет подготовленные наблюдения от реального запуска.
