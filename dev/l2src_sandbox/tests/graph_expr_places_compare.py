#!/usr/bin/env python3
"""Translation-time expression-site index -> retained physical place witness (G1).

Usage: graph_expr_places_compare.py [--require-shared-run] P0_EVENTS GRAPH_EVENTS EXPR_PLACES

EXPR_PLACES is the translator's own test-only dump (L2_EXPR_PLACES_OUT): one
record per source expression site noted in the PLACE pass, keyed by the
construction view (kind:index), the selecting method, the first written P0
node's span and the run's field count, and resolved after bind to a retained
place: the owning child chain from the method's occurrence. The dump reads the
translator's records only; the physical side is the driver's graph event dump
of the root occurrence, native and walker, before execution.

What is checked, and fails closed:

* Index integrity: no two records share one key; no record is left pending;
  no site is ambiguous (two sibling constructions of one run in one view).
* Non-aliasing: one P0 run (same span and count) constructed in two views or
  by two methods yields distinct records with distinct place objects. Their
  child chains may coincide, because each chain is relative to its own view's
  occurrence; the view is part of the key, not of the chain. With
  `--require-shared-run` at least one such run must exist and be bound twice.
* The root `sendMessage: [Ref] exit(...)` occurrence, in both graph blocks:
  the `exit_code` value site (one decimal literal, or one bare identifier)
  must be bound in the root view to a chain that reaches, through owned edges
  only, the node the primitive's NAMED `exit_code` actual borrows as its
  payload; a literal reaches a LIT whose int cell holds the written value, an
  identifier reaches an OWN. The written Ref run, when present, must be bound
  to the chain that reaches the very node the primitive borrows as its last
  input, an OF with its typed pointer-cell witness whose coordinate is the
  P0-resolved selector index (the supported Ref forms are those of
  graph_send_source_compare).

Other sites are counted, not interpreted: the unbound count is reported. The
verdict is PARTIAL OK: this is an index witness, not a complete native/walker
parity proof. A separate executable mutant checks the numeric LIT payload.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
import sys

import graph_method_order_compare as common
import graph_send_source_compare as send_oracle


LIT = 3
OWN = 4
OF = 15
PRIM_PUB = 33
NAMED = 47
SPAN = re.compile(r"^(\d+):(\d+)\+(\d+):(\d+)$")
DECIMAL = re.compile(rb"^-?[0-9]+$")
IDENTIFIER = re.compile(rb"^[A-Za-z_][A-Za-z0-9_]*$")
STATES = ("bound", "unbound", "ambiguous", "pending")


@dataclass(frozen=True)
class Site:
    line: int
    view_kind: int
    view_index: int
    method: int
    span: str
    count: int
    temp: int
    state: str
    place: int | None
    place_method: int | None
    path: tuple[int, ...] | None

    @property
    def key(self) -> tuple[int, int, int, str, int]:
        return (self.view_kind, self.view_index, self.method, self.span, self.count)

    @property
    def run(self) -> tuple[str, int]:
        return (self.span, self.count)

    @property
    def view(self) -> tuple[int, int, int]:
        return (self.view_kind, self.view_index, self.method)


@dataclass(frozen=True)
class Index:
    entry: int
    sites: tuple[Site, ...]


@dataclass(frozen=True)
class SourceSite:
    """The P0 side of one checked site: its first atom's span and run count."""
    span: str
    count: int


@dataclass(frozen=True)
class SourceExit:
    send_index: int
    field_index: int
    value: SourceSite
    kind: str
    literal: int | None
    ref: SourceSite | None
    ref_coordinate: int | None
    ref_spelling: bytes | None


@dataclass(frozen=True)
class Report:
    sites: int
    bound: int
    unbound: int
    shared_runs: int
    exit_site: Site
    ref_site: Site | None


