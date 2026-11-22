class OrderTable:
    def __init__(self, rows): self.rows = rows
    def total(self):
        result = 0
        for row in self.rows:
            result += row['quantity'] * row['price']
        return result
