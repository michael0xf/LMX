#!/usr/bin/env python3
"""Strict P0-to-retained-graph witness for one root sendMessage occurrence.

Usage: graph_send_source_compare.py P0_EVENTS GRAPH_EVENTS

The supported source slice is the unique root-level `sendMessage: [Ref]
exit(...)` Frame with one exit_code decimal and one unescaped quoted
stdout/stderr literal, in any written field order. Other root occurrences
are explicitly unchecked.

The optional Ref is the run of written atoms before the exit Structure. The
supported Ref syntax is one path `base\\selector[\\selector...]` of
identifier atoms separated by `\\` atoms (a P0 path is sibling atoms). Its
meaning is derived from P0 alone:

* `base` must be declared by exactly one root-level two-name
  `receiveMessage: base Model`. That declaration types `base` as a letter
  whose shape is `(sender; payload: Model)` -- the author's letter form
  (steps/closure-map.md, answer K3) synthesized by the translator as
  `{sender: @: LmxMsg; payload: Model}` (steps/send-ref-172.md). The
  letter shape is a type rule applied to whatever names are written; the
  oracle has no table of fixture names.
* Each selector is resolved by name to its field index in the current
  model: the letter shape first, then the P0 definition `Model: ... end:
  Model` for a selector after `payload`, recursively for nested named
  Structures. A field's name is the head of a nested named Structure or,
  for a typed leaf, the first atom after its head chain (`int: i 5`,
  `char: []: []: mainArgs`: the "name - requirement - optional value"
  order, READ.ME). `sender` has no P0 model, so a selector after it is
  unsupported. Any other form (a bare name, a Frame, an operator, a
  one-name receiveMessage, another declaring statement) fails closed.

The physical witness is the unique root sendMessage occurrence, which need
not have the same physical index when earlier declarations materialize
storage. Its single source-owned body is in PRIM_PUB slot 2 and keeps the
written order: the Ref expression node first (when written), then the
SOURCE_INERT exit Structure. Slots 3 onward must borrow those very same
source-owned nodes: each NAMED field node, and, last, the Ref node itself.

The Ref expression's physical layout was read from the native and walker
event dumps of `unit_receive_letter_model_root` (`m\\sender`) and of the
`length(m\\payload\\mainArgs)` operand in the same program
(build/g1send_ref_owned_20261014_03/logs): one OF node per selector, width
3 (OF record, base, SIZE_T coordinate), the outermost node standing for the
last selector and owning the node of the previous selector in its base
slot; the innermost base is a borrowed (not owned) reference to the OWN
node that the base's root-level declaration owns -- the node whose second
slot is the cell named `base`. Every coordinate must equal the P0-resolved
field index. Both native and walker graph blocks are checked independently
before their complete graph shapes are compared. Unsupported source or
physical forms fail closed.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
import sys

import graph_method_order_compare as common


# The conventional root index of the no-Ref fixtures; the oracle locates
# the occurrence itself and never assumes this index.
ROOT_INDEX = 2
OWN = 4
SET = 8
OF = 15
PRIM_PUB = 33
SOURCE_INERT = 44
NAMED = 47
NULL_ADDRESS = "0000000000000000"
PATH_SEPARATOR = b"\\"
IDENTIFIER = re.compile(rb"[A-Za-z_][A-Za-z0-9_]*")
RECEIVE_HEAD = b"receiveMessage"
END_TRAILER = b"end"
# The letter shape: field order of the type that a two-name receiveMessage
# gives its name. `sender` is a foreign Message reference without a P0
# model; `payload` is typed by the written Model definition.
LETTER_MODEL_NAME = b"letter"
LETTER_SENDER = b"sender"
LETTER_PAYLOAD = b"payload"


@dataclass(frozen=True)
class SourceField:
    name: bytes
    integer: int | None = None
    text: bytes | None = None


@dataclass(frozen=True)
class ModelField:
    """One field of a model known from P0. `frame` is the P0 Frame defining
    a nested named Structure; `definition_name` names a root-level
    definition to be read on demand; neither means a terminal field."""
    name: bytes
    frame: common.P0Node | None = None
    definition_name: bytes | None = None


@dataclass(frozen=True)
class Model:
    name: bytes
    fields: tuple[ModelField, ...]

    def select(self, selector: bytes, where: str) -> tuple[int, ModelField]:
        for index, field in enumerate(self.fields):
            if field.name == selector:
                return index, field
        names = [field.name.decode("ascii", "backslashreplace") for field in self.fields]
        raise common.CompareError(
            f"{where}: {selector!r} is not a field of model {self.name!r} (fields {names})")


@dataclass(frozen=True)
class RefPath:
    base: bytes
    selectors: tuple[bytes, ...]

    @property
    def spelling(self) -> bytes:
        return PATH_SEPARATOR.join((self.base,) + self.selectors)


@dataclass(frozen=True)
class ResolvedRef:
    path: RefPath
    declaration_index: int
    declaration_head: bytes
    coordinates: tuple[int, ...]
    models: tuple[bytes, ...]


@dataclass(frozen=True)
class SourceSend:
    index: int
    ref: ResolvedRef | None
    fields: tuple[SourceField, ...]

    @property
    def has_ref(self) -> int:
        return 0 if self.ref is None else 1


def plain_string(node: common.P0Node, where: str) -> bytes:
    token = common.atom_text(node, where)
    common.need(len(token) >= 2 and token[:1] == b'"' and token[-1:] == b'"',
                f"{where}: expected a quoted string")
    body = token[1:-1]
    common.need(all(0x20 <= byte <= 0x7E and byte not in (0x22, 0x5C)
                    for byte in body),
                f"{where}: only unescaped printable string bytes are supported")
    return body


def identifier(node: common.P0Node, where: str) -> bytes:
    common.need(node.tag == "atom" and node.text is not None,
                f"{where}: unsupported Ref form: expected an identifier atom, got {node.tag}")
    assert node.text is not None
    common.need(IDENTIFIER.fullmatch(node.text) is not None,
                f"{where}: unsupported Ref form: {node.text!r} is not an identifier")
    return node.text


def source_ref(nodes: list[common.P0Node], where: str) -> RefPath:
    """The written Ref: sibling atoms `base \\ selector [\\ selector ...]`."""
    common.need(len(nodes) != 1,
                f"{where}: unsupported Ref form: a bare name without a selector "
                "has no physical witness in this slice")
    common.need(len(nodes) % 2 == 1,
                f"{where}: unsupported Ref form: expected base\\selector..., "
                f"got {len(nodes)} written fields")
    base = identifier(nodes[0], f"{where}.ref[0]")
    selectors: list[bytes] = []
    for k in range(1, len(nodes), 2):
        separator = nodes[k]
        common.need(separator.tag == "atom" and separator.text == PATH_SEPARATOR,
                    f"{where}.ref[{k}]: unsupported Ref form: expected the path "
                    f"separator, got {separator.text if separator.tag == 'atom' else separator.tag!r}")
        selectors.append(identifier(nodes[k + 1], f"{where}.ref[{k + 1}]"))
    return RefPath(base, tuple(selectors))


def definition_frame(root: common.P0Node, name: bytes, where: str) -> common.P0Node:
    matches = [child for child in root.children
               if child.tag == "frame" and child.text == name and child.trailer is not None]
    common.need(len(matches) == 1,
                f"{where}: expected one root-level definition {name!r} closed by an end "
                f"trailer, found {len(matches)}")
    frame = matches[0]
    closing(frame, name, where)
    return frame


def closing(frame: common.P0Node, name: bytes, where: str) -> None:
    trailer = frame.trailer
    common.need(trailer is not None and trailer.text == END_TRAILER
                and common.attr(trailer.attrs, "colon", where) == "1"
                and len(trailer.children) == 1
                and common.atom_text(trailer.children[0], where) == name,
                f"{where}: definition {name!r} must close with `end: {name.decode('ascii', 'backslashreplace')}`")


def model_field(item: common.P0Node, where: str) -> ModelField:
    common.need(item.tag == "frame" and item.text is not None
                and common.attr(item.attrs, "colon", where) == "1",
                f"{where}: unsupported model field form {item.tag}")
    assert item.text is not None
    if item.trailer is not None:
        closing(item, item.text, where)
        return ModelField(item.text, frame=item)
    # A typed leaf: the head chain is the requirement, then the name.
    node = item
    while (len(node.children) == 1 and node.children[0].tag == "frame"
           and node.children[0].trailer is None):
        node = node.children[0]
    common.need(bool(node.children) and node.children[0].tag == "atom",
                f"{where}: field name is not derivable in this slice")
    return ModelField(identifier(node.children[0], where))


def model_of(frame: common.P0Node, where: str) -> Model:
    assert frame.text is not None
    fields = tuple(model_field(item, f"{where}.{frame.text.decode('ascii', 'backslashreplace')}[{k}]")
                   for k, item in enumerate(frame.children))
    names = [field.name for field in fields]
    common.need(len(names) == len(set(names)),
                f"{where}: definition {frame.text!r} repeats a field name; selection would be ambiguous")
    return Model(frame.text, fields)


def field_model(root: common.P0Node, field: ModelField, where: str) -> Model:
    if field.frame is not None:
        return model_of(field.frame, where)
    common.need(field.definition_name is not None,
                f"{where}: a selector after {field.name!r} is unsupported: "
                "that field has no P0 model")
    assert field.definition_name is not None
    return model_of(definition_frame(root, field.definition_name, where), where)


def letter_model(payload_definition: bytes) -> Model:
    return Model(LETTER_MODEL_NAME, (
        ModelField(LETTER_SENDER),
        ModelField(LETTER_PAYLOAD, definition_name=payload_definition),
    ))


def resolve_ref(root: common.P0Node, path: RefPath, where: str) -> ResolvedRef:
    declaring: list[tuple[int, common.P0Node]] = []
    for index, child in enumerate(root.children):
        if (child.tag == "frame" and child.text == RECEIVE_HEAD and child.children
                and child.children[0].tag == "atom" and child.children[0].text == path.base):
            declaring.append((index, child))
    common.need(len(declaring) == 1,
                f"{where}: base {path.base!r} must be declared by exactly one root-level "
                f"{RECEIVE_HEAD.decode('ascii')}; found {len(declaring)}")
    index, frame = declaring[0]
    place = f"{where} declared at P0 root[{index}]"
    common.need(common.attr(frame.attrs, "colon", place) == "1" and frame.trailer is None,
                f"{place}: unsupported declaration form")
    common.need(len(frame.children) == 2 and frame.children[1].tag == "atom",
                f"{place}: only the two-name `receiveMessage: base Model` form has a "
                "physical witness in this slice")
    model: Model | None = letter_model(identifier(frame.children[1], place))
    coordinates: list[int] = []
    models: list[bytes] = []
    for k, selector in enumerate(path.selectors):
        step = f"{where}.selector[{k}]"
        assert model is not None
        coordinate, field = model.select(selector, step)
        coordinates.append(coordinate)
        models.append(model.name)
        model = field_model(root, field, step) if k + 1 < len(path.selectors) else None
    return ResolvedRef(path, index, RECEIVE_HEAD, tuple(coordinates), tuple(models))


def source_send(root: common.P0Node) -> SourceSend:
    common.need(root.tag == "structure", "P0: root is not a Structure")
    matches = [index for index, child in enumerate(root.children)
               if child.tag == "frame" and child.text == b"sendMessage"]
    common.need(len(matches) == 1,
                f"P0: expected one root-level sendMessage, got {len(matches)}")
    index = matches[0]
    send = root.children[index]
    where = f"P0 root[{index}]"
    common.need(common.attr(send.attrs, "colon", where) == "1"
                and send.trailer is None and len(send.children) >= 1,
                f"{where}: expected sendMessage Frame with an exit child and no trailer")
    ref: ResolvedRef | None = None
    if len(send.children) > 1:
        ref = resolve_ref(root, source_ref(send.children[:-1], where), f"{where}.ref")
    exit_frame = send.children[-1]
    where += ".exit"
    common.need(exit_frame.tag == "frame" and exit_frame.text == b"exit"
                and common.attr(exit_frame.attrs, "colon", where) in {"0", "1"}
                and exit_frame.trailer is None and len(exit_frame.children) == 3,
                f"{where}: expected an exit Frame with exactly three fields")
    fields: list[SourceField] = []
    seen: set[bytes] = set()
    for field_index, frame in enumerate(exit_frame.children):
        place = f"{where}.field[{field_index}]"
        common.need(frame.tag == "frame" and frame.text is not None
                    and common.attr(frame.attrs, "colon", place) == "1"
                    and frame.trailer is None and len(frame.children) == 1,
                    f"{place}: expected a one-value field Frame")
        name = frame.text
        common.need(name in {b"exit_code", b"stdout", b"stderr"} and name not in seen,
                    f"{place}: unexpected or repeated field {name!r}")
        seen.add(name)
        if name == b"exit_code":
            fields.append(SourceField(name, integer=common.int_atom(frame.children[0], place)))
        else:
            fields.append(SourceField(name, text=plain_string(frame.children[0], place)))
    common.need(seen == {b"exit_code", b"stdout", b"stderr"},
                "P0 exit: missing required field")
    return SourceSend(index, ref, tuple(fields))


def graph_name(value: str, expected: bytes | None, where: str) -> None:
    actual = common.decode_graph_name(value, where)
    common.need(actual == expected,
                f"{where}: name {actual!r}, expected {expected!r}")


def owned_node(slot: common.GraphSlot, parent: common.GraphNode,
               where: str) -> common.GraphNode:
    child = slot.child
    common.need(child is not None, f"{where}: expected one owned child")
    assert child is not None
    common.need(common.attr(slot.attrs, "value", where) == common.attr(child.attrs, "node", where),
                f"{where}: owned slot does not point at its child")
    common.need(common.attr(child.attrs, "parent", where) == common.attr(parent.attrs, "node", where),
                f"{where}: wrong physical parent")
    return child


def plain_child(slot: common.GraphSlot, parent: common.GraphNode,
                where: str, width: int) -> common.GraphNode:
    common.require_slot(slot, where, kind=6, ty=13, op=-1, role=-1, owned=1)
    graph_name(common.attr(slot.attrs, "value_name", where), None, where)
    child = owned_node(slot, parent, where)
    graph_name(common.attr(child.attrs, "name", where), None, where)
    common.need(len(child.slots) == width,
                f"{where}: physical width {len(child.slots)}, expected {width}")
    return child


def op_node(slot: common.GraphSlot, parent: common.GraphNode, where: str,
            *, op: int, name: bytes | None, width: int) -> common.GraphNode:
    common.require_slot(slot, where, kind=6, ty=13, op=op, role=0, owned=1)
    graph_name(common.attr(slot.attrs, "value_name", where), name, where)
    child = owned_node(slot, parent, where)
    graph_name(common.attr(child.attrs, "name", where), name, where)
    common.need(len(child.slots) == width,
                f"{where}: physical width {len(child.slots)}, expected {width}")
    common.require_slot(child.slots[0], f"{where}.op", kind=17, ty=31,
                        op=op, role=-1, owned=0)
    return child


def root_occurrence(graph: common.GraphNode, head: bytes, label: str,
                    *, op: int | None) -> tuple[int, common.GraphSlot]:
    """The unique owned root occurrence carrying this written head.
    Count by name before validating its operator: another operator with
    the same head is not an ignorable second occurrence."""
    matches = [index for index, slot in enumerate(graph.slots)
               if common.decode_graph_name(slot.attrs.get("value_name", "-"),
                                            f"{label} root[{index}]") == head]
    spelled = head.decode("ascii", "backslashreplace")
    common.need(len(matches) == 1,
                f"{label}: expected one physical root {spelled} occurrence, got {len(matches)}")
    slot = graph.slots[matches[0]]
    where = f"{label} root[{matches[0]}] {spelled}"
    for key, wanted in (("kind", "6"), ("type", "13"), ("owned", "1")):
        common.need(common.attr(slot.attrs, key, where) == wanted,
                    f"{where}: {key}={slot.attrs[key]}, expected {wanted}")
    if op is not None:
        common.need(common.attr(slot.attrs, "op", where) == str(op),
                    f"{where}: op={slot.attrs['op']}, expected {op}")
    common.need(slot.child is not None, f"{where}: expected an owned occurrence")
    return matches[0], slot


def target_cell_name(occurrence: common.GraphNode, where: str) -> bytes | None:
    """Only SET operand 1 is the receive target. A same-name OWN in its
    value/body or another descendant does not declare the Ref base."""
    if len(occurrence.slots) < 2:
        return None
    target = occurrence.slots[1].child
    if target is None or len(target.slots) < 2:
        return None
    return common.decode_graph_name(target.slots[1].attrs.get("cell_name", "-"),
                                    f"{where}.target.cell")


def declaration_cell(occurrence: common.GraphNode, base: bytes, where: str) -> common.GraphNode:
    """The direct SET target OWN cell is the Ref base's physical identity."""
    common.need(len(occurrence.slots) >= 2,
                f"{where}: receive SET has no target operand")
    slot = occurrence.slots[1]
    common.require_slot(slot, f"{where}.own", kind=6, ty=13, op=OWN, role=0, owned=1)
    node = owned_node(slot, occurrence, f"{where}.own")
    common.need(len(node.slots) == 2,
                f"{where}.own: physical width {len(node.slots)}, expected 2")
    common.require_slot(node.slots[0], f"{where}.own.op", kind=17, ty=31,
                        op=OWN, role=-1, owned=0)
    cell = node.slots[1]
    common.require_slot(cell, f"{where}.own.cell", kind=0, ty=0,
                        op=-1, role=-1, owned=0)
    graph_name(common.attr(cell.attrs, "cell_name", where), base, f"{where}.own.cell")
    common.need(cell.child is None,
                f"{where}.own.cell: the declared cell must not own a node")
    return node


