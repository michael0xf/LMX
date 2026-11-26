"""Host-side checks of the reference planner; NOT execution of LMX."""

from dataclasses import dataclass
from pathlib import Path
import importlib.util
import sys
import unittest

path = Path(__file__).resolve().parents[1] / "tools/expression_grouping_reference.py"
sys.path.insert(0, str(path.parent))
from operand_depth_reference import DepthExpression, DepthError
spec = importlib.util.spec_from_file_location("lmx_expression_reference", path)
ref = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = ref
spec.loader.exec_module(ref)


@dataclass
class Group:
    items: tuple
    parent: object
    name: str | None = None


@dataclass
class Link:
    target: object


class View(ref.GraphView):
    def __init__(self, operations):
        self.operations = operations

    def resolve(self, node, context):
        seen = set()
        while isinstance(node, Link):
            if id(node) in seen:
                raise ValueError("cyclic reference chain")
            seen.add(id(node))
            node = node.target
        return node

    def is_structure(self, node): return isinstance(node, Group)
    def name(self, node): return node.name
    def parent(self, node): return node.parent
    def fields(self, node): return node.items
    def binding(self, node, context):
        return self.operations.get(node) if isinstance(node, str) else None


def shape(plan):
    if plan is ref.ABSENT: return None
    if isinstance(plan, ref.LeftView): return shape(plan.region)
    if isinstance(plan, ref.PreparedAtom): return shape(plan.value)
    if isinstance(plan, ref.PreparedGroup):
        return ("group", tuple(map(shape, plan.items)))
    if isinstance(plan, ref.PreparedGraphEdge): return "graph-edge"
    if isinstance(plan, ref.Unit):
        return plan.node if plan.kind == "atom" else plan.kind
    if isinstance(plan, ref.Apply):
        return (plan.operation.name, shape(plan.left), tuple(map(shape, plan.right)))
    return tuple(map(shape, plan))


class NumericMethod:
    """Tiny host method body; this is not LMX numeric semantics."""
    def __init__(self, function, arities=(2,)):
        self.function = function
        self.arities = arities
        self.calls = []

    def invoke(self, left, depth, right, namespace, evaluate):
        if depth != 0:
            raise NotImplementedError("this scalar test method has no lifting implementation")
        values = [] if left is ref.ABSENT else [evaluate(left.region)]
        values.extend(evaluate(item) for item in right)
        self.calls.append(tuple(values))
        if len(values) not in self.arities:
            raise ValueError("scalar numeric arity")
        consumed = ref.ABSENT if left is ref.ABSENT else left.region
        return ref.MethodOutcome(self.function(values), consumed)


class StoreMethod:
    """Scalar :=: one PLACE and one whole VALUE, never Array field assignment.

    The choice of equivalent prefix/infix forms occurs inside this body.
    """
    def __init__(self):
        self.received_shapes = []

    def invoke(self, left, depth, right, namespace, evaluate):
        if depth != 0:
            raise ValueError("scalar store body requires depth zero")
        self.received_shapes.append((left is ref.ABSENT, len(right)))
        if left is ref.ABSENT:
            if len(right) != 2: raise ValueError("target and value required")
            target, value_plan = right
            consumed = ref.ABSENT
        else:
            if len(right) != 1: raise ValueError("one value required")
            target, value_plan = left.occurrence, right[0]
            consumed = target
        if not isinstance(target, ref.Unit) or target.kind != "atom":
            raise ValueError("model requires a simple named place")
        value = evaluate(value_plan)
        namespace[target.node] = value
        return ref.MethodOutcome(value, consumed)


@dataclass(frozen=True)
class HostPlace:
    container: object
    key: object

    def store(self, value):
        self.container[self.key] = value


class HostNoArgCall:
    """A narrow test double for one already-dispatched receiver call."""
    def __init__(self, function):
        self.function = function
        self.calls = 0

    def obtain(self):
        self.calls += 1
        return self.function()


