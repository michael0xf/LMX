import {readFileSync} from 'node:fs';
import assert from 'node:assert/strict';
import {frames} from '../../examples/javascript/108_fixed_timestep.mjs';

for (const line of readFileSync(0, 'utf8').trim().split('\n').filter(Boolean)) {
    const [step, n, ...deltas] = line.split(/\s+/).map(Number);
    assert.equal(deltas.length, n);
    const before = deltas.slice();
    try {
        const output = frames(step, deltas);
        assert.deepEqual(deltas, before);
        assert.deepEqual(output, frames(step, deltas));
        let elapsed = 0;
        output.forEach((state, i) => {
            elapsed += deltas[i];
            assert.equal(state.ticks * step + state.lag, elapsed);
            assert(state.lag >= 0 && state.lag < step);
        });
        console.log(JSON.stringify({frames: output}));
        if (output.length > 1) {
            const first = {...output[0]};
            ++output.at(-1).position;
            assert.deepEqual(output[0], first);
        }
    } catch (error) {
        assert.deepEqual(deltas, before);
        if (!['InvalidStep', 'InvalidElapsed', 'TimeOverflow'].includes(error.message)) throw error;
        console.log(JSON.stringify({error: error.message}));
    }
}
