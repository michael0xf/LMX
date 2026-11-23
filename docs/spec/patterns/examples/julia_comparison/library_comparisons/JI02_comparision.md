# JI02. Границы, маски и устройство массивов

## Область реализации

Полные конечные одномерные массивы и прямоугольные массивы строк. Диапазоны и срезы полуоткрыты и используют нулевые позиции. Предусмотрены пустые входы, отрицательный шаг, отказ на нулевом шаге, проверка размеров и несовместимой формы. Копируются внешние позиции, ссылочные цели сохраняются. concat не делает рекурсивного flatten. Julia reference принимает обычные one-based AbstractVector, а не все возможные AbstractArray/OffsetArray.

Единое LMX-тело используется обеими клиентскими формами. Julia comparison-модуль клиенты не импортируют. Зависимости Julia: нет дополнительных Julia comparison-модулей.

[Общие определения](shared_dependencies.lmx) и [машинный реестр](../validation/implementation_dependencies.json) дополняют эти тела.

## LMX: действующие тела

```lmx
FxSeqRange:
    private:
        int: start
        int: stop
        int: step 1
    required: start stop
    return: @
    range:
        throws: FxKernelFailure FxTypeToken SequenceSize SequenceStep
        if: step = 0
            throw: SequenceStep()
        private: @: out FxSeqAllocate\make(int[]; 0)
        if: step > 0 && start >= stop
            return: out
        if: step < 0 && start <= stop
            return: out
        # Use the existing exact-integer numeric profile only for preflight.
        # This handles MIN_INT/-1 and ranges spanning both signs without a
        # wrapped subtraction, fixed word width, or an overflowing abs(step).
        private: bigint: first start
        private: bigint: last stop
        private: bigint: stride step
        private: bigint: distance last - first
        if: stride < 0
            distance := first - last
            stride := -stride
        private: bigint: wideCount (distance - 1) / stride + 1
        private: @: info FxSeqInfo\get(out)
        if: wideCount > info\maxLength
            throw: SequenceSize()
        private: int: count wideCount
        sys\resize(out; count)
        private: int: current start
        private: int: i 0
        while: i < count
            out[i] := current
            i += 1
            # Do not compute the nonexistent value after the final element.
            if: i < count
                current += step
        ---
        return: out

FxSeqSlice:
    private:
        @: source
        int: begin
        int: end
    required: source begin end
    return: @
    slice:
        throws: copy(FxThrows\sequence)
        private: int: count FxSeqBounds\count(source; begin; end)
        private: @: info FxSeqInfo\get(source)
        private: @: out FxSeqAllocate\make(info\arrayType; count)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(source; begin + i)
            FxKernel\arrayWrite(target := out; index := i; value := value)
            i += 1
        return: out

FxSeqReverse:
    private: @: source
    required: source
    return: @
    reverse:
        throws: copy(FxThrows\sequence)
        private: @: info FxSeqInfo\get(source)
        private: int: count length(source)
        private: @: out FxSeqAllocate\make(info\arrayType; count)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(source; count - 1 - i)
            FxKernel\arrayWrite(target := out; index := i; value := value)
            i += 1
        return: out

FxSeqCompress:
    private:
        @: source
        @: mask
    required: source mask
    return: @
    compress:
        throws: FxKernelFailure FxShape FxTypeToken ReceiverIndex SequenceElement SequenceSize
        private: @: info FxSeqInfo\get(source)
        FxSeqInfo\get(mask)
        private: int: count length(source)
        if: length(mask) != count
            throw: FxShape()
        private: @: flags FxSeqAllocate\make(int[]; count)
        private: int: accepted 0
        private: int: i 0
        # Validate every mask value before constructing the selected result.
        while: i < count
            private: @: value FxSeqRead\read(mask; i)
            private: int: flag FxSeqInteger\read(value)
            flags[i] := flag
            if: flag != 0
                accepted += 1
            i += 1
        private: @: out FxSeqAllocate\make(info\arrayType; accepted)
        private: int: written 0
        i := 0
        while: i < count
            if: flags[i] != 0
                private: @: value FxSeqRead\read(source; i)
                FxKernel\arrayWrite(target := out; index := written; value := value)
                written += 1
            i += 1
        return: out

FxSeqConcat:
    private: @: parts
    required: parts
    return: @
    concat:
        throws: copy(FxThrows\sequence)
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

FxTranspose:
    private: @: rows
    required: rows
    return: @
    transpose:
        throws: FxKernelFailure FxShape FxTypeToken ReceiverIndex SequenceSize
        FxSeqInfo\get(rows)
        private: int: height length(rows)
        private: @: result FxSeqAllocate\make(@[]; 0)
        if: height = 0
            return: result
        private: @: first FxSeqRead\read(rows; 0)
        FxSeqInfo\get(first)
        private: int: width length(first)
        private: int: i 0
        while: i < height
            private: @: row FxSeqRead\read(rows; i)
            FxSeqInfo\get(row)
            if: length(row) != width
                throw: FxShape()
            i += 1
        private: @: resultInfo FxSeqInfo\get(result)
        FxSeqSize\sum(0; width; resultInfo\maxLength)
        sys\resize(result; width)
        private: int: j 0
        while: j < width
            private: @: column FxSeqAllocate\make(@[]; height)
            i := 0
            while: i < height
                private: @: row FxSeqRead\read(rows; i)
                column[i] := FxSeqRead\read(row; j)
                i += 1
            result[j] := column
            j += 1
        return: result
```

