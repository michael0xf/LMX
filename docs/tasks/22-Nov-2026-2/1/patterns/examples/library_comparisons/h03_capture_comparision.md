# Partial: общий префикс аргументов

Редакция: 22 ноября 2026 года. Клиент: [H03](../lmx/H03.lm3), [разбор](../../LMX_examples_and_analogies.ru.md#h03).

## Контракт общего ресивера

partial принимает callable с N входами и K готовыми значениями любого подходящего Array через @. Построенный callable имеет N−K остаточных позиций и точный исходный результат R; реальные defaults и required/private исходных деклараций сохраняются, а не заменяются обязательностью всех p0…. K=0 и K=N допустимы; полный префикс создаёт отложенный nullary-callable. Новая функция не исполняет цель при создании. Примитивы захватываются по значению, ссылки сохраняют идентичность цели.

Публичный ресивер `partial` уже входит в единое текущее ядро и используется прямо. Никаких import или выбираемых версий библиотек нет. Внутренние Fx/Rx-имена ниже обозначают структуры реализации ядра.

Этот документ показывает исходники общего ядрового механизма и локального процедурного приёма. Это разные области контракта, а не две взаимозаменяемые версии ядра: специализированный приём не подменяет весь общий API только потому, что он короче. Основной клиент выбирается отдельно из корректных вариантов по полной длине и границе учёта, см. H03.

## Полный алгоритм ресивера ядра LMX

Ниже приведено консервативное замыкание по корневым LMX-определениям от `FxPartial`: полные определения перечислены один раз, включая те, которые упомянуты в генерируемом тексте тела. Это видимый исходник текущего ядра; он не подменяется строкой импорта. Общие определения повторно используются другими receivers; одинаковые определения не считаются новой самостоятельной реализацией для каждого клиента.

- [adapter_frames.lmx](../../LMX_Fn_Receivers/src/adapter_frames.lmx)
- [generic_functions.lmx](../../LMX_Fn_Receivers/src/generic_functions.lmx)
- [generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx)
- [sequences.lmx](../../LMX_Fn_Receivers/src/sequences.lmx)
- [sequences_core.lmx](../../LMX_Fn_Receivers/src/sequences_core.lmx)

```lmx
FxIndices:
    private:
        int: start
        int: count
    return: @
    make:
        throws:
            FxIndex
        if: start < 0 || count < 0
            throw: FxIndex()
        private: @: out (copy(()))
        sys\resize(out; count)
        private: int: i 0
        while: i < count
            out[i] := start + i
            i += 1
        return: out

FxInputPolicy:
    @: source 0
    @: positions 0
    @: boundPositions 0
    @: boundValues 0
    @: pendingPositions 0
    int: sourcePolicy 0

FxOwnPolicy:
    private: @: contract
    return: @
    make:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: info FxKernel\signature(contract)
        private: @: out (copy(FxInputPolicy))
        out\source := contract
        out\positions := FxIndices\make(0; length(info\inputTypes))
        out\boundPositions := (copy(()))
        out\boundValues := (copy(()))
        out\pendingPositions := (copy(()))
        return: out

FxBuild:
    private:
        @: contract
        char[]: bodyText
        @: state
        @: failures
        @: policy 0
    return: @
    make:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: shape FxKernel\signature(subject := contract)
        private: @: bodyGraph sys\fromLmx(bodyText)
        private: @: selectedPolicy policy
        if: selectedPolicy = 0
            selectedPolicy := FxOwnPolicy\make(contract)
        return: FxKernel\callable(contract; shape\names; bodyGraph; state; failures; selectedPolicy)

FxCaptureFailures:
    return: @
    names:
        private: @: out (copy(()))
        sys\resize(out; 1)
        out[0] := "FxRecordArity"
        return: out

FxCaptureState:
    @: record 0

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

FxSeqInfo:
    private: @: source
    required: source
    return: @
    get:
        throws:
            FxKernelFailure
            FxTypeToken
        return: FxKernel\arrayInfo(source := source)

FxSeqAllocate:
    private:
        int: arrayType
        int: count
    required: arrayType count
    return: @
    make:
        throws:
            FxKernelFailure
            FxTypeToken
            SequenceSize
        if: count < 0
            throw: SequenceSize()
        private: @: out (arrayType: [])
        private: @: info FxSeqInfo\get(out)
        if: count > info\maxLength
            throw: SequenceSize()
        sys\resize(out; count)
        return: out

FxSeqRead:
    private:
        @: source
        int: index
    required: source index
    return: @
    read:
        throws:
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
        return: FxKernel\arrayRead(source := source; index := index)

FxSeqSize:
    private:
        int: base
        int: extra
        int: limit
    required: base extra limit
    return: int
    sum:
        throws:
            SequenceSize
        if: base < 0 || extra < 0 || base > limit
            throw: SequenceSize()
        if: extra > limit - base
            throw: SequenceSize()
        return: base + extra

FxSeqConcat:
    private: @: parts
    required: parts
    return: @
    concat:
        throws:
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        FxSeqInfo\get(parts)
        private: int: count length(parts)
        private: int: arrayType @[]
        private: int: elementType 0
        private: int: allDense 1
        private: int: i 0
        # Inspect all parts, including empty dense parts. Comparison uses
        # canonical full element codes from the common type resolver.
        while: i < count
            private: @: part FxSeqRead\read(parts; i)
            private: @: info FxSeqInfo\get(part)
            if: i = 0
                arrayType := info\arrayType
                elementType := info\elementType
            if: info\dense = 0 || info\elementType != elementType
                allDense := 0
            i += 1
        if: count = 0 || allDense = 0
            arrayType := @[]
        private: @: out FxSeqAllocate\make(arrayType; 0)
        private: @: outInfo FxSeqInfo\get(out)
        private: int: total 0
        i := 0
        while: i < count
            private: @: part FxSeqRead\read(parts; i)
            total := FxSeqSize\sum(total; length(part); outInfo\maxLength)
            i += 1
        sys\resize(out; total)
        private: int: at 0
        i := 0
        while: i < count
            private: @: part FxSeqRead\read(parts; i)
            private: int: partSize length(part)
            private: int: j 0
            while: j < partSize
                private: @: value FxSeqRead\read(part; j)
                FxKernel\arrayWrite(target := out; index := at; value := value)
                at += 1
                j += 1
            i += 1
        return: out

FxConcat:
    private:
        char[]: first
        char[]: second
    return: char[]
    concat:
        throws:
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        private: @: out FxSeqConcat\concat(parts := (first; second))
        return: \out

FxDecimal:
    private: int: number
    return: char[]
    decimal:
        throws:
            FxIndex
        if: number < 0
            throw: FxIndex()
        private: char[]: digits "0123456789"
        private: char[]: reversed []
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
        private: char[]: out []
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
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
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
            ReceiverIndex
            SequenceSize
        private: @: labels FxLabels\labels(length(inputs))
        private: @: data FxKernel\signatureData(inputs := inputs; result := result; labels := labels)
        Built :: data
        return: Built

FxTypeTokens:
    reference:
        @: value

FxCaptureOne:
    private:
        @: requirement
        @: sourceRecord
    return: @
    capture:
        throws:
            FxIndex
            FxKernelFailure
            FxRecordArity
            FxTypeToken
            ReceiverIndex
            SequenceSize
        private: @: inputTypes (copy(()))
        sys\resize(inputTypes; 1)
        inputTypes[0] := requirement
        private: @: referenceType FxKernel\normalizeType(token := FxTypeTokens\reference[0])
        private: @: contract FxSignatures\make(inputTypes; referenceType)
        private: @: state (copy(FxCaptureState))
        state\record := FxRecordOperands\record
        private: @: failures FxCaptureFailures\names()
        # FxRecordArity невозможно при написанном пустом RHS, но имя включается
        # в явный контракт тела как объявленный исход используемого операнда.
        private: @: receiver FxBuild\make(contract; "return: (p0 node\\private\\state\\record)\n"; state; failures)
        return: receiver(p0 := \sourceRecord)

FxCapturePrefix:
    private:
        @: inputTypes
        @: prefix
    return: @
    capture:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxRecordArity
            FxTypeToken
            ReceiverIndex
            SequenceSize
        if: length(prefix) > length(inputTypes)
            throw: FxArity()
        private: @: captured (copy(()))
        sys\resize(captured; length(prefix))
        private: int: i 0
        while: i < length(prefix)
            captured[i] := FxCaptureOne\capture(inputTypes[i]; FxSeqRead\read(prefix; i))
            i += 1
        return: captured

FxFrameAttempt:
    private: @: frame
    return: @
    attempt:
        throws:
            FxKernelFailure
            FxTypeToken
        return: FxKernel\enter(frame; frame\failures)

FxFrameApply:
    private: @: frame
    return: @
    apply:
        throws:
            FxCallFailure
            FxKernelFailure
            FxTypeToken
        private: @: outcome FxFrameAttempt\attempt(frame)
        if: outcome\ok = 0
            throw: FxCallFailure(outcome)
        return: outcome\value

FxForwardEngine:
    private:
        @: state
        @: frame
    return: @
    run:
        throws:
            FxCallFailure
            FxKernelFailure
            FxTypeToken
        return: FxFrameApply\apply(frame)

FxSeqBounds:
    private:
        @: source
        int: begin
        int: end
    required: source begin end
    return: int
    count:
        throws:
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
        FxSeqInfo\get(source)
        if: begin < 0 || end < begin || end > length(source)
            throw: ReceiverIndex()
        return: end - begin

FxSeqSlice:
    private:
        @: source
        int: begin
        int: end
    required: source begin end
    return: @
    slice:
        throws:
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        private: int: count FxSeqBounds\count(source; begin; end)
        private: @: info FxSeqInfo\get(source)
        private: @: out FxSeqAllocate\make(info\arrayType; count)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(source; begin + i)
            FxKernel\arrayWrite(target := out; index := i; value := value)
            i += 1
        return: out

FxSlice:
    private:
        @[]: values
        int: start
        int: count
    return: @
    slice:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        if: start < 0 || count < 0 || start > length(values)
            throw: FxIndex()
        if: count > length(values) - start
            throw: FxIndex()
        return: FxSeqSlice\slice(source := values; begin := start; end := start + count)

FxSourcePolicy:
    private:
        @: operation
        @: positions
        @: boundPositions
        @: boundValues
        @: pendingPositions
    return: @
    make:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        private: @: info FxKernel\signature(operation)
        private: int: n length(info\inputTypes)
        if: length(boundPositions) != length(boundValues)
            throw: FxArity()
        private: @: covered (copy(()))
        sys\resize(covered; n)
        private: int: i 0
        while: i < n
            covered[i] := 0
            i += 1
        private: @: groups (positions; boundPositions; pendingPositions)
        private: int: group 0
        while: group < length(groups)
            private: @: values groups[group]
            private: int: j 0
            while: j < length(values)
                private: int: at \values[j]
                if: at < 0 || at >= n
                    throw: FxIndex()
                if: \covered[at] != 0
                    throw: FxArity()
                covered[at] := 1
                j += 1
            ---
            group += 1
        i := 0
        while: i < n
            if: \covered[i] = 0
                throw: FxArity()
            i += 1
        private: @: out (copy(FxInputPolicy))
        out\source := operation
        out\positions := FxSlice\slice(positions; 0; length(positions))
        out\boundPositions := FxSlice\slice(boundPositions; 0; length(boundPositions))
        out\boundValues := FxSlice\slice(boundValues; 0; length(boundValues))
        out\pendingPositions := FxSlice\slice(pendingPositions; 0; length(pendingPositions))
        out\sourcePolicy := 1
        return: out

FxPrefixPolicy:
    private:
        @: operation
        @: captured
    return: @
    make:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        private: @: info FxKernel\signature(operation)
        private: int: n length(info\inputTypes)
        private: int: k length(captured)
        if: k > n
            throw: FxArity()
        return: FxSourcePolicy\make(operation; FxIndices\make(k; n - k); FxIndices\make(0; k); captured; (copy(())))

FxEngineState:
    @: engine 0
    @: payload 0

FxSameText:
    private:
        char[]: first
        char[]: second
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
        char[]: excluded
    return: @
    without:
        private: @: out (copy(()))
        sys\resize(out; length(names))
        private: int: used 0
        private: int: i 0
        while: i < length(names)
            private: char[]: name \names[i]
            if: FxSameText\same(name; excluded) = 0
                out[used] := names[i]
                used += 1
            i += 1
        sys\resize(out; used)
        return: out

FxAppend:
    private:
        @: first
        @: second
    return: @
    append:
        throws:
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        private: @: empty (copy(()))
        return: FxSeqConcat\concat(parts := (empty; first; second))

FxFailures:
    private:
        @: first
        @: second
    return: @
    union:
        throws:
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        # Builder интернирует и устраняет повторные имена. Список не фиксирован.
        return: FxAppend\append(first; second)

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
        @: policy 0
    return: @
    make:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
            ReceiverIndex
            SequenceSize
        private: @: info FxKernel\signature(subject := contract)
        private: @: state (copy(FxEngineState))
        state\engine := engine
        state\payload := payload
        private: char[]: text "private: @: fx_frame FxKernel\\currentCall(node)\nprivate: @: fx_engine node\\private\\state\\engine\nprivate: @: fx_answer fx_engine(state := node\\private\\state\\payload; frame := fx_frame)\n"
        if: info\hasResult != 0
            text := FxConcat\concat(text; "return: \\fx_answer\n")
        else:
            text := FxConcat\concat(text; "return\n")
        text := FxConcat\concat(text; "catch: FxCallFailure (@: outcome)\n    FxKernel\\raise(name := outcome\\failure; payload := outcome\\payload)\n")
        private: @: engineInfo FxKernel\signature(subject := engine)
        private: @: escapingEngine FxFailureFilter\without(engineInfo\throws; "FxCallFailure")
        private: @: allFailures FxFailures\union(failures; FxStageFailures\names())
        allFailures := FxFailures\union(allFailures; escapingEngine)
        return: FxBuild\make(contract; text; state; allFailures; policy)

FxPartial:
    private:
        @: operation
        @: prefix
    return: @
    partial:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxRecordArity
            FxTypeToken
            ReceiverIndex
            SequenceSize
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

Явная граница ядра: `FxKernel`, системные примитивы и стандартные вызовы, описанные в [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). Это требуемые адаптеры к штатным операциям графа/вызова, а не показанный здесь C-код готового ядра. Их реализация не спрятана в цифре «размер библиотеки»: статус и условия приёмки приведены отдельно. Полный [собранный файл](../../LMX_Fn_Receivers/LMX_Receivers.lmx) и [экспорт имён](../../LMX_Fn_Receivers/src/public.lmx) находятся рядом.

## Реализация Haskell

В Haskell partial связывает первый вход уже каррированной функции. Полиморфные a/b/r не фиксируют Int; r само может быть функцией. Для нескольких исходных аргументов Haskell повторяет обычную аппликацию, тогда как LMX принимает явный вектор префикса. Числа 5 и 100 принадлежат клиенту.

[Точный исходник модуля](../libraries/haskell/Partial.hs):

```haskell
module Partial (partial) where

partial :: (a -> b -> r) -> a -> (b -> r)
partial binary first = \second -> binary first second
```

## Процедурный механизм сценария на том же ядре

Этот обычный пользовательский код показывает явный механизм конкретного сценария. Его int-специализация не является ограничением общего core-ресивера. Он не заменяет весь общий контракт ядра и не является старой библиотечной версией. У клиента он считается, если включён в его выбранный исходник; в таблице ниже его стоимость показана отдельно.

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

## Размеры и границы сравнения

| Показанный код | Непробельные символы | Непустые строки | UTF-8 байты |
| --- | ---: | ---: | ---: |
| LMX: алгоритм и перечисленные LMX-зависимости | 10958 | 596 | 17588 |
| Haskell: весь показанный модуль | 101 | 3 | 128 |
| LMX: процедурный механизм сценария, отдельный контракт | 275 | 18 | 418 |

Это механические размеры показанных исходников. LMX строит обычные графовые callable с точными сигнатурами; Haskell пользуется собственным типовым и функциональным runtime. Таблица не утверждает равенства стоимости их ядер, минимальности замыкания зависимостей или одинаковой реализации. Реализация ядра показана отдельно от клиента. Исключать её из конкурентного клиентского сравнения допустимо при сопоставимом встроенном/библиотечном/операторном механизме у контроля, либо как естественный механизм языка без скрытого предметного алгоритма. Архитектуры не обязаны совпадать; поля, состояние, копии, идентичности и эффекты обязаны сохраняться. Сравнение по клиентам и исходные сохранённые хеши — в [functional_receiver_counts.json](../validation/functional_receiver_counts.json).

**Проверка:** текст, ссылки и размеры воспроизводятся [скриптом](../tools/update_receiver_comparisons.py). LMX и GHC здесь не запускались; подготовленные assertions в [Analogies.hs](../haskell/Analogies.hs) не являются receipt исполнения.
