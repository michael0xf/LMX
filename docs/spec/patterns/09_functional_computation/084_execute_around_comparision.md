# 084. Execute Around

Переданные acquire/action/release исполняются вокруг защищённого использования ресурса. Основной LMX включает короткий локальный helper целиком; общий bracket сохранён как текущий вариант.

**Соседнее сравнение реализации:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

## Общий сценарий

Ресурс содержит 42. acquire дописывает 1 в журнал, action — 2, release — 3. Mode 0 успешен, mode 1 бросает ResourceFailure из action, mode 2 — из acquire. Все варианты передают acquire/release/action как callbacks, освобождают только успешно полученный ресурс и ловят прикладной отказ для наблюдения журнала. Использование максимально общего bracket не является отдельным требованием этого int-сценария.

**Ожидаемое наблюдение:** run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

Основные варианты: LMX — **общие code и eval**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Встроенные операции принадлежат одному текущему ядру; полный локальный helper допустим, когда сохраняет прикладной сценарий и включён в подсчёт. Исторические публикации остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

[Объявления выходов, обработчики и граница примера](FAILURE_BOUNDARIES.md#execute-around).

## LMX — основной: общие code и eval

```lmx
Around:
    @: acquire
    @: release
    @: action
    return: int
    use:
        throws: ResourceFailure
        @: resource acquire()
        finally:
            release(resource := resource)
        return: action(resource := resource)

Resource:
    int: value 42

Trace:
    int: mode 0
    int: events 0
    eval:
        Trace\events := events * 10 + x
    code:
        throws: ResourceFailure
        eval()
        if: Trace\mode = mode
            throw: ResourceFailure()
    end: code
    Acquire:
        return: @
        open:
            throws: ResourceFailure
            int: x 1
            code(2)
        return: Resource
    Action:
        @: resource
        return: int
        use:
            throws: ResourceFailure
            int: x 2
            code(1)
        return: resource\value
    Release:
        @: resource
        close:
            int: x 3
            eval()
        end: close
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

Around полностью включён в листинг. Trace\code объединяет запись события и проверку отказа, Trace\eval — само обновление журнала. Acquire, Action и Release объявляют собственный x перед вызовом общего кода. Release вызывает eval после int: x 3; декларация не подменяется аргументом-вызовом. Вход Trace\Example\run(mode). Сохраняются ресурс 42, три callbacks и результаты 42123, -123, -1 для mode 0, 1, 2.

Локальный Around целиком включён в основной листинг и его размер. Общая реализация bracket в [098. Execute Around implementation](098_execute_around_implementation_comparision.md) относится к сохранённой действующей альтернативе core; основной локальный вариант не вызывает этот компонент.

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

Другие сохранённые LMX варианты: [core](examples/lmx/variants/084_execute_around_core.lm3) — 802 символов (допустимый), [local_callbacks](examples/lmx/variants/084_execute_around_local_callbacks.lm3) — 719 символов (допустимый).

## LMX — действующая альтернатива: локальный Around целиком

```lmx
Around:
    @: acquire
    @: release
    @: action
    return: int
    use:
        throws: ResourceFailure
        @: resource acquire()
        finally:
            release(resource := resource)
        return: action(resource := resource)

Resource:
    int: value 42

Trace:
    int: mode 0
    int: events 0

Acquire:
    return: @
    open:
        throws: ResourceFailure
        Trace\events := Trace\events * 10 + 1
        if: Trace\mode = 2
            throw: ResourceFailure()
        return: Resource

Action:
    @: resource
    return: int
    use:
        throws: ResourceFailure
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

Around целиком включён в этот листинг и его размер. Клиент явно передаёт acquire, release и action; helper получает ресурс, регистрирует finally, вызывает action и возвращает int, требуемый этим прикладным сценарием. ResourceFailure передаётся напрямую и ловится в Example\run. Это действующая локальная процедура приложения, а не отдельная версия встроенного bracket. Общий вариант bracket сохранён ниже; контракт реализации 098 не сужен. [Разбор](FAILURE_BOUNDARIES.md#execute-around).

Полный размер этого варианта: **719 непробельных символов / 47 непустых строк**. Он не прибавляется к выбранному основному листингу; это отдельный допустимый способ выполнить тот же сценарий.

[Исходник текущей альтернативы](examples/lmx/variants/084_execute_around_local_callbacks.lm3)

## LMX — действующая альтернатива: текущее ядро

```lmx
Resource:
    int: value 42

Trace:
    int: mode 0
    int: events 0

Acquire:
    return: @
    open:
        throws: ResourceFailure
        Trace\events := Trace\events * 10 + 1
        if: Trace\mode = 2
            throw: ResourceFailure()
        return: Resource

Action:
    @: resource
    return: int
    use:
        throws: ResourceFailure
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
            FxTypeToken
            FxKernelFailure
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

Общий bracket вызывает callbacks через typed-record API и передаёт их отказ как FxCallFailure с исходным именем и payload. Этот вариант ловит конверт, проверяет ResourceFailure и возвращает отрицательный журнал. Объявлены только четыре оставшихся выхода непосредственно используемого bracket: FxKernelFailure, FxTypeToken, ReceiverIndex и SequenceSize; пойманный FxCallFailure не передаётся наружу. Весь клиент считается, а общий компонент показан в 098. Это действующая альтернатива локальному Around, не другая редакция ядра. [Обработчики](FAILURE_BOUNDARIES.md#execute-around).

Полный размер этого варианта: **802 непробельных символов / 48 непустых строк**. Он не прибавляется к выбранному основному листингу; это отдельный допустимый способ выполнить тот же сценарий.

[Исходник текущей альтернативы](examples/lmx/variants/084_execute_around_core.lm3)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 709 | 55 |
| Haskell | 579 | 20 |
| Scala | 440 | 26 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — сохранённый процедурный вариант целиком; вне текущего подсчёта

```lmx
Around:
    @: acquire
    @: release
    @: action
    return: int
    use:
        throws:
            ResourceFailure
        @: resource acquire()
        finally:
            release(resource := resource)
        return: action(resource := resource)

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

Полный размер сохранённого варианта: **719 непробельных символов / 50 непустых строк**: клиент — 563, Around — 156 символов.

Ранее здесь был неполный листинг: вызов `Around\use` без определения `Around`. Теперь перед неизменённым сохранённым клиентом включено точное тело `Around` из сохранённого варианта [098](098_execute_around_implementation_comparision.md). Здесь уже были `throw` и `catch ResourceFailure`; этот синтаксис не отменён. Исходный текст клиента отдельно сохранён в `alternative.LMX.code` и `procedural_lmx`, а добавленное определение — в `alternative.LMX.context_prefix`. Полный сохранённый вариант показан и посчитан отдельно от основного.

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

**Честная граница сравнения.** Сравнивается полный прикладной сценарий с переданными acquire/release/action, ресурсом 42, журналом и тремя исходами. В локальном варианте всё тело Around включено в основной листинг; он использует текущий синтаксис и не переключает ядро на старую библиотеку. Общий bracket также остаётся действующим кандидатом, его клиент учитывает конверт ошибки, а реализация показана в 098. Требование произвольного результата реализации 098 не навязывается прикладному int-клиенту 084. Основным выбирается короткий допустимый вариант. Общие Trace\code и Trace\eval, локальные x, все callbacks и весь Around входят в основной размер; журнал и обработчики сохранены.

**Основной LMX.** Around полностью включён в листинг. Trace\code объединяет запись события и проверку отказа, Trace\eval — само обновление журнала. Acquire, Action и Release объявляют собственный x перед вызовом общего кода. Release вызывает eval после int: x 3; декларация не подменяется аргументом-вызовом. Вход Trace\Example\run(mode). Сохраняются ресурс 42, три callbacks и результаты 42123, -123, -1 для mode 0, 1, 2.

**Наблюдаемый общий сценарий.** Сравниваются синхронные acquire/action/release и фактический int-результат этой задачи. Ошибка release может заменить ошибку action по обычному finally-контракту; двойное сохранение ошибок и асинхронная маскировка не обещаны. Локальный helper не заявлен универсальной заменой общего bracket: произвольный результат и дополнительные actuals остаются контрактом 098. В действующей общей альтернативе сохраняется FxCallFailure и объявленные технические выходы.

**Возможности общего ядра.** Сравниваются синхронные acquire/action/release. Ошибка release может заменить ошибку action по обычному finally-контракту; двойное сохранение ошибок и асинхронная маскировка не обещаны. LMX integration failures обозначены в throws и не перехватываются как FxCallFailure; проверка cause объяснена ниже.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; действующий общий вариант bracket проверяет этот договор явно. Локальный прикладной Around передаёт ResourceFailure напрямую и целиком входит в свой клиентский листинг.

## English explanation

Supplied acquire/action/release callbacks surround protected resource use. The shortest LMX includes its local helper in full; generic bracket remains a current alternative.

**Companion implementation:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

**Scenario.** The resource contains 42. acquire appends 1 to a log, action 2 and release 3. Mode 0 succeeds, mode 1 fails in action and mode 2 in acquisition. Every variant supplies acquire/release/action callbacks, releases only an acquired resource, and catches the application failure to observe the log. Using a maximally generic bracket is not a separate requirement of this int-result application.

**Expected observation.** run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Implementation comparisons retain their full generalized contracts. A usage scenario may instead use a complete counted local helper when it preserves that scenario. This does not select another core library edition; the generic component remains current.

**Primary LMX.** The listing includes the complete Around helper. Trace\code shares event recording and failure checking; Trace\eval owns the journal update. Acquire, Action, and Release declare their own x before invoking the shared code. Release calls eval after int: x 3; a declaration argument is not mistaken for an invocation. Entry is Trace\Example\run(mode). Resource 42, all three callbacks, and results 42123, -123, -1 for modes 0, 1, 2 are preserved.

**LMX variant `core`.** Generic bracket invokes callbacks through the typed-record API and transports their failure as FxCallFailure with the original name and payload. This variant catches the envelope, validates ResourceFailure, and returns the negative event log. Only the four remaining declared exits of the directly used bracket are advertised: FxKernelFailure, FxTypeToken, ReceiverIndex, and SequenceSize. The caught FxCallFailure is not propagated. The whole client is counted; companion 098 shows its shared component. This is a current alternative to local Around, not another core edition. [Handlers](FAILURE_BOUNDARIES.md#execute-around).

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [GHC base, Control.Exception](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html) — catch/throwIO и различие синхронной обработки с маскированием асинхронных исключений у bracket. Готовый bracket в новой паре не используется.
- [Scala 3 Book, Functional Error Handling](https://docs.scala-lang.org/scala3/book/fp-functional-error-handling.html) — Обычная обработка исключений как контрольный контекст; cleanup реализован собственным try/finally.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.en.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.

[Declared exits, handlers, and example boundary](FAILURE_BOUNDARIES.md#execute-around).
