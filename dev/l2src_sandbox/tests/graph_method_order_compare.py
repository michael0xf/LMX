#!/usr/bin/env python3
"""Compare one P0 method body with its physical Lmx graph in both run modes.

This is a deliberately narrow, independent G1 oracle slice.  Its source input is
the length-prefixed event stream from graph_p0_method_order_oracle.c, not a list
of expected fixture words.  Its graph input is the environment-gated
``shape_dump_graph_events`` stream from l2_eternal_driver.lm1.  It currently
supports one root-level ``sub`` with empty arguments and these body forms:
``int: name decimal``, ``name: decimal`` (for an earlier local), a parenthesized
``(decimal + decimal)``, and ``return``.  Unsupported source forms fail closed.

Usage: graph_method_order_compare.py [--method-body-only] P0_EVENTS GRAPH_EVENTS

The graph dump must print SIZE_T coordinate operands as ``size=``.  This
checker uses them to prove that each OWN instruction addresses its P0-derived
declaration cell, as well as physical order, roles, nesting, cardinality, names
and integer values.  Each supported Frame body step also checks its written
head at the exact executing slot, not merely somewhere else in the method.
By default, any root field other than the method is an
explicit unsupported-form failure.  ``--method-body-only`` opts into a
partial result that names those unchecked root positions (such as
sendMessage), rather than silently claiming full G1 coverage.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from pathlib import Path
import re
import sys


class CompareError(Exception):
    """Input, unsupported-form, or comparison failure with a useful location."""


@dataclass
class P0Node:
    tag: str
    attrs: dict[str, str]
    text: bytes | None = None
    children: list[P0Node] = field(default_factory=list)
    trailer: P0Node | None = None


@dataclass
class GraphSlot:
    attrs: dict[str, str]
    child: GraphNode | None = None


@dataclass
class GraphNode:
    attrs: dict[str, str]
    slots: list[GraphSlot] = field(default_factory=list)


@dataclass(frozen=True)
class BodyEvent:
    kind: str
    name: bytes | None = None
    value: int | None = None
    right: int | None = None
    head: bytes | None = None


@dataclass
class PrimitiveStorageWitness:
    """Check storage identity only for declarations/literals verified from P0.

    Literal cells may be shared with other literals, but not with a mutable
    declaration in this source slice.  The addresses are compared only inside
    one physical graph, never across native/walker processes.
    """

    declarations: dict[str, str] = field(default_factory=dict)
    literals: list[tuple[str, str]] = field(default_factory=list)

    def declaration(self, slot: GraphSlot, where: str) -> None:
        address = attr(slot.attrs, "value", where)
        need(address != "0000000000000000", f"{where}: declaration has null storage")
        previous = self.declarations.get(address)
        need(previous is None,
             f"{where}: mutable declaration shares primitive storage with {previous}")
        self.declarations[address] = where

    def literal(self, slot: GraphSlot, where: str) -> None:
        for key in ("cell_name", "value_name"):
            need(attr(slot.attrs, key, where) == "-",
                 f"{where}: LIT data has source {key}")
        address = attr(slot.attrs, "value", where)
        need(address != "0000000000000000", f"{where}: LIT data has null storage")
        self.literals.append((address, where))

    def finish(self) -> None:
        for address, where in self.literals:
            declaration = self.declarations.get(address)
            need(declaration is None,
                 f"{where}: LIT data aliases mutable declaration storage at {declaration}")


def need(condition: bool, message: str) -> None:
    if not condition:
        raise CompareError(message)


def number(value: str, where: str) -> int:
    try:
        return int(value, 10)
    except ValueError as exc:
        raise CompareError(f"{where}: invalid decimal {value!r}") from exc


def attr(attrs: dict[str, str], key: str, where: str) -> str:
    try:
        return attrs[key]
    except KeyError as exc:
        raise CompareError(f"{where}: missing {key}") from exc


def parse_attrs(tokens: list[str], where: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for token in tokens:
        key, mark, value = token.partition("=")
        need(bool(mark and key and value), f"{where}: malformed attribute {token!r}")
        need(key not in result, f"{where}: duplicate attribute {key}")
        result[key] = value
    return result


def decode_p0_text(encoded: str, where: str) -> bytes | None:
    if encoded == "null":
        return None
    size_text, mark, escaped = encoded.partition("=")
    need(bool(mark) and size_text.isdecimal(), f"{where}: bad length-prefixed text")
    result = bytearray()
    i = 0
    while i < len(escaped):
        if escaped[i] != "\\":
            result.append(ord(escaped[i]))
            i += 1
        elif escaped.startswith("\\\\", i):
            result.append(0x5C)
            i += 2
        elif escaped.startswith("\\x", i) and i + 4 <= len(escaped):
            try:
                result.append(int(escaped[i + 2 : i + 4], 16))
            except ValueError as exc:
                raise CompareError(f"{where}: invalid hex escape") from exc
            i += 4
        else:
            raise CompareError(f"{where}: invalid escape")
    need(len(result) == int(size_text), f"{where}: text byte length disagrees")
    return bytes(result)


def parse_p0_record(raw: bytes, line_number: int) -> tuple[str, dict[str, str], bytes | None]:
    where = f"P0 record {line_number}"
    size_raw, mark, payload = raw.partition(b":")
    need(bool(mark) and size_raw.isdigit(), f"{where}: missing byte-count prefix")
    need(len(payload) == int(size_raw), f"{where}: byte-count mismatch")
    try:
        line = payload.decode("ascii")
    except UnicodeDecodeError as exc:
        raise CompareError(f"{where}: non-ASCII event payload") from exc
    if line in {"p0-events 1", "end-document"}:
        return line, {}, None
    tag, _, rest = line.partition(" ")
    text: bytes | None = None
    text_key = {
        "frame": "head", "atom": "text", "disabled": "text",
        "trailer": "spelling", "reject": "message",
    }.get(tag)
    if text_key is not None:
        marker = f" {text_key}="
        if marker in line:
            before, encoded = line.split(marker, 1)
            need(before.startswith(tag), f"{where}: malformed text record")
            text = decode_p0_text(encoded, where)
            rest = before[len(tag) :].strip()
    attrs = parse_attrs(rest.split(), where)
    return tag, attrs, text


def parse_p0(path: Path) -> P0Node:
    raw_lines = path.read_bytes().splitlines()
    need(bool(raw_lines), "P0: empty event file")
    records = [parse_p0_record(raw.rstrip(b"\r"), i) for i, raw in enumerate(raw_lines, 1)]
    need(records[0][0] == "p0-events 1", "P0: unsupported event version")
    need(records[-1][0] == "end-document", "P0: missing end-document")
    need(len(records) >= 4 and records[1][0] == "document", "P0: missing document")
    need(attr(records[1][1], "root", "P0 document") == "structure", "P0: root is not Structure")
    stack: list[P0Node] = []
    root: P0Node | None = None
    for ordinal, (tag, attrs, text_value) in enumerate(records[2:-1], 3):
        where = f"P0 record {ordinal}"
        if tag in {"structure", "frame"}:
            depth = number(attr(attrs, "depth", where), where)
            need(depth == len(stack), f"{where}: depth mismatch")
            node = P0Node(tag, attrs, text_value)
            if stack:
                index = number(attr(attrs, "index", where), where)
                need(index == len(stack[-1].children), f"{where}: child index mismatch")
                stack[-1].children.append(node)
            else:
                need(root is None and tag == "structure", f"{where}: extra/non-Structure root")
                root = node
            stack.append(node)
        elif tag in {"atom", "disabled", "null-field", "node"}:
            need(bool(stack), f"{where}: field outside Structure")
            depth = number(attr(attrs, "depth", where), where)
            index = number(attr(attrs, "index", where), where)
            need(depth == len(stack) and index == len(stack[-1].children), f"{where}: field place mismatch")
            stack[-1].children.append(P0Node(tag, attrs, text_value))
        elif tag == "trailer":
            need(bool(stack), f"{where}: trailer outside owner")
            owner = stack[-1]
            owner_kind = attr(attrs, "of", where)
            need(owner_kind == owner.tag, f"{where}: trailer owner mismatch")
            need(number(attr(attrs, "depth", where), where) == len(stack), f"{where}: trailer depth mismatch")
            need(owner.trailer is None, f"{where}: second trailer on one owner")
            trailer = P0Node(tag, attrs, text_value)
            owner.trailer = trailer
            stack.append(trailer)
        elif tag == "end-trailer":
            need(bool(stack) and stack[-1].tag == "trailer", f"{where}: unmatched end-trailer")
            trailer = stack.pop()
            need(number(attr(attrs, "depth", where), where) == len(stack), f"{where}: trailer end depth mismatch")
            need(attr(attrs, "of", where) == attr(trailer.attrs, "of", where), f"{where}: trailer end owner mismatch")
            count = number(attr(attrs, "walked", where), where)
            need(count == len(trailer.children), f"{where}: trailer walked count mismatch")
            need(number(attr(trailer.attrs, "body_fields", where), where) == count,
                 f"{where}: trailer body field count mismatch")
            need(attr(trailer.attrs, "body_trailer", where) == "0",
                 f"{where}: nested trailer unsupported by first G1 slices")
        elif tag in {"end-structure", "end-frame"}:
            need(bool(stack), f"{where}: unmatched end")
            node = stack.pop()
            need(tag == f"end-{node.tag}", f"{where}: wrong end tag")
            depth = number(attr(attrs, "depth", where), where)
            need(depth == len(stack), f"{where}: end depth mismatch")
            count = number(attr(attrs, "walked", where), where)
            need(count == len(node.children), f"{where}: walked child count mismatch")
            expected = "fields" if node.tag == "structure" else "body_fields"
            need(number(attr(node.attrs, expected, where), where) == count, f"{where}: declared child count mismatch")
            trailer_flag = attr(node.attrs, "trailer", where)
            need(trailer_flag in {"0", "1"} and (trailer_flag == "1") == (node.trailer is not None),
                 f"{where}: trailer presence disagrees with owner")
            if node.tag == "frame":
                need(attr(node.attrs, "body_trailer", where) == "0", f"{where}: frame-body trailer unsupported")
        else:
            raise CompareError(f"{where}: unsupported record {tag!r}")
    need(root is not None and not stack, "P0: incomplete tree")
    return root


def ascii_text(value: bytes | None, where: str) -> str:
    need(value is not None, f"{where}: missing text")
    try:
        return value.decode("ascii")
    except UnicodeDecodeError as exc:
        raise CompareError(f"{where}: non-ASCII name outside this G1 slice") from exc


def atom_text(node: P0Node, where: str) -> bytes:
    need(node.tag == "atom" and node.text is not None, f"{where}: expected atom")
    return node.text


def int_atom(node: P0Node, where: str) -> int:
    spelling = ascii_text(atom_text(node, where), where)
    need(bool(re.fullmatch(r"[0-9]+", spelling)), f"{where}: expected nonnegative decimal literal")
    return int(spelling)


def source_method(root: P0Node) -> tuple[int, bytes, list[BodyEvent]]:
    methods: list[tuple[int, P0Node]] = []
    for index, item in enumerate(root.children):
        if item.tag == "frame" and item.text in {b"sub", b"fn", b"fm"}:
            methods.append((index, item))
    need(len(methods) == 1, f"P0: first G1 slice requires exactly one root method; found {len(methods)}")
    index, method = methods[0]
    need(method.text == b"sub", "P0: first G1 slice supports a sub method only")
    need(method.trailer is None, "P0 method: closing trailer unsupported by method-body slice")
    need(len(method.children) == 3, "P0 method: expected name, empty signature, body")
    name = atom_text(method.children[0], "P0 method name")
    need(name != b"", "P0 method: empty name")
    args, body = method.children[1:]
    need(args.tag == "structure" and not args.children, "P0 method: only empty argument list supported")
    need(body.tag == "structure", "P0 method: body is not Structure")
    need(args.trailer is None and body.trailer is None,
         "P0 method: header/body trailer unsupported by method-body slice")
    declared: set[bytes] = set()
    events: list[BodyEvent] = []
    for source_index, item in enumerate(body.children):
        where = f"P0 method {name!r} body field {source_index}"
        need(item.trailer is None, f"{where}: nested trailer unsupported by method-body slice")
        if item.tag == "frame":
            need(attr(item.attrs, "colon", where) == "1", f"{where}: colonless frame unsupported")
            head = item.text
            if head == b"int":
                need(len(item.children) == 2, f"{where}: only initialized int declaration supported")
                field_name = atom_text(item.children[0], where)
                need(field_name not in declared, f"{where}: repeated declaration unsupported")
                declared.add(field_name)
                events.append(BodyEvent("declaration", field_name, int_atom(item.children[1], where), head=head))
            elif head in declared:
                need(len(item.children) == 1, f"{where}: only one-literal assignment supported")
                events.append(BodyEvent("assignment", head, int_atom(item.children[0], where), head=head))
            else:
                raise CompareError(f"{where}: unsupported receiver {head!r}")
        elif item.tag == "structure":
            need(len(item.children) == 3, f"{where}: only binary expression supported")
            need(atom_text(item.children[1], where) == b"+", f"{where}: only addition supported")
            events.append(BodyEvent("add", value=int_atom(item.children[0], where), right=int_atom(item.children[2], where)))
        elif item.tag == "atom":
            need(item.text == b"return", f"{where}: unsupported bare atom {item.text!r}")
            events.append(BodyEvent("return"))
        else:
            raise CompareError(f"{where}: unsupported P0 node {item.tag!r}")
    need(bool(events), "P0 method: empty body unsupported by first G1 slice")
    return index, name, events


def parse_graph(path: Path) -> list[GraphNode]:
    lines = path.read_text(encoding="ascii").splitlines()
    need(bool(lines), "graph: empty event file")
    graphs: list[GraphNode] = []
    stack: list[GraphNode] = []
    in_graph = False
    block_roots = 0
    for line_number, line in enumerate(lines, 1):
        where = f"graph line {line_number}"
        fields = line.split()
        need(bool(fields), f"{where}: blank line")
        tag = fields[0]
        if tag == "graph-events":
            need(not in_graph and len(fields) == 2 and fields[1] == "1", f"{where}: bad graph header")
            in_graph = True
            block_roots = 0
            continue
        need(in_graph, f"{where}: record outside graph block")
        if tag == "begin":
            attrs = parse_attrs(fields[1:], where)
            depth = number(attr(attrs, "depth", where), where)
            via = number(attr(attrs, "via", where), where)
            need(depth == len(stack), f"{where}: begin depth mismatch")
            node = GraphNode(attrs)
            if stack:
                parent = stack[-1]
                need(via == len(parent.slots) - 1, f"{where}: begin does not follow its slot")
                slot = parent.slots[-1]
                need(attr(slot.attrs, "owned", where) == "1" and slot.child is None, f"{where}: child ownership mismatch")
                need(attr(attrs, "parent", where) == attr(parent.attrs, "node", where), f"{where}: physical parent mismatch")
                need(attr(attrs, "node", where) == attr(slot.attrs, "value", where), f"{where}: child pointer mismatch")
                slot.child = node
            else:
                need(via == 0 and attr(attrs, "parent", where) == "0000000000000000", f"{where}: invalid root")
                need(block_roots == 0, f"{where}: second root in one graph block")
                block_roots += 1
                graphs.append(node)
            stack.append(node)
        elif tag == "slot":
            need(bool(stack), f"{where}: slot outside node")
            attrs = parse_attrs(fields[1:], where)
            node = stack[-1]
            depth = number(attr(attrs, "depth", where), where)
            index = number(attr(attrs, "index", where), where)
            need(depth == len(stack) - 1 and index == len(node.slots), f"{where}: slot order/depth mismatch")
            if node.slots:
                last = node.slots[-1]
                need(attr(last.attrs, "owned", where) != "1" or last.child is not None, f"{where}: owned slot has no child")
            node.slots.append(GraphSlot(attrs))
        elif tag == "end":
            need(bool(stack), f"{where}: unmatched end")
            attrs = parse_attrs(fields[1:], where)
            node = stack.pop()
            need(number(attr(attrs, "depth", where), where) == len(stack), f"{where}: end depth mismatch")
            need(attr(attrs, "via", where) == attr(node.attrs, "via", where), f"{where}: end via mismatch")
            need(number(attr(node.attrs, "width", where), where) == len(node.slots), f"{where}: node width mismatch")
            if node.slots:
                last = node.slots[-1]
                need(attr(last.attrs, "owned", where) != "1" or last.child is not None, f"{where}: trailing owned slot has no child")
        elif tag == "end-graph":
            need(len(fields) == 1 and not stack and block_roots == 1,
                 f"{where}: unfinished or rootless graph")
            in_graph = False
        else:
            raise CompareError(f"{where}: unknown record {tag!r}")
    need(not in_graph and not stack, "graph: truncated final block")
    need(len(graphs) == 2, f"graph: expected native and walker blocks; found {len(graphs)}")
    return graphs


def decode_graph_name(value: str, where: str) -> bytes | None:
    if value == "-":
        return None
    size, mark, hex_data = value.partition(":")
    need(bool(mark) and size.isdecimal(), f"{where}: bad name encoding")
    try:
        name = bytes.fromhex(hex_data)
    except ValueError as exc:
        raise CompareError(f"{where}: non-hex name") from exc
    need(len(name) == int(size), f"{where}: name byte length mismatch")
    return name


def require_slot(slot: GraphSlot, where: str, *, kind: int, ty: int, op: int = -1,
                 role: int = -1, owned: int = 0) -> None:
    for key, wanted in (("kind", kind), ("type", ty), ("op", op), ("role", role), ("owned", owned)):
        actual = number(attr(slot.attrs, key, where), where)
        need(actual == wanted, f"{where}: {key}={actual}, expected {wanted}")
    need((slot.child is not None) == bool(owned), f"{where}: child ownership mismatch")


def opcode(node: GraphNode, where: str, code: int, role: int, width: int) -> None:
    need(len(node.slots) == width, f"{where}: op width {len(node.slots)}, expected {width}")
    record = node.slots[0]
    require_slot(record, f"{where}.op", kind=17, ty=31, op=code)


def literal(slot: GraphSlot, where: str, value: int, storage: PrimitiveStorageWitness) -> None:
    require_slot(slot, where, kind=6, ty=13, op=3, role=0, owned=1)
    node = slot.child
    assert node is not None
    opcode(node, where, 3, 0, 2)
    data = node.slots[1]
    require_slot(data, f"{where}.value", kind=1, ty=2)
    storage.literal(data, f"{where}.value")
    actual = number(attr(data.attrs, "int", where), where)
    need(actual == value, f"{where}: literal {actual}, expected {value}")


def set_step(slot: GraphSlot, where: str, role: int, target_index: int, value: int,
             storage: PrimitiveStorageWitness) -> None:
    require_slot(slot, where, kind=6, ty=13, op=8, role=role, owned=1)
    node = slot.child
    assert node is not None
    opcode(node, where, 8, role, 3)
    target = node.slots[1]
    require_slot(target, f"{where}.target", kind=6, ty=13, op=4, role=0, owned=1)
    target_node = target.child
    assert target_node is not None
    opcode(target_node, f"{where}.target", 4, 0, 3)
    require_slot(target_node.slots[1], f"{where}.target.base", kind=0, ty=0)
    need(attr(target_node.slots[1].attrs, "value", where) == "0000000000000000", f"{where}: target base not null")
    coordinate = target_node.slots[2]
    require_slot(coordinate, f"{where}.target.coordinate", kind=1, ty=3)
    actual_index = number(attr(coordinate.attrs, "size", where), where)
    need(actual_index == target_index,
         f"{where}: OWN target index {actual_index}, expected declaration slot {target_index}")
    literal(node.slots[2], f"{where}.value", value, storage)


def verify_method(root: GraphNode, root_index: int, method_name: bytes,
                  events: list[BodyEvent], source_root_width: int, label: str) -> None:
    where = f"{label} graph"
    need(len(root.slots) == source_root_width, f"{where}: root width differs from P0")
    need(root_index < len(root.slots), f"{where}: method root slot absent")
    method_slot = root.slots[root_index]
    require_slot(method_slot, f"{where}.method", kind=6, ty=13, owned=1)
    seen_name = decode_graph_name(attr(method_slot.attrs, "value_name", where), where)
    need(seen_name == method_name, f"{where}: method name {seen_name!r}, expected {method_name!r}")
    method = method_slot.child
    assert method is not None
    need(decode_graph_name(attr(method.attrs, "name", where), where) == method_name,
         f"{where}: begin name does not match P0 method")
    expected_width = 2 + sum(2 if e.kind == "declaration" else 1 for e in events)
    need(len(method.slots) == expected_width,
         f"{where}: method width {len(method.slots)}, expected {expected_width} from P0")
    for header_index in (0, 1):
        header = method.slots[header_index]
        require_slot(header, f"{where}.header[{header_index}]", kind=6, ty=13, owned=1)
        need(header.child is not None and not header.child.slots,
             f"{where}.header[{header_index}]: expected empty Structure")
    physical = 2
    declaration_slots: dict[bytes, int] = {}
    storage = PrimitiveStorageWitness()
    for source_index, event in enumerate(events):
        place = f"{where}.body[{source_index}] physical[{physical}]"
        head_slot: GraphSlot | None = None
        if event.kind == "declaration":
            assert event.name is not None and event.value is not None
            declaration_slots[event.name] = physical
            slot = method.slots[physical]
            require_slot(slot, f"{place}.cell", kind=1, ty=2)
            actual_name = decode_graph_name(attr(slot.attrs, "value_name", place), place)
            need(actual_name == event.name, f"{place}: declaration name {actual_name!r}, expected {event.name!r}")
            need(number(attr(slot.attrs, "int", place), place) == event.value,
                 f"{place}: declaration initial value mismatch")
            storage.declaration(slot, f"{place}.cell")
            physical += 1
            head_slot = method.slots[physical]
            set_step(head_slot, f"{place}.initializer", 1,
                     declaration_slots[event.name], event.value, storage)
            physical += 1
        elif event.kind == "assignment":
            assert event.name is not None and event.value is not None
            head_slot = method.slots[physical]
            set_step(head_slot, place, 0,
                     declaration_slots[event.name], event.value, storage)
            physical += 1
        elif event.kind == "add":
            holder = method.slots[physical]
            require_slot(holder, place, kind=6, ty=13, owned=1)
            container = holder.child
            assert container is not None
            need(len(container.slots) == 1, f"{place}: anonymous expression lost/gained a child")
            add = container.slots[0]
            require_slot(add, f"{place}.add", kind=6, ty=13, op=9, role=0, owned=1)
            add_node = add.child
            assert add_node is not None
            opcode(add_node, f"{place}.add", 9, 0, 3)
            literal(add_node.slots[1], f"{place}.left", event.value or 0, storage)
            literal(add_node.slots[2], f"{place}.right", event.right or 0, storage)
            physical += 1
        elif event.kind == "return":
            ret = method.slots[physical]
            require_slot(ret, place, kind=6, ty=13, op=1, role=0, owned=1)
            ret_node = ret.child
            assert ret_node is not None
            opcode(ret_node, place, 1, 0, 1)
            physical += 1
        else:
            raise CompareError(f"{place}: unsupported source event {event.kind}")
        if event.head is not None:
            need(head_slot is not None, f"{place}: supported Frame has no executing slot")
            actual_head = decode_graph_name(attr(head_slot.attrs, "value_name", place), place)
            need(actual_head == event.head,
                 f"{place}: Frame head {actual_head!r}, expected {event.head!r} on this occurrence")
    need(physical == len(method.slots), f"{where}: unconsumed physical method slot")
    storage.finish()


def canonical_graph(root: GraphNode) -> tuple:
    """Compare complete owned trees and external-reference alias shape.

    First-seen ordinals preserve repeated-vs-distinct external Structure
    addresses within each graph.  They cannot establish that two distinct
    external objects in different processes have the same identity.
    """
    address_path: dict[str, tuple[int, ...]] = {}
    external_ordinals: dict[str, int] = {}

    def assign(node: GraphNode, path: tuple[int, ...]) -> None:
        address = attr(node.attrs, "node", "canonical graph")
        need(address not in address_path, "graph: one owned node appears twice")
        address_path[address] = path
        for i, slot in enumerate(node.slots):
            if slot.child is not None:
                assign(slot.child, path + (i,))

    assign(root, ())

    def visit(node: GraphNode) -> tuple:
        slots: list[tuple] = []
        for slot in node.slots:
            attrs = slot.attrs
            value = attr(attrs, "value", "canonical slot")
            if value == "0000000000000000":
                reference: tuple | str = "null"
            elif number(attr(attrs, "kind", "canonical slot"), "canonical slot") == 6:
                if value in address_path:
                    reference = ("graph", address_path[value])
                else:
                    if value not in external_ordinals:
                        external_ordinals[value] = len(external_ordinals)
                    reference = ("external-structure", external_ordinals[value])
            else:
                reference = "value"
            fields = tuple((key, attrs.get(key)) for key in
                           ("kind", "type", "op", "role", "owned", "cell_name", "value_name", "int", "char", "size", "array"))
            slots.append((fields, reference, visit(slot.child) if slot.child is not None else None))
        return (attr(node.attrs, "name", "canonical node"), len(node.slots), tuple(slots))

    return visit(root)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--method-body-only", action="store_true",
                        help="explicit partial slice: report, but do not source-compare, other root fields")
    parser.add_argument("p0_events", type=Path)
    parser.add_argument("graph_events", type=Path)
    args = parser.parse_args()
    try:
        p0 = parse_p0(args.p0_events)
        root_index, method_name, events = source_method(p0)
        unchecked = [i for i in range(len(p0.children)) if i != root_index]
        if unchecked and not args.method_body_only:
            raise CompareError(
                f"P0 root fields {unchecked} are outside the method-body slice; "
                "pass --method-body-only for an explicitly PARTIAL comparison"
            )
        graphs = parse_graph(args.graph_events)
        for label, graph in zip(("native", "walker"), graphs):
            verify_method(graph, root_index, method_name, events, len(p0.children), label)
        need(canonical_graph(graphs[0]) == canonical_graph(graphs[1]),
             "native and walker complete physical graph trees differ")
    except (CompareError, OSError, UnicodeError) as exc:
        print(f"G1 method-order comparison FAILED: {exc}", file=sys.stderr)
        return 1
    status = "PARTIAL OK" if unchecked else "OK"
    suffix = f"; unchecked P0 root fields={unchecked}" if unchecked else ""
    print(f"G1 method-order comparison {status}: method={method_name.decode('ascii')} "
          f"source_body_fields={len(events)} native/walker=2; OWN target coordinates and Frame-head occurrences verified{suffix}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
