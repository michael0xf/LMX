#!/usr/bin/env python3
"""Execute only foreign implementations; never claim this executes LMX."""
import argparse
import importlib.util
import json
from pathlib import Path
import random
import shutil
import subprocess
import tempfile
import sys

sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parents[1]


def load(number, slug):
    path = ROOT / "examples" / "python" / f"{number}_{slug}.py"
    spec = importlib.util.spec_from_file_location(f"algorithm_{number}", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command, *, text="", cwd=None):
    return subprocess.run(command, input=text, text=True, capture_output=True,
                          check=True, timeout=60, cwd=cwd).stdout


def all_distances(graph, weighted=False):
    n = len(graph)
    d = [[None] * n for _ in graph]
    for u in range(n):
        d[u][u] = 0
        for edge in graph[u]:
            v, weight = edge if weighted else (edge, 1)
            if d[u][v] is None or weight < d[u][v]:
                d[u][v] = weight
    for k in range(n):
        for u in range(n):
            for v in range(n):
                if d[u][k] is not None and d[k][v] is not None:
                    candidate = d[u][k] + d[k][v]
                    if d[u][v] is None or candidate < d[u][v]:
                        d[u][v] = candidate
    return d


def component_labels(n, pairs):
    labels = list(range(n))
    for u, v in pairs:
        a, b = labels[u], labels[v]
        if a == b:
            continue
        if labels.count(a) < labels.count(b):
            a, b = b, a
        labels = [a if value == b else value for value in labels]
    return labels


def edit_oracle(left, right, same):
    matrix = [[i + j if i == 0 or j == 0 else 0
               for j in range(len(right) + 1)] for i in range(len(left) + 1)]
    for i, first in enumerate(left, 1):
        for j, second in enumerate(right, 1):
            matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1,
                               matrix[i - 1][j - 1] + (not same(first, second)))
    return matrix[-1][-1]


def is_acyclic(graph):
    color = [0] * len(graph)
    def visit(v):
        if color[v] == 1:
            return False
        if color[v] == 2:
            return True
        color[v] = 1
        if not all(visit(w) for w in graph[v]):
            return False
        color[v] = 2
        return True
    return all(visit(v) for v in range(len(graph)))


CPP_RUNNER = r"""
#include <cassert>
#include <iostream>
#include <string>
#include "100_lower_bound.cpp"
#include "103_union_find.cpp"
#include "105_dijkstra.cpp"
template<class T> void output(const std::vector<T>& result) {
    std::cout << '[';
    for (std::size_t i=0; i<result.size(); ++i) {
        if (i) std::cout << ',';
        std::cout << result[i];
    }
    std::cout << "]\n";
}
int main() {
    struct Row { int key; std::string label; };
    const std::vector<Row> rows{{2,"a"},{2,"b"},{8,"c"}};
    assert(lowerBound(rows,2,[](const Row& r,int k){return r.key<k;})==0);
    assert(lowerBound(rows,3,[](const Row& r,int k){return r.key<k;})==2);
    const std::vector<std::string> words{"a","b","b","z"};
    assert(lowerBound(words,std::string("b"))==1);
    int kind, n;
    while (std::cin >> kind >> n) {
        if (kind == 100) {
            long long needle;
            std::cin >> needle;
            std::vector<long long> items(n);
            for (auto& value:items) std::cin >> value;
            std::cout << lowerBound(items,needle) << '\n';
        } else if (kind == 103) {
            int m; std::cin >> m;
            std::vector<std::array<int,2>> pairs(m);
            for (auto& pair:pairs) std::cin >> pair[0] >> pair[1];
            output(unionFind(n,pairs));
        } else {
            int start; std::cin >> start;
            std::vector<std::vector<std::pair<int,std::int64_t>>> graph(n);
            for (auto& row:graph) {
                int degree; std::cin >> degree;
                row.resize(degree);
                for (auto& edge:row) std::cin >> edge.first >> edge.second;
            }
            output(dijkstra(graph,start));
        }
    }
}
"""

JAVA_RUNNER = r"""
import java.util.Arrays;
import java.util.Scanner;
class Runner {
    public static void main(String[] arguments) {
        Scanner input = new Scanner(System.in);
        while (input.hasNextInt()) {
            int kind=input.nextInt(), n=input.nextInt();
            int[] result;
            if (kind==103) {
                int count=input.nextInt();
                int[][] pairs=new int[count][2];
                for (int[] pair:pairs) {pair[0]=input.nextInt();pair[1]=input.nextInt();}
                result=UnionFindExample.run(n,pairs);
            } else {
                int start=input.nextInt();
                int[][] graph=new int[n][];
                for (int i=0;i<n;++i) {
                    graph[i]=new int[input.nextInt()];
                    for (int j=0;j<graph[i].length;++j) graph[i][j]=input.nextInt();
                }
                result=kind==101?BreadthFirstExample.run(graph,start):TopologicalExample.run(graph);
            }
            System.out.println(result==null?"null":Arrays.toString(result));
        }
    }
}
"""

