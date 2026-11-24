"""Executable reference of Expression *planning*, not a production LMX parser.

Input is a graph view supplied by an integration adapter, never source text.
There is no lexer, parenthesis token, source-origin test, or graph mutation.
Ready receiver descriptions supply binding rules and argument contracts.
The deliberately small classes below are transient views/plans, not new LMX
storage records or additions to OPERANDS_TEMPLATE. See EXPRESSION_ALGORITHM.md.
"""

from dataclasses import dataclass
from typing import Any, Callable


ABSENT = object()


@dataclass(frozen=True)
class Context:
    lexical_parent: Any
    activation: Any = None


@dataclass(frozen=True)
class Binding:
    """Derived existing binding policy, not new public operand DATA fields.

    Larger ranks bind more tightly. Equal ranks follow right_associative.
    prefix_rank preserves the established directional unary/power policy.
    attached preserves the common attached-unary class, with side left/right.
    Receiving roles never select a different parsing branch.
    """

    name: str
    rank: int
    right_associative: bool = False
    prefix_rank: int | None = None
    attached: str | None = None

    def right_limit(self):
        return Limit(self.rank, self.right_associative)

    def prefix_limit(self):
        rank = self.rank if self.prefix_rank is None else self.prefix_rank
        return Limit(rank, False)


@dataclass(frozen=True)
class Limit:
    rank: int | None = None
    include_equal: bool = True

    def accepts(self, binding):
        return (self.rank is None or binding.rank > self.rank
                or self.include_equal and binding.rank == self.rank)


@dataclass(frozen=True)
class Unit:
    kind: str                 # atom, group, receiver: internal plan choices
    node: Any                 # the actual resolved graph node
    context: Context
    raw: Any                  # original graph occurrence, including its link


@dataclass(frozen=True)
class GraphRange:
    owner: Any                # graph identity, not a source text/string
    first: int
    stop: int


@dataclass(frozen=True)
class LeftView:
    """One common internal view for every present left argument.

    occurrence is one graph atom/unit. region is its priority-formed value
    context. Only the ordinary receiver later chooses what it consumes.
    """
    occurrence: Any
    region: Any


@dataclass(frozen=True)
class Apply:
    operation: Binding
    operation_raw: Any         # exact operand occurrence; not only its name
    left: Any                 # one LeftView, or ABSENT; never a free left list
    right: tuple              # ordered plan units; not yet the runtime ABI
    context: Context
    raw: GraphRange           # whole original graph interval for RAW demand


@dataclass(frozen=True)
class LeftBundle:
    items: tuple              # references/places, not copied stored values


@dataclass(frozen=True)
class Actuals:
    left: Any
    right: tuple              # stand-in for the existing Array<reference>


def rightmost_occurrence(plan):
    """Retain the adjacent atom for every operation, independently of role."""
    if isinstance(plan, Unit):
        return plan
    if isinstance(plan, Apply):
        # A unary attachment is one structural unit at the outer level.
        if plan.operation.attached is not None:
            return plan
        if plan.right:
            return rightmost_occurrence(plan.right[-1])
        if plan.left is not ABSENT:
            return plan.left.occurrence
    return plan


def left_view(region):
    return LeftView(rightmost_occurrence(region), region)


class GraphView:
    """Integration boundary: implement these from the existing clean graph.

    resolve follows a supplied reference, preserving identity/parent. It must
    not execute a body or manufacture a call. binding reads ready metadata.
    A production implementation also carries the existing role/context maps.
    """

    def resolve(self, node, context):
        raise NotImplementedError

    def is_structure(self, node):
        raise NotImplementedError

    def name(self, node):
        raise NotImplementedError

    def parent(self, node):
        raise NotImplementedError

    def fields(self, node):
        raise NotImplementedError

    def binding(self, node, context):
        """Existing resolved operand contract, or None; never trial-execute."""
        raise NotImplementedError


class Cursor:
    def __init__(self, owner, items):
        self.owner = owner
        self.items = tuple(items)
        self.index = 0

    def more(self):
        return self.index < len(self.items)

    def peek(self):
        return self.items[self.index]

    def take(self):
        item = self.peek()
        self.index += 1
        return item