def parse_index(path: Path) -> Index:
    lines = path.read_text(encoding="ascii").splitlines()
    common.need(bool(lines), "index: empty expression-place dump")
    head = lines[0].split()
    common.need(len(head) == 3 and head[0] == "expr-places" and head[1] == "1",
                "index: unsupported dump header")
    entry = common.number(common.attr(common.parse_attrs(head[2:], "index header"), "entry",
                                      "index header"), "index header")
    common.need(lines[-1] == "end-expr-places", "index: missing end-expr-places")
    sites: list[Site] = []
    for line_number, line in enumerate(lines[1:-1], 2):
        where = f"index line {line_number}"
        fields = line.split()
        common.need(bool(fields) and fields[0] == "site", f"{where}: expected a site record")
        attrs = common.parse_attrs(fields[1:], where)
        view = common.attr(attrs, "view", where).split(":")
        common.need(len(view) == 2, f"{where}: malformed view")
        span = common.attr(attrs, "span", where)
        common.need(span == "-" or SPAN.match(span) is not None, f"{where}: malformed span {span!r}")
        state = common.attr(attrs, "state", where)
        common.need(state in STATES, f"{where}: unknown state {state!r}")
        place = place_method = None
        path: tuple[int, ...] | None = None
        if state == "bound":
            place = common.number(common.attr(attrs, "place", where), where)
            place_method = common.number(common.attr(attrs, "place_method", where), where)
            steps = common.attr(attrs, "path", where).split("/")
            common.need(all(step.isdigit() for step in steps), f"{where}: malformed path")
            path = tuple(int(step, 10) for step in steps)
        else:
            common.need(not ({"place", "place_method", "path"} & attrs.keys()),
                        f"{where}: an unbound record carries a place")
        sites.append(Site(
            line_number, common.number(view[0], where), common.number(view[1], where),
            common.number(common.attr(attrs, "method", where), where), span,
            common.number(common.attr(attrs, "count", where), where),
            common.number(common.attr(attrs, "temp", where), where), state,
            place, place_method, path))
    return Index(entry, tuple(sites))


def check_index(index: Index, require_shared: bool) -> int:
    """Integrity and non-aliasing over the whole dump; returns the number of
    P0 runs bound in two or more views/methods."""
    seen: dict[tuple[int, int, int, str, int], Site] = {}
    for site in index.sites:
        previous = seen.get(site.key)
        common.need(previous is None,
                    f"index line {site.line}: a second record of the site at line "
                    f"{previous.line if previous is not None else 0}")
        seen[site.key] = site
        common.need(site.state != "pending", f"index line {site.line}: site left pending after bind")
        common.need(site.state != "ambiguous",
                    f"index line {site.line}: span {site.span} count {site.count} has two "
                    f"constructions in view {site.view_kind}:{site.view_index}")
    runs: dict[tuple[str, int], list[Site]] = {}
    for site in index.sites:
        if site.span != "-":
            runs.setdefault(site.run, []).append(site)
    shared = 0
    for run, group in runs.items():
        if len({site.view for site in group}) < 2:
            continue
        bound = [site for site in group if site.state == "bound"]
        places = [site.place for site in bound]
        common.need(len(set(places)) == len(places),
                    f"run {run[0]} count {run[1]}: two views share one place object")
        if len(bound) >= 2:
            shared += 1
    if require_shared:
        common.need(shared >= 1, "no P0 run is bound in two construction views")
    return shared


def atom_span(node: common.P0Node, where: str) -> str:
    common.need(node.tag == "atom" and node.text is not None, f"{where}: expected an atom")
    span = common.attr(node.attrs, "span", where)
    common.need(SPAN.match(span) is not None, f"{where}: malformed span {span!r}")
    return span


def source_exit(root: common.P0Node) -> SourceExit:
    common.need(root.tag == "structure", "P0: root is not a Structure")
    matches = [index for index, child in enumerate(root.children)
               if child.tag == "frame" and child.text == b"sendMessage"]
    common.need(len(matches) == 1, f"P0: expected one root-level sendMessage, got {len(matches)}")
    send = root.children[matches[0]]
    where = f"P0 root[{matches[0]}]"
    common.need(common.attr(send.attrs, "colon", where) == "1" and send.trailer is None
                and len(send.children) >= 1, f"{where}: expected a sendMessage Frame")
    exit_frame = send.children[-1]
    common.need(exit_frame.tag == "frame" and exit_frame.text == b"exit" and exit_frame.trailer is None,
                f"{where}: expected an exit Frame last")
    fields = [index for index, frame in enumerate(exit_frame.children)
              if frame.tag == "frame" and frame.text == b"exit_code"]
    common.need(len(fields) == 1, f"{where}.exit: expected one exit_code field, got {len(fields)}")
    field = exit_frame.children[fields[0]]
    place = f"{where}.exit.exit_code"
    common.need(common.attr(field.attrs, "colon", place) == "1" and field.trailer is None
                and len(field.children) == 1, f"{place}: expected a one-value field")
    value = field.children[0]
    span = atom_span(value, place)
    assert value.text is not None
    if DECIMAL.match(value.text):
        kind, literal = "literal", int(value.text, 10)
    elif IDENTIFIER.match(value.text):
        kind, literal = "own", None
    else:
        raise common.CompareError(f"{place}: unsupported exit_code value {value.text!r}")
    ref = ref_coordinate = ref_spelling = None
    if len(send.children) > 1:
        written = send.children[:-1]
        resolved = send_oracle.resolve_ref(root, send_oracle.source_ref(written, f"{where}.ref"),
                                           f"{where}.ref")
        ref = SourceSite(atom_span(written[0], f"{where}.ref"), len(written))
        ref_coordinate = resolved.coordinates[-1]
        ref_spelling = resolved.path.spelling
    return SourceExit(matches[0], fields[0], SourceSite(span, 1), kind, literal,
                      ref, ref_coordinate, ref_spelling)


