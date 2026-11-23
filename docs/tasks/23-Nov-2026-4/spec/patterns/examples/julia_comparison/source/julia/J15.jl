function example(xs, limit)
    found = findfirst(x -> x > limit, xs)
    isnothing(found) ? nothing : found - 1
end
