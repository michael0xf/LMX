function example(text)
    digits = filter(c -> '0' <= c <= '9', text)
    last(digits, 4)
end
