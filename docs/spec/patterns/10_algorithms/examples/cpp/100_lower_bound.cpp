#include <cstddef>
#include <functional>
#include <vector>

template<class T, class U, class Less = std::less<>>
std::size_t lowerBound(const std::vector<T>& items, const U& needle, Less less = {}) {
    std::size_t low = 0, high = items.size();
    while (low < high) {
        const auto middle = low + (high - low) / 2;
        if (less(items[middle], needle)) low = middle + 1;
        else high = middle;
    }
    return low;
}
