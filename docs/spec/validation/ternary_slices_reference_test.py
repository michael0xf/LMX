"""Contract tests; PASS here is not a production LMX parser/runtime result."""
from pathlib import Path
import json
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from ternary_slices_reference import (
    OMITTED, Group, Mark, RawOccurrence, SliceFailure, SliceSpec,
    assign_selection, check_known_scalar_index, conditional, evaluated_slice,
    normalize_slice, pair_conditionals, scalar_index_offset, slice_place,
    slice_values, split_index_fields, strict_slice_values,
)


class Contracts(unittest.TestCase):
    def failure(self, code, call):
        with self.assertRaises(SliceFailure) as caught:
            call()
        self.assertEqual(caught.exception.code, code)

    def test_author_examples(self):
        a = list(range(7))
        cases = [
            (SliceSpec(step=2), [0, 2, 4, 6]),
            (SliceSpec(step=-1), [6, 5, 4, 3, 2, 1, 0]),
            (SliceSpec(start=-3), [4, 5, 6]),
            (SliceSpec(stop=-2), [0, 1, 2, 3, 4]),
            (SliceSpec(5, 1, -1), [5, 4, 3, 2]),
            (SliceSpec(1, 6, 2), [1, 3, 5]),
            (SliceSpec(-4, -1), [3, 4, 5]),
        ]
        for spec, expected in cases:
            with self.subTest(spec=spec):
                self.assertEqual(slice_values(a, spec), expected)
        self.assertEqual(a, list(range(7)))

    def test_python_oracle_over_bounds_and_steps(self):
        bounds = [None, -20, -8, -1, 0, 1, 3, 8, 20]
        steps = [None, -9, -3, -1, 1, 2, 9]
        for length in range(13):
            source = list(range(length))
            for begin in bounds:
                for end in bounds:
                    for step in steps:
                        spec = SliceSpec(*(OMITTED if v is None else v
                                           for v in (begin, end, step)))
                        got = slice_values(source, spec)
                        expected = source[slice(begin, end, step)]
                        self.assertEqual(got, expected,
                                         (length, begin, end, step))

    def test_omitted_stop_is_not_minus_one(self):
        a = list(range(7))
        self.assertEqual(slice_values(a, SliceSpec(step=-1)), a[::-1])
        self.assertEqual(slice_values(a, SliceSpec(stop=-1, step=-1)), [])
        self.assertEqual(slice_values([], SliceSpec(step=-1)), [])

    def test_failures_and_exact_extreme_arithmetic(self):
        self.failure("SequenceStep", lambda: normalize_slice(5, SliceSpec(step=0)))
        self.failure("SequenceElement", lambda: normalize_slice(5, SliceSpec(step=1.5)))
        self.failure("SequenceSize", lambda: normalize_slice(5, SliceSpec(), max_length=4))
        self.failure("ReceiverIndex", lambda: strict_slice_values([1, 2], -1, 2))
        self.failure("ReceiverIndex", lambda: strict_slice_values([1, 2], 0, 3))
        huge = 10**150
        self.assertEqual(slice_values([1, 2, 3], SliceSpec(-huge, huge, huge)), [1])
        self.assertEqual(slice_values([1, 2, 3], SliceSpec(huge, -huge, -huge)), [3])

    def test_reference_identity_and_shared_body_profile(self):
        item = {"parent": object()}
        source = [item, item]
        out = slice_values(source, SliceSpec(step=-1))
        self.assertIsNot(out, source)
        self.assertIs(out[0], item)
        self.assertIs(out[0], out[1])
        self.assertEqual(strict_slice_values(source, 0, 2), out)

    def test_scalar_negative_never_means_from_end(self):
        self.failure("ReceiverIndex", lambda: check_known_scalar_index(-1))
        self.failure("ReceiverIndex", lambda: scalar_index_offset(7, -1))
        self.failure("ReceiverIndex", lambda: scalar_index_offset(7, 7))
        self.assertEqual(scalar_index_offset(7, -1, checked=False), -1)
        # The unchecked case calculates an invalid offset; no memory access.

    def test_only_selected_arm_runs_once(self):
        effects = []
        def raw(name, result):
            return RawOccurrence(lambda: (effects.append(name), result)[1])
        def forbidden():
            raise AssertionError("unused arm ran")
        self.assertEqual(conditional(raw("condition", 2), raw("yes", 17),
                                     RawOccurrence(forbidden)), 17)
        self.assertEqual(effects, ["condition", "yes"])
        self.assertEqual(conditional(raw("condition", 0), RawOccurrence(forbidden),
                                     raw("no", 23)), 23)
        self.assertEqual(effects, ["condition", "yes", "condition", "no"])
        self.failure("FxPredicate", lambda: conditional(raw("bad", []),
                                                       raw("yes", 1), raw("no", 2)))

    def test_nested_conditional_and_failure_propagation(self):
        called = []
        r = lambda value: RawOccurrence(lambda: value)
        inner = RawOccurrence(lambda: conditional(r(0), r(2),
                              RawOccurrence(lambda: (called.append("inner"), 3)[1])))
        self.assertEqual(conditional(r(0), r(1), inner), 3)
        self.assertEqual(called, ["inner"])
        def bad():
            raise SliceFailure("ChosenFailure", "selected branch")
        self.failure("ChosenFailure", lambda: conditional(r(1), RawOccurrence(bad), r(0)))

    def test_bounds_evaluate_in_order_and_reacquire_length(self):
        calls, values = [], [0, 1, 2]
        def source():
            calls.append("source")
            return values
        def begin():
            calls.append("start")
            values.append(3)
            return 0
        def step():
            calls.append("step")
            return 1
        self.assertEqual(evaluated_slice(RawOccurrence(source), RawOccurrence(begin),
                                        step=RawOccurrence(step)), [0, 1, 2, 3])
        self.assertEqual(calls, ["source", "start", "step"])

    def test_overlap_assignment_no_resize_and_preflight(self):
        a = [0, 1, 2, 3]
        place = slice_place(a, SliceSpec(step=-1))
        self.assertIs(assign_selection(place, a), a)
        self.assertEqual(a, [3, 2, 1, 0])
        place = slice_place(a, SliceSpec(1, 3))
        self.failure("FxShape", lambda: assign_selection(place, [9, 10, 11]))
        self.assertEqual(a, [3, 2, 1, 0])
        assign_selection(place, [9])
        self.assertEqual(a, [3, 9, 9, 0])
        assign_selection(place, 8, scalar=True)
        self.assertEqual(a, [3, 8, 8, 0])
        self.failure("FxShape", lambda: assign_selection(place, []))
        class UnreadSingleton:
            def __len__(self): return 1
            def __iter__(self): raise AssertionError("empty target read an RHS element")
        assign_selection(slice_place(a, SliceSpec(1, 1)), UnreadSingleton())
        self.assertEqual(a, [3, 8, 8, 0])
        place = slice_place(a, SliceSpec())
        a.append(7)
        self.failure("FxShape", lambda: assign_selection(place, [1] * 4))

    def test_admission_stops_later_bound_effects(self):
        effects = []
        def later():
            effects.append("unexpected")
            return 2
        self.failure("SequenceElement", lambda: evaluated_slice(
            RawOccurrence(lambda: [1, 2]), RawOccurrence(lambda: "bad"),
            RawOccurrence(later)))
        self.assertEqual(effects, [])

    def test_rhs_effects_cannot_change_selected_shape(self):
        a = [1, 2]
        place = slice_place(a, SliceSpec())
        def supplied():
            yield 9
            a.append(3)
            yield 8
        self.failure("FxShape", lambda: assign_selection(place, supplied()))
        self.assertEqual(a, [1, 2, 3])

    def test_structural_colon_context(self):
        C, Q = Mark.COLON, Mark.QUESTION
        self.assertEqual(split_index_fields((C, C, -1)), ((), (), (-1,)))
        self.assertEqual(split_index_fields((-3, C)), ((-3,), ()))
        self.assertEqual(split_index_fields(("x", ".:", "y", C, 6)),
                         (("x", ".:", "y"), (6,)))
        self.assertEqual(pair_conditionals(("a", Q, "b", ".:", "c", C, "d")),
                         {1: 5})
        group = Group(("f", "::", "int"))
        self.assertEqual(split_index_fields((group, C, 6)), ((group,), (6,)))
        self.assertEqual(split_index_fields(("flag", Q, 1, C, 2, C, 6)),
                         (("flag", Q, 1, C, 2), (6,)))
        self.failure("SliceSyntax", lambda: split_index_fields((C, C, C)))
        self.failure("ConditionalSyntax", lambda: split_index_fields(("x", Q, 1)))
        self.assertEqual(pair_conditionals(("a", Q, "b", Q, "c", C, "d", C, "e")),
                         {3: 5, 1: 7})
        self.assertEqual(pair_conditionals(("a", Q, "b", C, "c", Q, "d", C, "e")),
                         {1: 3, 5: 7})


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(Contracts)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    report = {
        "revision": "2026-11-27",
        "status": "PASS" if result.wasSuccessful() else "FAIL",
        "scope": "independent Python contract model: conditional demand, slice normalization, one-axis .: broadcast/preflight; not production LMX",
        "test_methods": result.testsRun,
        "python_slice_oracle_vectors": 13 * 9 * 9 * 7,
        "production_parser": "NOT_RUN",
        "production_translator": "NOT_RUN",
        "lmx_runtime": "NOT_RUN",
        "failures": len(result.failures), "errors": len(result.errors),
    }
    Path(__file__).with_name("ternary_slices_reference_report.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8")
    raise SystemExit(0 if result.wasSuccessful() else 1)
