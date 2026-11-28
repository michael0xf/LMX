"""Synchronize the additive Array-expression examples; no production LMX run."""

import argparse
import hashlib
import json
from pathlib import Path

from register_expression_slices_examples import normalized, table


SPEC = Path(__file__).resolve().parents[1]
DOCS = SPEC.parent
EXAMPLES = SPEC / "examples/array_expressions"
CATALOG = EXAMPLES / "doc_examples"


def expected_files():
    cases = json.loads((EXAMPLES / "cases.json").read_text(encoding="utf-8"))["cases"]
    # Keep the maintained normative introduction, just as the Array-storage registry does.
    readme = EXAMPLES / "README.md"
    heading = "## Исходники и ожидания"
    current = readme.read_text(encoding="utf-8")
    if heading not in current:
        raise ValueError("Array-expression README is missing its source-section heading")
    text = current.split(heading, 1)[0].rstrip() + "\n\n" + heading + "\n"
    outputs, places, reports = {}, [], []
    index = [["#graph", "-", "-", "label=NOT_RUN", "-", "-", "-", "-", "No production execution"]]
    readme = EXAMPLES / "README.md"
    for block, case in enumerate(cases, 1):
        path = EXAMPLES / case["source"]
        code = normalized(path.read_text(encoding="utf-8"))
        ident = case["id"]
        text += f"\n### {case['title']}\n\n[Полный исходник]({case['source']}).\n\n"
        text += case["note"] + "\n\n"
        for entry in case["entries"]:
            text += f"- `{entry['call']}`: " + json.dumps(entry["expected"], ensure_ascii=False) + ".\n"
        text += "\n```lmx\n"
        line = len(text.splitlines()) + 1
        text += code + "```\n"
        outputs[CATALOG / "src" / f"{ident}.lm3"] = code
        places += [[ident, "docs/" + path.relative_to(DOCS).as_posix(), "file", "-", 1],
                   [ident, "docs/" + readme.relative_to(DOCS).as_posix(), "block", block, line]]
        index.append([ident, "fragment", 2, "-", "-", "-", "не проверен", "2026-11-28",
                      "Expected diagnostic; NOT_RUN" if case["negative"] else "Normative example; NOT_RUN"])
        reports.append({**case, "source": path.relative_to(DOCS).as_posix(),
                        "sha256": hashlib.sha256(code.encode()).hexdigest(),
                        "markdown": readme.relative_to(DOCS).as_posix(), "block": block, "line": line,
                        "source_markdown_sync": "PASS", "production_p0": "NOT_RUN",
                        "production_translator": "NOT_RUN", "lmx_runtime": "NOT_RUN"})
    outputs[readme] = text
    outputs[CATALOG / "index.tsv"] = table(
        ["id", "kind", "places", "p0", "build", "run", "class", "step_or_fix", "note"], index)
    outputs[CATALOG / "places.tsv"] = table(["id", "doc", "kind", "block", "line"], places)
    outputs[CATALOG / "README.md"] = f"""# Дополнительная группа doc_examples: Array expressions

{len(cases)} исходников, по два места каждого: файл и полный блок [README](../README.md).
ID `array_expressions__...` стабильны; index/places имеют обычный формат каталога.
Production p0/build/run — `-`, класс `не проверен`, Graph — NOT_RUN.
Пути places относительно каталога, содержащего docs. Нормализация — LF и один
завершающий LF; другие байты сохраняются. Повторная генерация из docs:
`python spec/tools/register_array_expression_examples.py`; проверка — `--check`.
[SHA-256 и ожидания](../../../validation/array_expression_examples_20261128.json).
"""
    outputs[EXAMPLES / "negative/README.md"] = """# Отдельная диагностика inline singleton

[Исходник](inline_singleton_mismatch.lm3) имеет внешнюю длину 2 слева и 1 у
`[arr2]`. Array из одного элемента не является scalar broadcast. Ожидается
диагностика транслятора либо интерпретатора, без нового catchable exception.
Полный текст и ожидание — в [общем README](../README.md). Production NOT_RUN.
"""
    outputs[SPEC / "validation/array_expression_examples_20261128.json"] = json.dumps({
        "revision": "2026-11-28", "status": "SOURCE_MD_SYNC_PASS",
        "scope": "Additive Array-expression examples; no production execution",
        "examples": len(cases), "places": len(places), "cases": reports,
    }, ensure_ascii=False, indent=2) + "\n"
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    changed = []
    for path, content in expected_files().items():
        if not path.exists() or path.read_text(encoding="utf-8") != content:
            changed.append(path.relative_to(DOCS).as_posix())
            if not args.check:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")
    print(json.dumps({"status": "FAIL" if args.check and changed else "PASS",
                      "production_execution": "NOT_RUN", "changed": changed}, ensure_ascii=False))
    return int(args.check and bool(changed))


if __name__ == "__main__":
    raise SystemExit(main())
