# JI01. Упорядоченные обходы, предикаты и свёртки

## Область реализации

Конечные последовательности, произвольные типы полезных значений, упорядоченные callbacks в одной Message. map/flatMap/scan/zip возвращают записи значений; filter сохраняет исходный профиль. Предикаты возвращают int LMX, Bool/Int Julia. Ошибка callback распространяется; callback не изменяет входную последовательность. Частичный результат не выдаётся. index различает отсутствие и индекс 0. record сохраняет принятое значение, а не копирует граф.

Это полная реализация объявленных операций в указанном профиле, а не весь Julia Base. Foreign comparison-модуль не импортируется клиентами. Зависимости Julia: нет дополнительных Julia comparison-модулей; тела находятся рядом. LMX-тела извлечены из текущего ядра; [общие определения](shared_dependencies.lmx) и [машинный реестр](../validation/implementation_dependencies.json) составляют их явное дополнение.

Публичные операции: `map`, `filter`, `foldl`, `scanl`, `zip`, `zipWith`, `flatMap`, `any`, `all`, `index`, `count`, `record`.

## LMX: действующие тела

```lmx
FxMap:
    private:
        @: items
        @: transform
    required: items transform
    return: @
    map:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(@[]; count)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            result[i] := FxApply\apply(transform; FxOne\make(item))
            i += 1
        return: result

FxFilter:
    private:
        @: items
        @: accepts
    required: items accepts
    return: @
    filter:
        throws: copy(FxThrows\traversal)
        private: @: info FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(info\arrayType; count)
        private: int: used 0
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: flagRecord FxApply\apply(accepts; FxOne\make(item))
            # Keep filter's established ordinary int-result admission channel.
            private: int: flag \flagRecord
            if: flag != 0
                FxKernel\arrayWrite(target := result; index := used; value := item)
                used += 1
            i += 1
        sys\resize(result; used)
        return: result

FxFold:
    private:
        @: items
        @: seed
        @: step
    required: items seed step
    return: @
    fold:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: accumulator seed
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            accumulator := FxApply\apply(step; FxTwo\make(accumulator; item))
            i += 1
        return: accumulator

FxScan:
    private:
        @: items
        @: seed
        @: step
    required: items seed step
    return: @
    scan:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(@[]; 0)
        private: @: info FxSeqInfo\get(result)
        private: int: total FxSeqSize\sum(count; 1; info\maxLength)
        sys\resize(result; total)
        private: @: accumulator seed
        result[0] := accumulator
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            accumulator := FxApply\apply(step; FxTwo\make(accumulator; item))
            result[i + 1] := accumulator
            i += 1
        return: result

FxPair:
    @: first 0
    @: second 0

FxZip:
    private:
        @: first
        @: second
    required: first second
    return: @
    zip:
        throws: copy(FxThrows\sequence)
        FxSeqInfo\get(first)
        FxSeqInfo\get(second)
        private: int: count length(first)
        if: length(second) < count
            count := length(second)
        private: @: result FxSeqAllocate\make(@[]; count)
        private: int: i 0
        while: i < count
            private: @: pair (copy(FxPair))
            pair\first := FxSeqRead\read(first; i)
            pair\second := FxSeqRead\read(second; i)
            result[i] := pair
            i += 1
        return: result

FxZipWith:
    private:
        @: first
        @: second
        @: combine
    required: first second combine
    return: @
    zipWith:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(first)
        FxSeqInfo\get(second)
        private: int: count length(first)
        if: length(second) < count
            count := length(second)
        private: @: result FxSeqAllocate\make(@[]; count)
        private: int: i 0
        while: i < count
            private: @: leftValue FxSeqRead\read(first; i)
            private: @: rightValue FxSeqRead\read(second; i)
            result[i] := FxApply\apply(combine; FxTwo\make(leftValue; rightValue))
            i += 1
        return: result

FxListBind:
    private:
        @: items
        @: next
    required: items next
    return: @
    flatMap:
        throws: copy(FxThrows\traversal)
        return: FxSeqFlatMap\flatMap(items; next)

FxSeqFlatMap:
    private:
        @: items
        @: next
    required: items next
    return: @
    flatMap:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: out FxSeqAllocate\make(@[]; 0)
        private: @: info FxSeqInfo\get(out)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: part FxApply\apply(next; FxOne\make(item))
            FxSeqInfo\get(part)
            private: int: before length(out)
            private: int: added length(part)
            private: int: after FxSeqSize\sum(before; added; info\maxLength)
            sys\resize(out; after)
            private: int: j 0
            while: j < added
                out[before + j] := FxSeqRead\read(part; j)
                j += 1
            i += 1
        return: out

FxSeqAny:
    private:
        @: items
        @: accepts
    required: items accepts
    return: int
    any:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: value FxApply\apply(accepts; FxOne\make(item))
            if: FxSeqPredicate\truth(value) != 0
                return: 1
            i += 1
        return: 0

FxSeqAll:
    private:
        @: items
        @: accepts
    required: items accepts
    return: int
    all:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: value FxApply\apply(accepts; FxOne\make(item))
            if: FxSeqPredicate\truth(value) = 0
                return: 0
            i += 1
        return: 1

FxSeqIndex:
    private:
        @: items
        @: accepts
    required: items accepts
    return: @
    index:
        throws: FxCallFailure FxKernelFailure FxPredicate FxRecordArity FxTypeToken ReceiverIndex
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: value FxApply\apply(accepts; FxOne\make(item))
            if: FxSeqPredicate\truth(value) != 0
                return: FxSome\some(value := (i FxRecordOperands\record))
            i += 1
        return: FxNone\none()

FxSeqCount:
    private:
        @: items
        @: accepts
    required: items accepts
    return: int
    count:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: matched 0
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: value FxApply\apply(accepts; FxOne\make(item))
            if: FxSeqPredicate\truth(value) != 0
                matched += 1
            i += 1
        return: matched

FxRecordOperands:
    copy: sys\OPERANDS_TEMPLATE
    required: left right
    return: @
    record:
        throws: FxRecordArity
        if: length(right) != 0
            throw: FxRecordArity()
        return: left

FxMaybe:
    int: present 0
    @: value 0

FxSome:
    private: @: value
    return: @
    some:
        private: @: result (copy(FxMaybe))
        result\present := 1
        result\value := value
        return: result

FxNone:
    return: @
    none:
        return: (copy(FxMaybe))
```