def declaring_occurrence(graph: common.GraphNode, base: bytes,
                         label: str) -> tuple[int, common.GraphNode]:
    """Locate a receive declaration by its P0 base, not by a globally
    unique receiveMessage head: unrelated receives are outside this slice."""
    matches: list[tuple[int, common.GraphSlot]] = []
    for index, slot in enumerate(graph.slots):
        where = f"{label} root[{index}]"
        if common.decode_graph_name(slot.attrs.get("value_name", "-"), where) != RECEIVE_HEAD:
            continue
        if slot.child is not None and target_cell_name(slot.child, where) == base:
            matches.append((index, slot))
    common.need(len(matches) == 1,
                f"{label}: expected one physical root receiveMessage declaration of "
                f"{base!r}, got {len(matches)}")
    index, slot = matches[0]
    where = f"{label} root[{index}] receiveMessage"
    common.require_slot(slot, where, kind=6, ty=13, op=SET, role=1, owned=1)
    graph_name(common.attr(slot.attrs, "value_name", where), RECEIVE_HEAD, where)
    child = owned_node(slot, graph, where)
    graph_name(common.attr(child.attrs, "name", where), RECEIVE_HEAD, where)
    common.need(bool(child.slots), f"{where}: receive SET has no operation record")
    common.require_slot(child.slots[0], f"{where}.op", kind=17, ty=31,
                        op=SET, role=-1, owned=0)
    return index, child


