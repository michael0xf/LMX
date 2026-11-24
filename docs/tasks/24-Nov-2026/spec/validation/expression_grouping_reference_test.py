"""Host-side checks of the reference planner; NOT execution of LMX."""

from dataclasses import dataclass
from pathlib import Path
import importlib.util
import sys
import unittest

path = Path(__file__).resolve().parents[1] / "tools/expression_grouping_reference.py"
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
    if isinstance(plan, ref.Unit):
        return plan.node if plan.kind == "atom" else plan.kind
    if isinstance(plan, ref.Apply):
        return (plan.operation.name, shape(plan.left), tuple(map(shape, plan.right)))
    return tuple(map(shape, plan))


class NumericMethod:
    """Tiny host method body; this is not LMX numeric semantics."""
    def __init__(self, function):
        self.function = function

    def invoke(self, left, right, namespace, evaluate):
        values = [] if left is ref.ABSENT else [evaluate(left.region)]
        values.extend(evaluate(item) for item in right)
        consumed = ref.ABSENT if left is ref.ABSENT else left.region
        return ref.MethodOutcome(self.function(values), consumed)


class StoreMethod:
    """The choice of equivalent forms occurs *inside this operand body*."""
    def __init__(self):
        self.received_shapes = []

    def invoke(self, left, right, namespace, evaluate):
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


def evaluate_model(plan, planner, methods, namespace, replacements=None):
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
        return evaluate_model(child, planner, methods, namespace, merged)
    if isinstance(plan, ref.Unit):
        if plan.kind == "group":
            units = planner.plan(plan.node, ref.Context(plan.node, plan.context.activation))
            if len(units) != 1: raise ValueError("not one complete expression")
            return evaluate(units[0])
        if plan.kind == "receiver":
            raise NotImplementedError("production receiver/call handling is external")
        return namespace[plan.node] if isinstance(plan.node, str) else plan.node
    return ref.receive_application(plan, methods[id(plan.operation)], namespace, evaluate)


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
        self.methods = {
            id(self.ops["+"]): NumericMethod(sum),
            id(self.ops["-"]): NumericMethod(lambda xs: -xs[0] if len(xs) == 1 else xs[0]-xs[1]),
            id(self.ops["*"]): NumericMethod(lambda xs: xs[0]*xs[1]),
            id(self.ops["**"]): NumericMethod(lambda xs: xs[0]**xs[1]),
            id(self.ops[":="]): self.store,
            id(self.ops["store"]): self.store,
        }

    def plan(self, *items):
        return self.planner.plan(Group(items, self.owner), self.context)

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
        app = self.plan(left, ":=", right)[0]
        ls = ref.expose_sequence((app.left.occurrence,), self.planner)
        rs = ref.expose_sequence(app.right, self.planner)
        actuals = ref.prepare_actuals(ls, rs, lambda x: x)
        self.assertEqual(shape(actuals.left.items), ("a", "b", "c"))
        self.assertEqual(shape(actuals.right), ("a", "c", "b"))
        self.assertIs(actuals.right[0].context.lexical_parent, right)
        self.assertIs(actuals.right[0].context.activation, self.context.activation)

    def test_three_sibling_groups_are_three_items(self):
        left = Group(("a", "b", "c"), self.owner)
        groups = [Group(("f", "g", "h"), self.owner) for _ in range(3)]
        app = self.plan(left, ":=", *groups)[0]
        rs = ref.expose_sequence(app.right, self.planner)
        self.assertEqual(len(rs), 3)
        self.assertTrue(all(isinstance(item, ref.Unit) for item in rs))

    def test_no_second_opening(self):
        inner = Group(("x", "y"), self.owner)
        outer = Group((inner,), self.owner)
        app = self.plan(Group(("target",), self.owner), ":=", outer)[0]
        rs = ref.expose_sequence(app.right, self.planner)
        self.assertEqual(len(rs), 1)
        self.assertIs(rs[0].node, inner)

    def test_rhs_expression_group_is_one_computed_unit(self):
        right = Group((2, "*", 3), self.owner)
        app = self.plan(Group(("target",), self.owner), ":=", right)[0]
        rs = ref.expose_sequence(app.right, self.planner)
        self.assertEqual(shape(rs), (("*", 2, (3,)),))

    def test_adapter_preserves_absence(self):
        actuals = ref.prepare_actuals(ref.ABSENT, (1, 2), lambda x: x)
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
        ref.group_assignment(("a", "b", "c"), ("a", "c", "b"),
                             values.__getitem__, validate, write)
        self.assertEqual(values, {"a": 1, "b": 3, "c": 2})

    def test_no_write_when_validation_fails(self):
        writes = []
        def reject(*args): raise ValueError("arity")
        with self.assertRaises(ValueError):
            ref.group_assignment(("a", "b"), (1,), lambda x: x,
                                 reject, lambda *args: writes.append(args))
        self.assertEqual(writes, [])

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


if __name__ == "__main__":
    unittest.main(verbosity=2)
