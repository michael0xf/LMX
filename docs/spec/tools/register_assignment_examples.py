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
    readme = f"""# Присваивание: `:=`, `.:` и сравнение `.=`

Фикстуры предыдущей редакции: {positives} положительных и {negatives} отрицательных.
Для TypeRef ABI случаи 021, 022 и negative/023 требуют `int[2][2]` вместо `int[][]`:
границы строк не сохраняют оси; готовый вход с заданным TYPE сохраняет его при допуске.
Production P0, translator и LMX runtime — **NOT_RUN**; нового `Main` нет.

`:=` меняет одно существующее место. Если это переменная-ссылка, меняется её
цель, а прежние алиасы продолжают ссылаться на прежний объект. `.:` меняет
элементы выбранного назначения и сохраняет идентичность его Array; в группе
слева находятся реальные переменные или другие допустимые PLACE. `.=` только
сравнивает соответствующие элементы и возвращает Array предикатов.

Для обычного `.:` вся RHS и допуск всех целей готовы до первой записи. Один
возвращённый Array читает сам поэлементный потребитель; несколько соседних
структурных значений остаются несколькими элементами. Скалярное заполнение
не делает Array из одного элемента скаляром. Явное `target .: fuse(expression)`
выбирает отдельный потоковый договор: поздний обычный скалярный отказ сохраняет
записанный префикс.

[Общая глубина](../../OPERATOR_DEPTH.ru.md) передаёт методу числовой `depth`:
`op` имеет depth=0, `.op` — 1, `.(EXPR)op` получает явную глубину через обычное
Expression один раз при востребовании. В ресиверной записи используется
базовое имя и `depth := n`. Присваивание отображается как `:=`, `.:`,
`.(EXPR):`; явное `.(0):` — обычная целая перепривязка настоящего binding PLACE.
Глубина потребляет сохранённые логические оси плоского Array: у ранга 2 depth=1
выбирает регионы строк, depth=2 — скалярные ячейки. Строка не получает отдельного
pointer-slot или объекта графа. Недостающая ось не маскируется распространением
скаляра, достигнутого внутри Array. Обычные Structure в полях сохраняют свою
идентичность; отдельной сущности «массив массивов» нет.

Примеры используют готовые числовые данные для понятных результатов;
операции Array и fused-метод не ограничены `int`. Списки `throws` копируются
из вызываемых базовых канонических методов; точечные имена в кавычках
не декодируются в операцию с глубиной. RAW/PLACE-адаптеры новых форм ещё должны
быть подключены в production согласно [границе реализации](../../FUSION.ru.md#implementation);
эти файлы не объявляют поддельных заглушек вместо ядра.

Нормы: [Array и присваивание](../../ARRAY_EXPRESSIONS.ru.md#assignment),
[срезы](../../TERNARY_AND_SLICES.ru.md), [fuse](../../FUSION.ru.md),
[групповое присваивание](../../LMX_semantics.ru.md#group-assign).
[doc_examples](doc_examples/README.md) содержит дополнительные стабильные ID,
два места каждого текста и SHA-256 в [отчёте](../../validation/assignment_forms_examples_20261126.json).

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

Ниже сохранены прежние ожидания; изменения TypeRef для случаев с осями оговорены выше.
Исполняемая [семантическая модель](../../tools/array_expression_reference.py)
и её [проверки](../../tools/array_expression_reference_results.json) отдельно
проверяют snapshots, alias, admission, shape и fusion. Синхронизация текстов
проверяет лишь совпадение исходников, блоков Markdown и копий doc_examples.

Отрицательные случаи вынесены в `negative/`; они не входят в успешный запуск
положительных примеров. Неподходящие глубина/форма и непригодное выражение fuse
диагностируются транслятором, если уже известны, иначе интерпретатором при
достижении. Это не catchable LMX exceptions и не дополнительные строки throws.
Обычный допуск целевого типа и ошибки самих числовых/обратных методов сохраняют
свой существующий договор. Откат уже выполненных эффектов RHS не обещается.

Поздний арифметический отказ в fused-записи проверен host-моделью с явно
выбранным бросающим scalar provider. Этот раздел не придумывает для всех
числовых типов единое имя или поведение деления на ноль. Production-проверки
RAW/PLACE, времени жизни, объявления `throws` и точных ошибок остаются NOT_RUN.

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
SHA-256, входы и ожидания: [машиночитаемый отчёт](../../../validation/assignment_forms_examples_20261126.json).
Совпадение текстов не является запуском production LMX.
"""
    outputs[EXAMPLES / "negative/README.md"] = """# Отдельные ожидаемые отказы и диагностика

Эти исходники преднамеренно не завершаются успешным результатом при указанных
входах. Все тексты, вызовы, входы и ожидаемое состояние назначения приведены
в [общем README](../README.md#отдельные-отрицательные-fixtures).
Production parser/translator/runtime: **NOT_RUN**. Структурные ошибки глубины,
формы и непригодное выражение fuse — диагностика транслятора/интерпретатора,
а не введённые здесь языковые исключения.

""" + "".join(
        f"- [{Path(case['source']).name}]({Path(case['source']).name}): {case['title']}.\n"
        for case in cases if case["negative"]
    )
    outputs[SPEC / "validation/assignment_forms_examples_20261126.json"] = json.dumps({
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
