#!/usr/bin/env python3
"""Synthetic positive and equal-exit mutants for the bounded G1 send oracle.

No translator, kernel, or project build is needed. The oracle itself reads
real P0/graph events when the harness later invokes its CLI; one optional
class below replays recorded evidence when its files exist and is skipped
otherwise.

The synthetic Ref graphs copy the physical layout read from the native and
walker dumps of `unit_receive_letter_model_root` (`m\\sender`) and from the
`length(m\\payload\\mainArgs)` operand of the same program: one OF node per
selector (OF record, base, SIZE_T coordinate), the outer node owning the
inner one, the innermost base borrowing the OWN node whose second slot is
the cell named by the base's root-level receiveMessage declaration.
"""

from __future__ import annotations

import copy
import os
from pathlib import Path
import unittest

import graph_method_order_compare as common
import graph_send_source_compare as send_oracle


OF = send_oracle.OF
OWN = send_oracle.OWN
SET = 8
SEPARATOR = send_oracle.PATH_SEPARATOR


def encoded(name: bytes | None) -> str:
    return "-" if name is None else f"{len(name)}:{name.hex()}"


def atom(text: bytes) -> common.P0Node:
    return common.P0Node("atom", {}, text)


def frame(name: bytes, children: list[common.P0Node], *, colon: str = "1",
          trailer: common.P0Node | None = None) -> common.P0Node:
    return common.P0Node("frame", {"colon": colon}, name, children, trailer)


def end_trailer(name: bytes) -> common.P0Node:
    return common.P0Node("trailer", {"colon": "1", "of": "frame"}, b"end", [atom(name)])


def path_atoms(spelling: bytes) -> list[common.P0Node]:
    """`m\\sender` as P0 writes it: sibling atoms with `\\` atoms between."""
    nodes: list[common.P0Node] = []
    for k, name in enumerate(spelling.split(SEPARATOR)):
        if k:
            nodes.append(atom(SEPARATOR))
        nodes.append(atom(name))
    return nodes


def model_definition() -> common.P0Node:
    # MainLetter:
    #     char: []: []: mainArgs
    # end: MainLetter
    leaf = frame(b"char", [frame(b"[]", [frame(b"[]", [atom(b"mainArgs")])])])
    return frame(b"MainLetter", [leaf], trailer=end_trailer(b"MainLetter"))


def source_root(*, ref: bytes | None = None, model: bool = False,
                receive: tuple[bytes, ...] | None = (b"m", b"MainLetter")) -> common.P0Node:
    """Root: [definition or task, receiveMessage or task, sendMessage, return].
    The send stays at ROOT_INDEX in every variant."""
    exit_frame = frame(b"exit", [
        frame(b"exit_code", [atom(b"7")]),
        frame(b"stdout", [atom(b'""')]),
        frame(b"stderr", [atom(b'""')]),
    ], colon="0")
    send_children: list[common.P0Node] = []
    if ref is not None:
        send_children += path_atoms(ref)
    send_children.append(exit_frame)
    children: list[common.P0Node] = [model_definition() if model else atom(b"task")]
    if ref is not None and receive is not None:
        children.append(frame(b"receiveMessage", [atom(name) for name in receive]))
    else:
        children.append(atom(b"task"))
    children.append(frame(b"sendMessage", send_children))
    children.append(atom(b"return"))
    return common.P0Node("structure", {}, children=children)


