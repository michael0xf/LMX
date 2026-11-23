#!/usr/bin/env python3
"""Publish current source checks and explicitly separate foreign execution receipts."""
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
    if 'status' in report:
        return report['status']
    if 'ok' in report:
        return 'PASS' if report['ok'] else 'FAIL'
    return 'PASS' if not report.get('errors') else 'FAIL'


def artifact_evidence():
    report = read('validation/artifact_review_20261123.json', True)
    if report is None:
        return {'status':'NOT_RECORDED','files':0,'hashes_current':0,'pdf':0,'xlsx':0}
    files = report.get('pdf_files', [])+report.get('xlsx_files', [])
    current = 0
    for entry in files:
        path = ROOT/entry['file']
        current += int(path.is_file() and hashlib.sha256(path.read_bytes()).hexdigest()==entry['sha256'])
    signoff = report.get('visual_signoff', {})
    return {'status':status(report),'files':len(files),'hashes_current':current,
            'pdf':len(report.get('pdf_files', [])),'xlsx':len(report.get('xlsx_files', [])),
            'pdf_pages':report.get('pdf_pages'),
            'visual_receipt_status':signoff.get('status','NOT_RECORDED') if isinstance(signoff,dict) else str(signoff)}


def main():
    provenance = restoration_metadata(ROOT)
    base = provenance['base_archive'];reference = provenance['short_example_reference']
    recount = read('validation/recount_report.json')
    packet = read('validation/current_packet_20261123.json')
    core = read('LMX_Fn_Receivers/tests/STATIC_REPORT.json')
    functional = read('09_functional_computation/validation_2026-11-23.json')
    examples = read('examples/STATISTICS.json');counts = examples['counts']
    julia = read('examples/julia_comparison/validation/check_report.json')
    perl = read('examples/perl_comparison/validation/client_tests.json')
    perl_impl = read('examples/perl_comparison/validation/implementation_tests.json')
    sbcl = read('examples/SBCL_comparison/validation/common_lisp.json')
    sbcl_impl = read('examples/SBCL_comparison/validation/implementation_execution.json')
    sbcl_source = read('examples/SBCL_comparison/validation/source_checks.json')
    throws = read('validation/throws_metrics_20261123.json')
    artifacts = artifact_evidence()
    catalog = json.loads((ROOT/'LMX_Fn_Receivers/catalog.json').read_text())
    checks_ok = all(status(item)=='PASS' for item in [recount,packet,core,functional,julia,sbcl_source])
    lines = [
        '# Проверка текущей редакции — 23 ноября 2026 года', '',
        f"**Проверки исходников и публикации: {'PASS' if checks_ok else 'FAIL / требуется завершение указанных проверок'}.** Общий валидатор: {packet['checks_count']} проверок, {len(packet['errors'])} ошибок. Этот генератор читает сохранённые результаты; он не запускает LMX или контрольные языки.", '',
        f"Основа — `{base['name']}`, SHA-256 `{base['sha256']}`. Короткие примеры восстановлены по `{reference['name']}`, SHA-256 `{reference['sha256']}`. Нормативная спецификация 23-Nov остаётся основой. Исторические отчёты прежних редакций не доказывают выполнение текущих исходников.", '',
        '## Комплектность и границы', '',
        f"Девять групп содержат **{recount['pattern_count']} паттернов + {recount['implementation_count']} сравнений реализаций = {recount['comparison_count']} записей / {recount['listing_count']} основных листингов**. Отдельная GoF-подборка содержит **23 сравнения / 184 листинга**. В ней явно проверены две разрешённые правки LMX — Visitor и Abstract Factory; остальные основные листинги сохранены относительно 23-Nov.", '',
        f"В examples находятся **{counts['lmx_examples']} сценариев LMX**: по 24 исходных, Julia, Perl и SBCL. **Полных сопоставимых пар — {counts['complete_pairs']}**; аналогии и LMX-only случаи помечены отдельно и не получают выдуманного нулевого размера иностранной программы. Отдельно посчитаны **{counts['implementation_comparisons']} сравнений реализаций**.", '',
        'Синхронные клиенты 039/045 используют общий компонент 097 во всех трёх языках. Они отмечены `shared_implementation_client`; сводка содержит клиентов, весь helper один раз и полную сумму. Расширенные и асинхронные договоры сохранены отдельно. Стандартные иностранные клиенты функционального набора используют настоящие средства языка; собственные сравнительные реализации не импортируются вместо них.', '',
        'В 084 полный авторский Around + Trace сохранён альтернативой (709 символов); основной core-клиент занимает 586. Точный ResourceFailure в Haskell соответствует Scala и LMX. Удаление проверки имени FxCallFailure обосновано замкнутым набором объявленных callback-ошибок только этого примера. [Доказательство границы](09_functional_computation/review/084_failure_boundary.md).', '',
        '## Проверки исходников и публикации', '',
        '| Область | Результат | Область утверждения |', '| --- | --- | --- |',
        f"| Общий пакет | {packet['status']}; {packet['checks_count']} checks, {len(packet['errors'])} ошибок | Идентичности, точные зеркала источников/JSON/Markdown/CSV, экспортируемые имена, разрешённые source changes, полные зависимости |",
        f"| Девять групп | {status(recount)}; {recount['comparison_count']} записей / {recount['listing_count']} листингов | Числа, полнота листингов и дополнительная Throws-метрика |",
        f"| Функциональная группа | {status(functional)}; {functional['checks']} checks | Exact source mirrors, выбор полных вариантов, границы callback/cleanup и зависимости |",
        f"| Ядро | {status(core)}; {core['requested_receivers']} имён / {core['source_parts']} частей | Экспорты, тела, ограниченная проверка границ и внешних входов |",
        f"| Julia | {julia['status']}; {len(julia['checks'])} source checks, {julia['logical_cases_checked']} Python oracle cases | Источники и независимые ожидаемые результаты; Julia не запускалась |",
        f"| SBCL publication | {sbcl_source['status']}; {sbcl_source['checks']} checks | Источники, ссылки, числовые поля и отдельные receipts |", '',
        'Общий валидатор хранит [машинный результат](validation/current_packet_20261123.json). [recount](validation/recount_report.json) и [функциональные проверки](09_functional_computation/validation_2026-11-23.json) описывают свои области. Статическая проверка не является разбором, проверкой типов или исполнением LMX.', '',
        '## Отдельные выполненные foreign tests', '',
        '| Среда | Receipt | Результат |', '| --- | --- | --- |',
        f"| Perl clients | [client_tests.json](examples/perl_comparison/validation/client_tests.json) | {perl['status']}; {perl['executed_cases']} случаев; {perl['runtime']} |",
        f"| Perl implementations | [implementation_tests.json](examples/perl_comparison/validation/implementation_tests.json) | {perl_impl['status']}; {perl_impl['executed_checks']} проверок |",
        f"| Common Lisp clients | [common_lisp.json](examples/SBCL_comparison/validation/common_lisp.json) | {sbcl['status']}; {sbcl['passed']} assertions; {sbcl['runtime']} |",
        f"| Common Lisp implementations | [implementation_execution.json](examples/SBCL_comparison/validation/implementation_execution.json) | {sbcl_impl['status']}; {sbcl_impl['checks']} проверок |", '',
        'Это результаты отдельных запусков, записанные соответствующими наборами. Их чтение здесь не считается повторным исполнением. **LMX runtime отсутствует; LMX, Julia, Haskell и Scala в этих текущих проверках не исполнялись.** Python oracle и foreign tests не подменяют runtime-приёмку LMX.', '',
        '## Ядро и интеграция', '',
        f"Каталог содержит **{len(catalog)}** публичных имён: **{base['public_names']}** сохранены из 23-Nov, **{len(catalog)-base['public_names']}** добавлены в семейства functional, Optional/Result/object, Common Lisp, text и numeric. Числа получены из текущих метаданных. Исторические восемь дополнений к более ранней базе уже входят в исходные {base['public_names']}.", '',
        f"[Полный реестр](../CORE_FUNCTIONS.md) связывает публичные имена, сигнатуры и исходники. [KERNEL_REQUIREMENTS](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) фиксирует **{len(core['provider_methods'])} существующих интеграционных входов**. Стандартные дополнения не объявляют выдуманные providers реализованными. Нативный kernel не поставляется.", '',
        f"В базовом пакете ядра подготовлено **{core['prepared_assertions']} assertions**; отдельные семейства содержат дополнительные acceptance cases. Подготовленные случаи и матрицы NOT_RUN не складываются в число исполненных LMX-тестов. Для generic outputs используется настоящая запись результата, без обязательного дополнительного @-контейнера; динамическая область и copy остаются частью действующей семантики.", '',
        'Исходные конечные throws сохраняются в авторской записи; синхронизация проверяет объявления, не выбирает более короткое форматирование. Вызовы callback, обычные именованные отказы и системные/интеграционные выходы различаются. Указание source-level cleanup не выдаётся за Haskell mask/restore.', '',
        '## Полная и дополнительная метрики', '',
        'Основной размер — непробельные Unicode-символы полного выбранного листинга, включая обязательные поля, импорты, комментарии внутри границы и Throws. Основные отношения размеров вычисляются только по этой полной колонке. Дополнительно считаются непустые строки, UTF-8-байты и SHA-256.', '',
        'Явные конечные ошибки и общий `Throws/copy(Throws)` по авторской оценке являются преимуществом LMX: видно, какой метод какие исходы порождает. В колонке «без сложного Throws» остаются заголовок и первый написанный аргумент списка; все ссылки/copy считаются полностью, а общий банк — один раз в собственной границе, также с первым аргументом. Ничего из программы не удаляется и контракты не сокращаются.', '',
        f"Общий [расчёт по исходникам](validation/throws_metrics_20261123.json) содержит **{len(throws['sources'])} границ** с перечислением пропущенных при подсчёте аргументов, разрешённых ссылок и неопределённых случаев. Один [throws_metrics.py](tools/throws_metrics.py) используется всеми генераторами; отдельные наборы сохраняют собственные detailed reports.", '',
        '## PDF, XLSX и ссылки', '',
        f"Отдельный [artifact_review](validation/artifact_review_20261123.json) сейчас описывает {artifacts['pdf']} PDF и {artifacts['xlsx']} XLSX; текущим файлам соответствуют {artifacts['hashes_current']} из {artifacts['files']} сохранённых SHA-256. Записанная визуальная оценка: {artifacts.get('visual_receipt_status','NOT_RECORDED')}. Этот генератор не рендерит документы и не переносит старую визуальную оценку на новые байты. Готовность документов устанавливается отдельным обновлённым отчётом.", '',
        '[Проверка ссылок](validation/doc_links_20261123.json) имеет собственную дату, область и baseline. Она обновляется после окончательной публикации. Манифесты также пересобираются в самом конце и фиксируют реальные хеши поставляемых файлов.', '',
        '## Воспроизведение', '',
        'Сначала собираются каталог и исходники ядра. Затем обновляются клиенты, реализации, dependency ledgers и выбор основных вариантов; после этого — group/GoF/examples statistics, recount и validate_current_packet. PDF/XLSX и source/link/artifact checks выполняются отдельно. В конце обновляется этот отчёт и манифесты.', '',
        '- [Статистика паттернов](STATISTICS_2026-11-22.md) и [общие компоненты](LIBRARY_COMPONENTS.md).',
        '- [Статистика всех examples](examples/STATISTICS.md).',
        '- [Julia](examples/julia_comparison/README.md), [Perl](examples/perl_comparison/README.md), [SBCL](examples/SBCL_comparison/README.md).', '',
    ]
    if packet['errors']:
        lines += ['## Незавершённые проверки', '']
        lines += ['- '+entry['check'] for entry in packet['errors']]
        lines.append('')
    (ROOT/'VALIDATION.md').write_text('\n'.join(lines))
    print(json.dumps({'current_validation':'patterns/VALIDATION.md','source_status':'PASS' if checks_ok else 'FAIL','packet_checks':packet['checks_count'],'packet_errors':len(packet['errors']),'artifacts':artifacts},ensure_ascii=False))


if __name__ == '__main__':
    main()
