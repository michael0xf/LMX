#!/usr/bin/env python3
"""Selected v0.4 tensor contracts on already prepared values, NOT an LMX parser.

Shapes/access maps here are explicit host service data, not new Lmx fields.
No source scanner, graph transplant, dotted alias or streaming-fuse API exists.
Production parsing, TYPE ABI, retention, C import and execution remain NOT_RUN.
"""
from __future__ import annotations
from copy import deepcopy
from dataclasses import dataclass, field
from functools import reduce
from itertools import product
import operator
from typing import Any, Callable, Iterable
from operand_depth_reference import ABSENT, DepthError, DepthExpression, admit_depth, resolve_depth


class ArrayExpressionDiagnostic(ValueError):
    """Host model of a translator/interpreter diagnostic, not an LMX throw."""


class ShapeDiagnostic(ArrayExpressionDiagnostic): pass
class RankDiagnostic(ArrayExpressionDiagnostic): pass
class ProfileDiagnostic(ArrayExpressionDiagnostic): pass
class FusionDiagnostic(ArrayExpressionDiagnostic): pass
class AliasDiagnostic(ArrayExpressionDiagnostic): pass
class ProfileError(ValueError):
    """An ordinary selected provider/admission failure."""


def size_of(shape):
    if any(type(n) is not int or n < 0 for n in shape):
        raise ShapeDiagnostic('extents must be nonnegative integers')
    return reduce(operator.mul, shape, 1)


def row_major_strides(shape):
    stride, result = 1, []
    for extent in reversed(shape):
        result.append(stride)
        stride *= extent
    return tuple(reversed(result))


def coordinates(shape):
    return product(*(range(n) for n in shape))


@dataclass(frozen=True, eq=False)
class ArrayType:
    """Canonical host object identity models TypeRef; no numeric type tags."""
    element: Any
    axes: tuple


_TYPES = {}


def array_type(element, axes):
    axes = tuple(axes)
    if not axes or any(n is not None and (type(n) is not int or n < 0) for n in axes):
        raise ShapeDiagnostic('Array type requires positive rank and valid constraints')
    return _TYPES.setdefault((element, axes), ArrayType(element, axes))


def shape_from_type(axes, length):
    axes = tuple(axes)
    unknown = [i for i, n in enumerate(axes) if n is None]
    known = size_of(tuple(n for n in axes if n is not None))
    if not unknown:
        if known != length:
            raise ShapeDiagnostic('length violates the complete type')
        return axes
    if known == 0:
        if length:
            raise ShapeDiagnostic('a known zero extent requires zero length')
        return None
    if length % known:
        raise ShapeDiagnostic('length is not divisible by the known dimensions')
    if len(unknown) == 1:
        result = list(axes)
        result[unknown[0]] = length // known
        return tuple(result)
    return None