## Julia: самостоятельная реализация

```julia
module JuliaArrayReference
export rangeValues, sliceValues, reverseValues, compressValues, concatValues,
       transposeRows

# One-based finite vectors; user-visible slice positions are zero based.
function vectorInput(xs::AbstractVector)
    Base.require_one_based_indexing(xs)
    xs
end
function bounds(xs::AbstractVector, lo::Int, hi::Int)
    vectorInput(xs)
    0 <= lo <= hi <= length(xs) || throw(BoundsError(xs, lo:hi))
    hi - lo
end
function checkedLength(old::Int, added::Int)
    added <= typemax(Int) - old || throw(OverflowError("sequence length"))
    old + added
end
function rangeValues(start::Int, stop::Int, step::Int=1)
    step != 0 || throw(ArgumentError("zero step"))
    (step > 0 ? start >= stop : start <= stop) && return Int[]
    distance = step > 0 ? big(stop) - big(start) : big(start) - big(stop)
    wideCount = div(distance - 1, abs(big(step))) + 1
    wideCount <= typemax(Int) || throw(OverflowError("sequence length"))
    result = Vector{Int}(undef, Int(wideCount))
    current = start
    for i in eachindex(result)
        result[i] = current
        i < length(result) && (current += step)
    end
    result
end
function sliceValues(xs::AbstractVector, lo::Int, hi::Int)
    count = bounds(xs, lo, hi)
    result = Vector{eltype(xs)}(undef, count)
    for i in eachindex(result)
        result[i] = xs[lo + i]
    end
    result
end
function reverseValues(xs::AbstractVector)
    vectorInput(xs)
    result = Vector{eltype(xs)}(undef, length(xs))
    for i in eachindex(result)
        result[i] = xs[length(xs) - (i - 1)]
    end
    result
end
function compressValues(xs::AbstractVector, mask::AbstractVector)
    vectorInput(xs); vectorInput(mask)
    length(xs) == length(mask) || throw(DimensionMismatch("mask"))
    flags = Vector{Int}(undef, length(mask))
    accepted = 0
    for i in eachindex(mask)
        value = mask[i]
        value isa Int || throw(ArgumentError("mask element"))
        flags[i] = value
        value != 0 && (accepted += 1)
    end
    result = Vector{eltype(xs)}(undef, accepted)
    written = 0
    for i in eachindex(xs)
        if flags[i] != 0
            written += 1
            result[written] = xs[i]
        end
    end
    result
end
function concatValues(parts::AbstractVector)
    vectorInput(parts)
    elementType = Any
    sameType = !isempty(parts)
    for i in eachindex(parts)
        part = vectorInput(parts[i])
        if i == 1
            elementType = eltype(part)
        elseif eltype(part) !== elementType
            sameType = false
        end
    end
    sameType || (elementType = Any)
    total = 0
    for part in parts
        total = checkedLength(total, length(part))
    end
    result = Vector{elementType}(undef, total)
    at = 0
    for part in parts
        for value in part
            at += 1
            result[at] = value
        end
    end
    result
end
function transposeRows(rows::AbstractVector)
    vectorInput(rows)
    isempty(rows) && return Any[]
    width = length(vectorInput(rows[1]))
    for row in rows
        vectorInput(row)
        length(row) == width || throw(DimensionMismatch("ragged rows"))
    end
    result = Vector{Any}(undef, width)
    for column in 1:width
        values = Vector{Any}(undef, length(rows))
        for row in eachindex(rows)
            values[row] = rows[row][column]
        end
        result[column] = values
    end
    result
end
end
```

## Полный размер компонентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX | 4233 | 6661 | 191 |
| Julia | 2529 | 3417 | 114 |

Общие зависимости считаются один раз; отдельные style-копии библиотечных тел не создаются. Runtime execution: NOT_RUN.

## Исходники LMX

- `FxSeqRange` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxSeqSlice` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxSeqReverse` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxSeqCompress` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxSeqConcat` — [../../LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx)
- `FxTranspose` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
- <https://docs.julialang.org/en/v1/base/collections/>
