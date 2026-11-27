"""Focused Array indexing/initializer model, not production P0 or LMX runtime.

Array is the shared host model. Its shape is service metadata, not a proposed
Lmx header field. InitializerGroup consumes row regions ALREADY delimited by
common P0; no source scanner, semicolon parser, or second graph is created.
"""
from dataclasses import dataclass
from typing import Any, Callable

from array_expression_reference import (
    Array, RankDiagnostic, ShapeDiagnostic, array_value, row_major_strides, shape_from_type, array_type,
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
    if array.shape is not None and array.strides != row_major_strides(array.shape):
        raise NotImplementedError("this reference entry models contiguous owning storage")
    if len(indices) == 1:
        linear = indices[0]
    elif len(indices) == array.rank:
        linear = 0
        for index, extent in zip(indices, array.require_shape()):
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
                 admission=array.admission, type_axes=(None,))


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
    *, axes: tuple | None = None,
) -> Array:
    """Validate anonymous initializer Structures, then publish only declared TYPE.

    Constructor row extents are validation evidence, never retained hidden
    dimensions. Equal []int declarations share a canonical type irrespective
    of length. Dynamic extents arrive already obtained through common P0.
    """
    if type(rank) is not int or rank < 1:
        raise RankDiagnostic('initializer rank must be a positive integer')
    axes = (None,) * rank if axes is None else tuple(axes)
    if len(axes) != rank:
        raise RankDiagnostic('declared extent count differs from Array rank')
    declared_type = array_type(element_type, axes)
    leaves = []
    extents = list(axes)
    counts = [None] * rank

    def flatten(group):
        for item in group.items:
            if isinstance(item, InitializerGroup):
                flatten(item)
            else:
                leaves.append(item)

    def collect(group, axis):
        start = len(leaves)
        child_count = sum(isinstance(item, InitializerGroup) for item in group.items)
        if child_count:
            if child_count != len(group.items) or axis + 1 == rank:
                raise ShapeDiagnostic('inconsistent explicit Structure nesting')
            extent = extents[axis]
            if extent is not None and extent != child_count:
                raise ShapeDiagnostic('explicit Structures contradict an axis extent')
            extents[axis] = child_count
            for child in group.items:
                collect(child, axis + 1)
        else:
            leaves.extend(group.items)
        count = len(leaves) - start
        if counts[axis] is not None and counts[axis] != count:
            raise ShapeDiagnostic('sibling Structures must describe the same shape')
        counts[axis] = count

    if not isinstance(region, InitializerGroup):
        raise ShapeDiagnostic('initializer Structure required')
    if rank == 1:
        flatten(region)
    else:
        collect(region, 0)
        for axis, count in enumerate(counts):
            if count is not None:
                shape_from_type(extents[axis:], count)
    retained_shape = shape_from_type(axes, len(leaves))
    values = []
    for leaf in leaves:
        value = (obtain(leaf.node, leaf.context) if isinstance(leaf, ValueOccurrence)
                 else obtain(leaf, None))
        if not admit(value):
            raise ValueError('element rejected by its existing requirement')
        values.append(value)
    result = Array(values, retained_shape, element_type, admission=admit,
                   type_axes=axes, length=len(values))
    assert result.type_descriptor is declared_type
    return result
