def save(db, id, version, cents):
    if db.compare_and_set(id, version, cents) != 1:
        raise RuntimeError('conflict')
