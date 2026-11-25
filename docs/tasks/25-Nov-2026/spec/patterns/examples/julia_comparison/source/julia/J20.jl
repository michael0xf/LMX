function example(items, capacity)
    ordered = sort(items; by=item -> item.key)
    ordered[1:min(capacity, length(ordered))]
end
