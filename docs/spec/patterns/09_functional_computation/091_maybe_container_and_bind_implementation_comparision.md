# 091. Maybe container and bind implementation

Обобщённый Maybe: наличие отделено от нуля, null, void и физического uninit; bind допускает изменение типа полезного значения.

## Общий сценарий

Реализовать some(record), none() и bind(input,next). Полезное значение хранится как запись {type,payload}; отсутствие определяется только флагом present. При наличии next вызывается ровно один раз с полезным значением.

**Ожидается:** some записи нуля остаётся присутствующим нулём; some записи null остаётся присутствующим null. none не читает value и bind(none,next) не вызывает next. Следующий результат может хранить другой тип.

Клиенты: [082. Monad](082_monad_comparision.md). Одно тело ядра обслуживает обе формы записи.

## LMX — единая общая реализация

```lmx
FxMaybe:
    int: present 0
    @: value 0

FxSome:
    private: @: value
    required: value
    return: FxMaybe@
    some:
        private: @: result (copy(FxMaybe))
        result\present := 1
        result\value := value
        return: result

FxNone:
    return: FxMaybe@
    none:
        return: (copy(FxMaybe))

FxBind:
    private:
        FxMaybe@: input
        @: next
    required: input next
    return: FxMaybe@
    bind:
        throws: copy(FxThrows\call)
        if: input\present = 0
            return: input
        private: @: record FxApply\apply(next; FxOne\make(input\value))
        private: FxMaybe@: result \record
        return: result
```

[Исходник](examples/lmx/091_maybe_container_and_bind_implementation.lm3)

Основной листинг — точные определения FxMaybe, FxSome, FxNone, FxBind из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

## Haskell

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

## Scala

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

## Подсчёт полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — общая реализация | 444 | 29 |
| Haskell | 271 | 10 |
| Scala | <span style="color:#176233"><u>265</u></span> | 12 |

Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.

Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.

## Семантические границы

Maybe не исполняет uninit-полезное значение автоматически: попытка передать его продолжению соблюдает обычное правило чтения uninit. Некоторые допустимые записи (например void) могут храниться, но continuation обязан иметь совместимый контракт. Публичная мутация контейнеров исключена договором этой библиотеки. Полный заявленный API здесь — конструкторы/bind либо done/more/runner; весь набор методов Maybe, Option, Free или TailCalls не заявлен.

[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).

## English explanation

Generic Maybe separates presence from zero, null, void and physical uninit; bind may change the payload type.

**Scenario.** Implement some(record), none() and bind(input,next). The payload is a typed value record; only the present tag determines absence. For presence, next is called exactly once with the payload.

**Expected.** some of zero remains present zero; some of null remains present null. none does not read value and bind(none,next) does not call next. The next result may carry a different type.

**Limits.** Maybe does not automatically execute or initialize an uninitialized payload: passing it to a continuation follows normal uninit-read rules. Records such as void can be represented, but the continuation must accept the corresponding contract. This library excludes external mutation of published containers. The scoped API is the complete constructor/bind or done/more/runner component shown here, not every method of Maybe, Option, Free or TailCalls.

Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.

## Источники

- [Haskell 2010 Report, predefined types and Monad](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html)
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html)
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html)

## Проверка

[Проверка публикации](VALIDATION_2026-11-26.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.
