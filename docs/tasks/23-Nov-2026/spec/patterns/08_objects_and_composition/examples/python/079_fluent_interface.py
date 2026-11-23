class Options:
    def with_count(self, value):
        self.count = value
        return self
    def with_price(self, value):
        self.price = value
        return self
    def total(self):
        return self.count * self.price

def demo():
    return Options().with_count(3).with_price(7).total()
