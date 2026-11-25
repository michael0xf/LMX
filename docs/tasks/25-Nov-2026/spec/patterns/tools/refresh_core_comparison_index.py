#!/usr/bin/env python3
"""Publish current comparison boundaries and metadata-backed core additions."""
from pathlib import Path
import json
from packet_metadata import addition_metadata, implementation_source, restoration_metadata

ROOT = Path(__file__).resolve().parents[1]


def main():
    records = {}
    for path in sorted(ROOT.glob('[0-9][0-9]_*/patterns.json')):
        for item in json.loads(path.read_text())['patterns']:
            records[item['id']] = (path.parent, item)
    links = {}
    for ident, (directory, row) in records.items():
        links[ident] = (directory / f'{ident:03d}_{row["slug"]}_comparision.md').relative_to(ROOT).as_posix()
    uses = {91:[82],92:[83],93:[13],94:[16],95:[31],96:[32],97:[39,45],98:[84],99:[85]}
    functions = {
        91:'some, none, bind',92:'done, more, trampoline',
        93:'pipe',94:'findFirst',95:'allOf',96:'equals',
        97:'retry',98:'bracket',99:'partial, curry',
    }
    boundaries = {
        91:'Стандартные Maybe / Option; отдельное обобщённое сравнение контейнера и bind.',
        92:'Haskell Free Identity / Scala TailCalls; отдельные контейнер и trampoline.',
        93:'Общий pipe применяет стадии к значению; контрольный профиль — целочисленный конвейер. compose строит callable и сравнивается отдельно.',
        94:'Общий findFirst принимает предикат; клиент сохраняет профиль поиска по id и прежнее представление отсутствия.',
        95:'Общий allOf сохраняет действительную совместимую сигнатуру; клиент проверяет два предиката с коротким замыканием.',
        96:'equals использует явную проекцию полей Money; общий алгоритм равенства и проекция имеют отдельные обязанности.',
        97:'Общий синхронный retry с явным профилем Http503; полные реализации и общие зависимости учитываются отдельно.',
        98:'Haskell bracket / Scala Using.resource; один ресурс, полный acquire/action/release.',
        99:'Haskell partial application / Scala curried; произвольная смешанная сигнатура LMX.',
    }
    statistics = json.loads((ROOT/'validation/statistics_20261122.json').read_text())
    text = [
        '# Библиотечные операции: использование и сравнение реализации', '',
        'Редакция **24 ноября 2026 года**. Короткие сопоставимые реализации 22-Nov восстановлены на основе спецификации 23-Nov. Девять сравнений реализаций сохранены. Их договоры различаются: некоторые показывают обобщённый стандартный API, другие — конкретный общий компонент приложения.', '',
        '| Реализация | Клиенты | LMX | Граница сравнения |',
        '| --- | --- | --- | --- |',
    ]
    for ident, clients in uses.items():
        name = records[ident][1]['name']
        client_links = ', '.join(f'[{i:03d}]({links[i]})' for i in clients)
        text.append(f'| [{ident:03d}. {name}]({links[ident]}) | {client_links} | `{functions[ident]}` | {boundaries[ident]} |')
    text += [
        '', '## Общие компоненты и полный размер', '',
        'Клиенты 039 и 045 используют общий синхронный компонент 097: канонический retry с явным Http503 в LMX и опубликованный RetryHelper в Go/C#. Они явно помечены `shared_implementation_client`. Таблица включает оба клиента и один полный helper; импорт не превращает реализацию в бесплатную стандартную библиотеку. Для одного выбранного клиента JSON содержит отдельную сумму client + helper. Асинхронные варианты с другим договором сохранены в extended_comparisons.', '',
        '| Компонент / клиенты | Язык | Клиенты | Helper один раз | Всего |',
        '| --- | --- | ---: | ---: | ---: |',
    ]
    for component in statistics['shared_implementation_components']:
        ident = str(component['implementation_id'])+' / '+', '.join(f'{n:03d}' for n in component['usage_ids'])
        for language, values in component['costs'].items():
            text.append(f"| {ident} | {language} | {values['clients']} | {values['helper_once']} | {values['complete_component']} |")
    text += [
        '', '## Краткость и полнота', '',
        'Для каждого функционального клиентского договора сравниваются обе полные формы LMX: процедурная и функциональная. Одна из них не исключается из сравнения из-за размера. Динамическое связывание, `{type value}` и копирование полей используются по действующей спецификации; лексическая видимость свободных имён не навязывается. Повторяющийся алгоритм выносится в обычную функцию либо заменяется копированием общего набора полей.', '',
        'В 084 сохранён целиком авторский Around + общий Trace (709 непробельных символов). Функциональный клиент core bracket занимает 586 символов; оба варианта входят в сравнение. Сравнение имени ошибки исключено по доказанному замкнутому набору callback-исходов этого примера; другие ошибки инфраструктуры выходят под собственными именами. Это не общее разрешение перехватывать любой FxCallFailure как ResourceFailure. [Точная проверка границы](09_functional_computation/review/084_failure_boundary.md).', '',
        'Клиенты функциональной группы используют настоящие средства Haskell/Scala. Самостоятельные сравнительные реализации этих языков остаются отдельными листингами. Публичные функции LMX принадлежат одному ядру; прикладные профили и полные общие исходники явно указаны рядом. [Общий реестр](../CORE_FUNCTIONS.md) связывает публичные имена и определения.', '',
        '## Дополнительные наборы', '',
        '[Исходные 24 примера](examples/README.md), [Julia](examples/julia_comparison/README.md), [Perl](examples/perl_comparison/README.md) и [SBCL/Common Lisp](examples/SBCL_comparison/README.md) публикуют клиентов, полные сравнения реализаций и зависимости отдельно. Если у новой операции нет иностранной сравнительной реализации, она обозначена как unpaired, а действующее определение LMX и замыкание зависимостей всё равно доступны и посчитаны.', '',
        '## Подсчёт и проверяемые ограничения', '',
        'Основной размер включает весь текст каждого опубликованного клиента: заголовки, обязательные поля, импорты и Throws. Считается полный текст каждой формы: все определения, вспомогательные методы, комментарии внутри листинга, обработчики, имена ошибок и полные ссылки `throws: copy(target\\throws)`. Списки берутся из фактически выбранных методов или явно заданного конечного объединения договоров. Статистического удаления аргументов Throws нет. В PDF/XLSX зелёным шрифтом и подчёркиванием числа выделяются **все** равные минимумы полного счёта сопоставимой строки; неполные аналогии победителя не получают. Общая реализация учитывается один раз в своей границе.', '',
        'Замыкания зависимостей разных альтернатив пересекаются, поэтому их нельзя механически складывать как один исполняемый пакет. [Статистика](STATISTICS_2026-11-22.md), [полный JSON](validation/statistics_20261122.json) и [методика](COMPARISON_RULES.md) фиксируют границы. LMX runtime отсутствует; source checks и пересчёт размеров не являются исполнением LMX. [Требования интеграции](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).', '',
    ]
    (ROOT/'LIBRARY_COMPONENTS.md').write_text('\n'.join(text))

    library = ROOT/'LMX_Fn_Receivers'
    catalog = json.loads((library/'catalog.json').read_text())
    additions, manifests = addition_metadata(library)
    main_metadata = json.loads((library/'CORE_ADDITIONS_20261123.json').read_text())
    family_files = set(main_metadata['addition_manifests'])
    current_names = {entry['name'] for item in manifests if item['file'] in family_files for entry in item['document']['entries']}
    additions = [item for item in additions if item['name'] in current_names]
    provenance = restoration_metadata(ROOT)
    base = json.loads((ROOT/'validation/expansion_baseline_20261124.json').read_text())['base_archive']; reference = provenance['historical_provenance']['short_example_reference']
    families = [item for item in manifests if item['file'] in family_files]
    report = [
        '# Текущая редакция сравнений и функций ядра', '',
        f"**24 ноября 2026 года.** Основа — `{base['name']}`, SHA-256 `{base['sha256']}`. Историческое восстановление коротких примеров из `{reference['name']}` уже входит в загруженную основу; этот старый архив не требуется для текущей сборки.", '',
        '## Что изменено', '',
        'Восстановлены краткие сопоставимые клиенты и реализации. Обобщённые или асинхронные варианты с другим договором сохранены отдельно. В повторяющемся коде используются обычные функции и copy; динамическое связывание не заменяется лексическими обходами.', '',
        'Функциональные клиенты имеют обе полные LMX-формы. В исходной восстановленной редакции GoF были изменены два LMX-листинга: Visitor использует общее тело обработчика, Abstract Factory копирует общий набор методов. Эти изменения уже присутствовали в свежем загруженном архиве. В функциональных клиентах 085 Haskell и Scala симметрично удалены неиспользуемая переменная и одноразовое промежуточное имя; их договор и результат сохранены. В 084 Haskell использует собственный ResourceFailure и типизированный catch.', '',
        f"Каталог содержит **{len(catalog)}** канонических публичных имён и **{sum(len(e.get('variants',[])) for e in catalog)}** типовых вариантов. Все исходные имена имеют явную миграцию в CANONICAL_MIGRATION.json; прежние callable aliases не публикуются. Имя объединяет перегрузки по типам, обе формы сохраняют один алгоритм. Исторические addition manifests считаются по канонической идентичности и варианту.", '',
        '## Семейства стандартных операций', '',
        '| Метаданные исторического добавления | Канонических записей |', '| --- | ---: |',
    ]
    for family in families:
        report.append(f"| [{family['file']}](LMX_Fn_Receivers/{family['file']}) | {len(family['document']['entries'])} |")
    report += ['', '## Стандартные операции, включённые в текущую основу', '', '| Имя | Договор | Исходник |', '| --- | --- | --- |']
    for item in additions:
        source = implementation_source(item)
        args = item.get('arguments', '')
        scope = item.get('scope', '').replace('|', r'\|')
        report.append(f"| `{item['name']}({args})` | {scope} | [{Path(source).name}](LMX_Fn_Receivers/{source}) |")
    report += [
        '', '## Границы реализации', '',
        '`bracket` заранее выделяет ячейку аргумента cleanup, сохраняет успешный acquire в готовую ячейку и регистрирует finally до построения аргументов action. При отказе acquire handler не зарегистрирован. Повторных acquired/ok-проверок нет. Нативная атомарность и Haskell asynchronous masking не объявляются реализованными одним этим исходником.', '',
        'Новые стандартные операции используют существующие typed value records, containers, names/nil, Pattern, ordinary callbacks и текущие интеграционные входы. Отдельные документы семейств описывают ограниченные конечные коллекции, payload/default правила, владение, ранний выход и отсутствие новых выдуманных providers. Подготовленные acceptance cases помечены NOT_RUN.', '',
        'Все конечные Throws считаются полностью. Где договор допускает, список копируется из действительно вызываемого метода. Библиотечное тело и его зависимости учитываются отдельно один раз; две клиентские формы сохраняют один наблюдаемый договор.', '',
        '## Где смотреть', '',
        '- [Клиенты и девять сравнений реализаций](LIBRARY_COMPONENTS.md).',
        '- [Все 96 примеров](examples/README.md) и [их статистика](examples/STATISTICS.md).',
        '- [Статистика паттернов](STATISTICS_2026-11-22.md), [машинные проверки](validation/current_packet_20261123.json).',
        '- [Optional/Result/object операции](LMX_Fn_Receivers/CORE_STANDARD_OBJECTS.md).',
        '- [Полный реестр ядра](../CORE_FUNCTIONS.md) и [интеграционные требования](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).',
        '- [Текущий отчёт проверок](VALIDATION.md).', '',
        'LMX runtime не поставляется. Статические проверки, Python-модели, генерация публикаций и отдельно выполненные foreign tests не заменяют исполнения LMX. Этот пакет содержит исходники алгоритмов, сравнения и конкретные требования интеграции.', '',
    ]
    (ROOT/'CORE_COMPARISONS_2026-11-23.md').write_text('\n'.join(report))
    print(json.dumps({'implementation_comparisons':len(uses),'public_functions':len(catalog),'additions_to_23Nov':len(additions),'base_archive':base['name']}))


if __name__ == '__main__':
    main()
