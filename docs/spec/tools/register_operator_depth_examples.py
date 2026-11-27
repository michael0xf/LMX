"""Synchronize documented depth examples; never execute a production parser."""
import argparse
import hashlib
import json
from pathlib import Path

from register_expression_slices_examples import normalized, table

SPEC = Path(__file__).resolve().parents[1]
DOCS = SPEC.parent
EXAMPLES = SPEC / "examples/operator_depth"
CATALOG = EXAMPLES / "doc_examples"
BEGIN = "<!-- generated-source-blocks:start -->"
END = "<!-- generated-source-blocks:end -->"


def expected_files():
    cases = json.loads((EXAMPLES / "cases.json").read_text())
    readme_path = EXAMPLES / "README.md"
    readme = readme_path.read_text().split(BEGIN)[0].rstrip()
    readme += "\n\n" + BEGIN + "\n\n## Полные листинги\n"
    outputs, places, receipts = {}, [], []
    index = [["#graph", "-", "-", "label=NOT_RUN", "-", "-", "-", "-",
              "No production parser/compiler/runtime was executed for this cohort"]]
    for block, case in enumerate(cases["positive"], 1):
        source = EXAMPLES / case["source"]
        code = normalized(source.read_text())
        ident = "operator_depth__" + case["id"]
        readme += f"\n### {source.name}\n\n{case['note_ru']}\n\n```lmx\n"
        line = len(readme.splitlines()) + 1
        readme += code + "```\n"
        outputs[CATALOG / "src" / f"{ident}.lm3"] = code
        places.extend([
            [ident, "docs/" + source.relative_to(DOCS).as_posix(), "file", "-", 1],
            [ident, "docs/" + readme_path.relative_to(DOCS).as_posix(), "block", block, line],
        ])
        index.append([ident, "fragment", 2, "-", "-", "-", "не проверен",
                      "2026-11-27", "Normative source; P0/translator/LMX runtime NOT_RUN"])
        receipts.append({
            **case, "id": ident, "source": source.relative_to(DOCS).as_posix(),
            "sha256": hashlib.sha256(code.encode()).hexdigest(),
            "markdown": readme_path.relative_to(DOCS).as_posix(),
            "block": block, "line": line, "source_markdown_sync": "PASS",
        })
    readme += "\n" + END + "\n"
    outputs[readme_path] = readme
    outputs[CATALOG / "index.tsv"] = table(
        ["id", "kind", "places", "p0", "build", "run", "class", "step_or_fix", "note"], index)
    outputs[CATALOG / "places.tsv"] = table(["id", "doc", "kind", "block", "line"], places)
    outputs[CATALOG / "README.md"] = """# Дополнительный doc_examples: глубина обхода операций

Пять полных исходников и десять мест текста: каждый отдельный `.lm3` также
приведён целиком в README рядом с ним. Формат `src`, `index.tsv`, `places.tsv`
сохраняет действующую схему каталога; стабильные ID начинаются operator_depth__.
Пути в places.tsv относительны директории, содержащей docs. При слиянии
дополнительной группы в общий каталог прежние ID и receipts не заменяются.

Это регистрация исходников и Markdown, **не запуск P0 или LMX**. В графах
p0/build/run стоят `-`, класс — «не проверен»; строка #graph сообщает NOT_RUN.
Негативные формы перечислены отдельно в [cases.json](../cases.json), они не
представляются как положительные parser fixtures.

Повторная синхронизация: `python spec/tools/register_operator_depth_examples.py`
из docs; проверка без записи — та же команда с `--check`.
SHA-256 и ожидаемые наблюдения: [отчёт](../../../validation/operator_depth_examples_20261127.json).
"""
    outputs[SPEC / "validation/operator_depth_examples_20261127.json"] = json.dumps({
        "revision": "2026-11-27", "status": "SOURCE_MD_SYNC_PASS",
        "scope": "Additive depth cohort; no production execution",
        "examples": len(receipts), "places": len(places), "cases": receipts,
        "negative_cases": cases["negative"],
        "invalid_depth": "Translator/interpreter diagnostic, not an LMX throw",
    }, ensure_ascii=False, indent=2) + "\n"
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    mismatches = []
    for path, content in expected_files().items():
        if not path.exists() or path.read_text() != content:
            mismatches.append(path.relative_to(DOCS).as_posix())
            if not args.check:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
    print(json.dumps({"status": "FAIL" if args.check and mismatches else "PASS",
                      "examples": 5, "locations": 10, "changed": mismatches,
                      "production_execution": "NOT_RUN"}, ensure_ascii=False))
    raise SystemExit(bool(args.check and mismatches))


if __name__ == "__main__":
    main()
