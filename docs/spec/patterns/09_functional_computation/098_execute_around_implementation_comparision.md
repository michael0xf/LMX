# 098. Execute Around implementation

Обобщённый acquire/action/release: ресурс, полезный результат и дополнительные аргументы не привязаны к int.

## Общий сценарий

Полностью реализовать контракт bracket для одного ресурса: получить один раз, вызвать action один раз, после успешного получения освободить один раз при успехе, допустимой ошибке и штатной остановке; сохранить произвольный результат/void. LMX заранее выделяет аргументы cleanup, сохраняет успешный результат acquire в готовую ячейку и регистрирует finally перед подготовкой action; Haskell использует mask/restore; Scala сохраняет два исключения по правилам приоритета и suppression, как Using.

**Ожидается:** Успех: журнал 123 и результат action. Ошибка action: журнал 123 и распространение ошибки. Ошибка acquire: журнал 1 без release. Соседний клиент кодирует эти случаи как 42123, −123, −1.

Клиенты: [084. Execute Around](084_execute_around_comparision.md). Одно тело ядра обслуживает обе формы записи.

## LMX — единая общая реализация

```lmx
FxAround:
    private:
        @: acquire
        @: release
        @: action
        @: arguments ()
    return: @
    around:
        throws: copy(FxThrows\traversal)
        private: @: resourceArgs (copy(()))
        sys\resize(resourceArgs; 1)
        resourceArgs[0] := FxApply\apply(acquire; ())
        finally:
            FxApply\apply(release; resourceArgs)
        return: FxApply\apply(action; FxAppend\append(resourceArgs; arguments))
```

[Исходник](examples/lmx/098_execute_around_implementation.lm3)

Основной листинг — точные определения FxAround из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

## Haskell

```haskell
{-# LANGUAGE ScopedTypeVariables #-}
module Around (bracket) where
import Control.Exception (SomeException, mask, throwIO, try)

bracket :: forall resource released result.
           IO resource -> (resource -> IO released) ->
           (resource -> IO result) -> IO result
bracket acquire release action = mask $ \restore -> do
  resource <- acquire
  outcome <- try (restore (action resource)) :: IO (Either SomeException result)
  _ <- release resource
  either throwIO pure outcome
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/haskell/098_execute_around_implementation.hs)

## Scala

```scala
import scala.util.control.{ControlThrowable, NonFatal}

object Around {
  private def severity(error: Throwable): Int = error match {
    case _: VirtualMachineError => 5
    case _: LinkageError => 4
    case _: InterruptedException | _: ThreadDeath => 3
    case _: ControlThrowable => 1
    case NonFatal(_) => 0
    case _ => 2
  }
  private def combine(first: Throwable, second: Throwable): Throwable = {
    val (primary, secondary) =
      if (severity(second) > severity(first)) (second, first)
      else (first, second)
    if (primary ne secondary) primary.addSuppressed(secondary)
    primary
  }
  def bracket[R, A](acquire: () => R,
                    release: R => Unit,
                    action: R => A): A = {
    val resource = acquire()
    if (resource == null) throw new NullPointerException("resource")
    var primary: Throwable = null
    try action(resource)
    catch {
      case error: Throwable => primary = error; throw error
    } finally {
      try release(resource)
      catch {
        case cleanup: Throwable =>
          if (primary == null) throw cleanup
          else throw combine(primary, cleanup)
      }
    }
  }
}
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/scala/098_execute_around_implementation.scala)

## Подсчёт полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — общая реализация | <span style="color:#176233"><u>313</u></span> | 15 |
| Haskell | 390 | 11 |
| Scala | 836 | 36 |

Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.

Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.

## Семантические границы

API ограничен одним ресурсом, тремя callback и произвольным результатом: это не переписывание всего Using.Manager. Маскированный Haskell cleanup может быть прерван в interruptible operation, как у стандартного bracket. Scala следует исключениям JVM. В LMX post отправляет целую операцию владельцу; если action только послал другую работу и вернулся, локальный срок bracket уже завершён. Аварийное завершение процесса и ошибка runtime/выделения при вызове cleanup не дают гарантии успешного внешнего освобождения.

[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).

## English explanation

Generic acquire/action/release: the resource, payload result and extra arguments are not tied to int.

**Scenario.** Implement the complete single-resource bracket contract: acquire once; action once; release once after successful acquisition on success, declared failure or supported orderly interruption; preserve arbitrary result/void. LMX preallocates cleanup actuals, stores the successful acquisition in the ready cell and registers finally before preparing the action. Haskell uses mask/restore; Scala preserves dual failures using Using-style severity and suppression.

**Expected.** Success: log 123 and the action result. Body failure: log 123 and propagation. Acquisition failure: log 1 and no release. The adjacent client encodes these cases as 42123, −123 and −1.

**Limits.** Scoped API: one resource, three callbacks, arbitrary result. This is not a reimplementation of all Using.Manager or every resource combinator. Haskell masked cleanup can still be interrupted at interruptible operations, as in standard bracket. Scala interruption follows JVM exceptions, not Haskell masking. LMX post sends the whole owner operation; returning from an action after merely posting work ends the local bracket lifetime. No language handler can guarantee cleanup after abrupt process termination. Runtime call/allocator failure during cleanup remains a kernel failure, not confirmed external release.

Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.

## Источники

- [GHC masking and bracket](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html)
- [Scala Using exception severity](https://www.scala-lang.org/api/2.13.16/scala/util/Using$.html)

## Проверка

[Проверка публикации](VALIDATION_2026-11-26.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.
