# JI04. Сортировка, уникальность и группировка

## Область реализации

Общие типы элементов и ключей. Устойчивая bottom-up merge sort с целочисленным трёхсторонним comparator; unique оставляет первое появление по явному равенству; groupBy вызывает keyOf один раз на элемент и сохраняет порядок внутри групп. Пустые входы и неверные ответы comparator/predicate обработаны. Источник и ключи callbacks не меняют. Generic unique/groupBy используют поиск без hash; их асимптотика не приравнивается к оптимизированным Base.unique/SplitApplyCombine.group.

Это полная реализация объявленных операций в указанном профиле, а не весь Julia Base. Foreign comparison-модуль не импортируется клиентами. Зависимости Julia: JI01; тела находятся рядом. LMX-тела извлечены из текущего ядра; [общие определения](shared_dependencies.lmx) и [машинный реестр](../validation/implementation_dependencies.json) составляют их явное дополнение.

Публичные операции: `sort`, `unique`, `groupBy`.

## LMX: действующие тела

```lmx
FxSort:
    private:
        @: items
        @: compare
    required: items compare
    return: @
    sort:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        private: @: info FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: current FxSeqSlice\slice(items; 0; count)
        if: count < 2
            return: current
        private: @: scratch FxSeqAllocate\make(info\arrayType; count)
        private: int: width 1
        while: width < count
            private: int: start 0
            while: start < count
                private: int: middle count
                if: width < count - start
                    middle := start + width
                private: int: end count
                if: width < count - middle
                    end := middle + width
                private: int: left start
                private: int: right middle
                private: int: at start
                while: at < end
                    private: int: takeLeft 0
                    if: right = end
                        takeLeft := 1
                    else:
                        if: left < middle
                            private: @: a FxSeqRead\read(current; left)
                            private: @: b FxSeqRead\read(current; right)
                            private: @: answer FxApply\apply(compare; FxTwo\make(a; b))
                            private: int: order FxSeqInteger\read(answer)
                            takeLeft := order <= 0
                    ---
                    private: @: selected 0
                    if: takeLeft != 0
                        selected := FxSeqRead\read(current; left)
                        left += 1
                    else:
                        selected := FxSeqRead\read(current; right)
                        right += 1
                    ---
                    FxSeqStore\write(scratch; at; selected)
                    at += 1
                start := end
            private: @: previous current
            current := scratch
            scratch := previous
            # Guard before doubling: count bounds the array length and bytes.
            if: width > count - width
                width := count
            else:
                width += width
        ---
        return: current

FxUnique:
    private:
        @: items
        @: same
    required: items same
    return: @
    unique:
        throws:
            FxCallFailure
            FxKernelFailure
            FxPredicate
            FxTypeToken
            ReceiverIndex
            SequenceElement
            SequenceSize
        private: @: info FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(info\arrayType; count)
        private: int: used 0
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: int: duplicate 0
            private: int: j 0
            while: j < used
                private: @: previous FxSeqRead\read(result; j)
                private: @: answer FxApply\apply(same; FxTwo\make(previous; item))
                if: FxSeqPredicate\truth(answer) != 0
                    duplicate := 1
                    break
                j += 1
            if: duplicate = 0
                FxSeqStore\write(result; used; item)
                used += 1
            i += 1
        sys\resize(result; used)
        return: result

FxGroup:
    @: key 0
    @: items 0

FxGroupBy:
    private:
        @: items
        @: keyOf
        @: sameKey
    required: items keyOf sameKey
    return: @
    groupBy:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(@[]; 0)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: key FxApply\apply(keyOf; FxOne\make(item))
            private: @: group 0
            private: int: j 0
            while: j < length(result)
                private: FxGroup@: candidate result[j]
                private: @: flagRecord FxApply\apply(sameKey; FxTwo\make(candidate\key; key))
                private: int: flag \flagRecord
                if: flag != 0
                    group := candidate
                    break
                j += 1
            if: group = 0
                group := (copy(FxGroup))
                group\key := key
                group\items := FxSeqAllocate\make(@[]; 0)
                FxSeqPush\append(result; group)
            FxSeqPush\append(group\items; item)
            i += 1
        return: result
```

## Julia: самостоятельная семантическая реализация

```julia
module JuliaOrderGroupReference
using ..JuliaOrderedReference: truth, vectorInput
export sortValues, uniqueValues, groupValues

# Explicit callbacks support arbitrary values; no hash/string conversion.
# Ordering and equality keys must not mutate while the operation is running.
function orderValue(answer)
    answer isa Int || throw(ArgumentError("comparator result"))
    answer
end
function sortValues(compare, items::AbstractVector)
    vectorInput(items)
    count = length(items)
    current = Vector{eltype(items)}(undef, count)
    for i in eachindex(items)
        current[i] = items[i]
    end
    count < 2 && return current
    scratch = similar(current)
    width = 1
    while width < count
        start = 0
        while start < count
            middle = width < count - start ? start + width : count
            stop = width < count - middle ? middle + width : count
            left, right = start, middle
            for at in start + 1:stop
                takeLeft = right == stop
                if !takeLeft && left < middle
                    takeLeft = orderValue(compare(current[left + 1],
                                                  current[right + 1])) <= 0
                end
                if takeLeft
                    left += 1
                    scratch[at] = current[left]
                else
                    right += 1
                    scratch[at] = current[right]
                end
            end
            start = stop
        end
        current, scratch = scratch, current
        width = width > count - width ? count : width + width
    end
    current
end
function uniqueValues(same, items::AbstractVector)
    vectorInput(items)
    result = Vector{eltype(items)}(undef, length(items))
    used = 0
    for item in items
        duplicate = false
        for j in 1:used
            if truth(same(result[j], item))
                duplicate = true
                break
            end
        end
        if !duplicate
            used += 1
            result[used] = item
        end
    end
    resize!(result, used)
end
function groupValues(keyOf, sameKey, items::AbstractVector)
    vectorInput(items)
    groups = Any[]
    for item in items
        key = keyOf(item)
        found = 0
        for j in eachindex(groups)
            if truth(sameKey(groups[j].key, key))
                found = j
                break
            end
        end
        if found == 0
            push!(groups, (key=key, items=Any[]))
            found = length(groups)
        end
        push!(groups[found].items, item)
    end
    groups
end
end
```

## Размеры компонентов

| Язык | Без пробельных | Непустые строки | Все символы |
| --- | ---: | ---: | ---: |
| LMX | 2676 | 134 | 4815 |
| Julia | 1614 | 86 | 2610 |

Размер общих зависимостей приводится отдельно: складывать его для каждой строки повторно нельзя. Подготовлены empty/error/alias/callback cases в validation; runtime execution NOT_RUN.

## Исходники LMX

- `FxSort` — [../../LMX_Fn_Receivers/src/corePerlExamples.lmx](../../../LMX_Fn_Receivers/src/corePerlExamples.lmx)
- `FxUnique` — [../../LMX_Fn_Receivers/src/corePerlExamples.lmx](../../../LMX_Fn_Receivers/src/corePerlExamples.lmx)
- `FxGroup` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)
- `FxGroupBy` — [../../LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx)

## Первичные источники семантики Julia

- [https://docs.julialang.org/en/v1/base/sort/](https://docs.julialang.org/en/v1/base/sort/)
- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
- [https://github.com/JuliaData/SplitApplyCombine.jl#grouping](https://github.com/JuliaData/SplitApplyCombine.jl#grouping)
