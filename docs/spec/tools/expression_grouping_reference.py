"""Executable reference of Expression *planning*, not a production LMX parser.

Input is a graph view supplied by an integration adapter, never source text.
There is no lexer, parenthesis token, source-origin test, or graph mutation.
Ready receiver descriptions supply binding rules and argument contracts.
The deliberately small classes below are transient views/plans, not new LMX
storage records or additions to OPERANDS_TEMPLATE. See EXPRESSION_ALGORITHM.md.
"""

from dataclasses import dataclass, replace
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


@dataclass(frozen=True)
class PreparedGroup:
    """One material subgroup with zero or several prepared items.

    This transient view is not a new public LMX data type.
    """
    items: tuple


@dataclass(frozen=True)
class PreparedAtom:
    """One original graph atom with its normalized Expression payload.

    Singleton groups disappear from value, but origins retains the original
    outer-to-inner occurrences. Thus a grouped Apply remains one source atom
    for selecting left, and RAW still has the untouched graph and contexts.
    """
    origins: tuple            # original Unit(group) occurrences, outer first
    value: Any                # one Unit/Apply, PreparedGroup or graph edge

    @property
    def raw(self):
        return self.origins[0].raw

    @property
    def context(self):
        return self.origins[0].context


@dataclass
class PreparedGraphNode:
    """A finite planning anchor; only back edges need to retain this object."""
    source: Unit
    items: tuple | None = None


@dataclass(frozen=True)
class PreparedGraphEdge:
    """A back edge, not a copied/infinitely expanded tree or language error."""
    target: PreparedGraphNode


def prepared_value(item):
    """Read a prepared payload without reopening or evaluating the graph."""
    while isinstance(item, PreparedAtom):
        item = item.value
    return item


def rightmost_occurrence(plan):
    """Retain the adjacent atom for every operation, independently of role."""
    if isinstance(plan, PreparedAtom):
        # Its payload may be Apply, but that whole grouped Apply is one atom.
        return plan
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


def normalize_expression(units, planner):
    """Recursively prepare graph groups after priority planning.

    This entry is for an already selected Expression graph. It does not
    inspect an operand's value/type admission, execute receivers, or inspect
    values/field streams that a receiver may later produce. Existing RAW,
    DATA and TYPE consumers keep access to the original graph occurrences.

    Every nested group is planned, then packed as one atom: a singleton uses
    its only payload; zero or several items use PreparedGroup. Several atoms
    at the current level stay several atoms. A PreparedAtom retains a source
    atom boundary even when its only payload is an Apply.

    Memoization below is by plan occurrence, not graph node. Two references
    to the same graph node therefore retain separate prepared occurrences.
    An active-path back edge is retained as PreparedGraphEdge, so pure-graph
    planning terminates without defining new runtime cycle semantics.
    """
    memo = {}
    active = {}

    def pack(source, items):
        if len(items) != 1:
            return PreparedAtom((source,), PreparedGroup(items))
        item = items[0]
        if isinstance(item, PreparedAtom):
            return PreparedAtom((source,) + item.origins, item.value)
        return PreparedAtom((source,), item)

    def prepare(item):
        entry = memo.get(id(item))
        if entry is not None and entry[0] is item:
            return entry[1]
        if isinstance(item, PreparedAtom):
            return item
        if isinstance(item, Unit) and item.kind == "group":
            context = Context(item.node, item.context.activation)
            key = (id(item.node), id(context.activation))
            if key in active:
                result = PreparedAtom((item,), PreparedGraphEdge(active[key]))
            else:
                anchor = PreparedGraphNode(item)
                active[key] = anchor
                try:
                    children = planner.plan(item.node, context)
                    prepared = tuple(prepare(child) for child in children)
                    anchor.items = prepared
                    result = pack(item, prepared)
                finally:
                    del active[key]
        elif isinstance(item, Apply):
            left = item.left
            if left is not ABSENT:
                region = prepare(left.region)
                occurrence = prepare(left.occurrence)
                if region is not left.region or occurrence is not left.occurrence:
                    left = LeftView(occurrence, region)
            right = tuple(prepare(child) for child in item.right)
            unchanged = (left is item.left and
                         all(a is b for a, b in zip(right, item.right)))
            result = item if unchanged else replace(item, left=left, right=right)
        else:
            result = item
        # Retaining the input prevents an id from being reused during this pass.
        memo[id(item)] = (item, result)
        return result

    return tuple(prepare(item) for item in units)


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
    """Choose the prepared current level for a SEQUENCE consumer.

    Normalization is generic Expression work; this helper only selects the
    effective level of a sole group. In a wider sequence every subgroup
    remains one atom, including an empty subgroup. Argument roles and stream
    production are handled by the existing receiver/namespace integration.
    """
    units = normalize_expression(tuple(units), planner)
    if len(units) == 1 and isinstance(units[0], PreparedAtom):
        value = prepared_value(units[0])
        return value.items if isinstance(value, PreparedGroup) else (value,)
    return units


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
