class Host:
    def __init__(self):
        self.value, self.extension = 7, None
    def install(self, addon):
        self.extension = addon
    def query(self):
        return self.extension

class Report:
    def __init__(self, target):
        self.target = target
    def render(self):
        return self.target.value * 2

def demo():
    host = Host()
    host.install(Report(host))
    return host.query().render()
