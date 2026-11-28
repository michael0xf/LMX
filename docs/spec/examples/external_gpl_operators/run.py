"""Two user operands on the LMX Expression reference model, backed by native GPL libraries."""

import inspect
import json
import math
import sys
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

import igraph as ig
import swiglpk as gl

# Use the project's grouper for already resolved occurrences. There is no source parser here.
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
import expression_grouping_reference as expr


def finite_vector(values, label):
    if not isinstance(values, (list, tuple)):
        raise ValueError(f"{label} must be a vector")
    if any(type(x) not in (int, float) or not math.isfinite(x) for x in values):
        raise ValueError(f"{label} must contain finite numbers")
    return values


def mip_max(margin, usage, stock, kinds, limit_ms):
    """Maximize margin*x under usage*x <= stock, x >= 0 and per-column domains."""
    finite_vector(margin, "margin")
    finite_vector(stock, "stock")
    n, m = len(margin), len(stock)
    if not n or not m or not isinstance(usage, (list, tuple)) or len(usage) != m:
        raise ValueError("expected n products, m resources and an m-by-n matrix")
    for row in usage:
        if len(finite_vector(row, "usage row")) != n:
            raise ValueError("each usage row must contain one entry per product")
    domains = {"B": gl.GLP_BV, "I": gl.GLP_IV, "C": gl.GLP_CV}
    if not isinstance(kinds, str) or len(kinds) != n or any(k not in domains for k in kinds):
        raise ValueError("kinds must give one B, I or C per column")
    if type(limit_ms) is not int or not 1 <= limit_ms <= 2**31 - 1:
        raise ValueError("limit_ms must be a positive C int")

    problem = gl.glp_create_prob()
    try:
        gl.glp_set_obj_dir(problem, gl.GLP_MAX)
        gl.glp_add_rows(problem, m)
        gl.glp_add_cols(problem, n)
        for j, (profit, kind) in enumerate(zip(margin, kinds), 1):
            gl.glp_set_col_bnds(problem, j, gl.GLP_LO, 0.0, 0.0)
            gl.glp_set_col_kind(problem, j, domains[kind])
            gl.glp_set_obj_coef(problem, j, profit)

        indices = gl.intArray(n + 1)
        coefficients = gl.doubleArray(n + 1)
        for i, (row, bound) in enumerate(zip(usage, stock), 1):
            gl.glp_set_row_bnds(problem, i, gl.GLP_UP, 0.0, bound)
            used = 0
            for j, coefficient in enumerate(row, 1):
                if coefficient != 0:
                    used += 1
                    indices[used] = j
                    coefficients[used] = coefficient
            gl.glp_set_mat_row(problem, i, used, indices, coefficients)

        controls = gl.glp_iocp()
        gl.glp_init_iocp(controls)
        controls.presolve = gl.GLP_ON
        controls.msg_lev = gl.GLP_MSG_OFF
        controls.tm_lim = limit_ms
        code = gl.glp_intopt(problem, controls)
        state = gl.glp_mip_status(problem)
        if code == 0 and state == gl.GLP_OPT:
            status = "optimal"
        elif code in (gl.GLP_ETMLIM, gl.GLP_EMIPGAP) and state == gl.GLP_FEAS:
            status = "feasible"
        elif code == gl.GLP_ENOPFS or (code == 0 and state == gl.GLP_NOFEAS):
            return {"status": "infeasible"}
        else:
            return {"status": "unfinished", "glpkCode": code, "glpkMipStatus": state}
        return {
            "status": status,
            "quantity": [gl.glp_mip_col_val(problem, j) for j in range(1, n + 1)],
            "score": gl.glp_mip_obj_val(problem),
        }
    finally:
        gl.glp_delete_prob(problem)


@dataclass(frozen=True)
class Network:
    names: tuple[str, ...]
    edges: tuple[tuple[int, int], ...]


