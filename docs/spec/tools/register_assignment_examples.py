"""Synchronize the additive assignment_forms cohort; do not execute LMX."""

import argparse
import hashlib
import json
from pathlib import Path

from register_expression_slices_examples import normalized, table


SPEC = Path(__file__).resolve().parents[1]
DOCS = SPEC.parent
EXAMPLES = SPEC / "examples/assignment_forms"
CATALOG = EXAMPLES / "doc_examples"


def expected_files():
    metadata = json.loads((EXAMPLES / "cases.json").read_text(encoding="utf-8"))
    cases = metadata["cases"]
    positives = sum(not case["negative"] for case in cases)
    negatives = len(cases) - positives
    readme = f"""# Присваивание := и транслирование срезу .:

{positives} положительных и {negatives} отрицательных примеров. Обычный :=
присваивает поэлементно с полным снимком RHS и проверкой всех назначений до
записи. Скалярное место @ принимает одно ссылочное значение по своему типу.
Срезовое .: отдельно допускает транслирование RHS: оси выравниваются справа,
каждая длина равна целевой либо 1. Обычный = сравнивает и ничего не записывает.

Depth задаёт глубину обхода: 0 означает максимум, положительное N — N внешних
осей. Пропуск depth сохраняется до выбора профиля. Модификатор — .(depth).
Structure []@ не исключается из Arrays, а допуск проверяет фактические типы.

Минимальный fuse создаёт свежий Scalar/Map результат; dest := fuse(expr)
использует последующее обычное присваивание. Не обещаются streaming store,
частичная запись при отказе внутри fuse или поддержка contraction в fuse.

Нормы: [TENSOR_EXPRESSIONS](../../TENSOR_EXPRESSIONS.md),
[depth](../../OPERATOR_DEPTH.ru.md), [fuse](../../FUSION.ru.md).
Production parser/translator/LMX runtime: **NOT_RUN**.

## Содержание

| Источник | Что проверяет | Статус |
| --- | --- | --- |
"""
    for case in cases:
        state = "Ожидаемый отказ; NOT_RUN" if case["negative"] else "Ожидаемый результат; NOT_RUN"
        title = case["title"].replace("|", "\\|")
        readme += f"| [{case['source']}]({case['source']}) | {title} | {state} |\n"
    readme += """
## Границы проверки

Ожидания приведены для новой нормативной семантики. Синхронизация исходников,
Markdown и doc_examples не означает выполнение production parser/runtime.
Неподходящие rank/frame/axisRules и неподдержанный fuse — диагностика
транслятора при известных данных или интерпретатора при достижении.
Ошибки выбранных скалярных методов сохраняют обычные throws.

## Полные положительные примеры
"""
    outputs, places, reports = {}, [], []
    index = [["#graph", "-", "-", "label=NOT_RUN", "-", "-", "-", "-",
              "No production Graph/parser/compiler/runtime executed for this cohort"]]
    negative_heading_written = False
    readme_path = EXAMPLES / "README.md"
    for block, case in enumerate(cases, 1):
        if case["negative"] and not negative_heading_written:
            readme += "\n## Отдельные отрицательные fixtures\n"
            negative_heading_written = True
        source = EXAMPLES / case["source"]
        code = normalized(source.read_text(encoding="utf-8"))
        ident = case["id"]
        readme += f"\n### {case['title']}\n\n"
        readme += f"[Полный исходник]({case['source']}); вызов `{case['entrypoint']}`.\n\n"
        if case["inputs"]:
            readme += "Входы: `" + json.dumps(case["inputs"], ensure_ascii=False) + "`.\n\n"
        readme += "Ожидание: `" + json.dumps(case["expected"], ensure_ascii=False) + "`.\n\n"
        readme += case["note"] + "\n\n```lmx\n"
        first_line = len(readme.splitlines()) + 1
        readme += code + "```\n"
        outputs[CATALOG / "src" / f"{ident}.lm3"] = code
        places += [
            [ident, "docs/" + source.relative_to(DOCS).as_posix(), "file", "-", 1],
            [ident, "docs/" + readme_path.relative_to(DOCS).as_posix(), "block", block, first_line],
        ]
        index.append([ident, "fragment", 2, "-", "-", "-", "не проверен",
                      metadata["revision"],
                      "Expected rejection; production NOT_RUN" if case["negative"]
                      else "Normative example; production NOT_RUN"])
        reports.append({
            **case, "source": source.relative_to(DOCS).as_posix(),
            "sha256": hashlib.sha256(code.encode()).hexdigest(),
            "markdown": readme_path.relative_to(DOCS).as_posix(),
            "block": block, "line": first_line, "source_markdown_sync": "PASS",
            "production_p0": "NOT_RUN", "production_translator": "NOT_RUN",
            "lmx_runtime": "NOT_RUN",
        })
    outputs[readme_path] = readme
    outputs[CATALOG / "index.tsv"] = table(
        ["id", "kind", "places", "p0", "build", "run", "class", "step_or_fix", "note"], index)
    outputs[CATALOG / "places.tsv"] = table(["id", "doc", "kind", "block", "line"], places)
    outputs[CATALOG / "README.md"] = f"""# Дополнительная группа doc_examples: присваивание

{len(cases)} самостоятельных текстов: {positives} положительных и {negatives}
отрицательных. Формат — `src/<id>.lm3`, `index.tsv`, `places.tsv`.
ID `assignment_forms__...` стабильны; группа добавляется к общему каталогу,
не наследуя результаты старого Graph. Корневой doc_examples в загруженных
docs отсутствовал; чужие тексты или старые PASS сюда не перенесены.

У каждого исходника два зарегистрированных места: отдельный `.lm3` и полный
блок общего [README](../README.md). Пути `places.tsv` относительны каталогу,
содержащему `docs`. Нормализация меняет только CRLF/CR на LF и завершающий LF.
Значения p0/build/run — `-`, класс `не проверен`, Graph — `NOT_RUN`.

Повторная регистрация: `python spec/tools/register_assignment_examples.py`
из docs; проверка без записи: та же команда с `--check`.
SHA-256, входы и ожидания: [машиночитаемый отчёт](../../../validation/assignment_forms_examples_20261127.json).
Совпадение текстов не является запуском production LMX.
"""
    outputs[EXAMPLES / "negative/README.md"] = """# Отдельные ожидаемые отказы и диагностика

Эти исходники преднамеренно не завершаются успешным результатом при указанных
входах. Все тексты, вызовы, входы и ожидаемое состояние назначения приведены
в [общем README](../README.md#отдельные-отрицательные-fixtures).
Production parser/translator/runtime: **NOT_RUN**. Структурные ошибки ранга,
формы и непригодное выражение fuse — диагностика транслятора/интерпретатора,
а не введённые здесь языковые исключения.

""" + "".join(
        f"- [{Path(case['source']).name}]({Path(case['source']).name}): {case['title']}.\n"
        for case in cases if case["negative"]
    )
    outputs[SPEC / "validation/assignment_forms_examples_20261127.json"] = json.dumps({
        "revision": metadata["revision"], "status": "SOURCE_MD_SYNC_PASS",
        "scope": "Additive assignment_forms cohort; no production execution",
        "examples": len(cases), "positive_examples": positives, "negative_fixtures": negatives,
        "places": len(places), "normalization": "LF and one final LF; all other bytes retained",
        "cases": reports,
    }, ensure_ascii=False, indent=2) + "\n"
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    outputs, changed = expected_files(), []
    for path, content in outputs.items():
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
