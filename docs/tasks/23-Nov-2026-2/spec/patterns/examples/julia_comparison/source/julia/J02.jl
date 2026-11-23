function example(xs, lo, hi)
    0 <= lo <= hi <= length(xs) || throw(BoundsError(xs, lo:hi))
    xs[lo + 1:hi]
end
