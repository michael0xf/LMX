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
from throws_metrics import measure_throws

def metrics(code):
    effects = measure_throws(code, PATTERNS)
    return {"without_complex_throws_characters":effects["without_complex_throws_characters"],
            "complex_throws_removed_characters":effects["removed_characters"],
            "characters":len(code),
            "nonwhitespace":sum(not c.isspace() for c in code),
            "nonblank_lines":sum(bool(s.strip()) for s in code.splitlines())}

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
    found = {}
    for path in sorted((CORE / 'src').rglob('*.lmx')):
        lines = path.read_text().splitlines(keepends=True)
        starts = []
        for i, line in enumerate(lines):
            match = re.match(r'^(?:independent:\s*)?((?:Fx|Rx)\w*)\s*(?:::|:)', line)
            if match:
                starts.append((i, match.group(1)))
        for pos, (start, name) in enumerate(starts):
            stop = starts[pos + 1][0] if pos + 1 < len(starts) else len(lines)
            body = lines[start:stop]
            while body and (not body[-1].strip() or body[-1].lstrip().startswith('#')):
                body.pop()
            if name in found:
                raise ValueError('Duplicate production root: ' + name)
            found[name] = {'code': ''.join(body).strip() + '\n', 'source': path.relative_to(CORE).as_posix()}
    return found

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

def public_roots(available):
    aliases = {m[1]: m[2] for m in re.finditer(r'^\s*@:\s+(\w+)\s+((?:Fx|Rx)\w+)\\\w+', (CORE / 'src/public.lmx').read_text(), re.M)}
    # New source can be reviewed before root exports are regenerated. Resolve
    # only its real unambiguous method, never a fabricated comparison component.
    for name, body in available.items():
        for method in re.findall(r'^    ([a-z][A-Za-z0-9]*):\s*$', body['code'], re.M):
            if method not in aliases:
                candidates = [n for n, b in available.items() if re.search(r'^    ' + re.escape(method) + r':\s*$', b['code'], re.M)]
                if len(candidates) == 1:
                    aliases[method] = name
    return aliases

def write(path, text):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text,encoding="utf-8",newline="\n")

def block(lang,text):
    return FENCE+lang+"\n"+text+FENCE+"\n"

def count_table(first,second):
    a,b=metrics(first),metrics(second)
    return ("| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |\n"
            "|---|---:|---:|---:|---:|\n"
            f"| LMX | {a['characters']} | {a['nonwhitespace']} | {a['without_complex_throws_characters']} | {a['nonblank_lines']} |\n"
            f"| Perl | {b['characters']} | {b['nonwhitespace']} | {b['without_complex_throws_characters']} | {b['nonblank_lines']} |\n\n"
            "Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.\n")