@dataclass(eq=False)
class Array:
    """Prepared access value, with type constraints distinct from access shape.

    shape=None represents owned storage whose declared dimensions are not known.
    An explicit non-contiguous shape/stride map is operation-context data only.
    Full runtime owner-retention is outside this focused host model.
    """
    storage: list
    shape: tuple | None
    element_type: Any = '@'
    offset: int = 0
    strides: tuple | None = None
    dense: bool = True
    admission: Callable | None = None
    type_axes: tuple | None = None
    length: int | None = None
    capacity: int | None = None
    writable: bool = True
    parent: Any = None
    type_descriptor: ArrayType = field(init=False)

    def __post_init__(self):
        if self.type_axes is None:
            if self.shape is None:
                raise ShapeDiagnostic('a missing shape still needs a declared type')
            self.type_axes = tuple(self.shape)
        self.type_descriptor = array_type(self.element_type, self.type_axes)
        self.type_axes = self.type_descriptor.axes
        if self.shape is not None:
            self.shape = tuple(self.shape)
            if len(self.shape) != len(self.type_axes):
                raise ShapeDiagnostic('access rank conflicts with type')
            if any(t is not None and t != n for t, n in zip(self.type_axes, self.shape)):
                raise ShapeDiagnostic('access shape violates a written extent')
            actual_size = size_of(self.shape)
        else:
            actual_size = len(self.storage) - self.offset if self.length is None else self.length
            self.shape = shape_from_type(self.type_axes, actual_size)
        if type(actual_size) is not int or actual_size < 0:
            raise ShapeDiagnostic('invalid length')
        if self.length is not None and self.length != actual_size:
            raise ShapeDiagnostic('length and access size differ')
        self.length = actual_size
        self.capacity = self.length if self.capacity is None else self.capacity
        if type(self.capacity) is not int or self.capacity < self.length:
            raise ShapeDiagnostic('capacity must cover length')
        if type(self.offset) is not int:
            raise ShapeDiagnostic('offset must be integral')
        if self.shape is not None:
            self.strides = row_major_strides(self.shape) if self.strides is None else tuple(self.strides)
            if len(self.strides) != self.rank or any(type(s) is not int for s in self.strides):
                raise ShapeDiagnostic('invalid signed element strides')
            if self.size:
                low = self.offset + sum(min(0, (n - 1) * s) for n, s in zip(self.shape, self.strides))
                high = self.offset + sum(max(0, (n - 1) * s) for n, s in zip(self.shape, self.strides))
                if low < 0 or high >= len(self.storage):
                    raise ShapeDiagnostic('map exceeds its supplied backing')
        elif self.offset < 0 or self.offset + self.size > len(self.storage):
            raise ShapeDiagnostic('flat range exceeds backing')

    @property
    def size(self): return self.length
    @property
    def rank(self): return len(self.type_axes)
    @property
    def capacity_entry(self): return None if self.capacity == self.length else self.capacity

    def require_shape(self):
        if self.shape is None:
            raise ShapeDiagnostic('required dimensions are unavailable')
        return self.shape

    def address(self, coord):
        shape = self.require_shape()
        if len(coord) != self.rank or any(type(i) is not int or i < 0 or i >= n for i, n in zip(coord, shape)):
            raise ShapeDiagnostic('invalid prepared logical coordinate')
        return self.offset + sum(i * s for i, s in zip(coord, self.strides))

    def get(self, coord): return self.storage[self.address(coord)]

    def flat_coordinate(self, i):
        if type(i) is not int or i < 0 or i >= self.size:
            raise ShapeDiagnostic('flat index outside length')
        shape = self.require_shape()
        result = []
        for stride in row_major_strides(shape):
            result.append(i // stride)
            i %= stride
        return tuple(result)

    def flat_address(self, i):
        if type(i) is not int or i < 0 or i >= self.size:
            raise ShapeDiagnostic('flat index outside length')
        return self.offset + i if self.shape is None else self.address(self.flat_coordinate(i))

    def flat_get(self, i): return self.storage[self.flat_address(i)]
    def values(self): return [self.flat_get(i) for i in range(self.size)]

    def cell(self, frame_coord, depth):
        shape = self.require_shape()
        depth = admit_depth(depth)
        traversed = self.rank if depth == 0 else depth
        if traversed > self.rank:
            raise DepthError('depth exceeds the actual Array rank')
        if traversed == self.rank:
            return self.get(frame_coord)
        offset = self.offset + sum(i * s for i, s in zip(frame_coord, self.strides[:traversed]))
        return Array(self.storage, shape[traversed:], self.element_type, offset, self.strides[traversed:],
                     self.dense, self.admission, writable=False, parent=self)

    def axis_at(self, i):
        shape = self.require_shape()
        if type(i) is not int or i < 0 or i >= shape[0]:
            raise ShapeDiagnostic('axis index outside extent')
        return self.cell((i,), 1)


def array_value(items, metrics=None):
    values = list(items)
    if metrics is not None: metrics.array_allocations += 1
    return Array(values, (len(values),), '@', dense=False, type_axes=(None,))


@dataclass
class Metrics:
    array_allocations: int = 0
    output_passes: int = 0
    output_elements: int = 0


@dataclass
class ScalarProfile:
    methods: dict
    result_type: Any = '@'
    admit: Callable = lambda value: True
    zero: Callable = lambda: 0
    one: Callable = lambda: 1
    # A supplied certificate is trusted model input, not inferred from purity.
    fusion_safe: frozenset = frozenset()

    def call(self, name, *values):
        if name not in self.methods:
            raise ProfileDiagnostic(f'unsupported actual scalar method: {name}')
        value = self.methods[name](*values)
        if not self.admit(value):
            raise ProfileError('scalar result rejected by its declared intermediate type')
        return value


def python_profile(result_type='@'):
    methods = {'+': operator.add, '-': operator.sub, '*': operator.mul, '/': operator.truediv,
               '%': operator.mod, '**': operator.pow, '=': operator.eq, '!=': operator.ne,
               '<': operator.lt, '>': operator.gt, '<=': operator.le, '>=': operator.ge,
               '&': operator.and_, '|': operator.or_, '^': operator.xor,
               '<<': operator.lshift, '>>': operator.rshift, 'same': operator.is_}
    return ScalarProfile(methods, result_type)


def common_shape(values):
    shapes = [v.require_shape() for v in values if isinstance(v, Array)]
    if shapes and any(s != shapes[0] for s in shapes[1:]):
        raise ShapeDiagnostic('iterated Array frames must match exactly')
    return shapes[0] if shapes else ()


def publish(values, shape, element_type, metrics=None):
    if metrics is not None:
        metrics.array_allocations += 1
        metrics.output_passes += 1
        metrics.output_elements += len(values)
    return Array(list(values), tuple(shape), element_type)


def ordinary(name, *values, profile, metrics=None):
    if name == '[*]':
        return matmul(*values, profile=profile, metrics=metrics)
    if name.startswith('.'):
        raise ProfileDiagnostic('no general dotted callable alias')
    shape = common_shape(values)
    if not any(isinstance(v, Array) for v in values):
        return profile.call(name, *values)
    output = [profile.call(name, *(v.get(c) if isinstance(v, Array) else v for v in values))
              for c in coordinates(shape)]
    return publish(output, shape, profile.result_type, metrics)


@dataclass(frozen=True)
class Held:
    value: Any


def map_cells(method, *values, depth, cell_shape=(), result_type='@', metrics=None):
    """Exactly one lifting; method is the selected base body, never auto-remapped."""
    depth = admit_depth(depth)
    arrays = [v for v in values if isinstance(v, Array)]
    if depth and any(depth > v.rank for v in arrays):
        raise DepthError('depth exceeds an iterated Array rank')
    frames = [v.require_shape() if depth == 0 else v.require_shape()[:depth] for v in arrays]
    frame = frames[0] if frames else ()
    if any(f != frame for f in frames[1:]):
        raise ShapeDiagnostic('depth frames must match; use an explicit held actual')
    def actual(v, coord):
        if isinstance(v, Held): return v.value
        return v.cell(coord, depth) if isinstance(v, Array) else v
    if not frame:
        return method(*(actual(v, ()) for v in values))
    output = []
    for coord in coordinates(frame):
        value = method(*(actual(v, coord) for v in values))
        if cell_shape:
            if not isinstance(value, Array) or value.require_shape() != tuple(cell_shape):
                raise ShapeDiagnostic('cell result violates declared assembly')
            output.extend(value.values())
        else:
            output.append(value)
    return publish(output, frame + tuple(cell_shape), result_type, metrics)


def _product_shape(a, b):
    if not a or not b:
        raise ShapeDiagnostic('automatic matrix product requires Array inputs')
    left, right = a[-1], b[-2] if len(b) > 1 else b[0]
    if left != right:
        raise ShapeDiagnostic('contracted dimensions differ')
    fa, fb = a[:-2] if len(a) > 2 else (), b[:-2] if len(b) > 2 else ()
    if fa and fb and fa != fb:
        raise ShapeDiagnostic('automatic batch frames differ')
    # This contract does not silently broadcast an unbatched matrix into batches.
    if fa != fb and len(a) > 1 and len(b) > 1:
        raise ShapeDiagnostic('use explicit axis rules for differing batch frames')
    return (fa or fb) + (() if len(a) == 1 else (a[-2],)) + (() if len(b) == 1 else (b[-1],))


def apply(name, *values, depth=ABSENT, profile, metrics=None):
    if depth is ABSENT:
        return ordinary(name, *values, profile=profile, metrics=metrics)
    depth = admit_depth(depth)
    arrays = [v for v in values if isinstance(v, Array)]
    if depth and any(depth > v.rank for v in arrays):
        raise DepthError('depth exceeds an iterated Array rank')
    shapes = [v.require_shape()[depth:] if depth else () for v in arrays]
    if name == '[*]':
        if len(shapes) != 2:
            raise ShapeDiagnostic('selected matrix handler requires two Array cells')
        cell_shape = _product_shape(*shapes)
        base = lambda *xs: matmul(*xs, profile=profile)
    else:
        if any(shapes):
            raise ProfileDiagnostic('scalar base handler does not admit remaining Array cells')
        cell_shape = ()
        base = lambda *xs: profile.call(name, *xs)
    return map_cells(base, *values, depth=depth, cell_shape=cell_shape,
                     result_type=profile.result_type, metrics=metrics)


@dataclass
class Accumulator:
    step: Callable
    start: str = 'first'
    identity: Callable | None = None
    seed: Any = ABSENT
    clone_seed: Callable = deepcopy
    map_to_state: Callable = lambda value: value
    finish: Callable = lambda state: state
    empty: str = 'error'

    def fold(self, values):
        iterator = iter(values)
        first = next(iterator, ABSENT)
        if self.seed is not ABSENT:
            state = self.clone_seed(self.seed)
            if first is not ABSENT: state = self.step(state, first)
        elif self.start == 'identity':
            if self.identity is None: raise ProfileDiagnostic('identity factory required')
            state = self.identity()
            if first is not ABSENT: state = self.step(state, first)
        elif self.start == 'first':
            if first is ABSENT:
                if self.empty != 'identity' or self.identity is None:
                    raise ProfileError('empty reduction has no result contract')
                state = self.identity()
            else:
                state = self.map_to_state(first)
        else:
            raise ProfileDiagnostic('unsupported declared start mode in focused model')
        for value in iterator:
            state = self.step(state, value)
        return self.finish(state)


def indexed_binary(a, b, kernel, rules=(), *, accumulator=None, reduce_actual=False,
                   order=None, result_type='@', metrics=None):
    """Rules already parsed as (left_axis, relation, right_axis), no DSL parsing."""
    sa = a.require_shape() if isinstance(a, Array) else ()
    sb = b.require_shape() if isinstance(b, Array) else ()
    used_a, used_b, retained, composite, contracted = set(), set(), [], [], []
    for i, relation, j in rules:
        if type(i) is not int or type(j) is not int or not 0 <= i < len(sa) or not 0 <= j < len(sb):
            raise ShapeDiagnostic('axis index outside operand rank')
        if i in used_a or j in used_b:
            raise ShapeDiagnostic('axis occurs in more than one relation')
        used_a.add(i); used_b.add(j)
        if relation not in (':', '=', '*'):
            raise ProfileDiagnostic('unknown axis relation')
        if relation != '*' and sa[i] != sb[j]:
            raise ShapeDiagnostic('linked lengths differ')
        {':': contracted, '=': retained, '*': composite}[relation].append((i, j))
    contracted.sort()
    descriptors = [('=', i, j, sa[i]) for i, j in retained]
    descriptors += [('*', i, j, sa[i]*sb[j]) for i, j in composite]
    descriptors += [('a', i, None, n) for i, n in enumerate(sa) if i not in used_a]
    descriptors += [('b', None, j, n) for j, n in enumerate(sb) if j not in used_b]
    if order is None: order = tuple(range(len(descriptors)))
    if sorted(order) != list(range(len(descriptors))):
        raise ShapeDiagnostic('output order must be a full permutation')
    output_shape = tuple(descriptors[i][3] for i in order)
    if contracted and accumulator is None:
        raise ProfileDiagnostic('a contracted kernel needs an explicit reducer contract')
    if not contracted and reduce_actual:
        raise ProfileDiagnostic('explicit reducer on a no-reduction application')
    def output_at(output_coord):
        canonical = [0] * len(order)
        for index, old in enumerate(order): canonical[old] = output_coord[index]
        ia, ib = [0]*len(sa), [0]*len(sb)
        for value, (kind, i, j, _) in zip(canonical, descriptors):
            if kind == '=': ia[i] = ib[j] = value
            elif kind == '*': ia[i], ib[j] = divmod(value, sb[j])
            elif kind == 'a': ia[i] = value
            else: ib[j] = value
        def call(): return kernel(a.get(tuple(ia)) if sa else a, b.get(tuple(ib)) if sb else b)
        if not contracted:
            return call()  # Default accumulator and identity are deliberately unused.
        def candidates():
            for coord in coordinates(tuple(sa[i] for i, _ in contracted)):
                for value, (i, j) in zip(coord, contracted): ia[i] = ib[j] = value
                yield call()
        return accumulator.fold(candidates())
    if not output_shape: return output_at(())
    return publish([output_at(c) for c in coordinates(output_shape)], output_shape, result_type, metrics)


def matmul(a, b, *, profile, metrics=None):
    if not isinstance(a, Array) or not isinstance(b, Array):
        raise ShapeDiagnostic('automatic matrix product requires Arrays')
    sa, sb = a.require_shape(), b.require_shape()
    _product_shape(sa, sb)
    # Rank-one vector promotion introduces no retained artificial dimension.
    rules = [(a.rank-1, ':', b.rank-2 if b.rank > 1 else 0)]
    fa, fb = max(a.rank-2, 0), max(b.rank-2, 0)
    if fa and fb:
        rules = [(i, '=', i) for i in range(fa)] + rules
    accumulator = Accumulator(lambda s, z: profile.call('+', s, z),
                              identity=profile.zero, empty='identity')
    return indexed_binary(a, b, lambda x, y: profile.call('*', x, y), rules,
                          accumulator=accumulator, result_type=profile.result_type, metrics=metrics)


def reduce_axes(array, axes, accumulator, *, diagonal=None, result_type='@', metrics=None):
    shape = array.require_shape()
    axes = tuple(sorted(axes))
    if len(set(axes)) != len(axes) or any(type(i) is not int or not 0 <= i < array.rank for i in axes):
        raise ShapeDiagnostic('invalid reduction axes')
    if diagonal is not None:
        i, j = diagonal
        if i == j or i not in axes or j not in axes or shape[i] != shape[j]:
            raise ShapeDiagnostic('invalid reduced diagonal')
    free = tuple(i for i in range(array.rank) if i not in axes)
    output_shape = tuple(shape[i] for i in free)
    reduced = tuple(i for i in axes if diagonal is None or i != diagonal[1])
    def at(out):
        index = [0]*array.rank
        for i, value in zip(free, out): index[i] = value
        def values():
            for coord in coordinates(tuple(shape[i] for i in reduced)):
                for i, value in zip(reduced, coord): index[i] = value
                if diagonal is not None: index[diagonal[1]] = index[diagonal[0]]
                yield array.get(tuple(index))
        return accumulator.fold(values())
    if not output_shape: return at(())
    return publish([at(c) for c in coordinates(output_shape)], output_shape, result_type, metrics)


def transpose(array, order):
    shape = array.require_shape()
    if sorted(order) != list(range(array.rank)):
        raise ShapeDiagnostic('axis permutation required')
    return Array(array.storage, tuple(shape[i] for i in order), array.element_type,
                 array.offset, tuple(array.strides[i] for i in order), array.dense,
                 array.admission, writable=False, parent=array)


def _assignment_values(destination, source, *, broadcast=False):
    """Prepare checked addresses and pre-write values; do not store."""
    if not destination.writable: raise ProfileError('destination is read-only')
    shape = destination.require_shape()
    source_shape = source.require_shape() if isinstance(source, Array) else ()
    if isinstance(source, Array):
        if broadcast:
            if len(source_shape) > len(shape): raise ShapeDiagnostic('RHS rank exceeds target rank')
            padded = (1,)*(len(shape)-len(source_shape)) + source_shape
            if any(s != t and s != 1 for s, t in zip(padded, shape)):
                raise ShapeDiagnostic('RHS cannot broadcast to destination')
        elif source_shape != shape:
            raise ShapeDiagnostic('ordinary assignment requires exact Array shape')
    addresses = [destination.address(c) for c in coordinates(shape)]
    if len(set(addresses)) != len(addresses):
        raise AliasDiagnostic('repeated destinations require an explicit scatter contract')
    values = []
    for coord in coordinates(shape):
        if not isinstance(source, Array): value = source
        elif broadcast:
            tail = coord[len(coord)-len(source_shape):]
            value = source.get(tuple(0 if n == 1 else i for i, n in zip(tail, source_shape)))
        else: value = source.get(coord)
        values.append(value)
    if destination.admission and not all(destination.admission(v) for v in values):
        raise ProfileError('target admission failed before stores')
    return list(zip(addresses, values))


def assign(destination, source, *, broadcast=False, depth=ABSENT):
    """Whole assignment or one depth frame, with one snapshot before all stores."""
    if broadcast:
        if depth is not ABSENT:
            depth = admit_depth(depth)
            if depth > destination.rank:
                raise DepthError('destination has insufficient logical axes')
        # .: owns PLACE preparation; no raw-RHS exact-frame Map is inserted.
        writes = _assignment_values(destination, source.value if isinstance(source, Held) else source, broadcast=True)
    elif depth is ABSENT:
        writes = _assignment_values(destination, source, broadcast=False)
    else:
        depth = admit_depth(depth)
        if depth > destination.rank:
            raise DepthError('destination has insufficient logical axes')
        count = destination.rank if depth == 0 else depth
        frame = destination.require_shape()[:count]
        if isinstance(source, Array):
            if depth > source.rank:
                raise DepthError('source has insufficient logical axes')
            other = source.require_shape() if depth == 0 else source.require_shape()[:depth]
            if frame != other:
                raise ShapeDiagnostic('assignment depth frames differ')
        writes = []
        for coord in coordinates(frame):
            rhs = source.value if isinstance(source, Held) else (source.cell(coord, depth) if isinstance(source, Array) else source)
            if count == destination.rank:
                if not destination.writable:
                    raise ProfileError('destination is read-only')
                if destination.admission and not destination.admission(rhs):
                    raise ProfileError('target admission failed before stores')
                writes.append((destination.address(coord), rhs))
            else:
                cell = destination.cell(coord, depth)
                cell.writable = destination.writable  # Rights come from the actual PLACE.
                writes.extend(_assignment_values(cell, rhs, broadcast=broadcast))
    addresses = [address for address, _ in writes]
    if len(set(addresses)) != len(addresses):
        raise AliasDiagnostic('duplicate places require an explicit scatter contract')
    for address, value in writes:
        destination.storage[address] = value
    return destination


@dataclass(frozen=True)
class ScalarCall:
    callback: Callable


@dataclass(frozen=True)
class Op:
    name: str
    args: tuple
    depth: Any = ABSENT


@dataclass(frozen=True)
class Select:
    condition: Any
    yes: Any
    no: Any


def op(name, *args, depth=ABSENT): return Op(name, args, depth)


def evaluate(node, *, profile, metrics=None, obtain_depth=None):
    if isinstance(node, ScalarCall): return node.callback()
    if isinstance(node, Select):
        condition = evaluate(node.condition, profile=profile, metrics=metrics, obtain_depth=obtain_depth)
        if isinstance(condition, Array): raise ProfileDiagnostic('condition must be scalar')
        return evaluate(node.yes if condition else node.no, profile=profile, metrics=metrics, obtain_depth=obtain_depth)
    if isinstance(node, Op):
        depth = resolve_depth(node.depth, obtain_depth or (lambda expr, context: expr()))
        values = [evaluate(x, profile=profile, metrics=metrics, obtain_depth=obtain_depth) for x in node.args]
        return apply(node.name, *values, depth=depth, profile=profile, metrics=metrics)
    return node


@dataclass
class _Fused:
    shape: tuple
    array_result: bool
    at: Callable


def fuse(node, *, profile, metrics=None, obtain_depth=None):
    """Fresh Scalar/Map only; conservative certificates protect failure order.

    A potentially failing intermediate Array node is rejected unless its method
    has an explicit ordering certificate. A sole root Map retains eager order.
    No destination parameter: outside assignment obtains this result first.
    """
    def prepare(value, inner=False):
        if isinstance(value, Select):
            condition = evaluate(value.condition, profile=profile, obtain_depth=obtain_depth)
            if isinstance(condition, Array): raise FusionDiagnostic('scalar branch condition required')
            return prepare(value.yes if condition else value.no, inner)
        if isinstance(value, ScalarCall): value = value.callback()
        if isinstance(value, Op):
            depth = resolve_depth(value.depth, obtain_depth or (lambda expr, context: expr()))
            if depth is not ABSENT: depth = admit_depth(depth)
            if value.name not in profile.methods or value.name.startswith('.'):
                raise FusionDiagnostic('unsupported Scalar/Map kernel')
            args = [prepare(x, True) for x in value.args]
            shapes = [x.shape for x in args if x.array_result]
            if depth is not ABSENT and depth:
                if any(depth > len(s) for s in shapes):
                    raise DepthError('depth exceeds an iterated Array rank')
                if any(depth != len(s) for s in shapes):
                    raise FusionDiagnostic('remaining Array cells have no scalar emitter here')
            if shapes and any(s != shapes[0] for s in shapes[1:]):
                raise ShapeDiagnostic('Map frames differ')
            shape = shapes[0] if shapes else ()
            is_array = bool(shapes)
            if inner and is_array and value.name not in profile.fusion_safe:
                raise FusionDiagnostic('intermediate failure/effect order is not certified')
            if not is_array:
                ready = profile.call(value.name, *(x.at(()) for x in args))
                return _Fused((), False, lambda c: ready)
            return _Fused(shape, True, lambda c: profile.call(value.name, *(x.at(c) for x in args)))
        if isinstance(value, Array):
            return _Fused(value.require_shape(), True, value.get)
        return _Fused((), False, lambda c: value)
    plan = prepare(node)
    if not plan.array_result: return plan.at(())
    values = [plan.at(c) for c in coordinates(plan.shape)]
    return publish(values, plan.shape, profile.result_type, metrics)
