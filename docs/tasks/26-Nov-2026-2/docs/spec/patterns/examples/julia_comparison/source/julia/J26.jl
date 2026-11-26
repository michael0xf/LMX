function example(values, count, newest_first)
    count >= 0 || throw(ArgumentError("count"))
    window = values[end - min(count, length(values)) + 1:end]
    newest_first != 0 ? reverse(window) : window
end
