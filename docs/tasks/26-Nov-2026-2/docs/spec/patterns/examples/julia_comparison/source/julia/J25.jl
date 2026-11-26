function example(xs, gain, bias, limit)
    calibrated = gain .* xs .+ bias
    calibrated[calibrated .>= limit]
end
