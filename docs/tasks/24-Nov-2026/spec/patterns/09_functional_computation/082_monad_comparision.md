# 082. Monad

Maybe: явная проверка промежуточного результата и компактная цепочка bind.

## Общий сценарий

Выполнить some(x) bind half bind half. Значение хранится со своим фактическим типом, half получает его обычным вызовом. При None следующие продолжения пропускаются. Проверки остаются 8, 6, 3 и дополнительно 0.

**Ожидается:** 8 → присутствующее 2; 6 → отсутствие после второго half; 3 → отсутствие после первого half, второй half не вызывается. Готовая ссылка на half сама по себе вызовом не является.

Общие реализации: [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md). Они учитываются отдельно; иностранные клиенты не импортируют эти сравнительные модули.

## Граница двух стилей

Оба варианта вызывают half по порядку и прекращают цепочку после none. Процедурный код проверяет present явно; функциональный использует общий bind. some/value capture остаётся общим конструктором ядра.

## LMX — процедурный

```lmx
Example:
    int: x
    return: FxMaybe@
    half:
        throws: FxRecordArity
        if: x % 2 = 0
            return: some(x / 2)
        return: none()
    run:
        throws: copy(half\throws)
        @: result half(x)
        if: result\present = 0
            return: result
        return: half(\result\value)
```

[Полный исходник](examples/lmx/procedural/082_monad.lm3). 191 непробельных символов; 14 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int: x
    return: FxMaybe@
    half:
        throws: FxRecordArity
        if: x % 2 = 0
            return: some(x / 2)
        return: none()
    run:
        throws: FxRecordArity copy(FxMaybeBindOperand\bind\throws)
        return: some(x) bind half bind half
```

[Полный исходник](examples/lmx/082_monad.lm3). 180 непробельных символов; 11 непустых строк. Все объявления и Throws включены.


## Haskell

```haskell
module MonadExample where

half :: Int -> Maybe Int
half x = if even x then Just (x `div` 2) else Nothing

run :: Int -> Maybe Int
run x = Just x >>= half >>= half
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/haskell/082_monad.hs)

## Scala

```scala
object MonadExample {
  def half(x: Int): Option[Int] =
    if (x % 2 == 0) Some(x / 2) else None
  def run(x: Int): Option[Int] = Some(x).flatMap(half).flatMap(half)
}
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/scala/082_monad.scala)

## Подсчёт полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 191 | 14 |
| LMX — функциональный | 180 | 11 |
| Haskell | **125** | 5 |
| Scala | 135 | 5 |

Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.

Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.

## Семантические границы

Чётность — конкретная задача над int; библиотечные конструкторы и bind этим типом не ограничены. Требуется подготовленный контекст публичных семейств и адаптивного входа. Законы монады относятся к допустимым чистым продолжениям и наблюдаемым значениям. Изменённый LMX-пример не исполнялся.

[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).

## English explanation

Maybe: explicit intermediate branching and a compact bind chain.

**Scenario.** Evaluate some(x) bind half bind half. The payload keeps its actual type and half receives it through ordinary admission. None skips subsequent continuations. The probes include 8, 6, 3 and 0.

**Expected.** 8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

**Limits.** Evenness is an integer-specific application; the constructors and bind are generic. Public-family selection and adaptive value admission are part of the prepared context. Monad laws concern admissible pure continuations and observable values. The revised LMX example has not been executed.

Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.

## Источники

- [Haskell Maybe and Monad instance](https://hackage-content.haskell.org/package/base-4.21.0.0/docs/Data-Maybe.html)
- [Scala Option.flatMap](https://www.scala-lang.org/api/2.13.16/scala/Option.html)

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.
