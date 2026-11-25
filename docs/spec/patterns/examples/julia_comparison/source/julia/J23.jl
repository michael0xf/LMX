function example(parts)
    history = collect(Iterators.flatten(parts))
    reverse(history)
end
