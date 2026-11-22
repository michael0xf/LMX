class Account:
    def __init__(self, balance=100): self.balance = balance
    def debit(self, amount):
        if amount < 0 or amount > self.balance: raise ValueError('funds')
        self.balance -= amount
        return self.balance