def cut_between(network, source, target, capacity):
    """Return a minimum directed s-t cut; capacities follow original edge order."""
    if not isinstance(network, Network):
        raise ValueError("expected a directed Network")
    names, edges = network.names, network.edges
    if any(not isinstance(name, str) for name in names) or len(set(names)) != len(names):
        raise ValueError("vertex names must be unique strings")
    if any(len(edge) != 2 or any(type(v) is not int or not 0 <= v < len(names) for v in edge)
           for edge in edges):
        raise ValueError("edge endpoints must be valid vertex indices")
    finite_vector(capacity, "capacity")
    if len(capacity) != len(edges) or any(x < 0 for x in capacity):
        raise ValueError("provide one nonnegative capacity per edge")
    graph = ig.Graph(n=len(names), edges=edges, directed=True, vertex_attrs={"name": names})

    def vertex_id(endpoint):
        if type(endpoint) is int and 0 <= endpoint < len(names):
            return endpoint
        if isinstance(endpoint, str):
            return graph.vs.find(name=endpoint).index
        raise ValueError("expected a vertex index or name")

    start, finish = vertex_id(source), vertex_id(target)
    if start == finish:
        raise ValueError("source and target must differ")
    cut = graph.st_mincut(start, finish, capacity=capacity)
    source_side = next(part for part in cut.partition if start in part)
    return {
        "capacity": cut.value,
        "edgeIds": sorted(cut.cut),
        "sourceSide": [names[i] for i in sorted(source_side)],
    }


@dataclass(frozen=True)
class UserOperand:
    binding: expr.Binding
    function: Callable

    def invoke(self, left, depth, right, namespace, evaluate):
        if left is expr.ABSENT or depth is not expr.ABSENT:
            raise ValueError("these whole-object methods require left and omit depth")
        # Bind the number of occurrences before demanding a single value.
        inspect.signature(self.function).bind(left, *right)
        result = self.function(evaluate(left.region), *(evaluate(item) for item in right))
        return expr.MethodOutcome(result, left.region)


@dataclass(frozen=True)
class Expression:
    items: tuple


class ReadyGraph(expr.GraphView):
    """Input contains resolved method references and ready values, including whole arrays."""
    def resolve(self, node, context):
        return node

    def fields(self, node):
        return node.items

    def is_structure(self, node):
        return isinstance(node, Expression)

    def name(self, node):
        return None

    def parent(self, node):
        return None

    def binding(self, node, context):
        return node.binding if isinstance(node, UserOperand) else None


def apply_example(*items):
    planner = expr.Planner(ReadyGraph())
    graph = Expression(items)
    application, = expr.normalize_expression(planner.plan(graph, expr.Context(graph)), planner)

    def obtain(unit):
        if not isinstance(unit, expr.Unit) or unit.kind != "atom":
            raise ValueError("expected a ready input occurrence in this example")
        return unit.node

    return expr.receive_application(application, application.operation_raw, None, obtain)


def main():
    mip = UserOperand(expr.Binding("mipMax", 70), mip_max)
    split = UserOperand(expr.Binding("cutBetween", 70), cut_between)
    margin = [12.0, 9.0, 2.0]
    usage = [[4.0, 3.0, 1.0], [2.0, 3.0, 0.0]]
    stock = [10.5, 6.0]
    mixed = apply_example(margin, mip, usage, stock, "IIC", 2500)
    whole = apply_example(margin, mip, usage, stock, "III", 2500)
    assert mixed == {"status": "optimal", "quantity": [2, 0, 2.5], "score": 29}
    assert whole == {"status": "optimal", "quantity": [2, 0, 2], "score": 28}

    network = Network(("порт", "север", "юг", "завод"),
                      ((0, 1), (0, 2), (1, 3), (2, 3), (1, 2)))
    capacity = [5.0, 4.0, 2.0, 3.0, 1.0]
    cut = apply_example(network, split, 0, "завод", capacity)
    assert cut == {"capacity": 5, "edgeIds": [2, 3], "sourceSide": ["порт", "север", "юг"]}
    assert cut == apply_example(network, split, "порт", 3, capacity)
    print(json.dumps({
        "GLPK": gl.glp_version(), "igraph": ig.__igraph_version__,
        "mipMax": mixed, "mipMaxAllInteger": whole, "cutBetween": cut,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
