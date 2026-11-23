from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Money:
    cents: int = 100
    currency: int = 840

def demo():
    first, second, third = Money(), Money(), Money(currency=978)
    return int(first == second) * 10 + int(first == third)
