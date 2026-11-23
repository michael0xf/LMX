#!/usr/bin/env python3
"""Render this suite from examples.json and canonical LMX roots."""
from pathlib import Path
import csv
import hashlib
import io
import json
import re

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ROOT.parents[1]
CORE = PATTERNS / "LMX_Fn_Receivers"
FENCE = chr(96) * 3

def metrics(code):
    return {"characters":len(code),
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

def write(path, text):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text,encoding="utf-8",newline="\n")

def block(lang,text):
    return FENCE+lang+"\n"+text+FENCE+"\n"

def count_table(first,second):
    a,b=metrics(first),metrics(second)
    return ("| Источник | Все символы | Без пробельных | Непустые строки |\n"
            "|---|---:|---:|---:|\n"
            f"| LMX | {a['characters']} | {a['nonwhitespace']} | {a['nonblank_lines']} |\n"
            f"| Perl | {b['characters']} | {b['nonwhitespace']} | {b['nonblank_lines']} |\n")

def main():
    data=json.loads((ROOT/"examples.json").read_text())
    rows=[]
    coverage={}
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
        dependencies.update(entry["foreign_dependencies"])
        write(ROOT/entry["lmx_file"],entry["lmx"])
        write(ROOT/entry["foreign_file"],entry["foreign"])
        entry["counts"]={"lmx":metrics(entry["lmx"]),"foreign":metrics(entry["foreign"])}
        pairs=["- "+name+": "+", ".join(f"[{p}](library_comparisons/{p}_comparision.md)" for p in coverage.get(name,[])) for name in entry["core_functions"]]
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
            parts.extend(["## Другой подход: "+alt["approach"]+"\n",block(alt["language"].lower(),alt["code"])])
        parts+=["## Проверка\n","Perl запущен: [отчёт](validation/client_tests.json). LMX: **NOT_RUN**.\n",
            "## Первичные источники\n","\n".join("- <"+u+">" for u in entry["sources"])+"\n"]
        write(ROOT/f"{entry['id']}_comparision.md","\n".join(parts))
        for lang,key in [("LMX","lmx"),("Perl","foreign")]:
            rows.append({"scope":"client","id":entry["id"],"title":entry["title"],"language":lang,**metrics(entry[key])})
    write(ROOT/"examples.json",json.dumps(data,ensure_ascii=False,indent=2)+"\n")
    buffer=io.StringIO()
    writer=csv.DictWriter(buffer,fieldnames=["scope","id","title","language","characters","nonwhitespace","nonblank_lines"])
    writer.writeheader();writer.writerows(rows)
    write(ROOT/"statistics.csv",buffer.getvalue())
    totals={scope:{lang:{key:sum(r[key] for r in rows if r["scope"]==scope and r["language"]==lang) for key in ("characters","nonwhitespace","nonblank_lines")} for lang in ("LMX","Perl")} for scope in ("client","implementation")}
    write(ROOT/"statistics.json",json.dumps({"suite":"perl","edition":data["edition"],"examples":len(data["examples"]),"implementations":len(data["implementations"]),"totals":totals,"rows":rows},ensure_ascii=False,indent=2)+"\n")
    cover={"coverage":coverage,"cases":{e["id"]:e["implementation_pairs"] for e in data["examples"]},
        "missing":sorted({f for e in data["examples"] for f in e["core_functions"] if f not in coverage}),
        "syntax_profile":"Pattern/TextView constructors and expression operands: PI07; declaration, copying, indexing, yield and scalar arithmetic: base language.",
        "foreign_dependencies":sorted(dependencies)}
    write(ROOT/"validation/library_coverage.json",json.dumps(cover,ensure_ascii=False,indent=2)+"\n")
    table="| Пример | Сценарий | LMX без пробельных | Perl без пробельных |\n|---|---|---:|---:|\n"
    for ex in data["examples"]:
        table+=f"| [{ex['id']}]({ex['id']}_comparision.md) | {ex['title']} | {ex['counts']['lmx']['nonwhitespace']} | {ex['counts']['foreign']['nonwhitespace']} |\n"
    readme=["# LMX и Perl: 24 характерных сценария\n",
        "Дата: 2026-11-23. Самостоятельный набор дополняет текущие примеры архива. Реальный runtime: Perl 5.40.1 / List::Util 1.63. LMX не исполнен.\n",
        "## Договор сравнения\n",
        "Списки/map/grep, накопления, срезы, splice, сортировка, уникальность, хеши и автовивификация, текст/regex, замыкания, итератор и освобождение ресурса. В каждом файле одинаковая задача, поля данных, входы и результаты. Функции определений примера — часть листинга, не скрытая зависимость.\n",
        "Клиенты Perl используют настоящие CORE/stdlib/List::Util. Полные сравнительные реализации лежат в library_comparisons и никогда ими не импортируются. LMX вызывает операции ядра напрямую. Новые sort/unique описаны в [CORE_PERL_EXAMPLES](../../LMX_Fn_Receivers/CORE_PERL_EXAMPLES.md).\n",
        "## Статистика\n",
        "Метрика: Unicode code points, все символы и отдельно без whitespace, плюс непустые строки. Комментарии внутри выбранного кода входят в счётчик. Harness и объяснения не входят. Клиентские листинги и библиотечные реализации — две отдельные совокупности. Счётчик не измеряет скорость или объём runtime.\n",
        table,
        "[Markdown](LMX_Comparison_Perl.md) · [PDF](LMX_Comparison_Perl.pdf) · [XLSX](LMX_Comparison_Perl.xlsx) · [CSV](statistics.csv) · [JSON](statistics.json).\n",
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
    write(ROOT/"LMX_Comparison_Perl.md","# Сводное сравнение LMX / Perl\n\n"+table+"\nМетодика и ограничения: [README](README.md). Реализации библиотек считаются отдельно.\n")
    design=["# Группы характерных сценариев Perl\n"]
    for category in dict.fromkeys(e["category"] for e in data["examples"]):
        design+=["## "+category+"\n"]+[f"- [{e['id']}. {e['title']}]({e['id']}_comparision.md): {e['contract']}" for e in data["examples"] if e["category"]==category]+[""]
    write(ROOT/"LMX_Design_Patterns.Perl.md","\n".join(design))
    print(json.dumps({"examples":len(data["examples"]),"implementations":len(data["implementations"]),"missing_coverage":cover["missing"],"totals":totals},ensure_ascii=False))

if __name__=="__main__":
    main()
