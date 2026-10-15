#!/usr/bin/env python3
"""Independent P0-to-physical-graph check for a recursive named Structure.

Usage: graph_named_structure_compare.py [--structure-only] P0_EVENTS GRAPH_EVENTS

The accepted source slice is one root-level named Structure with explicit
``end: Name`` and recursively nested named Structures, either explicitly
closed or empty ``name: ()`` occurrences, plus initialized ``int: name value``
leaves.  Names, order, depths, sibling counts and values come only from P0;
there is no fixture-specific expectation table.  Unsupported forms fail.

Unrelated root fields are not source-compared.  The explicit
``--structure-only`` opt-in permits such a PARTIAL result and lists their
indices.  Without it the checker fails closed.  Native and walker physical
graphs are still compared as complete owned trees.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import sys

import graph_method_order_compare as common


@dataclass(frozen=True)
class IntLeaf:
    name: bytes
    value: int


@dataclass(frozen=True)
class NamedStructure:
    name: bytes
    fields: tuple[NamedStructure | IntLeaf, ...]


def named_structure(frame: common.P0Node, where: str, *, empty_short_ok: bool) -> NamedStructure:
    common.need(frame.tag == "frame", f"{where}: expected named Structure Frame")
    common.need(common.attr(frame.attrs, "colon", where) == "1", f"{where}: colonless frame unsupported")
    name = frame.text
    common.need(name is not None and name != b"", f"{where}: missing Structure name")
    trailer = frame.trailer
    if trailer is None:
        common.need(empty_short_ok and not frame.children,
                    f"{where}: only an empty short Structure may omit its closing trailer")
    else:
        common.need(trailer.tag == "trailer" and trailer.text == b"end",
                    f"{where}: only an explicit end trailer is supported")
        common.need(common.attr(trailer.attrs, "colon", where) == "1"
                    and len(trailer.children) == 1,
                    f"{where}: end trailer must name its Structure exactly once")
        closed_name = common.atom_text(trailer.children[0], f"{where} end")
        common.need(closed_name == name,
                    f"{where}: end names {closed_name!r}, expected {name!r}")
    fields: list[NamedStructure | IntLeaf] = []
    for index, item in enumerate(frame.children):
        field_where = f"{where}.{name!r}[{index}]"
        common.need(item.tag == "frame", f"{field_where}: unsupported non-Frame field {item.tag}")
        if item.text == b"int":
            common.need(item.trailer is None and len(item.children) == 2,
                        f"{field_where}: only initialized int leaf supported")
            leaf_name = common.atom_text(item.children[0], f"{field_where} int name")
            leaf_value = common.int_atom(item.children[1], f"{field_where} int value")
            fields.append(IntLeaf(leaf_name, leaf_value))
        else:
            fields.append(named_structure(item, field_where, empty_short_ok=True))
    return NamedStructure(name, tuple(fields))


def source_structure(root: common.P0Node) -> tuple[int, NamedStructure, list[int]]:
    candidates: list[tuple[int, common.P0Node]] = []
    for index, item in enumerate(root.children):
        if item.tag == "frame" and item.trailer is not None:
            candidates.append((index, item))
    common.need(len(candidates) == 1,
                f"P0: first named-Structure slice requires exactly one root Frame with trailer; "
                f"found {len(candidates)}")
    index, frame = candidates[0]
    structure = named_structure(frame, "P0 root", empty_short_ok=False)
    unchecked = [i for i in range(len(root.children)) if i != index]
    return index, structure, unchecked


def verify_named_slot(slot: common.GraphSlot, source: NamedStructure,
                      where: str, *, root: bool,
                      storage: common.PrimitiveStorageWitness | None = None) -> None:
    own_storage = storage is None
    if storage is None:
        storage = common.PrimitiveStorageWitness()
    common.require_slot(slot, where, kind=6, ty=13, owned=1)
    value_name = common.decode_graph_name(common.attr(slot.attrs, "value_name", where), where)
    common.need(value_name == source.name,
                f"{where}: value name {value_name!r}, expected {source.name!r}")
    if not root:
        cell_name = common.decode_graph_name(common.attr(slot.attrs, "cell_name", where), where)
        common.need(cell_name == source.name,
                    f"{where}: field name {cell_name!r}, expected {source.name!r}")
    graph = slot.child
    assert graph is not None
    begin_name = common.decode_graph_name(common.attr(graph.attrs, "name", where), where)
    common.need(begin_name == source.name, f"{where}: Structure node name mismatch")
    expected_width = sum(2 if isinstance(field, IntLeaf) else 1 for field in source.fields)
    common.need(len(graph.slots) == expected_width,
                f"{where}: physical width {len(graph.slots)}, expected {expected_width} from P0")
    physical = 0
    for source_index, field in enumerate(source.fields):
        field_where = f"{where}.source[{source_index}] physical[{physical}]"
        if isinstance(field, IntLeaf):
            cell = graph.slots[physical]
            common.require_slot(cell, f"{field_where}.cell", kind=1, ty=2)
            cell_name = common.decode_graph_name(common.attr(cell.attrs, "cell_name", field_where), field_where)
            value_name = common.decode_graph_name(common.attr(cell.attrs, "value_name", field_where), field_where)
            common.need(cell_name == field.name and value_name == field.name,
                        f"{field_where}: int field name mismatch")
            actual_value = common.number(common.attr(cell.attrs, "int", field_where), field_where)
            common.need(actual_value == field.value,
                        f"{field_where}: int value {actual_value}, expected {field.value}")
            storage.declaration(cell, f"{field_where}.cell")
            target_index = physical
            physical += 1
            common.set_step(graph.slots[physical], f"{field_where}.initializer", 1,
                            target_index, field.value, storage)
            physical += 1
        else:
            verify_named_slot(graph.slots[physical], field, field_where, root=False,
                              storage=storage)
            physical += 1
    common.need(physical == len(graph.slots), f"{where}: unconsumed physical field")
    if own_storage:
        storage.finish()


def depth_and_width(source: NamedStructure) -> tuple[int, int]:
    maximum_depth = 1
    maximum_width = len(source.fields)
    for field in source.fields:
        if isinstance(field, NamedStructure):
            child_depth, child_width = depth_and_width(field)
            maximum_depth = max(maximum_depth, child_depth + 1)
            maximum_width = max(maximum_width, child_width)
    return maximum_depth, maximum_width


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--structure-only", action="store_true",
                        help="explicit partial comparison when unrelated root fields exist")
    parser.add_argument("p0_events", type=Path)
    parser.add_argument("graph_events", type=Path)
    args = parser.parse_args()
    try:
        source_root = common.parse_p0(args.p0_events)
        root_index, source, unchecked = source_structure(source_root)
        if unchecked and not args.structure_only:
            raise common.CompareError(
                f"P0 root fields {unchecked} are outside the named-Structure slice; "
                "pass --structure-only for an explicitly PARTIAL comparison"
            )
        graphs = common.parse_graph(args.graph_events)
        for label, graph in zip(("native", "walker"), graphs):
            where = f"{label} graph"
            common.need(len(graph.slots) == len(source_root.children),
                        f"{where}: root cardinality disagrees with P0")
            verify_named_slot(graph.slots[root_index], source, f"{where}.root[{root_index}]", root=True)
        common.need(common.canonical_graph(graphs[0]) == common.canonical_graph(graphs[1]),
                    "native and walker complete physical graph trees differ")
        maximum_depth, maximum_width = depth_and_width(source)
    except (common.CompareError, OSError, UnicodeError) as exc:
        print(f"G1 named-structure comparison FAILED: {exc}", file=sys.stderr)
        return 1
    status = "PARTIAL OK" if unchecked else "OK"
    suffix = f"; unchecked P0 root fields={unchecked}" if unchecked else ""
    print(f"G1 named-structure comparison {status}: root={source.name!r} "
          f"depth={maximum_depth} max_siblings={maximum_width} native/walker=2{suffix}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
