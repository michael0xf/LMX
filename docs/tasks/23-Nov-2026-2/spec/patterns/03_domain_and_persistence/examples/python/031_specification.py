def nonnegative(value): return value >= 0
def below100(value): return value < 100

def build():
    return lambda value: all(p(value) for p in (nonnegative, below100))
