function example(xs, seed)
    debit(balance, amount) = max(balance - amount, 0)
    foldl(debit, xs; init=seed)
end
