using SplitApplyCombine: group
function example(xs)
    distinct = unique(xs)
    group(isodd, distinct)
end
