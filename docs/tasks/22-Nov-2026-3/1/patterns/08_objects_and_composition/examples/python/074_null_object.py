def silent(value):
    pass

def execute(value, log=silent):
    log(value)
    return value

def demo():
    return execute(10)
