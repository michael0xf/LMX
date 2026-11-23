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