class GraphMaker:
    def __init__(self, base: int) -> None:
        self.next_address = base

    def address(self) -> str:
        self.next_address += 1
        return f"{self.next_address:016x}"

    def node(self, name: bytes | None = None) -> common.GraphNode:
        return common.GraphNode({
            "node": self.address(), "parent": send_oracle.NULL_ADDRESS,
            "name": encoded(name), "width": "0",
        })

    def slot(self, parent: common.GraphNode, *, child: common.GraphNode | None = None,
             kind: int, ty: int, op: int = -1, role: int = -1,
             name: bytes | None = None, value: str | None = None,
             **extra: str) -> common.GraphSlot:
        if child is not None:
            child.attrs["parent"] = parent.attrs["node"]
            value = child.attrs["node"]
        if value is None:
            value = self.address() if kind != 0 else send_oracle.NULL_ADDRESS
        attrs = {
            "value": value, "kind": str(kind), "type": str(ty),
            "op": str(op), "role": str(role), "owned": "1" if child is not None else "0",
            "cell_name": "-", "value_name": encoded(name),
        }
        attrs.update(extra)
        result = common.GraphSlot(attrs, child)
        parent.slots.append(result)
        parent.attrs["width"] = str(len(parent.slots))
        return result

    def operation(self, parent: common.GraphNode, code: int,
                  name: bytes | None, *, role: int = 0) -> common.GraphNode:
        node = self.node(name)
        self.slot(parent, child=node, kind=6, ty=13, op=code, role=role, name=name)
        self.slot(node, kind=17, ty=31, op=code)
        return node

    def plain(self, parent: common.GraphNode) -> common.GraphNode:
        node = self.node()
        self.slot(parent, child=node, kind=6, ty=13)
        return node

    def own_cell(self, holder: common.GraphNode, cell: bytes) -> common.GraphNode:
        """An OWN node whose second slot is the (still empty) cell named `cell`."""
        own = self.node()
        self.slot(holder, child=own, kind=6, ty=13, op=OWN, role=0)
        self.slot(own, kind=17, ty=31, op=OWN)
        self.slot(own, kind=0, ty=0, cell_name=encoded(cell))
        return own

    def declaration(self, root: common.GraphNode, head: bytes, cell: bytes,
                    *, decoy: bytes | None = None) -> common.GraphNode:
        """The root occurrence of `receiveMessage: cell Model`: a SET whose
        target is the OWN cell. Only the cell identity matters to the oracle;
        an optional decoy cell with another name sits beside it."""
        occurrence = self.operation(root, SET, head, role=1)
        own = self.own_cell(occurrence, cell)
        if decoy is not None:
            self.own_cell(occurrence, decoy)
        return own

    def path_chain(self, parent: common.GraphNode, own: common.GraphNode,
                   coordinates: tuple[int, ...]) -> common.GraphNode:
        """OF nodes from the last selector inward; the first selector's base
        borrows the declaration's OWN node."""
        node = self.operation(parent, OF, None)
        if len(coordinates) > 1:
            self.path_chain(node, own, coordinates[:-1])
        else:
            self.slot(node, kind=6, ty=13, op=OWN, role=0, value=own.attrs["node"])
        self.slot(node, kind=1, ty=3, size=str(coordinates[-1]))
        return node


def graph_root(base: int, *, ref: tuple[int, ...] | None = None,
               declared: bytes = b"m", head: bytes = b"receiveMessage",
               decoy: bytes | None = None) -> common.GraphNode:
    make = GraphMaker(base)
    root = make.node()
    make.slot(root, kind=0, ty=0)
    own: common.GraphNode | None = None
    if ref is not None:
        own = make.declaration(root, head, declared, decoy=decoy)
    else:
        make.slot(root, kind=0, ty=0)
    send = make.operation(root, send_oracle.PRIM_PUB, b"sendMessage")
    make.slot(send, kind=20, ty=34)
    body = make.plain(send)
    ref_node = None
    if ref is not None:
        assert own is not None
        # The written Ref expression at its written place: owned by the
        # source body, before the message.
        ref_node = make.path_chain(body, own, ref)
    exit_frame = make.operation(body, send_oracle.SOURCE_INERT, b"exit")
    fields_body = make.plain(exit_frame)
    fields: list[common.GraphNode] = []
    for index, name in enumerate((b"exit_code", b"stdout", b"stderr")):
        field = make.operation(fields_body, send_oracle.NAMED, name)
        make.slot(field, kind=1, ty=3, size=str(index))
        if name == b"exit_code":
            literal = make.operation(field, 3, b"")
            # A literal's operator node has no source name.
            field.slots[2].attrs["value_name"] = "-"
            literal.attrs["name"] = "-"
            make.slot(literal, kind=1, ty=2, int="7")
        else:
            make.slot(field, kind=3, ty=5, array="0:")
        fields.append(field)
    for name, field in zip((b"exit_code", b"stdout", b"stderr"), fields):
        make.slot(send, kind=6, ty=13, op=send_oracle.NAMED,
                  role=0, name=name, value=field.attrs["node"])
    if ref_node is not None:
        # The last actual borrows the source-owned Ref node.
        make.slot(send, kind=6, ty=13, op=OF, role=0, value=ref_node.attrs["node"])
    make.slot(root, kind=0, ty=0)
    return root


def send_and_body(graph: common.GraphNode) -> tuple[common.GraphNode, common.GraphNode]:
    send = graph.slots[send_oracle.ROOT_INDEX].child
    assert send is not None
    body = send.slots[2].child
    assert body is not None
    return send, body


def ref_node(graph: common.GraphNode) -> common.GraphNode:
    _, body = send_and_body(graph)
    node = body.slots[0].child
    assert node is not None
    return node


