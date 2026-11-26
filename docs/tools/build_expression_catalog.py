"""Project the documented Array/RAW/PLACE forms; never publish runtime names."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "core_catalog/core"
SOURCE = "spec/patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx"
ROWS = []

def add(name, family, roles, body, contract, precedence="scalar-counterpart",
        status="LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY", source=SOURCE):
    surface = name
    depth = 0
    if name == ".:":
        name, depth = ":=", 1
    elif name.startswith("var."):
        name, depth = name.replace("var.", "var", 1), 1
    elif name.startswith("."):
        name, depth = name[1:], 1
    ROWS.append(dict(
        name=name, family=family, roles=roles, precedence=precedence,
        expression_form=surface, example_depth=depth,
        depth_input="depth", operand_input_order=["left", "depth", "right"],
        depth_syntax="undotted=0; single-dot=1; .(general expression)=explicit; assignment stem ':' maps to ':='",
        receiver=f"`{name}`" if not name.isidentifier() else name,
        implementation=body, source=source,
        contract=contract, status=status,
        production_binding="NOT_RUN", lmx_executed=False,
    ))

for name in "+ - * / % ** & | ^ ~ << >>".split():
    body = "FxArrayProduct\\multiply / FxArrayElementwise\\apply" if name == "*" else "FxArrayElementwise\\apply"
    if name == "**": body = "selected-algebraic-power-profile (no new default body)"
    add(name, "ordinary-array-profile", ["VALUE"], body, "spec/ARRAY_EXPRESSIONS.en.md",
        status="SELECTED_PROFILE_CONTRACT_ONLY" if name == "**" else "LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY",
        source="spec/ARRAY_EXPRESSIONS.en.md" if name == "**" else SOURCE)
for name in ".+ .- .* ./ .% .** .& .| .^ .~ .<< .>> .= .!= .< .<= .> .>=".split():
    add(name, "component-value", ["VALUE"], "FxArrayDepth\\apply + selected base operation",
        "spec/ARRAY_EXPRESSIONS.en.md#dotted")
for name in ".+= .-= .*= ./= .%= .**= .&= .|= .^= .<<= .>>=".split():
    add(name, "component-update", ["PLACE", "VALUE"],
        "shared-update preparation -> FxArrayDepth\\apply -> FxArrayDepthAssignPrepared\\assign",
        "spec/ARRAY_EXPRESSIONS.en.md#assignment", "assignment",
        status="COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY")
for name in [".++var", "var.++", ".--var", "var.--"]:
    add(name, "attached-component-update", ["PLACE"],
        "old-value capture + FxArrayDepth\\apply(selected unit/update) + FxArrayDepthAssignPrepared\\assign + old/new result",
        "spec/ARRAY_EXPRESSIONS.en.md#dotted", "selected-attached-position",
        status="COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY")
add(".:", "component-assignment", ["PLACE", "VALUE"], "FxArrayDepthAssignPrepared\\assign -> shared FxArrayAssignPrepared\\assign",
    "spec/ARRAY_EXPRESSIONS.en.md#assignment", "assignment")
add("fuse", "one-loop-expression", ["RAW"], "FxFusePrepared\\run",
    "spec/FUSION.en.md#implementation", "receiver",
    status="LMX_LOOP_BODY_RAW_PREPARATION_REQUIRED")
add("?:", "lazy-conditional", ["VALUE", "RAW", "RAW"], "shared-expression-conditional",
    "spec/TERNARY_AND_SLICES.en.md#conditional", "below-logical-or-above-assignment-right",
    status="HOST_REFERENCE_AND_DOCUMENTED_ALGORITHM",
    source="spec/tools/ternary_slices_reference.py")
add("slice", "signed-strided-slice-overload", ["VALUE", "VALUE"],
    "shared-slice-normalize-and-selection", "spec/TERNARY_AND_SLICES.en.md#slice-receiver",
    "postfix-for-suffix-form", status="HOST_REFERENCE_AND_DOCUMENTED_ALGORITHM",
    source="spec/tools/ternary_slices_reference.py")

def build():
    OUT.mkdir(parents=True, exist_ok=True)
    data = dict(
        edition="2026-11-26",
        scope="Extension profiles of canonical operations; not a runtime export registry.",
        source_sha256=hashlib.sha256((ROOT/SOURCE).read_bytes()).hexdigest(),
        existing_catalog_names=215, existing_catalog_variants=227,
        note="The existing catalog counts describe its retained snapshot. Dot depth is an input of the base name, never a callable alias.",
        forms=ROWS,
    )
    (OUT/"array_expression_forms.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=2)+"\n")
    lines = [
        "# Array/RAW/PLACE operation profile inventory, 2026-11-26.",
        "# DATA only. Runtime export binding and LMX execution: NOT_RUN.",
        "# Bodies retain actual types, source parent and ordinary storage contracts.",
        "",
        "ArrayExpressionForms:",
    ]
    for i,row in enumerate(ROWS,1):
        lines.append(f"    entry{i:03}:")
        for key in ["name","family","receiver","expression_form","depth_input","depth_syntax","implementation","source","contract","precedence","status","production_binding"]:
            lines.append(f"        []char: {key} {json.dumps(row[key],ensure_ascii=False)}")
        lines.append(f"        int: exampleDepth {row['example_depth']}")
        lines.append("        int: executed 0")
    (OUT/"array_expression_forms.lmx").write_text("\n".join(lines)+"\n")
    head = """# Массивные операции, условие, срезы и fuse

