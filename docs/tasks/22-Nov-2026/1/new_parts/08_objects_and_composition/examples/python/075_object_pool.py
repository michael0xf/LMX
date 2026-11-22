class Resource:
    id = 7

class Pool:
    def __init__(self):
        self.free = Resource()
    def take(self):
        result, self.free = self.free, None
        return result
    def give(self, item):
        self.free = item

def demo():
    pool = Pool()
    first, busy = pool.take(), pool.take()
    pool.give(first)
    again = pool.take()
    return int(first is again and busy is None)
