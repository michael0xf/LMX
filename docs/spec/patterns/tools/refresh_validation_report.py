#!/usr/bin/env python3
"""Publish current full-source checks without executing any language or inheriting stale QA."""
from collections import Counter
from pathlib import Path
import hashlib
import json
from packet_metadata import restoration_metadata

ROOT = Path(__file__).resolve().parents[1]


def read(relative, optional=False):
    path = ROOT/relative
    if optional and not path.exists():
        return None
    return json.loads(path.read_text())


def status(report):
    if report is None:
        return 'NOT_RECORDED'
    if report.get('errors'):
        return 'FAIL'
    if 'status' in report:
        return report['status']
    if 'ok' in report:
        return 'PASS' if report['ok'] else 'FAIL'
    if 'rows' in report:
        return 'PASS' if report['rows'] and all(not row.get('errors') and row.get('limited_source_status', 'PASS') == 'PASS' for row in report['rows']) else 'FAIL'
    return 'PASS' if 'errors' in report or 'checks' in report or 'files' in report else 'NOT_RECORDED'


def check_count(report):
    value = (report or {}).get('checks', (report or {}).get('checks_count', 0))
    return len(value) if isinstance(value, list) else value


def artifact_evidence(relative, model_sha, expected_count):
    report = read(relative, True)
    if report is None:
        return {'status': 'NOT_RECORDED', 'files': 0, 'hashes_current': 0, 'pdf': 0, 'xlsx': 0,
                'visual_receipt_status': 'NOT_RECORDED'}
    files = report.get('files', report.get('pdf_files', [])+report.get('xlsx_files', []))
    by_file = {entry['file']: entry for entry in files}
    current = 0
    for entry in files:
        path = ROOT/entry['file']
        expected = entry.get('sha256')
        mirror_valid = True
        if expected is None and entry.get('byte_identical_to'):
            reference_name = entry['byte_identical_to']
            reference = ROOT/reference_name
            expected = by_file.get(reference_name, {}).get('sha256')
            mirror_valid = (expected is not None and reference.is_file()
                            and hashlib.sha256(reference.read_bytes()).hexdigest() == expected)
        current += int(mirror_valid and expected is not None and path.is_file()
                       and hashlib.sha256(path.read_bytes()).hexdigest() == expected)
    model_current = report.get('source_sha256', model_sha) == model_sha
    ready = len(files) == expected_count and current == len(files) and model_current
    recorded = status(report)
    effective = recorded if ready else 'STALE / INCOMPLETE'
    signoff = report.get('visual_signoff', {})
    visual = signoff.get('status', 'NOT_RECORDED') if isinstance(signoff, dict) else str(signoff)
    return {'status': effective, 'reported_status': recorded, 'files': len(files),
            'hashes_current': current, 'model_hash_current': model_current,
            'pdf': sum(entry['file'].endswith('.pdf') for entry in files),
            'xlsx': sum(entry['file'].endswith('.xlsx') for entry in files),
            'pdf_pages': report.get('pdf_pages'),
            'visual_receipt_status': visual if ready else 'NOT_CURRENT'}


