"""Depth transport/short-circuit checks; not production parsing or execution."""
from pathlib import Path
import json
import sys
import unittest

TOOLS = Path(__file__).resolve().parents[1] / "tools"
sys.path.insert(0, str(TOOLS))
from operand_depth_reference import (
    DepthError, DepthExpression, admit_depth, prepare_operand_arguments,
    resolve_depth,
)
from ternary_slices_reference import RawOccurrence, conditional


class DepthContracts(unittest.TestCase):
    def test_ready_zero_one_and_large_values_are_numbers(self):
        for value in (0, 1, 2, 10, 1000):
            self.assertEqual(resolve_depth(value, lambda *args: self.fail("literal")), value)

    def test_expression_uses_original_node_and_context_once(self):
        expression, context, calls = object(), {"base": 1}, []
        def obtain(node, scope):
            self.assertIs(node, expression)
            self.assertIs(scope, context)
            calls.append(node)
            return scope["base"] + 9
        self.assertEqual(resolve_depth(DepthExpression(expression, context), obtain), 10)
        self.assertEqual(calls, [expression])

    def test_no_cache_across_invocations(self):
        scope = {"n": 0}
        source = DepthExpression("next", scope)
        def obtain(node, context):
            context["n"] += 1
            return context["n"]
        self.assertEqual(resolve_depth(source, obtain), 1)
        self.assertEqual(resolve_depth(source, obtain), 2)

    def test_left_absence_and_right_identity_are_preserved(self):
        absent, right = object(), [1, 2, 3]
        actuals = prepare_operand_arguments(absent, 2, right, None)
        self.assertIs(actuals.left, absent)
        self.assertIs(actuals.right, right)
        self.assertEqual(actuals.depth, 2)

    def test_nested_values_are_never_flattened_by_transport(self):
        left, right = [[1, 2], [3, 4]], [[[10, 20], [30, 40]]]
        actuals = prepare_operand_arguments(left, 2, right, None)
        self.assertIs(actuals.left, left)
        self.assertIs(actuals.right, right)
        self.assertEqual(len(actuals.right), 1)
        self.assertEqual(actuals.depth, 2)

    def test_invalid_value_has_no_implicit_conversion(self):
        for value in (-1, 1.0, True, "2", [], [1, 2], None):
            with self.assertRaises(DepthError):
                admit_depth(value)

    def test_depth_failure_is_not_converted_or_retried(self):
        error, calls = RuntimeError("source failure"), []
        def obtain(node, context):
            calls.append(node)
            raise error
        with self.assertRaises(RuntimeError) as caught:
            resolve_depth(DepthExpression("call", object()), obtain)
        self.assertIs(caught.exception, error)
        self.assertEqual(calls, ["call"])

    def test_unselected_conditional_arm_has_no_depth_effect(self):
        events = []
        source = DepthExpression("effect", object())
        def obtain(node, context):
            events.append("depth")
            return 2
        result = conditional(RawOccurrence(lambda: 0),
                             RawOccurrence(lambda: resolve_depth(source, obtain)),
                             RawOccurrence(lambda: 42))
        self.assertEqual(result, 42)
        self.assertEqual(events, [])

    def test_selected_conditional_arm_gets_depth_once(self):
        events = []
        def requested():
            return resolve_depth(DepthExpression("effect", events),
                                 lambda node, context: context.append(node) or 2)
        result = conditional(RawOccurrence(lambda: 1), RawOccurrence(requested),
                             RawOccurrence(lambda: self.fail("unused arm")))
        self.assertEqual(result, 2)
        self.assertEqual(events, ["effect"])

    def test_skipped_logical_rhs_has_no_depth_effect(self):
        events = []
        def rhs():
            return resolve_depth(DepthExpression("effect", events),
                                 lambda node, context: context.append(node) or 2)
        # Host stand-in for the existing lazy &&/|| demand boundary.
        self.assertEqual(0 and rhs(), 0)
        self.assertEqual(1 or rhs(), 1)
        self.assertEqual(events, [])


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(DepthContracts)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    report = {"revision": "2026-11-26", "status": "PASS" if result.wasSuccessful() else "FAIL",
              "tests": result.testsRun, "failures": len(result.failures),
              "errors": len(result.errors), "production_p0": "NOT_RUN",
              "production_translator": "NOT_RUN", "lmx_runtime": "NOT_RUN",
              "scope": "Common depth validation/transport/demand; no lexer or lifting copy",
              "invalid_depth": "Translator/interpreter diagnostic; not a catchable LMX throw"}
    Path(__file__).with_name("operand_depth_reference_report.json").write_text(
        json.dumps(report, indent=2) + "\n")
    raise SystemExit(not result.wasSuccessful())
