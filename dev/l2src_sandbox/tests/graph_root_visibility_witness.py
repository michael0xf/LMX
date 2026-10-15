#!/usr/bin/env python3
"""Inventory P0 root occurrences against bytes visible in the retained graph.

Usage: graph_root_visibility_witness.py P0_EVENTS GRAPH_EVENTS [--root-index N]

This is a deliberately diagnostic, PARTIAL G1 witness, not a source decoder.
It applies one algorithm to every root occurrence: walk its P0 subtree in
source order, walk the same-position physical graph subtree, and report which
P0 head/atom spellings are not visible as graph name annotations or typed
integer values.  It does not assign a meaning to any receiver or OP code.
In particular, an OP can sometimes imply a canonical spelling, a string may
reside outside this event dump, and presence of a spelling elsewhere does not
prove the right occurrence/ordering.  Thus "unwitnessed" is evidence for a
G1 investigation, not by itself proof that the runtime lost those bytes.

The checker fails on malformed evidence, unequal root cardinality, or
native/walker graph divergence.  A successful run always says PARTIAL, even
when every inspected byte happens to be visible.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import sys

import graph_method_order_compare as common


@dataclass(frozen=True)
class SourceMark:
    path: str
    kind: str
    spelling: bytes


def source_marks(node: common.P0Node, path: str) -> list[SourceMark]:
    """Collect source spellings without interpreting receiver semantics."""
    marks: list[SourceMark] = []
    if node.tag == "frame" and node.text is not None:
        marks.append(SourceMark(path, "head", node.text))
    elif node.tag == "trailer" and node.text is not None:
        marks.append(SourceMark(path, "trailer", node.text))
    elif node.tag in {"atom", "disabled"} and node.text is not None:
        marks.append(SourceMark(path, node.tag, node.text))
    for index, child in enumerate(node.children):
        marks.extend(source_marks(child, f"{path}/field[{index}]"))
    if node.trailer is not None:
        marks.extend(source_marks(node.trailer, f"{path}/trailer"))
    return marks


def graph_observables(node: common.GraphNode, path: str) -> tuple[set[bytes], set[int], list[dict]]:
    """Use only typed scalar dump fields and existing source-name annotations."""
    names: set[bytes] = set()
    integers: set[int] = set()
    outline: list[dict] = []

    def add_name(encoded: str | None, where: str) -> None:
        if encoded is not None:
            name = common.decode_graph_name(encoded, where)
            if name is not None:
                names.add(name)

    def visit(current: common.GraphNode, current_path: str) -> None:
        add_name(current.attrs.get("name"), current_path)
        for index, slot in enumerate(current.slots):
            slot_path = f"{current_path}/slot[{index}]"
            attrs = slot.attrs
            add_name(attrs.get("cell_name"), slot_path)
            add_name(attrs.get("value_name"), slot_path)
            if "int" in attrs:
                integers.add(common.number(attrs["int"], slot_path))
            outline.append({
                "path": slot_path,
                "kind": common.number(common.attr(attrs, "kind", slot_path), slot_path),
                "type": common.number(common.attr(attrs, "type", slot_path), slot_path),
                "op": common.number(common.attr(attrs, "op", slot_path), slot_path),
                "owned": common.number(common.attr(attrs, "owned", slot_path), slot_path),
            })
            if slot.child is not None:
                visit(slot.child, slot_path)

    visit(node, path)
    return names, integers, outline


def spelling_record(mark: SourceMark) -> dict:
    return {"path": mark.path, "kind": mark.kind, "hex": mark.spelling.hex(),
            "display": mark.spelling.decode("utf-8", "backslashreplace")}


def source_visible(mark: SourceMark, names: set[bytes], integers: set[int]) -> bool:
    if mark.spelling in names:
        return True
    # An ordinary nonnegative decimal atom can be materialized as a typed
    # primitive.  This does not equate e.g. 007 with 7 or inspect expressions.
    if mark.kind == "atom" and mark.spelling.isdigit():
        value = int(mark.spelling)
        return str(value).encode("ascii") == mark.spelling and value in integers
    return False


def inspect_root(p0: common.P0Node, graph: common.GraphNode, index: int) -> dict:
    path = f"root[{index}]"
    item = p0.children[index]
    slot = graph.slots[index]
    marks = source_marks(item, path)
    names: set[bytes] = set()
    integers: set[int] = set()
    outline: list[dict] = []
    for key in ("cell_name", "value_name"):
        encoded = slot.attrs.get(key)
        if encoded is not None:
            name = common.decode_graph_name(encoded, path)
            if name is not None:
                names.add(name)
    if "int" in slot.attrs:
        integers.add(common.number(slot.attrs["int"], path))
    if slot.child is not None:
        child_names, child_integers, outline = graph_observables(slot.child, path)
        names.update(child_names)
        integers.update(child_integers)
    unwitnessed = [spelling_record(mark) for mark in marks
                   if not source_visible(mark, names, integers)]
    return {
        "root_index": index,
        "source_tag": item.tag,
        "source_direct_children": len(item.children),
        "source_marks_in_order": [spelling_record(mark) for mark in marks],
        "graph_root_kind": common.number(common.attr(slot.attrs, "kind", path), path),
        "graph_root_op": common.number(common.attr(slot.attrs, "op", path), path),
        "graph_direct_slots": len(slot.child.slots) if slot.child is not None else 0,
        "graph_owned_outline_in_order": outline,
        "graph_name_hex": sorted(name.hex() for name in names),
        "graph_int_values": sorted(integers),
        "unwitnessed_marks": unwitnessed,
    }


def compare(p0: common.P0Node, graphs: list[common.GraphNode],
            root_index: int | None = None) -> dict:
    common.need(len(graphs) == 2, "graph: expected native and walker blocks")
    for label, graph in zip(("native", "walker"), graphs):
        common.need(len(graph.slots) == len(p0.children),
                    f"{label}: root cardinality {len(graph.slots)} != P0 {len(p0.children)}")
    common.need(common.canonical_graph(graphs[0]) == common.canonical_graph(graphs[1]),
                "native and walker complete physical graph trees differ")
    indices = range(len(p0.children)) if root_index is None else (root_index,)
    if root_index is not None:
        common.need(0 <= root_index < len(p0.children),
                    f"root index {root_index} outside 0..{len(p0.children) - 1}")
    return {
        "status": "PARTIAL_DIAGNOSTIC",
        "root_cardinality": len(p0.children),
        "native_walker_physical_trees_equal": True,
        "scope": "P0 spellings visible as retained graph names or typed integers only",
        "limitations": [
            "OP semantics and external string storage are not decoded",
            "spelling presence does not prove occurrence identity or source order",
            "unwitnessed does not by itself prove irreversible information loss",
        ],
        "fields": [inspect_root(p0, graphs[0], index) for index in indices],
    }


def require_executing_root_head(p0: common.P0Node,
                                graphs: list[common.GraphNode], index: int) -> None:
    """Gate one selected Frame's head on its physical executing occurrence."""
    common.need(0 <= index < len(p0.children), f"root index {index} outside P0")
    source = p0.children[index]
    common.need(source.tag == "frame" and source.text is not None,
                f"root[{index}]: expected a written Frame head")
    for label, graph in zip(("native", "walker"), graphs):
        slot = graph.slots[index]
        op = common.number(common.attr(slot.attrs, "op", f"{label} root[{index}]"),
                           f"{label} root[{index}]")
        common.need(op > 0 and slot.child is not None,
                    f"{label} root[{index}]: expected one executing graph occurrence")
        actual = common.decode_graph_name(slot.attrs.get("value_name"),
                                          f"{label} root[{index}]")
        common.need(actual == source.text,
                    f"{label} root[{index}]: written head is not on its graph occurrence")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("p0_events", type=Path)
    parser.add_argument("graph_events", type=Path)
    parser.add_argument("--root-index", type=int)
    parser.add_argument("--require-root-head", action="store_true",
                        help="gate the selected executing Frame's written head")
    args = parser.parse_args()
    try:
        p0 = common.parse_p0(args.p0_events)
        graphs = common.parse_graph(args.graph_events)
        report = compare(p0, graphs, args.root_index)
        if args.require_root_head:
            common.need(args.root_index is not None,
                        "--require-root-head needs --root-index")
            require_executing_root_head(p0, graphs, args.root_index)
    except (common.CompareError, OSError, UnicodeError, ValueError) as exc:
        print(f"G1 root visibility witness FAILED: {exc}", file=sys.stderr)
        return 1
    if args.require_root_head:
        report["root_head_gate"] = "PASS"
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
