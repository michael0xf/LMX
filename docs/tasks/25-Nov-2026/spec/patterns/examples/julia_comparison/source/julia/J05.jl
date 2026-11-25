function example(xs, baseline)
    delta = xs .- baseline
    sum(delta .* delta)
end
