class Session:
    def __init__(self, load): self.load, self.cache = load, {}
    def get(self, id):
        if id not in self.cache:
            self.cache[id] = self.load(id)
        return self.cache[id]
