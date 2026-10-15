#!/usr/bin/env python3
"""Standalone tests for the diagnostic, form-agnostic G1 root witness.

Usage: python test_graph_root_visibility_witness.py P0_EVENTS GRAPH_EVENTS

Both inputs are previously captured real events.  Mutants change in-memory
copies only; no translator, driver, kernel build, or fixture file is touched.
"""

from __future__ import annotations

import copy
from pathlib import Path
import sys
import unittest

import graph_method_order_compare as common
import graph_root_visibility_witness as witness


class RootVisibilityWitnessTest(unittest.TestCase):
    p0_path: Path
    graph_path: Path
    p0: common.P0Node
    graphs: list[common.GraphNode]

    @classmethod
    def setUpClass(cls) -> None:
        if not hasattr(cls, "p0_path") or not hasattr(cls, "graph_path"):
            raise unittest.SkipTest(
                "real P0/graph event files required; run this module with both paths"
            )
        cls.p0 = common.parse_p0(cls.p0_path)
        cls.graphs = common.parse_graph(cls.graph_path)

    @classmethod
    def diagnostic_field(cls) -> dict:
        """Find a root whose nested heads remain unwitnessed by its graph."""
        report = witness.compare(cls.p0, cls.graphs)
        candidates = [field for field in report["fields"]
                      if field["source_tag"] == "frame"
                      and any(mark["kind"] == "head" and mark["path"] !=
                              f'root[{field["root_index"]}]'
                              for mark in field["source_marks_in_order"])
                      and all(mark in field["unwitnessed_marks"]
                              for mark in field["source_marks_in_order"]
                              if mark["kind"] == "head" and mark["path"] !=
                              f'root[{field["root_index"]}]')
                      and field["graph_int_values"]]
        if not candidates:
            raise AssertionError("evidence has no unwitnessed nested source Frame")
        return candidates[0]

    def test_status_never_claims_full_g1(self) -> None:
        report = witness.compare(self.p0, self.graphs)
        self.assertEqual(report["status"], "PARTIAL_DIAGNOSTIC")
        self.assertEqual(report["root_cardinality"], len(self.p0.children))
        self.assertEqual(len(report["fields"]), len(self.p0.children))
        self.assertTrue(report["native_walker_physical_trees_equal"])
        self.assertTrue(any("does not prove" in caveat for caveat in report["limitations"]))

    def test_existing_nested_root_payload_is_exposed_without_receiver_rules(self) -> None:
        field = self.diagnostic_field()
        self.assertGreater(field["source_direct_children"], 0)
        self.assertGreater(field["graph_direct_slots"], 0)
        missing = {(mark["path"], mark["hex"])
                   for mark in field["unwitnessed_marks"]}
        nested_heads = [mark for mark in field["source_marks_in_order"]
                        if mark["kind"] == "head" and mark["path"] !=
                        f'root[{field["root_index"]}]']
        self.assertTrue(nested_heads)
        self.assertTrue(all((mark["path"], mark["hex"]) in missing for mark in nested_heads))
        # The same generic traversal still sees materialized numeric values.
        visible_numeric_atoms = [mark for mark in field["source_marks_in_order"]
                                 if mark["kind"] == "atom"
                                 and bytes.fromhex(mark["hex"]).isdigit()
                                 and (mark["path"], mark["hex"]) not in missing]
        self.assertTrue(visible_numeric_atoms)

    def test_new_graph_annotation_is_seen_without_new_receiver_case(self) -> None:
        field = self.diagnostic_field()
        missing_head = next(mark for mark in field["unwitnessed_marks"]
                            if mark["kind"] == "head"
                            and sum(other["hex"] == mark["hex"]
                                    for other in field["source_marks_in_order"]) == 1)
        index = field["root_index"]
        graphs = copy.deepcopy(self.graphs)
        spelling = bytes.fromhex(missing_head["hex"])
        encoded = f"{len(spelling)}:{spelling.hex()}"
        for graph in graphs:
            graph.slots[index].attrs["cell_name"] = encoded
        repaired = witness.compare(self.p0, graphs, index)["fields"][0]
        self.assertNotIn(missing_head, repaired["unwitnessed_marks"])
        self.assertEqual(len(repaired["unwitnessed_marks"]),
                         len(field["unwitnessed_marks"]) - 1)

    def test_executing_root_head_gate_rejects_a_missing_annotation(self) -> None:
        index = self.diagnostic_field()["root_index"]
        graphs = copy.deepcopy(self.graphs)
        for graph in graphs:
            graph.slots[index].attrs["value_name"] = "-"
        with self.assertRaisesRegex(common.CompareError,
                                    "written head is not on its graph occurrence"):
            witness.require_executing_root_head(self.p0, graphs, index)

    def test_executing_root_head_gate_uses_same_rule_for_any_frame(self) -> None:
        index = self.diagnostic_field()["root_index"]
        head = self.p0.children[index].text
        self.assertIsNotNone(head)
        assert head is not None
        encoded = f"{len(head)}:{head.hex()}"
        graphs = copy.deepcopy(self.graphs)
        for graph in graphs:
            graph.slots[index].attrs["value_name"] = encoded
        witness.require_executing_root_head(self.p0, graphs, index)
        graphs[1].slots[index].attrs["value_name"] = "5:77726f6e67"
        with self.assertRaisesRegex(common.CompareError,
                                    "written head is not on its graph occurrence"):
            witness.require_executing_root_head(self.p0, graphs, index)

    def test_native_walker_divergence_is_failure(self) -> None:
        graphs = copy.deepcopy(self.graphs)
        graphs[1].slots[0].attrs["op"] = "99999"
        with self.assertRaisesRegex(common.CompareError,
                                    "native and walker complete physical graph trees differ"):
            witness.compare(self.p0, graphs)

    def test_root_cardinality_mismatch_is_failure(self) -> None:
        graphs = copy.deepcopy(self.graphs)
        graphs[0].slots.pop()
        with self.assertRaisesRegex(common.CompareError, "root cardinality"):
            witness.compare(self.p0, graphs)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    RootVisibilityWitnessTest.p0_path = Path(sys.argv[1])
    RootVisibilityWitnessTest.graph_path = Path(sys.argv[2])
    sys.argv = [sys.argv[0]]
    unittest.main()
