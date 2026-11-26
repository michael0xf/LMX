#!/usr/bin/env python3
"""Acceptance examples for the reference model, not an LMX runtime test."""

from decimal import Decimal, localcontext
import json
from pathlib import Path
import sys
import unittest

from array_expression_reference import (
    AliasDiagnostic, Array, Cell, FusionDiagnostic, Metrics, ProfileDiagnostic, ProfileError, RankDiagnostic,
    ScalarCall, ScalarProfile, Select, ShapeDiagnostic, assign, assign_places,
    assign_depth, array_literal, array_value, compound, dot, evaluate, fuse, increment, lift, matmul,
    op, ordinary, python_profile,
)

from operand_depth_reference import DepthError, DepthExpression


class ArrayExpressionTests(unittest.TestCase):
    def setUp(self):
        # Python true division can return a non-integer; these general fixtures
        # intentionally provide no uniform dense result type.
        self.profile = python_profile()

    @staticmethod
    def nested(rows, admission=None):
        return Array([Array(list(row), (len(row),), "int", admission=admission) for row in rows],
                     (len(rows),), "@", dense=False)

    @staticmethod
    def plain(value):
        return [ArrayExpressionTests.plain(item) for item in value.values()] if isinstance(value, Array) else value

    def test_depth_zero_one_two_select_the_base_profile(self):
        flat_a, flat_b = Array([1, 2], (2,), "int"), Array([3, 4], (2,), "int")
        self.assertEqual(lift("*", flat_a, flat_b, depth=0, profile=self.profile), 11)
        self.assertEqual(lift("*", flat_a, flat_b, depth=1, profile=self.profile).values(), [3, 8])
        a, b = self.nested([[1, 2], [3, 4]]), self.nested([[10, 20], [30, 40]])
        self.assertEqual(self.plain(lift("*", a, b, depth=1, profile=self.profile)), [50, 250])
        self.assertEqual(self.plain(lift("*", a, b, depth=2, profile=self.profile)), [[10, 40], [90, 160]])

    def test_depth_consumes_retained_flat_axes(self):
        a, b = Array([1, 2, 3, 4], (2, 2), "int"), Array([5, 6, 7, 8], (2, 2), "int")
        self.assertEqual(lift("*", a, b, depth=0, profile=self.profile).values(), [19, 22, 43, 50])
        self.assertEqual(lift("*", a, b, depth=1, profile=self.profile).values(), [17, 53])
        result = lift("*", a, b, depth=2, profile=self.profile)
        self.assertEqual(result.values(), [5, 12, 21, 32])
        self.assertEqual(result.shape, (2, 2))
        self.assertFalse(any(isinstance(item, Array) for item in result.storage))
        with self.assertRaises(DepthError):
            lift("*", a, b, depth=3, profile=self.profile)

    def test_axis_slices_share_flat_storage_without_row_values(self):
        cube = Array(list(range(8)), (2, 2, 2), "int")
        plane, row = cube.axis_at(1), cube.axis_at(1).axis_at(0)
        self.assertIs(plane.storage, cube.storage)
        self.assertIs(row.storage, cube.storage)
        self.assertEqual(plane.shape, (2, 2))
        self.assertEqual(row.values(), [4, 5])
        self.assertEqual(cube.flat_get(5), cube.get((1, 0, 1)))
        cube.flat_set(5, 99)
        self.assertEqual(row.get((1,)), 99)
        self.assertEqual(cube.shape, (2, 2, 2))
        self.assertFalse(any(isinstance(item, Array) for item in cube.storage))

    def test_flat_axis_outputs_have_only_one_result_allocation(self):
        a, b = Array([1, 2, 3, 4], (2, 2)), Array([5, 6, 7, 8], (2, 2))
        for depth in (1, 2):
            metrics = Metrics()
            lift("*", a, b, depth=depth, profile=self.profile, metrics=metrics)
            self.assertEqual(metrics.array_allocations, 1)
        self.assertEqual(lift("+", a, b, depth=1, profile=self.profile).shape, (2, 2))

    def test_flat_rank_three_depth_three_and_scalar_broadcast(self):
        cube = Array(list(range(8)), (2, 2, 2), "int")
        result = lift("*", cube, 10, depth=3, profile=self.profile)
        self.assertEqual(result.shape, cube.shape)
        self.assertEqual(result.values(), [10 * value for value in range(8)])
        with self.assertRaises(DepthError):
            lift("*", cube, 10, depth=4, profile=self.profile)

    def test_empty_flat_axes_preserve_shape_without_scalar_probe(self):
        calls = []
        profile = ScalarProfile({"+": lambda a, b: calls.append((a, b)) or a + b}, "int",
                                pure_methods=frozenset({"+"}))
        empty = Array([], (0, 3), "int")
        self.assertEqual(lift("+", empty, 1, depth=2, profile=profile).shape, (0, 3))
        self.assertEqual(fuse(op("+", empty, 1, depth=2), profile=profile).shape, (0, 3))
        self.assertEqual(calls, [])

    def test_flat_axis_fuse_uses_one_output_and_diagnoses_row_contraction(self):
        a, b = Array([1, 2, 3, 4], (2, 2)), Array([5, 6, 7, 8], (2, 2))
        metrics = Metrics()
        result = fuse(op("+", op("*", a, b, depth=2), 1, depth=2),
                      profile=self.profile, metrics=metrics)
        self.assertEqual(result.shape, (2, 2))
        self.assertEqual(result.values(), [6, 13, 22, 33])
        self.assertEqual((metrics.output_passes, metrics.output_elements, metrics.array_allocations), (1, 4, 1))
        with self.assertRaises(FusionDiagnostic):
            fuse(op(".*", a, b), profile=self.profile)

    def test_flat_axis_fused_assignment_preserves_backing(self):
        matrix = Array([1, 2, 3, 4], (2, 2), "int")
        backing, metrics = matrix.storage, Metrics()
        fuse(op("*", matrix, 10, depth=2), destination=matrix, destination_depth=2,
             profile=self.profile, metrics=metrics)
        self.assertIs(matrix.storage, backing)
        self.assertEqual(matrix.values(), [10, 20, 30, 40])
        self.assertEqual(metrics.array_allocations, 0)

    def test_flat_row_assignment_captures_complete_aliasing_blocks(self):
        matrix = Array([1, 2, 3, 4], (2, 2), "int")
        reverse_rows = Array(matrix.storage, (2, 2), "int", offset=2, strides=(-2, 1))
        assign(matrix, reverse_rows, depth=1)
        self.assertEqual(matrix.values(), [3, 4, 1, 2])
        self.assertEqual(matrix.shape, (2, 2))
        self.assertFalse(any(isinstance(item, Array) for item in matrix.storage))

    def test_flat_scalar_fill_selects_cells_not_row_rebinding(self):
        matrix = Array([1, 2, 3, 4], (2, 2), "int")
        with self.assertRaises(ProfileError):
            assign(matrix, 9, depth=1)
        self.assertEqual(matrix.values(), [1, 2, 3, 4])
        assign(matrix, 9, depth=2)
        self.assertEqual(matrix.values(), [9, 9, 9, 9])

    def test_sole_rank_two_rhs_supplies_whole_row_values_to_binding_places(self):
        matrix = Array([1, 2, 3, 4], (2, 2), "int")
        first, second = Cell(None), Cell(None)
        assign_places([first, second], [matrix])
        self.assertEqual(first.value.values(), [1, 2])
        self.assertEqual(second.value.values(), [3, 4])
        self.assertIsNot(first.value.storage, matrix.storage)
        self.assertEqual(matrix.shape, (2, 2))

    def test_inline_array_keeps_whole_child_and_identity(self):
        child = Array([100, 200], (2,), "int")
        outer = evaluate(array_literal(child), profile=self.profile)
        self.assertEqual(outer.shape, (1,))
        self.assertEqual(outer.element_type, "@")
        self.assertIs(outer.get((0,)), child)
        self.assertEqual(evaluate(array_literal(), profile=self.profile).shape, (0,))

    def test_inline_scalar_prefix_chain_preserves_eager_order(self):
        events = []
        def call(label, value):
            return ScalarCall(lambda: events.append(label) or value)
        profile = ScalarProfile({"+": lambda a, b: events.append(f"{a}+{b}") or a + b})
        expr = op("+", op("+", op("+", call("a", 1), call("b", 2)),
                                array_literal(call("x", 10), call("y", 20))), call("d", 4))
        self.assertEqual(evaluate(expr, profile=profile).values(), [17, 27])
        self.assertEqual(events, ["a", "b", "1+2", "x", "y", "3+10", "3+20", "d", "13+4", "23+4"])

    def test_inline_prefix_failure_skips_constructor_and_later_operands(self):
        events = []
        def add(a, b):
            events.append("add")
            raise ArithmeticError("ordinary selected numeric failure")
        expression = op("+", op("+", 1, 2), array_literal(ScalarCall(lambda: events.append("literal") or 10)))
        with self.assertRaises(ArithmeticError):
            evaluate(expression, profile=ScalarProfile({"+": add}))
        self.assertEqual(events, ["add"])

    def test_inline_singleton_child_chain_and_no_implicit_broadcast(self):
        arr0, arr1 = array_value([Array([1, 2], (2,))]), array_value([Array([10, 20], (2,))])
        arr2 = Array([100, 200], (2,))
        expression = op(".+", op(".+", arr0, arr1), array_literal(arr2))
        answer = evaluate(expression, profile=self.profile)
        self.assertEqual(self.plain(answer), [[111, 222]])
        self.assertEqual(arr2.values(), [100, 200])
        self.assertEqual(self.plain(fuse(expression, profile=self.profile)), [[111, 222]])
        with self.assertRaises(ShapeDiagnostic):
            evaluate(op(".+", array_value([arr2, arr2]), array_literal(arr2)), profile=self.profile)

    def test_original_scalar_fixed_point_and_nested_broadcast(self):
        self.assertEqual(lift("+", 2, 3, depth=10, profile=self.profile), 5)
        a = self.nested([[1, 2], [3]])
        self.assertEqual(self.plain(lift("+", a, 10, depth=2, profile=self.profile)), [[11, 12], [13]])

    def test_mismatch_and_excess_depth_are_diagnostics(self):
        nested, flat = self.nested([[1, 2], [3, 4]]), Array([10, 20], (2,), "int")
        with self.assertRaises(DepthError):
            lift("*", nested, flat, depth=2, profile=self.profile)
        with self.assertRaises(DepthError):
            lift("+", flat, 1, depth=2, profile=self.profile)
        # At remaining zero, the base profile owns consumption: Array/scalar
        # multiplication is scaling, not another implicit lifting level.
        self.assertEqual(self.plain(lift("*", nested, flat, depth=1, profile=self.profile)),
                         [[10, 20], [60, 80]])

    def test_custom_value_base_receives_whole_values(self):
        a = self.nested([[1, 2], [3, 4]])
        calls = []
        def base(value):
            calls.append(value)
            return len(value.storage)
        self.assertEqual(lift("inspect", a, depth=0, profile=self.profile, base=base), 2)
        self.assertIs(calls[0], a)
        calls.clear()
        self.assertEqual(lift("inspect", a, depth=1, profile=self.profile, base=base).values(), [2, 2])
        self.assertIs(calls[0], a.get((0,)))
        self.assertIs(calls[1], a.get((1,)))

    def test_void_lifting_has_no_array_of_void(self):
        events, metrics = [], Metrics()
        profile = ScalarProfile({"visit": lambda value: events.append(value)})
        answer = lift("visit", self.nested([[1, 2], [3]]), depth=2, profile=profile,
                      has_result=False, metrics=metrics)
        self.assertIsNone(answer)
        self.assertEqual(events, [1, 2, 3])
        self.assertEqual(metrics.array_allocations, 0)

    def test_dynamic_depth_is_demanded_once_and_skipped_with_branch(self):
        events = []
        depth = DepthExpression(ScalarCall(lambda: events.append("depth") or 2), context={})
        a = self.nested([[1, 2], [3, 4]])
        expression = op("+", a, 1, depth=depth)
        self.assertEqual(self.plain(fuse(expression, profile=self.profile)), [[2, 3], [4, 5]])
        self.assertEqual(events, ["depth"])
        self.assertEqual(fuse(Select(0, expression, 7), profile=self.profile), 7)
        self.assertEqual(events, ["depth"])
        fuse(expression, profile=self.profile)
        self.assertEqual(events, ["depth", "depth"])

    def test_dynamic_depth_integer_admission_uses_common_transport(self):
        for value in [-1, 1.5, True]:
            with self.subTest(value=value), self.assertRaises(DepthError):
                fuse(op("+", Array([1], (1,)), 2,
                        depth=DepthExpression(value, None)), profile=self.profile)

    def test_deep_assignment_captures_cross_branch_aliases(self):
        target = self.nested([[1, 2], [3, 4]])
        first, second = target.get((0,)), target.get((1,))
        source = Array([second, first], (2,), "@", dense=False)
        assign(target, source, depth=2)
        self.assertEqual(self.plain(target), [[3, 4], [1, 2]])
        self.assertIs(target.get((0,)), first)
        self.assertIs(target.get((1,)), second)

    def test_deep_assignment_checks_later_shape_and_admission_before_writes(self):
        for source in [self.nested([[10, 20], [30]]), self.nested([[10, 20], [30, 99]])]:
            target = self.nested([[1, 2], [3, 4]], admission=lambda value: value < 90)
            with self.assertRaises((ShapeDiagnostic, ProfileError)):
                assign(target, source, depth=2)
            self.assertEqual(self.plain(target), [[1, 2], [3, 4]])

    def test_assignment_depth_zero_rebinds_and_depth_one_replaces_whole_slots(self):
        old = self.nested([[1, 2], [3, 4]])
        new = self.nested([[10, 20], [30, 40]])
        binding = Cell(old)
        self.assertIs(assign_depth(binding, new, depth=0), new)
        self.assertIs(binding.value, new)
        self.assertEqual(self.plain(old), [[1, 2], [3, 4]])
        assign(old, new, depth=1)
        self.assertIs(old.get((0,)), new.get((0,)))
        # Reached PLACE depth zero accepts a new type when the place admits it.
        assign(old, Array([7, 8], (2,), "int"), depth=1)
        self.assertEqual(old.values(), [7, 8])
        scalar = Cell(1)
        self.assertEqual(assign_depth(scalar, 2, depth=10), 2)

    def test_deep_fuse_has_one_leaf_pass_and_only_result_containers(self):
        a, b = self.nested([[1, 2], [3, 4]]), self.nested([[10, 20], [30, 40]])
        metrics = Metrics()
        result = fuse(op("+", op("*", a, b, depth=2), 1, depth=2),
                      profile=self.profile, metrics=metrics)
        self.assertEqual(self.plain(result), [[11, 41], [91, 161]])
        self.assertEqual(metrics.output_passes, 1)
        self.assertEqual(metrics.output_elements, 4)
        self.assertEqual(metrics.array_allocations, 3)  # outer plus two result children
        self.assertEqual(metrics.scalar_operations, 8)

    def test_deep_inplace_fuse_preserves_all_target_containers(self):
        target = self.nested([[1, 2], [3, 4]])
        children, metrics = target.values(), Metrics()
        fuse(op("+", op("*", target, 2, depth=2), 1, depth=2), profile=self.profile,
             destination=target, destination_depth=2, metrics=metrics)
        self.assertEqual(self.plain(target), [[3, 5], [7, 9]])
        self.assertTrue(all(x is y for x, y in zip(children, target.values())))
        self.assertEqual(metrics.output_passes, 1)
        self.assertEqual(metrics.array_allocations, 0)

    def test_deep_fuse_rejects_cross_branch_aliases_before_writes(self):
        target = self.nested([[1, 2], [3, 4]])
        swapped = Array(list(reversed(target.values())), (2,), "@", dense=False)
        with self.assertRaises(AliasDiagnostic):
            fuse(op("+", swapped, 1, depth=2), profile=self.profile,
                 destination=target, destination_depth=2)
        self.assertEqual(self.plain(target), [[1, 2], [3, 4]])

    def test_deep_fuse_does_not_accidentally_contract_or_overdescend(self):
        a, b = self.nested([[1, 2], [3, 4]]), self.nested([[10, 20], [30, 40]])
        with self.assertRaises(FusionDiagnostic):
            fuse(op("*", a, b, depth=1), profile=self.profile)
        with self.assertRaises(DepthError):
            fuse(op("*", a, b, depth=3), profile=self.profile)

    def test_base_profile_scalar_register_is_reused_within_child_output(self):
        shallow = Array([1, 2], (2,), "int")
        nested = self.nested([[10, 20], [30, 40]])
        metrics = Metrics()
        expression = op("+", op("+", shallow, 1, depth=1), nested, depth=1)
        result = fuse(expression, profile=self.profile, metrics=metrics)
        self.assertEqual(self.plain(result), [[12, 22], [33, 43]])
        self.assertEqual(metrics.scalar_operations, 6)

    def test_deep_fused_late_admission_keeps_only_written_prefix(self):
        target = self.nested([[1, 2], [3, 4]], admission=lambda value: value < 8)
        with self.assertRaises(ProfileError):
            fuse(op("+", op("*", target, 2, depth=2), 1, depth=2), profile=self.profile,
                 destination=target, destination_depth=2)
        self.assertEqual(self.plain(target), [[3, 5], [7, 4]])

    def test_repeated_dots_are_not_a_depth_notation(self):
        with self.assertRaises(ProfileDiagnostic):
            dot("..+", Array([1], (1,)), 2, profile=self.profile)
        with self.assertRaises(FusionDiagnostic):
            fuse(op("..+", Array([1], (1,)), 2), profile=self.profile)

    def test_deep_void_preparation_diagnoses_before_source_effects(self):
        events = []
        source = Array([Array([1, 2], (2,), "int"), 3], (2,), "@", dense=False)
        with self.assertRaises(DepthError):
            lift("visit", source, depth=2,
                 profile=ScalarProfile({"visit": lambda value: events.append(value)}),
                 has_result=False)
        self.assertEqual(events, [])

    def test_deep_compound_and_postfix_share_update_and_preserve_old_values(self):
        target = self.nested([[1, 2], [3, 4]])
        compound(target, ".+=", 10, depth=2, profile=self.profile)
        old = increment(target, depth=2, postfix=True, profile=self.profile)
        self.assertEqual(self.plain(old), [[11, 12], [13, 14]])
        self.assertEqual(self.plain(target), [[12, 13], [14, 15]])
        self.assertIsNot(old.get((0,)), target.get((0,)))
        binding = Cell(3)
        self.assertEqual(increment(binding, depth=0, postfix=True, profile=self.profile), 3)
        self.assertEqual(binding.value, 4)

    def test_matrix_product_plus_e(self):
        a = Array([1, 2, 3, 4], (2, 2), "int")
        b = Array([5, 6, 7, 8], (2, 2), "int")
        e = Array([1, 1, 1, 1], (2, 2), "int")
        result = ordinary("+", ordinary("*", a, b, profile=self.profile), e, profile=self.profile)
        self.assertEqual(result.values(), [20, 23, 44, 51])
        self.assertEqual(result.shape, (2, 2))
        self.assertEqual(a.values(), [1, 2, 3, 4])

    def test_dot_product_is_different_from_matrix_product(self):
        a = Array([1, 2, 3, 4], (2, 2), "int")
        b = Array([5, 6, 7, 8], (2, 2), "int")
        self.assertEqual(dot(".*", a, b, profile=self.profile).values(), [17, 53])
        self.assertEqual(dot("*", a, b, depth=2, profile=self.profile).values(), [5, 12, 21, 32])

    def test_rectangular_product_plus_e(self):
        a = Array([1, 2, 3, 4, 5, 6], (2, 3), "int")
        b = Array([7, 8, 9, 10, 11, 12], (3, 2), "int")
        e = Array([1, 2, 3, 4], (2, 2), "int")
        result = ordinary("+", ordinary("*", a, b, profile=self.profile), e, profile=self.profile)
        self.assertEqual(result.values(), [59, 66, 142, 158])
        self.assertEqual(result.shape, (2, 2))

    def test_reference_structure_numeric_cells_and_heterogeneous_rejection(self):
        a = Array([1, 2], (2,), "@", dense=False)
        b = Array([3, 4], (2,), "@", dense=False)
        self.assertEqual(ordinary("*", a, b, profile=self.profile), 11)
        with self.assertRaises(TypeError):
            dot(".+", Array([1, "not numeric"], (2,), "@", dense=False), 1, profile=self.profile)

    def test_dotted_equality_is_comparison_not_assignment(self):
        a = Array([Decimal("1"), Decimal("2")], (2,), "decimal")
        b = Array([Decimal("1"), Decimal("3")], (2,), "decimal")
        result = dot(".=", a, b, profile=python_profile("decimal"))
        self.assertEqual(result.values(), [1, 0])
        self.assertEqual(result.element_type, "int")
        self.assertEqual(a.values(), [Decimal("1"), Decimal("2")])

    def test_all_dotted_comparisons(self):
        a = Array([1, 2, 3], (3,), "int")
        expected = {
            ".=": [0, 1, 0], ".!=": [1, 0, 1], ".<": [1, 0, 0],
            ".<=": [1, 1, 0], ".>": [0, 0, 1], ".>=": [0, 1, 1],
        }
        for name, values in expected.items():
            with self.subTest(name=name):
                self.assertEqual(dot(name, a, 2, profile=self.profile).values(), values)

    def test_vector_dot_matrix_vector_and_vector_matrix(self):
        a = Array([1, 2, 3, 4, 5, 6], (2, 3), "int")
        right = Array([10, 20, 30], (3,), "int")
        left = Array([10, 20], (2,), "int")
        self.assertEqual(matmul(a, right, profile=self.profile).values(), [140, 320])
        self.assertEqual(matmul(left, a, profile=self.profile).values(), [90, 120, 150])
        self.assertEqual(matmul(right, right, profile=self.profile), 1400)

    def test_empty_contraction_uses_provider_identity(self):
        p = python_profile("decimal", zero=lambda: Decimal("0"))
        a = Array([], (2, 0), "decimal")
        b = Array([], (0, 3), "decimal")
        result = matmul(a, b, profile=p)
        self.assertEqual(result.shape, (2, 3))
        self.assertEqual(result.values(), [Decimal("0")] * 6)
        self.assertIsInstance(result.values()[0], Decimal)
        self.assertEqual(matmul(Array([], (0,)), Array([], (0,)), profile=p), Decimal("0"))

    def test_empty_rectangular_result_runs_no_scalar_methods(self):
        events = []
        p = ScalarProfile(
            {"+": lambda a, b: events.append("+") or a + b,
             "*": lambda a, b: events.append("*") or a * b},
            "int", zero=lambda: events.append("zero") or 0,
            pure_methods=frozenset({"+", "*"}),
        )
        result = matmul(Array([], (0, 3), "int"), Array([1, 2, 3, 4, 5, 6], (3, 2), "int"), profile=p)
        self.assertEqual(result.shape, (0, 2))
        self.assertEqual(result.values(), [])
        self.assertEqual(events, [])

    def test_missing_empty_identity_is_a_profile_error(self):
        with self.assertRaises(ProfileDiagnostic):
            matmul(Array([], (0,)), Array([], (0,)), profile=python_profile(zero=None))

    def test_shape_and_rank_rejection(self):
        with self.assertRaises(ShapeDiagnostic):
            matmul(Array([1, 2], (1, 2)), Array([1, 2], (1, 2)), profile=self.profile)
        with self.assertRaises(RankDiagnostic):
            matmul(Array([1], (1, 1, 1)), Array([1], (1,)), profile=self.profile)

    def test_shape_not_inferred_from_total_length(self):
        with self.assertRaises(ShapeDiagnostic):
            dot(".+", Array([1, 2, 3, 4], (2, 2)), Array([1, 2, 3, 4], (4,)), profile=self.profile)

    def test_singleton_array_is_not_scalar_broadcast(self):
        with self.assertRaises(ShapeDiagnostic):
            dot(".+", Array([1, 2, 3], (3,)), Array([10], (1,)), profile=self.profile)
        self.assertEqual(dot(".+", Array([1, 2, 3], (3,)), 10, profile=self.profile).values(), [11, 12, 13])

    def test_scalar_expansion_preserves_order(self):
        a = Array([2, 4], (2,), "int")
        self.assertEqual(dot(".-", 10, a, profile=self.profile).values(), [8, 6])
        self.assertEqual(dot("./", 8, a, profile=self.profile).values(), [4, 2])
        self.assertEqual(ordinary("*", 3, a, profile=self.profile).values(), [6, 12])

    def test_all_builtin_arithmetic_and_bitwise_scalar_methods(self):
        p = self.profile
        left = Array([5, 6], (2,), "int")
        expected = {
            ".+": [7, 8], ".-": [3, 4], ".*": [10, 12], "./": [2.5, 3],
            ".%": [1, 0], ".**": [25, 36], ".<<": [20, 24], ".>>": [1, 1],
            ".&": [0, 2], ".|": [7, 6], ".^": [7, 4],
        }
        for name, result in expected.items():
            with self.subTest(name=name):
                self.assertEqual(dot(name, left, 2, profile=p).values(), result)
        self.assertEqual(dot(".~", left, profile=p).values(), [-6, -7])
        self.assertEqual(dot(".-", left, profile=p).values(), [-5, -6])
        self.assertEqual(dot(".+", left, profile=p).values(), [5, 6])

    def test_big_integers_are_not_narrowed(self):
        value = 2 ** 200
        result = fuse(op(".+", Array([value], (1,), "bigint"), value), profile=python_profile("bigint"))
        self.assertEqual(result.values(), [2 ** 201])

    def test_decimal_context_and_type_are_retained(self):
        with localcontext() as context:
            context.prec = 50
            p = python_profile("decimal", zero=lambda: Decimal(0))
            a = Array([Decimal("0.1"), Decimal("0.2")], (2,), "decimal")
            result = fuse(op(".+", op(".*", a, Decimal("3")), Decimal("0.1")), profile=p)
            self.assertEqual(result.values(), [Decimal("0.4"), Decimal("0.7")])
            self.assertTrue(all(isinstance(x, Decimal) for x in result.values()))

    def test_no_first_element_probe_on_empty_input(self):
        calls = []
        p = ScalarProfile({"+": lambda a, b: calls.append((a, b)) or a + b},
                          "custom", pure_methods=frozenset({"+"}))
        result = fuse(op(".+", Array([], (0,), "custom"), 1), profile=p)
        self.assertEqual(result.element_type, "custom")
        self.assertEqual(calls, [])

    def test_no_result_type_inference_from_first_value(self):
        a = Array([1, 2], (2,), "int")
        result = dot(".+", a, 1, profile=python_profile())
        self.assertFalse(result.dense)
        self.assertEqual(result.element_type, "@")

    def test_reference_array_remains_reference_result(self):
        a = Array([1, 2], (2,), "@", dense=False)
        result = fuse(op(".+", a, 1), profile=python_profile("int"))
        self.assertFalse(result.dense)

    def test_fuse_single_pass_and_one_result_allocation(self):
        a = Array([1, 2, 3], (3,), "int")
        b = Array([10, 20, 30], (3,), "int")
        e = Array([4, 5, 6], (3,), "int")
        metrics = Metrics()
        result = fuse(op(".+", op(".*", a, b), e), profile=self.profile, metrics=metrics)
        self.assertEqual(result.values(), [14, 45, 96])
        self.assertEqual(metrics.output_passes, 1)
        self.assertEqual(metrics.output_elements, 3)
        self.assertEqual(metrics.array_allocations, 1)
        self.assertEqual(metrics.scalar_operations, 6)

    def test_eager_dot_expression_has_two_passes_and_two_arrays(self):
        a = Array([1, 2, 3], (3,), "int")
        metrics = Metrics()
        result = dot(".+", dot(".*", a, 2, profile=self.profile, metrics=metrics),
                     1, profile=self.profile, metrics=metrics)
        self.assertEqual(result.values(), [3, 5, 7])
        self.assertEqual(metrics.output_passes, 2)
        self.assertEqual(metrics.array_allocations, 2)

    def test_fuse_rejects_contraction(self):
        a = Array([1, 2, 3, 4], (2, 2), "int")
        with self.assertRaises(FusionDiagnostic):
            fuse(op("*", a, a), profile=self.profile)
        self.assertEqual(fuse(op("*", a, 2), profile=self.profile).values(), [2, 4, 6, 8])

    def test_fused_unary_purity_checks_the_actual_selected_method(self):
        values = Array([2, -3], (2,), "int")
        for sign, selected, method, expected in (
            ("+", "pos", lambda value: +value, [2, -3]),
            ("-", "neg", lambda value: -value, [-2, 3]),
        ):
            with self.subTest(sign=sign):
                unary_only = ScalarProfile(
                    {selected: method}, "int", pure_methods=frozenset({selected})
                )
                self.assertEqual(fuse(op("." + sign, values), profile=unary_only).values(), expected)
                calls = []
                binary_only_pure = ScalarProfile(
                    {sign: lambda left, right: left + right,
                     selected: lambda value: calls.append(value) or value},
                    pure_methods=frozenset({sign}),
                )
                with self.assertRaises(FusionDiagnostic):
                    fuse(op("." + sign, values), profile=binary_only_pure)
                self.assertEqual(calls, [])

    def test_unknown_kernel_effects_are_not_executed(self):
        events = []
        p = ScalarProfile({"touch": lambda value: events.append(value) or value})
        with self.assertRaises(FusionDiagnostic):
            fuse(op(".touch", Array([1, 2], (2,))), profile=p)
        self.assertEqual(events, [])

    def test_explicit_fused_failure_order_is_coordinate_then_tree(self):
        class DivideFault(Exception):
            pass
        class RemainderFault(Exception):
            pass
        def divide(a, b):
            if b == 0:
                raise DivideFault()
            return a / b
        def remainder(a, b):
            if b == 0:
                raise RemainderFault()
            return a % b
        p = ScalarProfile({"/": divide, "%": remainder, "+": lambda a, b: a + b},
                          pure_methods=frozenset({"/", "%", "+"}))
        numerator = Array([4, 4], (2,))
        divisor = Array([2, 0], (2,))
        modulus = Array([0, 2], (2,))
        with self.assertRaises(DivideFault):
            dot("./", numerator, divisor, profile=p)
        with self.assertRaises(RemainderFault):
            fuse(op(".+", op("./", numerator, divisor),
                    op(".%", numerator, modulus)), profile=p)

    def test_scalar_captures_run_once_in_source_order(self):
        events = []
        a = Array([1, 2], (2,), "int")
        metrics = Metrics()
        expr = op(".+", op(".*", a, ScalarCall(lambda: events.append("scale") or 3)),
                  ScalarCall(lambda: events.append("bias") or 10))
        result = fuse(expr, profile=self.profile, metrics=metrics)
        self.assertEqual(result.values(), [13, 16])
        self.assertEqual(events, ["scale", "bias"])
        self.assertEqual(metrics.scalar_calls, 2)

    def test_shared_python_node_does_not_merge_written_occurrences(self):
        events = []
        call = ScalarCall(lambda: events.append("call") or 1)
        result = fuse(op(".+", op(".+", Array([0], (1,)), call), call), profile=self.profile)
        self.assertEqual(result.values(), [2])
        self.assertEqual(events, ["call", "call"])

    def test_scalar_subtree_is_obtained_once_even_for_empty_array(self):
        events = []
        p = ScalarProfile({"+": lambda a, b: events.append("scalar add") or a + b,
                           "*": lambda a, b: a * b},
                          "int", pure_methods=frozenset({"+", "*"}))
        result = fuse(op(".*", Array([], (0,), "int"), op("+", 1, 2)), profile=p)
        self.assertEqual(result.values(), [])
        self.assertEqual(events, ["scalar add"])

    def test_scalar_only_fuse_is_single_scalar_evaluation(self):
        metrics = Metrics()
        self.assertEqual(fuse(op("+", 1, 2), profile=self.profile, metrics=metrics), 3)
        self.assertEqual(metrics.output_passes, 0)
        self.assertEqual(metrics.scalar_operations, 1)

    def test_lazy_ternary_does_not_open_unused_branch(self):
        events = []
        yes = op(".+", Array([1, 2], (2,), "int"), 10)
        no = op("*", Array([1], (1,)), ScalarCall(lambda: events.append("wrong") or 4))
        result = fuse(Select(1, yes, no), profile=self.profile)
        self.assertEqual(result.values(), [11, 12])
        self.assertEqual(events, [])

    def test_array_ternary_condition_is_not_implicit_mask(self):
        with self.assertRaises(FusionDiagnostic):
            fuse(Select(Array([1, 0], (2,)), 3, 4), profile=self.profile)

    def test_same_coordinate_inplace_fuse_has_no_result_array(self):
        a = Array([1, 2, 3], (3,), "int")
        metrics = Metrics()
        result = fuse(op(".+", op(".*", a, 2), 1),
                      profile=self.profile, destination=a, metrics=metrics)
        self.assertIs(result, a)
        self.assertEqual(a.values(), [3, 5, 7])
        self.assertEqual(metrics.array_allocations, 0)
        self.assertEqual(metrics.output_passes, 1)

    def test_cross_coordinate_alias_refused_before_fused_writes(self):
        a = Array([1, 2, 3], (3,), "int")
        reverse = Array(a.storage, (3,), "int", offset=2, strides=(-1,))
        with self.assertRaises(AliasDiagnostic):
            fuse(op(".+", reverse, 0), profile=self.profile, destination=a)
        self.assertEqual(a.values(), [1, 2, 3])
        fuse(op(".+", reverse.copy(), 0), profile=self.profile, destination=a)
        self.assertEqual(a.values(), [3, 2, 1])

    def test_disjoint_borrowed_regions_are_allowed(self):
        backing = [1, 2, 0, 0]
        source = Array(backing, (2,), "int")
        target = Array(backing, (2,), "int", offset=2)
        fuse(op(".+", source, 10), profile=self.profile, destination=target)
        self.assertEqual(backing, [1, 2, 11, 12])

    def test_fused_shape_error_precedes_destination_writes(self):
        target = Array([8, 9], (2,), "int")
        with self.assertRaises(ShapeDiagnostic):
            fuse(op(".+", Array([1], (1,)), 2), profile=self.profile, destination=target)
        self.assertEqual(target.values(), [8, 9])

    def test_fused_scalar_failure_leaves_prior_writes(self):
        target = Array([90, 90, 90], (3,), "int")
        with self.assertRaises(ZeroDivisionError):
            fuse(op("./", 12, Array([3, 0, 2], (3,), "int")),
                 profile=self.profile, destination=target)
        self.assertEqual(target.values(), [4, 90, 90])

    def test_no_reassociation_or_implicit_fma(self):
        p = python_profile("double")
        a = Array([1e16], (1,), "double")
        result = fuse(op(".+", op(".+", a, -1e16), 1.0), profile=p)
        self.assertEqual(result.values(), [1.0])

    def test_ordinary_assignment_captures_overlapping_rhs(self):
        a = Array([1, 2, 3], (3,), "int")
        reverse = Array(a.storage, (3,), "int", offset=2, strides=(-1,))
        assign(a, reverse)
        self.assertEqual(a.values(), [3, 2, 1])

    def test_place_group_rotation(self):
        a, b, c = Cell(1), Cell(2), Cell(3)
        result = assign_places((a, b, c), (b, c, a))
        self.assertEqual([place.value for place in result], [2, 3, 1])
        self.assertIs(result[0], a)

    def test_place_rhs_calls_all_happen_before_any_write(self):
        a, b = Cell(1), Cell(2)
        events = []
        assign_places(
            (a, b),
            (ScalarCall(lambda: events.append(("first", a.value)) or b.value),
             ScalarCall(lambda: events.append(("second", a.value)) or a.value)),
        )
        self.assertEqual(events, [("first", 1), ("second", 1)])
        self.assertEqual((a.value, b.value), (2, 1))

    def test_one_returned_array_is_opened_by_assignment_consumer(self):
        a, b, c = Cell(0), Cell(0), Cell(0)
        calls = []
        assign_places((a, b, c), (ScalarCall(
            lambda: calls.append("producer") or Array([4, 5, 6], (3,), "int")
        ),))
        self.assertEqual((a.value, b.value, c.value), (4, 5, 6))
        self.assertEqual(calls, ["producer"])

    def test_sibling_arrays_are_not_recursively_flattened(self):
        a, b, c = Cell(None), Cell(None), Cell(None)
        values = [Array([1, 2, 3], (3,)) for _ in range(3)]
        assign_places((a, b, c), values)
        self.assertIs(a.value, values[0])
        self.assertIs(b.value, values[1])
        self.assertIs(c.value, values[2])

    def test_assignment_arity_failure_writes_nothing(self):
        a, b = Cell(1), Cell(2)
        with self.assertRaises(ShapeDiagnostic):
            assign_places((a, b), (Array([3], (1,)),))
        self.assertEqual((a.value, b.value), (1, 2))

    def test_scalar_assignment_fills_place_group_without_singleton_broadcast(self):
        a, b = Cell(1), Cell(2)
        assign_places((a, b), (9,))
        self.assertEqual((a.value, b.value), (9, 9))

    def test_assignment_target_admission_precedes_all_writes(self):
        a = Cell(1)
        b = Cell(2, admits=lambda value: isinstance(value, int))
        with self.assertRaises(ProfileError):
            assign_places((a, b), (7, "wrong"))
        self.assertEqual((a.value, b.value), (1, 2))

    def test_repeated_place_target_is_sequential(self):
        a = Cell(1)
        assign_places((a, a), (2, 3))
        self.assertEqual(a.value, 3)

    def test_dotted_compound_reuses_scalar_method(self):
        a = Array([1, 2], (2,), "int")
        result = compound(a, ".+=", 3, profile=self.profile)
        self.assertIs(result, a)
        self.assertEqual(a.values(), [4, 5])

    def test_prefix_and_postfix_dotted_increment(self):
        a = Array([1, 2], (2,), "int")
        old = increment(a, profile=self.profile, postfix=True)
        self.assertEqual(old.values(), [1, 2])
        self.assertEqual(a.values(), [2, 3])
        current = increment(a, profile=self.profile, decrement=True)
        self.assertIs(current, a)
        self.assertEqual(a.values(), [1, 2])


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ArrayExpressionTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if "--json" in sys.argv:
        path = Path(sys.argv[sys.argv.index("--json") + 1])
        path.write_text(json.dumps({
            "scope": "Python semantic reference only",
            "production_lmx_parser": "NOT_RUN",
            "production_lmx_runtime": "NOT_RUN",
            "new_form_diagnostics_are_catchable_lmx_exceptions": False,
            "tests": result.testsRun,
            "failures": len(result.failures),
            "errors": len(result.errors),
            "status": "PASS" if result.wasSuccessful() else "FAIL",
        }, indent=2) + "\n")
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