JS_RUNNER = r"""
const fs = require("fs");
const {editDistance} = require(process.argv[2]);
const cases = JSON.parse(fs.readFileSync(0,"utf8"));
for (const c of cases) {
    const {left,right,comparator} = c.input;
    const same = comparator === "key" ? (a,b)=>a.key===b.key : (a,b)=>a===b;
    console.log(JSON.stringify(editDistance(left,right,same)));
}
const trace = [];
const distance = editDistance([1,2],[2,1],(a,b)=>{trace.push([a,b]);return a===b;});
if (distance!==2 || JSON.stringify(trace)!==JSON.stringify([[1,2],[1,1],[2,2],[2,1]]))
    throw new Error("callback order");
if (editDistance([], [1], ()=>{throw new Error("unexpected callback")})!==1)
    throw new Error("empty input");
"""

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=ROOT / "tests" / "validation.json")
    args = parser.parse_args()
    cases = json.loads((ROOT / "tests" / "cases.json").read_text())["cases"]
    fixed_count = len(cases)
    rng = random.Random(20261125)
    py = {
        100: load(100,"lower_bound").lower_bound,
        101: load(101,"breadth_first_search").breadth_first_search,
        102: load(102,"topological_sort").topological_sort,
        104: load(104,"edit_distance").edit_distance,
        105: load(105,"dijkstra").dijkstra,
    }
    for iteration in range(120):
        n = rng.randrange(13)
        items = sorted(rng.randrange(-20,21) for _ in range(n))
        needle = rng.randrange(-25,26)
        expected = next((i for i,x in enumerate(items) if x>=needle),len(items))
        cases.append(dict(id=f"lb_random_{iteration}",algorithm=100,
                          input=dict(items=items,needle=needle),expected=expected))
        graph = [[rng.randrange(n) for _ in range(rng.randrange(6))]
                 for _ in range(n)]
        start = rng.randrange(n) if n else -1
        distances = all_distances(graph)
        expected = [-1 if x is None else x for x in distances[start]] if n else []
        cases.append(dict(id=f"bfs_random_{iteration}",algorithm=101,
                          input=dict(graph=graph,start=start),expected=expected))
        order = py[102](graph)
        assert (order is not None) == is_acyclic(graph)
        if order is not None:
            assert sorted(order)==list(range(n))
            rank={v:i for i,v in enumerate(order)}
            assert all(rank[u]<rank[v] for u,row in enumerate(graph) for v in row)
        cases.append(dict(id=f"topo_random_{iteration}",algorithm=102,
                          input=dict(graph=graph),expected=order))
        pairs = [[rng.randrange(n),rng.randrange(n)] for _ in range(rng.randrange(30))] if n else []
        cases.append(dict(id=f"dsu_random_{iteration}",algorithm=103,
                          input=dict(n=n,pairs=pairs),expected=component_labels(n,pairs)))
        left = [rng.choice(["a","b","я","🙂"]) for _ in range(rng.randrange(10))]
        right = [rng.choice(["a","b","я","🙂"]) for _ in range(rng.randrange(10))]
        cases.append(dict(id=f"edit_random_{iteration}",algorithm=104,
                          input=dict(left=left,right=right),
                          expected=edit_oracle(left,right,lambda a,b:a==b)))
        weighted = [[[v,rng.randrange(10)] for v in row] for row in graph]
        distances = all_distances(weighted,True)
        expected = [-1 if x is None else x for x in distances[start]] if n else []
        cases.append(dict(id=f"dijkstra_random_{iteration}",algorithm=105,
                          input=dict(graph=weighted,start=start),expected=expected))
    counts = {}
    for case in cases:
        number, data = case["algorithm"], case["input"]
        snapshot = json.dumps(data,ensure_ascii=False,sort_keys=True)
        if number in py:
            kwargs=dict(data)
            comparator=kwargs.pop("comparator",None)
            if comparator=="key": kwargs["same"]=lambda a,b:a["key"]==b["key"]
            result=py[number](**kwargs)
            assert result==case["expected"],(case["id"],"Python",result,case["expected"])
            counts[f"{number}:Python"]=counts.get(f"{number}:Python",0)+1
            assert snapshot==json.dumps(data,ensure_ascii=False,sort_keys=True),case["id"]
    rows=[{"key":2,"label":"a"},{"key":2,"label":"b"},{"key":8,"label":"c"}]
    assert py[100](rows,3,lambda row,key:row["key"]<key)==2
    assert py[100](["a","b","b","z"],"b")==1
    trace=[]
    assert py[104]([1,2],[2,1],lambda a,b:trace.append((a,b)) or a==b)==2
    assert trace==[(1,2),(1,1),(2,2),(2,1)]
    assert py[104]([], [1], lambda a,b:(_ for _ in ()).throw(AssertionError()))==1
    with tempfile.TemporaryDirectory(prefix="lmx-algorithms-") as temporary:
        tmp=Path(temporary)
        cpp_dir=ROOT / "examples" / "cpp"
        (tmp/"runner.cpp").write_text(CPP_RUNNER)
        compiler=shutil.which("g++")
        run([compiler,"-std=c++17","-O2","-Wall","-Wextra","-Werror","-I",str(cpp_dir),
             str(tmp/"runner.cpp"),"-o",str(tmp/"cpp")])
        cpp_cases=[c for c in cases if c["algorithm"] in (100,103,105)]
        lines=[]
        for case in cpp_cases:
            kind, data=case["algorithm"],case["input"]
            if kind==100:
                tokens=[100,len(data["items"]),data["needle"],*data["items"]]
            elif kind==103:
                tokens=[103,data["n"],len(data["pairs"])]
                tokens.extend(x for pair in data["pairs"] for x in pair)
            else:
                tokens=[105,len(data["graph"]),data["start"]]
                for row in data["graph"]:
                    tokens.append(len(row))
                    tokens.extend(x for edge in row for x in edge)
            lines.append(" ".join(map(str,tokens)))
        results=run([str(tmp/"cpp")],text="\n".join(lines)+"\n").splitlines()
        assert len(results)==len(cpp_cases)
        for case,raw in zip(cpp_cases,results):
            assert json.loads(raw)==case["expected"],(case["id"],"C++",raw)
            key=f'{case["algorithm"]}:C++'
            counts[key]=counts.get(key,0)+1
        (tmp/"Runner.java").write_text(JAVA_RUNNER)
        java_cases=[c for c in cases if c["algorithm"] in (101,102,103)]
        java_sources=[str(path) for path in sorted((ROOT/"examples/java").glob("*.java"))]
        java=shutil.which("java")
        run([java,"-m","jdk.compiler/com.sun.tools.javac.Main","-d",str(tmp),
             *java_sources,str(tmp/"Runner.java")])
        lines=[]
        for case in java_cases:
            kind,data=case["algorithm"],case["input"]
            if kind==103:
                tokens=[103,data["n"],len(data["pairs"])]
                tokens.extend(x for pair in data["pairs"] for x in pair)
            else:
                tokens=[kind,len(data["graph"]),data.get("start",-1)]
                for row in data["graph"]:
                    tokens.extend([len(row),*row])
            lines.append(" ".join(map(str,tokens)))
        results=run([java,"-cp",str(tmp),"Runner"],text="\n".join(lines)+"\n").splitlines()
        assert len(results)==len(java_cases)
        for case,raw in zip(java_cases,results):
            assert json.loads(raw)==case["expected"],(case["id"],"Java",raw)
            key=f'{case["algorithm"]}:Java'
            counts[key]=counts.get(key,0)+1
        (tmp/"runner.js").write_text(JS_RUNNER)
        js_cases=[c for c in cases if c["algorithm"]==104]
        results=run([shutil.which("node"),str(tmp/"runner.js"),
                     str(ROOT/"examples/javascript/104_edit_distance.js")],
                    text=json.dumps(js_cases,ensure_ascii=False)).splitlines()
        assert len(results)==len(js_cases)
        for case,raw in zip(js_cases,results):
            assert json.loads(raw)==case["expected"],(case["id"],"JavaScript",raw)
            counts["104:JavaScript"]=counts.get("104:JavaScript",0)+1
    report={
        "status":"PASS",
        "date":"2026-11-25",
        "fixed_contract_cases":fixed_count,
        "generated_contract_cases":len(cases)-fixed_count,
        "seed":20261125,
        "executed_foreign_case_results":sum(counts.values()),
        "by_implementation":dict(sorted(counts.items())),
        "extra_probes":["C++ and Python heterogeneous-key and text lowerBound",
                        "Python/JavaScript equality callback order and empty-input skip",
                        "Python input immutability on every fixture",
                        "independent Floyd-Warshall distance oracle",
                        "independent DFS cycle oracle and edge-order validity",
                        "component-relabel union-find oracle",
                        "full-matrix edit-distance oracle"],
        "lmx_P0":"NOT_RUN",
        "lmx_L3":"NOT_RUN",
        "statistics":"NOT_RECALCULATED_BY_USER_REQUEST",
        "tools": {
            "python":run([shutil.which("python3"),"--version"]).strip(),
            "g++":run([shutil.which("g++"),"--version"]).splitlines()[0],
            "javac":run([shutil.which("java"),"-m","jdk.compiler/com.sun.tools.javac.Main","-version"]).strip(),
            "node":run([shutil.which("node"),"--version"]).strip(),
        }
    }
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n")
    print(json.dumps(report,ensure_ascii=False,indent=2))


if __name__=="__main__":
    main()