def root_site(index: Index, source: SourceSite, label: str) -> Site:
    """The one bound record of a run in the root view, selected by the entry."""
    matches = [site for site in index.sites
               if site.view == (0, index.entry, index.entry) and site.run == (source.span, source.count)]
    common.need(len(matches) == 1,
                f"{label}: expected one root-view record of span {source.span} count {source.count}, "
                f"got {len(matches)}")
    site = matches[0]
    common.need(site.state == "bound", f"{label}: site at index line {site.line} is {site.state}")
    assert site.path is not None and site.place_method is not None
    common.need(site.place_method == index.entry,
                f"{label}: place method {site.place_method}, expected the entry {index.entry}")
    common.need(len(site.path) >= 1, f"{label}: empty place chain")
    return site


def follow(graph: common.GraphNode, path: tuple[int, ...], label: str) -> common.GraphNode:
    node = graph
    for step, child in enumerate(path):
        common.need(child < len(node.slots),
                    f"{label}: chain step {step} selects child {child} beyond width {len(node.slots)}")
        slot = node.slots[child]
        common.need(common.attr(slot.attrs, "owned", label) == "1" and slot.child is not None,
                    f"{label}: chain step {step} child {child} is not an owned edge")
        node = slot.child
    return node


def opcode(node: common.GraphNode, label: str) -> int:
    common.need(bool(node.slots), f"{label}: node without slots")
    head = node.slots[0].attrs
    common.need(common.attr(head, "kind", label) == "17" and common.attr(head, "type", label) == "31",
                f"{label}: slot 0 is not an operation record")
    return common.number(common.attr(head, "op", label), label)


def index_nodes(node: common.GraphNode, out: dict[str, common.GraphNode]) -> None:
    address = node.attrs["node"]
    common.need(address not in out, f"graph: node {address} dumped twice")
    out[address] = node
    for slot in node.slots:
        if slot.child is not None:
            index_nodes(slot.child, out)


