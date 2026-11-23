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
