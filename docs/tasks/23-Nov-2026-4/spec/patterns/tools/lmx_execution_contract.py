"""The existing root startup and subsequent case operations; no runner API."""
from copy import deepcopy
import re

EXECUTION_CONTRACT = {
    'startup_target': 'root',
    'startup_level': 'L3 Thread',
    'root_has_data': False,
    'root_accepts_user_arguments': False,
    'local_declarations_and_calls': 'The ordinary common language mechanism applies at the root and at later calls.',
    'case_operation_phase': 'after_root_startup',
    'named_operation_is_startup': False,
    'case_actuals': 'invoke/inputs/args describe ordinary later case operations, not startup arguments for the root.',
    'argument_fixture': 'A parent stub may have its own arguments and send a message to the root; this does not give DATA or user arguments to the root.',
    'source_dependencies': 'Required source definitions and load_before dependencies belong to the fixture. They do not introduce a DATA-load startup or a named alternative entry.',
}
RUNNER_CONTRACT = (
    'Always start the root as an L3 Thread without DATA or user arguments. '
    'Local declarations and calls use the ordinary common language mechanism. '
    'An invoke path or named case operation is performed by the root or an ordinary handler after startup; '
    'Main and Example\\run are not alternative program entries. '
    'A parent stub with its own arguments may send a message to the root. '
    'load_before lists required fixture definitions; import exposes existing names, not a new file loader. '
    'These records specify acceptance observations and do not claim an executed LMX runner.'
)
NOTE_HEADING = '## Запуск корня и дальнейшие операции'


def annotate_operation(record):
    """Rename only LMX operation metadata; foreign entry fields are untouched."""
    if 'lmx_entry_point' in record:
        record['lmx_operation'] = record.pop('lmx_entry_point')
    entries = record.get('entry_points')
    if isinstance(entries, dict) and 'lmx' in entries:
        record['lmx_operation'] = entries.pop('lmx')
        if not entries:
            record.pop('entry_points')
    record['lmx_operation_phase'] = 'after_root_startup'
    return record


def apply_execution_contract(document):
    document['lmx_execution_contract'] = deepcopy(EXECUTION_CONTRACT)
    document['lmx_runner_contract'] = RUNNER_CONTRACT
    if 'runner_contract' in document:
        document['runner_contract'] = RUNNER_CONTRACT
    for name in ('source_examples', 'additional_fixtures', 'comparison_programs', 'examples', 'entries', 'patterns', 'records'):
        for record in document.get(name, []):
            if isinstance(record, dict):
                annotate_operation(record)
    return document


def acceptance_document(document):
    apply_execution_contract(document)
    for record in document.get('examples', []) + document.get('cases', []):
        if not isinstance(record, dict):
            continue
        if 'entry_point' in record:
            record['operation'] = record.pop('entry_point')
        record['lmx_operation_phase'] = 'after_root_startup'
    return document


def startup_note(spec_link):
    return (NOTE_HEADING+'\n\n'
        'Всегда запускается корень R0 как L3 Thread. У корня нет DATA и пользовательских аргументов. '
        'Локальные объявления и вызовы обрабатываются общим механизмом языка.\n\n'
        'Именованные операции из invoke, inputs и тестовых cases выполняются корнем или обычным обработчиком '
        'уже после старта. Main и Example\\run не являются альтернативными точками запуска программы. '
        'Заглушка-родитель может иметь собственные аргументы и отправить корню сообщение; эти аргументы '
        'не становятся DATA корня.\n\n'
        'load_before обозначает необходимые определения фикстуры. Отдельного режима запуска через загрузку '
        'в DATA он не вводит; import открывает доступные имена. Для короткого фрагмента явно задаётся '
        'принимающий контекст последующей обычной операции. Новая команда CLI или API запуска здесь не определяется. '
        'LMX runtime: NOT_RUN. [Норма запуска]('+spec_link+').\n')


def ensure_startup_note(text, spec_link):
    """Replace prior explanatory prose without changing any fenced listing."""
    lines = text.splitlines(); kept = []; fenced = False
    for line in lines:
        if re.match(r'^\s*(```|~~~)', line):
            fenced = not fenced
        if not fenced and (line.startswith('Листинги с объявлениями структур и методов используют явный **профиль загрузки в DATA**.')
                           or line.startswith('Каждый клиент `.lm3` явно загружается **как DATA**')
                           or line == '## Загрузка LMX-примеров и выбор входа'):
            continue
        kept.append(line.replace('| Файл | Точка входа / проверка |', '| Файл | Обычная операция после запуска корня / проверка |') if not fenced else line)
    text = '\n'.join(kept)+'\n'
    text = re.sub(r'^'+re.escape(NOTE_HEADING)+r'\n[\s\S]*?(?=^## |\Z)', '', text, flags=re.M)
    return text.rstrip()+'\n\n'+startup_note(spec_link)
