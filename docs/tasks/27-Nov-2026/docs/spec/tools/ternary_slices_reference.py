"""Executable contract model for LMX conditional expressions and slices.

This is NOT the production LMX parser, translator, or runtime. It consumes
already separated structural occurrences or ready values. It never parses LMX
text, clones a source graph, changes parent links, or evaluates an unused arm.
Python's slice implementation is intentionally not used by the normalizer.
"""
from dataclasses import dataclass
from enum import Enum, auto
from typing import Any, Callable

OMITTED = object()


class SliceFailure(ValueError):
    def __init__(self, code: str, message: str):
        self.code = code
        super().__init__(message)


def integer(value, name):
    if type(value) is not int:
        raise SliceFailure("SequenceElement", f"{name} must be an exact integer")
    return value


@dataclass(frozen=True)
class SliceSpec:
    """Host model of an ordinary description with three independently absent fields.

    OMITTED models absence in this explicit description, not null, zero,
    a user value, or an opportunity for dynamic autofill.
    """
    start: Any = OMITTED
    stop: Any = OMITTED
    step: Any = OMITTED


@dataclass(frozen=True)
class SlicePlan:
    start: int
    stop: int
    step: int
    count: int

    def indices(self):
        # No addition is performed after the last admitted index.
        at = self.start
        for position in range(self.count):
            yield at
            if position + 1 < self.count:
                at += self.step


def normalize_slice(length: int, spec: SliceSpec, *, max_length=None) -> SlicePlan:
    """Normalize Python-style half-open bounds using exact signed arithmetic."""
    length = integer(length, "length")
    if length < 0:
        raise SliceFailure("SequenceSize", "negative source length")
    step = 1 if spec.step is OMITTED else integer(spec.step, "step")
    if step == 0:
        raise SliceFailure("SequenceStep", "slice step is zero")
    lower, upper = (0, length) if step > 0 else (-1, length - 1)

    def bound(value, default, name):
        if value is OMITTED:
            return default
        value = integer(value, name)
        if value < 0:
            value += length
        return min(upper, max(lower, value))

    start = bound(spec.start, 0 if step > 0 else length - 1, "start")
    stop = bound(spec.stop, length if step > 0 else -1, "stop")
    if step > 0:
        count = 0 if start >= stop else 1 + (stop - start - 1) // step
    else:
        count = 0 if start <= stop else 1 + (start - stop - 1) // (-step)
    if max_length is not None and count > max_length:
        raise SliceFailure("SequenceSize", "result exceeds allocation limit")
    return SlicePlan(start, stop, step, count)


def strict_slice_plan(length: int, begin: int, end: int) -> SlicePlan:
    """Existing three-actual slice profile: bounds are validated, never clipped."""
    length, begin, end = (integer(v, n) for v, n in
                          ((length, "length"), (begin, "begin"), (end, "end")))
    if not 0 <= begin <= end <= length:
        raise SliceFailure("ReceiverIndex", "invalid strict half-open interval")
    return SlicePlan(begin, end, 1, end - begin)


def collect_selection(source, plan: SlicePlan):
    """Shared selection body: fresh outer container, same immediate references."""
    return [source[index] for index in plan.indices()]


def slice_values(source, spec: SliceSpec):
    return collect_selection(source, normalize_slice(len(source), spec))


def strict_slice_values(source, begin, end):
    return collect_selection(source, strict_slice_plan(len(source), begin, end))


def scalar_index_offset(length: int, index: int, *, checked=True):
    """Return an offset, never a from-end transformation.

    checked=False models only native L2 offset computation. It does NOT read
    memory and does not claim that a negative or out-of-bounds access is safe.
    """
    integer(index, "index")
    if checked and not 0 <= index < length:
        raise SliceFailure("ReceiverIndex", "scalar index outside array")
    return index


def check_known_scalar_index(index: int):
    """Translation-time admission for a ready scalar index in any level."""
    if integer(index, "index") < 0:
        raise SliceFailure("ReceiverIndex", "known negative scalar index")
    return index


