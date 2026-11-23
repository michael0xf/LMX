class Edit:
    def __init__(self, locks, db): self.locks, self.db = locks, db
    def acquire(self, id, session):
        return self.locks.reserve(id, session)
    def save(self, id, session, token, cents):
        return self.db.write_with_lease(id, session, token, cents)
    def release(self, id, session, token):
        return self.locks.release(id, session, token)