def path_node(slot: common.GraphSlot, parent: common.GraphNode, resolved: ResolvedRef,
              k: int, declaration: common.GraphNode, where: str) -> common.GraphNode:
    """The OF node standing for selector k: width 3 (OF record, base,
    SIZE_T coordinate). Its base owns the node of selector k-1, or for the
    first selector borrows the declaration cell's OWN node."""
    selector = resolved.path.selectors[k]
    node = op_node(slot, parent, where, op=OF, name=None, width=3)
    base = node.slots[1]
    if k > 0:
        path_node(base, node, resolved, k - 1, declaration, f"{where}.base")
    else:
        common.require_slot(base, f"{where}.base", kind=6, ty=13, op=OWN, role=0, owned=0)
        graph_name(common.attr(base.attrs, "value_name", where), None, f"{where}.base")
        common.need(common.attr(base.attrs, "value", where) == common.attr(declaration.attrs, "node", where),
                    f"{where}.base: does not alias the declaration cell of {resolved.path.base!r}")
    coordinate = node.slots[2]
    common.require_slot(coordinate, f"{where}.coordinate", kind=1, ty=3,
                        op=-1, role=-1, owned=0)
    common.need(common.attr(coordinate.attrs, "value", where) != NULL_ADDRESS,
                f"{where}.coordinate: null SIZE_T coordinate")
    actual = common.number(common.attr(coordinate.attrs, "size", where), where)
    common.need(actual == resolved.coordinates[k],
                f"{where}.coordinate: selector coordinate {actual}, expected "
                f"{resolved.coordinates[k]} ({selector!r} in model {resolved.models[k]!r})")
    return node


