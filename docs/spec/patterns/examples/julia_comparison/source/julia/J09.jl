function example(left, right)
    shortages = [max(required - available, 0) for (required, available) in zip(left, right)]
    sum(shortages)
end
