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
