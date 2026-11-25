export function frames(step, deltas) {
    if (step <= 0) throw new RangeError("InvalidStep");
    let total = 0;
    for (const elapsed of deltas) {
        if (elapsed < 0) throw new RangeError("InvalidElapsed");
        if (elapsed > 2147483647 - total) throw new RangeError("TimeOverflow");
        total += elapsed;
    }
    const state = {ticks: 0, position: 0, velocity: 0, lag: 0};
    return deltas.map(elapsed => {
        state.lag += elapsed;
        while (state.lag >= step) {
            state.velocity = (state.velocity + 1) % 7;
            state.position = (state.position + state.velocity) % 97;
            ++state.ticks;
            state.lag -= step;
        }
        return {...state};
    });
}
