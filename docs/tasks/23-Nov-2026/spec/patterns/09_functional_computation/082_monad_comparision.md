# 082. Monad

Две операции bind над обобщённым Maybe; прикладной half по-прежнему проверяет чётность целого числа.

**Сравнения реализаций:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md). Это ссылки для чтения, не импорты самописных модулей в контрольные usage-клиенты.

## Общий сценарий

Вызвать half дважды через bind. В some хранится запись значения с его собственным типом, а next получает само значение по обычному контракту вызова. Для отсутствия продолжение не вызывается. Проверки остаются 8, 6 и 3.

**Ожидаемое наблюдение:** 8 → присутствующее 2; 6 → отсутствие после второго half; 3 → отсутствие после первого half, второй half не вызывается. Готовая ссылка на half сама по себе вызовом не является.

**Граница сравнения.** LMX вызывает непосредственные операции текущего ядра; контрольные языки используют настоящую библиотеку или собственные средства языка. Самописные аналоги из соседних сравнений сюда не импортируются.

| Язык | Используемое средство |
| --- | --- |
| Haskell | `base: Maybe, Just, Nothing, (>>=)` |
| Scala | `scala-library: Option, Some, None, flatMap` |

## LMX — прямой API ядра

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

[Исходник](examples/lmx/082_monad.lm3)

## Haskell — готовое средство языка/библиотеки

```haskell
module MonadExample where

half :: Int -> Maybe Int
half x = if even x then Just (x `div` 2) else Nothing

run :: Int -> Maybe Int
run x = Just x >>= half >>= half
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/haskell/082_monad.hs)

## Scala — готовое средство языка/библиотеки

```scala
object MonadExample {
  def half(x: Int): Option[Int] =
    if (x % 2 == 0) Some(x / 2) else None
  def run(x: Int): Option[Int] = Some(x).flatMap(half).flatMap(half)
}
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/scala/082_monad.scala)

## Подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 226 | 17 |
| Haskell | 125 | 5 |
| Scala | 135 | 5 |

Считается только `listings[].code`, включая импорты, объявления и throws. Альтернативный подход не прибавляется к основному. [Выбор](variant_selection.json) сравнивает допустимые варианты одной границы. [Зависимости реализации](IMPLEMENTATION_DEPENDENCIES.md) показывают общие LMX-тела отдельно.

## Удалённые малозначимые повторы

Удалены полные повторы, отличавшиеся импортом, написанием вызова, повторением общего тела либо специализацией на int. Эти отличия не образуют отдельного текущего алгоритма; исходная редакция сохраняется в базе diff.

## Семантические границы

Обобщение относится к хранимому значению и типам A→Maybe<B>, а не к любому возможному Monad/IO/State. Прикладной half принимает int. Законы монады здесь относятся к чистым полным продолжениям и наблюдаемым значениям, а не к адресам или внешней мутации.

[Политика очистки, ошибок и Message/post](FAILURE_BOUNDARIES.md).

## English explanation

Two bind operations over generic Maybe; the application half still checks an integer for evenness.

**Scenario.** Apply half twice through bind. some retains a value record with its own type; next receives the payload through ordinary call admission. Absence skips the continuation. The probes remain 8, 6 and 3.

**Expected.** 8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

**Limits.** Generality covers payloads and A→Maybe<B>, not every possible Monad/IO/State. The application half takes int. Monad laws here concern pure total continuations and observable values, not addresses or external mutation.

Usage clients call the real language/library facility. Adjacent foreign implementations are independent comparison subjects and are not imported by usage clients. Only genuinely different approaches remain. The source listings have not been executed by an LMX/Haskell/Scala runtime in this workspace.

## Источники / Sources

- [Haskell Maybe and Monad instance](https://hackage-content.haskell.org/package/base-4.21.0.0/docs/Data-Maybe.html)
- [Scala Option.flatMap](https://www.scala-lang.org/api/2.13.16/scala/Option.html)

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [источники ядра](../LMX_Fn_Receivers/README.md).

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) сверяет данные, исходники, отсутствие подмены библиотечных клиентов и границы подсчёта. [Acceptance matrix](acceptance_cases.json) отделяет подготовленные наблюдения от реального запуска.
