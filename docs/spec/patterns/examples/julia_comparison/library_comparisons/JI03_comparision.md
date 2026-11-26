# JI03. Изменение диапазона с сохранением target

## Область реализации

Один общий алгоритм replaceRange, splice возвращает удалённые элементы, append возвращает исходный target. Обе reference-реализации полностью подготавливают вставку до первой записи, в том числе при перекрытии. Обычное принятие типа и исчерпание ресурсов остаются правилами respective runtime; обещания общей транзакции нет. Сравнение клиентов J17/J18 ограничено совместимыми неперекрывающимися входами, поскольку Base.splice! предупреждает о разделяемой памяти.

Единое LMX-тело используется обеими клиентскими формами. Julia comparison-модуль клиенты не импортируют. Зависимости Julia: JI02.

[Общие определения](shared_dependencies.lmx) и [машинный реестр](../validation/implementation_dependencies.json) дополняют эти тела.

## LMX: действующие тела

```lmx
FxSeqReplaceRange:
    private:
        @: target
        int: begin
        int: end
        @: values
    required: target begin end values
    return: @
    replaceRange:
        throws: copy(FxThrows\mutation)
        private: @: info FxSeqInfo\get(target)
        FxSeqInfo\get(values)
        private: int: removed FxSeqBounds\count(target; begin; end)
        private: int: oldSize length(target)
        private: int: added length(values)
        private: int: retained oldSize - removed
        private: int: newSize FxSeqSize\sum(retained; added; info\maxLength)
        private: @: stage FxSeqAllocate\make(info\arrayType; added)
        private: int: i 0
        # This conservative overlap-safe path buffers only the inserted range.
        # Dense preparation keeps dense T storage; @[] keeps direct references.
        # No hidden user converter or initializer is called by arrayAdmit.
        # Full ordinary admission belongs here, never in the commit loop.
        while: i < added
            private: @: sourceValue FxSeqRead\read(values; i)
            private: @: ready FxSeqAdmit\admit(target; sourceValue)
            FxKernel\arrayWrite(target := stage; index := i; value := ready)
            i += 1
        # Capacity can change while descriptor identity is retained. Resource
        # failure is ordinary; no general transactional promise is introduced.
        sys\reserve(target; newSize)
        if: newSize > oldSize
            private: int: shift newSize - oldSize
            sys\resize(target; newSize)
            i := oldSize
            # Move the tail backwards before inserting, like a typed memmove.
            while: i > end
                i -= 1
                private: @: value FxSeqRead\read(target; i)
                FxKernel\arrayWrite(target := target; index := i + shift; value := value)
        ---
        else:
            private: int: destination begin + added
            i := end
            # For shrink/equal length the forward order does not overwrite a
            # source tail element that has not yet been read.
            while: i < oldSize
                private: @: value FxSeqRead\read(target; i)
                FxKernel\arrayWrite(target := target; index := destination; value := value)
                destination += 1
                i += 1
            sys\resize(target; newSize)
        i := 0
        while: i < added
            private: @: value FxSeqRead\read(stage; i)
            FxKernel\arrayWrite(target := target; index := begin + i; value := value)
            i += 1
        return: target

FxSeqSplice:
    private:
        @: target
        int: begin
        int: end
        @: values
    required: target begin end values
    return: @
    splice:
        throws: copy(FxThrows\mutation)
        # Snapshot the removed range before reserve, resize, or any target
        # write. Slice preserves the complete physical element profile and
        # copies outer slots only: referenced targets remain shared.
        private: @: removed FxSeqSlice\slice(target; begin; end)
        # The common replacement path prepares all inserted values before
        # commit, including values = target and other overlapping sources.
        # Failure during preparation leaves target's contents unchanged.
        FxSeqReplaceRange\replaceRange(target; begin; end; values)
        return: removed

FxSeqAppend:
    private:
        @: target
        @: values
    required: target values
    return: @
    append:
        throws: copy(FxThrows\mutation)
        FxSeqInfo\get(target)
        private: int: end length(target)
        return: FxSeqReplaceRange\replaceRange(target; end; end; values)
```

## Julia: самостоятельная реализация

```julia
module JuliaMutationReference
using ..JuliaArrayReference: bounds, sliceValues, vectorInput, checkedLength
export replaceRange!, spliceValues!, appendValues!

# Full scoped mutation algorithm. It also handles overlapping source values.
# Ordinary element admission happens in stage before the first target write.
# Allocation/runtime failures are propagated, not presented as a transaction.
function replaceRange!(target::Vector{T}, lo::Int, hi::Int,
                       values::AbstractVector) where T
    removed = bounds(target, lo, hi)
    vectorInput(values)
    oldSize = length(target)
    added = length(values)
    newSize = checkedLength(oldSize - removed, added)
    stage = Vector{T}(undef, added)
    for i in eachindex(values)
        stage[i] = values[i]
    end
    sizehint!(target, newSize)
    if newSize > oldSize
        shift = newSize - oldSize
        resize!(target, newSize)
        i = oldSize
        while i > hi
            target[i + shift] = target[i]
            i -= 1
        end
    else
        destination = lo + added + 1
        for i in hi + 1:oldSize
            target[destination] = target[i]
            destination += 1
        end
        resize!(target, newSize)
    end
    for i in eachindex(stage)
        target[lo + i] = stage[i]
    end
    target
end
function spliceValues!(target::Vector, lo::Int, hi::Int,
                       values::AbstractVector)
    removed = sliceValues(target, lo, hi)
    replaceRange!(target, lo, hi, values)
    removed
end
function appendValues!(target::Vector, values::AbstractVector)
    position = length(target)
    replaceRange!(target, position, position, values)
end
end
```

## Полный размер компонентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX | 2522 | 3684 | 88 |
| Julia | <span style="color:#176233"><u>1230</u></span> | 1668 | 50 |

Общие зависимости считаются один раз; отдельные style-копии библиотечных тел не создаются. Runtime execution: NOT_RUN.

## Исходники LMX

- `FxSeqReplaceRange` — [../../LMX_Fn_Receivers/src/sequences_mutation.lmx](../../../LMX_Fn_Receivers/src/sequences_mutation.lmx)
- `FxSeqSplice` — [../../LMX_Fn_Receivers/src/sequences_mutation.lmx](../../../LMX_Fn_Receivers/src/sequences_mutation.lmx)
- `FxSeqAppend` — [../../LMX_Fn_Receivers/src/sequences_mutation.lmx](../../../LMX_Fn_Receivers/src/sequences_mutation.lmx)

## Первичные источники

- <https://docs.julialang.org/en/v1/base/collections/>
