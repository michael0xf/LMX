# 084. Execute Around

Полный локальный Around и функциональный bracket сохраняют один ресурсный жизненный цикл.

## Общий сценарий

Ресурс содержит42. acquire/action/release добавляют1/2/3 в журнал. Оба полных LMX-варианта сохраняют режимы успеха, отказа action и отказа acquire; освобождается только полученный ресурс.

**Ожидается:** run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

Общие реализации: [098. Execute Around implementation](098_execute_around_implementation_comparision.md). Они учитываются отдельно; иностранные клиенты не импортируют эти сравнительные модули.

## Граница двух стилей

Процедурный вариант содержит весь Around и использует finally/catch с исходным ResourceFailure. Функциональный вызывает общий bracket; его закрытый набор callback-ошибок обрабатывается без сравнения имени. Порядок acquire/action/release и журналы одинаковы.

## LMX — процедурный

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

[Полный исходник](examples/lmx/procedural/084_execute_around.lm3). 709 непробельных символов; 55 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
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
            throws: copy(FxThrows\sequence)
            Trace\mode := mode
            Trace\events := 0
            int: value \bracket(Acquire\open; Release\close; Action\use)
            return: value * 1000 + Trace\events
            catch: FxCallFailure (@: error)
                return: -Trace\events
```

[Полный исходник](examples/lmx/084_execute_around.lm3). 586 непробельных символов; 45 непустых строк. Все объявления и Throws включены.


## Haskell

```haskell
module ExecuteAroundExample where
import Control.Exception (Exception, bracket, throwIO, try)
import Data.IORef (newIORef, modifyIORef', readIORef)

newtype Resource = Resource Int
data ResourceFailure = ResourceFailure deriving Show
instance Exception ResourceFailure

run :: Int -> IO Int
run mode = do
  events <- newIORef 0
  let note n = modifyIORef' events (\x -> x * 10 + n)
      failure = throwIO ResourceFailure
      acquire = do
        note 1
        if mode == 2 then failure else pure (Resource 42)
      action (Resource value) = do
        note 2
        if mode == 1 then failure else pure value
      release _ = note 3
  result <- try (bracket acquire release action) :: IO (Either ResourceFailure Int)
  logValue <- readIORef events
  pure (either (const (-logValue)) (\value -> value * 1000 + logValue) result)
```

Control.Exception.bracket и try; собственный тип ResourceFailure. try ловит только его, как Scala catch и основной LMX catch; все прочие исключения проходят наружу. Ручной проверки текста нет.

[Исходник](examples/haskell/084_execute_around.hs)

## Scala

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

## Подсчёт полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 709 | 55 |
| LMX — функциональный | 586 | 45 |
| Haskell | 642 | 21 |
| Scala | **521** | 27 |

Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.

Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.

## Семантические границы

Общие наблюдения проверяют ошибку получения и действия. В 098 дополнительно описаны ошибка освобождения и остановка. Haskell маскирует асинхронные исключения при организации/освобождении ресурса; Scala объединяет два исключения по приоритету; LMX использует штатные finally и владение Message. Разные политики ошибок указаны явно.

LMX ловит оболочку только замкнутого набора {ResourceFailure}; Haskell и Scala ловят собственный ResourceFailure. Проверки текста нет ни на одной стороне. FxKernelFailure/FxTypeToken/ReceiverIndex/SequenceSize и implicit failures не превращаются в ResourceFailure и проходят наружу. См. [доказательство и границы](review/084_failure_boundary.md).

[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).

## English explanation

The complete local Around and functional bracket preserve one resource lifecycle.

**Scenario.** The resource holds42. acquire/action/release append1/2/3 to the trace. Both complete LMX styles preserve success, action failure and acquisition failure; only an acquired resource is released.

**Expected.** run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

**Limits.** The shared observations exercise acquisition and action failure. The full comparison in 098 also specifies release failure and interruption. Haskell masks asynchronous exceptions during setup/cleanup; Scala combines dual failures by severity; LMX uses ordinary finally and Message ownership. These distinct error policies are disclosed, not silently treated as equivalent.

Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.

## Источники

- [GHC Control.Exception.bracket](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html)
- [Scala Using.resource](https://www.scala-lang.org/api/2.13.16/scala/util/Using$.html)

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.
