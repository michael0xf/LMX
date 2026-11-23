example(xs, seed) = [seed; accumulate(+, xs; init=seed)]
