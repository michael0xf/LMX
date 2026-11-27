#!/usr/bin/env python3
"""Focused semantic acceptance for v0.4 + author depth=0=max clarification.

This consumes prepared values/configuration, not LMX text; production NOT_RUN.
"""
from decimal import Decimal
import json
import operator
from pathlib import Path
import sys
import unittest
from array_expression_reference import (
    ABSENT, Accumulator, AliasDiagnostic, Array, DepthError, DepthExpression,
    FusionDiagnostic, Held, Metrics, ProfileDiagnostic, ProfileError,
    ScalarCall, ScalarProfile, Select, ShapeDiagnostic, apply, array_value,
    assign, evaluate, fuse, indexed_binary, map_cells, matmul, op, ordinary,
    python_profile, reduce_axes, transpose,
)


class TensorContracts(unittest.TestCase):
    def setUp(self):
        self.p = python_profile('int')
        self.a = Array([1, 2, 3, 4], (2, 2), 'int')
        self.b = Array([5, 6, 7, 8], (2, 2), 'int')

    def test_plain_multiply_is_componentwise(self):
        self.assertEqual(ordinary('*', self.a, self.b, profile=self.p).values(), [5, 12, 21, 32])

    def test_matrix_multiply_is_explicit(self):
        self.assertEqual(ordinary('[*]', self.a, self.b, profile=self.p).values(), [19, 22, 43, 50])

    def test_depth_zero_is_maximum_and_positive_two_matches(self):
        for d in (0, 2):
            self.assertEqual(apply('*', self.a, self.b, depth=d, profile=self.p).values(), [5, 12, 21, 32])

    def test_depth_one_rows_reach_base_dot(self):
        self.assertEqual(apply('[*]', self.a, self.b, depth=1, profile=self.p).values(), [17, 53])

    def test_absent_product_and_explicit_zero_are_distinct(self):
        self.assertEqual(apply('[*]', self.a, self.b, profile=self.p).shape, (2, 2))
        with self.assertRaises(ShapeDiagnostic):
            apply('[*]', self.a, self.b, depth=0, profile=self.p)

    def test_selected_array_cells_do_not_restart_automatic_map(self):
        with self.assertRaises(ProfileDiagnostic):
            apply('*', self.a, self.b, depth=1, profile=self.p)

    def test_depth_exceeding_rank_is_diagnostic_not_clipped(self):
        with self.assertRaises(DepthError):
            apply('*', self.a, self.b, depth=3, profile=self.p)

    def test_cube_depth_counts_outer_axes(self):
        cube = Array(list(range(24)), (2, 3, 4), 'int')
        for d, expected_shape, count in ((1, (3, 4), 2), (2, (4,), 6), (3, None, 24), (0, None, 24)):
            seen = []
            def base(cell):
                seen.append(cell.shape if isinstance(cell, Array) else None)
                return 1
            result = map_cells(base, cube, depth=d, result_type='int')
            self.assertEqual(seen, [expected_shape] * count)
            self.assertEqual(result.size, count)

    def test_original_scalar_needs_no_synthetic_axes(self):
        self.assertEqual(apply('+', 2, 3, depth=8, profile=self.p), 5)

    def test_depth_expression_once_with_original_context(self):
        calls, context = [], object()
        expression = DepthExpression('depth expression', context)
        def obtain(node, supplied):
            self.assertIs(supplied, context)
            calls.append(node)
            return 2
        result = evaluate(op('*', self.a, self.b, depth=expression), profile=self.p, obtain_depth=obtain)
        self.assertEqual(result.values(), [5, 12, 21, 32])
        self.assertEqual(calls, ['depth expression'])

    def test_invalid_depths_are_not_numeric_coercions(self):
        for d in (-1, 1.5, True):
            with self.assertRaises(DepthError): apply('+', 1, 2, depth=d, profile=self.p)

    def test_frame_match_and_explicit_held_value(self):
        z = Array(list(range(6)), (2, 3), 'int')
        bias = Array([10, 20, 30], (3,), 'int')
        with self.assertRaises(ShapeDiagnostic):
            map_cells(lambda row, b: ordinary('+', row, b, profile=self.p), z, bias, depth=1, cell_shape=(3,))
        result = map_cells(lambda row, b: ordinary('+', row, b, profile=self.p), z, Held(bias),
                           depth=1, cell_shape=(3,), result_type='int')
        self.assertEqual(result.values(), [10, 21, 32, 13, 24, 35])

    def test_empty_frame_does_not_probe_a_cell(self):
        calls = []
        result = map_cells(lambda x: calls.append(x), Array([], (0, 3), 'int'), depth=1, cell_shape=(2,))
        self.assertEqual(result.shape, (0, 2))
        self.assertEqual(calls, [])

    def test_reference_array_is_not_excluded(self):
        x, y = object(), object()
        a, b = array_value([x, y]), array_value([x, x])
        result = ordinary('same', a, b, profile=self.p)
        self.assertEqual(result.values(), [True, False])
        self.assertIs(a.values()[0], x)

    def test_unsupported_actual_reference_operation_is_local_failure(self):
        with self.assertRaises(TypeError):
            ordinary('+', array_value([object()]), 1, profile=self.p)

    def test_outer_and_axis_free_addition_differ_from_plain_map(self):
        a, b = Array([1, 2], (2,), 'int'), Array([10, 20, 30], (3,), 'int')
        result = indexed_binary(a, b, operator.add)
        self.assertEqual((result.shape, result.values()), ((2, 3), [11, 21, 31, 12, 22, 32]))
        with self.assertRaises(ShapeDiagnostic): ordinary('+', a, b, profile=self.p)

    def test_min_plus_and_max_plus_require_distinct_reducers(self):
        for reducer, expected in ((min, [6, 7, 8, 9]), (max, [9, 10, 11, 12])):
            result = indexed_binary(self.a, self.b, operator.add, [(1, ':', 0)], accumulator=Accumulator(reducer))
            self.assertEqual(result.values(), expected)
        with self.assertRaises(ProfileDiagnostic):
            indexed_binary(self.a, self.b, operator.add, [(1, ':', 0)])

    def test_no_reduction_ignores_default_identity_and_finish(self):
        calls = []
        accumulator = Accumulator(operator.add, start='identity', identity=lambda: calls.append('identity'),
                                  finish=lambda s: calls.append('finish'))
        result = indexed_binary(Array([2], (1,)), Array([3], (1,)), operator.mul,
                                accumulator=accumulator)
        self.assertEqual(result.values(), [6]); self.assertEqual(calls, [])
        with self.assertRaises(ProfileDiagnostic):
            indexed_binary(self.a, self.b, operator.add, accumulator=accumulator, reduce_actual=True)

    def test_boolean_and_gf2_are_different(self):
        a = Array([1, 1, 0, 1], (2, 2))
        b = Array([1, 0, 1, 1], (2, 2))
        boolean = indexed_binary(a, b, operator.and_, [(1, ':', 0)], accumulator=Accumulator(operator.or_))
        gf2 = indexed_binary(a, b, operator.and_, [(1, ':', 0)], accumulator=Accumulator(operator.xor))
        self.assertEqual(boolean.values(), [1, 1, 1, 1])
        self.assertEqual(gf2.values(), [0, 1, 1, 1])

    def test_shared_axes_and_output_permutation(self):
        m, v = Array([1, 2, 3, 4, 5, 6], (2, 3)), Array([10, 20, 30], (3,))
        direct = indexed_binary(m, v, operator.sub, [(1, '=', 0)])
        row_order = indexed_binary(m, v, operator.sub, [(1, '=', 0)], order=(1, 0))
        self.assertEqual(direct.shape, (3, 2))
        self.assertEqual((row_order.shape, row_order.values()), ((2, 3), [-9, -18, -27, -6, -15, -24]))

    def test_composite_axis_right_index_changes_fastest(self):
        result = indexed_binary(Array([1, 2], (2,)), Array([10, 20, 30], (3,)), operator.add, [(0, '*', 0)])
        self.assertEqual((result.shape, result.values()), ((6,), [11, 21, 31, 12, 22, 32]))

    def test_axis_duplicates_scalar_axis_and_bad_permutation_rejected(self):
        for rules in ([(0, '=', 0), (0, ':', 1)], [(2, ':', 0)]):
            with self.assertRaises(ShapeDiagnostic): indexed_binary(self.a, self.b, operator.mul, rules)
        with self.assertRaises(ShapeDiagnostic): indexed_binary(self.a, 0, operator.gt, [(0, '=', 0)])
        with self.assertRaises(ShapeDiagnostic): indexed_binary(self.a, self.b, operator.add, order=(0, 0, 1, 2))

    def test_sum_product_and_trace_are_distinct(self):
        m = Array([1, 2, 3, 4, 5, 6], (2, 3))
        self.assertEqual(reduce_axes(m, (1,), Accumulator(operator.add)).values(), [6, 15])
        self.assertEqual(reduce_axes(m, (1,), Accumulator(operator.mul)).values(), [6, 120])
        self.assertEqual(reduce_axes(self.a, (0, 1), Accumulator(operator.add), diagonal=(0, 1)), 5)
        self.assertEqual(reduce_axes(self.a, (0, 1), Accumulator(operator.mul), diagonal=(0, 1)), 4)

    def test_reduction_axes_sorted_preserve_fold_order(self):
        m = Array([1, 2, 3, 4], (2, 2))
        self.assertEqual(reduce_axes(m, (1, 0), Accumulator(operator.sub)), -8)
        self.assertEqual(reduce_axes(m, (0, 1), Accumulator(operator.sub)), -8)

    def test_first_min_retains_first_typed_record(self):
        first, second = {'value': 3, 'type': 'int'}, {'value': 3, 'type': 'real'}
        policy = Accumulator(lambda a, b: b if b['value'] < a['value'] else a)
        self.assertIs(policy.fold([first, second]), first)

    def test_seed_is_not_identity_and_empty_runs_finish(self):
        policy = Accumulator(operator.add, seed=10, identity=lambda: 0, empty='identity', finish=lambda n: {'total': n})
        self.assertEqual(policy.fold([1, 2]), {'total': 13})
        self.assertEqual(policy.fold([]), {'total': 10})
        identity = Accumulator(operator.add, identity=lambda: 0, empty='identity', finish=lambda n: ['done', n])
        self.assertEqual(identity.fold([]), ['done', 0])

    def test_mutable_seed_is_independent_for_each_result(self):
        seed = {'sum': 10}
        def step(state, value): state['sum'] += value; return state
        result = reduce_axes(self.a, (1,), Accumulator(step, seed=seed))
        self.assertEqual(result.values(), [{'sum': 13}, {'sum': 17}])
        self.assertIsNot(result.values()[0], result.values()[1])
        self.assertEqual(seed, {'sum': 10})

    def test_empty_contraction_typed_zero_and_empty_free_axis(self):
        calls = []
        p = python_profile('decimal'); p.zero = lambda: calls.append('zero') or Decimal(0)
        result = matmul(Array([], (2, 0), 'decimal'), Array([], (0, 3), 'decimal'), profile=p)
        self.assertEqual(result.values(), [Decimal(0)] * 6); self.assertEqual(len(calls), 6)
        calls.clear()
        result = matmul(Array([], (0, 0), 'decimal'), Array([], (0, 3), 'decimal'), profile=p)
        self.assertEqual(result.shape, (0, 3)); self.assertEqual(calls, [])

    def test_default_batch_product_has_exact_batch_axes(self):
        a, b = Array([1, 0, 0, 1, 2, 0, 0, 2], (2, 2, 2)), Array(list(range(8)), (2, 2, 2))
        self.assertEqual(matmul(a, b, profile=self.p).values(), [0, 1, 2, 3, 8, 10, 12, 14])
        with self.assertRaises(ShapeDiagnostic): matmul(a, self.b, profile=self.p)

    def test_assignment_exact_vs_broadcast(self):
        target = Array([0]*6, (2, 3))
        row = Array([10, 20, 30], (3,))
        with self.assertRaises(ShapeDiagnostic): assign(target, row)
        assign(target, row, broadcast=True)
        self.assertEqual(target.values(), [10, 20, 30, 10, 20, 30])
        assign(target, Array([100, 200], (2, 1)), broadcast=True)
        self.assertEqual(target.values(), [100, 100, 100, 200, 200, 200])

    def test_depth_slice_broadcast_keeps_the_prepared_full_map(self):
        for depth in (0, 1, 2, 3):
            target = Array([0]*24, (2, 3, 4))
            row = Array([1, 2, 3, 4], (4,))
            assign(target, row, broadcast=True, depth=depth)
            self.assertEqual(target.values(), [1, 2, 3, 4]*6)
            source = Array([1, 2, 3, 4, 10, 20, 30, 40], (2, 1, 4))
            assign(target, source, broadcast=True, depth=depth)
            self.assertEqual(target.values(), [1, 2, 3, 4]*3 + [10, 20, 30, 40]*3)
        with self.assertRaises(ShapeDiagnostic):
            assign(target, Array(list(range(8)), (2, 4)), broadcast=True, depth=1)

    def test_broadcast_one_to_zero_but_not_zero_to_positive(self):
        target = Array([], (0, 3))
        assign(target, Array([1, 2, 3], (1, 3)), broadcast=True)
        with self.assertRaises(ShapeDiagnostic): assign(Array([0]*6, (2, 3)), target, broadcast=True)

    def test_assignment_and_depth_frames_snapshot_before_any_write(self):
        target = Array([1, 2, 3, 4], (2, 2))
        reverse = Array(target.storage, (2, 2), offset=2, strides=(-2, 1))
        assign(target, reverse, depth=1)
        self.assertEqual(target.values(), [3, 4, 1, 2])

    def test_admission_failure_does_not_write_prefix(self):
        target = Array([1, 2], (2,), admission=lambda x: x >= 0)
        with self.assertRaises(ProfileError): assign(target, Array([9, -1], (2,)))
        self.assertEqual(target.values(), [1, 2])

    def test_duplicate_write_map_is_rejected(self):
        target = Array([1], (2,), strides=(0,))
        with self.assertRaises(AliasDiagnostic): assign(target, 3)
        self.assertEqual(target.storage, [1])

    def test_readonly_transpose_cannot_amplify_write_rights(self):
        view = transpose(self.a, (1, 0))
        self.assertIs(view.parent, self.a)
        self.assertEqual(view.values(), [1, 3, 2, 4])
        with self.assertRaises(ProfileError): assign(view, 0)

    def test_fuse_fresh_map_has_one_result(self):
        # The fixture certifies exact integer +/* on these finite actual values.
        self.p.fusion_safe = frozenset({'+', '*'})
        metrics = Metrics()
        result = fuse(op('+', op('*', self.a, self.b), 1), profile=self.p, metrics=metrics)
        self.assertEqual(result.values(), [6, 13, 22, 33])
        self.assertEqual((metrics.array_allocations, metrics.output_passes, metrics.output_elements), (1, 1, 4))
        self.assertEqual(self.a.values(), [1, 2, 3, 4])

    def test_fuse_requires_failure_order_certificate(self):
        with self.assertRaises(FusionDiagnostic):
            fuse(op('+', op('/', self.a, self.b), 1), profile=self.p)

    def test_fuse_rejects_contraction_and_remaining_array_cells(self):
        with self.assertRaises(FusionDiagnostic): fuse(op('[*]', self.a, self.b), profile=self.p)
        with self.assertRaises(FusionDiagnostic): fuse(op('*', self.a, self.b, depth=1), profile=self.p)
        with self.assertRaises(DepthError): fuse(op('*', self.a, self.b, depth=3), profile=self.p)
        self.assertEqual(fuse(op('*', self.a, self.b, depth=0), profile=self.p).values(), [5, 12, 21, 32])
        self.assertEqual(fuse(op('*', self.a, self.b, depth=2), profile=self.p).values(), [5, 12, 21, 32])

    def test_fuse_lazy_branch_does_not_obtain_unused_depth(self):
        calls = []
        bad = op('*', self.a, self.b, depth=DepthExpression('unused', None))
        result = fuse(Select(False, bad, op('+', self.a, ScalarCall(lambda: calls.append('bias') or 1))),
                      profile=self.p, obtain_depth=lambda x, c: self.fail('unused depth evaluated'))
        self.assertEqual(result.values(), [2, 3, 4, 5]); self.assertEqual(calls, ['bias'])

    def test_fuse_intermediate_numeric_boundary_is_preserved(self):
        p = ScalarProfile({'*': lambda a, b: round(a*b, 1), '+': operator.add}, 'real',
                          fusion_safe=frozenset({'*'}))
        result = fuse(op('+', op('*', Array([0.26], (1,)), 2), 0.04), profile=p)
        self.assertEqual(result.values(), [0.54])

    def test_failed_fuse_rhs_leaves_outside_destination_unchanged(self):
        target = Array([10, 20], (2,))
        with self.assertRaises(ZeroDivisionError):
            assign(target, fuse(op('/', Array([1, 2], (2,)), Array([1, 0], (2,))), profile=self.p))
        self.assertEqual(target.values(), [10, 20])

    def test_no_dotted_callable_alias(self):
        with self.assertRaises(ProfileDiagnostic): ordinary('.*', self.a, self.b, profile=self.p)


if __name__ == '__main__':
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(TensorContracts)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    report = {'revision': '2026-11-27', 'status': 'PASS' if result.wasSuccessful() else 'FAIL',
              'tests': result.testsRun, 'failures': len(result.failures), 'errors': len(result.errors),
              'scope': 'Prepared host contracts: depth=0=max, one lifting, Map/index plans, accumulator, assignment/broadcast, minimal fresh fuse',
              'production_parser': 'NOT_RUN', 'production_translator': 'NOT_RUN', 'lmx_runtime': 'NOT_RUN',
              'retention_runtime': 'NOT_RUN', 'C_import': 'NOT_RUN'}
    output = Path(sys.argv[sys.argv.index('--json')+1]) if '--json' in sys.argv else Path(__file__).with_name('array_expression_reference_results.json')
    output.write_text(json.dumps(report, indent=2) + '\n')
    raise SystemExit(not result.wasSuccessful())
