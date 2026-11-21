class UnitOfWork:
    def __init__(self, db):
        self.db, self.dirty = db, {}
    def mark(self, id, cents):
        self.dirty[id] = cents
    def flush(self):
        def write_all():
            for id, cents in self.dirty.items():
                self.db.upsert(id, cents)
        self.db.atomic(write_all)
        self.dirty.clear()
