# 082. Monad

Две операции bind над обобщённым Maybe; прикладной half по-прежнему проверяет чётность целого числа.

**Соседнее сравнение реализации:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

## Общий сценарий

Вызвать half дважды через bind. В some хранится запись значения с его собственным типом, а next получает само значение по обычному контракту вызова. Для отсутствия продолжение не вызывается. Проверки остаются 8, 6 и 3.

**Ожидаемое наблюдение:** 8 → присутствующее 2; 6 → отсутствие после второго half; 3 → отсутствие после первого half, второй half не вызывается. Готовая ссылка на half сама по себе вызовом не является.

Основные варианты: LMX — **текущее ядро**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Клиенты используют один текущий компонент; исторические специализированные формы остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: текущее ядро

```lmx
Example:
    int: x
    return: @
    half:
        throws: FxRecordArity
        if: x % 2 = 0
            return: some(value := (x / 2 record))
        return: none()
    run:
        throws:
            FxIndex
            FxArity
            FxRecordArity
            FxTypeToken
            FxKernelFailure
            FxCallFailure
        return: bind(bind(some(value := (x record)); half); half)
```

Операции являются частью текущего ядра и доступны напрямую. Библиотеку другой редакции загружать не нужно; общий код реализации показан в соседних сравннениях и реестре зависимостей.

Тела используемых компонентов показаны рядом: [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/lmx/082_monad.lm3)

## Haskell — основной: обобщённая реализация

```haskell
module MonadExample where
import MaybeValue (MaybeValue, some, none, bind)

half :: Int -> MaybeValue Int
half x = if even x then some (x `div` 2) else none

run :: Int -> MaybeValue Int
run x = (some x `bind` half) `bind` half
```

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

Тела используемых компонентов показаны рядом: [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/haskell/082_monad.hs)

## Scala — основной: обобщённая реализация

```scala
import MaybeValue.*

object MonadExample {
  def half(x: Int): Value[Int] =
    if (x % 2 == 0) some(x / 2) else none()
  def run(x: Int): Value[Int] = some(x).bind(half).bind(half)
}
```

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

Тела используемых компонентов показаны рядом: [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/scala/082_monad.scala)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 226 | 17 |
| Haskell | 183 | 6 |
| Scala | 147 | 6 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

```lmx
Example:
    int: x
    return: @
    half:
        import: Maybe
        if: x % 2 = 0
            return: unit(x / 2)
        return: none()
    run:
        import: Maybe MaybeOps
        return: (unit(x) bind half) bind half
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module MonadExample where
import MaybeInt (MaybeInt, unit, none, bind)

half :: Int -> MaybeInt
half x = if even x then unit (x `div` 2) else none

run :: Int -> MaybeInt
run x = (unit x `bind` half) `bind` half
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
import MaybeInt.*

object MonadExample {
  def half(x: Int): Value =
    if (x % 2 == 0) unit(x / 2) else none()
  def run(x: Int): Value = unit(x).bind(half).bind(half)
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Сравнивается клиент одного готового Maybe-компонента: во всех трёх языках показаны две последовательные bind и short-circuit при отсутствии. Тело some/none/bind находится в соседнем сравнении 091; прямые операции LMX входят в ядро, их реализации и общие зависимости учтены отдельно.

**Основной LMX.** Все указанные операции доступны прямо из текущего ядра. `(x record)` сохраняет типизированную запись примитивного x, не превращая его в IntBox. Внешний @ у Maybe — служебная ссылка на запись; bind читает её через общий apply и передаёт half настоящее int-значение. Для передачи записи целиком some использует именованный actual value.

**Наблюдаемый общий сценарий.** Обобщение относится к хранимому значению и типам A→Maybe<B>, а не к любому возможному Monad/IO/State. Прикладной half принимает int. Законы монады здесь относятся к чистым полным продолжениям и наблюдаемым значениям, а не к адресам или внешней мутации.

**Возможности общего ядра.** Обобщение относится к хранимому значению и типам A→Maybe<B>, а не к любому возможному Monad/IO/State. Прикладной half принимает int. Законы монады здесь относятся к чистым полным продолжениям и наблюдаемым значениям, а не к адресам или внешней мутации.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; основной пример bracket проверяет этот договор явно.

## English explanation

Two bind operations over generic Maybe; the application half still checks an integer for evenness.

**Companion implementation:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

**Scenario.** Apply half twice through bind. some retains a value record with its own type; next receives the payload through ordinary call admission. Absence skips the continuation. The probes remain 8, 6 and 3.

**Expected observation.** 8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Specialized historical implementations do not satisfy the full generalized current contract. There is one current component implementation; historical specialized code is not offered as another library dependency.

**Primary LMX.** The operations are directly available from the current core. `(x record)` captures the primitive value record without an IntBox. A Maybe payload uses a record reference; bind invokes half through generic apply, passing an actual int value. The named value actual keeps the record whole.

**Current core implementation.** The operations are directly available from the current core. `(x record)` captures the primitive value record without an IntBox. A Maybe payload uses a record reference; bind invokes half through generic apply, passing an actual int value. The named value actual keeps the record whole.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [Haskell 2010 Report, predefined types and Monad](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html) — Контекст Maybe и три закона bind; готовый Prelude Maybe в листингах этой пары не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственный алгебраический тип, сопоставление конструкторов и объявления fixity.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Собственный enum для двух вариантов Maybe; готовый Option не используется.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.ru.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.
