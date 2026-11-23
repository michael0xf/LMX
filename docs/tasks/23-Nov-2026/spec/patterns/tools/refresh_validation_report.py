#!/usr/bin/env python3
"""Publish current evidence; historical receipts are not new execution claims."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]


def read(relative):
    return json.loads((ROOT / relative).read_text())


def main():
    recount = read('validation/recount_report.json')
    core = read('LMX_Fn_Receivers/tests/STATIC_REPORT.json')
    functional = read('09_functional_computation/validation_2026-11-23.json')
    examples = read('examples/STATISTICS.json')
    julia = read('examples/julia_comparison/validation/check_report.json')
    perl = read('examples/perl_comparison/validation/client_tests.json')
    artifacts = read('validation/artifact_review_20261123.json')
    links = read('validation/doc_links_20261123.json')
    assert recount['ok'] and not core['errors'] and functional['ok']
    assert not artifacts['errors'] and julia['status'] == 'PASS' and perl['status'] == 'PASS'
    assert artifacts['visual_signoff'] != 'pending human/model inspection of rendered files'
    counts = examples['counts']
    n_pdf, n_xlsx = len(artifacts['pdf_files']), len(artifacts['xlsx_files'])
    n_formula = sum(x['formulas'] for x in artifacts['xlsx_files'])
    lines = [
        '# Проверка текущей редакции — 23 ноября 2026 года', '',
        'Основа — текущий загруженный `spec.tar.gz`, SHA-256 '
        '`4b142bab169cf7cc3fd89766da35b90561f913b68dca3ab1f0725793e4ecb932`. '
        'Предыдущие архивы не использованы как исходная редакция. Этот отчёт заменяет '
        'прежний сводный VALIDATION.md; датированные отчёты 21–22 ноября остаются историческими '
        'свидетельствами своих этапов и не доказывают исполнение текущего кода.', '',
        '## Комплектность и границы сравнения', '',
        f'Сохранены **{recount["pattern_count"]} паттернов + {recount["implementation_count"]} '
        f'сравнений реализаций = {recount["comparison_count"]} записей / '
        f'{recount["listing_count"]} основных листингов** в девяти группах. '
        'Отдельная исходная GoF-подборка содержит **23 сравнения / 184 основных листинга**; '
        'их код не изменён относительно загруженной базы.', '',
        f'В examples теперь **{counts["lmx_examples"]} сценария LMX**: исходные 24, '
        '24 характерных Julia и 24 характерных Perl. Существующие Haskell-материалы '
        f'сохранены. **Полных пар — {counts["complete_pairs"]}**; остальные старые '
        'случаи явно отмечены как поясняющие аналогии или примеры только LMX. '
        'Они не получают фиктивное нулевое число символов контрольного языка.', '',
        f'Внутри examples отдельно посчитаны **{counts["implementation_comparisons"]} '
        'сравнений реализации общих операций**. Иностранные клиенты вызывают настоящие '
        'стандартные средства или указанные библиотеки; самостоятельные сравнительные '
        'реализации ими не импортируются. LMX использует прямые функции одного ядра.', '',
        'Однострочные и устаревшие дубли удалены по индивидуальным решениям. '
        'Существенно разные подходы сохранены с общим наблюдаемым договором; '
        'самый короткий допустимый выбран основным. Старые содержимые изменённых '
        'и удалённых файлов доступны в preimages пакета Fable, а не маскируются '
        'под дополнительные современные варианты.', '',
        '## Фактически выполненные проверки', '',
        '| Область | Результат | Что это доказывает |',
        '| --- | --- | --- |',
        f'| Девять групп | {recount["comparison_count"]} записей / {recount["listing_count"]} листингов, 0 ошибок | Согласованность JSON, исходников, Markdown и размеров |',
        f'| Группа 09 | {functional["checks"]} проверок, 0 ошибок | Общие определения, полные клиенты, две существенные альтернативы и публикация |',
        '| Исходные examples | 24 клиента; GoF 184 листинга сверены | Основные варианты, реальные зависимости, сравнение с upload |',
        f'| Julia | {len(julia["checks"])} source checks; {julia["logical_cases_checked"]} логических случаев Python | Целостность источников и независимая проверка ожиданий; не исполнение Julia |',
        f'| Perl | {perl["executed_cases"]} клиентских случаев PASS, {perl["runtime"]} | Реальное исполнение контрольных клиентов |',
        f'| Пакет ядра | {core["requested_receivers"]} публичных имён, {core["source_parts"]} частей, 0 source errors | Экспорты, тела, ограниченная проверка скобок/границ и зависимостей |',
        f'| Артефакты | {n_pdf} PDF / {artifacts["pdf_pages"]} страниц и {n_xlsx} XLSX | Перегенерация, контроль размеров/формул и визуальная проверка |', '',
        'Отдельные проверки реализаций Perl записаны в '
        '[implementation_tests.json](examples/perl_comparison/validation/implementation_tests.json). '
        'Независимый обзор обоих новых наборов: '
        '[independent_suites_review_20261123.json](examples/validation/independent_suites_review_20261123.json). '
        'Проверка всей поставки воспроизводится '
        '[validate_current_packet.py](tools/validate_current_packet.py) и хранит '
        '[машинный результат](validation/current_packet_20261123.json).', '',
        'В группах 01–08 выполнены 19 сценариев Python и три независимые Python-реализации; '
        'точная область — [отчёт](validation/group_library_revision_20261123.json). '
        'Переносить их PASS на LMX, Go, Java или C# нельзя.', '',
        '## Ядро, объявленные исходы и оставшаяся интеграция', '',
        f'**Прямых функций и операндов в каталоге — {core["requested_receivers"]}**: '
        '115 из upload и восемь дополнений: `findFirst`, `allOf`, `equalFields`, '
        '`retryPost`, `between`, `iterateUntilStop`, `sort`, `unique`. '
        '[Полный реестр](../CORE_FUNCTIONS.md) связывает имена, договоры и LMX-исходники. '
        'Публичные имена имеют lowerCamelCase; нет обязательного import: fun '
        'или параллельных библиотечных версий.', '',
        f'В [KERNEL_REQUIREMENTS](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) перечислены '
        f'**{len(core["provider_methods"])} внутренних интеграционных границ**. '
        'AE01 сохраняет принятые декларации/тела и живые места принимающего исполнения. '
        'AR01 наблюдает существующую совместимость без исполнения пользовательского кода, '
        'отделяя доказанную несовместимость от невозможности завершить проверку. '
        'Он устраняет четыре ошибочных Boolean-use `satisfies` в прежних Regex-исходниках, '
        'не меняя публичный договор `satisfies`.', '',
        '`retryPost` имеет Message-владельца, post/reply, сохранённый итог и обработку '
        'поздних ответов. HTTP-транспорт сохраняется. Таймаут или остановка новых попыток '
        'не означают отмену уже исполняемой работы или право освободить живую арену. '
        '`bracket` охраняет acquire/action/release в одном исполнении; `lazy`/`once` '
        'устанавливают cleanup до перехода в Busy. Нативная атомарность передачи ресурса '
        'остаётся проверяемым требованием, не выданным за реализованный Haskell mask.', '',
        'Форматирование конечных throws идемпотентно и сохраняет явно проверенные списки. '
        'Это не полный вывод эффектов и не доказательство покрытия динамических callback-исходов. '
        'Сервисные границы и именованные пользовательские отказы не смешаны с implicit/system exits.', '',
        f'В общем пакете подготовлено {core["prepared_assertions"]} assertions. '
        'Матрицы типов, последовательностей, Pattern, адаптеров и новые AR01/AE01-наблюдения '
        'имеют собственные границы и не складываются в число исполненных LMX-тестов.', '',
        '**LMX runtime отсутствует; LMX, Julia, Haskell и Scala здесь не исполнялись.** '
        'Текстовые проверки, Python-модели и генерация публикаций не заменяют запуск '
        'интерпретатора, native и смешанных переходов. В архиве находятся алгоритмы на LMX '
        'и точные контракты интеграции; готовый нативный kernel не заявлен.', '',
        '## Статистика, таблицы и PDF', '',
        'Основная метрика — непробельные Unicode-символы; дополнительно непустые строки, '
        'UTF-8-байты и SHA-256. Считается полный выбранный листинг с обязательными полями, '
        'импортами и эффектами. Комментарии внутри выбранной границы учитываются. '
        'Клиент, реализация и общие зависимости разделены; пересекающиеся замыкания '
        'нельзя суммировать как размер одного приложения.', '',
        f'Во всех {n_xlsx} итоговых XLSX проверены ZIP/XML, формулы '
        f'с сохранёнными значениями (**{n_formula}**) и отсутствие ячеек ошибок. Генераторы через '
        '@oai/artifact-tool сверяют живые результаты и проверяют пересчёт изменением '
        'исходного числа с последующим восстановлением. Это не запуск Microsoft Excel.', '',
        f'Отрендерены все страницы PDF (**{artifacts["pdf_pages"]}**); проверены границы текстовых '
        'элементов, отсутствие пустых страниц и свежие изображения документов. '
        'Визуально проверены также итоговые листы XLSX. Файлы, SHA-256 и просмотренные '
        'изображения указаны в [artifact_review](validation/artifact_review_20261123.json).', '',
        '- [Статистика паттернов](STATISTICS_2026-11-22.md): имя сохранено для прежних ссылок, редакция внутри текущая.',
        '- [Статистика всей examples](examples/STATISTICS.md), [PDF](examples/STATISTICS.pdf), [XLSX](examples/STATISTICS.xlsx).',
        '- [Julia](examples/julia_comparison/README.md) и [Perl](examples/perl_comparison/README.md): договоры, исходники, реализация библиотек и приёмка.', '',
        '## Воспроизведение и слияние', '',
        'Порядок: каталог и сборка ядра → генераторы исходников/сравнений → '
        'refresh_statistics и refresh_examples_statistics → PDF/XLSX → '
        'source/link/artifact checks → просмотр → rebuild_manifests. '
        'Скрипты находятся в tools каждого соответствующего набора; '
        'они не скачивают и не запускают LMX автоматически.', '',
        '[Пакет Fable](../../fable_merge/README.md) содержит source/generated patches, '
        'точные preimages и merge.py. По умолчанию выполняется проверка; '
        'трёхстороннее слияние сохраняет совместимые локальные правки, '
        'конфликт блокирует применение всего набора. Реальная проверка применения '
        'к копии upload и идемпотентности находится в отдельном VALIDATION.json пакета.', '',
        'Локальные ссылки проверены по файлам и якорям; отчёт '
        '[doc_links_20261123.json](validation/doc_links_20261123.json) отделяет '
        'ссылки на отсутствующие части более широкого репозитория, уже имевшиеся в upload, '
        'от новых ошибок. Финальные манифесты содержат реальные SHA-256 и исключают '
        'только самих себя и служебные файлы ОС.', '',
    ]
    (ROOT / 'VALIDATION.md').write_text('\n'.join(lines))
    print(json.dumps({'current_validation': 'patterns/VALIDATION.md', 'pdf': n_pdf, 'xlsx': n_xlsx}))


if __name__ == '__main__':
    main()
