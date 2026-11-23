#!/usr/bin/env python3
"""Render this suite from examples.json and canonical LMX roots."""
from pathlib import Path
import csv
import hashlib
import io
import json
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ROOT.parents[1]
CORE = PATTERNS / "LMX_Fn_Receivers"
FENCE = chr(96) * 3
sys.path.insert(0, str(PATTERNS / "tools"))
from lmx_style_variants import get_variants, validate_variants
from lmx_style_suite_reports import prepare as prepare_style, rows_for, client_markdown, count_table as complete_count_table, write_overview, write_csv
from lmx_execution_contract import apply_execution_contract
from canonical_operations import definitions, public_roots as catalog_roots, selected_operations

def metrics(code):
    return {"characters":len(code),"nonwhitespace":sum(not c.isspace() for c in code),"nonblank_lines":sum(bool(s.strip()) for s in code.splitlines())}

def root_blocks(path, names):
    lines = path.read_text().splitlines(keepends=True)
    starts = []
    for i,line in enumerate(lines):
        m = re.match(r"^(?:independent:\s*)?([A-Za-z_]\w*)\s*(?:::|:)", line)
        if m:
            starts.append((i,m.group(1)))
    blocks = {}
    for pos,(start,name) in enumerate(starts):
        stop = starts[pos+1][0] if pos+1 < len(starts) else len(lines)
        body = lines[start:stop]
        while body and (not body[-1].strip() or body[-1].lstrip().startswith("#")):
            body.pop()
        blocks[name] = "".join(body).strip()+"\n"
    missing=set(names)-set(blocks)
    if missing:
        raise ValueError(f"{path}: missing canonical roots {sorted(missing)}")
    return "\n".join(blocks[name] for name in names)

def production():
    return definitions(CORE)

def refs(code, available=None):
    # Follow actual qualified roots, model heads, copy/merge DATA streams and
    # ready Structure values. Plain failure labels in throws banks are not calls.
    clean = '\n'.join(line.split('#', 1)[0] for line in code.splitlines())
    found = set(re.findall(r'\b((?:Fx|Rx)\w+)(?=\\|@)', clean))
    found.update(re.findall(r'\b(?:copy|merge|import)\s*(?:\(|:)\s*((?:Fx|Rx)\w+)', clean))
    if available is not None:
        throws_indent = None
        for line in clean.splitlines():
            if not line.strip():
                continue
            indent = len(line) - len(line.lstrip())
            if throws_indent is not None and indent <= throws_indent:
                throws_indent = None
            if line.lstrip().startswith('throws:'):
                throws_indent = indent
                continue
            if throws_indent is not None or line.lstrip().startswith('throw:'):
                continue
            found.update(set(re.findall(r'\b(?:Fx|Rx)\w+\b', line)) & set(available))
    return found

def closure(names, available):
    result, external, stack = set(), set(), list(names)
    while stack:
        name = stack.pop()
        if name in result:
            continue
        if name not in available:
            external.add(name)
            continue
        result.add(name)
        if name != 'FxThrows':
            stack.extend(refs(available[name]['code'], available) - result)
    return result, external

def public_roots(available, families=None):
    return catalog_roots(CORE, available, families)

def write(path, text):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text,encoding="utf-8",newline="\n")

def block(lang,text):
    return FENCE+lang+"\n"+text+FENCE+"\n"

def count_table(first,second):
    return complete_count_table([("LMX",first),("Perl",second)])

