def transfer(db, from_id, to_id, amount):
    def body():
        a, b = db.read_locked(from_id), db.read_locked(to_id)
        if amount < 0 or from_id == to_id or a < amount:
            raise ValueError('funds')
        db.write(from_id, a - amount)
        db.write(to_id, b + amount)
    db.atomic(body)