class Planner:
    def __init__(self, view):
        self.view = view

    def classify(self, item, context):
        """Only for a position already consumed as CODE/Expression."""
        node = self.view.resolve(item, context)
        if not self.view.is_structure(node):
            return Unit("atom", node, context, item)
        anonymous = self.view.name(node) is None
        same_parent = self.view.parent(node) is context.lexical_parent
        if anonymous or not same_parent:
            return Unit("group", node, context, item)
        # A named Structure owned by this lexical parent is a receiver/call
        # form. Its own argument contract still decides DATA/CODE/etc.
        return Unit("receiver", node, context, item)

    def plan(self, group, context):
        """Analyze one graph level; group interiors remain demand/role bound."""
        group = self.view.resolve(group, context)
        cursor = Cursor(group, self.view.fields(group))
        result = []
        while cursor.more():
            result.append(self._unit(cursor, Limit(), context))
        return tuple(result)

    def _binding(self, cursor, context):
        if not cursor.more():
            return None
        node = self.view.resolve(cursor.peek(), context)
        return self.view.binding(node, context)

    def _unit(self, cursor, limit, context):
        start = cursor.index
        def application(operation, operation_raw, left, right):
            return Apply(operation, operation_raw, left, right, context,
                         GraphRange(cursor.owner, start, cursor.index))
        first = self._binding(cursor, context)
        if first is not None:
            # An operand in the first position has no left occurrence.
            operation_raw = cursor.take()
            if first.attached == "right":
                raise ValueError("right-attached unary operation needs an atom")
            if first.attached == "left":
                if not cursor.more():
                    raise ValueError("left-attached unary operation needs an atom")
                right = (self._attached_atom(cursor, context),)
            else:
                right = self._tail(cursor, first.prefix_limit(), context)
            left = application(first, operation_raw, ABSENT, right)
        else:
            left = self.classify(cursor.take(), context)

        while cursor.more():
            operation = self._binding(cursor, context)
            if (operation is None or operation.attached == "left"
                    or not limit.accepts(operation)):
                break
            operation_raw = cursor.take()
            right = (() if operation.attached == "right" else
                     self._tail(cursor, operation.right_limit(), context))
            left = application(operation, operation_raw, left_view(left), right)
        return left

    def _tail(self, cursor, limit, context):
        result = []
        while cursor.more():
            next_operation = self._binding(cursor, context)
            if (result and next_operation is not None
                    and next_operation.attached != "left"
                    and not limit.accepts(next_operation)):
                break
            # At the first RHS position, an operand starts a prefix unit;
            # there is no preceding RHS atom to supply its left argument.
            result.append(self._unit(cursor, limit, context))
        return tuple(result)

    def _attached_atom(self, cursor, context):
        """Exactly one atom plus its attachment chain, never an n-ary tail."""
        start = cursor.index
        operation = self._binding(cursor, context)
        if operation is None:
            unit = self.classify(cursor.take(), context)
        elif operation.attached == "left":
            raw = cursor.take()
            if not cursor.more():
                raise ValueError("left-attached unary operation needs an atom")
            target = self._attached_atom(cursor, context)
            unit = Apply(operation, raw, ABSENT, (target,), context,
                         GraphRange(cursor.owner, start, cursor.index))
        else:
            raise ValueError("an attached unary operation requires one atom")
        while cursor.more():
            operation = self._binding(cursor, context)
            if operation is None or operation.attached != "right":
                break
            raw = cursor.take()
            unit = Apply(operation, raw, left_view(unit), (), context,
                         GraphRange(cursor.owner, start, cursor.index))
        return unit


@dataclass(frozen=True)
class MethodOutcome:
    value: Any
    consumed_left_region: Any = ABSENT


def receive_application(application, method, namespace, evaluate):
    """Receive an ALREADY DEMANDED application, outside the grouper.

    Precondition: the production executor has established demand and retained
    previously obtained surrounding values. This helper is not a scheduler:
    evaluate must resume the existing context, preserving its effect order and
    short-circuit rules. Calling every syntactic Apply eagerly is incorrect.

    The method receives the unchanged left view/absence and unchanged right
    sequence. Only *inside that method* may it choose equivalent handling of
    prefix/infix forms or a PLACE/NAME/RAW/value consumption contract. Neither
    the grouper nor this dispatcher moves right[0] to left. MethodOutcome is
    model bookkeeping for the existing namespace dependency mechanism, not a
    new public LMX result type or an extra return field required of methods.
    evaluate(plan, replacements) substitutes by occurrence identity, never by
    identifier spelling. A production executor retains its demand/effect rules.
    """
    outcome = method.invoke(application.left, application.right, namespace, evaluate)
    if application.left is ABSENT:
        return outcome.value
    region = application.left.region
    if outcome.consumed_left_region is region:
        return outcome.value
    return evaluate(region, {id(outcome.consumed_left_region): outcome.value})


def expose_sequence(units, planner):
    """Select one immediate material level for a SEQUENCE consumer.

    This is called by grouping under the resolved receiving contract, not
    unconditionally on every actual. Interior operations are grouped before
    the resulting immediate units are exposed. Each unit retains the group's
    lexical context and the existing activation. Sibling groups and their
    children are deliberately not flattened.
    """
    if len(units) == 1 and isinstance(units[0], Unit):
        unit = units[0]
        if unit.kind == "group":
            context = Context(unit.node, unit.context.activation)
            return planner.plan(unit.node, context)
    return tuple(units)


def prepare_actuals(left_sequence, right_sequence, make_reference: Callable):
    """Separate application adapter: no parsing or further group opening.

    Sequence choice, DATA/TYPE/PLACE roles, RAW demand and stream production
    have already been settled by the receiving contract. left_sequence is
    ABSENT or an ordered sequence. An empty present group is not ABSENT.
    """
    if left_sequence is ABSENT:
        left = ABSENT
    else:
        refs = tuple(make_reference(item) for item in left_sequence)
        left = refs[0] if len(refs) == 1 else LeftBundle(refs)
    right = tuple(make_reference(item) for item in right_sequence)
    return Actuals(left, right)


def group_assignment(targets, right_items, read_once, validate_all, write):
    """Existing group-assignment ordering, shown independently of planning."""
    values = tuple(read_once(item) for item in right_items)
    validate_all(targets, values)   # count, place and type checks before writes
    for target, value in zip(targets, values):
        write(target, value)