def ref_alias(slot: common.GraphSlot, source_slot: common.GraphSlot,
              node: common.GraphNode, op: int, where: str) -> None:
    common.require_slot(slot, where, kind=6, ty=13, op=op, role=0, owned=0)
    common.need(common.attr(slot.attrs, "value", where) == common.attr(node.attrs, "node", where),
                f"{where}: does not alias the source-owned Ref node")
    common.need(common.attr(slot.attrs, "value_name", where)
                == common.attr(source_slot.attrs, "value_name", where),
                f"{where}: alias spelling differs from its source-owned Ref node")


def char_array(slot: common.GraphSlot, where: str, expected: bytes) -> None:
    common.require_slot(slot, where, kind=3, ty=5, op=-1, role=-1, owned=0)
    graph_name(common.attr(slot.attrs, "value_name", where), None, where)
    common.need(common.attr(slot.attrs, "value", where) != NULL_ADDRESS,
                f"{where}: null Array<Char> descriptor")
    encoded = common.attr(slot.attrs, "array", where)
    size, marker, hex_bytes = encoded.partition(":")
    common.need(bool(marker) and size.isdecimal() and len(hex_bytes) == 2 * int(size),
                f"{where}: malformed Array<Char> dump")
    try:
        actual = bytes.fromhex(hex_bytes)
    except ValueError as exc:
        raise common.CompareError(f"{where}: non-hex Array<Char> data") from exc
    common.need(actual == expected,
                f"{where}: Array<Char> bytes {actual!r}, expected {expected!r}")


