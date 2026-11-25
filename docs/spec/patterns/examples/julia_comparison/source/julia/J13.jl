function example(xs, limit)
    positions = 2:length(xs)
    any(i -> xs[i-1] > limit && xs[i] > limit, positions)
end
