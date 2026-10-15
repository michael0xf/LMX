#!/usr/bin/env python3
"""Read-only regression tests for graph_method_order_compare.py.

Usage: python test_graph_method_order_compare.py P0_EVENTS GRAPH_EVENTS

The caller supplies two real event files.  Each negative case mutates a deep
copy of their parsed graph in memory; this test never edits evidence or starts
a kernel build.  The P0 source and graph fixtures are not named in this file.
"""

from __future__ import annotations

import contextlib
import copy
import io
from pathlib import Path
import subprocess
import sys
import unittest
from unittest import mock

import graph_method_order_compare as compare


class MethodOrderComparatorTest(unittest.TestCase):
    p0_path: Path
    graph_path: Path
    root_index: int
    source_root_width: int
    graph_blocks: list[compare.GraphNode]

    @classmethod
    def setUpClass(cls) -> None:
        if not hasattr(cls, "p0_path") or not hasattr(cls, "graph_path"):
            raise unittest.SkipTest("requires explicit P0 and retained-graph event files")
        source = compare.parse_p0(cls.p0_path)
        cls.root_index, _name, _events = compare.source_method(source)
        cls.source_root_width = len(source.children)
        cls.graph_blocks = compare.parse_graph(cls.graph_path)

    def run_cli(self, *options: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(Path(compare.__file__).resolve()), *options,
             str(self.p0_path), str(self.graph_path)],
            text=True,
            capture_output=True,
            check=False,
        )

    def run_with_graph_copy(self, graphs: list[compare.GraphNode]) -> tuple[int, str]:
        stderr = io.StringIO()
        argv = [str(Path(compare.__file__).resolve()), "--method-body-only",
                str(self.p0_path), str(self.graph_path)]
        with mock.patch.object(compare, "parse_graph", return_value=graphs), \
             mock.patch.object(sys, "argv", argv), contextlib.redirect_stderr(stderr):
            status = compare.main()
        return status, stderr.getvalue()

    def method(self, graph: compare.GraphNode) -> compare.GraphNode:
        node = graph.slots[self.root_index].child
        self.assertIsNotNone(node)
        assert node is not None
        return node

    def test_valid_explicit_partial_slice(self) -> None:
        result = self.run_cli("--method-body-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("PARTIAL OK", result.stdout)
        self.assertIn("OWN target coordinates and Frame-head occurrences verified", result.stdout)
        self.assertIn("unchecked P0 root fields=", result.stdout)

    def test_unchecked_root_fails_closed_without_explicit_slice(self) -> None:
        self.assertGreater(self.source_root_width, 1)
        result = self.run_cli()
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("outside the method-body slice", result.stderr)

    def test_wrong_own_target_is_rejected(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        initializer_index = next(
            i for i, slot in enumerate(method.slots)
            if slot.attrs.get("op") == "8" and slot.attrs.get("role") == "1"
        )
        initializer = method.slots[initializer_index].child
        self.assertIsNotNone(initializer)
        assert initializer is not None
        target = initializer.slots[1].child
        self.assertIsNotNone(target)
        assert target is not None
        coordinate = target.slots[2].attrs
        coordinate["size"] = str(int(coordinate["size"]) + 1)
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("OWN target index", error)

    def test_swapped_body_slots_are_rejected(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        initializer_index = next(
            i for i, slot in enumerate(method.slots)
            if slot.attrs.get("op") == "8" and slot.attrs.get("role") == "1"
        )
        assignment_index = next(
            i for i in range(initializer_index + 1, len(method.slots))
            if method.slots[i].attrs.get("op") == "8"
            and method.slots[i].attrs.get("role") == "0"
        )
        method.slots[initializer_index], method.slots[assignment_index] = (
            method.slots[assignment_index], method.slots[initializer_index]
        )
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("role=0, expected 1", error)

    def test_assignment_head_must_name_its_own_executing_slot(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        assignment = next(slot for slot in method.slots
                          if slot.attrs.get("op") == "8" and slot.attrs.get("role") == "0")
        self.assertNotEqual(assignment.attrs["value_name"], "-")
        # The declaration cell still spells i; finding it elsewhere must not
        # make a missing name on the assignment's own occurrence pass.
        assignment.attrs["value_name"] = "-"
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("Frame head", error)

    def test_initializer_head_must_name_its_own_executing_slot(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        initializer = next(slot for slot in method.slots
                           if slot.attrs.get("op") == "8" and slot.attrs.get("role") == "1")
        self.assertNotEqual(initializer.attrs["value_name"], "-")
        initializer.attrs["value_name"] = "-"
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("Frame head", error)

    def test_extra_physical_method_slot_is_rejected(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        method.slots.append(copy.deepcopy(method.slots[-1]))
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("method width", error)

    def test_native_walker_graph_divergence_is_rejected(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        unchecked_index = next(i for i in range(len(graphs[1].slots)) if i != self.root_index)
        attr = graphs[1].slots[unchecked_index].attrs
        attr["op"] = str(int(attr["op"]) + 100)
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("native and walker complete physical graph trees differ", error)

    def test_distinct_mutable_declarations_cannot_share_int_storage(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        cells = [slot for slot in method.slots
                 if slot.attrs.get("kind") == "1" and slot.attrs.get("type") == "2"
                 and slot.attrs.get("value_name") != "-"]
        self.assertGreaterEqual(len(cells), 2)
        self.assertNotEqual(cells[0].attrs["value"], cells[1].attrs["value"])
        cells[1].attrs["value"] = cells[0].attrs["value"]
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("shares primitive storage", error)

    def test_literal_data_cannot_alias_mutable_declaration(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        declaration = next(slot for slot in method.slots
                           if slot.attrs.get("kind") == "1" and slot.attrs.get("type") == "2"
                           and slot.attrs.get("value_name") != "-")
        initializer = next(slot.child for slot in method.slots
                           if slot.attrs.get("op") == "8" and slot.attrs.get("role") == "1")
        self.assertIsNotNone(initializer)
        assert initializer is not None
        lit = initializer.slots[2].child
        self.assertIsNotNone(lit)
        assert lit is not None
        lit.slots[1].attrs["value"] = declaration.attrs["value"]
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("LIT data aliases mutable declaration storage", error)

    def test_literal_data_cannot_acquire_a_source_name(self) -> None:
        graphs = copy.deepcopy(self.graph_blocks)
        method = self.method(graphs[0])
        initializer = next(slot.child for slot in method.slots
                           if slot.attrs.get("op") == "8" and slot.attrs.get("role") == "1")
        self.assertIsNotNone(initializer)
        assert initializer is not None
        lit = initializer.slots[2].child
        self.assertIsNotNone(lit)
        assert lit is not None
        lit.slots[1].attrs["value_name"] = "1:78"
        status, error = self.run_with_graph_copy(graphs)
        self.assertEqual(status, 1)
        self.assertIn("LIT data has source value_name", error)

    def test_external_structure_alias_pattern_is_preserved(self) -> None:
        def slot(address: str) -> compare.GraphSlot:
            return compare.GraphSlot({
                "value": address, "kind": "6", "type": "13", "op": "-1",
                "role": "-1", "owned": "0", "cell_name": "-", "value_name": "-",
            })

        original = compare.GraphNode({"node": "0000000000000001", "name": "-"},
                                     [slot("0000000000000010"), slot("0000000000000010")])
        same_shape = compare.GraphNode({"node": "0000000000000002", "name": "-"},
                                       [slot("0000000000000020"), slot("0000000000000020")])
        changed_alias = compare.GraphNode({"node": "0000000000000003", "name": "-"},
                                          [slot("0000000000000030"), slot("0000000000000040")])
        self.assertEqual(compare.canonical_graph(original), compare.canonical_graph(same_shape))
        self.assertNotEqual(compare.canonical_graph(original), compare.canonical_graph(changed_alias))

    def test_char_array_bytes_participate_in_native_walker_comparison(self) -> None:
        def graph(data: str) -> compare.GraphNode:
            return compare.GraphNode(
                {"node": "0000000000000001", "name": "-"},
                [compare.GraphSlot({
                    "value": "0000000000000010", "kind": "3", "type": "5",
                    "op": "-1", "role": "-1", "owned": "0",
                    "cell_name": "-", "value_name": "-", "array": data,
                })],
            )

        self.assertEqual(compare.canonical_graph(graph("4:6B657074")),
                         compare.canonical_graph(graph("4:6B657074")))
        self.assertNotEqual(compare.canonical_graph(graph("4:6B657074")),
                            compare.canonical_graph(graph("4:6B657075")))

    def test_atom_text_containing_head_marker_is_not_frame_head(self) -> None:
        payload = b'atom depth=1 index=1 flags=0x0 span=1:1+0:10 text=10="a head=x"'
        tag, attrs, text = compare.parse_p0_record(str(len(payload)).encode() + b":" + payload, 1)
        self.assertEqual(tag, "atom")
        self.assertEqual(attrs["index"], "1")
        self.assertEqual(text, b'"a head=x"')


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {Path(sys.argv[0]).name} P0_EVENTS GRAPH_EVENTS", file=sys.stderr)
        return 2
    MethodOrderComparatorTest.p0_path = Path(sys.argv[1]).resolve()
    MethodOrderComparatorTest.graph_path = Path(sys.argv[2]).resolve()
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(MethodOrderComparatorTest)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
