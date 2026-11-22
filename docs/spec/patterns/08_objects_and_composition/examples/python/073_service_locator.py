class Locator:
    def resolve(self, key):
        return (lambda: 42) if key == 1 else (lambda: 0)

def client(locator):
    return locator.resolve(1)()

def demo():
    return client(Locator())
