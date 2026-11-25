import {readFileSync} from 'node:fs';
import assert from 'node:assert/strict';
import {CachedMaximum} from '../../examples/javascript/107_dirty_flag.mjs';

for (const line of readFileSync(0, 'utf8').trim().split('\n').filter(Boolean)) {
    const tokens = line.split(/\s+/);
    let at = 0;
    const number = () => Number(tokens[at++]);
    const list = () => Array.from({length: number()}, number);
    const input = list();
    const cache = new CachedMaximum(input);
    const original = input.slice();
    if (input.length) input[0] = input[0] === 0 ? 1 : 0;
    assert.deepEqual(cache.values, original);
    const count = number(), events = [];
    for (let i = 0; i < count; ++i) {
        const op = tokens[at++], event = {};
        if (op === 'G') event.value = cache.get();
        else if (op === 'R') {
            const values = list();
            cache.reset(values);
            const expected = values.slice();
            if (values.length) values[0] = values[0] === 0 ? 1 : 0;
            assert.deepEqual(cache.values, expected);
        } else {
            const index = number(), value = number();
            const before = JSON.stringify(cache);
            try { cache.set(index, value); }
            catch (error) {
                assert.equal(JSON.stringify(cache), before);
                event.error = error.message;
            }
        }
        events.push({...event, dirty: cache.dirty, rebuilds: cache.rebuilds});
    }
    console.log(JSON.stringify({events, values: cache.values, cached: cache.cached,
                               dirty: cache.dirty, rebuilds: cache.rebuilds}));
}
