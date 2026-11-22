# 098. Execute Around implementation

Полная повторяемая схема acquire/action/release с синхронными ошибками, без готового bracket/Using.

**Примеры использования:** [084. Execute Around](084_execute_around_comparision.md)

## Общий сценарий

Принимать acquire()→resource, release(resource)→процедура и action(resource)→int. После успешного acquire выполнять release ровно один раз при нормальном выходе или ResourceFailure тела. Если acquire отказал, release не вызывать. Клиентский ресурс, журнал и правила отказа остаются в Execute Around.

**Ожидаемое наблюдение:** Успех: журнал 123 и результат action. Ошибка action: журнал 123 и распространение ошибки. Ошибка acquire: журнал 1 без release. Соседний клиент кодирует эти случаи как 42123, −123, −1.

**Граница сравнения:** Реализация библиотеки. Общая гарантия — синхронный ResourceFailure/соответствующая обычная ошибка; release сам не бросает. Самописный Haskell around не маскирует асинхронные исключения и не заявляет полную гарантию стандартного bracket. Отмена, async exceptions, аварийное завершение процесса и политика двух ошибок вне общей области. Это явно сохранённая синхронная граница прежнего сравнения, а не обещание заменить bracket во всех программах.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

## LMX

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

Это авторский готовый Around для клиента. acquire/action могут иметь объявленный выход ResourceFailure; release не бросает. Загружать библиотеку до клиента в тот же namespace.

[Отдельный листинг](examples/lmx/098_execute_around_implementation.lm3)

## Haskell

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

Haskell2010/base. Реализован именно синхронный cleanup без bracket, finally или onException. Модуль AroundInt подаётся компилятору вместе с клиентом; для автоматического поиска допустимо имя AroundInt.hs.

[Отдельный листинг](examples/haskell/098_execute_around_implementation.hs)

## Scala

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

Scala 3. Весь механизм показан через try/finally; готовый Using не используется. Компилировать этот объект с клиентом ExecuteAroundExample.

[Отдельный листинг](examples/scala/098_execute_around_implementation.scala)

## Разбор LMX

finally регистрируется только после успешного acquire. Helper объявляет разрешённое имя выхода ResourceFailure; клиент обрабатывает его обычным catch. Именованная передача resource сохраняет целый ресурс и исключает раскрытие единственной Structure. Helper не копирует клиентский кадр и не требует операнда.

## Сопоставление

Каждый язык показывает собственный around. Haskell использует только обычные catch/throwIO, Scala — try/finally, LMX — finally. Готовые bracket, Using или скрытые resource-helpers не вызываются. Общий интерфейс сохраняет прикладные функции в клиенте.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 156 | 12 |
| Haskell | 293 | 10 |
| Scala | 145 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

The complete reusable acquire/action/release mechanism for synchronous failures, without ready bracket/Using.

**Usage examples:** [084. Execute Around](084_execute_around_comparision.md)

**Scenario.** Accept acquire()→resource, release(resource)→procedure and action(resource)→int. After successful acquisition, release exactly once on normal exit or a ResourceFailure from the body. Failed acquisition must not release. The resource, log and application failure rules remain in Execute Around.

**Expected observation.** Success: log 123 and the action result. Body failure: log 123 and propagation. Acquisition failure: log 1 and no release. The adjacent client encodes these cases as 42123, −123 and −1.

**LMX.** finally is registered only after successful acquisition. The helper declares the permitted ResourceFailure exit and the client handles it with ordinary catch. Named resource supply passes the complete resource and avoids single-Structure expansion. The helper copies no client frame and needs no operand.

**Comparison.** Every language shows its own around. Haskell uses ordinary catch/throwIO, Scala try/finally and LMX finally. No ready bracket, Using or hidden resource helper is called. Application callbacks remain in the client.

**Scope and limitations.** The shared guarantee covers synchronous ResourceFailure or its ordinary-error equivalent; release itself does not fail. The custom Haskell around does not mask asynchronous exceptions and makes no full standard-bracket guarantee. Cancellation, async exceptions, process termination and competing-error policy are outside scope. This explicitly retains the previous comparison synchronous boundary rather than promising to replace bracket everywhere.

### Dependencies and execution boundaries

- **LMX:** This is the author-supplied Around used by the client. acquire/action may declare ResourceFailure; release does not fail. Load the library into the same namespace before its client.
- **Haskell:** Haskell2010/base. Implements synchronous cleanup without bracket, finally or onException. Supply AroundInt together with its client; AroundInt.hs may be used for automatic module lookup.
- **Scala:** Scala 3. The complete mechanism uses try/finally; ready Using is not used. Compile this object with ExecuteAroundExample.

## Источники / Sources

- [GHC base, Control.Exception](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html) — catch/throwIO и различие синхронной обработки с маскированием асинхронных исключений у bracket. Готовый bracket в новой паре не используется.
- [Scala 3 Book, Functional Error Handling](https://docs.scala-lang.org/scala3/book/fp-functional-error-handling.html) — Обычная обработка исключений как контрольный контекст; cleanup реализован собственным try/finally.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
