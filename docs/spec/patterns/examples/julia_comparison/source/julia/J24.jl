function example(left, right, budget)
    [(x, y) for x in left for y in right if x + y <= budget]
end
