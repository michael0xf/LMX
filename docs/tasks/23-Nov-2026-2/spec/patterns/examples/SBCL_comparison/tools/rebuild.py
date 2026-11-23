#!/usr/bin/env python3
"""Regenerate only this comparison directory from its canonical source files.

examples.json supplies contracts and source paths. Source files supply code.
No file outside SBCL_comparison is created, changed, or removed.
"""
from pathlib import Path
import sys
sys.dont_write_bytecode = True
import csv
import hashlib
import io
import json

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ROOT.parents[1]
sys.path.insert(0, str(PATTERNS / 'tools'))
from throws_metrics import measure_throws
EDITION = "2026-11-23"
FENCE = "`" * 3


def normalized(text):
    lines = text.replace("\r\n", "\n").replace("\r", "\n").splitlines()
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    return "\n".join(lines) + "\n"


def metrics(text):
    text = normalized(text)
    throws = measure_throws(text, patterns_root=PATTERNS)
    return {
        "characters_nonwhitespace": sum(not c.isspace() for c in text),
        "without_complex_throws_characters": throws['without_complex_throws_characters'],
        "complex_throws_removed_characters": throws['removed_characters'],
        "characters_all": len(text),
        "nonblank_lines": sum(bool(s.strip()) for s in text.splitlines()),
        "utf8_bytes": len(text.encode("utf-8")),
        "sha256": hashlib.sha256(text.encode("utf-8")).hexdigest(),
    }


def write(relative, text):
    target = (ROOT / relative).resolve()
    if not target.is_relative_to(ROOT):
        raise ValueError(f"Output escapes comparison directory: {relative}")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8", newline="\n")


