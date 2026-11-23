example(xs) = collect(Iterators.flatmap(x -> (x, x * x), xs))
