def find_first(items, accepts):
    if not callable(accepts): raise TypeError("accepts must be callable")
    for item in items:
        if accepts(item): return True, item
    return False, None