def write_json(relative, data):
    write(relative, json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def code_block(language, code):
    return f"{FENCE}{language}\n{normalized(code)}{FENCE}\n"


def source_code(relative):
    target = (ROOT / relative).resolve()
    if not target.is_relative_to(ROOT):
        raise ValueError(f"Client source escapes comparison directory: {relative}")
    return normalized(target.read_text(encoding="utf-8"))


def source_list(values):
    rows = []
    for item in values:
        if isinstance(item, str):
            rows.append(f"- <{item}>")
        else:
            rows.append(f"- [{item.get('title', item.get('url'))}]({item['url']})")
    return "\n".join(rows) + "\n"


def count_table(a, b):
    return ("| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |\n"
            "| --- | ---: | ---: | ---: | ---: |\n"
            f"| LMX | {a['characters_nonwhitespace']} | {a['without_complex_throws_characters']} | {a['characters_all']} | {a['nonblank_lines']} |\n"
            f"| Common Lisp / SBCL | {b['characters_nonwhitespace']} | — | {b['characters_all']} | {b['nonblank_lines']} |\n")


def as_paragraphs(value):
    if not value:
        return ""
    if isinstance(value, str):
        return value + "\n"
    if isinstance(value, list):
        return "\n\n".join(as_paragraphs(x).rstrip() for x in value) + "\n"
    return code_block("json", json.dumps(value, ensure_ascii=False, indent=2))


def total(rows, language):
    keys = ["characters_nonwhitespace", "without_complex_throws_characters", "complex_throws_removed_characters", "characters_all", "nonblank_lines", "utf8_bytes"]
    return {k: sum(row[language][k] for row in rows) for k in keys}


def main():
    data = json.loads((ROOT / "examples.json").read_text(encoding="utf-8"))
    implementation_data = json.loads((ROOT / "implementation_data.json").read_text(encoding="utf-8"))
    implementations = implementation_data["implementations"]
    coverage = {}
    for impl in implementations:
        for name in impl["core_functions"]:
            coverage.setdefault(name, []).append(impl["id"])

    rows, variants, inventory = [], [], []
    for entry in data["examples"]:
        lmx = source_code(entry["source_files"]["lmx"])
        foreign = source_code(entry["source_files"]["foreign"])
        entry["lmx"], entry["foreign"] = lmx, foreign
        counts = {"lmx": metrics(lmx), "foreign": metrics(foreign)}
        entry["counts"] = counts
        status = entry.get("comparison_status", "complete_pair")
        entry["comparison_status"] = status
        ratio = counts["foreign"]["characters_nonwhitespace"] / counts["lmx"]["characters_nonwhitespace"] if status == "complete_pair" else None
        row = {"id": entry["id"], "title": entry["title"], "category": entry["category"],
               "comparison_status": status, "ratio_foreign_over_lmx": ratio, **counts}
        rows.append(row)
        entry["implementation_links"] = {name: coverage.get(name, []) for name in entry.get("core_functions", [])}
        for language in ("lmx", "foreign"):
            inventory.append({"id": entry["id"], "scope": "client", "language": language,
                              "path": entry["source_files"][language], **counts[language]})
        scope = "Полная пара в указанном ниже договоре." if status == "complete_pair" else "Протокольная аналогия. Требует LMX integration fixture и исключена из итоговых коэффициентов."
        parts = [f"# {entry['id']}. {entry['title']}\n", scope + "\n", "## Общий договор\n",
                 as_paragraphs(entry["contract"]), as_paragraphs(entry.get("domain")),
                 as_paragraphs(entry.get("observables")), "## Входы и ожидаемые наблюдения\n",
                 code_block("json", json.dumps(entry.get("test_cases", entry.get("semantic_cases", [])), ensure_ascii=False, indent=2)),
                 "## Размер основного варианта\n", count_table(counts["lmx"], counts["foreign"]),
                 "Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.\n",
                 "## LMX\n", f"[Исходник]({entry['source_files']['lmx']}).\n", code_block("lmx", lmx),
                 "## Common Lisp / SBCL\n", f"[Исходник]({entry['source_files']['foreign']}).\n", code_block("common-lisp", foreign),
                 "## Почему эти варианты сопоставимы\n", as_paragraphs(entry.get("selection_reason")),
                 as_paragraphs(entry.get("notes_ru")), as_paragraphs(entry.get("limitations")),
                 as_paragraphs(entry.get("foreign_boundary")), as_paragraphs(entry.get("lmx_boundary"))]
        deps = entry.get("foreign_dependencies", [])
        if deps:
            parts.append("Средства Common Lisp/SBCL: " + ", ".join(f"`{x}`" for x in deps) + ".\n")
        links = entry["implementation_links"]
        parts.append("## Реализации используемых функций\n")
        if links:
            for name, ids in links.items():
                parts.append(f"- `{name}`: " + ", ".join(f"[{i}](library_comparisons/{i}_comparision.md)" for i in ids) + "\n")
        else:
            parts.append("Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.\n")
        parts.append("Common Lisp-клиент не загружает сравнительные reference-реализации.\n")
        for alt in entry.get("alternatives", []):
            text = source_code(alt["source_file"])
            alt["code"], alt["counts"] = text, metrics(text)
            variants.append({"example": entry["id"], "approach": alt["approach"], "language": alt.get("language", "LMX"),
                             "source_file": alt["source_file"], **alt["counts"]})
            inventory.append({"id": entry["id"], "scope": "alternative", "language": alt.get("language", "LMX"),
                              "path": alt["source_file"], **alt["counts"]})
            parts.extend(["## Другой подход: " + alt["approach"] + "\n", as_paragraphs(alt.get("reason")),
                          f"[Исходник]({alt['source_file']}). В основной коэффициент не входит.\n",
                          code_block("lmx" if alt.get("language", "LMX") == "LMX" else "common-lisp", text)])
            for name in alt.get("core_functions", []):
                parts.append(f"`{name}`: " + ", ".join(f"[{i}](library_comparisons/{i}_comparision.md)" for i in coverage.get(name, [])) + ".\n")
        parts.extend(["## Проверка\n", "SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.\n",
                      "## Первичные источники\n", source_list(entry.get("sources", []))])
        write(f"{entry['id']}_comparision.md", "\n".join(p for p in parts if p))

    impl_rows = []
    for impl in implementations:
        code = {key: source_code(impl["source_files"][key]) for key in ("lmx", "foreign")}
        measures = {key: metrics(value) for key, value in code.items()}
        impl_rows.append({"id": impl["id"], "title": impl["title"], "core_functions": impl["core_functions"],
                          "dependency_role": impl.get("dependency_role", "primary"), **measures})
        for key in ("lmx", "foreign"):
            inventory.append({"id": impl["id"], "scope": "implementation", "language": key,
                              "path": impl["source_files"][key], **measures[key]})

    paired = [x for x in rows if x["comparison_status"] == "complete_pair"]
    a, b = total(paired, "lmx"), total(paired, "foreign")
    statistics = {"suite": "sbcl", "edition": EDITION,
                  "method": "Unicode codepoints, LF, exterior blank lines removed, one terminal LF; primary metric excludes Unicode whitespace; comments included.",
                  "counts": {"examples": len(rows), "complete_pairs": len(paired), "related_analogies": len(rows) - len(paired),
                             "implementation_pairs": len(impl_rows), "alternatives": len(variants)},
                  "paired_totals": {"lmx": a, "foreign": b, "ratio_foreign_over_lmx": b["characters_nonwhitespace"] / a["characters_nonwhitespace"]},
                  "all_client_totals": {key: total(rows, key) for key in ("lmx", "foreign")},
                  "implementation_primary_totals": {key: total(impl_rows, key) for key in ("lmx", "foreign")},
                  "examples": rows, "implementations": impl_rows, "alternatives": variants,
                  "dependency_closure": implementation_data.get("totals", {}),
                  "runtime": {"common_lisp": "See validation/common_lisp.json and implementation_execution.json", "lmx": "NOT_RUN"}}
    write_json("examples.json", data)
    write_json("statistics.json", statistics)
    write_json("SOURCE_INVENTORY.json", {"edition": EDITION, "files": inventory})
    flat = []
    for scope, selected in (("client", rows), ("implementation", impl_rows)):
        for row in selected:
            for language in ("lmx", "foreign"):
                flat.append({"scope": scope, "id": row["id"], "title": row["title"], "language": "LMX" if language == "lmx" else "Common Lisp / SBCL",
                             "comparison_status": row.get("comparison_status", "separate_implementation"), **row[language]})
    fields = ["scope", "id", "title", "language", "comparison_status", "characters_nonwhitespace", "without_complex_throws_characters", "complex_throws_removed_characters", "characters_all", "nonblank_lines", "utf8_bytes", "sha256"]
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=fields, lineterminator="\n")
    writer.writeheader()
    writer.writerows(flat)
    write("statistics.csv", buffer.getvalue())
    used = {n for e in data["examples"] for n in e.get("core_functions", [])}
    alternative_used = {n for e in data["examples"] for alt in e.get("alternatives", []) for n in alt.get("core_functions", [])}
    write_json("validation/library_coverage.json", {
        "coverage": coverage, "primary_core_functions": sorted(used), "alternative_core_functions": sorted(alternative_used),
        "missing_primary": sorted(used - coverage.keys()), "missing_alternative": sorted(alternative_used - coverage.keys()),
        "rule": "Reference Common Lisp implementation modules are never loaded by foreign clients."})
    table = ("| ID | Задача | LMX полный | LMX без сложного Throws | Lisp полный | Lisp / LMX |\n"
             "| --- | --- | ---: | ---: | ---: | ---: |\n")
    for row in rows:
        ratio = f"{row['ratio_foreign_over_lmx']:.3f}" if row["ratio_foreign_over_lmx"] is not None else "вне итога"
        table += f"| [{row['id']}]({row['id']}_comparision.md) | {row['title']} | {row['lmx']['characters_nonwhitespace']} | {row['lmx']['without_complex_throws_characters']} | {row['foreign']['characters_nonwhitespace']} | {ratio} |\n"
    table += f"| **Итого: {len(paired)} полных пар** | | **{a['characters_nonwhitespace']}** | **{a['without_complex_throws_characters']}** | **{b['characters_nonwhitespace']}** | **{statistics['paired_totals']['ratio_foreign_over_lmx']:.3f}** |\n"
    impl_table = "| ID | Операции | LMX полный | LMX без сложного Throws | Lisp полный |\n| --- | --- | ---: | ---: | ---: |\n"
    for row in impl_rows:
        impl_table += f"| [{row['id']}](library_comparisons/{row['id']}_comparision.md) | {row['title']} | {row['lmx']['characters_nonwhitespace']} | {row['lmx']['without_complex_throws_characters']} | {row['foreign']['characters_nonwhitespace']} |\n"
    write("LMX_Comparison_SBCL.md", "# LMX / Common Lisp на SBCL\n\n23 ноября 2026 года. Размер исходного кода, не скорость исполнения.\n\n" + table +
          "\nS24 показан отдельно: его LMX host/parser fixture ещё требует интеграции. Полная пара означает совпадение заявленных наблюдений на указанном домене, а не тождество всех возможностей языкового механизма.\n\n" +
          "Все размеры в таблицах — без пробельных символов. Основной коэффициент использует полные листинги. Дополнительная колонка сохраняет заголовок и первый синтаксический аргумент Throws/банка; copy и ссылки считаются целиком. Явные Throws и copy(Throws) — преимущество LMX: видно, что метод может бросить. Это не предложение сокращать такие исходные объявления.\n\n" +
          "## Реализации операций\n\n" + impl_table +
          "\nОбщие зависимости пересекаются между группами и учитываются отдельно; сумма строк не является размером одного приложения. [Методика](README.md), [JSON](statistics.json), [CSV](statistics.csv), [PDF](LMX_Comparison_SBCL.pdf), [XLSX](LMX_Comparison_SBCL.xlsx).\n")
    design = ["# Характерные приёмы Common Lisp / SBCL и их LMX-варианты\n"]
    for category in dict.fromkeys(e["category"] for e in data["examples"]):
        design.append("## " + category + "\n")
        design.extend(f"- [{e['id']}. {e['title']}]({e['id']}_comparision.md): {e.get('summary', e['contract'] if isinstance(e['contract'], str) else '')}" for e in data["examples"] if e["category"] == category)
        design.append("")
    write("LMX_Design_Patterns.SBCL.md", "\n".join(design))
    throw_details=[]
    for record in inventory:
        if record['language'] in ('lmx','LMX'):
            throw_details.append({'path':record['path'],**measure_throws(source_code(record['path']),patterns_root=PATTERNS)})
    for path in ('source/lmx/Expression_examples.lm3','source/implementations/lmx/shared_dependencies.lmx'):
        throw_details.append({'path':path,**measure_throws(source_code(path),patterns_root=PATTERNS)})
    write_json('validation/throws_metrics.json',{'source':'../../tools/throws_metrics.py','full_metric_unchanged':True,'files':throw_details})
    print(json.dumps({"counts": statistics["counts"], "paired_totals": statistics["paired_totals"], "missing_core_coverage": sorted(used - coverage.keys())}, ensure_ascii=False))


if __name__ == "__main__":
    main()
