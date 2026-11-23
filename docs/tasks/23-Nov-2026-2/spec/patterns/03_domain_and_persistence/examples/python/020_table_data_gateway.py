class Accounts:
    def __init__(self, db): self.db = db
    def balance(self, id):
        return self.db.scalar('SELECT cents FROM account WHERE id = ?', id)
    def update(self, id, cents):
        return self.db.execute('UPDATE account SET cents = ? WHERE id = ?', cents, id)
