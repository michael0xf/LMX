def both(left, right):
    def accepts(value):
        return left(value) and right(value)
    return accepts
