class Holder:
    def __init__(self, load):
        self.load, self.loaded, self.value = load, False, 0
    def get(self):
        if not self.loaded:
            value = self.load()
            self.value, self.loaded = value, True
        return self.value
