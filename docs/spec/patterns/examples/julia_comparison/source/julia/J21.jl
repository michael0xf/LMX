function example(batches)
    joined = collect(Iterators.flatten(batches))
    unique(joined)
end
