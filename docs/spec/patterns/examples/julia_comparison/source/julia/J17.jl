function example(target, values, capacity)
    append!(target, values)
    drop = length(target) - capacity
    drop > 0 && splice!(target, 1:drop)
    target
end
