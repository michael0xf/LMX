"""New rank/initializer risks only; no production parser or runtime execution."""
import json
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from array_expression_reference import Array, RankDiagnostic, ShapeDiagnostic, array_value, lift, python_profile
from array_storage_reference import InitializerGroup as G, ValueOccurrence, scalar_offset, flat_selection, typed_initializer, ordinary_structure
from ternary_slices_reference import SliceSpec


def rows(values, origin):
    return G(tuple(G(tuple(row), (origin, i)) for i, row in enumerate(values)), origin)


def ints(region, rank=2, obtain=lambda value, context: value):
    return typed_initializer(region, rank, "int", obtain, lambda value: type(value) is int)


class StorageContracts(unittest.TestCase):
    def test_flat_and_rank_three_coordinates_share_one_place(self):
        source = Array(list(range(1, 9)), (2, 2, 2), "int")
        before = (id(source), id(source.storage), source.shape, source.element_type)
        self.assertEqual(scalar_offset(source, (5,)), scalar_offset(source, (1, 0, 1)))
        source.storage[scalar_offset(source, (5,))] = 42
        self.assertEqual(source.storage[scalar_offset(source, (1, 0, 1))], 42)
        self.assertEqual(before, (id(source), id(source.storage), source.shape, source.element_type))

    def test_existing_final_element_policy_does_not_gain_axis_checks(self):
        source = Array(list(range(6)), (2, 3), "int")
        self.assertEqual(scalar_offset(source, (0, 3)), scalar_offset(source, (1, 0)))
        self.assertEqual(scalar_offset(source, (0, 3)), 3)
        with self.assertRaises(ShapeDiagnostic):
            scalar_offset(source, (2, 0))

    def test_bad_flat_and_partial_coordinate_access(self):
        source = Array(list(range(8)), (2, 2, 2), "int")
        for index in (-1, 8):
            with self.assertRaises(ShapeDiagnostic):
                scalar_offset(source, (index,))
        for indexes in ((), (1, 0), (0, 0, 0, 0)):
            with self.assertRaises(RankDiagnostic):
                scalar_offset(source, indexes)
        # Only models unchecked native offset arithmetic, not a memory read.
        self.assertEqual(scalar_offset(source, (-1,), checked=False), -1)

    def test_flat_selection_retains_original_rank_and_type(self):
        source = Array(list(range(1, 9)), (2, 2, 2), "int")
        result = flat_selection(source, SliceSpec(1, 7, 2))
        self.assertEqual(result.values(), [2, 4, 6])
        self.assertEqual(result.shape, (3,))
        self.assertEqual(source.shape, (2, 2, 2))
        self.assertEqual(source.values(), list(range(1, 9)))
        self.assertEqual(source.element_type, result.element_type)

    def test_zero_extent_keeps_rank_without_a_probe_element(self):
        source = Array([], (2, 0, 3), "int")
        self.assertEqual(source.rank, 3)
        self.assertEqual(flat_selection(source, SliceSpec(step=-1)).shape, (0,))
        self.assertEqual(source.shape, (2, 0, 3))
        with self.assertRaises(ShapeDiagnostic):
            scalar_offset(source, (0,))

    def test_semicolon_and_grouped_rows_use_one_constructor(self):
        data = ((1, 2), (3, 4), (5, 6))
        semi, square = rows(data, "semicolon regions"), rows(data, "nested square regions")
        a, b = ints(semi), ints(square)
        self.assertEqual(a.shape, (3, 2))
        self.assertEqual((a.shape, a.values()), (b.shape, b.values()))
        self.assertEqual(semi.origin, "semicolon regions")
        self.assertEqual(square.origin, "nested square regions")

    def test_author_final_forms_have_equal_shape_and_values(self):
        data = ((1, 2, 3), (1, 2, 4), (1, 2, 3))
        first = ints(rows(data, "[a b c; a b d; a b c]"))
        second = ints(rows(data, "[[a b c] [a b d] [a b c]]"))
        self.assertEqual(first.shape, (3, 3))
        self.assertEqual((first.shape, first.values()), (second.shape, second.values()))

    def test_both_unequal_row_forms_diagnose_before_leaf_effects(self):
        for origin in ("semicolon regions", "nested square regions"):
            calls = []
            def obtain(value, context):
                calls.append(value)
                return value
            with self.assertRaises(ShapeDiagnostic):
                ints(rows(((1, 2, 3), (1, 2, 3, 4), (1, 2, 3, 4, 5)), origin), obtain=obtain)
            self.assertEqual(calls, [])

    def test_leaf_obtaining_is_once_in_source_context_and_order(self):
        calls, context = [], {"offset": 10}
        graph = rows(((ValueOccurrence(1, context), ValueOccurrence(2, context)),
                      (ValueOccurrence(3, context), ValueOccurrence(4, context))), "source")
        def obtain(node, scope):
            self.assertIs(scope, context)
            calls.append(node)
            return node + scope["offset"]
        result = ints(graph, obtain=obtain)
        self.assertEqual(calls, [1, 2, 3, 4])
        self.assertEqual(result.values(), [11, 12, 13, 14])

    def test_nested_call_and_literal_semicolons_are_opaque_to_consumer(self):
        call = object()
        graph = rows(((ValueOccurrence(call, "f(a;b)"), "literal;with:semicolon"),), "outer")
        calls = []
        def obtain(node, context):
            if node is call:
                calls.append(context)
                return "call result"
            return node
        result = typed_initializer(graph, 2, "@", obtain, lambda value: True)
        self.assertEqual(result.shape, (1, 2))
        self.assertEqual(result.values(), ["call result", "literal;with:semicolon"])
        self.assertEqual(calls, ["f(a;b)"])

    def test_rank_three_initializer_and_axis_depth_share_flat_store(self):
        graph = G((rows(((1, 2), (3, 4)), "layer0"), rows(((5, 6), (7, 8)), "layer1")), "cube")
        source = ints(graph, rank=3)
        self.assertEqual(source.shape, (2, 2, 2))
        self.assertEqual(source.storage, list(range(1, 9)))
        shifted = lift("+", source, 10, depth=3, profile=python_profile("int"))
        self.assertEqual(shifted.shape, source.shape)
        self.assertEqual(shifted.values(), list(range(11, 19)))
        self.assertEqual(source.values(), list(range(1, 9)))

    def test_inline_singleton_and_typed_reference_leaf_do_not_flatten(self):
        child = Array([10, 20], (2,), "int")
        outer = array_value([child])
        typed = typed_initializer(G((child,), "reference initializer"), 1, "@",
                                  lambda node, context: node, lambda value: True)
        self.assertEqual(outer.shape, (1,))
        self.assertEqual(outer.element_type, "@")
        self.assertIs(outer.storage[0], child)
        self.assertIs(typed.storage[0], child)
        child.storage[1] = 21
        self.assertEqual(outer.storage[0].storage[1], 21)
        empty = array_value([])
        self.assertEqual((empty.shape, empty.element_type), ((0,), "@"))

    def test_ordinary_data_fields_have_independent_sizes_for_both_source_forms(self):
        data = ((1, 2, 3), (1, 2, 4), (1, 2, 3, 4))
        results = []
        for origin in ("Struct: [a b c] [a b d] [a b c d]",
                       "Struct: (a b c) (a b d) (a b c d)"):
            calls = []
            def obtain(value, context):
                calls.append(value)
                return value
            result = ordinary_structure(rows(data, origin), obtain)
            self.assertEqual(result.shape, (3,))
            self.assertEqual([child.shape for child in result.values()], [(3,), (3,), (4,)])
            self.assertEqual(calls, [1, 2, 3, 1, 2, 4, 1, 2, 3, 4])
            results.append([child.values() for child in result.values()])
        self.assertEqual(results[0], results[1])

    def test_exact_author_unequal_three_three_four_typed_form_is_diagnostic(self):
        graph = rows(((1, 2, 3), (1, 2, 4), (1, 2, 3, 4)),
                     "int[][]: [[a b c] [a b d] [a b c d]]")
        calls = []
        def obtain(value, context):
            calls.append(value)
            return value
        with self.assertRaises(ShapeDiagnostic):
            ints(graph, obtain=obtain)
        self.assertEqual(calls, [])


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(StorageContracts)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    report = {
        "revision": "2026-11-26", "status": "PASS" if result.wasSuccessful() else "FAIL",
        "tests": result.testsRun, "failures": len(result.failures), "errors": len(result.errors),
        "scope": "New flat/nD access, rectangular initializer rows, ordinary DATA fields, inline identity; host only",
        "production_p0": "NOT_RUN", "production_translator": "NOT_RUN", "lmx_runtime": "NOT_RUN",
        "bounds": "Existing final scalar element check; no per-axis upper-bound restriction added",
        "metadata": "Host shape models arena metadata, not new Lmx fields",
        "initializer_parser": "NOT_RUN; row regions already supplied by common P0 in this model",
    }
    Path(__file__).with_name("array_storage_reference_report.json").write_text(json.dumps(report, indent=2) + "\n")
    raise SystemExit(not result.wasSuccessful())
