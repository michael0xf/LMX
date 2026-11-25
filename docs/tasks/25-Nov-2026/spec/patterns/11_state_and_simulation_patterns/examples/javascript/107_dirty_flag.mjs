export class CachedMaximum {
    constructor(values) {
        this.rebuilds = 0;
        this.cached = 0;
        this.reset(values);
    }
    reset(values) {
        this.values = values.slice();
        this.dirty = true;
    }
    set(index, value) {
        if (index < 0 || index >= this.values.length)
            throw new RangeError("InvalidIndex");
        this.values[index] = value;
        this.dirty = true;
    }
    get() {
        if (this.dirty) {
            this.cached = this.values.length === 0 ? 0 :
                this.values.reduce((a, b) => Math.max(a, b));
            ++this.rebuilds;
            this.dirty = false;
        }
        return this.cached;
    }
}
