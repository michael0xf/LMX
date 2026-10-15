#!/usr/bin/env python3
"""Synthetic positives and fail-closed mutants for the G1 expression-place witness.

No translator, kernel or project build is needed. The synthetic P0 and graphs
reuse the send-oracle test builders; atom spans are assigned here because the
synthetic P0 nodes carry none. One optional class replays a recorded harness
build (translator dump + P0/graph events) when its files exist.
"""

from __future__ import annotations

import os
from pathlib import Path
import unittest

import graph_method_order_compare as common
import graph_expr_places_compare as oracle
import test_graph_send_source_compare as send_tests


ENTRY = 0
LITERAL_SPAN = "4:30+121:1"
REF_SPAN = "4:14+105:1"
STDOUT_SPAN = "4:41+132:2"


def source_root(*, ref: bytes | None = None, own: bool = False) -> common.P0Node:
    root = send_tests.source_root(ref=ref)
    send = root.children[2]
    exit_frame = send.children[-1]
    value = exit_frame.children[0].children[0]
    if own:
        value.text = b"ok"
    value.attrs["span"] = LITERAL_SPAN
    exit_frame.children[1].children[0].attrs["span"] = STDOUT_SPAN
    if ref is not None:
        for k, atom in enumerate(send.children[:-1]):
            atom.attrs["span"] = f"4:{14 + k}+{105 + k}:1"
    return root


def graphs(*, ref: bool = False) -> list[common.GraphNode]:
    result = [send_tests.graph_root(0x1000, ref=(0,) if ref else None),
              send_tests.graph_root(0x2000, ref=(0,) if ref else None)]
    if ref:
        # The shared send-oracle builder models the older three-slot OF.
        # This oracle checks the current five-slot pointer-cell witness.
        for graph in result:
            node = send_tests.ref_node(graph)
            for kind, ty in ((0, 0), (1, 1053)):
                node.slots.append(common.GraphSlot({
                    "value": send_tests.send_oracle.NULL_ADDRESS if kind == 0 else "0000000000000001",
                    "kind": str(kind), "type": str(ty), "op": "-1", "role": "-1",
                    "owned": "0", "cell_name": "-", "value_name": "-",
                }))
            node.attrs["width"] = str(len(node.slots))
    return result


def literal_path(ref: bool) -> str:
    # root -> PRIM_PUB (2) -> source body (2) -> exit (after the Ref when written)
    # -> fields plain (1) -> NAMED exit_code (0) -> payload LIT (2)
    return f"2/2/{1 if ref else 0}/1/0/2"


def payload_node(graph: common.GraphNode) -> common.GraphNode:
    """The exit_code payload node the synthetic primitive borrows (its LIT)."""
    _, body = send_tests.send_and_body(graph)
    exit_frame = body.slots[-1].child
    assert exit_frame is not None
    fields = exit_frame.slots[1].child
    assert fields is not None
    field = fields.slots[0].child
    assert field is not None
    node = field.slots[2].child
    assert node is not None
    return node


def record(span: str, *, count: int = 1, view: str = f"0:{ENTRY}", method: int = ENTRY,
           temp: int = 9, state: str = "bound", place: int = 5, place_method: int = ENTRY,
           path: str | None = None) -> str:
    text = f"site view={view} method={method} span={span} count={count} temp={temp} state={state}"
    if state == "bound":
        text += f" place={place} place_method={place_method} path={path}"
    return text


def dump(*records: str, entry: int = ENTRY) -> str:
    return "\n".join([f"expr-places 1 entry={entry}", *records, "end-expr-places"]) + "\n"


