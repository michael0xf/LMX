"""Focused Array indexing/initializer model, not production P0 or LMX runtime.

Array is the shared host model. Its shape is service metadata, not a proposed
Lmx header field. InitializerGroup consumes row regions ALREADY delimited by
common P0; no source scanner, semicolon parser, or second graph is created.
"""
from dataclasses import dataclass
from typing import Any, Callable

from array_expression_reference import (
    Array, RankDiagnostic, ShapeDiagnostic, array_value, row_major_strides,
)
from ternary_slices_reference import SliceSpec, normalize_slice


def scalar_offset(array: Array, indices, *, checked=True) -> int:
    """One flat index or complete coordinates, preserving final-index policy.

    This focused entry models the owning contiguous C-storage profile.
    Array.address() is an internal checked-coordinate helper; applying it to
    user coordinates would incorrectly introduce per-axis upper-bound checks.
    unchecked returns an offset only, never performs an unsafe memory access.
    """
    indices = tuple(indices)
    if any(type(index) is not int for index in indices):
        raise RankDiagnostic("scalar indexes require integer values")
    if array.strides != row_major_strides(array.shape):
        raise NotImplementedError("this reference entry models contiguous owning storage")
    if len(indices) == 1:
        linear = indices[0]
    elif len(indices) == array.rank:
        linear = 0
        for index, extent in zip(indices, array.shape):
            linear = linear * extent + index
    else:
        raise RankDiagnostic("use one flat index or the complete coordinate vector")
    if checked and not 0 <= linear < array.size:
        raise ShapeDiagnostic("final Array index is outside length")
    return array.offset + linear


def flat_selection(array: Array, spec: SliceSpec) -> Array:
    """Fresh rank-one selection; source metadata and element identity remain.

    Bounds use the one existing slice normalizer. No reshape or source copy is
    needed simply to select the flat consumer; only the requested result is new.
    """
    plan = normalize_slice(array.size, spec)
    values = [array.storage[scalar_offset(array, (i,))] for i in plan.indices()]
    return Array(values, (plan.count,), array.element_type, dense=array.dense,
                 admission=array.admission)


@dataclass(frozen=True)
class ValueOccurrence:
    node: Any
    context: Any = None


@dataclass(frozen=True)
class InitializerGroup:
    """A view of a complete existing initializer/row region with its origin.

    Both semicolon-delimited and explicitly grouped rows provide this view.
    Source spelling is retained in origin but does not choose an algorithm.
    A call/string leaf remains opaque, including any internal semicolons.
    """
    items: tuple[Any, ...]
    origin: Any = None


def ordinary_structure(
    region: InitializerGroup, obtain: Callable[[Any, Any], Any],
) -> Array:
    """Consume ordinary anonymous DATA fields without a rectangular contract.

    Source groups are already ordinary graph regions. Their origin is only
    provenance and never chooses this behavior. Already obtained Array values
    remain whole fields; there is no nested-Array kind or singleton unwrapping.
    """
    def field(item):
        if isinstance(item, InitializerGroup):
            return ordinary_structure(item, obtain)
        if isinstance(item, ValueOccurrence):
            return obtain(item.node, item.context)
        return obtain(item, None)

    return array_value([field(item) for item in region.items])


def typed_initializer(
    region: InitializerGroup, rank: int, element_type: Any,
    obtain: Callable[[Any, Any], Any], admit: Callable[[Any], bool],
) -> Array:
    """Consume an already-delimited rectangular initializer into one store.

    Row/layer groups are source regions, not newly allocated Array values.
    Static shape preparation never obtains a leaf. Ordinary namespace obtaining
    and actual T admission happen once per leaf in source order afterwards.
    Explicit copy/merge streams require their existing stream integration; this
    small model does not guess a stream from an ordinary Array VALUE.
    """
    if type(rank) is not int or rank < 1:
        raise RankDiagnostic("initializer rank must be a positive integer")
    leaves = []

    def topology(group, remaining):
        if not isinstance(group, InitializerGroup):
            raise ShapeDiagnostic("missing initializer region at the declared rank")
        if remaining == 1:
            leaves.extend(group.items)
            return (len(group.items),)
        if not group.items:
            raise ShapeDiagnostic("empty outer region needs a complete remaining shape")
        shapes = [topology(child, remaining - 1) for child in group.items]
        if any(shape != shapes[0] for shape in shapes[1:]):
            raise ShapeDiagnostic("initializer rows must have equal shapes")
        return (len(group.items),) + shapes[0]

    shape = topology(region, rank)
    values = []
    for leaf in leaves:
        value = (obtain(leaf.node, leaf.context) if isinstance(leaf, ValueOccurrence)
                 else obtain(leaf, None))
        if not admit(value):
            raise ValueError("element rejected by its existing requirement")
        values.append(value)
    return Array(values, shape, element_type, admission=admit)
