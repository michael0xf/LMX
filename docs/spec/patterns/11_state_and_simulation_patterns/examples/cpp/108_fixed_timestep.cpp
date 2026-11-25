#include <cstdint>
#include <stdexcept>
#include <vector>

struct FrameState {
    std::int32_t ticks = 0, position = 0, velocity = 0, lag = 0;
};

std::vector<FrameState> frames(std::int32_t step, const std::vector<std::int32_t>& deltas) {
    if (step <= 0) throw std::invalid_argument("InvalidStep");
    std::int32_t total = 0;
    for (auto elapsed : deltas) {
        if (elapsed < 0) throw std::invalid_argument("InvalidElapsed");
        if (elapsed > 2147483647 - total) throw std::overflow_error("TimeOverflow");
        total += elapsed;
    }
    FrameState state;
    std::vector<FrameState> output;
    for (auto elapsed : deltas) {
        state.lag += elapsed;
        while (state.lag >= step) {
            state.velocity = (state.velocity + 1) % 7;
            state.position = (state.position + state.velocity) % 97;
            ++state.ticks;
            state.lag -= step;
        }
        output.push_back(state);
    }
    return output;
}
