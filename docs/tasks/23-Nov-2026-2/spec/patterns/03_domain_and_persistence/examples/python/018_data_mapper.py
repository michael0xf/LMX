from dataclasses import dataclass
@dataclass
class Account:
    id: int
    cents: int
class Mapper:
    def __init__(self, rows): self.rows = rows
    def load(self, id):
        row = self.rows.read(id)
        return Account(row[0], row[1])
    def save(self, account):
        self.rows.write(account.id, account.cents)
        return account
