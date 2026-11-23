function example(target, lo, hi, values)
    0 <= lo <= hi <= length(target) || throw(BoundsError(target, lo:hi))
    splice!(target, lo + 1:hi, values)
end
