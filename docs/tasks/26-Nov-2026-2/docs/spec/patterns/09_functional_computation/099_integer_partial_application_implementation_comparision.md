# 099. General partial-application implementation

Общая реализация partial(F;prefix): произвольная смешанная сигнатура, 0≤k≤N, точный остаточный контракт и исходный return.

## Общий сценарий

Реализовать произвольный типизированный префикс без привязки к int и двум входам: сохранить k из N значений в порядке и вернуть callable для N-k входов, не вызывая цель. Haskell Args/Callable и Scala Tuple/Callable задают вектор типов явно; LMX отражает существующий DATA и дополнительно сохраняет его defaults/binding.

**Ожидается:** Общий случай сохраняет порядок и типы входов, точный R и объявленные failures. Для клиента сложения результат — 6,101,6. Для N=0 фабрика возвращает nullary callable; для k>N отказ происходит до публикации результата.

Клиенты: [085. Currying](085_currying_comparision.md), [083. Trampoline](083_trampoline_comparision.md). Одно тело ядра обслуживает обе формы записи.

## LMX — единая общая реализация

```lmx
FxPartial:
    private:
        @: operation
        @: prefix
    return: @
    partial:
        throws: copy(FxThrows\capture)
        private: @: info FxKernel\signature(subject := operation)
        private: int: n length(info\inputTypes)
        private: int: k length(prefix)
        if: k > n
            throw: FxArity()
        private: @: captured FxCapturePrefix\capture(info\inputTypes; prefix)
        private: @: remaining FxSlice\slice(info\inputTypes; k; n - k)
        private: @: contract FxSignatures\make(remaining; info\resultType)
        private: @: policy FxPrefixPolicy\make(operation; captured)
        return: FxWrap\make(contract; FxForwardEngine\run; (copy(())); info\throws; policy)
```

[Исходник](examples/lmx/099_integer_partial_application_implementation.lm3)

Основной листинг — точные определения FxPartial из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

## Haskell

```haskell
{-# LANGUAGE DataKinds, GADTs, KindSignatures, TypeFamilies, TypeOperators #-}
module Partial (Args(..), Callable(..), Append, appendArgs, partial) where
import Data.Kind (Type)

data Args (types :: [Type]) where
  Nil :: Args '[]
  (:&) :: value -> Args rest -> Args (value ': rest)
infixr 5 :&

type family Append prefix rest where
  Append '[] rest = rest
  Append (value ': prefix) rest = value ': Append prefix rest

appendArgs :: Args prefix -> Args rest -> Args (Append prefix rest)
appendArgs Nil rest = rest
appendArgs (value :& prefix) rest = value :& appendArgs prefix rest

newtype Callable inputs result = Callable { invoke :: Args inputs -> result }

partial :: Callable (Append prefix rest) result -> Args prefix -> Callable rest result
partial (Callable operation) prefix =
  Callable (\rest -> operation (appendArgs prefix rest))
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/haskell/099_integer_partial_application_implementation.hs)

## Scala

```scala
object Partial {
  final case class Callable[Inputs <: Tuple, Result](invoke: Inputs => Result)

  def partial[Prefix <: Tuple, Rest <: Tuple, Result](
      operation: Callable[Tuple.Concat[Prefix, Rest], Result],
      prefix: Prefix): Callable[Rest, Result] =
    Callable(rest => operation.invoke(prefix ++ rest))
}
```

Самостоятельная полная реализация объявленного ниже API для сравнения с LMX; клиент её не импортирует. Это не копия всей стандартной библиотеки.

[Исходник](examples/scala/099_integer_partial_application_implementation.scala)

## Подсчёт полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — общая реализация | 533 | 17 |
| Haskell | 699 | 17 |
| Scala | <span style="color:#176233"><u>263</u></span> | 7 |

Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.

Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.

## Семантические границы

Все три реализации допускают пустой/полный префикс, разнородные значения, независимые захваты, ссылочную идентичность и void/Unit. Haskell/Scala отвергают неверные формы статически, а нулевой вызов получает Nil/EmptyTuple. LMX проверяет во время выполнения и дополнительно сохраняет defaults/private/dynamic binding исходного callable. Foreign Callable — только сравнение реализации; usage его не импортирует.

[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).

## English explanation

General partial(F;prefix): an arbitrary heterogeneous signature, 0≤k≤N, exact residual contract and original return.

**Scenario.** Implement arbitrary typed prefix binding with no int-only values or fixed binary arity. Capture k of N inputs in order and return an ordinary callable for N-k inputs without calling the target. Haskell Args/Callable and Scala Tuple/Callable encode input vectors explicitly; LMX reflects existing callable DATA and preserves its richer defaults/binding contract.

**Expected.** The general case retains input order/types, exact R and declared failures. The addition client yields 6,101,6. N=0 produces a nullary callable; k>N fails before publishing a result.

**Limits.** All three implementations cover empty/full prefixes, heterogeneous records, independent captures, reference identity and void/Unit results. Haskell and Scala reject incompatible prefix shapes statically and use Nil/EmptyTuple for nullary calls. LMX checks at runtime and also preserves declaration-specific defaults/private/dynamic binding through its adapters. The typed foreign Callable is a comparison implementation, never an imported usage dependency.

Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.

## Источники

- [GHC GADTs](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/gadt.html)
- [Scala Tuple concatenation](https://www.scala-lang.org/api/3.x/scala/Tuple.html)

## Проверка

[Проверка публикации](VALIDATION_2026-11-26.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.
