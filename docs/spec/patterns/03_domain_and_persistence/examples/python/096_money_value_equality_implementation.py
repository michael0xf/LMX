def equal_fields(first, second, same):
    if not callable(same): raise TypeError("same must be callable")
    if len(first) != len(second): return False
    for index in range(len(first)):
        if not same(first[index], second[index]): return False
    return True

class Money(tuple):
    __slots__ = ()
    def __new__(cls, cents=100, currency=840):
        return tuple.__new__(cls, (cents, currency))
    @property
    def cents(self): return self[0]
    @property
    def currency(self): return self[1]
    def __eq__(self, other):
        if type(other) is not Money: return NotImplemented
        return equal_fields(self, other, lambda a,b: a == b)
    def __ne__(self, other):
        equal = self.__eq__(other)
        return NotImplemented if equal is NotImplemented else not equal
    __hash__ = tuple.__hash__
