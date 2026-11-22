# 091. Maybe container and bind implementation

Собственная библиотека Maybe<int>: конструкторы присутствия/отсутствия и бинарный bind во всех трёх языках.

**Примеры использования:** [082. Monad](082_monad_comparision.md)

## Общий сценарий

Реализовать unit(int), none и bind(Maybe<int>, int→Maybe<int>). Для отсутствия bind возвращает отсутствие без чтения payload и без вызова продолжения; для присутствия вызывает продолжение один раз с числом. Клиент Monad использует именно эти реализации.

**Ожидаемое наблюдение:** unit(0) остаётся присутствующим нулём; none отличается от него. bind(none, next) не вызывает next; bind(unit(8), half) даёт присутствующее 4. Для чистых total-продолжений выполняются left identity, right identity и associativity по наблюдаемому значению.

**Граница сравнения:** Реализация библиотеки. Это конкретный Maybe<int>, не универсальный Monad, IO или transformer. Контракт bind бинарный: один Maybe слева и одно продолжение справа; некорректные формы вне этой области не сравниваются. Законы не сравнивают адреса контейнеров и предполагают отсутствие внешней мутации, исключений и наблюдаемых эффектов продолжений. Общий none не является физическим uninit.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

## LMX

```lmx
MaybeValue:
    int: present 0
    int: value 0

Maybe:
    int: value
    return: @
    unit:
        @: result (copy(MaybeValue))
        result\present := 1
        result\value := value
        return: result
    none:
        return: MaybeValue

MaybeOps:
    copy: sys\OPERANDS_TEMPLATE
    return: @
    bind:
        @: input MaybeValue \left
        @: next \right[0]
        if: input\present = 0
            return: input
        return: next(input\value)
```

Авторская библиотека из этого листинга, а не builtin Maybe. Заголовок sys\OPERANDS_TEMPLATE даёт режим 0 и приоритет сложения; скобки клиента явно задают цепочку. Перед клиентом загрузить этот граф в тот же namespace.

[Отдельный листинг](examples/lmx/091_maybe_container_and_bind_implementation.lm3)

## Haskell

```haskell
module MaybeInt (MaybeInt(..), unit, none, bind) where

data MaybeInt = Absent | Present Int deriving (Eq, Show)

unit :: Int -> MaybeInt
unit = Present

none :: MaybeInt
none = Absent

infixl 1 `bind`
bind :: MaybeInt -> (Int -> MaybeInt) -> MaybeInt
bind Absent _ = Absent
bind (Present value) next = next value
```

Haskell2010. Собственный тип MaybeInt и функция bind; стандартный экземпляр Monad не используется. Передавать этот файл компилятору вместе с клиентом или размещать модуль как MaybeInt.hs на пути поиска.

[Отдельный листинг](examples/haskell/091_maybe_container_and_bind_implementation.hs)

## Scala

```scala
object MaybeInt {
  enum Value {
    case Absent
    case Present(value: Int)
    def bind(next: Int => Value): Value = this match {
      case Absent => Absent
      case Present(value) => next(value)
    }
  }
  def unit(value: Int): Value = Value.Present(value)
  def none(): Value = Value.Absent
}
```

Scala 3. Собственный enum и метод bind; ни Option, ни готовый flatMap не вызываются. Этот файл и клиент компилируются вместе.

[Отдельный листинг](examples/scala/091_maybe_container_and_bind_implementation.scala)

## Разбор LMX

MaybeValue содержит только данные. unit создаёт отдельный результат через (copy(MaybeValue)); none возвращает общий отсутствующий прототип. Опубликованные значения не изменяются по договору. MaybeOps копирует общий заголовок ядра; bind читает подготовленный Maybe через \left и готовую ссылку на продолжение через \right[0]. Только явный next(input\value) вызывает продолжение. Логический результат @ остаётся ссылкой.

## Сопоставление

Во всех трёх листингах показаны собственный тип, конструкторы и вся логика bind. Haskell не использует Maybe/Monad из Prelude, Scala не использует Option/flatMap. Подсчёт включает этот код целиком; реализации примитивов, обычного вызова и структурного шаблона ядра остаются инфраструктурой языка.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 297 | 22 |
| Haskell | 255 | 10 |
| Scala | 223 | 12 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A custom Maybe<int> library: present/absent constructors and binary bind in all three languages.

**Usage examples:** [082. Monad](082_monad_comparision.md)

**Scenario.** Implement unit(int), none and bind(Maybe<int>, int→Maybe<int>). For absence, bind returns absence without reading a payload or calling the continuation; for presence it calls the continuation once with the number. The Monad client uses these exact implementations.

**Expected observation.** unit(0) remains a present zero and differs from none. bind(none, next) does not call next; bind(unit(8), half) yields present 4. Pure total continuations satisfy left identity, right identity and associativity by observable value.

**LMX.** MaybeValue contains data only. unit builds a separate result with (copy(MaybeValue)); none returns the shared absent prototype. Published values are immutable by contract. MaybeOps copies the kernel header; bind reads the prepared Maybe through \left and a prepared continuation reference through \right[0]. Only next(input\value) invokes the continuation. The logical @ result remains a reference.

**Comparison.** All three listings show the custom type, constructors and complete bind logic. Haskell does not use Prelude Maybe/Monad; Scala does not use Option/flatMap. The complete shown library is counted; primitive types, ordinary calls and the kernel structural header remain language infrastructure.

**Scope and limitations.** This is concrete Maybe<int>, not universal Monad, IO or a transformer. bind is binary: one Maybe on the left and one continuation on the right; malformed forms are outside this comparison. The laws ignore container addresses and assume no external mutation, exceptions or observable continuation effects. Shared none is not physical uninit.

### Dependencies and execution boundaries

- **LMX:** This listing defines an author-supplied library, not a built-in Maybe. sys\OPERANDS_TEMPLATE supplies mode 0 and addition priority; client parentheses explicitly group the chain. Load this graph into the same namespace before the client.
- **Haskell:** Haskell2010. Custom MaybeInt type and bind function; no standard Monad instance is used. Supply this source together with the client or place it as MaybeInt.hs on the module search path.
- **Scala:** Scala 3. A custom enum and bind method; neither Option nor a ready flatMap is called. Compile this source and its client together.

## Источники / Sources

- [Haskell 2010 Report, predefined types and Monad](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html) — Контекст Maybe и три закона bind; готовый Prelude Maybe в листингах этой пары не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственный алгебраический тип, сопоставление конструкторов и объявления fixity.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Собственный enum для двух вариантов Maybe; готовый Option не используется.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