class ElementwiseStoreMethod:
    """Host .: consumer; source admission is separate from graph grouping.

    Both a group of field places and an existing Array select real cells and
    use ref.elementwise_assignment. Python tuple/list stand for the same
    unrestricted LMX Array shape; they do not introduce a tuple language type.
    This small model checks one level, not physical LMX typing or Array rank.
    """
    def __init__(self, planner):
        self.planner = planner
        self.received_shapes = []

    def invoke(self, left, depth, right, namespace, evaluate):
        if depth != 1:
            raise NotImplementedError("this one-level consumer models depth one")
        self.received_shapes.append((left is ref.ABSENT, len(right)))
        if left is ref.ABSENT:
            if len(right) < 2:
                raise ValueError("target and incoming values required")
            target, source = right[0], right[1:]
            consumed = ref.ABSENT
        else:
            target, source, consumed = left.occurrence, right, left.occurrence

        target_items = ref.expose_sequence((target,), self.planner)
        places, original_lengths = [], []
        array_target = None
        for item in target_items:
            item = ref.prepared_value(item)
            if (not isinstance(item, ref.Unit) or item.kind != "atom"
                    or not isinstance(item.node, str)):
                raise ValueError("model requires live named or Array places")
            if len(target_items) == 1 and isinstance(namespace.get(item.node), list):
                array_target = namespace[item.node]
                original_lengths.append((array_target, len(array_target)))
                places.extend(HostPlace(array_target, i)
                              for i in range(len(array_target)))
            else:
                places.append(HostPlace(namespace, item.node))

        # The sole Array returned by a call is still one whole VALUE here.
        # Only this receiver consumes its immediate fields. Wider streams
        # retain each Array as one item; no recursive flattening is performed.
        source_items = ref.expose_sequence(source, self.planner)
        incoming = tuple(evaluate(item) for item in source_items)
        if len(incoming) == 1:
            value = incoming[0]
            incoming = tuple(value) if isinstance(value, (tuple, list)) else (value,) * len(places)

        def validate(targets, values):
            if any(len(array) != size for array, size in original_lengths):
                raise ValueError("destination shape changed while obtaining RHS")

        ref.elementwise_assignment(places, incoming, lambda value: value,
                                   validate, lambda place, value: place.store(value))
        # Return the existing target representation, never a copied value
        # vector. A group is represented here by its original graph occurrence.
        result = array_target if array_target is not None else target
        return ref.MethodOutcome(result, consumed)


class AssignmentMethod:
    """One canonical := family; surface .: supplies depth=1 before demand.

    The generic recursive lifting implementation is specified separately.
    These host checks deliberately exercise only the existing zero/one bodies.
    """
    def __init__(self, scalar, elementwise):
        self.scalar, self.elementwise = scalar, elementwise

    def invoke(self, left, depth, right, namespace, evaluate):
        body = self.scalar if depth == 0 else self.elementwise
        return body.invoke(left, depth, right, namespace, evaluate)


class ArgumentProbe:
    def __init__(self):
        self.received = []

    def invoke(self, left, depth, right, namespace, evaluate):
        self.received.append((left, depth, right))
        consumed = ref.ABSENT if left is ref.ABSENT else left.region
        return ref.MethodOutcome(depth, consumed)


def evaluate_model(plan, planner, methods, namespace, replacements=None, depth_obtain=None):
    """Small host consumer model, outside parsing; not a full effect scheduler.

    Only the explicit assertions below are checked. This evaluator does not
    establish general LMX evaluation order, short-circuiting or activation
    lifetime. Production continuation/demand integration remains NOT_RUN.
    """
    replacements = replacements or {}
    if id(plan) in replacements:
        return replacements[id(plan)]
    def evaluate(child, more=None):
        merged = dict(replacements)
        if more: merged.update(more)
        return evaluate_model(child, planner, methods, namespace, merged, depth_obtain)
    if isinstance(plan, ref.PreparedAtom):
        return evaluate(plan.value)
    if isinstance(plan, ref.PreparedGroup):
        # One opaque material value in this host model. Its fields are not
        # spliced into the caller's argument list. Numeric admission belongs
        # to the method, after it receives this value.
        return tuple(evaluate(item) for item in plan.items)
    if isinstance(plan, ref.PreparedGraphEdge):
        # No runtime cycle semantics are asserted by this planner test.
        return plan
    if isinstance(plan, ref.Unit):
        if plan.kind == "group":
            return evaluate(ref.normalize_expression((plan,), planner)[0])
        if plan.kind == "receiver":
            handler = namespace.get(plan.node.name)
            if isinstance(handler, HostNoArgCall) and not plan.node.items:
                return handler.obtain()
            raise NotImplementedError("production receiver/call handling is external")
        return namespace[plan.node] if isinstance(plan.node, str) else plan.node
    return ref.receive_application(plan, methods[id(plan.operation)], namespace, evaluate,
                                   depth_obtain)


