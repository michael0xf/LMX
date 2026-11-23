# 091. Maybe container and bind implementation

Обобщённый Maybe: наличие отделено от нуля, null, void и физического uninit; bind допускает изменение типа полезного значения.

**Примеры использования:** [082. Monad](082_monad_comparision.md)

## Общий сценарий

Реализовать some(record), none() и bind(input,next). Полезное значение хранится как запись {type,payload}; отсутствие определяется только флагом present. При наличии next вызывается ровно один раз с полезным значением.

**Ожидаемое наблюдение:** some записи нуля остаётся присутствующим нулём; some записи null остаётся присутствующим null. none не читает value и bind(none,next) не вызывает next. Следующий результат может хранить другой тип.

Основные варианты: LMX — **текущее ядро**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Клиенты используют один текущий компонент; исторические специализированные формы остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: текущее ядро

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
        throws:
            FxCallFailure
            FxKernelFailure
            FxTypeToken
        if: input\present = 0
            return: input
        private: @: record FxApply\apply(next; FxOne\make(input\value))
        private: FxMaybe@: result record
        return: result
```

Основной листинг — точные определения FxMaybe, FxSome, FxNone, FxBind из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

[Основной листинг](examples/lmx/091_maybe_container_and_bind_implementation.lm3)

## Haskell — основной: обобщённая реализация

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

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

[Основной листинг](examples/haskell/091_maybe_container_and_bind_implementation.hs)

## Scala — основной: обобщённая реализация

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

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

[Основной листинг](examples/scala/091_maybe_container_and_bind_implementation.scala)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 410 | 30 |
| Haskell | 271 | 10 |
| Scala | 265 | 12 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

```lmx
MaybeValue:
    int: present 0
    int: value 0

Maybe:
    int: value
    return: @
    unit:
        @: result (copy(MaybeValue))
        result\present := 1
        result\value := value
        return: result
    none:
        return: MaybeValue

MaybeOps:
    copy: sys\OPERANDS_TEMPLATE
    return: @
    bind:
        MaybeValue@: input \left
        @: next \right[0]
        if: input\present = 0
            return: input
        return: next(input\value)
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module MaybeInt (MaybeInt(..), unit, none, bind) where

data MaybeInt = Absent | Present Int deriving (Eq, Show)

unit :: Int -> MaybeInt
unit = Present

none :: MaybeInt
none = Absent

infixl 1 `bind`
bind :: MaybeInt -> (Int -> MaybeInt) -> MaybeInt
bind Absent _ = Absent
bind (Present value) next = next value
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
object MaybeInt {
  enum Value {
    case Absent
    case Present(value: Int)
    def bind(next: Int => Value): Value = this match {
      case Absent => Absent
      case Present(value) => next(value)
    }
  }
  def unit(value: Int): Value = Value.Present(value)
  def none(): Value = Value.Absent
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Это сравнение реализации одного общего Maybe-компонента: основной LMX показывает some, none и bind с произвольной типизированной записью, а не вызов скрытой готовой операции. Haskell/Scala также показывают общие по payload контейнеры и bind. Технический мост вызова и срок жизни результата раскрыты отдельно; старый MaybeInt не соответствует общему контракту.

**Основной LMX.** Показанные определения извлечены из src/containers.lmx. Значение @ здесь — адрес типизированной записи, а не обещание, что полезный тип тоже @. Вызов continuation выполняет общий apply; его инфраструктура и сохранение результата описаны отдельно. Фиксированы только два варианта Maybe, не количество типов или аргументов пользовательской функции.

**Наблюдаемый общий сценарий.** Maybe не исполняет uninit-полезное значение автоматически: попытка передать его продолжению соблюдает обычное правило чтения uninit. Некоторые допустимые записи (например void) могут храниться, но continuation обязан иметь совместимый контракт. Публичная мутация контейнеров исключена договором этой библиотеки.

**Возможности общего ядра.** Maybe не исполняет uninit-полезное значение автоматически: попытка передать его продолжению соблюдает обычное правило чтения uninit. Некоторые допустимые записи (например void) могут храниться, но continuation обязан иметь совместимый контракт. Публичная мутация контейнеров исключена договором этой библиотеки.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; основной пример bracket проверяет этот договор явно.

## English explanation

Generic Maybe separates presence from zero, null, void and physical uninit; bind may change the payload type.

**Usage examples:** [082. Monad](082_monad_comparision.md)

**Scenario.** Implement some(record), none() and bind(input,next). The payload is a typed value record; only the present tag determines absence. For presence, next is called exactly once with the payload.

**Expected observation.** some of zero remains present zero; some of null remains present null. none does not read value and bind(none,next) does not call next. The next result may carry a different type.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Specialized historical implementations do not satisfy the full generalized current contract. There is one current component implementation; historical specialized code is not offered as another library dependency.

**Primary LMX.** Definitions are extracted from src/containers.lmx. The @ is a value-record address, not a claim that the payload type is @. Generic apply invokes the continuation; its infrastructure and result retention are documented separately. Only Maybe's two variants are fixed, not a set of payload types or function arities.

**Current core implementation.** Definitions are extracted from src/containers.lmx. The @ is a value-record address, not a claim that the payload type is @. Generic apply invokes the continuation; its infrastructure and result retention are documented separately. Only Maybe's two variants are fixed, not a set of payload types or function arities.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [Haskell 2010 Report, predefined types and Monad](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html) — Контекст Maybe и три закона bind; готовый Prelude Maybe в листингах этой пары не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственный алгебраический тип, сопоставление конструкторов и объявления fixity.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Собственный enum для двух вариантов Maybe; готовый Option не используется.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.en.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.
