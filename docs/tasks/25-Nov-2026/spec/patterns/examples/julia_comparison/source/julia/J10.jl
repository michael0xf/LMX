function example(left, right, limit)
    length(left) == length(right) || throw(DimensionMismatch("scores"))
    scores = 2 .* left .+ right .* right
    scores[scores .>= limit]
end
