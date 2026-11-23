"""Render complete procedural/functional clients without changing their contracts."""
import csv
import json
from lmx_style_variants import STYLES, normalize, measure, write_sources, validate_variants, markdown_variants
from lmx_execution_contract import annotate_operation, ensure_startup_note

FENCE=chr(96)*3
LABELS={"procedural":"LMX процедурный","functional":"LMX функциональный"}

def block(language,code):
    return FENCE+language+"\n"+normalize(code)+FENCE+"\n"

def prepare(case,directory):
    annotate_operation(case)
    if set(case.get("lmx_variants",{}))!=set(STYLES):
        raise ValueError(case["id"]+": both complete LMX variants are required")
    for variant in case["lmx_variants"].values():
        variant["code"]=normalize(variant["code"])
        variant["metrics"]=measure(variant["code"])
    case["lmx"]=case["lmx_variants"]["functional"]["code"]
    if "source_files" in case:
        case["source_files"]["lmx"]=case["lmx_variants"]["functional"]["source_file"]
    if "lmx_file" in case:
        case["lmx_file"]=case["lmx_variants"]["functional"]["source_file"]
    write_sources(case,directory)
    errors=validate_variants(case,directory)
    if errors:raise ValueError(case["id"]+": "+"; ".join(errors))

def count_table(listings):
    text="| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |\n| --- | ---: | ---: | ---: |\n"
    for label,code in listings:
        m=measure(code)
        text+=f"| {label} | {m['characters']} | {m['characters_with_whitespace']} | {m['nonblank_lines']} |\n"
    return text

def client_table(case,foreign):
    return count_table([(LABELS[s],case["lmx_variants"][s]["code"]) for s in STYLES]+[(foreign,case["foreign"])])

def rows_for(case,foreign):
    rows=[]
    for style in STYLES:
        variant=case["lmx_variants"][style]
        rows.append({"id":case["id"],"scope":"client","language":LABELS[style],"style":style,
                     "contract_id":variant["contract_id"],"source_file":variant["source_file"],**variant["metrics"]})
    rows.append({"id":case["id"],"scope":"client","language":foreign,"style":"foreign",
                 "contract_id":case["id"],**measure(case["foreign"])})
    return rows