def main():
    data=apply_execution_contract(json.loads((ROOT/"examples.json").read_text()))
    rows=[]
    coverage={}
    available=production(); aliases=public_roots(available)
    all_defs=set(); primary_defs=set(); dependency_rows=[]
    for impl in data["implementations"]:
        parts=[]; fingerprints=[]
        for source in impl.get("lmx_extract",[]):
            path=CORE/"src"/source["file"]
            text=root_blocks(path,source["roots"])
            parts.append(text)
            fingerprints.append({"file":str(path.relative_to(PATTERNS.parent)),
                "roots":source["roots"],"file_sha256":hashlib.sha256(path.read_bytes()).hexdigest(),
                "extract_sha256":hashlib.sha256(text.encode()).hexdigest()})
        if parts:
            impl["lmx"]="\n".join(parts).rstrip()+"\n"
        owners=[name for source in impl.get("lmx_extract",[]) for name in source["roots"]]
        needed,external=closure(owners,available)
        all_defs.update(needed);primary_defs.update(owners)
        dependency_rows.append({"id":impl["id"],"primary_definitions":owners,"all_definitions":sorted(needed),"external_boundaries":sorted(external)})
        impl["shared_lmx_definitions"]=sorted(needed-set(owners))
        impl["canonical_sources"]=fingerprints
        impl["source_files"]=[x["file"] for x in fingerprints]
        impl["lmx_file"]=f"library_comparisons/source/lmx/{impl['id']}.lmx"
        impl["foreign_file"]=f"library_comparisons/source/perl/{impl['id']}.pm"
        write(ROOT/impl["lmx_file"],impl["lmx"])
        write(ROOT/impl["foreign_file"],impl["foreign"])
        for name in impl["core_functions"]:
            coverage.setdefault(name,[]).append(impl["id"])
        parts=[f"# {impl['id']}. {impl['title']}\n",impl["contract"]+"\n",
            "Это отдельное сравнение реализации. Клиенты Perl **не импортируют** этот модуль: они используют настоящий CORE/List::Util. LMX вызывает предлагаемое ядро.\n",
            "## Граница реализации\n",impl.get("boundary","")+"\n",
            "## Размер\n",count_table(impl["lmx"],impl["foreign"]),
            "## LMX\n",f"[Исходник](source/lmx/{impl['id']}.lmx). Корни извлекаются из канонических модулей; SHA-256 фиксируется в examples.json.\n",
            block("lmx",impl["lmx"]),"## Perl\n",f"[Исходник](source/perl/{impl['id']}.pm).\n",block("perl",impl["foreign"]),
            "## Проверка и ограничения\n",impl.get("limitations","")+"\n",
            "Запуск Perl: [отчёт](../validation/implementation_tests.json). LMX: **NOT_RUN**; проверка текста не подменяет запуск.\n",
            "## Первичные источники\n","\n".join("- <"+u+">" for u in impl["sources"])+"\n"]
        write(ROOT/"library_comparisons"/f"{impl['id']}_comparision.md","\n".join(parts))
        for lang,key in [("LMX","lmx"),("Perl","foreign")]:
            rows.append({"scope":"implementation","id":impl["id"],"title":impl["title"],"language":lang,**metrics(impl[key])})

    dependencies=set(); comparison_rows=[]
    for entry in data["examples"]:
        prepare_style(entry,ROOT)
        aliases=public_roots(available,entry.get("core_families"))
        entry["lmx_file"]=entry["lmx_variants"]["functional"]["source_file"]
        entry["foreign_file"]=f"source/perl/{entry['id']}.pl"
        entry["implementation_pairs"]={name:coverage.get(name,[]) for name in entry["core_functions"]}
        entry["core_sources"]={}
        for name in entry["core_functions"]:
            if name not in aliases or aliases[name] not in available:raise ValueError(entry["id"]+": unresolved core "+name)
            owner=aliases[name];needed,external=closure([owner],available);all_defs.update(needed)
            entry["core_sources"][name]={"root":owner,"source":"../../LMX_Fn_Receivers/"+available[owner]["source"],"sha256":hashlib.sha256(available[owner]["code"].encode()).hexdigest(),"all_definitions":sorted(needed),"external_boundaries":sorted(external),"comparison_pairs":coverage.get(name,[])}
        for _,variant in get_variants(entry):
            needed,_=closure(refs(variant["code"],available),available)
            all_defs.update(needed)
        dependencies.update(entry["foreign_dependencies"])
        write(ROOT/entry["foreign_file"],entry["foreign"])
        entry["counts"]={"lmx":metrics(entry["lmx"]),"foreign":metrics(entry["foreign"])}
        pairs=[]
        for name in entry["core_functions"]:
            if coverage.get(name):pairs.append("- "+name+": "+", ".join(f"[{ident}](library_comparisons/{ident}_comparision.md)" for ident in coverage[name]))
            else:pairs.append("- "+name+": [полное тело ядра]("+entry["core_sources"][name]["source"]+"); [общие зависимости](library_comparisons/shared_dependencies.lmx).")
        write(ROOT/f"{entry['id']}_comparision.md",client_markdown(entry,"Perl","\n".join(pairs),"notes",
            "Perl-клиенты проверяет [действительный harness](validation/client_tests.json). LMX: **NOT_RUN**; обе формы проверяются как исходники, без заявления runtime-приёмки."))
        comparison_rows.extend(rows_for(entry,"Perl"))
        for lang,key in [("LMX","lmx"),("Perl","foreign")]:
            rows.append({"scope":"client","id":entry["id"],"title":entry["title"],"language":lang,**metrics(entry[key])})
    shared=all_defs-primary_defs
    shared_code="\n".join(available[name]["code"] for name in sorted(shared))
    write(ROOT/"library_comparisons/shared_dependencies.lmx",shared_code)
    dependency_report={"date":"2026-11-23","component_dependencies":dependency_rows,"definitions":[{"name":name,"source":"../../LMX_Fn_Receivers/"+available[name]["source"],"sha256":hashlib.sha256(available[name]["code"].encode()).hexdigest(),**metrics(available[name]["code"])} for name in sorted(all_defs)],"unique_definitions":len(all_defs),"unique_lmx_total":metrics("\n".join(available[name]["code"] for name in sorted(all_defs))),"shared_not_in_primary":metrics(shared_code),"unpaired_functions":sorted({name for entry in data["examples"] for name in entry["core_functions"] if not coverage.get(name)}),"runtime_implementation_measured":False,"note":"Real core definitions and transitive shared bodies; no missing foreign comparison is presented as an existing PI pair. Existing FxKernel/sys boundaries remain external."}
    write(ROOT/"validation/implementation_dependencies.json",json.dumps(dependency_report,ensure_ascii=False,indent=2)+"\n")
    write(ROOT/"examples.json",json.dumps(data,ensure_ascii=False,indent=2)+"\n")

    write_csv(ROOT,data,"Perl")
    totals={scope:{lang:{key:sum(r[key] for r in rows if r["scope"]==scope and r["language"]==lang) for key in ("characters","nonwhitespace","nonblank_lines")} for lang in ("LMX","Perl")} for scope in ("client","implementation")}
    style_totals=write_overview(ROOT,data,"Perl",
        "[Единые библиотечные реализации](library_comparisons/README.md) PI01–PI07 и [общие зависимости](validation/implementation_dependencies.json) учитываются отдельно.")
    write(ROOT/"statistics.json",json.dumps({"suite":"perl","edition":data["edition"],"examples":len(data["examples"]),"implementations":len(data["implementations"]),"legacy_lmx_role":"functional compatibility mirror only","totals":totals,"style_totals":style_totals,"shared_lmx":dependency_report["shared_not_in_primary"],"unique_lmx_implementation":dependency_report["unique_lmx_total"],"rows":rows,"comparison_rows":comparison_rows},ensure_ascii=False,indent=2)+"\n")
    cover={"coverage":coverage,"cases":{e["id"]:e["implementation_pairs"] for e in data["examples"]},"missing":sorted({f for e in data["examples"] for f in e["core_functions"] if f not in aliases}),"unpaired_functions":dependency_report["unpaired_functions"],"canonical_sources":{e["id"]:e["core_sources"] for e in data["examples"]},"coverage_policy":"One canonical implementation shared by both client styles; unpaired foreign implementations remain explicit.","foreign_dependencies":sorted(dependencies)}
    write(ROOT/"validation/library_coverage.json",json.dumps(cover,ensure_ascii=False,indent=2)+"\n")
    design=["# Группы характерных сценариев Perl\n"]
    for category in dict.fromkeys(e["category"] for e in data["examples"]):
        design+=["## "+category+"\n"]+[f"- [{e['id']}. {e['title']}]({e['id']}_comparision.md): {e['contract']}" for e in data["examples"] if e["category"]==category]+[""]
    write(ROOT/"LMX_Design_Patterns.Perl.md","\n".join(design))
    (ROOT/"validation/throws_metrics.json").unlink(missing_ok=True)
    print(json.dumps({"examples":len(data["examples"]),"lmx_client_variants":len(comparison_rows)-len(data["examples"]),"implementations":len(data["implementations"]),"missing_coverage":cover["missing"],"style_totals":style_totals},ensure_ascii=False))

if __name__=="__main__":
    main()
