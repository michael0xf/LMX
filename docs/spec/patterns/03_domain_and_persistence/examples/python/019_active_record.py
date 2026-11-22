class Account:
    def __init__(self, db, id=7, cents=100):
        self.db, self.id, self.cents = db, id, cents
    def debit(self, amount):
        if amount < 0 or amount > self.cents: raise ValueError('funds')
        self.cents -= amount
    def save(self):
        self.db.upsert(self.id, self.cents)