def verify_field(slot: common.GraphSlot, parent: common.GraphNode,
                 source: SourceField, index: int, where: str) -> common.GraphNode:
    field = op_node(slot, parent, where, op=NAMED, name=source.name, width=3)
    coordinate = field.slots[1]
    common.require_slot(coordinate, f"{where}.coordinate", kind=1, ty=3,
                        op=-1, role=-1, owned=0)
    common.need(common.number(common.attr(coordinate.attrs, "size", where), where) == index,
                f"{where}: NAMED coordinate is not source field index {index}")
    common.need(common.attr(coordinate.attrs, "value", where) != NULL_ADDRESS,
                f"{where}: null NAMED coordinate")
    payload = field.slots[2]
    if source.integer is not None:
        common.literal(payload, f"{where}.payload", source.integer,
                       common.PrimitiveStorageWitness())
    else:
        assert source.text is not None
        char_array(payload, f"{where}.payload", source.text)
    return field


def verify_send(graph: common.GraphNode, source: SourceSend, label: str) -> None:
    # A declaration can materialize both a storage slot and an operation,
    # shifting later physical indexes. Match this one source occurrence by
    # its unique retained root head, then verify its entire subtree and aliases.
    fields = source.fields
    has_ref = source.has_ref
    physical_index, send_slot = root_occurrence(graph, b"sendMessage", label, op=PRIM_PUB)
    where = f"{label} root[{physical_index}] for P0 root[{source.index}]"
    send = op_node(send_slot, graph, where,
                   op=PRIM_PUB, name=b"sendMessage", width=3 + len(fields) + has_ref)
    record = send.slots[1]
    common.require_slot(record, f"{where}.record", kind=20, ty=34,
                        op=-1, role=-1, owned=0)
    common.need(common.attr(record.attrs, "value", where) != NULL_ADDRESS,
                f"{where}: null primitive record")
    # The one source body, in written order: [Ref,] exit.
    body = plain_child(send.slots[2], send, f"{where}.body", 1 + has_ref)
    ref: common.GraphNode | None = None
    if source.ref is not None:
        ref_slot = body.slots[0]
        ref_where = f"{where}.body.ref"
        op = common.number(common.attr(ref_slot.attrs, "op", ref_where), ref_where)
        common.need(op not in (SOURCE_INERT, NAMED, PRIM_PUB),
                    f"{ref_where}: source order: expected the Ref expression node, got op={op}")
        # The base's physical identity: the OWN cell its own declaration owns.
        declaration_index, declaration_occ = declaring_occurrence(
            graph, source.ref.path.base, label)
        declaration = declaration_cell(
            declaration_occ, source.ref.path.base,
            f"{label} root[{declaration_index}] for P0 root[{source.ref.declaration_index}]")
        ref = path_node(ref_slot, body, source.ref, len(source.ref.path.selectors) - 1,
                        declaration, ref_where)
    exit_frame = op_node(body.slots[has_ref], body, f"{where}.body.exit",
                         op=SOURCE_INERT, name=b"exit", width=2)
    field_body = plain_child(exit_frame.slots[1], exit_frame,
                             f"{where}.body.exit.body", len(fields))
    for index, field_source in enumerate(fields):
        place = f"{where}.body.exit.body[{index}]"
        field = verify_field(field_body.slots[index], field_body, field_source, index, place)
        alias = send.slots[3 + index]
        common.require_slot(alias, f"{where}.actual[{index}]",
                            kind=6, ty=13, op=NAMED, role=0, owned=0)
        graph_name(common.attr(alias.attrs, "value_name", place), field_source.name,
                   f"{where}.actual[{index}]")
        common.need(common.attr(alias.attrs, "value", place)
                    == common.attr(field.attrs, "node", place),
                    f"{where}.actual[{index}]: does not alias its source-owned NAMED field")
    if ref is not None:
        # The Ref actual is the last operand and the same physical node.
        ref_alias(send.slots[3 + len(fields)], body.slots[0], ref, OF,
                  f"{where}.actual[{len(fields)}]")


