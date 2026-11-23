example(start::Int, stop::Int, step::Int) =
    collect(Iterators.takewhile(x -> step > 0 ? x < stop : x > stop,
                               start:step:stop))
