#!/usr/bin/env python3
"""Publish current evidence without inheriting PASS from historical receipts."""
from pathlib import Path
import hashlib
import json

ROOT=Path(__file__).resolve().parents[1]
def read(name):
    return json.loads((ROOT/name).read_text())
def status(value):
    if value.get('status'): return value['status']
    if value.get('static_status'): return value['static_status']
    if value.get('ok') is not None: return 'PASS' if value['ok'] else 'FAIL'
    return 'PASS' if value.get('errors')==[] else 'UNKNOWN'
def count(value):
    v=value.get('checks_count',value.get('checks',0))
    return len(v) if isinstance(v,list) else v

def main():
    model=read('PUBLICATION_DATA.json')
    packet=read('validation/current_packet_expansion_20261124.json')
    recount=read('validation/recount_report.json')
    publication=read('validation/publication_checks.json')
    core=read('LMX_Fn_Receivers/tests/STATIC_REPORT.json')
    visual=read('validation/visual_review_expansion_20261124.json')
    julia=read('examples/julia_comparison/validation/check_report.json')
    haskell=read('examples/haskell_comparision/validation/check_receipt.json')
    sbcl=read('examples/SBCL_comparison/validation/workflow_source_checks.json')
    perl=read('examples/perl_comparison/validation/client_tests.json')
    baseline=read('validation/expansion_baseline_20261124.json')['base_archive']
    model_hash=hashlib.sha256((ROOT/'PUBLICATION_DATA.json').read_bytes()).hexdigest()
    expected_files=len(model['documents'])+len(model['mirrors'])
    artifacts=[]
    for name in ['validation/pdf_generation_20261123.json','validation/workbook_publication_20261123.json']:
        receipt=read(name); errors=[]
        if receipt['source_sha256']!=model_hash: errors.append('model hash mismatch')
        if len(receipt['files'])!=expected_files: errors.append('document count mismatch')
        for row in receipt['files']:
            path=ROOT/row['file']
            wanted=row.get('sha256')
            if not path.is_file(): errors.append('missing '+row['file']);continue
            actual=hashlib.sha256(path.read_bytes()).hexdigest()
            if wanted and actual!=wanted: errors.append('hash '+row['file'])
            if row.get('byte_identical_to') and path.read_bytes()!=(ROOT/row['byte_identical_to']).read_bytes(): errors.append('mirror '+row['file'])
        artifacts.append({'receipt':name,'status':'PASS' if not errors else 'FAIL','files':len(receipt['files']),'errors':errors})
    for row in visual['files']:
        if hashlib.sha256((ROOT/row['file']).read_bytes()).hexdigest()!=row['sha256']:
            raise ValueError('Visual review is stale: '+row['file'])
    passed=all(status(r)=='PASS' for r in [packet,recount,publication,core,visual,julia,haskell,sbcl,perl]) and all(x['status']=='PASS' for x in artifacts)
    # Explicit status per evidence category, with execution limits retained.
    result={'edition':'2026-11-24','status':'PASS' if passed else 'FAIL',
            'source_model_sha256':model_hash,'source_packet':status(packet),
            'recount':status(recount),'publication':status(publication),'artifacts':artifacts,
            'visual_review':status(visual),'lmx_parser':'NOT_RUN','lmx_runtime':'NOT_RUN'}
    (ROOT/'validation/validation_overview_expansion_20261124.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    rows=[
      ('Весь текущий пакет',status(packet),f"{count(packet)} проверок; текущие исходники, зеркала и метрики",'validation/current_packet_expansion_20261124.json'),
      ('11 групп',status(recount),f"{recount['comparison_count']} записей, {recount['listing_count']} сравниваемых листингов",'validation/recount_report.json'),
      ('Ядро',status(core),f"{core['requested_receivers']} имён, {core['source_parts']} частей; ограниченная статическая проверка",'LMX_Fn_Receivers/tests/STATIC_REPORT.json'),
      ('Haskell',status(haskell),'24 модуля; 32 сохранённых LMX-файла; GHC и LMX NOT_RUN','examples/haskell_comparision/validation/check_receipt.json'),
      ('Julia',status(julia),f"{count(julia)} проверок, {julia['logical_cases_checked']} Python oracle cases; Julia NOT_RUN",'examples/julia_comparison/validation/check_report.json'),
      ('Perl',status(perl),f"{perl['executed_cases']} клиентских + {perl['implementation_executed_checks']} библиотечных проверок на настоящем Perl",'examples/perl_comparison/validation/client_tests.json'),
      ('SBCL',status(sbcl),f"{count(sbcl)} статических проверок; новые runtime cases NOT_RUN",'examples/SBCL_comparison/validation/workflow_source_checks.json'),
      ('PDF/XLSX',status(publication),f"{expected_files} PDF и {expected_files} XLSX; значения, формулы, цвета и подчёркивания",'validation/publication_checks.json'),
      ('Визуальная проверка',status(visual),'34 PDF-страницы и 32 листа XLSX просмотрены после рендера','validation/visual_review_expansion_20261124.json')]
    lines=['# Проверка дополнения — 24 ноября 2026 года',
      f"Основа: `{baseline['name']}`, SHA-256 `{baseline['sha256']}`. Текущие результаты ниже относятся к новым файлам и полному пересчёту. Предыдущие receipts сохраняют только свою историческую область; их PASS не переносится на новый код.",
      '## Текущие проверки',
      '| Область | Статус | Что проверено | Отчёт |\n| --- | --- | --- | --- |\n'+'\n'.join(f'| {label} | {state} | {scope} | [JSON]({url}) |' for label,state,scope,url in rows),
      '## Комплектность и размеры',
      f"В 11 группах: {recount['pattern_count']} паттерна, {recount['algorithm_count']} алгоритмов и {recount['implementation_count']} сравнений реализаций. Ещё 23 GoF-сравнения сохранены. Общая модель содержит {model['lmx_style_clients']} договоров с двумя LMX-формами / {model['lmx_style_listings']} полных измерений. В examples находятся 96 сценариев; 80 являются полными парами, 16 — реализованными аналогиями. Все 24 Haskell-сценария имеют контрольный код.",
      'Полный размер включает объявления, локальные пользовательские зависимости, комментарии внутри границы и Throws. Одна физическая общая часть включается ровно один раз в каждый использующий её полный листинг. Многочастные исходники перечислены в source_files. Совместимое поле LMX не является третьей сравниваемой формой.',
      'Все PDF/XLSX и текстовые таблицы используют [PUBLICATION_DATA.json](PUBLICATION_DATA.json). Зелёным подчёркнуты минимумы сопоставимой строки, включая равенства; обе формы LMX участвуют самостоятельно. Аналогии не участвуют в минимуме или сумме полных пар. Измерение размера не является измерением скорости или памяти.',
      '## Исполнение контрольных программ',
      'Алгоритмы 100–105: 1492 результата настоящих контрольных программ на фиксированных и генерируемых входах — PASS; [отчёт](10_algorithms/tests/validation.json). Для 106–108 выполнены C++ и предусмотренные JavaScript-контроли; Go NOT_RUN, потому что компилятор Go отсутствует. [Отчёт](11_state_and_simulation_patterns/tests/validation_results.json) сохраняет PARTIAL для общего набора и отдельные PASS выполненных сторон.',
      'Julia и SBCL не установлены; Python oracle Julia и статическая сверка SBCL не считаются запуском этих языков. GHC не установлен. Старые SBCL execution receipts не подтверждают изменённые клиентские листинги.',
      '## Парсер и doc_examples',
      'Настоящие LMX parser/runtime в данной среде не предоставлены. Новые и изменённые примеры имеют NOT_RUN. [Общий doc_examples](../../../tests/doc_examples/README.md) обновлён в прежнем формате src и TSV с дедупликацией кода, актуальными местами в документации и сохранением прежних результатов только для совпадающих текстов. Два случая parser-debt:21.12 сохраняются явно. Новые примеры стрелки включены в тот же каталог.',
      'Сигнатуры проверены относительно действующей нормы: [28 профилей](../ARROW_EXAMPLES.md). Объявления Model@ и int[] сохраняют постфиксную форму. Корень запускается как L3 Thread без DATA; имена примеров не вводят Main. Проверки документации и вспомогательные Python-модели не являются доказательством работы транслятора.',
      '## Замечания к исходной загрузке',
      '[Отдельный файл замечаний](../REVIEW_NOTES.md#author-review-20261124) различает исходную намеренную отсрочку пересчёта и актуальные проблемы текста. Repository JSON синхронизирован с уже проверенным .lm3 до регенерации. Две слишком широкие фразы о голом S оставлены как конкретное замечание к нормативной формулировке; правила графа не переопределялись.',
      '## Воспроизведение',
      'Исходные генераторы обновляют код/зеркала наборов. Затем refresh_examples_statistics.py, refresh_statistics.py --metadata-only, refresh_group_csv.py и build_publication_data.py --text создают текущие данные. publish_pdfs.py и publish_workbooks.mjs строят документы. recount_patterns.py, validate_current_packet.py и verify_publication.py проверяют их. Визуальная проверка выполняется отдельно после рендера; этот генератор сам её не заменяет. Объединение doc_examples описано в его README. Манифесты строятся последними.',
      '[Состав изменений](EXPANSION_2026-11-24.md) · [Статистика](STATISTICS_2026-11-22.md) · [Статистика examples](examples/STATISTICS.md).']
    (ROOT/'VALIDATION.md').write_text('\n\n'.join(lines)+'\n')
    print(json.dumps(result,ensure_ascii=False))
    return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
