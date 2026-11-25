#include <cstddef>
#include <stdexcept>
#include <vector>

std::vector<int> evolve(const std::vector<int>& cells, int steps) {
    if (steps < 0) throw std::invalid_argument("InvalidSteps");
    for (int cell : cells)
        if (cell != 0 && cell != 1) throw std::invalid_argument("InvalidCell");
    auto current = cells;
    std::vector<int> next(cells.size());
    for (int tick = 0; tick < steps; ++tick) {
        for (std::size_t i = 0; i < cells.size(); ++i) {
            auto left = i == 0 ? cells.size() - 1 : i - 1;
            auto right = i + 1 == cells.size() ? 0 : i + 1;
            next[i] = (current[left] + current[right]) % 2;
        }
        current.swap(next);
    }
    return current;
}
