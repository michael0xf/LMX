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
