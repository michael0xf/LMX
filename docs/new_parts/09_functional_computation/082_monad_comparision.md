# 082. Monad

Использование готовой библиотеки Maybe<int> и её bind: отсутствие пропускает продолжение.

**Реализация используемого компонента:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

## Общий сценарий

Клиент определяет прикладной half: чётное число превращается в присутствующую половину, нечётное — в none. Два bind применяют half к 8, 6 и 3. Конструкторы, контейнер и bind предоставлены соседним сравнением реализации.

**Ожидаемое наблюдение:** 8 → присутствующее 2; 6 → отсутствие после второго half; 3 → отсутствие после первого half, второй half не вызывается. Готовая ссылка на half сама по себе вызовом не является.

**Граница сравнения:** Использование библиотеки. Сравнивается только клиент конкретного Maybe<int>. Внешняя мутация опубликованных значений запрещена договором библиотеки. Это не универсальный Monad/IO/State и не доказательство законов для эффектных продолжений. Два bind явно сгруппированы слева; значение приоритета шаблона не подменяет закон ассоциативности монады.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

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

Входы Example\run(8), Example\run(6), Example\run(3). Зависимость: examples/lmx/091_maybe_container_and_bind_implementation.lm3, загруженный перед этим файлом. Реализация библиотеки считается отдельно.

[Отдельный листинг](examples/lmx/082_monad.lm3)

## Haskell

```haskell
module MonadExample where
import MaybeInt (MaybeInt, unit, none, bind)

half :: Int -> MaybeInt
half x = if even x then unit (x `div` 2) else none

run :: Int -> MaybeInt
run x = (unit x `bind` half) `bind` half
```

Haskell2010. Скомпилировать вместе с examples/haskell/091_maybe_container_and_bind_implementation.hs: этот файл объявляет импортируемый модуль MaybeInt. Самописный bind показан целиком в companion. Внешние пробы run 8, run 6 и run 3 одинаково исключены из клиентского кода.

[Отдельный листинг](examples/haskell/082_monad.hs)

## Scala

```scala
import MaybeInt.*

object MonadExample {
  def half(x: Int): Value =
    if (x % 2 == 0) unit(x / 2) else none()
  def run(x: Int): Value = unit(x).bind(half).bind(half)
}
```

Scala 3. Компилировать с examples/scala/091_maybe_container_and_bind_implementation.scala. Value и bind принадлежат этой авторской библиотеке; Option не используется. Внешние вызовы MonadExample.run(8), run(6), run(3).

[Отдельный листинг](examples/scala/082_monad.scala)

## Разбор LMX

Загрузить авторскую библиотеку Maybe/MaybeOps из Maybe container and bind implementation, затем этот клиент. import делает её уже загруженные объявления видимыми; это обычный namespace-import, а не новый файловый загрузчик. unit/none и bind имеют ровно контракт показанной библиотеки. Режим 0 достаточен: half передаётся как ссылка; bind решает, вызывать ли её. Приложение сохраняет условие чётности и цепочку вычисления. import выполняется в теле half/run; в DATA Example остаются только x и return, поэтому импортируемые постоянные свойства операнда не сдвигают позиционный x.

## Сопоставление

Все три клиента используют готовую библиотеку с собственными реализациями, приведёнными рядом. Из клиентского размера исключена библиотека у всех трёх; обращения и импорты включены. Haskell здесь импортирует MaybeInt, Scala — MaybeInt, а не готовые Prelude Maybe и Option.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 131 | 11 |
| Haskell | 169 | 6 |
| Scala | 135 | 6 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Using a ready Maybe<int> library and its bind: absence skips the continuation.

**Implementation of the supplied component:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

**Scenario.** The client defines half: an even number yields a present half and an odd number yields none. Two binds apply half to 8, 6 and 3. Constructors, the container and bind are supplied by the adjacent implementation comparison.

**Expected observation.** 8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

**LMX.** Load the author-supplied Maybe/MaybeOps library from Maybe container and bind implementation, then this client. import exposes already loaded declarations through ordinary namespace import; it is not a new file loader. unit/none and bind have exactly that library contract. Mode 0 suffices: half is passed as a reference and bind decides whether to call it. The parity condition and computation chain remain application code. Client imports are placed directly inside half/run, where the library is used. The companion implementation puts sys\OPERANDS_TEMPLATE first in MaybeOps DATA, preserving left/right as the first input positions.

**Comparison.** All three clients use ready libraries whose custom implementations are shown alongside. Library code is excluded from every client count; calls and imports are included. Haskell imports MaybeInt and Scala imports MaybeInt rather than relying on Prelude Maybe or Option.

**Scope and limitations.** Only the client of concrete Maybe<int> is compared. The library contract forbids external mutation of published values. This is not universal Monad/IO/State or a proof of laws for effectful continuations. The two binds are explicitly grouped to the left; the header priority is not the monad associativity law.

### Dependencies and execution boundaries

- **LMX:** Call Example\run(8), Example\run(6), Example\run(3). Dependency: examples/lmx/091_maybe_container_and_bind_implementation.lm3 loaded before this file. The library implementation is counted separately.
- **Haskell:** Haskell2010. Compile together with examples/haskell/091_maybe_container_and_bind_implementation.hs, which declares the imported MaybeInt module. The companion shows the complete custom bind. External probes run 8, run 6 and run 3 are excluded from the client code equally.
- **Scala:** Scala 3. Compile with examples/scala/091_maybe_container_and_bind_implementation.scala. Value and bind belong to that author-supplied library; Option is not used. External calls: MonadExample.run(8), run(6), run(3).

## Источники / Sources

- [Haskell 2010 Report, predefined types and Monad](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html) — Контекст Maybe и три закона bind; готовый Prelude Maybe в листингах этой пары не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственный алгебраический тип, сопоставление конструкторов и объявления fixity.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Собственный enum для двух вариантов Maybe; готовый Option не используется.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