def declaration_occurrence(graph: common.GraphNode) -> common.GraphNode:
    occurrence = graph.slots[1].child
    assert occurrence is not None
    return occurrence


def own_node(graph: common.GraphNode, index: int = 1) -> common.GraphNode:
    node = declaration_occurrence(graph).slots[index].child
    assert node is not None
    return node


def exit_value(graph: common.GraphNode) -> str:
    _, body = send_and_body(graph)
    exit_frame = body.slots[-1].child
    assert exit_frame is not None
    fields = exit_frame.slots[1].child
    assert fields is not None
    field = fields.slots[0].child
    assert field is not None
    literal = field.slots[2].child
    assert literal is not None
    return literal.slots[1].attrs["int"]


class SendSourceComparatorTest(unittest.TestCase):
    def setUp(self) -> None:
        self.source = source_root()
        self.graphs = [graph_root(0x1000), graph_root(0x2000)]

    def fields_body(self, graph: common.GraphNode) -> common.GraphNode:
        send = graph.slots[send_oracle.ROOT_INDEX].child
        assert send is not None
        body = send.slots[2].child
        assert body is not None
        exit_frame = body.slots[0].child
        assert exit_frame is not None
        fields = exit_frame.slots[1].child
        assert fields is not None
        return fields

    def test_positive_one_owned_tree_two_borrowing_graphs(self) -> None:
        send = send_oracle.compare(self.source, self.graphs)
        self.assertEqual(tuple(field.name for field in send.fields),
                         (b"exit_code", b"stdout", b"stderr"))
        self.assertIsNone(send.ref)
        self.assertEqual(send.index, send_oracle.ROOT_INDEX)

    def test_unchecked_storage_before_send_can_shift_physical_index(self) -> None:
        for graph in self.graphs:
            graph.slots.insert(0, copy.deepcopy(graph.slots[0]))
        send = send_oracle.compare(self.source, self.graphs)
        self.assertEqual(len(send.fields), 3)

    def test_ambiguous_physical_root_send_is_rejected(self) -> None:
        for graph in self.graphs:
            graph.slots.append(copy.deepcopy(graph.slots[send_oracle.ROOT_INDEX]))
        with self.assertRaisesRegex(common.CompareError, "expected one physical root sendMessage"):
            send_oracle.compare(self.source, self.graphs)

    def test_same_head_with_other_op_is_not_ignored(self) -> None:
        for graph in self.graphs:
            other = copy.deepcopy(graph.slots[send_oracle.ROOT_INDEX])
            other.attrs["op"] = str(SET)
            graph.slots.append(other)
        with self.assertRaisesRegex(common.CompareError, "expected one physical root sendMessage"):
            send_oracle.compare(self.source, self.graphs)

    def test_drop_stderr_detected_with_exit_still_seven(self) -> None:
        for graph in self.graphs:
            self.fields_body(graph).slots.pop(2)
        self.assertEqual(self.source.children[2].children[0].children[0].children[0].text, b"7")
        self.assertEqual(common.canonical_graph(self.graphs[0]),
                         common.canonical_graph(self.graphs[1]))
        with self.assertRaisesRegex(common.CompareError, "physical width"):
            send_oracle.compare(self.source, self.graphs)

    def test_swap_equal_value_text_fields_detected(self) -> None:
        for graph in self.graphs:
            body = self.fields_body(graph)
            body.slots[1], body.slots[2] = body.slots[2], body.slots[1]
        self.assertEqual(common.canonical_graph(self.graphs[0]),
                         common.canonical_graph(self.graphs[1]))
        with self.assertRaisesRegex(common.CompareError, "name .*expected"):
            send_oracle.compare(self.source, self.graphs)

    def test_rename_stdout_detected_at_its_source_occurrence(self) -> None:
        for graph in self.graphs:
            field = self.fields_body(graph).slots[1]
            field.attrs["value_name"] = encoded(b"stdouX")
            assert field.child is not None
            field.child.attrs["name"] = encoded(b"stdouX")
            send = graph.slots[send_oracle.ROOT_INDEX].child
            assert send is not None
            send.slots[4].attrs["value_name"] = encoded(b"stdouX")
        self.assertEqual(common.canonical_graph(self.graphs[0]),
                         common.canonical_graph(self.graphs[1]))
        with self.assertRaisesRegex(common.CompareError, "name .*expected"):
            send_oracle.compare(self.source, self.graphs)

    def test_equal_value_alias_to_wrong_field_detected(self) -> None:
        for graph in self.graphs:
            send = graph.slots[send_oracle.ROOT_INDEX].child
            assert send is not None
            # stdout/stderr both contain Array<Char> 0:, so exit_code remains 7.
            send.slots[4].attrs["value"] = send.slots[5].attrs["value"]
        self.assertEqual(common.canonical_graph(self.graphs[0]),
                         common.canonical_graph(self.graphs[1]))
        with self.assertRaisesRegex(common.CompareError, "does not alias"):
            send_oracle.compare(self.source, self.graphs)

    def test_text_bytes_are_derived_from_p0_and_checked(self) -> None:
        self.source.children[2].children[0].children[1].children[0].text = b'"ab"'
        for graph in self.graphs:
            field = self.fields_body(graph).slots[1].child
            assert field is not None
            field.slots[2].attrs["array"] = "2:6162"
        send_oracle.compare(self.source, self.graphs)
        for graph in self.graphs:
            field = self.fields_body(graph).slots[1].child
            assert field is not None
            field.slots[2].attrs["array"] = "2:6163"
        with self.assertRaisesRegex(common.CompareError, "Array<Char> bytes"):
            send_oracle.compare(self.source, self.graphs)

    def test_both_modes_are_checked_not_just_compared(self) -> None:
        graph = self.graphs[1]
        self.fields_body(graph).slots[1].attrs["value_name"] = encoded(b"stdouX")
        with self.assertRaisesRegex(common.CompareError, "walker .*name .*expected"):
            send_oracle.compare(self.source, self.graphs)

    def test_unsupported_source_escape_fails_closed(self) -> None:
        source = copy.deepcopy(self.source)
        source.children[2].children[0].children[1].children[0].text = b'"\\n"'
        with self.assertRaisesRegex(common.CompareError, "only unescaped"):
            send_oracle.compare(source, self.graphs)

    def test_extra_primitive_slot_is_not_ignored(self) -> None:
        for graph in self.graphs:
            send = graph.slots[send_oracle.ROOT_INDEX].child
            assert send is not None
            send.slots.append(copy.deepcopy(send.slots[-1]))
        with self.assertRaisesRegex(common.CompareError, "physical width"):
            send_oracle.compare(self.source, self.graphs)

    def test_root_send_is_located_not_assumed_at_index_two(self) -> None:
        # P0 declarations before the send shift its root index; the oracle
        # must find the unique root-level occurrence and report that index.
        self.source.children.insert(0, atom(b"task"))
        send = send_oracle.compare(self.source, self.graphs)
        self.assertEqual(send.index, 3)

    def test_two_root_level_sends_fail_closed(self) -> None:
        self.source.children.append(copy.deepcopy(self.source.children[2]))
        with self.assertRaisesRegex(common.CompareError, "expected one root-level sendMessage"):
            send_oracle.compare(self.source, self.graphs)