@dataclass(frozen=True)
class RawOccurrence:
    obtain: Callable[[], Any]
    context: Any = None
    origin: Any = None


def conditional(condition: RawOccurrence, yes: RawOccurrence,
                no: RawOccurrence):
    """Same method body for a ? b : c and the canonical ?: receiver."""
    truth = condition.obtain()
    if type(truth) is not int:
        raise SliceFailure("FxPredicate", "condition must satisfy int truth contract")
    return (yes if truth != 0 else no).obtain()


def evaluated_slice(source: RawOccurrence, start=OMITTED, stop=OMITTED,
                    step=OMITTED):
    """Evaluate source, then present bounds once in written order.

    The actual source length is obtained after bound effects. No storage
    pointer captured before those effects is reused.
    """
    target = source.obtain()
    ready = []
    for name, field in zip(("start", "stop", "step"), (start, stop, step)):
        ready.append(OMITTED if field is OMITTED else integer(field.obtain(), name))
    return slice_values(target, SliceSpec(*ready))


@dataclass(frozen=True)
class SlicePlace:
    """Operation-local destination view, not a new runtime array kind."""
    source: list
    plan: SlicePlan
    original_length: int


def slice_place(source: list, spec: SliceSpec):
    return SlicePlace(source, normalize_slice(len(source), spec), len(source))


def assign_selection(place: SlicePlace, values, *, scalar=False):
    """One-axis .: broadcast on selected cells, admitted before all stores.

    Snapshot the required RHS values before stores to handle overlap. The
    production write bridge additionally enforces const, element admission,
    physical stride and its ordinary failure/ownership contracts. A supplied
    iterable without length models obtaining the RHS value first; a ready
    sized RHS exposes its shape without reading any elements.
    """
    count = place.plan.count
    if scalar:
        ready = [values] * count
    else:
        supplied = values if hasattr(values, "__len__") else list(values)
        source_count = len(supplied)
        if source_count not in (count, 1):
            raise SliceFailure("FxShape", "RHS cannot broadcast to selected shape")
        # A singleton Array is broadcast by .:, not reclassified as scalar.
        # Empty targets admit source lengths 0 or 1 without reading elements.
        ready = [] if not count else list(supplied)
        if source_count == 1 and count:
            ready *= count
    if len(place.source) != place.original_length:
        raise SliceFailure("FxShape", "destination shape changed while preparing RHS")
    for index, value in zip(place.plan.indices(), ready):
        place.source[index] = value
    return place.source


class Mark(Enum):
    QUESTION = auto()
    COLON = auto()


@dataclass(frozen=True)
class Group:
    """An opaque nested structural level; not a parenthesis token."""
    children: tuple


def split_index_fields(items):
    """Source-structure adapter for one already bounded index payload.

    At this level ':' marks split slice fields unless paired with a pending
    '?'. Nested groups/receiver Frames are opaque. The lexer of this index
    context provides two COLON marks for '::'; outside it :: remains one
    signature operand. This helper has no source-text or bracket dependency.
    """
    parts = [[]]
    pending = 0
    separators = 0
    for item in items:
        if item is Mark.QUESTION:
            pending += 1
            parts[-1].append(item)
        elif item is Mark.COLON and pending:
            pending -= 1
            parts[-1].append(item)
        elif item is Mark.COLON:
            separators += 1
            if separators > 2:
                raise SliceFailure("SliceSyntax", "more than two slice separators")
            parts.append([])
        else:
            parts[-1].append(item)
    if pending:
        raise SliceFailure("ConditionalSyntax", "unmatched conditional question")
    return tuple(tuple(part) for part in parts)


def pair_conditionals(items):
    """Pair structural conditional marks at one level, without evaluation."""
    stack, pairs = [], {}
    for at, item in enumerate(items):
        if item is Mark.QUESTION:
            stack.append(at)
        elif item is Mark.COLON:
            if not stack:
                raise SliceFailure("ConditionalSyntax", "unmatched conditional colon")
            pairs[stack.pop()] = at
    if stack:
        raise SliceFailure("ConditionalSyntax", "unmatched conditional question")
    return pairs