def write_csv(directory,data,foreign):
    """Publish both full clients and each common implementation exactly once."""
    fields=["scope","id","title","language","style","characters","characters_with_whitespace",
            "nonblank_lines","utf8_bytes","sha256"]
    rows=[]
    for case in data["examples"]:
        for row in rows_for(case,foreign):
            row["title"]=case["title"]
            rows.append({key:row[key] for key in fields})
    for item in data["implementations"]:
        for language,key in [("LMX","lmx"),(foreign,"foreign")]:
            rows.append({"scope":"implementation","id":item["id"],"title":item["title"],
                         "language":language,"style":"shared",**measure(item[key])})
    with (directory/"statistics.csv").open("w",newline="") as stream:
        writer=csv.DictWriter(stream,fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    return rows

def client_markdown(case,foreign,links="",notes_key="notes",runtime_note=""):
    notes=case.get(notes_key,"")
    common=case.get("style_note","")
    foreign_path=case.get("foreign_file",case.get("source_files",{}).get("foreign",""))
    source_link=f"[Полный исходник]({foreign_path}).\n\n" if foreign_path else ""
    sources="\n".join("- <"+u+">" for u in case.get("sources",[]))
    result=(f"# {case['id']}. {case['title']}\n\n## Общий наблюдаемый договор\n\n{case['contract']}\n\n"
            f"{common}\n\n{notes}\n\n## Вход и ожидаемое наблюдение\n\n"
            +block("json",json.dumps({"arguments":case["inputs"],"result":case["expected"]},ensure_ascii=False,indent=2))
            +"\n## Размер полных клиентов\n\n"+client_table(case,foreign)
            +"\nОбе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки "
             "на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.\n\n"
            +markdown_variants(case)
            +f"\n## {foreign}\n\n"+source_link+block(foreign.lower(),case["foreign"])
            +"\n## Общие библиотечные реализации\n\n"+(links or "Используются базовые операции языка; предметные определения приведены целиком.")
            +"\n\nТела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. "
             "Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.\n\n"
            +"## Проверка\n\n"+(runtime_note or "LMX: **NOT_RUN**. Проверка текста и независимый oracle не являются выполнением LMX.")
            +"\n\n## Первичные источники\n\n"+sources+"\n")
    return result

def summary(data,foreign):
    table=f"| Сценарий | LMX процедурный | LMX функциональный | {foreign} |\n| --- | ---: | ---: | ---: |\n"
    totals={s:0 for s in (*STYLES,"foreign")}
    for case in data["examples"]:
        counts={s:case["lmx_variants"][s]["metrics"]["characters"] for s in STYLES}
        counts["foreign"]=measure(case["foreign"])["characters"]
        for s,value in counts.items():totals[s]+=value
        table+=f"| [{case['id']}. {case['title']}]({case['id']}_comparision.md) | {counts['procedural']} | {counts['functional']} | {counts['foreign']} |\n"
    table+=f"| **Всего** | **{totals['procedural']}** | **{totals['functional']}** | **{totals['foreign']}** |\n"
    return table,totals

def write_overview(directory,data,foreign,implementation_note=""):
    table,totals=summary(data,foreign)
    intro=(f"# LMX и {foreign}: {len(data['examples'])} наблюдаемых договоров\n\n"
           "У каждого клиента опубликованы **две полные LMX-формы**: процедурная и функциональная. "
           "Процедурная показывает явный порядок, ветвления, циклы и изменение данных; функциональная "
           "использует общие операции ядра, Expression и короткие адаптивные формы. "
           "Обе сохраняют один наблюдаемый договор, включая порядок, отсутствие результата, профиль данных и эффекты.\n\n"
           "## Подсчёт\n\n"
           "Таблица содержит непробельные Unicode-символы полного исходника. Комментарии внутри кода, "
           "все объявления, обработчики и полные ссылки copy(target\\throws) считаются. "
           "Статистическая модификация Throws не применяется. Harness и объяснения в счётчик не входят. "
           "Подробные Throws остаются явным контрактом методов.\n\n"
           +table+"\n"+implementation_note+"\n\n"
           "## Источники и проверка\n\n"
           "Функциональные исходники находятся в source/lmx; процедурные — в source/lmx/procedural. "
           "examples.json хранит обе версии, один contract_id и независимые метрики/SHA-256. "
           "Старое поле lmx — только зеркало функциональной формы и не третий участник сравнения.\n\n"
           "Библиотечные реализации имеют один общий LMX-исходник. Их зависимости учитываются отдельно, "
           "без повторного включения тела ради каждого стиля. Foreign-исходники сохранены.\n\n"
           "**LMX runtime: NOT_RUN.** Статическая проверка и проверка ожидаемых значений не доказывают "
           "работу нового кода на LMX runtime. Проверяются обе формы; runtime-приёмка остаётся отдельным этапом.\n\n"
           "Редактируются examples.json и единые исходники ядра; tools/rebuild.py воспроизводит исходники, Markdown и метрики. "
           "Проверка suite выполняется tools/check.py для Julia и tools/validate.py для Perl. "
           "PDF/XLSX формирует общая сборка архива.\n")
    (directory/"README.md").write_text(ensure_startup_note(intro,"../../../LMX_semantics.en.md#source-entry-profiles"))
    (directory/f"LMX_Comparison_{foreign}.md").write_text(f"# Сводное сравнение LMX / {foreign}\n\n"+table+
        "\nВсе числа считают полные исходники. Оба LMX-варианта остаются отдельными колонками. "
        "Методика, единые библиотечные зависимости и ограничения: [README](README.md).\n")
    return totals
