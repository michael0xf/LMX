# 084. Execute Around

Клиент вызывает прямой bracket; acquire/action/release и наблюдаемый журнал остались прикладным кодом.

**Соседнее сравнение реализации:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

## Общий сценарий

Ресурс содержит 42. acquire дописывает 1 в журнал, action — 2, release — 3. Mode 0 успешен, mode 1 бросает ResourceFailure из action, mode 2 — из acquire. Клиент использует одинаковый готовый bracket во всех трёх языках и перехватывает ошибку только для наблюдения журнала.

**Ожидаемое наблюдение:** run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

Основные варианты: LMX — **текущее ядро**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Клиенты используют один текущий компонент; исторические специализированные формы остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: текущее ядро

```lmx
Resource:
    int: value 42

Trace:
    int: mode 0
    int: events 0

Acquire:
    return: @
    open:
        throws:
            ResourceFailure
        Trace\events := Trace\events * 10 + 1
        if: Trace\mode = 2
            throw: ResourceFailure()
        return: Resource

Action:
    @: resource
    return: int
    use:
        throws:
            ResourceFailure
        Trace\events := Trace\events * 10 + 2
        if: Trace\mode = 1
            throw: ResourceFailure()
        return: resource\value

Release:
    @: resource
    close:
        Trace\events := Trace\events * 10 + 3

Example:
    int: mode
    return: int
    run:
        throws:
            FxIndex
            FxArity
            FxRecordArity
            FxTypeToken
            FxKernelFailure
            FxCallFailure
            ReceiverIndex
            SequenceSize
        Trace\mode := mode
        Trace\events := 0
        int: value \bracket(Acquire\open; Release\close; Action\use)
        return: value * 1000 + Trace\events
        catch: FxCallFailure (@: outcome)
            char[]: actual outcome\failure
            char[]: expected sys\name(ResourceFailure)
            sys\assert(length(actual) = length(expected))
            int: i 0
            while: i < length(actual)
                sys\assert(actual[i] = expected[i])
                i += 1
            return: -Trace\events
```

Операции являются частью текущего ядра и доступны напрямую. Библиотеку другой редакции загружать не нужно; общий код реализации показан в соседних сравннениях и реестре зависимостей.

Тела используемых компонентов показаны рядом: [098. Execute Around implementation](098_execute_around_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/lmx/084_execute_around.lm3)

## Haskell — основной: обобщённая реализация

```haskell
module ExecuteAroundExample where
import Around (bracket)
import Control.Exception (IOException, try)
import Data.IORef (newIORef, modifyIORef', readIORef)

newtype Resource = Resource Int

run :: Int -> IO Int
run mode = do
  events <- newIORef 0
  let note n = modifyIORef' events (\x -> x * 10 + n)
      failure = ioError (userError "ResourceFailure")
      acquire = do
        note 1
        if mode == 2 then failure else pure (Resource 42)
      action (Resource value) = do
        note 2
        if mode == 1 then failure else pure value
      release _ = note 3
  result <- try (bracket acquire release action) :: IO (Either IOException Int)
  logValue <- readIORef events
  pure (either (const (-logValue)) (\value -> value * 1000 + logValue) result)
```

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

Тела используемых компонентов показаны рядом: [098. Execute Around implementation](098_execute_around_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/haskell/084_execute_around.hs)

## Scala — основной: обобщённая реализация

```scala
import Around.bracket

object ExecuteAroundExample {
  final case class Resource(value: Int)
  final class ResourceFailure extends RuntimeException
  def run(mode: Int): Int = {
    var events = 0
    def note(n: Int): Unit = { events = events * 10 + n }
    try {
      val value = bracket(
        () => {
          note(1)
          if (mode == 2) throw new ResourceFailure
          Resource(42)
        },
        (_: Resource) => note(3),
        (resource: Resource) => {
          note(2)
          if (mode == 1) throw new ResourceFailure
          resource.value
        })
      value * 1000 + events
    } catch {
      case _: ResourceFailure => -events
    }
  }
}
```

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

Тела используемых компонентов показаны рядом: [098. Execute Around implementation](098_execute_around_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/scala/084_execute_around.scala)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 842 | 54 |
| Haskell | 579 | 20 |
| Scala | 440 | 26 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

