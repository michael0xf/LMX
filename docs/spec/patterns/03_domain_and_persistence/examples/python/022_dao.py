class DbDao:
    def __init__(self, db): self.db = db
    def read_balance(self, id):
        return self.db.scalar('SELECT cents FROM account WHERE id = ?', id)
class FixedDao:
    def read_balance(self, id): return 25
def read(dao, id):
    return dao.read_balance(id)