class IndexTest(unittest.TestCase):
    def parse(self, text: str) -> oracle.Index:
        path = Path(self.id().replace(".", "_") + ".places")
        path.write_text(text, encoding="ascii", newline="\n")
        try:
            return oracle.parse_index(path)
        finally:
            path.unlink()

    def test_bound_and_unbound_records_parse(self) -> None:
        index = self.parse(dump(record(LITERAL_SPAN, path="2/2/0/1/0/2"),
                                record(STDOUT_SPAN, state="unbound")))
        self.assertEqual(index.entry, ENTRY)
        self.assertEqual([site.state for site in index.sites], ["bound", "unbound"])
        self.assertEqual(index.sites[0].path, (2, 2, 0, 1, 0, 2))
        self.assertIsNone(index.sites[1].path)

    def test_malformed_records_fail_closed(self) -> None:
        cases = [
            ("expr-places 2 entry=0\nend-expr-places\n", "unsupported dump header"),
            (dump(record(LITERAL_SPAN, path="2/x")), "malformed path"),
            (dump(record("4:30", path="2")), "malformed span"),
            (dump(record(LITERAL_SPAN, state="lost")), "unknown state"),
            (dump("site view=0 method=0 span=- count=1 temp=1 state=unbound"), "malformed view"),
            (dump(record(LITERAL_SPAN, state="unbound") + " path=2"), "carries a place"),
            ("expr-places 1 entry=0\n" + record(LITERAL_SPAN, path="2"), "missing end-expr-places"),
        ]
        for text, message in cases:
            with self.subTest(message=message):
                with self.assertRaisesRegex(common.CompareError, message):
                    self.parse(text)

    def test_index_integrity_and_non_aliasing(self) -> None:
        good = self.parse(dump(
            record(LITERAL_SPAN, path="2/2/0/1/0/2"),
            record(LITERAL_SPAN, view="1:0", place=6, place_method=3, path="2/2/0/1/0/2"),
            record(LITERAL_SPAN, view="0:3", method=3, place=7, place_method=3, path="1/0"),
        ))
        self.assertEqual(oracle.check_index(good, True), 1)
        self.assertEqual(oracle.check_index(self.parse(dump(record(LITERAL_SPAN, path="2"))), False), 0)
        cases = [
            (dump(record(LITERAL_SPAN, path="2"), record(LITERAL_SPAN, temp=11, path="3")),
             "a second record of the site"),
            (dump(record(LITERAL_SPAN, state="pending")), "left pending"),
            (dump(record(LITERAL_SPAN, state="ambiguous")), "two constructions in view"),
            (dump(record(LITERAL_SPAN, path="2"), record(LITERAL_SPAN, view="1:0", path="2")),
             "two views share one place object"),
        ]
        for text, message in cases:
            with self.subTest(message=message):
                with self.assertRaisesRegex(common.CompareError, message):
                    oracle.check_index(self.parse(text), False)
        with self.assertRaisesRegex(common.CompareError, "no P0 run is bound in two"):
            oracle.check_index(self.parse(dump(record(LITERAL_SPAN, path="2"))), True)