```lmx
Resource:
    int: value 42

Trace:
    int: mode 0
    int: events 0

Acquire:
    return: @
    open:
        throws:
            ResourceFailure
        Trace\events := Trace\events * 10 + 1
        if: Trace\mode = 2
            throw: ResourceFailure()
        return: Resource

Action:
    @: resource
    return: int
    use:
        throws:
            ResourceFailure
        Trace\events := Trace\events * 10 + 2
        if: Trace\mode = 1
            throw: ResourceFailure()
        return: resource\value

Release:
    @: resource
    close:
        Trace\events := Trace\events * 10 + 3

Example:
    int: mode
    return: int
    run:
        Trace\mode := mode
        Trace\events := 0
        int: value Around\use(Acquire\open; Release\close; Action\use)
        return: value * 1000 + Trace\events
        catch: ResourceFailure ()
            return: -Trace\events
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module ExecuteAroundExample where
import AroundInt (around)
import Control.Exception (IOException, try)
import Data.IORef (newIORef, modifyIORef', readIORef)

newtype Resource = Resource Int

run :: Int -> IO Int
run mode = do
  events <- newIORef 0
  let note n = modifyIORef' events (\x -> x * 10 + n)
      failure = ioError (userError "ResourceFailure")
      acquire = do
        note 1
        if mode == 2 then failure else pure (Resource 42)
      action (Resource value) = do
        note 2
        if mode == 1 then failure else pure value
      release _ = note 3
  result <- try (around acquire release action) :: IO (Either IOException Int)
  logValue <- readIORef events
  pure (either (const (-logValue)) (\value -> value * 1000 + logValue) result)
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
import AroundInt.around

object ExecuteAroundExample {
  final case class Resource(value: Int)
  final class ResourceFailure extends RuntimeException
  def run(mode: Int): Int = {
    var events = 0
    def note(n: Int): Unit = { events = events * 10 + n }
    try {
      val value = around(
        () => {
          note(1)
          if (mode == 2) throw new ResourceFailure
          Resource(42)
        },
        (_: Resource) => note(3),
        (resource: Resource) => {
          note(2)
          if (mode == 1) throw new ResourceFailure
          resource.value
        })
      value * 1000 + events
    } catch {
      case _: ResourceFailure => -events
    }
  }
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Сравнивается клиент готового bracket с теми же ресурсом, действием, журналом и тремя исходами. Контрольные листинги также используют компонент из соседнего сравнения 098; LMX явно проверяет исходное имя внутри FxCallFailure и не скрывает стоимость этой проверки. Одно текущее ядро не подменяется более короткой старой специализацией AroundInt.

**Основной LMX.** bracket принимает обычные callable и возвращает адрес записи результата action. Клиент читает int через явное разыменование результата; реализация вокруг не объявляет int-результат. ResourceFailure остаётся именем прикладного отказа. finally зарегистрирован только после успешного acquire. Прямой общий bracket оборачивает заявленный отказ callback в FxCallFailure(outcome); обработчик явно проверяет исходное имя ResourceFailure посимвольно и только затем читает журнал. Это сохраняет критерии наблюдения, но не выдаётся за сохранение внешнего имени исключения. Непредвиденное имя нарушит assert; такой assert является проверкой примера, не универсальным обработчиком.

**Наблюдаемый общий сценарий.** Сравниваются синхронные acquire/action/release. Ошибка release может заменить ошибку action по обычному finally-контракту; двойное сохранение ошибок и асинхронная маскировка не обещаны. LMX integration failures обозначены в throws и не перехватываются как FxCallFailure; проверка cause объяснена ниже.

**Возможности общего ядра.** Сравниваются синхронные acquire/action/release. Ошибка release может заменить ошибку action по обычному finally-контракту; двойное сохранение ошибок и асинхронная маскировка не обещаны. LMX integration failures обозначены в throws и не перехватываются как FxCallFailure; проверка cause объяснена ниже.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; основной пример bracket проверяет этот договор явно.

## English explanation

The client calls direct bracket; acquire/action/release and the observable log remain application code.

**Companion implementation:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

**Scenario.** The resource contains 42. acquire appends 1 to a log, action 2 and release 3. Mode 0 succeeds, mode 1 fails in action and mode 2 in acquisition. The client uses the same ready bracket abstraction in all three languages and catches the failure only to observe the log.

**Expected observation.** run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Specialized historical implementations do not satisfy the full generalized current contract. There is one current component implementation; historical specialized code is not offered as another library dependency.

**Primary LMX.** bracket accepts ordinary callables and returns the action result-record address. The client reads int through explicit dereference of the result; bracket does not declare an int result. ResourceFailure remains an application failure. finally is installed only after acquire succeeds. The generic direct bracket wraps a declared callback failure in FxCallFailure(outcome). The handler explicitly checks the original ResourceFailure spelling character by character before reading the log. This preserves the observations, not external exception-name identity. An unexpected name fails the example assertion; this assertion is an observation check, not a general handler.

**Current core implementation.** bracket accepts ordinary callables and returns the action result-record address. The client reads int through explicit dereference of the result; bracket does not declare an int result. ResourceFailure remains an application failure. finally is installed only after acquire succeeds. The generic direct bracket wraps a declared callback failure in FxCallFailure(outcome). The handler explicitly checks the original ResourceFailure spelling character by character before reading the log. This preserves the observations, not external exception-name identity. An unexpected name fails the example assertion; this assertion is an observation check, not a general handler.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [GHC base, Control.Exception](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html) — catch/throwIO и различие синхронной обработки с маскированием асинхронных исключений у bracket. Готовый bracket в новой паре не используется.
- [Scala 3 Book, Functional Error Handling](https://docs.scala-lang.org/scala3/book/fp-functional-error-handling.html) — Обычная обработка исключений как контрольный контекст; cleanup реализован собственным try/finally.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.en.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.