class PlannerChecks(unittest.TestCase):
    def setUp(self):
        self.owner = object()
        self.context = ref.Context(self.owner, object())
        self.ops = {
            "+": ref.Binding("+", 10, prefix_rank=25),
            "-": ref.Binding("-", 10, prefix_rank=25),
            "*": ref.Binding("*", 20),
            "**": ref.Binding("**", 30, right_associative=True),
            ":=": ref.Binding(":=", 0, right_associative=True),
            "::": ref.Binding("::", 0),
            "->": ref.Binding("->", 10),
            "op": ref.Binding("op", 10),
            "high": ref.Binding("high", 20),
            "low": ref.Binding("low", 5),
            "store": ref.Binding("store", 0, right_associative=True),
            "pre": ref.Binding("pre", 40, attached="left"),
            "post": ref.Binding("post", 40, attached="right"),
            "tighter": ref.Binding("tighter", 50),
        }
        self.view = View(self.ops)
        self.planner = ref.Planner(self.view)
        self.store = StoreMethod()
        self.elementwise_store = ElementwiseStoreMethod(self.planner)
        self.assign_each = ref.DecoratedOperation(":=", 1)
        self.assignment_method = AssignmentMethod(self.store, self.elementwise_store)
        self.methods = {
            id(self.ops["+"]): NumericMethod(sum, arities=(1, 2)),
            id(self.ops["-"]): NumericMethod(lambda xs: -xs[0] if len(xs) == 1 else xs[0]-xs[1], arities=(1, 2)),
            id(self.ops["*"]): NumericMethod(lambda xs: xs[0]*xs[1]),
            id(self.ops["**"]): NumericMethod(lambda xs: xs[0]**xs[1]),
            id(self.ops[":="]): self.assignment_method,
            id(self.ops["store"]): self.store,
        }

    def plan(self, *items):
        return self.planner.plan(Group(items, self.owner), self.context)

    def test_undecorated_application_supplies_zero_depth(self):
        app = self.plan(1, "+", 2)[0]
        self.assertEqual(app.depth, 0)
        self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 3)

    def test_depth_decoration_inherits_base_priority_without_evaluation(self):
        source = DepthExpression(object(), {"depth": 99})
        decorated = ref.DecoratedOperation("*", source, object())
        app = self.plan(1, "+", 2, decorated, 3)[0]
        prepared = ref.normalize_expression((app,), self.planner)[0]
        self.assertEqual(shape(prepared), ("+", 1, (("*", 2, (3,)),)))
        self.assertIs(prepared.right[0].depth, source)
        self.assertIs(prepared.right[0].operation, self.ops["*"])
        self.assertIs(prepared.right[0].operation_raw, decorated)

    def test_depth_is_obtained_once_in_original_context_before_method(self):
        events = []
        expression, context = object(), {"n": 1}
        source = DepthExpression(expression, context, object())
        app = self.plan("a", ref.DecoratedOperation("op", source), "b")[0]
        probe = ArgumentProbe()
        self.methods[id(self.ops["op"])] = probe
        def obtain(node, live_context):
            self.assertIs(node, expression)
            self.assertIs(live_context, context)
            events.append("depth")
            return live_context["n"] + 9
        self.assertEqual(evaluate_model(app, self.planner, self.methods,
                                        {"a": 4, "b": 5}, depth_obtain=obtain), 10)
        left, depth, right = probe.received[0]
        self.assertIs(left, app.left)
        self.assertIs(right, app.right)
        self.assertEqual(depth, 10)
        self.assertEqual(events, ["depth"])

    def test_explicit_zero_depth_keeps_scalar_behavior_and_evaluates_expression(self):
        calls = []
        source = DepthExpression("zero", self.context)
        app = self.plan(2, ref.DecoratedOperation("+", source), 3)[0]
        def obtain(expression, context):
            calls.append((expression, context))
            return 0
        self.assertEqual(evaluate_model(app, self.planner, self.methods, {},
                                        depth_obtain=obtain), 5)
        self.assertEqual(calls, [("zero", self.context)])

    def test_prefix_depth_does_not_promote_first_right(self):
        app = self.plan(ref.DecoratedOperation("op", 2), 1, 2)[0]
        probe = ArgumentProbe()
        self.methods[id(self.ops["op"])] = probe
        self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 2)
        left, depth, right = probe.received[0]
        self.assertIs(left, ref.ABSENT)
        self.assertEqual(depth, 2)
        self.assertEqual(shape(right), (1, 2))

    def test_bad_depth_never_enters_method(self):
        for invalid in (-1, 1.5, True, (1, 2)):
            probe = ArgumentProbe()
            self.methods[id(self.ops["op"])] = probe
            app = self.plan(1, ref.DecoratedOperation("op", invalid), 2)[0]
            with self.assertRaises(DepthError):
                evaluate_model(app, self.planner, self.methods, {})
            self.assertEqual(probe.received, [])

    def test_shared_depth_source_is_not_cached_across_distinct_demands(self):
        calls = []
        source = DepthExpression("nextDepth", self.context)
        probe = ArgumentProbe()
        self.methods[id(self.ops["op"])] = probe
        def obtain(expression, context):
            calls.append(expression)
            return len(calls)
        for expected in (1, 2):
            app = self.plan(1, ref.DecoratedOperation("op", source), 2)[0]
            self.assertEqual(evaluate_model(app, self.planner, self.methods, {},
                                            depth_obtain=obtain), expected)
        self.assertEqual(len(calls), 2)

    def test_nested_arrays_are_not_flattened_by_depth_transport(self):
        nested = [[1, 2], [3, 4]]
        app = self.plan("values", ref.DecoratedOperation("op", 2), 10)[0]
        probe = ArgumentProbe()
        self.methods[id(self.ops["op"])] = probe
        self.assertEqual(evaluate_model(app, self.planner, self.methods,
                                        {"values": nested}), 2)
        left, depth, right = probe.received[0]
        self.assertIs(evaluate_model(left.region, self.planner, self.methods,
                                     {"values": nested}), nested)
        self.assertEqual(len(right), 1)
        self.assertEqual(depth, 2)

    def test_depth_zero_assignment_preserves_left_demand_dependencies(self):
        namespace = {"v": 100}
        app = self.plan(1, "+", "v", ref.DecoratedOperation(":=", 0), 2, "+", 3)[0]
        self.assertEqual(evaluate_model(app, self.planner, self.methods, namespace), 6)
        self.assertEqual(namespace["v"], 5)

    def test_attached_depth_preserves_general_side_class(self):
        app = self.plan(ref.DecoratedOperation("pre", 3), "a", "tighter", "b")[0]
        self.assertEqual(shape(app), ("tighter", ("pre", None, ("a",)), ("b",)))
        self.assertEqual(app.left.region.depth, 3)

    def test_prefix_has_absent_left_and_all_right_items(self):
        self.assertEqual(shape(self.plan("op", 1, 2, 3)), (("op", None, (1, 2, 3)),))

    def test_empty_prefix_does_not_invent_arguments(self):
        self.assertEqual(shape(self.plan("op")), (("op", None, ()),))

    def test_binary_subset_and_precedence(self):
        self.assertEqual(shape(self.plan(1, "+", 2, "*", 3)),
                         (("+", 1, (("*", 2, (3,)),)),))

    def test_variadic_right_and_stronger_neighbor(self):
        self.assertEqual(shape(self.plan("a", "op", "b", "c", "high", "d")),
                         (("op", "a", ("b", ("high", "c", ("d",)))),))

    def test_variadic_right_and_weaker_neighbor(self):
        self.assertEqual(shape(self.plan("a", "op", "b", "c", "low", "d")),
                         (("low", ("op", "a", ("b", "c")), ("d",)),))

    def test_no_free_left_array_from_neighboring_atoms(self):
        self.assertEqual(shape(self.plan("a", "b", "c", "op", "d")),
                         ("a", "b", ("op", "c", ("d",))))

    def test_prefix_on_right_does_not_steal_a_left(self):
        self.assertEqual(shape(self.plan(2, "**", "-", 2)),
                         (("**", 2, (("-", None, (2,)),)),))

    def test_power_and_prefix_direction(self):
        self.assertEqual(shape(self.plan("-", 2, "**", 2)),
                         (("-", None, (("**", 2, (2,)),)),))

    def test_power_right_associativity(self):
        self.assertEqual(shape(self.plan(2, "**", 3, "**", 2)),
                         (("**", 2, (("**", 3, (2,)),)),))

    def test_every_left_retains_atom_and_value_context(self):
        app = self.plan(1, "+", "v", ":=", 2, "+", 3)[0]
        self.assertEqual(app.left.occurrence.node, "v")
        self.assertEqual(shape(app.left.region), ("+", 1, ("v",)))
        value_app = self.plan(10, "*", 2, "+", 3)[0]
        self.assertEqual(value_app.left.occurrence.node, 2)
        self.assertEqual(shape(value_app.left.region), ("*", 10, (2,)))

    def test_method_consumption_resumes_unconsumed_context(self):
        namespace = {"v": 100}
        app = self.plan(1, "+", "v", ":=", 2, "+", 3)[0]
        self.assertEqual(evaluate_model(app, self.planner, self.methods, namespace), 6)
        self.assertEqual(namespace["v"], 5)

    def test_same_consumer_under_another_operand_name(self):
        namespace = {"v": 100}
        app = self.plan(10, "*", "v", "store", 2, "+", 3)[0]
        self.assertEqual(evaluate_model(app, self.planner, self.methods, namespace), 50)
        self.assertEqual(namespace["v"], 5)

    def test_value_consumer_uses_full_priority_region(self):
        app = self.plan(10, "*", 2, "+", 3)[0]
        self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 23)

    def test_same_name_on_rhs_is_a_distinct_occurrence(self):
        namespace = {"v": 4}
        app = self.plan("v", ":=", "v", "+", 1)[0]
        self.assertEqual(evaluate_model(app, self.planner, self.methods, namespace), 5)

    def test_prefix_infix_equivalence_only_inside_method(self):
        prefix = self.plan(":=", "a", 1)[0]
        infix = self.plan("a", ":=", 1)[0]
        self.assertIs(prefix.left, ref.ABSENT)
        self.assertEqual(len(prefix.right), 2)
        self.assertEqual(infix.left.occurrence.node, "a")
        self.assertEqual(len(infix.right), 1)
        one, two = {}, {}
        self.assertEqual(evaluate_model(prefix, self.planner, self.methods, one), 1)
        self.assertEqual(evaluate_model(infix, self.planner, self.methods, two), 1)
        self.assertEqual(one, two)
        self.assertEqual(self.store.received_shapes, [(True, 2), (False, 1)])

    def test_assignment_chain(self):
        self.assertEqual(shape(self.plan("a", ":=", "b", ":=", 10)),
                         ((":=", "a", ((":=", "b", (10,)),)),))

    def test_signature_name_and_constructor_tail(self):
        self.assertEqual(shape(self.plan("f", "::", "int", "->", "int", "int")),
                         (("::", "f", (("->", "int", ("int", "int")),)),))

    def test_foreign_parent_reference_is_group(self):
        foreign = object()
        s = Group(("a", "b", "c", "d"), foreign, "S")
        middle = self.plan(1, "+", Link(s), "+", 2)[0].left.region.right[0]
        self.assertEqual(middle.kind, "group")
        self.assertIs(middle.node, s)
        self.assertIs(s.parent, foreign)

    def test_named_same_parent_is_receiver(self):
        s = Group(("a", "b"), self.owner, "S")
        self.assertEqual(self.plan(Link(s))[0].kind, "receiver")

    def test_anonymous_same_parent_is_group(self):
        s = Group(("a", "b"), self.owner)
        self.assertEqual(self.plan(Link(s))[0].kind, "group")

    def test_one_rhs_group_selects_current_level(self):
        left = Group(("a", "b", "c"), self.owner)
        right = Group(("a", "c", "b"), self.owner)
        app = self.plan(left, self.assign_each, right)[0]
        ls = ref.expose_sequence((app.left.occurrence,), self.planner)
        rs = ref.expose_sequence(app.right, self.planner)
        actuals = ref.prepare_actuals(ls, 1, rs, lambda x: x)
        self.assertEqual(shape(actuals.left.items), ("a", "b", "c"))
        self.assertEqual(shape(actuals.right), ("a", "c", "b"))
        self.assertIs(actuals.right[0].context.lexical_parent, right)
        self.assertIs(actuals.right[0].context.activation, self.context.activation)

    def test_three_sibling_groups_are_three_items(self):
        left = Group(("a", "b", "c"), self.owner)
        groups = [Group(("f", "g", "h"), self.owner) for _ in range(3)]
        app = self.plan(left, self.assign_each, *groups)[0]
        rs = ref.expose_sequence(app.right, self.planner)
        self.assertEqual(len(rs), 3)
        self.assertTrue(all(isinstance(item, ref.PreparedAtom) for item in rs))
        self.assertTrue(all(isinstance(item.value, ref.PreparedGroup) for item in rs))

    def test_singleton_chain_exposes_multi_atom_level(self):
        inner = Group(("x", "y"), self.owner)
        outer = Group((inner,), self.owner)
        app = self.plan(Group(("a", "b"), self.owner), self.assign_each, outer)[0]
        rs = ref.expose_sequence(app.right, self.planner)
        self.assertEqual(shape(rs), ("x", "y"))
        self.assertIs(rs[0].context.lexical_parent, inner)

    def test_rhs_expression_group_is_one_computed_unit(self):
        right = Group((2, "*", 3), self.owner)
        app = self.plan(Group(("target",), self.owner), ":=", right)[0]
        rs = ref.expose_sequence(app.right, self.planner)
        self.assertEqual(shape(rs), (("*", 2, (3,)),))

    def test_adapter_preserves_absence(self):
        actuals = ref.prepare_actuals(ref.ABSENT, 0, (1, 2), lambda x: x)
        self.assertIs(actuals.left, ref.ABSENT)
        self.assertEqual(actuals.right, (1, 2))

    def test_raw_retains_graph_identity_interval_and_context(self):
        group = Group((1, "+", 2, "*", 3), self.owner)
        app = self.planner.plan(group, self.context)[0]
        self.assertIs(app.raw.owner, group)
        self.assertEqual((app.raw.first, app.raw.stop), (0, 5))
        nested = app.right[0]
        self.assertIs(nested.raw.owner, group)
        self.assertEqual((nested.raw.first, nested.raw.stop), (2, 5))
        self.assertIs(nested.context, self.context)
        self.assertEqual(group.items, (1, "+", 2, "*", 3))

    def test_raw_link_and_resolved_group_both_retained(self):
        target = Group((1,), object(), "S")
        link = Link(target)
        unit = self.plan(link)[0]
        self.assertIs(unit.raw, link)
        self.assertIs(unit.node, target)

    def test_operand_occurrence_retained_for_dispatch(self):
        occurrence = Link("+")
        app = self.plan(1, occurrence, 2)[0]
        self.assertIs(app.operation_raw, occurrence)
        self.assertEqual(app.operation.name, "+")

    def test_assignment_snapshots_before_writes(self):
        values = {"a": 1, "b": 2, "c": 3}
        writes = []
        def validate(targets, incoming):
            self.assertEqual(len(targets), len(incoming))
            self.assertEqual(writes, [])
        def write(target, value):
            writes.append(target)
            values[target] = value
        ref.elementwise_assignment(("a", "b", "c"), ("a", "c", "b"),
                                   values.__getitem__, validate, write)
        self.assertEqual(values, {"a": 1, "b": 3, "c": 2})

    def test_no_write_when_validation_fails(self):
        writes = []
        def reject(*args): raise ValueError("arity")
        with self.assertRaises(ValueError):
            ref.elementwise_assignment(("a", "b"), (1,), lambda x: x,
                                       reject, lambda *args: writes.append(args))
        self.assertEqual(writes, [])

    def test_elementwise_group_rotation_uses_captured_rhs(self):
        g = lambda *items: Group(items, self.owner)
        namespace = {"a": 1, "b": 2, "c": 3}
        app = self.plan(g("a", "b", "c"), self.assign_each, g("b", "c", "a"))[0]
        evaluate_model(app, self.planner, self.methods, namespace)
        self.assertEqual(namespace, {"a": 2, "b": 3, "c": 1})
        self.assertEqual(self.store.received_shapes, [])

    def test_elementwise_prefix_equivalence_is_inside_its_method(self):
        g = lambda *items: Group(items, self.owner)
        prefix = self.plan(self.assign_each, g("a", "b", "c"), g("b", "c", "a"))[0]
        infix = self.plan(g("a", "b", "c"), self.assign_each, g("b", "c", "a"))[0]
        self.assertIs(prefix.left, ref.ABSENT)
        self.assertEqual(len(prefix.right), 2)
        one = {"a": 1, "b": 2, "c": 3}
        two = dict(one)
        evaluate_model(prefix, self.planner, self.methods, one)
        evaluate_model(infix, self.planner, self.methods, two)
        self.assertEqual(one, two)
        self.assertEqual(self.elementwise_store.received_shapes, [(True, 2), (False, 1)])

    def test_elementwise_consumer_reads_one_returned_array(self):
        g = lambda *items: Group(items, self.owner)
        namespace = {"a": 1, "b": 2, "c": 3}
        returned = [2, 3, 1]
        function = HostNoArgCall(lambda: returned)
        namespace["myFn"] = function
        call = Group((), self.owner, "myFn")
        app = self.plan(g("a", "b", "c"), self.assign_each, call)[0]
        prepared = ref.normalize_expression((app,), self.planner)[0]
        self.assertEqual(len(prepared.right), 1)
        self.assertEqual(function.calls, 0)
        evaluate_model(prepared, self.planner, self.methods, namespace)
        self.assertEqual(function.calls, 1)
        self.assertEqual([namespace[k] for k in ("a", "b", "c")], returned)

    def test_elementwise_sibling_groups_remain_array_items(self):
        g = lambda *items: Group(items, self.owner)
        namespace = {"a": None, "b": None, "c": None}
        app = self.plan(g("a", "b", "c"), self.assign_each, g(1, 2), g(3, 4), g(5, 6))[0]
        evaluate_model(app, self.planner, self.methods, namespace)
        self.assertEqual(namespace, {"a": (1, 2), "b": (3, 4), "c": (5, 6)})

    def test_array_target_uses_same_elementwise_commit_body(self):
        target, incoming = [0, 0, 0], [10, 20, 30]
        namespace = {"target": target, "incoming": incoming}
        app = self.plan("target", self.assign_each, "incoming")[0]
        result = evaluate_model(app, self.planner, self.methods, namespace)
        self.assertIs(result, target)
        self.assertEqual(target, incoming)
        self.assertIsNot(target, incoming)

    def test_elementwise_shape_failure_keeps_destinations_unchanged(self):
        g = lambda *items: Group(items, self.owner)
        namespace = {"a": 1, "b": 2, "c": 3}
        app = self.plan(g("a", "b", "c"), self.assign_each, g(8, 9))[0]
        with self.assertRaisesRegex(ValueError, "shape mismatch"):
            evaluate_model(app, self.planner, self.methods, namespace)
        self.assertEqual(namespace, {"a": 1, "b": 2, "c": 3})

    def test_scalar_assignment_does_not_copy_array_fields(self):
        source = [1, 2, 3]
        namespace = {"target": None, "source": source}
        app = self.plan("target", ":=", "source")[0]
        self.assertIs(evaluate_model(app, self.planner, self.methods, namespace), source)
        self.assertIs(namespace["target"], source)
        self.assertEqual(self.elementwise_store.received_shapes, [])

    def test_scalar_assignment_refuses_material_group_target(self):
        g = lambda *items: Group(items, self.owner)
        namespace = {"a": 1, "b": 2, "c": 3}
        app = self.plan(g("a", "b", "c"), ":=", g("b", "c", "a"))[0]
        with self.assertRaisesRegex(ValueError, "simple named place"):
            evaluate_model(app, self.planner, self.methods, namespace)
        self.assertEqual(namespace, {"a": 1, "b": 2, "c": 3})

    def test_attached_left_class_has_one_argument(self):
        self.assertEqual(shape(self.plan("pre", 1, 2)), (("pre", None, (1,)), 2))

    def test_attached_right_class_has_one_argument(self):
        self.assertEqual(shape(self.plan(1, "post", 2)), (("post", 1, ()), 2))

    def test_attached_class_needs_its_atom(self):
        with self.assertRaises(ValueError): self.plan("pre")
        with self.assertRaises(ValueError): self.plan("post", 1)

    def test_attached_atom_does_not_capture_stronger_ordinary_tail(self):
        self.assertEqual(shape(self.plan("pre", "a", "tighter", "b")),
                         (("tighter", ("pre", None, ("a",)), ("b",)),))

    def test_attached_chain_stays_one_argument(self):
        self.assertEqual(shape(self.plan("pre", "pre", "a", "post", "b")),
                         (("pre", None, (("pre", None, (("post", "a", ()),)),)), "b"))

    def test_nested_graph_group_scalar_expression(self):
        inner = Group((2,), self.owner)
        outer = Group((inner,), self.owner)
        app = self.plan(1, "+", outer)[0]
        self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 3)

    def test_author_singleton_groups_prepare_scalar_right_items(self):
        g = lambda *items: Group(items, self.owner)
        app = ref.normalize_expression(
            self.plan(1, "+", 2, g(g(g(3))), g(4), g(g(5))), self.planner)[0]
        self.assertEqual(shape(app), ("+", 1, (2, 3, 4, 5)))
        self.assertEqual(self.methods[id(self.ops["+"])].calls, [])

    def test_author_wider_right_arity_is_rejected_only_inside_numeric_method(self):
        g = lambda *items: Group(items, self.owner)
        app = ref.normalize_expression(
            self.plan(1, "+", 2, g(g(g(5, 6))), g(4), 5), self.planner)[0]
        self.assertEqual(shape(app), ("+", 1, (2, ("group", (5, 6)), 4, 5)))
        method = self.methods[id(self.ops["+"])]
        self.assertEqual(method.calls, [])
        with self.assertRaisesRegex(ValueError, "scalar numeric arity"):
            evaluate_model(app, self.planner, self.methods, {})
        # The whole subgroup remains one item. The receiving scalar method,
        # not normalization, rejects the wider five-value invocation.
        self.assertEqual(method.calls, [(1, 2, (5, 6), 4, 5)])

    def test_author_prefix_operation_in_subgroup_is_one_unit(self):
        g = lambda *items: Group(items, self.owner)
        app = ref.normalize_expression(
            self.plan(1, "+", 2, g(g(g("+", 5, 6))), g(4), 5), self.planner)[0]
        self.assertEqual(shape(app), ("+", 1, (2, ("+", None, (5, 6)), 4, 5)))
        inner = ref.prepared_value(app.right[1])
        self.assertIs(inner.left, ref.ABSENT)
        self.assertEqual(len(inner.right), 2)
        self.assertEqual(evaluate_model(inner, self.planner, self.methods, {}), 11)
        with self.assertRaisesRegex(ValueError, "scalar numeric arity"):
            evaluate_model(app, self.planner, self.methods, {})

    def test_normalized_grouped_apply_remains_one_source_atom(self):
        group = Group((3, "+", 4), self.owner)
        app = ref.normalize_expression(self.plan(2, "*", group), self.planner)[0]
        atom = app.right[0]
        self.assertIsInstance(atom, ref.PreparedAtom)
        self.assertIsInstance(atom.value, ref.Apply)
        self.assertIs(ref.rightmost_occurrence(atom), atom)
        self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 14)
        store = ref.normalize_expression(self.plan(2, "*", group, ":=", 9), self.planner)[0]
        self.assertIs(store.left.occurrence, store.left.region.right[0])
        self.assertIsInstance(store.left.occurrence, ref.PreparedAtom)

    def test_sibling_expression_groups_are_normalized_without_splicing(self):
        g = lambda *items: Group(items, self.owner)
        app = ref.normalize_expression(
            self.plan(g("a", "b", "c"), self.assign_each, g("x", "+", 1),
                      g("y", "*", 2), g("z", "-", 3)), self.planner)[0]
        rs = ref.expose_sequence(app.right, self.planner)
        self.assertEqual(len(rs), 3)
        values = tuple(evaluate_model(item, self.planner, self.methods,
                                      {"x": 4, "y": 5, "z": 9}) for item in rs)
        self.assertEqual(values, (5, 10, 6))

    def test_empty_group_remains_one_argument_in_wider_right(self):
        empty = Group((), self.owner)
        app = ref.normalize_expression(self.plan("op", 1, empty, 2), self.planner)[0]
        self.assertIs(app.left, ref.ABSENT)
        self.assertEqual(shape(app.right), (1, ("group", ()), 2))
        self.assertEqual(len(ref.expose_sequence(app.right, self.planner)), 3)
        actuals = ref.prepare_actuals(ref.ABSENT, 0, app.right, lambda x: x)
        self.assertIs(actuals.left, ref.ABSENT)
        self.assertEqual(len(actuals.right), 3)

    def test_normalized_singleton_raw_and_all_contexts_are_retained(self):
        foreign = object()
        inner = Group((7,), foreign)
        outer = Group((inner,), foreign, "S")
        link = Link(outer)
        atom = ref.normalize_expression(self.plan(link), self.planner)[0]
        self.assertEqual(shape(atom), 7)
        self.assertIs(atom.raw, link)
        self.assertIs(atom.origins[0].node, outer)
        self.assertIs(atom.origins[1].node, inner)
        self.assertIs(atom.value.context.lexical_parent, inner)
        self.assertIs(atom.value.context.activation, self.context.activation)
        self.assertIs(outer.parent, foreign)
        self.assertEqual(outer.items, (inner,))

    def test_shared_graph_references_remain_separate_occurrences(self):
        group = Group((1, "+", 2), object(), "S")
        first, second = Link(group), Link(group)
        app = ref.normalize_expression(self.plan("op", first, second), self.planner)[0]
        one, two = app.right
        self.assertIsNot(one, two)
        self.assertIsNot(one.value, two.value)
        self.assertIs(one.raw, first)
        self.assertIs(two.raw, second)
        self.assertIs(one.origins[0].node, two.origins[0].node)
        self.assertEqual(shape(one), shape(two))

    def test_cycle_is_retained_as_finite_prepared_graph_edge(self):
        group = Group((), object(), "S")
        link = Link(group)
        group.items = (link,)
        atom = ref.normalize_expression(self.plan(link), self.planner)[0]
        edge = ref.prepared_value(atom)
        self.assertIsInstance(edge, ref.PreparedGraphEdge)
        self.assertIs(edge.target.source.node, group)
        self.assertIs(ref.prepared_value(edge.target.items[0]), edge)
        self.assertIs(atom.raw, link)
        self.assertIs(group.items[0], link)

    def test_normalizer_preserves_receiver_without_executing_its_body(self):
        group = Group((), self.owner)
        receiver = Group(("undefined", "+", 1), group, "makeRecord")
        group.items = (receiver,)
        atom = ref.normalize_expression(self.plan(group), self.planner)[0]
        self.assertIsInstance(atom, ref.PreparedAtom)
        self.assertEqual(atom.value.kind, "receiver")
        self.assertIs(atom.value.node, receiver)
        self.assertIs(atom.raw, group)
        self.assertEqual(receiver.items, ("undefined", "+", 1))
        self.assertEqual(self.methods[id(self.ops["+"])].calls, [])

    def test_normalized_prefix_actuals_are_not_promoted_or_unified(self):
        prefix = ref.normalize_expression(self.plan(":=", "a", 1), self.planner)[0]
        infix = ref.normalize_expression(self.plan("a", ":=", 1), self.planner)[0]
        self.assertIs(prefix.left, ref.ABSENT)
        self.assertEqual(shape(prefix.right), ("a", 1))
        self.assertIsNot(infix.left, ref.ABSENT)
        self.assertEqual(shape(infix.right), (1,))
        for app in (prefix, infix):
            namespace = {}
            self.assertEqual(evaluate_model(app, self.planner, self.methods, namespace), 1)
            self.assertEqual(namespace, {"a": 1})
        self.assertEqual(self.store.received_shapes, [(True, 2), (False, 1)])


    def test_normalizing_prepared_plan_preserves_occurrence_identity(self):
        group = Group((3, "+", 4), self.owner)
        prepared = ref.normalize_expression(self.plan(2, "*", group), self.planner)
        again = ref.normalize_expression(prepared, self.planner)
        self.assertIs(again[0], prepared[0])
        self.assertIs(again[0].left, prepared[0].left)
        self.assertIs(again[0].right[0], prepared[0].right[0])
        self.assertEqual(self.methods[id(self.ops["+"])].calls, [])

    def test_source_graph_and_original_plan_stay_unchanged(self):
        group = Group((3, "+", 4), self.owner)
        outer = Group((2, "*", group), self.owner)
        before_fields = (outer.items, group.items, outer.parent, group.parent)
        original = self.planner.plan(outer, self.context)[0]
        original_atom = original.right[0]
        prepared = ref.normalize_expression((original,), self.planner)[0]
        self.assertIs(original.right[0], original_atom)
        self.assertEqual(original_atom.kind, "group")
        self.assertIs(prepared.right[0].origins[0], original_atom)
        self.assertEqual((outer.items, group.items, outer.parent, group.parent),
                         before_fields)
        self.assertIs(prepared.raw, original.raw)


if __name__ == "__main__":
    unittest.main(verbosity=2)
