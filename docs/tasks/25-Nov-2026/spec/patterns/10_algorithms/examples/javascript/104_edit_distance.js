function editDistance(left, right, same = (a, b) => a === b) {
    let previous = Array.from({length: right.length + 1}, (_, index) => index);
    for (let i = 1; i <= left.length; ++i) {
        const current = [i];
        for (let j = 1; j <= right.length; ++j) {
            const cost = same(left[i - 1], right[j - 1]) ? 0 : 1;
            current.push(Math.min(previous[j] + 1, current[j - 1] + 1,
                                  previous[j - 1] + cost));
        }
        previous = current;
    }
    return previous[right.length];
}

module.exports = {editDistance};
