# 084. Execute Around

Клиент готового around предоставляет ресурс, действие и журнал; обычный выход и два отказа проверяют освобождение.

**Реализация используемого компонента:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

## Общий сценарий

Ресурс содержит 42. acquire дописывает 1 в журнал, action — 2, release — 3. Mode 0 успешен, mode 1 бросает ResourceFailure из action, mode 2 — из acquire. Клиент использует одинаковый готовый Around во всех трёх языках и перехватывает ошибку только для наблюдения журнала.

**Ожидаемое наблюдение:** run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

**Граница сравнения:** Использование библиотеки. Область — синхронные отказы и release, который не бросает. Стандартный Haskell bracket имеет дополнительные гарантии по асинхронным исключениям; самописная библиотека их не обещает, как явно описано в companion. Нет аварийного уничтожения процесса, межпроцессной аренды или общей политики конкурирующих ошибок. Перед каждым прогоном журнал очищается.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

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

Внешние пробы Example\run(0/1/2). До клиента загрузить LMX-листинг companion Execute Around implementation, определяющий Around. Обычный catch наблюдает отказ; ресурсные callbacks и журнал не являются библиотечными портами, их код показан здесь.

[Отдельный листинг](examples/lmx/084_execute_around.lm3)

## Haskell

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

Haskell2010/base. Компилировать с модулем AroundInt из companion Execute Around implementation. Внешние пробы run 0, run 1, run 2. try находится в клиенте только для наблюдения распространённой ошибки; библиотечный cleanup показан отдельно.

[Отдельный листинг](examples/haskell/084_execute_around.hs)

## Scala

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

Scala 3. Компилировать вместе с AroundInt из companion Execute Around implementation. Внешние пробы ExecuteAroundExample.run(0/1/2). Клиентский catch не выполняет cleanup: он лишь переводит наблюдение отказа в число.

[Отдельный листинг](examples/scala/084_execute_around.scala)

## Разбор LMX

Around загружается из соседнего Execute Around implementation; это авторский компонент, не новый builtin. Прикладные ресурс, журнал и условия отказа находятся в клиенте. catch перехватывает ResourceFailure после выхода из helper; cleanup принадлежит реализации Around. Все записи журнала адресуют явный граф одного последовательного Message.

## Сопоставление

Все три клиента используют собственный готовый around с реализацией рядом. Library-код исключён симметрично; импорты, прикладные callbacks и наблюдение трёх исходов включены. Haskell больше не получает бесплатно standard bracket при сравнении с полной LMX-реализацией.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 563 | 38 |
| Haskell | 580 | 20 |
| Scala | 441 | 26 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A client supplies the resource, action and log to ready around; normal exit and two failures test release.

**Implementation of the supplied component:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

**Scenario.** The resource contains 42. acquire appends 1 to a log, action 2 and release 3. Mode 0 succeeds, mode 1 fails in action and mode 2 in acquisition. The client uses the same ready Around abstraction in all three languages and catches the failure only to observe the log.

**Expected observation.** run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

**LMX.** Around is loaded from the adjacent Execute Around implementation; it is an author-supplied component, not a new built-in. The resource, log and failure conditions stay in the client. catch observes ResourceFailure after the helper exits; cleanup belongs to Around. Log writes target the explicit graph of one serial Message.

**Comparison.** All three clients use a custom ready around whose implementation appears alongside. Library code is excluded symmetrically; imports, application callbacks and observation of all three outcomes are counted. Haskell no longer gets standard bracket free while a complete LMX implementation is charged to its client.

**Scope and limitations.** The scope is synchronous failures and non-failing release. Standard Haskell bracket has additional asynchronous-exception guarantees which the custom companion explicitly does not promise. Process destruction, distributed leases and general competing-error policy are excluded. Each run resets the log.

### Dependencies and execution boundaries

- **LMX:** External probes: Example\run(0/1/2). Load the LMX companion Execute Around implementation defining Around first. Ordinary catch observes failure; callbacks and the log are not hidden library ports, their code is shown here.
- **Haskell:** Haskell2010/base. Compile with AroundInt from companion Execute Around implementation. External probes: run 0, run 1, run 2. Client try only observes the propagated failure; library cleanup is shown separately.
- **Scala:** Scala 3. Compile with AroundInt from companion Execute Around implementation. External probes: ExecuteAroundExample.run(0/1/2). Client catch performs no cleanup; it only encodes the failure observation.

## Источники / Sources

- [GHC base, Control.Exception](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html) — catch/throwIO и различие синхронной обработки с маскированием асинхронных исключений у bracket. Готовый bracket в новой паре не используется.
- [Scala 3 Book, Functional Error Handling](https://docs.scala-lang.org/scala3/book/fp-functional-error-handling.html) — Обычная обработка исключений как контрольный контекст; cleanup реализован собственным try/finally.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
