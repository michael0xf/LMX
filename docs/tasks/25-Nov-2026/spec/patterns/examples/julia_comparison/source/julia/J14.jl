function example(required, available)
    length(required) == length(available) || return false
    all(i -> 0 < required[i] <= available[i], eachindex(required))
end
