"""Register the new examples in doc_examples format; never run an LMX parser.

This is a standalone additive cohort because the supplied docs archive does
not contain the project's root doc_examples directory. Its stable IDs and TSV
columns can be merged into that directory without inheriting historic PASS.
"""
import argparse
import csv
import hashlib
import io
import json
from pathlib import Path

SPEC = Path(__file__).resolve().parents[1]
DOCS = SPEC.parent
EXAMPLES = SPEC / "examples/expression_slices"
CATALOG = EXAMPLES / "doc_examples"
BEGIN = "<!-- generated-source-blocks:start -->"
END = "<!-- generated-source-blocks:end -->"

EXPECTED = {
    "001_author_slices": {"value": [[0, 2, 4, 6], [6, 5, 4, 3, 2, 1, 0],
                                    [4, 5, 6], [0, 1, 2, 3, 4], [5, 4, 3, 2]]},
    "002_slice_omission": {"value": [[6, 5, 4, 3, 2, 1, 0], [], [6, 4, 2, 0]]},
    "003_lazy_conditional": {"value": 42, "unused_arm_calls": 0},
    "004_conditional_receiver": {"value": 42, "unused_arm_calls": 0},
    "005_overlap_reverse": {"value": [6, 5, 4, 3, 2, 1, 0]},
    "006_group_rotation": {"value": [2, 3, 1]},
    "007_pointer_neighbor": {"value": 10},
    "008_nested_conditional": {"inputs": [[1, 0], [0, 1], [0, 0]],
                               "values": [10, 20, 30]},
    "009_conditional_bound": {"inputs": [1, 0], "values": [[1, 3, 5], [2, 4]]},
    "010_slice_zero_step": {"failure": "SequenceStep", "source_unchanged": True},
}


def normalized(text):
    return text.replace("\r\n", "\n").replace("\r", "\n").rstrip("\n") + "\n"


def table(header, rows):
    out = io.StringIO()
    writer = csv.writer(out, delimiter="\t", lineterminator="\n")
    writer.writerow(header)
    writer.writerows(rows)
    return out.getvalue()


def expected_files():
    readme_path = EXAMPLES / "README.md"
    readme = readme_path.read_text(encoding="utf-8").split(BEGIN)[0].rstrip()
    readme += ("\n\n" + BEGIN + "\n\n## Полные листинги\n\n"
               "Блоки ниже синхронизированы с отдельными `.lm3`. "
               "[Каталог в формате doc_examples](doc_examples/README.md) "
               "сохраняет два места каждого текста и отдельный статус NOT_RUN.\n")
    outputs, places, cases = {}, [], []
    index = [["#graph", "-", "-", "label=NOT_RUN", "-", "-", "-", "-",
              "No production Graph/parser/compiler/runtime was executed for this cohort"]]
    for block, source in enumerate(sorted(EXAMPLES.glob("*.lm3")), 1):
        ident = "expression_slices__" + source.stem
        code = normalized(source.read_text(encoding="utf-8"))
        expected = EXPECTED[source.stem]
        readme += f"\n### {source.name}\n\n```lmx\n"
        first_line = len(readme.splitlines()) + 1
        readme += code + "```\n"
        outputs[CATALOG / "src" / f"{ident}.lm3"] = code
        file_doc = "docs/" + source.relative_to(DOCS).as_posix()
        md_doc = "docs/" + readme_path.relative_to(DOCS).as_posix()
        places.extend([[ident, file_doc, "file", "-", 1],
                       [ident, md_doc, "block", block, first_line]])
        index.append([ident, "fragment", 2, "-", "-", "-", "не проверен",
                      "2026-11-26", "Normative source; P0/translator/LMX runtime NOT_RUN"])
        cases.append({"id": ident, "source": source.relative_to(DOCS).as_posix(),
                      "sha256": hashlib.sha256(code.encode()).hexdigest(),
                      "markdown": readme_path.relative_to(DOCS).as_posix(),
                      "block": block, "line": first_line,
                      "source_markdown_sync": "PASS", "expected": expected,
                      "production_p0": "NOT_RUN", "production_translator": "NOT_RUN",
                      "lmx_runtime": "NOT_RUN"})
    readme += "\n" + END + "\n"
    outputs[readme_path] = readme
    outputs[CATALOG / "index.tsv"] = table(
        ["id", "kind", "places", "p0", "build", "run", "class", "step_or_fix", "note"], index)
    outputs[CATALOG / "places.tsv"] = table(["id", "doc", "kind", "block", "line"], places)
    outputs[CATALOG / "README.md"] = """# Дополнительная группа doc_examples: условные формы и срезы

Это отдельная группа из 10 новых текстов редакции 26 ноября 2026. В поставленном
архиве docs не было корневого doc_examples; прежние тексты и результаты из другой
редакции сюда не перенесены. Эта группа подготовлена для слияния с общим каталогом.

Формат соответствует прежнему каталогу: `src/<id>.lm3`, `index.tsv` и `places.tsv`.
У текста два места: самостоятельный файл и полный блок README рядом с ним. Пути
в places.tsv относительны каталогу, содержащему docs. Идентификаторы начинаются
с `expression_slices__`; при слиянии они сохраняются. Нормализация ограничена
CRLF/CR → LF и одним завершающим LF, остальные символы сохраняются.

Колонки p0/build/run имеют `-`, класс — `не проверен`. Строка #graph говорит
NOT_RUN, а не называет ранее испытанный Graph. Совпадение текстов и host-model
PASS не являются результатом P0, трансляции или запуска этих LMX-программ.

Повторная регистрация: `python spec/tools/register_expression_slices_examples.py`
из docs; проверка без записи — та же команда с `--check`.
Машиночитаемые ожидания и SHA-256: [отчёт](../../../validation/expression_slices_examples_20261126.json).
"""
    outputs[SPEC / "validation/expression_slices_examples_20261126.json"] = json.dumps(
        {"revision": "2026-11-26", "status": "SOURCE_MD_SYNC_PASS",
         "scope": "Additive expression_slices cohort; no production execution",
         "examples": len(cases), "places": len(places),
         "normalization": "LF and exactly one final LF; all other bytes retained",
         "cases": cases}, ensure_ascii=False, indent=2) + "\n"
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    outputs = expected_files()
    mismatches = []
    for path, content in outputs.items():
        same = path.exists() and path.read_text(encoding="utf-8") == content
        if not same:
            mismatches.append(path.relative_to(DOCS).as_posix())
            if not args.check:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")
    print(json.dumps({"status": "FAIL" if args.check and mismatches else "PASS",
                      "examples": len(EXPECTED), "locations": len(EXPECTED) * 2,
                      "production_execution": "NOT_RUN", "changed": mismatches},
                     ensure_ascii=False))
    return int(args.check and bool(mismatches))


if __name__ == "__main__":
    raise SystemExit(main())