class CompareTest(unittest.TestCase):
    def index(self, *records: str) -> oracle.Index:
        path = Path(self.id().replace(".", "_") + ".places")
        path.write_text(dump(*records), encoding="ascii", newline="\n")
        try:
            return oracle.parse_index(path)
        finally:
            path.unlink()

    def test_literal_site_resolves_to_the_payload_literal(self) -> None:
        index = self.index(record(LITERAL_SPAN, path=literal_path(False)),
                           record(STDOUT_SPAN, state="unbound"))
        report = oracle.compare(source_root(), graphs(), index)
        self.assertEqual((report.sites, report.bound, report.unbound, report.shared_runs), (2, 1, 1, 0))
        self.assertEqual(report.exit_site.path, (2, 2, 0, 1, 0, 2))
        self.assertIsNone(report.ref_site)

    def test_ref_site_resolves_to_the_borrowed_of_node(self) -> None:
        index = self.index(record(LITERAL_SPAN, path=literal_path(True)),
                           record(REF_SPAN, count=3, temp=4, place=2, path="2/2/0"))
        report = oracle.compare(source_root(ref=b"m\\sender"), graphs(ref=True), index)
        assert report.ref_site is not None
        self.assertEqual(report.ref_site.path, (2, 2, 0))

    def test_own_value_requires_an_own_node(self) -> None:
        index = self.index(record(LITERAL_SPAN, path=literal_path(False)))
        with self.assertRaisesRegex(common.CompareError, "expected OWN"):
            oracle.compare(source_root(own=True), graphs(), index)
        own_graphs = graphs()
        for graph in own_graphs:
            node = payload_node(graph)
            node.slots[0].attrs["op"] = str(oracle.OWN)
            node.slots.append(common.GraphSlot({"value": "0000000000000000", "kind": "0", "type": "0",
                                                "op": "-1", "role": "-1", "owned": "0",
                                                "cell_name": "-", "value_name": "-"}))
            node.attrs["width"] = "3"
        report = oracle.compare(source_root(own=True), own_graphs, index)
        self.assertEqual(report.bound, 1)

    def test_mutants_fail_closed(self) -> None:
        root = source_root(ref=b"m\\sender")
        base = [record(LITERAL_SPAN, path=literal_path(True)),
                record(REF_SPAN, count=3, temp=4, place=2, path="2/2/0")]
        cases: list[tuple[list[str], str]] = [
            ([record(LITERAL_SPAN, path="2/2/1/1/1/2"), base[1]], "is not an owned edge"),
            ([record(LITERAL_SPAN, path="2/2/1/1/0"), base[1]], "expected LIT of width 2"),
            ([record(LITERAL_SPAN, path="2/2/1/1/0/2/9"), base[1]], "beyond width"),
            ([record(LITERAL_SPAN, path="2/3"), base[1]], "is not an owned edge"),
            ([record(LITERAL_SPAN, state="unbound"), base[1]], "is unbound"),
            ([record(LITERAL_SPAN, path=literal_path(True), place_method=4), base[1]],
             "expected the entry"),
            ([record(LITERAL_SPAN, view="1:0", path=literal_path(True)), base[1]],
             "expected one root-view record"),
            ([base[0]], "ref: expected one root-view record"),
            ([base[0], record(REF_SPAN, count=3, temp=4, place=2, path="2/2/1")],
             "expected OF of width 5"),
            ([base[0], record(REF_SPAN, count=2, temp=4, place=2, path="2/2/0")],
             "ref: expected one root-view record"),
        ]
        for records, message in cases:
            with self.subTest(message=message):
                with self.assertRaisesRegex(common.CompareError, message):
                    oracle.compare(root, graphs(ref=True), self.index(*records))

    def test_graph_mutants_fail_closed(self) -> None:
        root = source_root(ref=b"m\\sender")
        index = self.index(record(LITERAL_SPAN, path=literal_path(True)),
                           record(REF_SPAN, count=3, temp=4, place=2, path="2/2/0"))
        changed = graphs(ref=True)
        self.assertEqual(send_tests.exit_value(changed[1]), "7")
        payload_node(changed[1]).slots[1].attrs["int"] = "9"
        with self.assertRaisesRegex(common.CompareError, "walker exit_code: LIT holds 9, P0 writes 7"):
            oracle.compare(root, changed, index)
        rewired = graphs(ref=True)
        send, _ = send_tests.send_and_body(rewired[0])
        send.slots[-1].attrs["value"] = "00000000deadbeef"
        with self.assertRaisesRegex(common.CompareError, "the primitive borrows 00000000deadbeef"):
            oracle.compare(root, rewired, index)
        detached = graphs(ref=True)
        _, body = send_tests.send_and_body(detached[0])
        exit_frame = body.slots[-1].child
        assert exit_frame is not None
        fields = exit_frame.slots[1].child
        assert fields is not None
        field = fields.slots[0].child
        assert field is not None
        field.slots[2].attrs["value"] = "00000000deadbeef"
        with self.assertRaisesRegex(common.CompareError, "the primitive's payload is 00000000deadbeef"):
            oracle.compare(root, detached, index)
        coordinate = graphs(ref=True)
        send_tests.ref_node(coordinate[0]).slots[2].attrs["size"] = "1"
        with self.assertRaisesRegex(common.CompareError, "selector coordinate 1, P0 resolves 0"):
            oracle.compare(root, coordinate, index)
        wrong_witness = graphs(ref=True)
        send_tests.ref_node(wrong_witness[0]).slots[4].attrs["type"] = "1054"
        with self.assertRaisesRegex(common.CompareError, "Message-reference pointer-cell witness"):
            oracle.compare(root, wrong_witness, index)

    def test_unsupported_source_forms_fail_closed(self) -> None:
        root = source_root()
        index = self.index(record(LITERAL_SPAN, path=literal_path(False)))
        send = root.children[2]
        value = send.children[-1].children[0].children[0]
        value.text = b'"7"'
        with self.assertRaisesRegex(common.CompareError, "unsupported exit_code value"):
            oracle.compare(root, graphs(), index)
        value.text = b"7"
        root.children.append(common.P0Node("frame", {"colon": "1"}, b"sendMessage", []))
        with self.assertRaisesRegex(common.CompareError, "expected one root-level sendMessage"):
            oracle.compare(root, graphs(), index)


