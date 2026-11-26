#!/usr/bin/env python3
"""Summarize current evidence without invoking exporters, validators or runtimes.

Only VALIDATION.md and the overview for PUBLICATION_DATA.edition are written.
Prior execution receipts keep their recorded scope. An absent current revision
check is NOT_RUN, never replaced by a historical packet PASS.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MONTHS = ('января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
          'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path, optional=False):
    if optional and not path.is_file():
        return {'status': 'NOT_RUN', 'reason': 'Current receipt is absent.'}
    return json.loads(path.read_text(encoding='utf-8'))


def status(value):
    for key in ('status', 'static_status'):
        if value.get(key):
            return value[key]
    if 'ok' in value:
        return 'PASS' if value['ok'] else 'FAIL'
    return 'PASS' if value.get('errors') == [] else 'UNKNOWN'


def count(value):
    result = value.get('checks_count', value.get('checks', 0))
    return len(result) if isinstance(result, list) else result


def relative(path, root):
    return Path(os.path.relpath(path, root)).as_posix()


def receipt_evidence(root, name):
    path = root / name
    value = read(path, optional=True)
    evidence = {'receipt': name, 'status': status(value)}
    if path.is_file():
        evidence['sha256'] = digest(path)
    return value, evidence


def artifact_evidence(root, name, model_hash, expected):
    value, evidence = receipt_evidence(root, name)
    errors = []
    if not (root / name).is_file():
        evidence['errors'] = ['Current generation receipt is absent.']
        return evidence
    if value.get('source_sha256') != model_hash:
        errors.append('Publication model hash differs from generation receipt.')
    rows = value.get('files', [])
    if len(rows) != expected:
        errors.append('Published document count differs from current model.')
    for row in rows:
        path = root / row['file']
        if not path.is_file():
            errors.append('Missing file: ' + row['file'])
            continue
        if row.get('sha256') and row['sha256'] != digest(path):
            errors.append('Changed artifact: ' + row['file'])
        elif not row.get('sha256') and not row.get('byte_identical_to'):
            errors.append('Artifact has neither hash nor mirror identity: ' + row['file'])
        if row.get('byte_identical_to'):
            original = root / row['byte_identical_to']
            if not original.is_file() or path.read_bytes() != original.read_bytes():
                errors.append('Changed mirror: ' + row['file'])
    evidence.update(status='PASS' if not errors else 'FAIL', files=len(rows),
                    errors=errors,
                    current_edition_files=sum(row.get('generation_edition') == value.get('edition')
                                              for row in rows))
    return evidence


def find_revision(root, stamp, requested):
    if requested:
        candidate = Path(requested).expanduser()
        if not candidate.is_absolute():
            candidate = candidate if candidate.is_file() else root / candidate
        return candidate.resolve()
    candidates = [root / 'validation' / (prefix + stamp + '.json') for prefix in
                  ('current_revision_checks_', 'revision_checks_', 'current_revision_')]
    return next((path for path in candidates if path.is_file()), candidates[0])


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=ROOT,
                        help='patterns/ containing PUBLICATION_DATA.json')
    parser.add_argument('--revision-checks',
                        help='Optional current review JSON; absence is NOT_RUN')
    parser.add_argument('--check', action='store_true',
                        help='Compare expected overview/Markdown without writing')
    args = parser.parse_args(argv)
    root = args.root.resolve()
    model = read(root / 'PUBLICATION_DATA.json')
    edition = model['edition']
    year, month, day = map(int, edition.split('-'))
    stamp = edition.replace('-', '')
    edition_label = f'{day} {MONTHS[month - 1]} {year}'
    model_hash = digest(root / 'PUBLICATION_DATA.json')
    expected_files = len(model['documents']) + len(model['mirrors'])
    revision_path = find_revision(root, stamp, args.revision_checks)
    revision = read(revision_path, optional=True)
    revision_ref = relative(revision_path, root)
    revision_evidence = {'receipt': revision_ref, 'status': status(revision)}
    if revision_path.is_file():
        revision_evidence['sha256'] = digest(revision_path)
        revision_evidence['scope'] = revision.get('scope', 'Scope recorded by the supplied current review.')
        for key in ('registered_sources', 'registered_locations'):
            if key in revision:
                revision_evidence[key] = revision[key]
    else:
        revision_evidence['reason'] = 'Current whole-packet review was not provided; no earlier PASS is inherited.'
    documentation = revision.get('documentation_checker', {})
    historical_findings = documentation.get('unchanged_historical_findings', [])
    if documentation:
        revision_evidence['documentation_whole_tree_status'] = documentation.get('whole_tree_status', 'NOT_RUN')
        revision_evidence['unchanged_historical_findings'] = len(historical_findings)
        revision_evidence['new_documentation_issues'] = len(documentation.get('new_issues', []))
    if not revision_path.is_file():
        revision_scope = 'Отчёт текущей ревизии отсутствует; прежний PASS не переносится'
    elif 'registered_sources' in revision and 'registered_locations' in revision:
        revision_scope = (f"Текущие изменённые/новые материалы; {revision['registered_sources']} исходника "
                          f"и {revision['registered_locations']} мест, связанные evidence receipts")
    elif count(revision):
        revision_scope = f"{count(revision)} проверок в области переданного текущего отчёта"
    else:
        revision_scope = 'Текущие изменённые/новые материалы; состав и границы указаны в отчёте'

    inputs = {
        'recount': 'validation/recount_report.json',
        'publication': 'validation/publication_checks.json',
        'core': 'LMX_Fn_Receivers/tests/STATIC_REPORT.json',
        'visual_review': f'validation/visual_review_{stamp}.json',
        'operand_depth': f'LMX_Fn_Receivers/tests/operand_depth_source_{stamp}.json',
        'julia': 'examples/julia_comparison/validation/check_report.json',
        'haskell': 'examples/haskell_comparision/validation/check_receipt.json',
        'sbcl': 'examples/SBCL_comparison/validation/workflow_source_checks.json',
        'perl': 'examples/perl_comparison/validation/final_consistency.json',
    }
    values, evidence = {}, {}
    for key, name in inputs.items():
        values[key], evidence[key] = receipt_evidence(root, name)
    source_errors = []
    for key in ('publication', 'visual_review'):
        if evidence[key]['status'] != 'NOT_RUN' and values[key].get('source_sha256') != model_hash:
            source_errors.append(key + ': publication model hash differs.')
            evidence[key]['status'] = 'FAIL'
    visual = values['visual_review']
    publication_path = root / inputs['publication']
    # A later read-only verifier run may refresh its timestamp without changing
    # any reviewed artifact. Keep that provenance visible; artifact/model hashes
    # below, rather than the timestamp of another receipt, govern staleness.
    if visual.get('automated_report_sha256') and publication_path.is_file():
        evidence['visual_review']['automated_receipt_refreshed_since_review'] = (
            visual['automated_report_sha256'] != digest(publication_path))
    for row in visual.get('files', []):
        path = root / row['file']
        if not path.is_file() or digest(path) != row['sha256']:
            source_errors.append('Visual review is stale: ' + row['file'])
            evidence['visual_review']['status'] = 'FAIL'
    artifacts = [artifact_evidence(root, f'validation/{prefix}_{stamp}.json', model_hash, expected_files)
                 for prefix in ('pdf_generation', 'workbook_publication')]
    examples = read(root / 'examples/STATISTICS.json')
    counts = examples['counts']
    if examples.get('edition') != edition:
        source_errors.append('Examples statistics edition differs from publication model.')

    historical_names = [
        'examples/perl_comparison/validation/client_tests.json',
        'examples/SBCL_comparison/validation/common_lisp.json',
        'examples/SBCL_comparison/validation/implementation_execution.json',
        '10_algorithms/tests/validation.json',
        '11_state_and_simulation_patterns/tests/validation_results.json',
    ]
    historical = []
    for name in historical_names:
        path = root / name
        if not path.is_file():
            continue
        old = read(path)
        historical.append({'receipt': name, 'sha256': digest(path),
                           'recorded_status': status(old),
                           'use': 'Prior recorded execution only; not re-executed or promoted to current runtime PASS.'})
    checks = [item['status'] for item in evidence.values()] + [item['status'] for item in artifacts]
    current_status = ('FAIL' if source_errors or any(s == 'FAIL' for s in checks)
                      else 'PASS' if all(s == 'PASS' for s in checks) else 'PARTIAL')
    overall = ('FAIL' if current_status == 'FAIL' or status(revision) == 'FAIL'
               else 'PASS' if current_status == 'PASS' and status(revision) == 'PASS' else 'PARTIAL')
    result = {
        'edition': edition, 'status': overall,
        'scope': 'Current source/document/publication evidence only; not language execution.',
        'source_model_sha256': model_hash, 'source_packet': revision_evidence,
        'source_and_publication_status': current_status, 'evidence': evidence,
        'artifacts': artifacts, 'errors': source_errors,
        'counts': {'documents': len(model['documents']), 'mirrors': len(model['mirrors']),
                   'pdf_files': expected_files, 'xlsx_files': expected_files,
                   'lmx_style_clients': model['lmx_style_clients'],
                   'lmx_style_listings': model['lmx_style_listings'],
                   'examples': counts},
        'current_execution': {name: 'NOT_RUN' for name in
                              ('lmx_parser', 'lmx_translator', 'lmx_runtime',
                               'pd01_production_integration', 'julia', 'haskell', 'sbcl',
                               'perl', 'native_excel')},
        'previous_receipts': historical,
        'dynamic_type_postfix': revision.get('dynamic_type_postfix', {'production_acceptance': 'NOT_RUN'}),
        'execution_note': 'This summary generator invokes no compiler, interpreter, language harness or publication exporter. Historical executions retain only their recorded scope.',
    }
    recount, core = values['recount'], values['core']
    publication = values['publication'].get('summary', {})
    rows = [
        ('Общий текущий пакет', revision_evidence['status'],
         revision_scope, revision_ref),
        ('Группы сравнений', evidence['recount']['status'],
         f"{recount.get('group_count', '?')} групп, {recount.get('comparison_count', '?')} сравнений, {recount.get('listing_count', '?')} полных листингов", inputs['recount']),
        ('Ядро', evidence['core']['status'],
         f"{core.get('requested_receivers', '?')} имён, {core.get('source_parts', '?')} частей, {len(core.get('provider_methods', []))} интеграционных границ; ограниченная статическая проверка", inputs['core']),
        ('Depth ABI', evidence['operand_depth']['status'],
         f"{count(values['operand_depth'])} проверок исходников и метаданных; PD01 production NOT_RUN", inputs['operand_depth']),
        ('Haskell', evidence['haskell']['status'],
         f"{values['haskell'].get('haskell_modules_checked', '?')} модулей, {values['haskell'].get('lmx_source_files_checked', '?')} LMX-файла; исходники, исполнение NOT_RUN", inputs['haskell']),
        ('Julia', evidence['julia']['status'],
         f"{count(values['julia'])} проверок, {values['julia'].get('logical_cases_checked', '?')} случаев Python oracle; Julia и LMX NOT_RUN", inputs['julia']),
        ('Perl', evidence['perl']['status'],
         f"{values['perl'].get('checked_comparisons', '?')} сравнений: исходники, JSON, Markdown и размеры; текущий runtime NOT_RUN", inputs['perl']),
        ('SBCL', evidence['sbcl']['status'],
         f"{count(values['sbcl'])} проверок исходников и размеров; SBCL и LMX NOT_RUN", inputs['sbcl']),
        ('PDF/XLSX', evidence['publication']['status'],
         f"{publication.get('verified_pdfs', '?')}/{expected_files} PDF и {publication.get('verified_workbooks', '?')}/{expected_files} XLSX; {publication.get('numeric_count_cells', '?')} числовых размеров, формулы, минимумы и равенства", inputs['publication']),
        ('Визуальная проверка', evidence['visual_review']['status'],
         f"Выборочно просмотрены {visual.get('visually_reviewed_pdf_pages', '?')} PDF-страниц и {visual.get('visually_reviewed_xlsx_sheets', '?')} полных листов; прочая проверка отдельно обозначена в отчёте", inputs['visual_review']),
    ]
    lines = [
        '# Проверка документации и публикаций — ' + edition_label,
        f"Текущая модель: [PUBLICATION_DATA.json](PUBLICATION_DATA.json), SHA-256 `{model_hash}`. Статус исходников и публикаций: **{current_status}**; статус текущих изменённых/новых материалов переданной ревизии: **{overall}**. PASS относится к указанной текущей области и перечисленным проверкам, а не ко всем историческим записям дерева. Production LMX parser, translator, runtime и интеграция PD01 имеют **NOT_RUN**.",
        '## Текущие проверки',
        '| Область | Статус | Что проверено | Отчёт |\n| --- | --- | --- | --- |\n' + '\n'.join(
            f'| {label} | {state} | {scope} | [JSON]({url}) |' for label, state, scope, url in rows),
        '## Граница текущей ревизии и исторические записи',
        (f"Общий обход дерева документации сохраняет статус **{documentation.get('whole_tree_status', 'NOT_RUN')}**: "
         f"в нём остаются **{len(historical_findings)}** прежних наблюдений в исторических файлах, побайтно совпадающих с базовым архивом. "
         f"Новых замечаний в текущем отчёте: **{len(documentation.get('new_issues', []))}**. "
         f"Их точные пути, SHA-256 и область проверки сохранены в [отчёте ревизии]({revision_ref}). "
         'Исторические записи не переписаны для получения общего PASS; PASS текущей ревизии не отменяет результат обхода всего дерева.'
         if documentation else
         'Отдельная оценка исторического дерева текущим отчётом не предоставлена; она не выводится из PASS публикаций.'),
        (f"Формы {', '.join('`' + form + '`' for form in revision['dynamic_type_postfix'].get('forms', []))} "
         f"имеют область **{revision['dynamic_type_postfix'].get('scope', 'DOC_SPEC_ADDITION_ONLY')}** и production acceptance "
         f"**{revision['dynamic_type_postfix'].get('production_acceptance', 'NOT_RUN')}**. Описание синтаксиса не выдаётся за выполненную проверку его production-парсером."
         if revision.get('dynamic_type_postfix') else ''),
        '## Комплектность и измерения',
        f"Модель содержит **{model['lmx_style_clients']}** клиентских договоров и **{model['lmx_style_listings']}** измерений двух LMX-форм. В {len(model['suite_summaries'])} языковых наборах examples находятся **{counts['lmx_examples']}** сценариев и **{counts['lmx_style_listings']}** стилевых листингов; **{counts['complete_pairs']}** сценария образуют полные пары. Отдельно учтены **{counts['implementation_comparisons']}** сравнений общих реализаций. Это разные области подсчёта; они не складываются в число различных программ.",
        f"Публикация состоит из **{len(model['documents'])}** основных документов и **{len(model['mirrors'])}** зеркала: всего **{expected_files} PDF** и **{expected_files} XLSX**. В этой ревизии пересозданы {visual.get('updated_pdf_files', '?')} PDF и {visual.get('updated_xlsx_files', '?')} XLSX. Неизменённые файлы сохраняют исходную дату генерации в текущих receipts; их история не переписана.",
        'Полный размер включает все объявления, код в указанной границе, комментарии, Throws и ссылки copy. Обе формы LMX участвуют самостоятельно. Минимум сопоставимой строки подчёркнут зелёным; при равенстве отмечены все победители. Аналогии не становятся нулевым контрольным листингом и не входят в сумму полных пар. Размер исходника не измеряет скорость или память.',
        '## Публикации и визуальная область',
        f"[PDF receipt](validation/pdf_generation_{stamp}.json) и [XLSX receipt](validation/workbook_publication_{stamp}.json) содержат хеши готовых файлов и их действительную edition. [Проверка](validation/publication_checks.json) читает сериализованные XLSX и PDF: значения, формулы и кэш сумм, правила условного форматирования, реальные зелёные числа и подчёркивания. Artifact-tool пересчитывал формулы; запуск Microsoft Excel не заявляется.",
        f"[Визуальный отчёт](validation/visual_review_{stamp}.json) перечисляет конкретные просмотренные страницы и листы с хешами файлов и рендеров. Выборочная визуальная проверка не названа просмотром всех страниц. Проверки остальных страниц и их границ указаны отдельно.",
        '## Исполнение и предыдущие receipts',
        'Этот генератор только читает доказательства и обновляет сводку. Он не запускает LMX, Julia, Haskell, SBCL, Perl или сторонние компиляторы. Текущий Julia-отчёт проверяет исходники и Python oracle; это не исполнение Julia. Проверка формы или размера кода не подтверждает связывание, типизацию, parent-связи, время жизни или нативный ABI.',
        'Следующие прежние receipts сохранены отдельно. Записанный в них PASS не переносится на изменённый LMX-код или новые случаи исполнения:',
        '\n'.join(f"- [{row['receipt']}]({row['receipt']}) — записанный статус `{row['recorded_status']}`; прежняя область отчёта." for row in historical)
        or 'Предыдущие execution receipts в этом пакете не найдены.',
        '## Воспроизведение текущей сводки',
        'После синхронизации исходников и метаданных обновляют статистику и PUBLICATION_DATA. Экспорт выполняют только для реально затронутых сравнительных документов; затем отдельно проверяют готовые файлы и их рендеры. Эта команда не повторяет экспорт или широкие тесты:',
        f"```sh\npython -B tools/refresh_validation_report.py --revision-checks validation/current_revision_checks_{stamp}.json\n```",
        f"Команда запускается из spec/patterns. Путь --revision-checks может указывать на другой текущий отчёт. Без существующего текущего отчёта поле source_packet остаётся NOT_RUN и общий статус PARTIAL. Записываются только [VALIDATION.md](VALIDATION.md) и [validation_overview_{stamp}.json](validation/validation_overview_{stamp}.json); исторические receipts не изменяются. `--check` сравнивает эти два результата без записи.",
    ]
    outputs = {
        root / f'validation/validation_overview_{stamp}.json': json.dumps(result, ensure_ascii=False, indent=2) + '\n',
        root / 'VALIDATION.md': '\n\n'.join(lines) + '\n',
    }
    changed = []
    for path, text in outputs.items():
        if not path.exists() or path.read_text(encoding='utf-8') != text:
            changed.append(relative(path, root))
            if not args.check:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(text, encoding='utf-8')
    print(json.dumps({'edition': edition, 'status': overall,
                      'source_and_publication_status': current_status,
                      'source_packet': revision_evidence['status'],
                      'changed_files': changed, 'write': not args.check,
                      'errors': source_errors + [error for item in artifacts for error in item.get('errors', [])],
                      'production_lmx': 'NOT_RUN'}, ensure_ascii=False))
    return 1 if overall == 'FAIL' or (args.check and changed) else 0


if __name__ == '__main__':
    raise SystemExit(main())