Редакция 2026-11-26. [LMX-опись](array_expression_forms.lmx) и
[JSON-проекция](array_expression_forms.json) перечисляют договоры дополнения.
Это описания публикации, а не повторный runtime-диспетчер.
Исходный каталог 215 имён / 227 вариантов сохранён как исходная опись.
Новые профили не маскируются под уже проверенные экспорты компилятора.

Для каждого имени обе формы используют один обработчик. RAW-выражение
fuse/условия и PLACE назначения нельзя пропускать через eager VALUE-адаптер.
Унарная/бинарная форма точечных знаков выбирается обычным договором арности.
Обычный `*` использует целый матричный/векторный профиль. `.*` имеет
глубину 1 по логическим измерениям; скалярные координаты rank-2 массива
получаются через `.(2)*`. Промежуточные структуры строк не создаются.
`.=` сравнивает, `.:` присваивает элементам. `:=` присваивает целому месту
на глубине 0; `.(выражение):` задаёт глубину явно. Поэтому перестановка
элементов записывается `(a b c) .: (b c a)`.

[Общий depth](../../spec/OPERATOR_DEPTH.ru.md) — второй вход между left и right.
Форма без точки передаёт 0, одна точка — 1, `.(выражение)` — явно вычисленную
глубину. Внутри круглых скобок работает общий парсер. `.(` всегда начинает модификатор, не десятичную точку. Базовое имя
ресивера остаётся без точек; используется именованный depth. Таблица
ниже показывает профили и примеры поверхностной записи, не новые
вызываемые имена. Неопределимая/недопустимая глубина, несовместимая
структура и непригодный fuse — диагностика транслятора/интерпретатора,
без новых пользовательских исключений.

[LMX-тела](../../spec/patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx)
содержат реальные общие циклы, включая внутреннюю свёртку матричного
произведения. [Подключение](../../spec/FUSION.ru.md#implementation)
сохраняет существующий граф и namespace; подготовка формы/RAW/PLACE и
провайдеры скалярных операций остаются явно указанными точками интеграции.
Production parser, translator и runtime: **NOT_RUN**.

| Базовое имя | Пример формы | Семейство | Роли | Единое тело/алгоритм | Состояние исходника |
| --- | --- | --- | --- | --- | --- |
"""
    for row in ROWS:
        esc=lambda x:x.replace("|","\\|")
        head += f"| `{esc(row['name'])}` | `{esc(row['expression_form'])}` | {row['family']} | {', '.join(row['roles'])} | `{esc(row['implementation'])}` | {row['status']} |\n"
    (OUT/"ARRAY_EXPRESSIONS.md").write_text(head)
    return len(ROWS)

if __name__ == "__main__":
    print(f"{build()} documented operation profiles; no runtime publication.")