EVIDENCE = Path(os.environ.get(
    "LMX_G1_EXPR_EVIDENCE",
    Path(__file__).resolve().parents[3] / "build" / "codex_g1_live_focus_20261014_02" / "logs"))
STEM = os.environ.get("LMX_G1_EXPR_STEM", "graph_expr_place_ref")
EVIDENCE_P0 = EVIDENCE / f"oracle.g1.{STEM}.p0.events"
EVIDENCE_GRAPH = EVIDENCE / f"oracle.g1.{STEM}.both.graph.events"
EVIDENCE_INDEX = EVIDENCE / f"oracle.g1.{STEM}.expr.places"


@unittest.skipUnless(EVIDENCE_P0.is_file() and EVIDENCE_GRAPH.is_file() and EVIDENCE_INDEX.is_file(),
                     f"no recorded expression-place evidence under {EVIDENCE}")
class RecordedEvidenceTest(unittest.TestCase):
    """Replay of a real translator dump with its P0/native/walker events."""

    def setUp(self) -> None:
        self.root = common.parse_p0(EVIDENCE_P0)
        self.graphs = common.parse_graph(EVIDENCE_GRAPH)
        self.index = oracle.parse_index(EVIDENCE_INDEX)

    def test_recorded_evidence_compares(self) -> None:
        report = oracle.compare(self.root, self.graphs, self.index)
        self.assertGreaterEqual(report.bound, 1)
        self.assertEqual(report.exit_site.place_method, self.index.entry)

    def test_recorded_literal_mutant_is_rejected(self) -> None:
        source = oracle.source_exit(self.root)
        if source.kind != "literal":
            self.skipTest("the recorded exit_code is not a literal")
        site = oracle.root_site(self.index, source.value, "exit_code")
        assert site.path is not None
        node = oracle.follow(self.graphs[0], site.path, "native")
        node.slots[1].attrs["int"] = str(source.literal + 2)
        with self.assertRaisesRegex(common.CompareError, "native exit_code: LIT holds"):
            oracle.compare(self.root, self.graphs, self.index)

    def test_recorded_chain_mutant_is_rejected(self) -> None:
        source = oracle.source_exit(self.root)
        site = oracle.root_site(self.index, source.value, "exit_code")
        assert site.path is not None
        moved = site.path[:-1] + (site.path[-1] + 1,)
        sites = tuple(oracle.Site(s.line, s.view_kind, s.view_index, s.method, s.span, s.count,
                                  s.temp, s.state, s.place, s.place_method,
                                  moved if s is site else s.path) for s in self.index.sites)
        with self.assertRaises(common.CompareError):
            oracle.compare(self.root, self.graphs, oracle.Index(self.index.entry, sites))


if __name__ == "__main__":
    unittest.main()
