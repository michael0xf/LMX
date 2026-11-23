def all_of(predicates):
    checks = tuple(predicates)
    for predicate in checks:
        if not callable(predicate): raise TypeError("predicate must be callable")
    def accepts(*args, **kwargs):
        for predicate in checks:
            if not predicate(*args, **kwargs): return False
        return True
    return accepts
