from dataclasses import dataclass

@dataclass
class Account:
    id: int
    cents: int

class Repository:
    def __init__(self, rows): self.rows = rows
    def find(self, id): return next((row for row in self.rows if row.id == id), None)
