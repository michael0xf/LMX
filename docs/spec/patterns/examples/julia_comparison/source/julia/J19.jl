function example(matrix, baseline)
    calibrated = matrix .- baseline
    [sum(column) for column in eachcol(calibrated)]
end
