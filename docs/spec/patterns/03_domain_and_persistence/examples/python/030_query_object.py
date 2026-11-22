from dataclasses import dataclass
@dataclass(frozen=True)
class RangeQuery:
    minimum: int
    maximum: int
    def execute(self, db):
        if self.minimum > self.maximum: raise ValueError('range')
        return db.query('SELECT id,cents FROM account WHERE cents BETWEEN ? AND ?', self.minimum, self.maximum)
