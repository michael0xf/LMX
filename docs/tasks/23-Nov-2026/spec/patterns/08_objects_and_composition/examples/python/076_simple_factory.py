class Product:
    def __init__(self, cost):
        self.cost = cost

def create(kind):
    return Product(5 if kind == 0 else 9)

def demo():
    return create(0).cost + create(1).cost
