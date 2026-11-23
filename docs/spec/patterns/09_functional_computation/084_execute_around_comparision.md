# 084. Execute Around

Переданные acquire/action/release исполняются вокруг защищённого использования ресурса. Основной LMX включает короткий локальный helper целиком; общий bracket сохранён как текущий вариант.

**Сравнения реализаций:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md). Это ссылки для чтения, не импорты самописных модулей в контрольные usage-клиенты.

## Общий сценарий

Ресурс содержит 42. acquire добавляет в журнал 1, action — 2, release — 3. Режим 0 успешен, режим 1 падает в action, режим 2 — в acquire. Основной клиент вызывает встроенный bracket / Control.Exception.bracket / Using.resource: освобождает только полученный ресурс и наблюдает ошибку вместе с журналом.

**Ожидаемое наблюдение:** run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

**Граница сравнения.** LMX вызывает непосредственные операции текущего ядра; контрольные языки используют настоящую библиотеку или собственные средства языка. Самописные аналоги из соседних сравнений сюда не импортируются.

| Язык | Используемое средство |
| --- | --- |
| Haskell | `base: Control.Exception.bracket` |
| Scala | `scala-library: scala.util.Using.resource` |

## LMX — прямой API ядра

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

Основной вариант вызывает встроенный bracket и обрабатывает FxCallFailure с проверкой исходного ResourceFailure. Самостоятельный Around оставлен только как отдельный процедурный подход и целиком показан ниже.

[Исходник](examples/lmx/084_execute_around.lm3)

## Haskell — готовое средство языка/библиотеки

```haskell
module ExecuteAroundExample where
import Control.Exception (IOException, bracket, try)
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

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/haskell/084_execute_around.hs)

## Scala — готовое средство языка/библиотеки

```scala
import scala.util.Using

object ExecuteAroundExample {
  final case class Resource(value: Int)
  final class ResourceFailure extends RuntimeException
  def run(mode: Int): Int = {
    var events = 0
    def note(n: Int): Unit = { events = events * 10 + n }
    given Using.Releasable[Resource] with {
      def release(resource: Resource): Unit = note(3)
    }
    def acquire(): Resource = {
      note(1)
      if (mode == 2) throw new ResourceFailure
      Resource(42)
    }
    try {
      val value = Using.resource(acquire()) { resource =>
        note(2)
        if (mode == 1) throw new ResourceFailure
        resource.value
      }
      value * 1000 + events
    } catch {
      case _: ResourceFailure => -events
    }
  }
}
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/scala/084_execute_around.scala)

## LMX — другой подход: процедурная композиция с локальным Around

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

Самостоятельная композиция acquire/action/release через локальный Around и динамическое связывание. Это иной подход с прикладным контрактом; helper показан целиком, но не подменяет встроенный bracket в основном usage-сравнении.

[Исходник альтернативы](examples/lmx/variants/084_execute_around_local_callbacks.lm3)

## Подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 802 | 48 |
| Haskell | 566 | 19 |
| Scala | 521 | 27 |

Считается только `listings[].code`, включая импорты, объявления и throws. Альтернативный подход не прибавляется к основному. [Выбор](variant_selection.json) сравнивает допустимые варианты одной границы. [Зависимости реализации](IMPLEMENTATION_DEPENDENCIES.md) показывают общие LMX-тела отдельно.

## Удалённые малозначимые повторы

Удалены полные повторы, отличавшиеся импортом, написанием вызова, повторением общего тела либо специализацией на int. Эти отличия не образуют отдельного текущего алгоритма; исходная редакция сохраняется в базе diff.

## Семантические границы

Общие наблюдения проверяют ошибку получения и действия. В 098 дополнительно описаны ошибка освобождения и остановка. Haskell маскирует асинхронные исключения при организации/освобождении ресурса; Scala объединяет два исключения по приоритету; LMX использует штатные finally и владение Message. Разные политики ошибок указаны явно.

[Политика очистки, ошибок и Message/post](FAILURE_BOUNDARIES.md).

## English explanation

Supplied acquire/action/release callbacks surround protected resource use. The shortest LMX includes its local helper in full; generic bracket remains a current alternative.

**Scenario.** The resource contains 42. acquire appends 1 to a log, action 2 and release 3. Mode 0 succeeds, mode 1 fails in action and mode 2 in acquisition. Use core bracket, Haskell Control.Exception.bracket, or Scala Using.resource; each releases only an acquired resource and the client observes the failure and log.

**Expected.** run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

**Limits.** The shared observations exercise acquisition and action failure. The full comparison in 098 also specifies release failure and interruption. Haskell masks asynchronous exceptions during setup/cleanup; Scala combines dual failures by severity; LMX uses ordinary finally and Message ownership. These distinct error policies are disclosed, not silently treated as equivalent.

Usage clients call the real language/library facility. Adjacent foreign implementations are independent comparison subjects and are not imported by usage clients. Only genuinely different approaches remain. The source listings have not been executed by an LMX/Haskell/Scala runtime in this workspace.

## Источники / Sources

- [GHC Control.Exception.bracket](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html)
- [Scala Using.resource](https://www.scala-lang.org/api/2.13.16/scala/util/Using$.html)

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [источники ядра](../LMX_Fn_Receivers/README.md).

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) сверяет данные, исходники, отсутствие подмены библиотечных клиентов и границы подсчёта. [Acceptance matrix](acceptance_cases.json) отделяет подготовленные наблюдения от реального запуска.