def check_graph(graph: common.GraphNode, label: str, source: SourceExit,
                exit_site: Site, ref_site: Site | None) -> None:
    nodes: dict[str, common.GraphNode] = {}
    index_nodes(graph, nodes)
    _, slot = send_oracle.root_occurrence(graph, b"sendMessage", label, op=PRIM_PUB)
    prim = slot.child
    assert prim is not None and exit_site.path is not None
    where = f"{label} exit_code"
    node = follow(graph, exit_site.path, where)
    code = opcode(node, where)
    if source.kind == "literal":
        common.need(code == LIT and len(node.slots) == 2, f"{where}: op={code} width={len(node.slots)}, expected LIT of width 2")
        cell = node.slots[1].attrs
        common.need(common.attr(cell, "kind", where) == "1" and common.attr(cell, "type", where) == "2",
                    f"{where}: LIT operand is not an int cell")
        held = common.number(common.attr(cell, "int", where), where)
        common.need(held == source.literal, f"{where}: LIT holds {held}, P0 writes {source.literal}")
    else:
        common.need(code == OWN, f"{where}: op={code}, expected OWN")
    actual_slot = 3 + source.field_index
    common.need(actual_slot < len(prim.slots), f"{where}: the primitive has no actual {actual_slot}")
    named = prim.slots[actual_slot].attrs
    common.need(common.attr(named, "op", where) == str(NAMED)
                and common.decode_graph_name(named.get("value_name", "-"), where) == b"exit_code",
                f"{where}: primitive actual {actual_slot} is not the NAMED exit_code")
    named_node = nodes.get(common.attr(named, "value", where))
    common.need(named_node is not None and len(named_node.slots) == 3,
                f"{where}: the NAMED exit_code node is not an owned node of this graph")
    assert named_node is not None
    payload = common.attr(named_node.slots[2].attrs, "value", where)
    common.need(payload == node.attrs["node"],
                f"{where}: the chain reaches {node.attrs['node']}, the primitive's payload is {payload}")
    if source.ref is None:
        common.need(ref_site is None, f"{label}: a Ref record without a written Ref")
        return
    assert ref_site is not None and ref_site.path is not None
    where = f"{label} ref"
    node = follow(graph, ref_site.path, where)
    code = opcode(node, where)
    common.need(code == OF and len(node.slots) == 5, f"{where}: op={code} width={len(node.slots)}, expected OF of width 5")
    coordinate = node.slots[2].attrs
    common.need(common.attr(coordinate, "kind", where) == "1" and common.attr(coordinate, "type", where) == "3",
                f"{where}: OF coordinate is not a size_t cell")
    held = common.number(common.attr(coordinate, "size", where), where)
    common.need(held == source.ref_coordinate,
                f"{where}: selector coordinate {held}, P0 resolves {source.ref_coordinate}")
    witness = node.slots[4].attrs
    common.need(common.attr(witness, "kind", where) == "1"
                and common.attr(witness, "type", where) == "1053",
                f"{where}: OF has no Message-reference pointer-cell witness")
    last = prim.slots[-1].attrs
    common.need(common.attr(last, "op", where) == str(OF) and common.attr(last, "owned", where) == "0",
                f"{where}: the primitive's last input is not a borrowed OF")
    common.need(common.attr(last, "value", where) == node.attrs["node"],
                f"{where}: the chain reaches {node.attrs['node']}, the primitive borrows {last['value']}")


def compare(root: common.P0Node, graphs: list[common.GraphNode], index: Index,
            *, require_shared: bool = False) -> Report:
    shared = check_index(index, require_shared)
    source = source_exit(root)
    exit_site = root_site(index, source.value, "exit_code")
    ref_site = root_site(index, source.ref, "ref") if source.ref is not None else None
    for label, graph in zip(("native", "walker"), graphs):
        check_graph(graph, label, source, exit_site, ref_site)
    bound = sum(1 for site in index.sites if site.state == "bound")
    unbound = sum(1 for site in index.sites if site.state == "unbound")
    return Report(len(index.sites), bound, unbound, shared, exit_site, ref_site)


def chain(site: Site) -> str:
    assert site.path is not None
    return "/".join(str(step) for step in site.path)


def main() -> int:
    args = sys.argv[1:]
    require_shared = False
    if args and args[0] == "--require-shared-run":
        require_shared = True
        args = args[1:]
    if len(args) != 3:
        print(f"usage: {Path(sys.argv[0]).name} [--require-shared-run] P0_EVENTS GRAPH_EVENTS EXPR_PLACES",
              file=sys.stderr)
        return 2
    try:
        root = common.parse_p0(Path(args[0]))
        graphs = common.parse_graph(Path(args[1]))
        index = parse_index(Path(args[2]))
        report = compare(root, graphs, index, require_shared=require_shared)
        source = source_exit(root)
    except (common.CompareError, OSError, UnicodeError) as exc:
        print(f"G1 expression-place comparison FAILED: {exc}", file=sys.stderr)
        return 1
    value = f"literal {source.literal}" if source.kind == "literal" else "own"
    ref = "none"
    if report.ref_site is not None and source.ref_spelling is not None:
        ref = f"{source.ref_spelling.decode('ascii', 'backslashreplace')} at {chain(report.ref_site)}"
    print(f"G1 expression-place comparison PARTIAL OK: sites={report.sites} bound={report.bound} "
          f"unbound={report.unbound} exit_code={value} at {chain(report.exit_site)} ref={ref} "
          f"shared-runs={report.shared_runs} native/walker=2; other sites counted, not interpreted; "
          f"numeric LIT parity checked separately")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
