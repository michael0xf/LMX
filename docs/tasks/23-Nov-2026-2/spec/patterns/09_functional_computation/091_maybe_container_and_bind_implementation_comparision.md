# 091. Maybe container and bind implementation

Обобщённый Maybe: наличие отделено от нуля, null, void и физического uninit; bind допускает изменение типа полезного значения.

**Клиенты готовых средств:** [082. Monad](082_monad_comparision.md). Они не подключают показанные здесь foreign-реализации.

## Общий сценарий

Реализовать some(record), none() и bind(input,next). Полезное значение хранится как запись {type,payload}; отсутствие определяется только флагом present. При наличии next вызывается ровно один раз с полезным значением.

**Ожидаемое наблюдение:** some записи нуля остаётся присутствующим нулём; some записи null остаётся присутствующим null. none не читает value и bind(none,next) не вызывает next. Следующий результат может хранить другой тип.

**Граница сравнения.** Полные реализации заявленного компонента сопоставлены отдельно от его использования. Они не заявляются исходниками всего пакета стандартной библиотеки.

## LMX — прямой API ядра

```lmx
FxMaybe:
    int: present 0
    @: value 0

FxSome:
    private: @: value
    return: @
    some:
        private: @: result (copy(FxMaybe))
        result\present := 1
        result\value := value
        return: result

FxNone:
    return: @
    none:
        return: (copy(FxMaybe))

FxBind:
    private:
        FxMaybe@: input
        @: next
    return: @
    bind:
        throws: copy(FxThrows\call)
        if: input\present = 0
            return: input
        private: @: record FxApply\apply(next; FxOne\make(input\value))
        private: FxMaybe@: result record
        return: result
```

Основной листинг — точные определения FxMaybe, FxSome, FxNone, FxBind из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

[Исходник](examples/lmx/091_maybe_container_and_bind_implementation.lm3)

## Haskell — самостоятельная реализация

```haskell
module MaybeValue (MaybeValue(..), some, none, bind) where

data MaybeValue a = Absent | Present a deriving (Eq, Show)

some :: a -> MaybeValue a
some = Present

none :: MaybeValue a
none = Absent

infixl 1 `bind`
bind :: MaybeValue a -> (a -> MaybeValue b) -> MaybeValue b
bind Absent _ = Absent
bind (Present value) next = next value
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/haskell/091_maybe_container_and_bind_implementation.hs)

## Scala — самостоятельная реализация

```scala
object MaybeValue {
  enum Value[+A] {
    case Absent extends Value[Nothing]
    case Present(value: A)
    def bind[B](next: A => Value[B]): Value[B] = this match {
      case Absent => Absent
      case Present(value) => next(value)
    }
  }
  def some[A](value: A): Value[A] = Value.Present(value)
  def none[A](): Value[A] = Value.Absent
}
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/scala/091_maybe_container_and_bind_implementation.scala)

## Подсчёт

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 390 | 27 | 390 |
| Haskell | 271 | 10 | — |
| Scala | 265 | 12 | — |

Считается только `listings[].code`, включая импорты, объявления и throws. Альтернативный подход не прибавляется к основному. [Выбор](variant_selection.json) сравнивает допустимые варианты одной границы. [Зависимости реализации](IMPLEMENTATION_DEPENDENCIES.md) показывают общие LMX-тела отдельно.

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основная цена включает их полностью. Дополнительная колонка оставляет заголовок и первый написанный аргумент списка; copy/ссылка сохраняется целиком, общий банк учитывается один раз с первым аргументом. Это только другой подсчёт, не сокращение исходника или контракта.

## Удалённые малозначимые повторы

Удалены полные повторы, отличавшиеся импортом, написанием вызова, повторением общего тела либо специализацией на int. Эти отличия не образуют отдельного текущего алгоритма; исходная редакция сохраняется в базе diff.

## Семантические границы

Maybe не исполняет uninit-полезное значение автоматически: попытка передать его продолжению соблюдает обычное правило чтения uninit. Некоторые допустимые записи (например void) могут храниться, но continuation обязан иметь совместимый контракт. Публичная мутация контейнеров исключена договором этой библиотеки. Полный заявленный API здесь — конструкторы/bind либо done/more/runner; весь набор методов Maybe, Option, Free или TailCalls не заявлен.

[Политика очистки, ошибок и Message/post](FAILURE_BOUNDARIES.md).

## English explanation

Generic Maybe separates presence from zero, null, void and physical uninit; bind may change the payload type.

**Scenario.** Implement some(record), none() and bind(input,next). The payload is a typed value record; only the present tag determines absence. For presence, next is called exactly once with the payload.

**Expected.** some of zero remains present zero; some of null remains present null. none does not read value and bind(none,next) does not call next. The next result may carry a different type.

**Limits.** Maybe does not automatically execute or initialize an uninitialized payload: passing it to a continuation follows normal uninit-read rules. Records such as void can be represented, but the continuation must accept the corresponding contract. This library excludes external mutation of published containers. The scoped API is the complete constructor/bind or done/more/runner component shown here, not every method of Maybe, Option, Free or TailCalls.

Usage clients call the real language/library facility. Adjacent foreign implementations are independent comparison subjects and are not imported by usage clients. Only genuinely different approaches remain. The source listings have not been executed by an LMX/Haskell/Scala runtime in this workspace.

## Источники / Sources

- [Haskell 2010 Report, predefined types and Monad](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html)
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html)
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html)

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [источники ядра](../LMX_Fn_Receivers/README.md).

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) сверяет данные, исходники, отсутствие подмены библиотечных клиентов и границы подсчёта. [Acceptance matrix](acceptance_cases.json) отделяет подготовленные наблюдения от реального запуска.
