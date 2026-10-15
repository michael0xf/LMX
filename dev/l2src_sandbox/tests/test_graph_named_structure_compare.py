#!/usr/bin/env python3
"""Read-only regressions for graph_named_structure_compare.py.

Usage: python test_graph_named_structure_compare.py WIDE_P0 WIDE_GRAPH DEEP_P0 DEEP_GRAPH

The event files are supplied by the caller, never generated or edited here.
Negative cases modify only deep copies of their parsed trees in memory.  No
fixture spelling is embedded in the assertions.
"""

from __future__ import annotations

import copy
from pathlib import Path
import subprocess
import sys
import unittest

import graph_method_order_compare as common
import graph_named_structure_compare as named


class NamedStructureComparatorTest(unittest.TestCase):
    wide_p0_path: Path
    wide_graph_path: Path
    deep_p0_path: Path
    deep_graph_path: Path
    wide_p0: common.P0Node
    deep_p0: common.P0Node
    wide_index: int
    deep_index: int
    wide_source: named.NamedStructure
    deep_source: named.NamedStructure
    wide_graphs: list[common.GraphNode]
    deep_graphs: list[common.GraphNode]

    @classmethod
    def setUpClass(cls) -> None:
        if not all(hasattr(cls, name) for name in (
            "wide_p0_path", "wide_graph_path", "deep_p0_path", "deep_graph_path"
        )):
            raise unittest.SkipTest("requires explicit wide/deep P0 and retained-graph event files")
        cls.wide_p0 = common.parse_p0(cls.wide_p0_path)
        cls.deep_p0 = common.parse_p0(cls.deep_p0_path)
        cls.wide_index, cls.wide_source, _ = named.source_structure(cls.wide_p0)
        cls.deep_index, cls.deep_source, _ = named.source_structure(cls.deep_p0)
        cls.wide_graphs = common.parse_graph(cls.wide_graph_path)
        cls.deep_graphs = common.parse_graph(cls.deep_graph_path)
        wide_depth, wide_siblings = named.depth_and_width(cls.wide_source)
        deep_depth, _ = named.depth_and_width(cls.deep_source)
        if wide_siblings <= 16 or deep_depth <= 4:
            raise AssertionError(
                f"supplied evidence misses intended boundaries: "
                f"wide max siblings={wide_siblings}, deep depth={deep_depth}"
            )

    @staticmethod
    def run_cli(p0: Path, graph: Path, *options: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(Path(named.__file__).resolve()), *options, str(p0), str(graph)],
            text=True,
            capture_output=True,
            check=False,
        )

    def reject_slot(self, slot: common.GraphSlot, source: named.NamedStructure,
                    diagnostic: str) -> None:
        with self.assertRaisesRegex(common.CompareError, diagnostic):
            named.verify_named_slot(slot, source, "mutant", root=True)

    def test_wide_explicit_partial_match(self) -> None:
        result = self.run_cli(self.wide_p0_path, self.wide_graph_path, "--structure-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("G1 named-structure comparison PARTIAL OK:", result.stdout)
        self.assertIn("native/walker=2", result.stdout)
        self.assertIn("unchecked P0 root fields=", result.stdout)

    def test_deep_explicit_partial_match(self) -> None:
        result = self.run_cli(self.deep_p0_path, self.deep_graph_path, "--structure-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("G1 named-structure comparison PARTIAL OK:", result.stdout)
        self.assertIn("native/walker=2", result.stdout)
        self.assertIn("unchecked P0 root fields=", result.stdout)

    def test_unchecked_root_fails_closed_without_opt_in(self) -> None:
        for p0, graph in ((self.wide_p0_path, self.wide_graph_path),
                          (self.deep_p0_path, self.deep_graph_path)):
            with self.subTest(p0=p0):
                result = self.run_cli(p0, graph)
                self.assertEqual(result.returncode, 1, result.stdout)
                self.assertIn("outside the named-Structure slice", result.stderr)

    def test_extra_wide_sibling_is_rejected(self) -> None:
        graph = copy.deepcopy(self.wide_graphs[0])
        slot = graph.slots[self.wide_index]
        self.assertIsNotNone(slot.child)
        assert slot.child is not None
        slot.child.slots.append(copy.deepcopy(slot.child.slots[-1]))
        self.reject_slot(slot, self.wide_source, "physical width")

    def test_swapped_wide_siblings_are_rejected(self) -> None:
        graph = copy.deepcopy(self.wide_graphs[0])
        slot = graph.slots[self.wide_index]
        self.assertIsNotNone(slot.child)
        assert slot.child is not None
        slot.child.slots[0], slot.child.slots[1] = slot.child.slots[1], slot.child.slots[0]
        self.reject_slot(slot, self.wide_source, "value name")

    def test_missing_nested_structure_beyond_depth_four_is_rejected(self) -> None:
        graph = copy.deepcopy(self.deep_graphs[0])
        slot = graph.slots[self.deep_index]
        self.assertIsNotNone(slot.child)
        assert slot.child is not None
        node = slot.child
        for _ in range(4):
            self.assertTrue(node.slots)
            child = node.slots[0].child
            self.assertIsNotNone(child)
            assert child is not None
            node = child
        node.slots.pop(0)
        self.reject_slot(slot, self.deep_source, "physical width")

    def test_wrong_int_own_coordinate_is_rejected(self) -> None:
        graph = copy.deepcopy(self.deep_graphs[0])
        slot = graph.slots[self.deep_index]
        self.assertIsNotNone(slot.child)
        assert slot.child is not None
        node = slot.child
        while node.slots and node.slots[0].attrs.get("kind") == "6":
            child = node.slots[0].child
            self.assertIsNotNone(child)
            assert child is not None
            node = child
        self.assertGreaterEqual(len(node.slots), 2)
        initializer = node.slots[1].child
        self.assertIsNotNone(initializer)
        assert initializer is not None
        target = initializer.slots[1].child
        self.assertIsNotNone(target)
        assert target is not None
        coordinate = target.slots[2].attrs
        coordinate["size"] = str(int(coordinate["size"]) + 1)
        self.reject_slot(slot, self.deep_source, "OWN target index")

    def test_int_literal_cannot_alias_its_mutable_leaf(self) -> None:
        graph = copy.deepcopy(self.deep_graphs[0])
        slot = graph.slots[self.deep_index]
        self.assertIsNotNone(slot.child)
        assert slot.child is not None
        node = slot.child
        while node.slots and node.slots[0].attrs.get("kind") == "6":
            child = node.slots[0].child
            self.assertIsNotNone(child)
            assert child is not None
            node = child
        declaration = node.slots[0]
        initializer = node.slots[1].child
        self.assertIsNotNone(initializer)
        assert initializer is not None
        literal = initializer.slots[2].child
        self.assertIsNotNone(literal)
        assert literal is not None
        literal.slots[1].attrs["value"] = declaration.attrs["value"]
        self.reject_slot(slot, self.deep_source, "LIT data aliases mutable declaration storage")

    def test_distinct_nested_int_leaves_cannot_share_storage(self) -> None:
        graph = copy.deepcopy(self.deep_graphs[0])
        slot = graph.slots[self.deep_index]
        self.assertIsNotNone(slot.child)
        assert slot.child is not None
        node = slot.child
        while node.slots and node.slots[0].attrs.get("kind") == "6":
            child = node.slots[0].child
            self.assertIsNotNone(child)
            assert child is not None
            node = child
        self.assertEqual(len(node.slots), 2)
        extra_cell, extra_initializer = copy.deepcopy(node.slots)
        extra_cell.attrs["cell_name"] = "5:6578747261"  # b"extra"
        extra_cell.attrs["value_name"] = "5:6578747261"
        initializer = extra_initializer.child
        self.assertIsNotNone(initializer)
        assert initializer is not None
        target = initializer.slots[1].child
        self.assertIsNotNone(target)
        assert target is not None
        target.slots[2].attrs["size"] = "2"
        node.slots.extend((extra_cell, extra_initializer))

        def add_leaf(source: named.NamedStructure) -> named.NamedStructure:
            if isinstance(source.fields[0], named.NamedStructure):
                return named.NamedStructure(source.name,
                                            (add_leaf(source.fields[0]), *source.fields[1:]))
            self.assertIsInstance(source.fields[0], named.IntLeaf)
            first = source.fields[0]
            assert isinstance(first, named.IntLeaf)
            return named.NamedStructure(source.name,
                                        (*source.fields, named.IntLeaf(b"extra", first.value)))

        self.reject_slot(slot, add_leaf(self.deep_source), "shares primitive storage")

    def test_wrong_end_trailer_name_is_rejected(self) -> None:
        source = copy.deepcopy(self.deep_p0.children[self.deep_index])
        while source.children and source.children[0].tag == "frame" and source.children[0].text != b"int":
            source = source.children[0]
        self.assertIsNotNone(source.trailer)
        assert source.trailer is not None
        closing = source.trailer.children[0]
        self.assertIsNotNone(closing.text)
        assert closing.text is not None
        closing.text += b"_mismatch"
        with self.assertRaisesRegex(common.CompareError, "end names"):
            named.named_structure(source, "mutant", empty_short_ok=False)


def main() -> int:
    if len(sys.argv) != 5:
        print(f"usage: {Path(sys.argv[0]).name} WIDE_P0 WIDE_GRAPH DEEP_P0 DEEP_GRAPH",
              file=sys.stderr)
        return 2
    (NamedStructureComparatorTest.wide_p0_path,
     NamedStructureComparatorTest.wide_graph_path,
     NamedStructureComparatorTest.deep_p0_path,
     NamedStructureComparatorTest.deep_graph_path) = (
        Path(argument).resolve() for argument in sys.argv[1:]
    )
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(NamedStructureComparatorTest)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
