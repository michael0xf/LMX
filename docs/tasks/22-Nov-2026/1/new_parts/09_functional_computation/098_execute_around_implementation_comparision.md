# 098. Execute Around implementation

Обобщённый acquire/action/release: ресурс, полезный результат и дополнительные аргументы не привязаны к int.

**Примеры использования:** [084. Execute Around](084_execute_around_comparision.md)

## Общий сценарий

После успешного acquire зарегистрировать release(resource), затем вызвать action(resource; additionalArgs...). Сохранить типизированную запись результата либо void. При ошибке acquisition release не вызывается; после успешного acquisition он вызывается ровно один раз при любом обычном выходе.

**Ожидаемое наблюдение:** Успех: журнал 123 и результат action. Ошибка action: журнал 123 и распространение ошибки. Ошибка acquire: журнал 1 без release. Соседний клиент кодирует эти случаи как 42123, −123, −1.

Основные варианты: LMX — **текущее ядро**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Клиенты используют один текущий компонент; исторические специализированные формы остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: текущее ядро

```lmx
FxAround:
    private:
        @: acquire
        @: release
        @: action
        @: arguments ()
    return: @
    around:
        throws:
            FxCallFailure
            FxKernelFailure
            FxTypeToken
        private: @: empty (copy(()))
        private: @: resource FxApply\apply(acquire; empty)
        private: @: resourceArgs FxOne\make(resource)
        finally:
            FxApply\apply(release; resourceArgs)
        ---
        private: @: actionArgs FxAppend\append(resourceArgs; arguments)
        return: FxApply\apply(action; actionArgs)
```

Основной листинг — точные определения FxAround из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

[Основной листинг](examples/lmx/098_execute_around_implementation.lm3)

## Haskell — основной: обобщённая реализация

```haskell
module Around (bracket) where
import Control.Exception (SomeException, catch, throwIO)

bracket :: IO r -> (r -> IO ()) -> (r -> IO a) -> IO a
bracket acquire release action = do
  resource <- acquire
  let failed :: SomeException -> IO a
      failed err = release resource >> throwIO err
  value <- action resource `catch` failed
  release resource
  pure value
```

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

[Основной листинг](examples/haskell/098_execute_around_implementation.hs)

## Scala — основной: обобщённая реализация

```scala
object Around {
  def bracket[R, A](acquire: () => R,
                   release: R => Unit,
                   action: R => A): A = {
    val resource = acquire()
    try action(resource)
    finally release(resource)
  }
}
```

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

[Основной листинг](examples/scala/098_execute_around_implementation.scala)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 374 | 20 |
| Haskell | 287 | 10 |
| Scala | 141 | 9 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

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
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module AroundInt (around) where
import Control.Exception (SomeException, catch, throwIO)

around :: IO r -> (r -> IO ()) -> (r -> IO Int) -> IO Int
around acquire release action = do
  resource <- acquire
  let failed :: SomeException -> IO Int
      failed err = release resource >> throwIO err
  value <- action resource `catch` failed
  release resource
  pure value
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
object AroundInt {
  def around[R](acquire: () => R,
                release: R => Unit,
                action: R => Int): Int = {
    val resource = acquire()
    try action(resource)
    finally release(resource)
  }
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Все три основных листинга показывают алгоритм acquire/action/finally/release для произвольных типов ресурса и результата. В LMX вызов через типизированную запись и FxCallFailure раскрыт в общем runtime, а тела bracket здесь приведены полностью. Старый AroundInt не заменяет общий контракт; различия внешней оболочки ошибки явно описаны и проверяются клиентом.

**Основной LMX.** Листинг содержит тело вокруг из src/generic_wrappers.lmx. Ресурс и все actuals передаются через вектор типизированных записей; массив не переинтерпретируется как плотный int. Общий apply использует штатные правила приёма аргументов и возвращает запись с точным result type. Direct-record API сообщает неизвестные заранее отказы как FxCallFailure с сохранёнными именем и payload. В отличие от него, построенные типизированные callable сохраняют исходные throws через явный raise-bridge.

**Наблюдаемый общий сценарий.** Обсуждается синхронная схема. Обобщение результата не означает автоматическую поддержку асинхронных исключений или ресурсных гарантий Message. Ошибки release следуют обычному finally-контракту; дополнительно прикладные failure names передаются через общий call-bridge.

**Возможности общего ядра.** Обсуждается синхронная схема. Обобщение результата не означает автоматическую поддержку асинхронных исключений или ресурсных гарантий Message. Ошибки release следуют обычному finally-контракту; дополнительно прикладные failure names передаются через общий call-bridge.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; основной пример bracket проверяет этот договор явно.

## English explanation

Generic acquire/action/release: the resource, payload result and extra arguments are not tied to int.

**Usage examples:** [084. Execute Around](084_execute_around_comparision.md)

**Scenario.** After successful acquire, register release(resource), then invoke action(resource; additionalArgs...). Retain a typed result record or void. Acquisition failure does not call release; after successful acquisition release runs exactly once on ordinary exit.

**Expected observation.** Success: log 123 and the action result. Body failure: log 123 and propagation. Acquisition failure: log 1 and no release. The adjacent client encodes these cases as 42123, −123 and −1.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Specialized historical implementations do not satisfy the full generalized current contract. There is one current component implementation; historical specialized code is not offered as another library dependency.

**Primary LMX.** The listing contains the bracket body from src/generic_wrappers.lmx. Resource and actuals travel in a vector of typed value records, not a reinterpreted dense int array. Generic apply uses ordinary argument admission and returns a record carrying the exact result type. The direct record API reports previously unknown failures as FxCallFailure with the original name and payload. Generated typed callables instead retain their declared failures through the explicit raise bridge.

**Current core implementation.** The listing contains the bracket body from src/generic_wrappers.lmx. Resource and actuals travel in a vector of typed value records, not a reinterpreted dense int array. Generic apply uses ordinary argument admission and returns a record carrying the exact result type. The direct record API reports previously unknown failures as FxCallFailure with the original name and payload. Generated typed callables instead retain their declared failures through the explicit raise bridge.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [GHC base, Control.Exception](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html) — catch/throwIO и различие синхронной обработки с маскированием асинхронных исключений у bracket. Готовый bracket в новой паре не используется.
- [Scala 3 Book, Functional Error Handling](https://docs.scala-lang.org/scala3/book/fp-functional-error-handling.html) — Обычная обработка исключений как контрольный контекст; cleanup реализован собственным try/finally.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [ТЗ интеграции](../../tasks/TZ_Receivers_Satisfies_2026-11-22.md) описывает требуемую поддержку новых общих ресиверов.
