# 099. Integer partial-application implementation

Повторяемый capture(binary, first): сохранить функцию и первый int, вернуть callable одного int.

**Примеры использования:** [085. Currying](085_currying_comparision.md)

## Общий сценарий

Для binary:(int,int)→int и first:int построить независимое сохранённое вычисление second→binary(first,second). Завершить фабрику, создать другую функцию и вызывать первую снова. Сложение не встроено в helper: его определяет клиент Currying.

**Ожидаемое наблюдение:** capture(add,5)(1)=6, capture(add,100)(1)=101, повтор первого даёт 6. Другая binary-функция также получает сохранённый первый и явный второй аргумент. Клиентская saved=1000 не заменяет capture; исходный LMX-прототип остаётся неизменным.

**Граница сравнения:** Реализация библиотеки. Helper ограничен двумя int-входами и int-результатом; это не универсальный curry для произвольных сигнатур. Сохраняется первый аргумент, не меняется default исходного метода и не добавляется второй публичный вход возвращённой функции. Граф подчиняется обычному времени жизни; клиент не мутирует сохранённое окружение.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

## LMX

```lmx
CapturePrototype:
    int: saved 0
    @: binary 0
    inputs:
        int: second
        return: int
        apply:
            return: node\binary(node\saved; second)

Curry:
    @: binary
    int: first
    return: @
    capture:
        @: instance (copy(CapturePrototype))
        @: owner parent(instance\inputs)
        owner\saved := first
        owner\binary := binary
        return: instance\inputs\apply
```

Обобщён на любую binary с указанной int×int→int сигнатурой уже показанный в архиве приём H03/085. Загрузить этот граф до клиента. Никаких скрытых native-замыканий или специального операнда нет.

[Отдельный листинг](examples/lmx/099_integer_partial_application_implementation.lm3)

## Haskell

```haskell
module CurryInt (capture) where

capture :: (Int -> Int -> Int) -> Int -> (Int -> Int)
capture binary first = \second -> binary first second
```

Haskell2010. Вся обёртка показана. Передать модуль CurryInt компилятору с клиентом или назвать файл CurryInt.hs для поиска по имени.

[Отдельный листинг](examples/haskell/099_integer_partial_application_implementation.hs)

## Scala

```scala
object CurryInt {
  def capture(binary: (Int, Int) => Int, first: Int): Int => Int =
    second => binary(first, second)
}
```

Scala 3. Собственная лямбда вместо вызова Function2.curried. Компилировать этот объект вместе с CurryingExample.

[Отдельный листинг](examples/scala/099_integer_partial_application_implementation.scala)

## Разбор LMX

Обычный copy строит отдельный граф окружения. parent(instance\inputs) выбирает фактического скопированного владельца, в него записываются saved и binary; возвращается его одновходовый inputs\apply. В теле node\saved и node\binary читают сохранённое окружение, а не одноимённые локалы вызывающего. Завершённый фабричный кадр не удерживается.

## Сопоставление

LMX показывает всю графовую реализацию захвата, Haskell и Scala — собственную lambda-обёртку. Готовый Scala .curried не используется. Разница в стоимости механизма остаётся видна именно здесь; клиент не оплачивает её при каждом использовании.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 275 | 18 |
| Haskell | 114 | 3 |
| Scala | 97 | 4 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Reusable capture(binary, first): retain a function and first int, returning a callable of one int.

**Usage examples:** [085. Currying](085_currying_comparision.md)

**Scenario.** Given binary:(int,int)→int and first:int, build an independent retained computation second→binary(first,second). Finish the factory, build another function and call the first again. Addition is not built into the helper; the Currying client defines it.

**Expected observation.** capture(add,5)(1)=6, capture(add,100)(1)=101 and calling the first again yields 6. A different binary function likewise receives the retained first and explicit second argument. Caller saved=1000 does not replace the capture; the LMX prototype is unchanged.

**LMX.** Ordinary copy creates a separate environment graph. parent(instance\inputs) selects the actual copied owner; saved and binary are written there, and its single-input inputs\apply is returned. node\saved and node\binary read the retained environment rather than same-named caller locals. No completed factory frame is retained.

**Comparison.** LMX shows the complete graph-based capture implementation; Haskell and Scala show custom lambda wrappers. Ready Scala .curried is not used. The mechanism cost difference remains visible here, while the client does not pay it at every use.

**Scope and limitations.** The helper is limited to two int inputs and an int result, not universal curry for arbitrary signatures. It retains the first argument rather than changing the original method default or exposing a second public input on the returned function. The graph follows ordinary lifetime rules and the client does not mutate its retained environment.

### Dependencies and execution boundaries

- **LMX:** Generalizes the archive H03/085 construction to any binary with the stated int×int→int contract. Load this graph before the client. There are no hidden native closures or special operands.
- **Haskell:** Haskell2010. The complete wrapper is shown. Supply CurryInt with the client or name its file CurryInt.hs for module lookup.
- **Scala:** Scala 3. A custom lambda rather than Function2.curried. Compile this object with CurryingExample.

## Источники / Sources

- [Haskell 2010 Report, expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html) — Функциональное применение, лямбда и лексически сохранённое значение.
- [Scala Tour, Higher-order Functions](https://docs.scala-lang.org/tour/higher-order-functions.html) — Функция как вход и создаваемая лямбда; готовый Function2.curried в этой паре не используется.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
