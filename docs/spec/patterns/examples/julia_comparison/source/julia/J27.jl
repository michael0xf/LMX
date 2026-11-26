function example(values, next)
    before = copy(values)
    if !isempty(values)
        values[2:end] .= values[1:end-1]
        values[1] = next
    end
    values .== before
end
