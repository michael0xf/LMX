from operator import lt


def lower_bound(items, needle, less=lt):
    low, high = 0, len(items)
    while low < high:
        middle = low + (high - low) // 2
        if less(items[middle], needle):
            low = middle + 1
        else:
            high = middle
    return low
