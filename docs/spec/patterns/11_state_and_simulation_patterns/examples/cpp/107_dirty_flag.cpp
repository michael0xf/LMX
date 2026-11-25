#include <algorithm>
#include <stdexcept>
#include <vector>

struct CachedMaximum {
    std::vector<int> values;
    bool dirty = true;
    int cached = 0;
    int rebuilds = 0;
    explicit CachedMaximum(const std::vector<int>& input) : values(input) {}
    void reset(const std::vector<int>& input) {
        values = input;
        dirty = true;
    }
    void set(int index, int value) {
        if (index < 0 || static_cast<std::size_t>(index) >= values.size())
            throw std::out_of_range("InvalidIndex");
        values[index] = value;
        dirty = true;
    }
    int get() {
        if (dirty) {
            cached = values.empty() ? 0 : *std::max_element(values.begin(), values.end());
            ++rebuilds;
            dirty = false;
        }
        return cached;
    }
};