class SendRefSourceComparatorTest(unittest.TestCase):
    """`sendMessage: m\\sender exit(...)` after `receiveMessage: m MainLetter`:
    the Ref expression is owned by the one source body at its written place
    (before exit), the last actual borrows that very node, and the inner
    expression is one OF whose base borrows m's declaration cell and whose
    coordinate is sender's index in the letter shape."""

    def setUp(self) -> None:
        self.source = source_root(ref=b"m\\sender")
        self.graphs = [graph_root(0x1000, ref=(0,)), graph_root(0x2000, ref=(0,))]

    def assert_equal_exit_mutant(self) -> None:
        """Both modes carry the same mutation; the program's exit stays 7."""
        self.assertEqual(common.canonical_graph(self.graphs[0]),
                         common.canonical_graph(self.graphs[1]))
        for graph in self.graphs:
            self.assertEqual(exit_value(graph), "7")
            prim, body = send_and_body(graph)
            self.assertEqual(prim.slots[6].attrs["value"], body.slots[0].attrs["value"])

    def test_positive_ref_owned_first_and_borrowed_last(self) -> None:
        send = send_oracle.compare(self.source, self.graphs)
        assert send.ref is not None
        self.assertEqual(send.ref.path.spelling, b"m\\sender")
        self.assertEqual(send.ref.path.base, b"m")
        self.assertEqual(send.ref.coordinates, (0,))
        self.assertEqual(send.ref.models, (b"letter",))
        self.assertEqual(send.ref.declaration_index, 1)
        self.assertEqual(send.has_ref, 1)
        for graph in self.graphs:
            prim, body = send_and_body(graph)
            self.assertEqual(len(prim.slots), 7)
            self.assertEqual(len(body.slots), 2)
            self.assertEqual(body.slots[0].attrs["op"], str(OF))
            self.assertEqual(body.slots[1].attrs["op"], str(send_oracle.SOURCE_INERT))
            self.assertEqual(prim.slots[6].attrs["value"], body.slots[0].attrs["value"])
            self.assertEqual(ref_node(graph).slots[1].attrs["value"], own_node(graph).attrs["node"])

    def test_ref_after_exit_breaks_source_order(self) -> None:
        for graph in self.graphs:
            _, body = send_and_body(graph)
            body.slots[0], body.slots[1] = body.slots[1], body.slots[0]
        self.assertEqual(common.canonical_graph(self.graphs[0]),
                         common.canonical_graph(self.graphs[1]))
        with self.assertRaisesRegex(common.CompareError, "source order"):
            send_oracle.compare(self.source, self.graphs)

    def test_ref_actual_outside_the_source_body_is_rejected(self) -> None:
        # The old layout: the Ref expression hangs from the primitive itself,
        # the source body holds only the exit Structure.
        for graph in self.graphs:
            prim, body = send_and_body(graph)
            ref_slot = body.slots.pop(0)
            body.attrs["width"] = str(len(body.slots))
            assert ref_slot.child is not None
            ref_slot.child.attrs["parent"] = prim.attrs["node"]
            prim.slots[6] = ref_slot
            prim.attrs["width"] = str(len(prim.slots))
        with self.assertRaisesRegex(common.CompareError, "body: physical width 1, expected 2"):
            send_oracle.compare(self.source, self.graphs)

    def test_ref_actual_aliasing_another_node_is_rejected(self) -> None:
        for graph in self.graphs:
            prim, body = send_and_body(graph)
            prim.slots[6].attrs["value"] = body.slots[1].attrs["value"]
            prim.slots[6].attrs["op"] = body.slots[1].attrs["op"]
        with self.assertRaisesRegex(common.CompareError, r"actual\[3\]: op="):
            send_oracle.compare(self.source, self.graphs)
        for graph in self.graphs:
            prim, body = send_and_body(graph)
            prim.slots[6].attrs["op"] = str(OF)
        with self.assertRaisesRegex(common.CompareError, "does not alias the source-owned Ref node"):
            send_oracle.compare(self.source, self.graphs)

    def test_ref_actual_copy_instead_of_borrow_is_rejected(self) -> None:
        for graph in self.graphs:
            prim, body = send_and_body(graph)
            twin = copy.deepcopy(body.slots[0])
            assert twin.child is not None
            twin.child.attrs["node"] = "00000000deadbeef"
            twin.child.attrs["parent"] = prim.attrs["node"]
            twin.attrs["value"] = "00000000deadbeef"
            prim.slots[6] = twin
        with self.assertRaisesRegex(common.CompareError, r"actual\[3\]: owned=1, expected 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_written_ref_missing_from_graph_is_rejected(self) -> None:
        graphs = [graph_root(0x1000), graph_root(0x2000)]
        with self.assertRaisesRegex(common.CompareError, "physical width 6, expected 7"):
            send_oracle.compare(self.source, graphs)

    def test_graph_ref_without_written_ref_is_rejected(self) -> None:
        with self.assertRaisesRegex(common.CompareError, "physical width 7, expected 6"):
            send_oracle.compare(source_root(), self.graphs)

    def test_both_modes_checked_for_the_ref_alias(self) -> None:
        prim, body = send_and_body(self.graphs[1])
        prim.slots[6].attrs["value"] = send_oracle.NULL_ADDRESS
        with self.assertRaisesRegex(common.CompareError, "walker .*does not alias the source-owned Ref node"):
            send_oracle.compare(self.source, self.graphs)

    # Equal-exit mutants of the inner Ref expression. The alias and the
    # program output are untouched; only the written meaning is lost.

    def test_inner_selector_coordinate_changed_in_both_modes_is_rejected(self) -> None:
        for graph in self.graphs:
            ref_node(graph).slots[2].attrs["size"] = "1"   # sender -> payload
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError,
                                    r"body\.ref\.coordinate: selector coordinate 1, expected 0 \(b'sender' in model b'letter'\)"):
            send_oracle.compare(self.source, self.graphs)

    def test_inner_base_rebound_to_a_decoy_cell_in_both_modes_is_rejected(self) -> None:
        self.graphs = [graph_root(0x1000, ref=(0,), decoy=b"k"),
                       graph_root(0x2000, ref=(0,), decoy=b"k")]
        # A second cell beside m's does not confuse the locator.
        send_oracle.compare(self.source, self.graphs)
        for graph in self.graphs:
            ref_node(graph).slots[1].attrs["value"] = own_node(graph, 2).attrs["node"]
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError,
                                    r"body\.ref\.base: does not alias the declaration cell of b'm'"):
            send_oracle.compare(self.source, self.graphs)

    def test_inner_base_pointing_outside_any_cell_is_rejected(self) -> None:
        for graph in self.graphs:
            ref_node(graph).slots[1].attrs["value"] = "00000000deadbeef"
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError, "does not alias the declaration cell"):
            send_oracle.compare(self.source, self.graphs)

    def test_inner_op_changed_consistently_in_both_modes_is_rejected(self) -> None:
        other = 31   # OWN_OF: another path-shaped operator of width 3
        for graph in self.graphs:
            prim, body = send_and_body(graph)
            body.slots[0].attrs["op"] = str(other)
            ref_node(graph).slots[0].attrs["op"] = str(other)
            prim.slots[6].attrs["op"] = str(other)
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError, r"body\.ref: op=31, expected 15"):
            send_oracle.compare(self.source, self.graphs)

    def test_inner_base_copied_instead_of_borrowed_is_rejected(self) -> None:
        for graph in self.graphs:
            node = ref_node(graph)
            twin = copy.deepcopy(declaration_occurrence(graph).slots[1])
            assert twin.child is not None
            twin.child.attrs["node"] = "00000000deadbeef"
            twin.child.attrs["parent"] = node.attrs["node"]
            twin.attrs["value"] = "00000000deadbeef"
            node.slots[1] = twin
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError, r"body\.ref\.base: owned=1, expected 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_extra_chain_level_beyond_the_written_path_is_rejected(self) -> None:
        self.graphs = [graph_root(0x1000, ref=(1, 0)), graph_root(0x2000, ref=(1, 0))]
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError, r"body\.ref\.base: op=15, expected 4"):
            send_oracle.compare(self.source, self.graphs)

    def test_inner_node_width_change_is_rejected(self) -> None:
        for graph in self.graphs:
            node = ref_node(graph)
            node.slots.append(copy.deepcopy(node.slots[2]))
            node.attrs["width"] = str(len(node.slots))
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError, r"body\.ref: physical width 4, expected 3"):
            send_oracle.compare(self.source, self.graphs)

    def test_declaration_cell_renamed_in_both_modes_is_rejected(self) -> None:
        self.graphs = [graph_root(0x1000, ref=(0,), declared=b"k"),
                       graph_root(0x2000, ref=(0,), declared=b"k")]
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError,
                                    "expected one physical root receiveMessage declaration of b'm', got 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_declaration_cell_wrong_type_in_both_modes_is_rejected(self) -> None:
        for graph in self.graphs:
            own_node(graph).slots[1].attrs["kind"] = "1"
            own_node(graph).slots[1].attrs["type"] = "2"
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError,
                                    r"own\.cell: kind=1, expected 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_decoy_named_like_base_is_not_the_set_target(self) -> None:
        self.graphs = [graph_root(0x1000, ref=(0,), declared=b"n", decoy=b"m"),
                       graph_root(0x2000, ref=(0,), declared=b"n", decoy=b"m")]
        for graph in self.graphs:
            ref_node(graph).slots[1].attrs["value"] = own_node(graph, 2).attrs["node"]
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError,
                                    "expected one physical root receiveMessage declaration of b'm', got 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_receive_set_operation_record_changed_in_both_modes_is_rejected(self) -> None:
        for graph in self.graphs:
            declaration_occurrence(graph).slots[0].attrs["op"] = "13"
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError, r"receiveMessage\.op: op=13, expected 8"):
            send_oracle.compare(self.source, self.graphs)

    def test_declaring_occurrence_missing_from_graph_is_rejected(self) -> None:
        self.graphs = [graph_root(0x1000, ref=(0,), head=b"receiveMessagX"),
                       graph_root(0x2000, ref=(0,), head=b"receiveMessagX")]
        with self.assertRaisesRegex(common.CompareError,
                                    "expected one physical root receiveMessage declaration of b'm', got 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_unrelated_receive_does_not_hide_the_base_declaration(self) -> None:
        self.source.children.insert(2, frame(b"receiveMessage", [atom(b"n"), atom(b"MainLetter")]))
        for index, graph in enumerate(self.graphs):
            make = GraphMaker(0x3000 + index * 0x1000)
            make.declaration(graph, b"receiveMessage", b"n")
        send = send_oracle.compare(self.source, self.graphs)
        assert send.ref is not None
        self.assertEqual(send.ref.path.base, b"m")

    def test_walker_only_coordinate_change_names_the_walker(self) -> None:
        ref_node(self.graphs[1]).slots[2].attrs["size"] = "1"
        with self.assertRaisesRegex(common.CompareError, "walker .*selector coordinate 1, expected 0"):
            send_oracle.compare(self.source, self.graphs)

    # Source-side resolution: the written path is read, not assumed.

    def test_payload_selector_resolves_to_its_letter_index(self) -> None:
        # `m\payload` is a Structure, not a reference: the translator refuses
        # it as a Ref. The oracle still resolves the name generically.
        self.source = source_root(ref=b"m\\payload")
        with self.assertRaisesRegex(common.CompareError, "selector coordinate 0, expected 1"):
            send_oracle.compare(self.source, self.graphs)
        self.graphs = [graph_root(0x1000, ref=(1,)), graph_root(0x2000, ref=(1,))]
        send = send_oracle.compare(self.source, self.graphs)
        assert send.ref is not None
        self.assertEqual(send.ref.coordinates, (1,))

    def test_depth_two_path_resolves_the_payload_definition_from_p0(self) -> None:
        # Layout modeled on the length(m\payload\mainArgs) operand of the
        # recorded program; a non-reference Ref itself is refused by the
        # translator, so no Ref-position witness of depth 2 exists yet.
        self.source = source_root(ref=b"m\\payload\\mainArgs", model=True)
        self.graphs = [graph_root(0x1000, ref=(1, 0)), graph_root(0x2000, ref=(1, 0))]
        send = send_oracle.compare(self.source, self.graphs)
        assert send.ref is not None
        self.assertEqual(send.ref.coordinates, (1, 0))
        self.assertEqual(send.ref.models, (b"letter", b"MainLetter"))
        for graph in self.graphs:
            outer = ref_node(graph)
            inner = outer.slots[1].child
            assert inner is not None
            self.assertEqual(outer.slots[2].attrs["size"], "0")
            self.assertEqual(inner.slots[2].attrs["size"], "1")
            self.assertEqual(inner.slots[1].attrs["value"], own_node(graph).attrs["node"])
        for graph in self.graphs:
            outer = ref_node(graph)
            inner = outer.slots[1].child
            assert inner is not None
            outer.slots[2].attrs["size"], inner.slots[2].attrs["size"] = "1", "0"
        self.assert_equal_exit_mutant()
        with self.assertRaisesRegex(common.CompareError,
                                    r"body\.ref\.base\.coordinate: selector coordinate 0, expected 1 \(b'payload' in model b'letter'\)"):
            send_oracle.compare(self.source, self.graphs)

    def test_depth_two_inner_link_must_be_owned(self) -> None:
        self.source = source_root(ref=b"m\\payload\\mainArgs", model=True)
        self.graphs = [graph_root(0x1000, ref=(1, 0)), graph_root(0x2000, ref=(1, 0))]
        for graph in self.graphs:
            ref_node(graph).slots[1].attrs["owned"] = "0"
        with self.assertRaisesRegex(common.CompareError, r"body\.ref\.base: owned=0, expected 1"):
            send_oracle.compare(self.source, self.graphs)

    def test_depth_two_without_the_definition_fails_closed(self) -> None:
        self.source = source_root(ref=b"m\\payload\\mainArgs")
        self.graphs = [graph_root(0x1000, ref=(1, 0)), graph_root(0x2000, ref=(1, 0))]
        with self.assertRaisesRegex(common.CompareError,
                                    "expected one root-level definition b'MainLetter' closed by an end trailer, found 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_selector_absent_from_the_letter_shape_is_rejected(self) -> None:
        self.source = source_root(ref=b"m\\nope")
        with self.assertRaisesRegex(common.CompareError,
                                    r"b'nope' is not a field of model b'letter' \(fields \['sender', 'payload'\]\)"):
            send_oracle.compare(self.source, self.graphs)

    def test_selector_after_sender_is_unsupported(self) -> None:
        self.source = source_root(ref=b"m\\sender\\x")
        with self.assertRaisesRegex(common.CompareError, "a selector after b'sender' is unsupported"):
            send_oracle.compare(self.source, self.graphs)

    def test_base_not_declared_by_a_root_receive_is_rejected(self) -> None:
        self.source = source_root(ref=b"m\\sender", receive=None)
        with self.assertRaisesRegex(common.CompareError,
                                    "base b'm' must be declared by exactly one root-level receiveMessage; found 0"):
            send_oracle.compare(self.source, self.graphs)
        self.source = source_root(ref=b"n\\sender")
        with self.assertRaisesRegex(common.CompareError, "base b'n' must be declared"):
            send_oracle.compare(self.source, self.graphs)

    def test_two_root_declarations_of_the_base_fail_closed(self) -> None:
        self.source.children.insert(1, copy.deepcopy(self.source.children[1]))
        with self.assertRaisesRegex(common.CompareError, "found 2"):
            send_oracle.compare(self.source, self.graphs)

    def test_one_name_receive_form_is_rejected(self) -> None:
        self.source = source_root(ref=b"m\\sender", receive=(b"m",))
        with self.assertRaisesRegex(common.CompareError, "only the two-name"):
            send_oracle.compare(self.source, self.graphs)

    def test_unsupported_ref_forms_fail_closed(self) -> None:
        send = self.source.children[2]
        exit_frame = send.children[-1]
        cases: list[tuple[list[common.P0Node], str]] = [
            ([atom(b"m")], "a bare name without a selector"),
            ([atom(b"m"), atom(SEPARATOR)], "got 2 written fields"),
            ([atom(b"m"), atom(b"sender"), atom(b"x")], "expected the path separator"),
            ([atom(b"m"), atom(SEPARATOR), atom(b"7x")], "b'7x' is not an identifier"),
            ([frame(b"f", [], colon="0"), atom(SEPARATOR), atom(b"sender")],
             "expected an identifier atom, got frame"),
            ([atom(b"m"), atom(SEPARATOR), common.P0Node("structure", {}, children=[])],
             "expected an identifier atom, got structure"),
        ]
        for written, message in cases:
            with self.subTest(written=[node.text for node in written]):
                send.children = written + [exit_frame]
                with self.assertRaisesRegex(common.CompareError, message):
                    send_oracle.compare(self.source, self.graphs)


EVIDENCE = Path(os.environ.get(
    "LMX_G1_SEND_EVIDENCE",
    Path(__file__).resolve().parents[3] / "build" / "g1send_ref_owned_20261014_03" / "logs"))
EVIDENCE_P0 = EVIDENCE / "oracle.g1.unit_receive_letter_model_root.p0.events"
EVIDENCE_GRAPH = EVIDENCE / "oracle.g1.unit_receive_letter_model_root.both.graph.events"


@unittest.skipUnless(EVIDENCE_P0.is_file() and EVIDENCE_GRAPH.is_file(),
                     f"no recorded send-Ref evidence under {EVIDENCE}")
class RecordedEvidenceTest(unittest.TestCase):
    """Replay of real P0/native/walker dumps of unit_receive_letter_model_root."""

    def setUp(self) -> None:
        self.source = common.parse_p0(EVIDENCE_P0)
        self.graphs = common.parse_graph(EVIDENCE_GRAPH)

    def recorded_ref(self, graph: common.GraphNode) -> common.GraphNode:
        _, slot = send_oracle.root_occurrence(graph, b"sendMessage", "recorded",
                                              op=send_oracle.PRIM_PUB)
        assert slot.child is not None
        body = slot.child.slots[2].child
        assert body is not None
        node = body.slots[0].child
        assert node is not None
        return node

    def test_recorded_ref_fixture_decodes(self) -> None:
        send = send_oracle.compare(self.source, self.graphs)
        assert send.ref is not None
        self.assertEqual(send.ref.path.spelling, b"m\\sender")
        self.assertEqual(send.ref.coordinates, (0,))
        self.assertEqual(send.ref.declaration_index, 1)

    def test_recorded_coordinate_mutant_is_rejected(self) -> None:
        for graph in self.graphs:
            self.recorded_ref(graph).slots[2].attrs["size"] = "1"
        with self.assertRaisesRegex(common.CompareError, "selector coordinate 1, expected 0"):
            send_oracle.compare(self.source, self.graphs)

    def test_recorded_base_mutant_is_rejected(self) -> None:
        for graph in self.graphs:
            self.recorded_ref(graph).slots[1].attrs["value"] = "00000000deadbeef"
        with self.assertRaisesRegex(common.CompareError, "does not alias the declaration cell of b'm'"):
            send_oracle.compare(self.source, self.graphs)

    def test_recorded_receive_set_record_mutant_is_rejected(self) -> None:
        for graph in self.graphs:
            _, occurrence = send_oracle.declaring_occurrence(graph, b"m", "recorded")
            occurrence.slots[0].attrs["op"] = "13"
        with self.assertRaisesRegex(common.CompareError, r"receiveMessage\.op: op=13, expected 8"):
            send_oracle.compare(self.source, self.graphs)


if __name__ == "__main__":
    unittest.main()