def compare(root: common.P0Node, graphs: list[common.GraphNode]) -> SourceSend:
    source = source_send(root)
    common.need(len(graphs) == 2, "graph: expected native and walker blocks")
    for label, graph in zip(("native", "walker"), graphs):
        verify_send(graph, source, label)
    common.need(common.canonical_graph(graphs[0]) == common.canonical_graph(graphs[1]),
                "native and walker complete physical graph trees differ")
    return source


def describe_ref(ref: ResolvedRef | None) -> str:
    if ref is None:
        return "ref=none"
    spelled = ref.path.spelling.decode("ascii", "backslashreplace")
    steps = ", ".join(
        f"{selector.decode('ascii', 'backslashreplace')}->{coordinate} in {model.decode('ascii', 'backslashreplace')}"
        for selector, coordinate, model in zip(ref.path.selectors, ref.coordinates, ref.models))
    return (f"ref={spelled} (base {ref.path.base.decode('ascii', 'backslashreplace')} = the OWN cell "
            f"declared by P0 root[{ref.declaration_index}] "
            f"{ref.declaration_head.decode('ascii')}, borrowed; selectors {steps}; "
            f"OF chain depth {len(ref.coordinates)} owned at body[0], borrowed by the last actual)")


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {Path(sys.argv[0]).name} P0_EVENTS GRAPH_EVENTS", file=sys.stderr)
        return 2
    try:
        source = common.parse_p0(Path(sys.argv[1]))
        graphs = common.parse_graph(Path(sys.argv[2]))
        send = compare(source, graphs)
    except (common.CompareError, OSError, UnicodeError) as exc:
        print(f"G1 send-source comparison FAILED: {exc}", file=sys.stderr)
        return 1
    order = ",".join(field.name.decode("ascii") for field in send.fields)
    unchecked = [i for i in range(len(source.children)) if i != send.index]
    note = ""
    if send.ref is not None:
        note = (f"; declaration root[{send.ref.declaration_index}] used for the base "
                "cell identity only")
    print(f"G1 send-source comparison PARTIAL OK: P0 root[{send.index}] "
          f"sendMessage→exit fields={order} {describe_ref(send.ref)} "
          f"native/walker=2; "
          f"unchecked P0 root fields={unchecked}{note}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
