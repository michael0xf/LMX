#!/usr/bin/env python3
"""Executable reference for the Array arithmetic and fuse contracts.

This is a semantic model, not the LMX parser, translator, native ABI, or runtime.
Shape is supplied explicitly. A Python list is only backing storage, never a
source from which rank or the scalar result type is inferred.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from functools import reduce
from itertools import product
import operator
from typing import Any, Callable, Iterable, Mapping

from operand_depth_reference import DepthError, admit_depth, resolve_depth


class ArrayExpressionDiagnostic(ValueError):
    """Host representation of a translator/interpreter diagnostic, not an LMX throw."""


class ShapeDiagnostic(ArrayExpressionDiagnostic):
    pass


class RankDiagnostic(ArrayExpressionDiagnostic):
    pass


class ProfileDiagnostic(ArrayExpressionDiagnostic):
    pass


class ProfileError(ValueError):
    """Ordinary provider/target admission failure, not a new language error name."""


class FusionDiagnostic(ArrayExpressionDiagnostic):
    """Invalid fusion is diagnosed by the translator/interpreter; no catchable LMX error."""


class AliasDiagnostic(ArrayExpressionDiagnostic):
    """Unsupported fusion aliasing is a translator/interpreter diagnostic."""


def size_of(shape: tuple[int, ...]) -> int:
    if any(type(n) is not int or n < 0 for n in shape):
        raise ShapeDiagnostic("dimensions must be nonnegative integers")
    return reduce(operator.mul, shape, 1)


def row_major_strides(shape: tuple[int, ...]) -> tuple[int, ...]:
    stride = 1
    result = []
    for extent in reversed(shape):
        result.append(stride)
        stride *= extent
    return tuple(reversed(result))


def coordinates(shape: tuple[int, ...]) -> Iterable[tuple[int, ...]]:
    return product(*(range(extent) for extent in shape))


@dataclass
class Array:
    """Array view used by this model; shape/strides are explicit metadata.

    This record is not a proposed replacement for the existing Lmx descriptor.
    Negative strides describe an explicitly supplied borrowed view, not the
    result of the new language slice syntax, which creates a fresh container.
    """

    storage: list[Any]
    shape: tuple[int, ...]
    element_type: Any = "@"
    offset: int = 0
    strides: tuple[int, ...] | None = None
    dense: bool = True
    admission: Callable[[Any], bool] | None = None

    def __post_init__(self) -> None:
        self.shape = tuple(self.shape)
        if not self.shape:
            raise ShapeDiagnostic("an Array has at least one axis")
        size_of(self.shape)
        if self.strides is None:
            self.strides = row_major_strides(self.shape)
        else:
            self.strides = tuple(self.strides)
        if len(self.strides) != len(self.shape):
            raise ShapeDiagnostic("rank and stride count differ")
        if type(self.offset) is not int or any(type(s) is not int for s in self.strides):
            raise ShapeDiagnostic("offset and strides must be integers")
        if self.size:
            low, high = self.address_interval()
            if low < 0 or high >= len(self.storage):
                raise ShapeDiagnostic("view lies outside its supplied backing")

    @property
    def size(self) -> int:
        return size_of(self.shape)

    @property
    def rank(self) -> int:
        return len(self.shape)

    def address(self, coord: tuple[int, ...]) -> int:
        # Internal prepared-coordinate checker, not the language's scalar
        # suffix-index algorithm. User nD indexing/final-address admission is
        # modelled separately by the Array-storage reference.
        if len(coord) != self.rank or any(i < 0 or i >= n for i, n in zip(coord, self.shape)):
            raise ShapeDiagnostic("invalid logical coordinate")
        return self.offset + sum(i * s for i, s in zip(coord, self.strides))

    def get(self, coord: tuple[int, ...]) -> Any:
        return self.storage[self.address(coord)]

    def set(self, coord: tuple[int, ...], value: Any) -> None:
        self.storage[self.address(coord)] = value

    def values(self) -> list[Any]:
        return [self.get(coord) for coord in coordinates(self.shape)]

    def axis_at(self, index: int) -> Any:
        """Select one logical leading-axis item without allocating row storage.

        A remaining rank is represented by an operation-local descriptor over
        the same backing, not by an Array object inserted into the LMX graph.
        At rank one the stored whole value is returned unchanged.
        """
        if type(index) is not int or index < 0 or index >= self.shape[0]:
            raise ShapeDiagnostic("logical axis index is out of range")
        if self.rank == 1:
            return self.get((index,))
        return Array(self.storage, self.shape[1:], self.element_type,
                     self.offset + index * self.strides[0], self.strides[1:],
                     self.dense, self.admission)

    def flat_coordinate(self, index: int) -> tuple[int, ...]:
        if type(index) is not int or index < 0 or index >= self.size:
            raise ShapeDiagnostic("flat index is out of range")
        result = []
        for stride, extent in zip(row_major_strides(self.shape), self.shape):
            result.append(index // stride)
            index %= stride
        return tuple(result)

    def flat_get(self, index: int) -> Any:
        return self.get(self.flat_coordinate(index))

    def flat_set(self, index: int, value: Any) -> None:
        self.set(self.flat_coordinate(index), value)

    def copy(self) -> Array:
        return Array(self.values(), self.shape, self.element_type, dense=self.dense, admission=self.admission)

    def address_interval(self) -> tuple[int, int]:
        low = high = self.offset
        for extent, stride in zip(self.shape, self.strides):
            delta = (extent - 1) * stride
            low += min(0, delta)
            high += max(0, delta)
        return low, high

    def has_proven_distinct_cells(self) -> bool:
        """A sufficient affine proof, deliberately not an exhaustive solver."""
        if not self.size:
            return True
        span = 1
        for stride, extent in sorted(
            (abs(s), n) for n, s in zip(self.shape, self.strides) if n > 1
        ):
            if stride < span:
                return False
            span += (extent - 1) * stride
        return True


@dataclass
class Metrics:
    output_passes: int = 0
    output_elements: int = 0
    scalar_operations: int = 0
    scalar_calls: int = 0
    array_allocations: int = 0
    reduction_steps: int = 0
    rhs_snapshots: int = 0


@dataclass(frozen=True)
class ScalarProfile:
    """Actual scalar methods and complete result contract supplied by the caller.

    zero supplies the additive identity for an empty contraction. A missing
    complete result requirement means a reference-array result. No first
    element is executed to determine a type. The provider owns numeric context,
    precision, overflow, conversion and failure semantics.
    """

    methods: Mapping[str, Callable[..., Any]]
    result_requirement: Any = None
    zero: Callable[[], Any] | None = None
    pure_methods: frozenset[str] = field(default_factory=frozenset)
    truth: Callable[[Any], bool] = bool
    one: Callable[[], Any] | None = None

    def requirement(self, name: str) -> Any:
        if isinstance(self.result_requirement, Mapping):
            return self.result_requirement.get(name)
        if name in ("=", "!=", "<", "<=", ">", ">="):
            return "int"
        return self.result_requirement

    def apply(self, name: str, args: tuple[Any, ...], metrics: Metrics) -> Any:
        selected = {"+" : "pos", "-" : "neg"}.get(name, name) if len(args) == 1 else name
        method = self.methods.get(selected)
        if method is None:
            raise ProfileDiagnostic(f"scalar profile has no method {name!r}")
        metrics.scalar_operations += 1
        return method(*args)


def python_profile(
    result_requirement: Any = None, zero: Callable[[], Any] | None = lambda: 0
) -> ScalarProfile:
    """Convenience provider for tests, not a definition of LMX numeric semantics."""
    methods = {
        "+": operator.add, "-": operator.sub, "*": operator.mul,
        "/": operator.truediv, "%": operator.mod, "**": operator.pow,
        "<<": operator.lshift, ">>": operator.rshift,
        "&": operator.and_, "|": operator.or_, "^": operator.xor,
        "neg": operator.neg, "pos": operator.pos, "~": operator.invert,
        "=": lambda a, b: int(a == b), "!=": lambda a, b: int(a != b),
        "<": lambda a, b: int(a < b), "<=": lambda a, b: int(a <= b),
        ">": lambda a, b: int(a > b), ">=": lambda a, b: int(a >= b),
    }
    return ScalarProfile(methods, result_requirement, zero, frozenset(methods), one=lambda: 1)


def common_shape(values: Iterable[Any]) -> tuple[int, ...] | None:
    shapes = [value.shape for value in values if isinstance(value, Array)]
    if not shapes:
        return None
    if any(shape != shapes[0] for shape in shapes[1:]):
        raise ShapeDiagnostic("Array shapes must match exactly; no singleton broadcast")
    return shapes[0]


def result_array(
    values: list[Any], shape: tuple[int, ...], requirement: Any, sources: Iterable[Any]
) -> Array:
    dense = requirement is not None and all(
        not isinstance(source, Array) or source.dense for source in sources
    )
    return Array(
        values, shape, requirement if dense else "@", dense=dense
    )


def _component_scalar(
    name: str, *values: Any, profile: ScalarProfile, metrics: Metrics | None = None
) -> Any:
    """Elementwise scalar method, exact shape and scalar expansion only."""
    metrics = metrics if metrics is not None else Metrics()
    name = name[1:] if name.startswith(".") else name
    shape = common_shape(values)
    if shape is None:
        return profile.apply(name, tuple(values), metrics)
    metrics.output_passes += 1
    out = []
    for coord in coordinates(shape):
        args = tuple(value.get(coord) if isinstance(value, Array) else value for value in values)
        out.append(profile.apply(name, args, metrics))
        metrics.output_elements += 1
    metrics.array_allocations += 1
    return result_array(out, shape, profile.requirement(name), values)


def _sum_products(
    pairs: Iterable[tuple[Any, Any]], profile: ScalarProfile, metrics: Metrics
) -> Any:
    have_value = False
    result = None
    for left, right in pairs:
        term = profile.apply("*", (left, right), metrics)
        result = profile.apply("+", (result, term), metrics) if have_value else term
        have_value = True
        metrics.reduction_steps += 1
    if have_value:
        return result
    if profile.zero is None:
        raise ProfileDiagnostic("empty contraction requires the scalar additive identity")
    return profile.zero()


def matmul(
    left: Array, right: Array, *, profile: ScalarProfile, metrics: Metrics | None = None
) -> Any:
    """Ranks 1/2; ordered contraction, no nested-array or higher-rank inference."""
    metrics = metrics if metrics is not None else Metrics()
    if left.rank not in (1, 2) or right.rank not in (1, 2):
        raise RankDiagnostic("ordinary product profile accepts vector/matrix ranks 1 and 2")
    contracted = left.shape[-1]
    if contracted != right.shape[0]:
        raise ShapeDiagnostic("contracted dimensions differ")
    if left.rank == right.rank == 1:
        return _sum_products(
            ((left.get((k,)), right.get((k,))) for k in range(contracted)), profile, metrics
        )
    if left.rank == 2 and right.rank == 2:
        shape = (left.shape[0], right.shape[1])
        pair_for = lambda coord, k: (left.get((coord[0], k)), right.get((k, coord[1])))
    elif left.rank == 2:
        shape = (left.shape[0],)
        pair_for = lambda coord, k: (left.get((coord[0], k)), right.get((k,)))
    else:
        shape = (right.shape[1],)
        pair_for = lambda coord, k: (left.get((k,)), right.get((k, coord[0])))
    metrics.output_passes += 1
    result = []
    for coord in coordinates(shape):
        result.append(_sum_products(
            (pair_for(coord, k) for k in range(contracted)), profile, metrics
        ))
        metrics.output_elements += 1
    metrics.array_allocations += 1
    return result_array(result, shape, profile.requirement("+"), (left, right))


def ordinary(
    name: str, *values: Any, profile: ScalarProfile, metrics: Metrics | None = None
) -> Any:
    """Reference ordinary +, -, *, / and signs; other Array profiles are explicit."""
    metrics = metrics if metrics is not None else Metrics()
    arrays = [value for value in values if isinstance(value, Array)]
    if not arrays:
        return profile.apply(name, tuple(values), metrics)
    if name == "*" and len(values) == 2 and len(arrays) == 2:
        return matmul(values[0], values[1], profile=profile, metrics=metrics)
    if name in ("+", "-", "neg", "pos", "%", "&", "|", "^", "~", "<<", ">>",
                "=", "!=", "<", "<=", ">", ">="):
        return _component_scalar(name, *values, profile=profile, metrics=metrics)
    if name == "*" and len(values) == 2 and len(arrays) == 1:
        return _component_scalar(name, *values, profile=profile, metrics=metrics)
    if name == "/" and len(values) == 2 and isinstance(values[0], Array) and not isinstance(values[1], Array):
        return _component_scalar(name, *values, profile=profile, metrics=metrics)
    raise ProfileDiagnostic(f"no ordinary Array profile for {name!r}; select an explicit operation")


def lift(
    name: str, *values: Any, depth: int = 1, profile: ScalarProfile,
    metrics: Metrics | None = None, has_result: bool = True,
    base: Callable[..., Any] | None = None,
) -> Any:
    """Opt-in VALUE lifting over retained logical axes of flat Array storage.

    An axis slice is a local address/shape descriptor, never an allocated row.
    A stored Structure reference is still the same ordinary value; no separate
    nested-array kind is introduced. Common transport already obtained depth.
    """
    depth = admit_depth(depth)
    metrics = metrics if metrics is not None else Metrics()

    original_arrays = tuple(isinstance(value, Array) for value in values)

    def validate(actuals: tuple[Any, ...], remaining: int) -> None:
        if remaining == 0 or not any(original_arrays):
            return
        descended = [isinstance(value, Array) for value, origin in zip(actuals, original_arrays) if origin]
        if any(descended) != all(descended):
            raise DepthError("original Array operands have incompatible structural depths")
        if not any(descended):
            raise DepthError("requested depth exceeds the actual Array structure")
        arrays = [value for value in actuals if isinstance(value, Array)]
        count = arrays[0].shape[0]
        if any(value.shape[0] != count for value in arrays[1:]):
            raise ShapeDiagnostic("selected logical axis extents must match")
        if count == 0 and remaining > min(value.rank for value in arrays):
            raise DepthError("empty Array description has no requested further axis")
        for index in range(count):
            validate(tuple(value.axis_at(index) if isinstance(value, Array) else value
                           for value in actuals), remaining - 1)

    validate(tuple(values), depth)

    def calls(actuals: tuple[Any, ...], remaining: int, path: tuple[int, ...] = ()):
        arrays = [value for value in actuals if isinstance(value, Array)]
        if remaining == 0 or not arrays:
            yield path, actuals
            return
        for index in range(arrays[0].shape[0]):
            yield from calls(tuple(value.axis_at(index) if isinstance(value, Array) else value
                                   for value in actuals), remaining - 1, path + (index,))

    if depth == 0 or not any(original_arrays):
        value = base(*values) if base is not None else ordinary(name, *values, profile=profile, metrics=metrics)
        return value if has_result else None
    if not has_result:
        for _, actuals in calls(tuple(values), depth):
            if base is not None:
                base(*actuals)
            else:
                ordinary(name, *actuals, profile=profile, metrics=metrics)
        return None

    # Standard numerical profiles determine complete result layout before any
    # scalar callback. Custom host fixtures expose scalar R explicitly here;
    # arbitrary custom array-return contracts need their own preparation hook.
    layout = _lift_layout(name, tuple(layout_of(value) for value in values), depth,
                          profile.requirement(name), custom_scalar=base is not None)
    result = _allocate_result(layout, metrics)
    metrics.output_passes += 1
    for path, actuals in calls(tuple(values), depth):
        value = base(*actuals) if base is not None else ordinary(name, *actuals, profile=profile, metrics=metrics)
        target = _target_at(result, path)
        if isinstance(target, Array):
            if not isinstance(value, Array) or value.shape != target.shape:
                raise ProfileError("base result does not satisfy its prepared complete result shape")
            for coord in coordinates(target.shape):
                target.set(coord, value.get(coord))
                metrics.output_elements += 1
        else:
            target.value = value
            metrics.output_elements += 1
    return result


def dot(
    name: str, *values: Any, profile: ScalarProfile, metrics: Metrics | None = None,
    depth: int | None = None,
) -> Any:
    """Host convenience for one leading dot or an explicit obtained depth.

    This helper does not parse .(EXPR) source and does not decode quoted names.
    Production transport supplies the canonical base name and numerical depth.
    """
    if name.startswith(".."):
        raise ProfileDiagnostic("repeated dots are not depth syntax; use explicit depth")
    if name.startswith("."):
        name = name[1:]
    return lift(name, *values, depth=1 if depth is None else depth,
                profile=profile, metrics=metrics)


@dataclass(frozen=True)
class Value:
    value: Any


@dataclass(frozen=True)
class ScalarCall:
    function: Callable[[], Any]
    label: str = "scalar call"


@dataclass(frozen=True)
class ArrayLiteral:
    """Common-P0 inline [items] after parsing; not a grouping/flatten node."""
    items: tuple[Any, ...]


def array_literal(*items: Any) -> ArrayLiteral:
    return ArrayLiteral(items)


def array_value(items: Iterable[Any], metrics: Metrics | None = None) -> Array:
    values = list(items)
    if metrics is not None:
        metrics.array_allocations += 1
    return Array(values, (len(values),), "@", dense=False)


@dataclass(frozen=True)
class Op:
    name: str
    args: tuple[Any, ...]
    depth: Any = None


@dataclass(frozen=True)
class Select:
    condition: Any
    yes: Any
    no: Any


def op(name: str, *args: Any, depth: Any = None) -> Op:
    return Op(name, args, depth)


def evaluate(
    expression: Any, *, profile: ScalarProfile, metrics: Metrics | None = None,
    obtain_depth: Callable[[Any, Any], Any] | None = None,
) -> Any:
    """Eager evaluation of an already parsed host fixture, not an LMX parser.

    Written grouping and dependency order are retained. ArrayLiteral supplies
    a ready whole Array VALUE; no singleton-group normalization is performed.
    """
    metrics = metrics if metrics is not None else Metrics()
    if isinstance(expression, Value):
        return expression.value
    if isinstance(expression, ScalarCall):
        metrics.scalar_calls += 1
        return expression.function()
    if isinstance(expression, ArrayLiteral):
        return array_value((evaluate(item, profile=profile, metrics=metrics,
                                     obtain_depth=obtain_depth) for item in expression.items), metrics)
    if isinstance(expression, Select):
        condition = evaluate(expression.condition, profile=profile, metrics=metrics, obtain_depth=obtain_depth)
        if isinstance(condition, Array):
            raise ProfileDiagnostic("ternary condition must be scalar")
        return evaluate(expression.yes if profile.truth(condition) else expression.no,
                        profile=profile, metrics=metrics, obtain_depth=obtain_depth)
    if isinstance(expression, Op):
        name, source_depth = _operator_depth(expression.name, expression.depth)
        depth = resolve_depth(source_depth, obtain_depth or (
            lambda node, context: evaluate(node, profile=profile, metrics=metrics)))
        values = tuple(evaluate(item, profile=profile, metrics=metrics, obtain_depth=obtain_depth)
                       for item in expression.args)
        return lift(name, *values, depth=depth, profile=profile, metrics=metrics)
    return expression


@dataclass(frozen=True)
class Layout:
    """Operation-local shape metadata; no copied scalar program or values.

    source describes an actual input Array lazily. Computed children describe
    only result container boundaries; None children means scalar leaves.
    """
    shape: tuple[int, ...]
    source: Array | None = None
    children: tuple[Layout | None, ...] | None = None
    requirement: Any = None
    reference: bool = False

    def child(self, coord: tuple[int, ...]) -> Layout | None:
        if self.source is not None:
            value = self.source.get(coord)
            return layout_of(value)
        if self.children is None:
            return None
        flat = sum(i * stride for i, stride in zip(coord, row_major_strides(self.shape)))
        return self.children[flat]

    def axis_child(self, index: int, *, prototype: bool = False) -> Layout | None:
        if len(self.shape) > 1:
            if self.source is not None and not prototype:
                return layout_of(self.source.axis_at(index))
            count = size_of(self.shape[1:])
            return Layout(self.shape[1:], children=(
                self.children[index * count:(index + 1) * count]
                if self.children is not None else None),
                requirement=self.requirement, reference=self.reference)
        if prototype:
            return None
        return self.child((index,))


def layout_of(value: Any) -> Layout | None:
    if not isinstance(value, Array):
        return None
    return Layout(value.shape, source=value,
                  requirement=value.element_type if value.dense else None,
                  reference=not value.dense)


@dataclass(frozen=True)
class Prepared:
    shape: tuple[int, ...] | None
    value: Any = None
    name: str | None = None
    args: tuple[Prepared, ...] = ()
    arrays: tuple[Array, ...] = ()
    requirement: Any = None
    layout: Layout | None = None
    depth: int = 0


def _operator_depth(name: str, explicit: Any) -> tuple[str, Any]:
    if name.startswith(".."):
        raise FusionDiagnostic("repeated dots are not depth syntax")
    dotted = name.startswith(".")
    base = name[1:] if dotted else name
    return base, (1 if dotted else 0) if explicit is None else explicit


def _ordinary_layout(name: str, layouts: tuple[Layout | None, ...], requirement: Any,
                     *, fused: bool) -> Layout | None:
    arrays = [layout for layout in layouts if layout is not None]
    if not arrays:
        return None
    if name == "*" and len(arrays) == 2:
        if fused:
            raise FusionDiagnostic("matrix/vector contraction is not a per-leaf fused operation")
        left, right = arrays
        lr, rr = len(left.shape), len(right.shape)
        if lr not in (1, 2) or rr not in (1, 2):
            raise RankDiagnostic("ordinary contraction requires rank one or two")
        inner = left.shape[-1]
        if inner != right.shape[0]:
            raise ShapeDiagnostic("contraction inner extents differ")
        shape = (() if lr == rr == 1 else
                 (left.shape[0], right.shape[1]) if lr == rr == 2 else
                 (left.shape[0],) if lr == 2 else (right.shape[1],))
        return Layout(shape, requirement=requirement,
                      reference=any(layout.reference for layout in arrays)) if shape else None
    shape = arrays[0].shape
    if any(layout.shape != shape for layout in arrays[1:]):
        raise ShapeDiagnostic("the selected base Array profile requires equal complete shapes")
    if name not in ("+", "-", "*", "neg", "pos", "/", "%", "&", "|", "^",
                    "~", "<<", ">>", "=", "!=", "<", "<=", ">", ">="):
        raise ProfileDiagnostic(f"ordinary {name!r} has no admitted whole-Array profile")
    if name == "/" and (len(layouts) != 2 or layouts[0] is None or layouts[1] is not None):
        raise ProfileDiagnostic("only ordinary Array/scalar division is componentwise")
    if fused:
        for coord in coordinates(shape):
            if any(layout.child(coord) is not None for layout in arrays):
                raise FusionDiagnostic("a base scalar method would receive a Structure; select its depth/profile")
    return Layout(shape, requirement=requirement,
                  reference=any(layout.reference for layout in arrays))


def _lift_layout(
    name: str, layouts: tuple[Layout | None, ...], depth: int, requirement: Any,
    origins: tuple[bool, ...] | None = None, *, fused: bool = False,
    custom_scalar: bool = False,
) -> Layout | None:
    origins = tuple(layout is not None for layout in layouts) if origins is None else origins
    descended = [layout is not None for layout, origin in zip(layouts, origins) if origin]
    if depth and descended and any(descended) != all(descended):
        raise DepthError("original Array operands reach different required logical levels")
    if depth and descended and not any(descended):
        raise DepthError("requested depth exceeds the available logical axes")
    arrays = [layout for layout in layouts if layout is not None]
    if not arrays:
        return None  # Only original scalar operands are positive-depth fixed points.
    if depth == 0:
        return None if custom_scalar else _ordinary_layout(name, layouts, requirement, fused=fused)
    count = arrays[0].shape[0]
    if any(layout.shape[0] != count for layout in arrays[1:]):
        raise ShapeDiagnostic("selected logical axis extents must match; no singleton broadcast")
    children = tuple(
        _lift_layout(name, tuple(layout.axis_child(index) if layout is not None else None
                                for layout in layouts), depth - 1, requirement, origins,
                     fused=fused, custom_scalar=custom_scalar)
        for index in range(count)
    )
    prototype = children[0] if children else _lift_layout(
        name, tuple(layout.axis_child(0, prototype=True) if layout is not None else None
                    for layout in layouts), depth - 1, requirement, origins,
        fused=fused, custom_scalar=custom_scalar)
    # Preserve known flat axes; never infer them from a set of stored Structure
    # references. Only existing rank/extents or a base result contract permit
    # composing a rectangular output description.
    if any(len(layout.shape) > 1 for layout in arrays) and prototype is not None:
        if any(child is None or child.shape != prototype.shape for child in children):
            raise ShapeDiagnostic("selected base results do not form the prepared rectangular output")
        physical_children = tuple(
            descendant for child in children for descendant in (
                child.children if child.children is not None else (None,) * size_of(child.shape)
            )
        )
        return Layout((count,) + prototype.shape,
                      children=physical_children if any(c is not None for c in physical_children) else None,
                      requirement=prototype.requirement,
                      reference=any(layout.reference for layout in arrays) or prototype.reference)
    has_children = any(child is not None for child in children)
    return Layout((count,), children=children if has_children else None,
                  requirement=requirement if not has_children else None,
                  reference=has_children or any(layout.reference for layout in arrays))


def _prepare(
    node: Any, profile: ScalarProfile, metrics: Metrics,
    obtain_depth: Callable[[Any, Any], Any] | None = None,
) -> Prepared:
    if isinstance(node, Value):
        node = node.value
    if isinstance(node, ArrayLiteral):
        node = evaluate(node, profile=profile, metrics=metrics, obtain_depth=obtain_depth)
    if isinstance(node, ScalarCall):
        metrics.scalar_calls += 1
        value = node.function()
        if isinstance(value, Array):
            raise FusionDiagnostic("a scalar-call capture returned an Array")
        return Prepared(None, value=value)
    if isinstance(node, Select):
        condition = _prepare(node.condition, profile, metrics, obtain_depth)
        if condition.shape is not None:
            raise FusionDiagnostic("ternary condition must be scalar, not an implicit mask")
        flag = profile.truth(_cell(condition, (), profile, metrics, {}))
        return _prepare(node.yes if flag else node.no, profile, metrics, obtain_depth)
    if isinstance(node, Op):
        name, source_depth = _operator_depth(node.name, node.depth)
        def obtain(expression: Any, context: Any) -> Any:
            if obtain_depth is not None:
                return obtain_depth(expression, context)
            prepared = _prepare(expression, profile, metrics, obtain_depth)
            if prepared.layout is not None:
                raise FusionDiagnostic("depth expression must return a scalar integer")
            return _cell(prepared, (), profile, metrics, {})
        depth = resolve_depth(source_depth, obtain)
        args = tuple(_prepare(arg, profile, metrics, obtain_depth) for arg in node.args)
        if all(arg.layout is None for arg in args):
            value = profile.apply(name, tuple(_cell(arg, (), profile, metrics, {}) for arg in args), metrics)
            if isinstance(value, Array):
                raise FusionDiagnostic("a scalar subtree returned an Array")
            return Prepared(None, value=value)
        selected = {"+": "pos", "-": "neg"}.get(name, name) if len(args) == 1 else name
        if selected not in profile.pure_methods or selected not in profile.methods:
            raise FusionDiagnostic(f"{node.name!r} is not a proven pure scalar operation")
        requirement = profile.requirement(name)
        layout = _lift_layout(name, tuple(arg.layout for arg in args), depth, requirement, fused=True)
        arrays = tuple(array for arg in args for array in arg.arrays)
        return Prepared(layout.shape, name=name, args=args, arrays=arrays,
                        requirement=requirement, layout=layout, depth=depth)
    if isinstance(node, Array):
        return Prepared(node.shape, value=node, arrays=(node,),
                        requirement=node.element_type if node.dense else None,
                        layout=layout_of(node))
    return Prepared(None, value=node)


def _trim_path(layout: Layout | None, path: tuple[int, ...]) -> tuple[int, ...]:
    retained = []
    for index in path:
        if layout is None:
            break
        retained.append(index)
        layout = layout.axis_child(index)
    return tuple(retained)


def _cell(
    plan: Prepared, path: tuple[int, ...], profile: ScalarProfile,
    metrics: Metrics, cache: dict[int, tuple[Any, Any]],
) -> Any:
    path = _trim_path(plan.layout, path)
    if plan.name is not None:
        # One scalar register per written occurrence is enough for ordered DFS.
        # A shallower scalar result broadcast into children is not recomputed.
        old = cache.get(id(plan))
        if old is not None and old[0] == path:
            return old[1]
        value = profile.apply(
            plan.name, tuple(_cell(arg, path, profile, metrics, cache) for arg in plan.args), metrics
        )
        cache[id(plan)] = (path, value)
        return value
    value = plan.value
    for index in path:
        if not isinstance(value, Array):
            break
        value = value.axis_at(index)
    return value


def _leaf_paths(layout: Layout, path: tuple[int, ...] = ()):
    for index in range(layout.shape[0]):
        child = layout.axis_child(index)
        if child is None:
            yield path + (index,)
        else:
            yield from _leaf_paths(child, path + (index,))


def _read_addresses(plan: Prepared, path: tuple[int, ...]):
    path = _trim_path(plan.layout, path)
    if plan.name is not None:
        for arg in plan.args:
            yield from _read_addresses(arg, path)
        return
    value = plan.value
    for index in path:
        if not isinstance(value, Array):
            break
        if value.rank == 1:
            yield id(value.storage), value.address((index,))
        value = value.axis_at(index)


def _target_at(target: Array, path: tuple[int, ...]) -> Any:
    if not path:
        return target
    for index in path[:-1]:
        target = target.axis_at(index)
        if not isinstance(target, Array):
            raise ShapeDiagnostic("destination lacks the selected logical level")
    return target.axis_at(path[-1]) if target.rank > 1 else ArrayPlace(target, (path[-1],))


def _place_at(target: Array, path: tuple[int, ...]) -> ArrayPlace:
    result = _target_at(target, path)
    if not isinstance(result, ArrayPlace):
        raise ShapeDiagnostic("leaf path selects a whole logical region")
    return result


def _destination_layout(
    target: Array, depth: int, source: Layout | None, original_scalar: bool | None = None
) -> Layout:
    original_scalar = source is None if original_scalar is None else original_scalar
    if depth == 0:
        raise FusionDiagnostic("fused element output requires a positive destination depth")
    if source is not None and target.shape[0] != source.shape[0]:
        raise ShapeDiagnostic("fused destination extent differs at a selected logical axis")
    children = []
    for index in range(target.shape[0]):
        child_source = source.axis_child(index) if source is not None else None
        value = target.axis_at(index)
        if depth > 1:
            if not isinstance(value, Array):
                raise DepthError("fused destination has no requested deeper Array level")
            if child_source is None and not original_scalar:
                raise DepthError("an Array-derived scalar cannot broadcast into a deeper destination")
            children.append(_destination_layout(value, depth - 1, child_source, original_scalar))
        elif target.rank > 1:
            if child_source is None or value.shape != child_source.shape:
                raise ShapeDiagnostic("a logical region requires a compatible complete block")
            children.append(Layout(value.shape, requirement=child_source.requirement,
                                   reference=child_source.reference))
        else:
            if child_source is not None:
                raise FusionDiagnostic("destination depth stops before a computed Array; no implicit deep write")
            children.append(None)
    if target.rank > 1:
        physical = tuple(child for item in children for child in (
            item.children if item.children is not None else (None,) * size_of(item.shape)))
        return Layout(target.shape, children=physical if any(c is not None for c in physical) else None)
    return Layout(target.shape, children=tuple(children) if any(c is not None for c in children) else None)


def _allocate_result(layout: Layout, metrics: Metrics) -> Array:
    result = Array([None] * size_of(layout.shape), layout.shape,
                   layout.requirement if layout.requirement is not None and not layout.reference else "@",
                   dense=layout.requirement is not None and not layout.reference)
    metrics.array_allocations += 1
    for coord in coordinates(layout.shape):
        child = layout.child(coord)
        if child is not None:
            result.set(coord, _allocate_result(child, metrics))
    return result


def _validate_fused_aliases(target: Array, layout: Layout, plan: Prepared) -> None:
    positions = {}
    for output_index, path in enumerate(_leaf_paths(layout)):
        place = _place_at(target, path)
        address = (id(place.array.storage), place.array.address(place.coordinate))
        if address in positions:
            raise AliasDiagnostic("fused destination contains repeated actual places")
        positions[address] = output_index
    for output_index, path in enumerate(_leaf_paths(layout)):
        for address in _read_addresses(plan, path):
            if address in positions and positions[address] != output_index:
                raise AliasDiagnostic("cross-coordinate overlap requires an explicit source snapshot")


def fuse(
    expression: Any, *, profile: ScalarProfile, destination: Array | None = None,
    destination_depth: int = 1, metrics: Metrics | None = None,
    obtain_depth: Callable[[Any, Any], Any] | None = None,
) -> Any:
    """One leaf-output traversal, with shared source expressions and local shape metadata.

    destination/depth model explicit assignment lowering, not extra public fuse
    parameters. All result containers are result storage; no per-operator Array
    intermediates or copied program trees are made. A scalar register is reused
    when a shallower result broadcasts into several descendant leaves.
    """
    metrics = metrics if metrics is not None else Metrics()
    plan = _prepare(expression, profile, metrics, obtain_depth)
    cache: dict[int, tuple[Any, Any]] = {}
    if destination is None and plan.layout is None:
        return _cell(plan, (), profile, metrics, cache)
    if destination is not None:
        layout = _destination_layout(destination, admit_depth(destination_depth), plan.layout)
        _validate_fused_aliases(destination, layout, plan)
        result = destination
    else:
        layout = plan.layout
        if plan.name is None and isinstance(plan.value, Array):
            # A ready Array expression copies immediate slots only; it does not
            # request unbounded recursive traversal of arbitrary reference graphs.
            layout = Layout(plan.value.shape, requirement=plan.requirement,
                            reference=not plan.value.dense)
        result = _allocate_result(layout, metrics)
    metrics.output_passes += 1
    for path in _leaf_paths(layout):
        value = _cell(plan, path, profile, metrics, cache)
        place = _place_at(result, path)
        if not place.admits(value):
            raise ProfileError("fused destination rejects this leaf after the written prefix")
        place.value = value
        metrics.output_elements += 1
    return result

def assign(
    destination: Array, value: Any, *, depth: int = 1, metrics: Metrics | None = None
) -> Array:
    """Element assignment at an explicitly selected actual nesting depth."""
    return assign_depth(destination, value, depth=depth, metrics=metrics)


def compound(
    destination: Array, name: str, value: Any, *,
    profile: ScalarProfile, metrics: Metrics | None = None, depth: int = 1,
) -> Array:
    """A depth-selected compound update reuses base arithmetic and assignment."""
    metrics = metrics if metrics is not None else Metrics()
    base = name[:-1] if name.endswith("=") else name
    actual = destination.value if isinstance(destination, (Cell, ArrayPlace)) else destination
    result = dot(base, actual, value, profile=profile, metrics=metrics, depth=depth)
    return assign_depth(destination, result, metrics=metrics, depth=depth)


@dataclass
class Cell:
    """A real execution place, not a copy of its current value."""
    value: Any
    admits: Callable[[Any], bool] = lambda value: True

    def put(self, value: Any) -> None:
        if not self.admits(value):
            raise ProfileError("the destination place rejects this value")
        self.value = value


@dataclass
class ArrayPlace:
    """An actual Array slot used by deep assignment; it is not a value copy."""
    array: Array
    coordinate: tuple[int, ...]

    @property
    def value(self) -> Any:
        return self.array.get(self.coordinate)

    @value.setter
    def value(self, value: Any) -> None:
        self.array.set(self.coordinate, value)

    def admits(self, value: Any) -> bool:
        return self.array.admission(value) if self.array.admission is not None else True


@dataclass(frozen=True)
class RegionPlace:
    """A transient PLACE descriptor for a logical flat-storage block.

    There is no independently rebindable row-reference slot in flat storage.
    Whole base assignment admits a compatible block and writes its real cells.
    """
    array: Array

    @property
    def value(self) -> Array:
        return self.array


def _commit_writes(writes: list[tuple[Any, Any]], metrics: Metrics) -> None:
    # Every selected RHS value is already retained. Admit all places before
    # the first write, including places reached in a later nested branch.
    for place, value in writes:
        if not place.admits(value):
            raise ProfileError("a destination rejects its value before the write phase")
    metrics.rhs_snapshots += 1
    metrics.output_passes += 1
    for place, value in writes:
        place.value = value
        metrics.output_elements += 1


def assign_depth(
    destination: Any, value: Any, *, depth: int = 1, metrics: Metrics | None = None
) -> Any:
    """Snapshot all selected RHS leaves, admit all real places, then write.

    Whole depth-0 rebinding requires a Cell/ArrayPlace. An Array object by itself
    is a value, not the reference-variable place that points at that value.
    Depth selects logical axes. At rank two, depth one selects real row regions
    and depth two scalar places. Stored Structure references remain ordinary
    whole values; depth zero of a binding place still rebinds that place.
    """
    depth = admit_depth(depth)
    metrics = metrics if metrics is not None else Metrics()
    writes: list[tuple[Any, Any]] = []
    original_scalar_source = not isinstance(value, Array)
    original_target = destination.value if isinstance(destination, (Cell, ArrayPlace)) else destination
    original_array_target = isinstance(original_target, Array)

    def collect(target: Any, source: Any, remaining: int) -> None:
        actual = target.value if isinstance(target, (Cell, ArrayPlace, RegionPlace)) else target
        if remaining and isinstance(actual, Array):
            if not isinstance(source, Array) and not original_scalar_source:
                raise DepthError("an Array-derived scalar cannot invent assignment broadcasting")
            if isinstance(source, Array) and source.shape[0] != actual.shape[0]:
                raise ShapeDiagnostic("assignment extents must match at each selected logical axis")
            if actual.shape[0] == 0 and remaining > actual.rank:
                raise DepthError("empty target description has no further logical axis")
            for index in range(actual.shape[0]):
                item = source.axis_at(index) if isinstance(source, Array) else source
                place = (RegionPlace(actual.axis_at(index)) if actual.rank > 1
                         else ArrayPlace(actual, (index,)))
                collect(place, item, remaining - 1)
            return
        if isinstance(target, RegionPlace):
            if not isinstance(source, Array):
                raise ProfileError("a scalar does not satisfy whole logical-region admission")
            if source.shape != actual.shape:
                raise ShapeDiagnostic("logical-region assignment requires the same complete block shape")
            for coord in coordinates(actual.shape):
                writes.append((ArrayPlace(actual, coord), source.get(coord)))
            return
        if not isinstance(target, (Cell, ArrayPlace)):
            raise ProfileDiagnostic("whole assignment requires a real binding/slot place")
        if remaining and original_array_target:
            raise DepthError("assignment depth exceeds the actual target structure")
        if remaining and isinstance(source, Array):
            raise ShapeDiagnostic("a scalar target cannot invent an Array level")
        writes.append((target, source))

    collect(destination, value, depth)
    _commit_writes(writes, metrics)
    return destination.value if isinstance(destination, (Cell, ArrayPlace)) else destination


def assign_places(
    destinations: Iterable[Cell], sources: Iterable[Any], *, metrics: Metrics | None = None
) -> tuple[Cell, ...]:
    """Model (a b c) .: (b c a): capture places, capture values, then write."""
    metrics = metrics if metrics is not None else Metrics()
    places = tuple(destinations)
    if any(not isinstance(place, Cell) for place in places):
        raise ProfileDiagnostic("the left group must contain real writable places")
    captured = []
    for source in sources:
        if isinstance(source, Cell):
            captured.append(source.value)
        elif isinstance(source, ScalarCall):
            metrics.scalar_calls += 1
            captured.append(source.function())
        else:
            captured.append(source)
    # This is the .: consumer's selected-axis rule. It is not a second
    # Expression grouping pass and does not recursively flatten siblings.
    if len(captured) == 1 and isinstance(captured[0], Array):
        source = captured[0]
        captured = [source.axis_at(index) for index in range(source.shape[0])]
        if source.rank > 1:
            # A whole row escaping into an ordinary binding value is an actual
            # required result, unlike an internal traversal descriptor.
            captured = [value.copy() for value in captured]
            metrics.array_allocations += len(captured)
    elif len(captured) == 1:
        captured = captured * len(places)
    if len(places) != len(captured):
        raise ShapeDiagnostic("place and value counts differ")
    _commit_writes(list(zip(places, captured)), metrics)
    return places


def capture_depth(value: Any, depth: int) -> Any:
    """Value snapshot of selected container levels, retaining deeper references."""
    memo = {}
    def capture(actual: Any, remaining: int) -> Any:
        if remaining == 0 or not isinstance(actual, Array):
            return actual
        key = id(actual), remaining
        if key in memo:
            return memo[key]
        copied = Array([None] * actual.size, actual.shape, actual.element_type,
                       dense=actual.dense, admission=actual.admission)
        memo[key] = copied
        for coord in coordinates(actual.shape):
            copied.set(coord, capture(actual.get(coord), max(0, remaining - actual.rank)))
        return copied
    return capture(value, admit_depth(depth))


def increment(
    destination: Any, *, profile: ScalarProfile, decrement: bool = False,
    postfix: bool = False, depth: int = 1, metrics: Metrics | None = None,
) -> Any:
    """One shared prefix/postfix update at the selected actual nesting depth."""
    depth = admit_depth(depth)
    metrics = metrics if metrics is not None else Metrics()
    actual = destination.value if isinstance(destination, (Cell, ArrayPlace)) else destination
    previous = capture_depth(actual, depth)
    metrics.rhs_snapshots += 1
    if not isinstance(actual, Array) or actual.size:
        if profile.one is None:
            raise ProfileDiagnostic("increment requires the scalar profile's unit")
        unit = profile.one()
        name = "-" if decrement else "+"
        updated = lift(name, previous, unit, depth=depth, profile=profile, metrics=metrics)
        assign_depth(destination, updated, depth=depth, metrics=metrics)
    current = destination.value if isinstance(destination, (Cell, ArrayPlace)) else destination
    return previous if postfix else current
