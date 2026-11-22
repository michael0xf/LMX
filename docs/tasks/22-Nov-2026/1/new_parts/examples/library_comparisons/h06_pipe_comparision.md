# Pipe: сохраняемая композиция точных сигнатур

Редакция: 22 ноября 2026 года. Клиент: [H06](../lmx/H06.lm3), [разбор](../../LMX_examples_and_analogies.ru.md#h06).

## Контракт общего ресивера

pipe(first; second) создаёт callable без исполнения стадий. Его входы совпадают со всеми входами first; second имеет один вход, принимающий результат first. Промежуточный и конечный типы могут отличаться. Сохранённый callable выполняет стадии один раз и в записанном порядке. Два компонента — смысл бинарной композиции, не ограничение арности исходной функции.

Публичный ресивер `pipe` уже входит в единое текущее ядро и используется прямо. Никаких import или выбираемых версий библиотек нет. Внутренние Fx/Rx-имена ниже обозначают структуры реализации ядра.

Этот документ показывает исходники общего ядрового механизма и локального процедурного приёма. Это разные области контракта, а не две взаимозаменяемые версии ядра: специализированный приём не подменяет весь общий API только потому, что он короче. Основной клиент выбирается отдельно из корректных вариантов по полной длине и границе учёта, см. H06.

## Полный алгоритм ресивера ядра LMX

Ниже приведено консервативное замыкание по корневым LMX-определениям от `FxPipe`: полные определения перечислены один раз, включая те, которые упомянуты в генерируемом тексте тела. Это видимый исходник текущего ядра; он не подменяется строкой импорта. Общие определения повторно используются другими receivers; одинаковые определения не считаются новой самостоятельной реализацией для каждого клиента.

- [generic_combinators.lmx](../../LMX_Fn_Receivers/src/generic_combinators.lmx)
- [generic_functions.lmx](../../LMX_Fn_Receivers/src/generic_functions.lmx)
- [generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx)

```lmx
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

FxOne:
    private: @: value
    return: @
    make:
        private: @: out (copy(()))
        sys\resize(out; 1)
        out[0] := value
        return: out

FxCompositionEngine:
    private:
        @: state
        @: args
    return: @
    run:
        throws:
            FxCallFailure
            FxKernelFailure
            FxTypeToken
        private: @: middle FxApply\apply(state\inner; args)
        return: FxApply\apply(state\outer; FxOne\make(middle))

FxCompositionState:
    @: outer 0
    @: inner 0

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

FxCompose:
    private:
        @: outer
        @: inner
    return: @
    compose:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: a FxKernel\signature(subject := outer)
        private: @: b FxKernel\signature(subject := inner)
        if: length(a\inputTypes) != 1 || b\hasResult = 0
            throw: FxArity()
        private: @: contract FxSignatures\make(b\inputTypes; a\resultType)
        private: @: state (copy(FxCompositionState))
        state\outer := outer
        state\inner := inner
        private: @: failures FxFailures\union(a\throws; b\throws)
        return: FxWrap\make(contract; FxCompositionEngine\run; state; failures)

FxPipe:
    private:
        @: first
        @: second
    return: @
    pipe:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxTypeToken
        return: FxCompose\compose(outer := second; inner := first)
```

Явная граница ядра: `FxKernel`, системные примитивы и стандартные вызовы, описанные в [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). Это требуемые адаптеры к штатным операциям графа/вызова, а не показанный здесь C-код готового ядра. Их реализация не спрятана в цифре «размер библиотеки»: статус и условия приёмки приведены отдельно. Полный [собранный файл](../../LMX_Fn_Receivers/LMX_Receivers.lmx) и [экспорт имён](../../LMX_Fn_Receivers/src/public.lmx) находятся рядом.

## Реализация Haskell

pipe2 и pipeIO2 показывают общую композицию a→b→c. Для прежних проверок полностью сохранены также pipe/pipeIO по списку однородных стадий; их типы стали полиморфными. IO-вариант задаёт порядок эффектов, чистый вариант не выдаётся за IO-действие.

[Точный исходник модуля](../libraries/haskell/IntPipe.hs):

```haskell
module IntPipe (pipe, pipeIO, pipe2, pipeIO2) where

pipe :: a -> [a -> a] -> a
pipe value [] = value
pipe value (stage : rest) =
  let next = stage value
  in next `seq` pipe next rest

pipeIO :: a -> [a -> IO a] -> IO a
pipeIO value [] = pure value
pipeIO value (stage : rest) = do
  next <- stage value
  next `seq` pipeIO next rest

pipe2 :: (a -> b) -> (b -> c) -> a -> c
pipe2 first second = second . first

pipeIO2 :: (a -> IO b) -> (b -> IO c) -> a -> IO c
pipeIO2 first second input = first input >>= second
```

## Процедурный механизм сценария на том же ядре

Этот обычный пользовательский код показывает явный механизм конкретного сценария. Его int-специализация не является ограничением общего core-ресивера. Он не заменяет весь общий контракт ядра и не является старой библиотечной версией. У клиента он считается, если включён в его выбранный исходник; в таблице ниже его стоимость показана отдельно.

```lmx
PipeLibrary:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    pipe:
        int: value \left
        int: i 0
        while: i < length(right)
            @: stage \right[i]
            value := stage(value)
            i += 1
        return: value
```

## Размеры и границы сравнения

| Показанный код | Непробельные символы | Непустые строки | UTF-8 байты |
| --- | ---: | ---: | ---: |
| LMX: алгоритм и перечисленные LMX-зависимости | 5456 | 294 | 8588 |
| Haskell: весь показанный модуль | 389 | 15 | 517 |
| LMX: процедурный механизм сценария, отдельный контракт | 145 | 11 | 252 |

Это механические размеры показанных исходников. LMX строит обычные графовые callable с точными сигнатурами; Haskell пользуется собственным типовым и функциональным runtime. Таблица не утверждает равенства стоимости их ядер, минимальности замыкания зависимостей или одинаковой реализации. Реализация ядра показана отдельно от клиента. Исключать её из конкурентного клиентского сравнения допустимо при сопоставимом встроенном/библиотечном/операторном механизме у контроля, либо как естественный механизм языка без скрытого предметного алгоритма. Архитектуры не обязаны совпадать; поля, состояние, копии, идентичности и эффекты обязаны сохраняться. Сравнение по клиентам и исходные сохранённые хеши — в [functional_receiver_counts.json](../validation/functional_receiver_counts.json).

**Проверка:** текст, ссылки и размеры воспроизводятся [скриптом](../tools/update_receiver_comparisons.py). LMX и GHC здесь не запускались; подготовленные assertions в [Analogies.hs](../haskell/Analogies.hs) не являются receipt исполнения.
