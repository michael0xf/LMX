#include <cassert>
#include <iostream>
#include "../../examples/cpp/108_fixed_timestep.cpp"

int main() {
    std::int32_t step;
    int n;
    while (std::cin >> step >> n) {
        std::vector<std::int32_t> deltas(n);
        for (auto& delta : deltas) std::cin >> delta;
        const auto before = deltas;
        try {
            auto output = frames(step, deltas);
            assert(deltas == before);
            auto again = frames(step, deltas);
            assert(output.size() == again.size());
            std::int64_t elapsed = 0;
            std::cout << "{\"frames\":[";
            for (std::size_t i = 0; i < output.size(); ++i) {
                const auto& s = output[i];
                const auto& a = again[i];
                assert(s.ticks == a.ticks && s.position == a.position);
                assert(s.velocity == a.velocity && s.lag == a.lag);
                elapsed += deltas[i];
                assert(static_cast<std::int64_t>(s.ticks) * step + s.lag == elapsed);
                assert(s.lag >= 0 && s.lag < step);
                if (i) std::cout << ',';
                std::cout << "{\"ticks\":" << s.ticks << ",\"position\":" << s.position
                          << ",\"velocity\":" << s.velocity << ",\"lag\":" << s.lag << '}';
            }
            std::cout << "]}\n";
            if (output.size() > 1) {
                auto first = output.front();
                ++output.back().position;
                assert(output.front().position == first.position);
            }
        } catch (const std::exception& error) {
            assert(deltas == before);
            std::cout << "{\"error\":\"" << error.what() << "\"}\n";
        }
    }
}
