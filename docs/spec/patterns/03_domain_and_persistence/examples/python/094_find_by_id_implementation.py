def find_by_id(rows, id):
    for row in rows:
        if row.id == id:
            return row
    return None
