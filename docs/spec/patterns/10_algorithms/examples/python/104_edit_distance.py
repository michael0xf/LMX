from operator import eq


def edit_distance(left, right, same=eq):
    previous = list(range(len(right) + 1))
    for i, first in enumerate(left, 1):
        current = [i]
        for j, second in enumerate(right, 1):
            cost = 0 if same(first, second) else 1
            current.append(min(previous[j] + 1, current[-1] + 1,
                               previous[j - 1] + cost))
        previous = current
    return previous[-1]
