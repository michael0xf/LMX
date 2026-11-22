from dataclasses import dataclass
from lookup import find_by_id

@dataclass
class Account:
    id: int
    cents: int

class Repository:
    def __init__(self, rows): self.rows = rows
    def find(self, id): return find_by_id(self.rows, id)
