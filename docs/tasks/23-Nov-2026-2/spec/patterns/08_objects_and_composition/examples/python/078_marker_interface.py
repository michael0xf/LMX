class Auditable:
    pass

class Marked(Auditable):
    pass

class Unmarked:
    value = 7

def accepts(item):
    return int(isinstance(item, Auditable))

def demo():
    return accepts(Marked()) * 10 + accepts(Unmarked())
