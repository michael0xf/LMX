class TypeData:
    def __init__(self, damage):
        self.damage = damage

class Item:
    def __init__(self, kind):
        self.kind = kind

def damage(item):
    return item.kind.damage

def demo():
    kind = TypeData(2)
    first, second = Item(kind), Item(kind)
    before = damage(first)
    kind.damage = 3
    return before * 10 + damage(second)
