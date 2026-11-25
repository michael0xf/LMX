#include <cassert>
#include <iostream>
#include "../../examples/cpp/106_double_buffer.cpp"

int main() {
    int steps, n;
    while (std::cin >> steps >> n) {
        std::vector<int> cells(n);
        for (auto& cell : cells) std::cin >> cell;
        const auto before = cells;
        try {
            auto result = evolve(cells, steps);
            assert(cells == before);
            assert(result == evolve(cells, steps));
            std::cout << "{\"cells\":[";
            for (std::size_t i = 0; i < result.size(); ++i) {
                if (i) std::cout << ',';
                std::cout << result[i];
            }
            std::cout << "]}\n";
            if (!result.empty()) result[0] = 1 - result[0];
            assert(cells == before);
        } catch (const std::exception& error) {
            assert(cells == before);
            std::cout << "{\"error\":\"" << error.what() << "\"}\n";
        }
    }
}