def main():
    data=json.loads((ROOT/"examples.json").read_text())
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
    dependencies=set()
    for entry in data["examples"]:
        entry["lmx_file"]=f"source/lmx/{entry['id']}.lm3"
        entry["foreign_file"]=f"source/perl/{entry['id']}.pl"
        entry["implementation_pairs"]={name:coverage.get(name,[]) for name in entry["core_functions"]}
        entry["core_sources"]={}
        for name in entry["core_functions"]:
            if name not in aliases or aliases[name] not in available:
                raise ValueError(entry["id"] + ": unresolved core source " + name)
            owner=aliases[name]; needed,external=closure([owner],available);all_defs.update(needed)
            entry["core_sources"][name]={"root":owner,"source":"../../LMX_Fn_Receivers/"+available[owner]["source"],"sha256":hashlib.sha256(available[owner]["code"].encode()).hexdigest(),"all_definitions":sorted(needed),"external_boundaries":sorted(external),"comparison_pairs":coverage.get(name,[])}
        dependencies.update(entry["foreign_dependencies"])
        write(ROOT/entry["lmx_file"],entry["lmx"])
        write(ROOT/entry["foreign_file"],entry["foreign"])
        entry["counts"]={"lmx":metrics(entry["lmx"]),"foreign":metrics(entry["foreign"])}
        pairs=[]
        for name in entry["core_functions"]:
            if coverage.get(name):
                pairs.append("- "+name+": "+", ".join(f"[{p}](library_comparisons/{p}_comparision.md)" for p in coverage[name]))
            else:
                pairs.append("- "+name+": [полное тело ядра]("+entry["core_sources"][name]["source"]+"); [транзитивные зависимости](library_comparisons/shared_dependencies.lmx). Отдельная Perl-пара этой операции не написана.")
        parts=[f"# {entry['id']}. {entry['title']}\n","## Общий договор\n",entry["contract"]+"\n",entry.get("notes","")+"\n",
            "## Вход и ожидаемый результат\n",block("json",json.dumps({"arguments":entry["inputs"],"result":entry["expected"]},ensure_ascii=False,indent=2)+"\n"),
            "Дополнительные границы находятся в test_cases канонического [examples.json](examples.json); harness исключён из размера кода.\n",
            "## Размер выбранного варианта\n",count_table(entry["lmx"],entry["foreign"]),
            "Учитываются полные листинги, директивы, комментарии и обработка ошибок. Встроенное ядро не добавляется к каждому клиенту; его реализации считаются отдельно.\n",
            "## LMX\n",f"[Исходник]({entry['lmx_file']}).\n",block("lmx",entry["lmx"]),
            "## Perl\n",f"[Исходник]({entry['foreign_file']}).\n",block("perl",entry["foreign"]),
            "## Отдельные реализации\n","\n".join(pairs)+"\n" if pairs else "Только базовые средства языка и определения предметного объекта примера; отдельного библиотечного импорта нет.\n",
            "Штатные средства Perl: "+", ".join(entry["foreign_dependencies"])+".\n"]
        if entry.get("syntax_dependencies"):
            parts.append("Построение Pattern/TextView: "+", ".join(entry["syntax_dependencies"])+". Общий строитель regex-профиля отдельно показан в [PI07](library_comparisons/PI07_comparision.md).\n")
        for alt in entry.get("alternatives",[]):
            parts.extend(["## Другой подход: "+alt["approach"]+"\n", "Полный вариант: "+str(metrics(alt["code"])["nonwhitespace"])+" символов без пробельных; без сложного Throws: "+str(metrics(alt["code"])["without_complex_throws_characters"])+". Локальный helper и весь сценарий входят в счёт.\n",block(alt["language"].lower(),alt["code"])])
        parts+=["## Проверка\n","Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.\n",
            "## Первичные источники\n","\n".join("- <"+u+">" for u in entry["sources"])+"\n"]
        write(ROOT/f"{entry['id']}_comparision.md","\n".join(parts))
        for lang,key in [("LMX","lmx"),("Perl","foreign")]:
            rows.append({"scope":"client","id":entry["id"],"title":entry["title"],"language":lang,**metrics(entry[key])})
    shared=all_defs-primary_defs
    shared_code="\n".join(available[name]["code"] for name in sorted(shared))
    write(ROOT/"library_comparisons/shared_dependencies.lmx",shared_code)
    dependency_report={"date":"2026-11-23","component_dependencies":dependency_rows,"definitions":[{"name":name,"source":"../../LMX_Fn_Receivers/"+available[name]["source"],"sha256":hashlib.sha256(available[name]["code"].encode()).hexdigest(),**metrics(available[name]["code"])} for name in sorted(all_defs)],"unique_definitions":len(all_defs),"unique_lmx_total":metrics("\n".join(available[name]["code"] for name in sorted(all_defs))),"shared_not_in_primary":metrics(shared_code),"unpaired_functions":sorted({name for entry in data["examples"] for name in entry["core_functions"] if not coverage.get(name)}),"runtime_implementation_measured":False,"note":"Real core definitions and transitive shared bodies; no missing foreign comparison is presented as an existing PI pair. Existing FxKernel/sys boundaries remain external."}
    write(ROOT/"validation/implementation_dependencies.json",json.dumps(dependency_report,ensure_ascii=False,indent=2)+"\n")
    write(ROOT/"examples.json",json.dumps(data,ensure_ascii=False,indent=2)+"\n")
    buffer=io.StringIO()
    writer=csv.DictWriter(buffer,fieldnames=["scope","id","title","language","characters","nonwhitespace","without_complex_throws_characters","complex_throws_removed_characters","nonblank_lines"])
    writer.writeheader();writer.writerows(rows)
    write(ROOT/"statistics.csv",buffer.getvalue())
    totals={scope:{lang:{key:sum(r[key] for r in rows if r["scope"]==scope and r["language"]==lang) for key in ("characters","nonwhitespace","without_complex_throws_characters","complex_throws_removed_characters","nonblank_lines")} for lang in ("LMX","Perl")} for scope in ("client","implementation")}
    write(ROOT/"statistics.json",json.dumps({"suite":"perl","edition":data["edition"],"examples":len(data["examples"]),"implementations":len(data["implementations"]),"totals":totals,"shared_lmx":dependency_report["shared_not_in_primary"],"unique_lmx_implementation":dependency_report["unique_lmx_total"],"rows":rows},ensure_ascii=False,indent=2)+"\n")
    cover={"coverage":coverage,"cases":{e["id"]:e["implementation_pairs"] for e in data["examples"]},
        "missing":sorted({f for e in data["examples"] for f in e["core_functions"] if f not in aliases}),
        "unpaired_functions":dependency_report["unpaired_functions"],
        "canonical_sources":{e["id"]:e["core_sources"] for e in data["examples"]},
        "coverage_policy":"Known core bodies without a real foreign implementation pair are linked and counted as unpaired; no fabricated PI mapping.",
        "syntax_profile":"Pattern/TextView constructors and expression operands: PI07; declaration, copying, indexing, yield and scalar arithmetic: base language.",
        "foreign_dependencies":sorted(dependencies)}
    write(ROOT/"validation/library_coverage.json",json.dumps(cover,ensure_ascii=False,indent=2)+"\n")
    table="| Пример | Сценарий | LMX без пробельных | LMX без сложного Throws | Perl без пробельных | Perl без сложного Throws |\n|---|---|---:|---:|---:|---:|\n"
    for ex in data["examples"]:
        table+=f"| [{ex['id']}]({ex['id']}_comparision.md) | {ex['title']} | {ex['counts']['lmx']['nonwhitespace']} | {ex['counts']['lmx']['without_complex_throws_characters']} | {ex['counts']['foreign']['nonwhitespace']} | {ex['counts']['foreign']['without_complex_throws_characters']} |\n"
    total_table="| Слой | LMX полный | LMX без сложного Throws | Perl полный | Perl без сложного Throws |\n| --- | ---: | ---: | ---: | ---: |\n"
    for scope,label in [("client","Клиенты"),("implementation","Основные реализации PI01–PI07")]:
        a,b=totals[scope]["LMX"],totals[scope]["Perl"]
        total_table+=f"| {label} | {a['nonwhitespace']} | {a['without_complex_throws_characters']} | {b['nonwhitespace']} | {b['without_complex_throws_characters']} |\n"
    for field,label in [("shared_not_in_primary","Общие LMX-тела вне PI-листингов"),("unique_lmx_total","Все уникальные LMX-тела реализаций")]:
        a=dependency_report[field]
        total_table+=f"| {label} | {a['nonwhitespace']} | {a['without_complex_throws_characters']} | — | — |\n"
    readme=["# LMX и Perl: 24 характерных сценария\n",
        "Дата: 2026-11-23. Самостоятельный набор дополняет текущие примеры архива. Реальный runtime: Perl 5.40.1 / List::Util 1.63. LMX не исполнен.\n",
        "## Договор сравнения\n",
        "Списки/map/grep, накопления, срезы, splice, сортировка, уникальность, хеши и автовивификация, текст/regex, замыкания, итератор и освобождение ресурса. В каждом файле одинаковая задача, поля данных, входы и результаты. Функции определений примера — часть листинга, не скрытая зависимость.\n",
        "Клиенты Perl используют настоящие CORE/stdlib/List::Util. Полные сравнительные реализации лежат в library_comparisons и никогда ими не импортируются. LMX вызывает операции ядра напрямую. Новые sort/unique описаны в [CORE_PERL_EXAMPLES](../../LMX_Fn_Receivers/CORE_PERL_EXAMPLES.md).\n",
        "## Статистика\n",
        "Дополнительная колонка «Без сложного Throws» сохраняет заголовок и первый синтаксический аргумент Throws; только последующие аргументы исключены из дополнительного счётчика. copy(Throws) и прочие ссылки остаются полностью, общий банк считается один раз в зависимостях. Полные счётчики и исходники не меняются. Явный Throws/copy(Throws) — преимущество LMX: точный контракт отказов виден в коде; ради размера эти записи не сокращаются.\n",
        "Метрика: Unicode code points, все символы и отдельно без whitespace, плюс непустые строки. Комментарии внутри выбранного кода входят в счётчик. Harness и объяснения не входят. Клиентские листинги и библиотечные реализации — две отдельные совокупности. Счётчик не измеряет скорость или объём runtime.\n",
        total_table,
        "В таблицах ниже и выше числа обозначают непробельные Unicode-символы. Последняя строка — уникальная сумма LMX-реализаций, а не ещё одно слагаемое к двум предыдущим. Чужой runtime и невыполненные иностранные пары не получают нулевую цену.\n",
        table,
        "[Markdown](LMX_Comparison_Perl.md) · [PDF](LMX_Comparison_Perl.pdf) · [XLSX](LMX_Comparison_Perl.xlsx) · [CSV](statistics.csv) · [JSON](statistics.json).\n",
        "[Полные общие зависимости](library_comparisons/shared_dependencies.lmx) и [их уникальный счётчик](validation/implementation_dependencies.json) включают новые repeatText/translate/collect и фактические зависимости copy: Fx...; отсутствие отдельной иностранной пары явно отмечено как unpaired_functions.\n",
        "Однострочных дубликатов альтернатив нет. Если нужен новый вариант, сохраняется только реально другой подход с тем же договором; кратчайший допустимый становится основным.\n",
        "## Проверки и ограничения\n",
        "- [Тесты клиентов Perl](validation/client_tests.json).\n- [Тесты реализаций](validation/implementation_tests.json).\n- [Покрытие core-функций](validation/library_coverage.json).\n- [Проверки текста LMX](validation/source_checks.json).\n",
        "LMX **NOT_RUN**: нет доступного исполнителя. Текстовая проверка не доказывает связывание имён, типы или работу ядра. Regex-клиенты используют ASCII и byteText; история повторных захватов, Unicode и все детали движка не объявляются автоматически эквивалентными. Различия uniq/unique, splice и пустого split описаны и проверены.\n",
        "Все примеры синхронны. Чтобы асинхронно выполнить операцию целиком, достаточно post на метод владельца Message; собственный фоновый runtime в эти библиотеки не добавлен. Post отдельной работы не продлевает срок действия ресурса bracket.\n",
        "## Воспроизведение\n",
        block("sh","python tools/rebuild.py\npython tools/validate.py\n"),
        "validate запускает клиентские и реализационные тесты Perl, проверяет completion-report и актуальность извлечённых LMX-исходников. При необходимости отдельный harness доступен как tools/test_implementations.pl.\n",
        "Редактируются examples.json и канонические LMX-модули. Генератор обновляет источники, SHA-256, Markdown и статистику; PDF/XLSX строит общая сборка архива.\n"]
    write(ROOT/"README.md","\n".join(readme))
    write(ROOT/"LMX_Comparison_Perl.md","# Сводное сравнение LMX / Perl\n\n"+total_table+"\n"+table+"\nМетодика и ограничения: [README](README.md). Реализации библиотек считаются отдельно.\n")
    design=["# Группы характерных сценариев Perl\n"]
    for category in dict.fromkeys(e["category"] for e in data["examples"]):
        design+=["## "+category+"\n"]+[f"- [{e['id']}. {e['title']}]({e['id']}_comparision.md): {e['contract']}" for e in data["examples"] if e["category"]==category]+[""]
    write(ROOT/"LMX_Design_Patterns.Perl.md","\n".join(design))
    throws_report={"method":"Keep Throws head and first syntactic argument; retain copy references; full source is unchanged.","listings":{item["id"]:measure_throws(item["lmx"],PATTERNS) for item in data["examples"]+data["implementations"]},"shared":measure_throws(shared_code,PATTERNS)}
    write(ROOT/"validation/throws_metrics.json",json.dumps(throws_report,ensure_ascii=False,indent=2)+"\n")
    print(json.dumps({"examples":len(data["examples"]),"implementations":len(data["implementations"]),"missing_coverage":cover["missing"],"totals":totals},ensure_ascii=False))

if __name__=="__main__":
    main()
