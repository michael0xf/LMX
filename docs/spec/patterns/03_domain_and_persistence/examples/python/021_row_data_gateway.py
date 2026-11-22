class RowGateway:
    def __init__(self, db, id, cents):
        self.db, self.id, self.cents = db, id, cents
    def update(self):
        return self.db.execute('UPDATE account SET cents = ? WHERE id = ?', self.cents, self.id)
