# 084. Execute Around

Приобретение и освобождение ресурса окружают переданное пользовательское действие.

## Общий сценарий

Передать три операции: acquire создаёт ресурс, action возвращает 42 либо выбрасывает ошибку, release фиксирует освобождение. Проверить обычный результат, ошибку тела и ошибку acquire.

**Ожидаемое наблюдение:** Успех: acquire → action → release, результат 42. Ошибка action: тот же порядок с обязательным release и распространением ошибки. Ошибка acquire: release не вызывается, потому что ресурс не получен.

**Граница сравнения:** Ядро сценария. Предполагается, что release сам не выбрасывает ошибку. Иначе политика при двух ошибках требует отдельного сравнения. Гарантия не распространяется на аварийное уничтожение процесса или аппаратный сбой. Это управление ресурсом внутри одного исполнения, не протокол межпроцессной аренды.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Around:
    @: acquire
    @: release
    @: action
    return: int
    use:
        @: resource acquire()
        finally:
            release(resource := resource)
        return: action(resource := resource)
```

Контракты: acquire() → @ ресурса; release(resource: @) → процедура; action(resource: @) → int или обычный throw. Именованная передача гарантирует передачу целого ресурса и исключает раскрытие W/E. Ресурс не передаётся другому Message. Показан весь around-алгоритм; сценарный журнал предоставляется тестовыми функциями.

[Отдельный листинг](examples/lmx/084_execute_around.lm3)

## Haskell

```haskell
module ExecuteAroundExample where

import Control.Exception (bracket)

around :: IO r -> (r -> IO ()) -> (r -> IO Int) -> IO Int
around acquire release action = bracket acquire release action
```

Контракты совпадают с LMX; IO-действие acquire передаётся без преждевременного исполнения. Реализация bracket — часть base.

[Отдельный листинг](examples/haskell/084_execute_around.hs)

## Scala

```scala
object ExecuteAroundExample {
  def around[R](acquire: () => R,
                release: R => Unit,
                action: R => Int): Int = {
    val resource = acquire()
    try action(resource)
    finally release(resource)
  }
}
```

Scala 3. Явный try/finally сохраняет ровно тот же интерфейс трёх supplied функций. Для AutoCloseable существует стандартный Using.resource.

[Отдельный листинг](examples/scala/084_execute_around.scala)

## Разбор LMX

finally регистрируется после успешного acquire и исполняется при выходе из области. Это общий механизм выходов LMX. resource жив до cleanup; в исходный граф кадр не копируется. Все три ссылки передаются явно.

## Сопоставление

LMX использует finally, Haskell — bracket, Scala — try/finally. У Haskell bracket также учитывает асинхронные исключения; наш общий сценарий ограничен обычным выходом и ошибкой тела. Сравниваются одинаковые supplied acquire/release/action, поэтому размер реализации файловой системы не приписывается одному языку.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 134 | 10 |
| Haskell | 158 | 4 |
| Scala | 156 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Resource acquisition and release surround a supplied user action.

**Scenario.** Supply acquire, action and release. Action returns 42 or fails; release records cleanup. Check success, body failure and acquisition failure.

**Expected observation.** Success: acquire, action, release, result 42. Action failure still runs release and propagates the error. Acquisition failure does not call release because no resource was acquired.

**LMX.** finally is registered after acquisition succeeds and runs on scope exit through the common LMX exit mechanism. resource stays live through cleanup. All three callable references are explicit.

**Comparison.** LMX uses finally, Haskell bracket and Scala try/finally. Haskell bracket additionally handles asynchronous-exception concerns; the shared scenario covers normal exit and body failure. The same supplied acquire/release/action boundaries apply to all three.

**Scope and limitations.** release is assumed not to fail; competing cleanup/body errors require a separate policy comparison. Process destruction and hardware failure are excluded. This is local resource management, not a distributed lease.

### Dependencies and execution boundaries

- **LMX:** Contracts: acquire() returns a resource reference; release has one reference input named resource; action has the same input and returns int or throws. Named supply passes the whole resource and suppresses W/E expansion. Test callables provide the observation log.
- **Haskell:** The contracts match LMX. The acquire IO action is supplied without running it early. bracket is provided by base.
- **Scala:** Scala 3. Explicit try/finally preserves the exact three-function interface. AutoCloseable also has the standard Using.resource alternative.

## Источники / Sources

- [GHC base, Control.Exception.bracket](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html) — Порядок acquire/use/release и границы асинхронного cleanup.
- [Scala Using API](https://www.scala-lang.org/api/current/scala/util/Using%24.html) — Стандартный resource-management аналог и политика нескольких исключений.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
