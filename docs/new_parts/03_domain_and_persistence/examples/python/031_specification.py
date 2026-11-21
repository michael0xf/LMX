def nonnegative(value): return value >= 0
def below100(value): return value < 100
def both(left, right):
    return lambda value: left(value) and right(value)
