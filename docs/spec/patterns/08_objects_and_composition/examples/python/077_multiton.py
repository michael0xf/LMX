class Settings:
    def __init__(self):
        self.value = 0

class Registry:
    def __init__(self):
        self.first, self.second = Settings(), Settings()
    def get(self, key):
        return self.first if key == 0 else self.second

def demo():
    registry = Registry()
    a, b, c = registry.get(0), registry.get(0), registry.get(1)
    a.value = 7
    return b.value * 10 + c.value
