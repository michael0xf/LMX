function example(xs, lo, hi)
    isempty(xs) && return 0
    accepted = count(x -> lo <= x <= hi, xs)
    1000 * accepted ÷ length(xs)
end