def main():
    provenance = restoration_metadata(ROOT)
    base = provenance['base_archive']
    reference = provenance.get('historical_provenance', {}).get('short_example_reference', {})
    recount = read('validation/recount_report.json')
    packet = read('validation/current_packet_20261123.json')
    core = read('LMX_Fn_Receivers/tests/STATIC_REPORT.json')
    functional = read('09_functional_computation/validation_2026-11-23.json')
    root_styles = read('examples/validation/style_variants.json')
    receiver_revision = read('examples/validation/receiver_revision.json')
    execution_contract = read('examples/validation/execution_contract_checks.json')
    julia = read('examples/julia_comparison/validation/check_report.json')
    perl_source = read('examples/perl_comparison/validation/source_checks.json')
    perl = read('examples/perl_comparison/validation/client_tests.json')
    perl_impl = read('examples/perl_comparison/validation/implementation_tests.json')
    sbcl = read('examples/SBCL_comparison/validation/common_lisp.json')
    sbcl_impl = read('examples/SBCL_comparison/validation/implementation_execution.json')
    sbcl_source = read('examples/SBCL_comparison/validation/source_checks.json')
    model = read('PUBLICATION_DATA.json')
    model_sha = hashlib.sha256((ROOT/'PUBLICATION_DATA.json').read_bytes()).hexdigest()
    case_statuses = Counter(case['comparison_status'] for case in model['cases'])
    catalog = read('LMX_Fn_Receivers/catalog.json')
    migrations = read('LMX_Fn_Receivers/CANONICAL_MIGRATION.json')
    variants = sum(len(entry.get('variants', [])) for entry in catalog)
    expected_files = len(model['documents']) + len(model.get('mirrors', []))
    pdfs = artifact_evidence('validation/pdf_generation_20261123.json', model_sha, expected_files)
    workbooks = artifact_evidence('validation/workbook_publication_20261123.json', model_sha, expected_files)
    artifacts = artifact_evidence('validation/artifact_review_20261123.json', model_sha, 2*expected_files)
    publication_checks = read('validation/publication_checks.json', True)
    publication_status = status(publication_checks)
    if publication_checks and publication_checks.get('source_sha256') != model_sha:
        publication_status = 'STALE'
    source_checks_ok = all(status(item) == 'PASS' for item in [recount, packet, core, functional, root_styles, receiver_revision, execution_contract, julia, perl_source, sbcl_source])
    model_ok = not model['errors'] and model['lmx_style_clients'] == 100 and model['lmx_style_listings'] == 200
    source_checks_ok = source_checks_ok and model_ok
    documents_ok = (all(item['status'] == 'PASS' for item in [pdfs, workbooks, artifacts])
                    and publication_status == 'PASS' and artifacts['visual_receipt_status'] == 'PASS')
    functional84 = next(case for case in model['cases'] if case['suite'] == 'functional' and case['id'] == '084')
    around = functional84['lmx_variants']
    lines = [
        '# Проверка текущей редакции — 23 ноября 2026 года', '',
        f"**Проверки исходников: {'PASS' if source_checks_ok else 'FAIL / требуется завершение указанных проверок'}.** Общий валидатор: {packet['checks_count']} проверок, {len(packet['errors'])} ошибок. **Публикация PDF/XLSX: {'PASS' if documents_ok else 'не завершена или отчёты требуют обновления'}.** Генератор читает отдельные receipts и проверяет их связь с текущими файлами; он не запускает языки или офисные приложения.", '',
        f"Текущий исходный архив — `{base['name']}`, SHA-256 `{base['sha256']}`. Его каталог проверяется относительно неизменяемой копии загруженных файлов. Историческая ссылка коротких примеров — `{reference.get('name', 'не указана')}`, SHA-256 `{reference.get('sha256', 'не указан')}`. Исторические отчёты не доказывают разбор или выполнение переработанных исходников.", '',
        '## Комплектность и границы', '',
        f"Девять групп содержат **{recount['pattern_count']} паттернов + {recount['implementation_count']} сравнений реализаций = {recount['comparison_count']} записей / {recount['listing_count']} сравниваемых листингов**. В прежних полях JSON остаётся {recount['compatibility_listing_count']} зеркал языковых записей; четыре дополнительных LMX-стиля относятся к клиентам 082–085. Совместимое поле LMX отражает функциональный исходник и не образует третьего сравниваемого стиля. [Пересчёт](validation/recount_report.json).", '',
        f"[Общая модель публикации](PUBLICATION_DATA.json) содержит **{model['lmx_style_clients']} клиентских контрактов и {model['lmx_style_listings']} полных LMX-измерений**: 24 исходных/Haskell, 24 Julia, 24 Perl, 24 SBCL и 4 сценария Haskell/Scala группы 09. Полных сопоставимых контрактов — {case_statuses['complete_pair']}; связанных аналогий — {case_statuses['related_analogy']}; LMX-only — {case_statuses['lmx_only']}. Аналогия или отсутствие иностранной программы не становится нулём в таблице и не участвует в сумме полных пар.", '',
        f"GoF-подборка содержит **23 сравнения / 184 листинга**. Две разрешённые правки LMX — Visitor и Abstract Factory — проверяются по сохранённым исходным и текущим хешам. Другие основные GoF-листинги и иностранные исходники сравниваются с загруженной базой. Всего отдельно зарегистрировано **{packet['summary']['implementation_comparisons_total']} сравнений общих реализаций**; библиотечные тела не размножаются ради стилевой пары. [Полный пакетный audit](validation/current_packet_20261123.json).", '',
        'Синхронные клиенты 039/045 используют общий компонент 097 во всех трёх языках. Они отмечены shared_implementation_client: показываются клиенты, общий helper один раз и полная сумма. Расширенные и асинхронные договоры описаны отдельно. Иностранные клиенты функционального набора используют средства своих языков; сравнительные библиотечные реализации не импортируются вместо них.', '',
        f"В 084 сравниваются обе полные формы: процедурная Around + Trace — {around['procedural']['characters']} символов, функциональный core-клиент — {around['functional']['characters']}. Они сохраняют acquisition/action/release и исходы ResourceFailure. Граница FxCallFailure обоснована замкнутым набором объявленных callback-ошибок этого сценария. [Разбор границы ошибок](09_functional_computation/review/084_failure_boundary.md).", '',
        '## Проверки исходников', '',
        '| Область | Результат | Область утверждения |', '| --- | --- | --- |',
        f"| Общий пакет | {status(packet)}; {packet['checks_count']} checks, {len(packet['errors'])} ошибок | Исходники, JSON/Markdown/CSV, обе полные стилевые метрики, каталог, миграции имён и зависимости |",
        f"| Девять групп | {status(recount)}; {recount['comparison_count']} записей /{recount['listing_count']} сравниваемых листингов | Полные числовые границы, точные fences, наборы файлов, таблицы и контейнеры PDF/XLSX |",
        f"| Клиенты Haskell/Scala 082–085 | {status(functional)}; {check_count(functional)} checks | Две записи, одинаковые observable contracts, callback/cleanup и одинарные реализации |",
        f"| Исходные 24/Haskell | {status(root_styles)}; {check_count(root_styles)} checks | {root_styles['compared_style_records']} стилевых метрик /{root_styles['unique_lmx_sources']} физических исходников; exact mirrors и postfix declarations |",
        f"| Guide и договоры исходных 24 | {status(receiver_revision)}; {check_count(receiver_revision)} checks | Оба стиля, все старые acceptance cases, обычные ошибки H09 и реальные Haskell imports |",
        f"| Запуск корня | {status(execution_contract)}; {check_count(execution_contract)} checks | R0 как обычный L3 Thread без DATA и пользовательских actuals; именованные операции после запуска, аргументы родителя сообщением |",
        f"| Ядро | {status(core)}; {core['requested_receivers']} имён /{core['source_parts']} частей | Экспорты, варианты, точные тела, ограниченные статические проверки |",
        f"| Julia | {status(julia)}; {check_count(julia)} checks, {julia.get('logical_cases_checked', 0)} Python oracle cases | Источники, метрики и ожидаемые результаты; Julia/LMX не запускаются |",
        f"| Perl sources | {status(perl_source)}; {len(perl_source.get('rows', []))} контрактов | Ограниченные source checks обеих записей и допустимых импортов |",
        f"| SBCL publication | {status(sbcl_source)}; {check_count(sbcl_source)} checks | Источники, ссылки, метрики и отдельно зарегистрированные execution receipts |", '',
        '[Основной результат](validation/current_packet_20261123.json), [пересчёт](validation/recount_report.json), [проверка четырёх клиентов](09_functional_computation/validation_2026-11-23.json), [проверка исходных 24](examples/validation/style_variants.json) и [guide/acceptance audit](examples/validation/receiver_revision.json) имеют собственные области. Эти проверки не являются парсером, проверкой типов или исполнением LMX.', '',
        '[Проверка контракта запуска](examples/validation/execution_contract_checks.json) сверяет текущие метаданные с единственным запуском от корня. [Проверка форм объявлений](../validation/type_declaration_checks.json) сверяет исходники и fenced-примеры с восемью авторскими формами. Результаты относятся к тексту и метаданным, а исполнение LMX остаётся NOT_RUN.', '',
        '## Отдельные выполнения контрольных языков', '',
        '| Среда | Receipt | Записанный результат |', '| --- | --- | --- |',
        f"| Perl clients | [client_tests.json](examples/perl_comparison/validation/client_tests.json) | {status(perl)}; {perl.get('executed_cases', 0)} случаев; {perl.get('runtime', '')} |",
        f"| Perl implementations | [implementation_tests.json](examples/perl_comparison/validation/implementation_tests.json) | {status(perl_impl)}; {perl_impl.get('executed_checks', 0)} проверок |",
        f"| Common Lisp clients | [common_lisp.json](examples/SBCL_comparison/validation/common_lisp.json) | {status(sbcl)}; {sbcl.get('passed', 0)} assertions; {sbcl.get('runtime', '')} |",
        f"| Common Lisp implementations | [implementation_execution.json](examples/SBCL_comparison/validation/implementation_execution.json) | {status(sbcl_impl)}; {sbcl_impl.get('checks', 0)} проверок |", '',
        'Это receipts отдельных запусков. Их чтение не считается новым исполнением. **Текущие LMX-исходники имеют parser_execution=NOT_RUN и runtime_execution=NOT_RUN; Julia, Haskell и Scala также не исполнялись этими проверками.** Проверенные Python oracle и иностранные программы не заменяют приёмку LMX. Парсер-проверка загруженного baseline относится только к прежним байтам.', '',
        '## Канонические операции и общие реализации', '',
        f"Каталог содержит **{len(catalog)} канонических публичных имён /{variants} вариантов семейств**. [Таблица миграций](LMX_Fn_Receivers/CANONICAL_MIGRATION.json) покрывает все {migrations['baseline_count']} публичных имени загруженной базы. Число канонических имён не вычисляется прибавлением исторических additions: переименования, объединения и новые варианты отражаются по отдельным API и семействам.", '',
        f"[Полный реестр](../CORE_FUNCTIONS.md) связывает имена, сигнатуры и источники. [Kernel requirements](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) фиксирует {len(core['provider_methods'])} существующих интеграционных входов. Стандартная библиотека содержит LMX-тела; производственный переводчик и native kernel здесь не поставляются.", '',
        f"В базовом наборе ядра подготовлено **{core['prepared_assertions']} assertions**; другие семейства содержат дополнительные acceptance cases. Подготовленные случаи и матрицы NOT_RUN не складываются с исполненными проверками. Generic results сохраняют фактическую запись результата, динамическая область и copy входят в действующий договор языка.", '',
        'Узлы с типизированной ссылкой используют postfix форму `Model@: p`, `int@: left`; массивы — `Model[]: arr`, `int[]: values`, включая именованные и безымянные объявления с начальным значением. Общее `@: value expression` остаётся отдельной допустимой формой. [Формы объявлений](../TYPE_DECLARATION_FORMS.md) и acceptance fixtures определяют положительные и отрицательные примеры.', '',
        '## Два стиля и одна полная метрика', '',
        'Процедурная запись показывает явные циклы, ветвления, мутации и прямые операции. Функциональная использует композицию, Expression и общие операции библиотеки. Оба стиля измеряются целиком: непробельные Unicode-символы, все объявления, комментарии внутри листинга и все Throws. Дополнительно фиксируются непустые строки, полные UTF-8-байты и SHA-256. Никакая часть списка ошибок не вычитается из сравнения.', '',
        'Если договор низкого уровня допускает одну общую минимальную форму, style_relation=same_minimal_form указывает оба измерения на один источник, а Markdown показывает одно тело с пояснением. Две одинаковые цифры сохраняются в таблице; выдуманная дополнительная обвязка не создаётся. При разных формах каждая имеет свой источник. Локальные implementations и пересекающиеся зависимости сохраняются один раз.', '',
        'Явные конечные ошибки и общий `Throws/copy(Throws)` по авторской оценке являются преимуществом LMX: видно, какой метод какие исходы порождает. `throws: copy(target\\throws)` переносит объявление вызываемого метода; дополнительные реальные отказы сохраняются. Эти записи полностью входят в обе метрики.', '',
        '## PDF, XLSX и актуальность свидетельств', '',
        '| Проверка | Текущее состояние | Связь с опубликованными байтами |', '| --- | --- | --- |',
        f"| [PDF generation](validation/pdf_generation_20261123.json) | {pdfs['status']} | {pdfs['hashes_current']}/{pdfs['files']} хешей текущие; ожидается {expected_files} PDF |",
        f"| [Workbook publication](validation/workbook_publication_20261123.json) | {workbooks['status']} | {workbooks['hashes_current']}/{workbooks['files']} хешей текущие; ожидается {expected_files} XLSX |",
        f"| [Serialized publication checks](validation/publication_checks.json) | {publication_status} | Источники, экспортированные значения, SUM/cache, правила и равные минимумы; source hash должен совпадать с текущей моделью |",
        f"| [Artifact review](validation/artifact_review_20261123.json) | {artifacts['status']} | {artifacts['hashes_current']}/{artifacts['files']} хешей текущие; visual receipt: {artifacts['visual_receipt_status']} |", '',
        'Зелёным отмечается минимальное полное число среди сравнимых колонок строки, включая оба LMX-стиля и все равные минимумы. Пустое значение, аналогия и отсутствующий контроль не становятся победителем. Общие реализации имеют отдельную единственную LMX-колонку. Формулы и форматирование проверяются в сериализованных XLSX; это не запуск native Excel.', '',
        'Проверка формул, цветов, подчеркиваний, границ страниц и визуальное чтение имеют отдельные receipts. Старый PASS не переносится на изменённый PDF, XLSX или PUBLICATION_DATA. Этот генератор сам не рендерит документы и не подписывает визуальную приёмку.', '',
        '[Проверка ссылок](validation/doc_links_20261123.json) обновляется после публикации. Финальные манифесты фиксируют фактические поставляемые файлы и их хеши. [Отчёт интеграции](../INTEGRATION_REPORT.md) описывает весь комплект.', '',
        '## Воспроизведение', '',
        'Сначала собираются каталог и LMX-исходники ядра. Затем синхронизируются общие реализации, dependencies и обе клиентские записи. После локальных source generators обновляются legacy compatibility statistics, затем tools/build_publication_data.py --text создаёт единую модель и общие текстовые таблицы. tools/publish_pdfs.py и tools/publish_workbooks.mjs формируют документы из этой модели. Recount, validate_current_packet, отдельные source/publication/artifact/link checks проверяют результат; этот отчёт и манифесты обновляются последними.', '',
        '- [Статистика паттернов](STATISTICS_2026-11-22.md) и [общие компоненты](LIBRARY_COMPONENTS.md).',
        '- [Все примеры](examples/STATISTICS.md) и [машинная модель](PUBLICATION_DATA.json).',
        '- [Julia](examples/julia_comparison/README.md), [Perl](examples/perl_comparison/README.md), [SBCL](examples/SBCL_comparison/README.md).', '',
    ]
    if packet['errors']:
        lines += ['## Незавершённые пакетные проверки', '']
        lines += ['- '+entry['check'] for entry in packet['errors']]
        lines.append('')
    (ROOT/'VALIDATION.md').write_text('\n'.join(lines))
    print(json.dumps({'current_validation': 'patterns/VALIDATION.md',
                      'source_status': 'PASS' if source_checks_ok else 'FAIL',
                      'documents_status': 'PASS' if documents_ok else 'INCOMPLETE',
                      'packet_checks': packet['checks_count'], 'packet_errors': len(packet['errors']),
                      'style_contracts': model['lmx_style_clients'], 'style_metrics': model['lmx_style_listings'],
                      'artifacts': artifacts}, ensure_ascii=False))


if __name__ == '__main__':
    main()