## Julia: самостоятельная семантическая реализация

```julia
module JuliaOrderedReference
export mapValues, filterValues, foldValues, scanValues, zipValues, zipWithValues,
       flatMapValues, anyValues, allValues, indexValue, countValues, recordValue

# Scoped reference algorithms, not copies of Base and not imported by clients.
# Finite one-based vectors; callbacks may throw, but must not mutate the inputs.
# A logical LMX int predicate corresponds here to Bool or machine Int.
function truth(value)
    (value isa Bool || value isa Int) || throw(ArgumentError("predicate result"))
    value != 0
end
function vectorInput(xs::AbstractVector)
    Base.require_one_based_indexing(xs)
    xs
end
function extraLength(old::Int, added::Int)
    added <= typemax(Int) - old || throw(OverflowError("sequence length"))
    old + added
end
recordValue(value) = value
function mapValues(f, xs::AbstractVector)
    vectorInput(xs)
    result = Vector{Any}(undef, length(xs))
    for i in eachindex(xs)
        result[i] = f(xs[i])
    end
    result
end
function filterValues(f, xs::AbstractVector)
    vectorInput(xs)
    result = Vector{eltype(xs)}(undef, length(xs))
    used = 0
    for i in eachindex(xs)
        value = xs[i]
        if truth(f(value))
            used += 1
            result[used] = value
        end
    end
    resize!(result, used)
end
# Julia String is a different storage profile; iterate characters and rebuild.
filterValues(f, text::AbstractString) = String(filterValues(f, collect(text)))
function foldValues(f, seed, xs::AbstractVector)
    vectorInput(xs)
    accumulator = seed
    for i in eachindex(xs)
        accumulator = f(accumulator, xs[i])
    end
    accumulator
end
function scanValues(f, seed, xs::AbstractVector)
    vectorInput(xs)
    result = Vector{Any}(undef, extraLength(length(xs), 1))
    result[1] = seed
    accumulator = seed
    for i in eachindex(xs)
        accumulator = f(accumulator, xs[i])
        result[i + 1] = accumulator
    end
    result
end
function zipValues(xs::AbstractVector, ys::AbstractVector)
    vectorInput(xs); vectorInput(ys)
    result = Vector{Any}(undef, min(length(xs), length(ys)))
    for i in eachindex(result)
        result[i] = (xs[i], ys[i])
    end
    result
end
function zipWithValues(f, xs::AbstractVector, ys::AbstractVector)
    vectorInput(xs); vectorInput(ys)
    result = Vector{Any}(undef, min(length(xs), length(ys)))
    for i in eachindex(result)
        result[i] = f(xs[i], ys[i])
    end
    result
end
function flatMapValues(f, xs::AbstractVector)
    vectorInput(xs)
    result = Any[]
    for i in eachindex(xs)
        part = f(xs[i])
        (part isa AbstractVector || part isa Tuple) ||
            throw(ArgumentError("callback must return a sequence"))
        part isa AbstractVector && vectorInput(part)
        before = length(result)
        resize!(result, extraLength(before, length(part)))
        for j in eachindex(part)
            result[before + j] = part[j]
        end
    end
    result
end
function anyValues(f, xs::AbstractVector)
    vectorInput(xs)
    for i in eachindex(xs)
        truth(f(xs[i])) && return true
    end
    false
end
function allValues(f, xs::AbstractVector)
    vectorInput(xs)
    for i in eachindex(xs)
        truth(f(xs[i])) || return false
    end
    true
end
function indexValue(f, xs::AbstractVector)
    vectorInput(xs)
    for i in eachindex(xs)
        truth(f(xs[i])) && return i - 1
    end
    nothing
end
function countValues(f, xs::AbstractVector)
    vectorInput(xs)
    found = 0
    for i in eachindex(xs)
        if truth(f(xs[i]))
            found += 1
        end
    end
    found
end
end
```

