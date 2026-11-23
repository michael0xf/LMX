function example(xs, mask)
    length(xs) == length(mask) || throw(DimensionMismatch("mask"))
    xs[mask .!= 0]
end
