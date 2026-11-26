#!/usr/bin/env python3
"""Publish common operation implementations from the current canonical LMX.

Foreign implementations keep their stated domain profiles. Source copies are
publication mirrors, never an independent implementation of a core algorithm.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import sys
sys.dont_write_bytecode = True
from canonical_operations import definitions as canonical_definitions
ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "LMX_Fn_Receivers"
SELECT = {
    93: ["FxPipe"],
    94: ["FxFindFirst"],
    95: ["FxAllOfTypeToken", "FxAllOfState", "FxAllOfEngine", "FxAllOf"],
    96: ["FxEquals"],
    97: ["FxRetryValue"],
}
POLICY = """Http503:
    int: status
    int: attempt
    return: int
    retryOn:
        return: status = 503
"""


def blocks():
    return canonical_definitions(LIB)

def closure(names, definitions):
    seen = set()
    pending = list(names)
    while pending:
        name = pending.pop()
        if name in seen or name not in definitions:
            continue
        seen.add(name)
        if name == "FxThrows":
            continue
        code = "\n".join(line.split("#",1)[0] for line in definitions[name]["code"].splitlines())
        refs = set(re.findall(r"\b(?:Fx|Rx)[A-Za-z0-9_]+\b", code))
        pending.extend(refs - seen)
    return seen


def metric(text):
    return {"characters":sum(not c.isspace() for c in text),
            "sha256":hashlib.sha256(text.encode()).hexdigest(),
            "nonblank_lines":sum(bool(line.strip()) for line in text.splitlines())}


def save(path, data):
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n")


def sync_reviewed_hashes():
    path=ROOT/'validation/reviewed_source_changes_20261123.json'
    data=json.loads(path.read_text())
    records={row['id']:row for source in ROOT.glob('[0-9][0-9]_*/patterns.json') for row in json.loads(source.read_text())['patterns']}
    for section in ['shared_implementation_clients','shared_implementations']:
        for review in data[section]:
            row=records[review['id']]
            review.setdefault('uploaded_listing_sha256',dict(review['listing_sha256']))
            for listing in row['listings']:
                if listing['language']=='LMX':
                    review['listing_sha256']['LMX']=metric(listing['code'].strip()+'\n')['sha256']
            review['current_reason']='Canonical generic retry with explicit Http503 policy preserves the synchronous status503 profile. Foreign clients and helper source hashes are unchanged. Async retryPost remains a separate contract.'
            review['lmx_runtime_execution']='NOT_RUN'
    save(path,data)


def sync_extended(definitions):
    for path in sorted(ROOT.glob('*/extended_comparisons/*_generalized.json')):
        row=json.loads(path.read_text())
        listing=next(x for x in row['listings'] if x['language']=='LMX')
        names=re.findall(r'^((?:Fx|Rx)[A-Za-z0-9_]+):',listing['code'],re.M)
        if row['id']==93:names=[n for n in names if n!='FxPipe']
        missing=set(names)-set(definitions)
        if missing:raise ValueError(f'{path}: missing definitions {missing}')
        listing['code']='\n'.join(definitions[n]['code'] for n in names)
        row['lmx_runtime_execution']='NOT_RUN'
        row['implementation_sources']=[{'definition':n,'source':'../../LMX_Fn_Receivers/'+definitions[n]['source']} for n in names]
        row['lmx_notes_ru']='Точные общие определения '+', '.join(names)+' из текущего ядра. Общий договор сохраняет явно указанные типы, контекст вызова и отказы. Копия обновляется из единственного исходника; runtime LMX — NOT_RUN.'
        row['lmx_notes_en']='Exact common definitions '+', '.join(names)+' from the current core. This publication mirror preserves the stated type, context and failure contract; revised LMX runtime execution is NOT_RUN.'
        if row['id']==93:
            row['name']='Compose — generic implementation'
            row['summary_ru']='Общий compose строит callable outer(inner(...)); pipe применяет стадии к уже принятому значению.'
            row['summary_en']='Generic compose builds outer(inner(...)); pipe applies stages to an accepted value.'
            row['limits_ru']='Композиция строится без выполнения стадий. inner получает исходные входы, outer принимает один результат; итоговый тип и контекст сохраняются. Сравнение не является stream scheduler.'
        save(path,row)
        stem=path.stem
        (path.parent/'source/lmx'/(stem+'.lm3')).write_text(listing['code'])
        lines=[f"# {row['id']:03d}. {row['name']}: общий договор",'',
            'Действующие общие определения извлечены из единого ядра. Эта отдельная пара сохраняет свой договор; её размер не подменяет размер клиентского вызова.', '',
            '## Договор','',row.get('scenario_ru',''),'',row.get('expected_ru',''),'',row.get('limits_ru','')]
        extensions={'LMX':'lm3','Java':'java','Go':'go','Python':'py','C#':'cs'}
        folders={'LMX':'lmx','Java':'java','Go':'go','Python':'python','C#':'csharp'}
        tags={'LMX':'lmx','Java':'java','Go':'go','Python':'python','C#':'csharp'}
        for item in row['listings']:
            lang=item['language'];code=item['code'].strip()+'\n'
            lines += ['',f'## {lang}','','```'+tags[lang],code.rstrip(),'```','',f"[Исходник](source/{folders[lang]}/{stem}.{extensions[lang]})",'',row['lmx_notes_ru'] if lang=='LMX' else item.get('notes_ru','')]
        lines += ['','## Измерение отдельной реализации','','| Язык | Непробельные символы |','| --- | ---: |']
        for item in row['listings']:
            code=item['code'].strip()+'\n'
            lines += [f"| {item['language']} | {metric(code)['characters']} |"]
        main=path.stem.removesuffix('_generalized')+'_comparision.md'
        lines += ['','Полный текст каждого листинга включает все объявления, заголовки Throws, аргументы и ссылки; исключений из подсчёта нет.', '',f'[Основная пара](../{main}). [Единые формы](../../UNIFIED_OPERATIONS.md).','', 'Результаты языкового выполнения изменённых исходников не заявлены.']
        (path.parent/(path.stem+'_comparision.md')).write_text('\n'.join(lines)+'\n')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dependencies-only',action='store_true',
                        help='Refresh current dependency ledgers without changing examples or historical review receipts')
    args=parser.parse_args()
    definitions = blocks()
    ledger = []
    for path in sorted(ROOT.glob("[0-9][0-9]_*/patterns.json")):
        data = json.loads(path.read_text())
        changed = False
        for row in data["patterns"]:
            ident = row["id"]
            if ident not in SELECT:
                continue
            names = SELECT[ident]
            missing = set(names)-set(definitions)
            if missing:
                raise ValueError(f"{ident}: unavailable canonical definitions {sorted(missing)}")
            code = "\n".join(definitions[name]["code"] for name in names)
            if ident == 97:
                code += "\n"+POLICY
            listing = next(x for x in row["listings"] if x["language"]=="LMX")
            listing["code"] = code
            row["implementation_sources"] = [
                {"source":"../LMX_Fn_Receivers/"+definitions[name]["source"],"definition":name}
                for name in names]
            row["lmx_notes_ru"] = (
                "Точное текущее определение "+", ".join(names)+
                " извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; "
                "второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз "
                "в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся."
            )
            row["lmx_notes_en"] = (
                "The exact current "+", ".join(names)+
                " definitions are extracted from the common core. Clients use canonical names and explicit "
                "domain arguments. The dependency ledger accounts for shared definitions once; no local "
                "duplicate algorithm is introduced. The revised LMX source has not been executed."
            )
            if ident == 97:
                row["lmx_notes_ru"] += " Http503 — только профиль retryOn(status; attempt), а не второй цикл повторения."
                row["lmx_notes_en"] += " Http503 is only the retryOn(status; attempt) profile, not a second retry loop."
            listing["notes_ru"] = row["lmx_notes_ru"]
            listing["notes_en"] = row["lmx_notes_en"]
            row["limits_ru"] = (
                "LMX показывает общий алгоритм с фактическими типами и исходным контекстом. "
                "Контрольные реализации сохраняют явно указанный прикладной профиль. "
                "Сравнение одного профиля не означает одинакового охвата библиотек или скорости; "
                "для полной стоимости прибавляются общие зависимости и runtime каждого языка."
            )
            row["limits_en"] = (
                "LMX shows the common algorithm with actual types and original context. Foreign implementations "
                "retain the stated application profile. A comparison for one profile does not establish equal "
                "library coverage or speed; complete cost includes shared dependencies and each runtime."
            )
            row["summary_ru"] = {
                93:"Общий pipe применяет стадии к значению; его фактический тип может меняться между стадиями.",
                94:"Общий findFirst возвращает Maybe первого элемента по переданному предикату.",
                95:"Общий allOf строит callable произвольной совместимой сигнатуры с коротким замыканием.",
                96:"Общий equals сравнивает значения через явную проекцию и единое равенство.",
                97:"Общий retry сохраняет фактический результат и использует явные retryOn/delay/limit."
            }[ident]
            row["summary_en"] = {
                93:"Generic pipe applies stages to a value whose actual type may change between stages.",
                94:"Generic findFirst returns Maybe of the first element accepted by the supplied predicate.",
                95:"Generic allOf builds a short-circuit callable with the actual compatible signature.",
                96:"Generic equals applies an explicit projection and the shared equality dispatch.",
                97:"Generic retry preserves the actual result and uses explicit retryOn/delay/limit policies."
            }[ident]
            source = path.parent/"examples/lmx"/f"{ident:03d}_{row['slug']}.lm3"
            if args.dependencies_only:
                if source.read_text().strip()!=code.strip():
                    raise ValueError(f'{source}: canonical body changed; synchronize this comparison explicitly first')
            else:source.write_text(code)
            companions = {93:['FxPipeState','FxPipeEngine','FxPipeBuild'],97:['FxRetryValueState','FxRetryValueEngine','FxRetryBuild']}.get(ident,[])
            required = closure(names+companions,definitions)
            ledger.append({
                "id":ident,"primary_definitions":names,"source":source.relative_to(ROOT).as_posix(),
                "primary":metric(code),
                "shared_definitions":sorted(required-set(names)),
                "definitions":[{"name":name,**definitions[name],**metric(definitions[name]["code"])} for name in sorted(required)],
                "domain_profile":POLICY if ident==97 else "",
                "runtime_status":"NOT_RUN",
            })
            changed = True
        if changed and not args.dependencies_only:
            save(path,data)
    if not args.dependencies_only:
        sync_extended(definitions)
        sync_reviewed_hashes()
    save(ROOT/"validation/common_operation_dependencies.json",{"scope":"Current source accounting, not runtime execution","components":ledger})
    lines=[
        "# Общие реализации примеров и их зависимости",
        "",
        "Примеры 093–097 используют канонические определения одного ядра. Прикладные предикаты и проекции "
        "задают отдельный договор, но не повторяют общий алгоритм. Листинги в каталогах являются автоматически "
        "обновляемыми копиями для публикации. Источник каждой реализации указан ниже.",
        "",
        "| Пример | Общие определения | Размер первичного листинга, символы | Зависимости |",
        "| --- | --- | ---: | --- |",
    ]
    for row in ledger:
        sources=", ".join(f"[{name}](LMX_Fn_Receivers/{definitions[name]['source']})" for name in row["primary_definitions"])
        lines.append(f"| {row['id']:03d} | {sources} | {row['primary']['characters']} | {len(row['shared_definitions'])} определений |")
    lines += [
        "",
        "Полные исходники и контрольные суммы зависимостей находятся в [машинном реестре](validation/common_operation_dependencies.json). "
        "Каждое определение считается один раз внутри выбранного компонента. Между компонентами зависимости пересекаются.",
        "",
        "Полный конечный throws сохраняется и учитывается целиком: заголовки, все аргументы и ссылки на общий банк. "
        "Никакая часть объявления ошибок не исключается из подсчёта.",
        "",
        "Контрольные языки сохраняют опубликованные исходники и свой прикладной профиль. Это не сравнение полного "
        "охвата всех стандартных библиотек. Source accounting не заменяет исполнение: LMX runtime — NOT_RUN.",
        "",
        "Воспроизведение: python3 tools/sync_common_operation_examples.py, затем обычная регенерация публикаций и метрик.",
        "",
    ]
    (ROOT/"COMMON_OPERATION_DEPENDENCIES.md").write_text("\n".join(lines))
    print(json.dumps({"components":len(ledger),"runtime":"NOT_RUN"}))


if __name__ == "__main__":
    main()
