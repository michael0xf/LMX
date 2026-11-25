function example(xs, seed)
    balances = [seed; accumulate(+, xs; init=seed)]
    filter(<(0), balances)
end
