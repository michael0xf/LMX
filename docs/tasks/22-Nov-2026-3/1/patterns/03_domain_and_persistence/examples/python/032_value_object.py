from money import Money, same

def demo():
    first = Money()
    second = Money()
    third = Money(currency=978)
    return int(same(first, second)) * 10 + int(same(first, third))
