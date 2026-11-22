class Client:
    def __init__(self, read):
        self.read = read
    def execute(self):
        return self.read() * 2

def demo():
    return Client(lambda: 5).execute() + Client(lambda: 7).execute()
