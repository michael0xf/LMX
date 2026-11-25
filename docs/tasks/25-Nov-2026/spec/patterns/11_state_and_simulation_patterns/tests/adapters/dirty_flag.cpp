#include <cassert>
#include <iostream>
#include <string>
#include "../../examples/cpp/107_dirty_flag.cpp"

int main() {
    int n;
    while (std::cin >> n) {
        std::vector<int> input(n);
        for (auto& value : input) std::cin >> value;
        CachedMaximum cache(input);
        const auto original = input;
        if (!input.empty()) input[0] = input[0] == 0 ? 1 : 0;
        assert(cache.values == original);
        int count;
        std::cin >> count;
        std::cout << "{\"events\":[";
        for (int event = 0; event < count; ++event) {
            if (event) std::cout << ',';
            char op;
            std::cin >> op;
            std::cout << '{';
            if (op == 'G') {
                const auto value = cache.get();
                std::cout << "\"value\":" << value << ',';
            } else if (op == 'R') {
                int size;
                std::cin >> size;
                std::vector<int> values(size);
                for (auto& value : values) std::cin >> value;
                cache.reset(values);
                const auto expected = values;
                if (!values.empty()) values[0] = values[0] == 0 ? 1 : 0;
                assert(cache.values == expected);
            } else {
                int index, value;
                std::cin >> index >> value;
                const auto oldValues = cache.values;
                const auto oldDirty = cache.dirty;
                const auto oldCached = cache.cached;
                const auto oldRebuilds = cache.rebuilds;
                try {
                    cache.set(index, value);
                } catch (const std::out_of_range& error) {
                    assert(cache.values == oldValues && cache.dirty == oldDirty);
                    assert(cache.cached == oldCached && cache.rebuilds == oldRebuilds);
                    std::cout << "\"error\":\"" << error.what() << "\",";
                }
            }
            std::cout << "\"dirty\":" << (cache.dirty ? "true" : "false")
                      << ",\"rebuilds\":" << cache.rebuilds << '}';
        }
        std::cout << "],\"values\":[";
        for (std::size_t i = 0; i < cache.values.size(); ++i) {
            if (i) std::cout << ',';
            std::cout << cache.values[i];
        }
        std::cout << "],\"cached\":" << cache.cached
                  << ",\"dirty\":" << (cache.dirty ? "true" : "false")
                  << ",\"rebuilds\":" << cache.rebuilds << "}\n";
    }
}
