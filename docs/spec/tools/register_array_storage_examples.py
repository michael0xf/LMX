"""Synchronize the Array-storage source cohort; no production parser execution."""
import argparse
import hashlib
import json
from pathlib import Path

from register_expression_slices_examples import normalized, table

SPEC = Path(__file__).resolve().parents[1]
DOCS = SPEC.parent
EXAMPLES = SPEC / "examples/array_storage"
CATALOG = EXAMPLES / "doc_examples"
BEGIN = "<!-- generated-source-blocks:start -->"
END = "<!-- generated-source-blocks:end -->"


def expected_files():
    cases = json.loads((EXAMPLES / "cases.json").read_text())
    readme_path = EXAMPLES / "README.md"
    readme = readme_path.read_text().split(BEGIN)[0].rstrip()
    block = readme.count("```lmx\n")
    readme += "\n\n" + BEGIN + "\n\n## Полные листинги\n"
    outputs, places, receipts = {}, [], []
    verification = cases.get("verification")
    production = "PARTIAL" if verification else "NOT_RUN"
    index = [["#graph", "-", "-", "label=" + production, "-", "-", "-", "-",
              verification["graph_sha256"] if verification else "No production execution"]]
    for category in ("positive", "negative"):
        for case in cases[category]:
            source = EXAMPLES / case["source"]
            code = normalized(source.read_text())
            ident = "array_storage__" + case["id"]
            label = "Отрицательный пример" if category == "negative" else "Положительная форма"
            readme += f"\n### {source.name}\n\n{label}: {case['note_ru']}\n\n```lmx\n"
            block += 1
            line = len(readme.splitlines()) + 1
            readme += code + "```\n"
            outputs[CATALOG / "src" / f"{ident}.lm3"] = code
            places.extend([
                [ident, "docs/" + source.relative_to(DOCS).as_posix(), "file", "-", 1],
                [ident, "docs/" + readme_path.relative_to(DOCS).as_posix(), "block", block, line],
            ])
            p0 = "0" if case.get("production_p0") == "PASS" else "-"
            if case.get("production_translator") == "EXPECTED_SHAPE_DIAGNOSTIC":
                build, run, result, note = "answered 2", "-", "ожидаемый отказ", "Shape diagnostic"
            elif case.get("lmx_runtime") == "INTERPRETER_PASS":
                build, run, result, note = "0", "0", "проверен", "Graph interpreter"
            else:
                build, run, result, note = "-", "-", "не проверен", "Production NOT_RUN"
            index.append([ident, "fragment", 2, p0, build, run, result, "2026-11-27", note])
            receipts.append({
                **case, "id": ident, "category": category,
                "source": source.relative_to(DOCS).as_posix(),
                "sha256": hashlib.sha256(code.encode()).hexdigest(),
                "markdown": readme_path.relative_to(DOCS).as_posix(),
                "block": block, "line": line, "source_markdown_sync": "PASS",
            })
    readme += "\n" + END + "\n"
    outputs[readme_path] = readme
    outputs[CATALOG / "index.tsv"] = table(
        ["id", "kind", "places", "p0", "build", "run", "class", "step_or_fix", "note"], index)
    outputs[CATALOG / "places.tsv"] = table(["id", "doc", "kind", "block", "line"], places)
    outputs[CATALOG / "README.md"] = f"""# Дополнительный doc_examples: плоское хранение Array

{len(receipts)} полных исходников ({len(cases['positive'])} положительных и
{len(cases['negative'])} отрицательных) и {len(places)} мест текста: каждый
самостоятельный `.lm3` также приведён целиком в README рядом с ним. Формат
`src`, `index.tsv`, `places.tsv` сохраняет схему каталога; стабильные ID
начинаются `array_storage__`. Пути в places.tsv относительны директории,
содержащей docs. При слиянии группы прежние ID и receipts не заменяются.

Регистратор сверяет исходники и Markdown. Колонки p0/build/run показывают
отдельно записанные результаты Graph. Прочерк означает отсутствие прогона.
У отрицательных примеров `answered 2` означает проверенную диагностику
формы при построении графа.

Повторная синхронизация: `python spec/tools/register_array_storage_examples.py`
из docs; проверка без записи — та же команда с `--check`.
SHA-256, категории и наблюдения: [отчёт](../../../validation/array_storage_examples_20261127.json).
"""
    outputs[SPEC / "validation/array_storage_examples_20261127.json"] = json.dumps({
        "revision": "2026-11-27", "status": "SOURCE_MD_SYNC_PASS",
        "scope": "Array-storage source registration with recorded per-case evidence",
        "examples": len(receipts), "places": len(places),
        "positive": len(cases["positive"]), "negative": len(cases["negative"]),
        "cases": receipts, "production_execution": production,
        "normalization": "LF and exactly one final LF; all other source bytes retained",
    }, ensure_ascii=False, indent=2) + "\n"
    return outputs, len(receipts), len(places)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    outputs, count, locations = expected_files()
    mismatches = []
    for path, content in outputs.items():
        if not path.exists() or path.read_text() != content:
            mismatches.append(path.relative_to(DOCS).as_posix())
            if not args.check:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
    print(json.dumps({"status": "FAIL" if args.check and mismatches else "PASS",
                      "examples": count, "locations": locations, "changed": mismatches,
                      "production_execution": "see case records"}, ensure_ascii=False))
    return int(args.check and bool(mismatches))


if __name__ == "__main__":
    raise SystemExit(main())
