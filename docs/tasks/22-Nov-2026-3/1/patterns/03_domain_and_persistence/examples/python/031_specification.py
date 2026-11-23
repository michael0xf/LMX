from specification import both

def nonnegative(value): return value >= 0
def below100(value): return value < 100

def build():
    return both(nonnegative, below100)
