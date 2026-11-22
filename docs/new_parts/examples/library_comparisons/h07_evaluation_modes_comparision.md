# Lazy: общий отложенный результат и повтор эффектов

Редакция: 22 ноября 2026 года. Клиент: [H07](../lmx/H07.lm3), [разбор](../../LMX_examples_and_analogies.ru.md#h07).

## Контракт общего ресивера

lazy получает nullary-callable и сохраняет точный тип его результата. До первого исполнения цель не вызывается; успешный результат кешируется, отказ оставляет возможность повторить попытку. Повторный вход в вычисляющийся thunk даёт FxLazyCycle. Здесь один владелец Message; потокобезопасный разделяемый между Message кеш не обещается.

Публичный ресивер `lazy` уже входит в единое текущее ядро и используется прямо. Никаких import или выбираемых версий библиотек нет. Внутренние Fx/Rx-имена ниже обозначают структуры реализации ядра.

Этот документ показывает исходники общего ядрового механизма и локального процедурного приёма. Это разные области контракта, а не две взаимозаменяемые версии ядра: специализированный приём не подменяет весь общий API только потому, что он короче. Основной клиент выбирается отдельно из корректных вариантов по полной длине и границе учёта, см. H07.

## Полный алгоритм ресивера ядра LMX

Ниже приведено консервативное замыкание по корневым LMX-определениям от `FxLazy`: полные определения перечислены один раз, включая те, которые упомянуты в генерируемом тексте тела. Это видимый исходник текущего ядра; он не подменяется строкой импорта. Общие определения повторно используются другими receivers; одинаковые определения не считаются новой самостоятельной реализацией для каждого клиента.

- [generic_functions.lmx](../../LMX_Fn_Receivers/src/generic_functions.lmx)
- [generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx)
- [generic_wrappers.lmx](../../LMX_Fn_Receivers/src/generic_wrappers.lmx)

```lmx
FxAppend:
    private:
        @: first
        @: second
    return: @
    append:
        private: @: out (copy(()))
        private: int: n length(first)
        sys\resize(out; n + length(second))
        private: int: i 0
        while: i < n
            out[i] := first[i]
            i += 1
        private: int: j 0
        while: j < length(second)
            out[n + j] := second[j]
            j += 1
        return: out

FxFailures:
    private:
        @: first
        @: second
    return: @
    union:
        # Builder интернирует и устраняет повторные имена. Список не фиксирован.
        return: FxAppend\append(first; second)

FxTry:
    private:
        @: operation
        @: args
    return: @
    attempt:
        throws:
            FxKernelFailure
            FxTypeToken
        private: @: info FxKernel\signature(subject := operation)
        return: FxKernel\attempt(operation; args; info\throws)

FxApply:
    private:
        @: operation
        @: args
    return: @
    apply:
        throws:
            FxCallFailure
            FxKernelFailure
            FxTypeToken
        private: @: outcome FxTry\attempt(operation := operation; args := args)
        if: outcome\ok = 0
            throw: FxCallFailure(outcome)
        return: outcome\value

FxLazyEngine:
    private:
        @: state
        @: args
    return: @
    run:
        throws:
            FxCallFailure
            FxKernelFailure
            FxLazyCycle
            FxTypeToken
        if: state\status = 2
            return: state\value
        if: state\status = 1
            throw: FxLazyCycle()
        state\status := 1
        private: int: completed 0
        finally:
            if: completed = 0
                state\status := 0
        ---
        private: @: result FxApply\apply(state\operation; args)
        state\value := result
        state\status := 2
        completed := 1
        return: result

FxLazyState:
    @: operation 0
    int: status 0
    @: value 0

FxConcat:
    private:
        []: char first
        []: char second
    return: []: char
    concat:
        private: []: char out ()
        private: int: n length(first)
        private: int: m length(second)
        sys\resize(out; n + m)
        private: int: i 0
        while: i < n
            out[i] := first[i]
            i += 1
        private: int: j 0
        while: j < m
            out[n + j] := second[j]
            j += 1
        return: out

FxDecimal:
    private: int: number
    return: []: char
    decimal:
        throws:
            FxIndex
        if: number < 0
            throw: FxIndex()
        private: []: char digits "0123456789"
        private: []: char reversed ()
        private: int: used 0
        private: int: rest number
        while: 1
            sys\resize(reversed; used + 1)
            reversed[used] := digits[rest % 10]
            used += 1
            rest := rest / 10
            if: rest = 0
                break
        ---
        private: []: char out ()
        sys\resize(out; used)
        private: int: i 0
        while: i < used
            out[i] := reversed[used - i - 1]
            i += 1
        return: out

FxLabels:
    private: int: count
    return: @
    labels:
        throws:
            FxIndex
        if: count < 0
            throw: FxIndex()
        private: @: out (copy(()))
        sys\resize(out; count)
        private: int: i 0
        while: i < count
            out[i] := FxConcat\concat("p"; FxDecimal\decimal(i))
            i += 1
        return: out

FxSignatures:
    private:
        @: inputs
        @: result
    return: @
    make:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: labels FxLabels\labels(length(inputs))
        private: @: data FxKernel\signatureData(inputs := inputs; result := result; labels := labels)
        Built :: data
        return: Built

FxBuild:
    private:
        @: contract
        []: char bodyText
        @: state
        @: failures
    return: @
    make:
        throws:
            FxKernelFailure
            FxTypeToken
        private: @: shape FxKernel\signature(subject := contract)
        private: @: bodyGraph sys\fromLmx(bodyText)
        return: FxKernel\callable(contract; shape\names; bodyGraph; state; failures)

FxEngineState:
    @: engine 0
    @: payload 0
    @: record 0

FxSameText:
    private:
        []: char first
        []: char second
    return: int
    same:
        if: length(first) != length(second)
            return: 0
        private: int: i 0
        while: i < length(first)
            if: first[i] != second[i]
                return: 0
            i += 1
        return: 1

FxFailureFilter:
    private:
        @: names
        []: char excluded
    return: @
    without:
        private: @: out (copy(()))
        sys\resize(out; length(names))
        private: int: used 0
        private: int: i 0
        while: i < length(names)
            private: []: char name \names[i]
            if: FxSameText\same(name; excluded) = 0
                out[used] := names[i]
                used += 1
            i += 1
        sys\resize(out; used)
        return: out

FxRecordOperands:
    copy: sys\OPERANDS_TEMPLATE
    required: left right
    return: @
    record:
        throws:
            FxRecordArity
        if: length(right) != 0
            throw: FxRecordArity()
        return: left

FxStageFailures:
    return: @
    names:
        private: @: out (copy(()))
        sys\resize(out; 5)
        out[0] := "FxIndex"
        out[1] := "FxArity"
        out[2] := "FxRecordArity"
        out[3] := "FxTypeToken"
        out[4] := "FxKernelFailure"
        return: out

FxWrap:
    private:
        @: contract
        @: engine
        @: payload
        @: failures
    return: @
    make:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: info FxKernel\signature(subject := contract)
        private: @: state (copy(FxEngineState))
        state\engine := engine
        state\payload := payload
        state\record := FxRecordOperands\record
        private: []: char text "private: @: fx_args (copy(()))\nsys\\resize(fx_args; "
        text := FxConcat\concat(text; FxDecimal\decimal(length(info\inputTypes)))
        text := FxConcat\concat(text; ")\n")
        private: int: i 0
        while: i < length(info\inputTypes)
            private: []: char number FxDecimal\decimal(i)
            text := FxConcat\concat(text; "fx_args[")
            text := FxConcat\concat(text; number)
            text := FxConcat\concat(text; "] := (p")
            text := FxConcat\concat(text; number)
            text := FxConcat\concat(text; " node\\private\\state\\record)\n")
            i += 1
        text := FxConcat\concat(text; "private: @: fx_engine node\\private\\state\\engine\n")
        text := FxConcat\concat(text; "private: @: fx_answer fx_engine(state := node\\private\\state\\payload; args := fx_args)\n")
        if: info\hasResult != 0
            text := FxConcat\concat(text; "return: \\fx_answer\n")
        else:
            text := FxConcat\concat(text; "return\n")
        text := FxConcat\concat(text; "catch: FxCallFailure (@: outcome)\n    FxKernel\\raise(name := outcome\\failure; payload := outcome\\payload)\n")
        private: @: engineInfo FxKernel\signature(subject := engine)
        private: @: escapingEngine FxFailureFilter\without(engineInfo\throws; "FxCallFailure")
        private: @: allFailures FxFailures\union(failures; FxStageFailures\names())
        allFailures := FxFailures\union(allFailures; escapingEngine)
        return: FxBuild\make(contract; text; state; allFailures)

FxOnce:
    private: @: operation
    return: @
    once:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: info FxKernel\signature(subject := operation)
        private: @: contract FxSignatures\make(info\inputTypes; info\resultType)
        private: @: state (copy(FxLazyState))
        state\operation := operation
        private: @: failures FxFailures\union(info\throws; ("FxLazyCycle"))
        return: FxWrap\make(contract; FxLazyEngine\run; state; failures)

FxLazy:
    private: @: operation
    return: @
    lazy:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: info FxKernel\signature(subject := operation)
        if: length(info\inputTypes) != 0
            throw: FxArity()
        return: FxOnce\once(operation := operation)
```

Явная граница ядра: `FxKernel`, системные примитивы и стандартные вызовы, описанные в [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). Это требуемые адаптеры к штатным операциям графа/вызова, а не показанный здесь C-код готового ядра. Их реализация не спрятана в цифре «размер библиотеки»: статус и условия приёмки приведены отдельно. Полный [собранный файл](../../LMX_Fn_Receivers/LMX_Receivers.lmx) и [экспорт имён](../../LMX_Fn_Receivers/src/public.lmx) находятся рядом.

## Реализация Haskell

lazyIO — явная общая реализация на IORef для одного потока: Cold/Busy/Ready, сброс после ошибки и вычисление результата до WHNF. Она не объявляется атомарным многопоточным кешем. Void LMX и () Haskell имеют разные представления. Прежний prepared/raw пример сохранён отдельно: lazy не выдаётся за доступ к исходным LMX-occurrences.

[Точный исходник модуля](../libraries/haskell/Lazy.hs):

```haskell
module Lazy (lazyIO) where

import Control.Exception (evaluate, mask, onException)
import Data.IORef (newIORef, readIORef, writeIORef)

data LazyState a = Cold | Busy | Ready a

lazyIO :: IO a -> IO (IO a)
lazyIO action = do
  cell <- newIORef Cold
  pure $ mask $ \restore -> do
    state <- readIORef cell
    case state of
      Ready value -> pure value
      Busy -> ioError (userError "LazyCycle")
      Cold -> do
        writeIORef cell Busy
        value <- restore (action >>= evaluate) `onException` writeIORef cell Cold
        writeIORef cell (Ready value)
        pure value
```

## Процедурный механизм сценария на том же ядре

Этот обычный пользовательский код показывает явный механизм конкретного сценария. Его int-специализация не является ограничением общего core-ресивера. Он не заменяет весь общий контракт ядра и не является старой библиотечной версией. У клиента он считается, если включён в его выбранный исходник; в таблице ниже его стоимость показана отдельно.

```lmx
PreparedOps:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    twice:
        return: \left + \left

RawOps:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    twice:
        int: first sys\eval(left)
        int: second sys\eval(left)
        return: first + second
```

## Размеры и границы сравнения

| Показанный код | Непробельные символы | Непустые строки | UTF-8 байты |
| --- | ---: | ---: | ---: |
| LMX: алгоритм и перечисленные LMX-зависимости | 5492 | 295 | 8674 |
| Haskell: весь показанный модуль | 438 | 17 | 589 |
| LMX: процедурный механизм сценария, отдельный контракт | 295 | 18 | 425 |

Это механические размеры показанных исходников. LMX строит обычные графовые callable с точными сигнатурами; Haskell пользуется собственным типовым и функциональным runtime. Таблица не утверждает равенства стоимости их ядер, минимальности замыкания зависимостей или одинаковой реализации. Реализация ядра показана отдельно от клиента. Исключать её из конкурентного клиентского сравнения допустимо при сопоставимом встроенном/библиотечном/операторном механизме у контроля, либо как естественный механизм языка без скрытого предметного алгоритма. Архитектуры не обязаны совпадать; поля, состояние, копии, идентичности и эффекты обязаны сохраняться. Сравнение по клиентам и исходные сохранённые хеши — в [functional_receiver_counts.json](../validation/functional_receiver_counts.json).

**Проверка:** текст, ссылки и размеры воспроизводятся [скриптом](../tools/update_receiver_comparisons.py). LMX и GHC здесь не запускались; подготовленные assertions в [Analogies.hs](../haskell/Analogies.hs) не являются receipt исполнения.
