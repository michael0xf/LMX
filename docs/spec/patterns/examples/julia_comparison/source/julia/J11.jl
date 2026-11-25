function example(xs)
    candidates = collect(Iterators.flatmap(x -> (x-1, x, x+1), xs))
    unique(filter(>=(0), candidates))
end