## Размеры компонентов

| Язык | Без пробельных | Без сложного Throws | Непустые строки | Все символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 5123 | 5021 | 263 | 7887 |
| Julia | 2758 | 2758 | 125 | 3610 |

Колонка «Без сложного Throws» исключает только аргументы после первого; copy(Throws) сохраняется целиком. Исходник не изменяется. Размер общих зависимостей приводится отдельно: складывать его для каждой строки повторно нельзя. Подготовлены empty/error/alias/callback cases в validation; runtime execution NOT_RUN.

## Исходники LMX

- `FxMap` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxFilter` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxFold` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxScan` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxPair` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxZip` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxZipWith` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxListBind` — [../../LMX_Fn_Receivers/src/containers.lmx](../../../LMX_Fn_Receivers/src/containers.lmx)
- `FxSeqFlatMap` — [../../LMX_Fn_Receivers/src/sequences_selection.lmx](../../../LMX_Fn_Receivers/src/sequences_selection.lmx)
- `FxSeqAny` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxSeqAll` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxSeqIndex` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxSeqCount` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxRecordOperands` — [../../LMX_Fn_Receivers/src/generic_functions.lmx](../../../LMX_Fn_Receivers/src/generic_functions.lmx)
- `FxMaybe` — [../../LMX_Fn_Receivers/src/containers.lmx](../../../LMX_Fn_Receivers/src/containers.lmx)
- `FxSome` — [../../LMX_Fn_Receivers/src/containers.lmx](../../../LMX_Fn_Receivers/src/containers.lmx)
- `FxNone` — [../../LMX_Fn_Receivers/src/containers.lmx](../../../LMX_Fn_Receivers/src/containers.lmx)

## Первичные источники семантики Julia

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
- [https://docs.julialang.org/en/v1/base/iterators/](https://docs.julialang.org/en/v1/base/iterators/)
- [https://docs.julialang.org/en/v1/base/arrays/](https://docs.julialang.org/en/v1/base/arrays/)
