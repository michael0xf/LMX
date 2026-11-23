#!/usr/bin/env python3
"""Build the current receiver inventory from canonical names and type variants."""
from pathlib import Path
import json
import re
R=Path(__file__).resolve().parents[1]


def main():
    path=R/'RECEIVERS.md'
    previous=path.read_text()
    head=previous.split('## Полный каталог',1)[0]
    tail='## Значение, запись и созданная функция'+previous.split('## Значение, запись и созданная функция',1)[1]
    catalog=json.loads((R/'LMX_Fn_Receivers/catalog.json').read_text())
    variants=sum(len(e['variants']) for e in catalog)
    lines=[head.rstrip(),'', '## Полный каталог','',
        f"Каталог содержит **{len(catalog)}** канонических имён и **{variants}** вариантов по типам. "
        'У каждого имени есть обычная ресиверная и общая операндная форма. Обе формы используют одно тело, '
        'те же роли аргументов и исходный контекст связывания. Вариант выбирается по типам; имя не создаёт отдельного алгоритма.', '',
        'P0 уже принимает все ресиверы в Expression. Поддержка конкретной операции и ролей находится в трансляторе. '
        'Обычная и заключённая в обратные кавычки запись одного идентификатора обозначают одно имя. '
        'Символические операции сохраняют точное имя, а четыре прижатые формы `++var`, `var++`, `--var`, `var--` '
        'получают отдельные канонические шаблоны с одним аргументом PLACE. '
        '[Полный договор форм](../OPERATION_FORMS.md).', '',
        '| Имя | Обычная форма | Варианты и исходники |',
        '| --- | --- | --- |']
    for entry in catalog:
        cases=[]
        for variant in entry['variants']:
            cases.append(f"{variant['family']}: [{variant['api']}](LMX_Fn_Receivers/{variant['source']})")
        signature=entry.get('signature',entry['name']+'(...)')
        lines.append(f"| `{entry['name']}` | `{signature.replace('|','&#124;')}` | {'; '.join(cases)} |")
    lines += ['', '## Общие договоры','',
        '`bind` объединяет Maybe, Result и Array по типам. Он заменяет отдельные названия той же операции; '
        'some(x), ok(x), err(x) и done(x) сами захватывают типизированную запись значения. '
        'Пользовательский клиент может писать `some(x) bind half bind half`; обычная форма bind сохраняется. '
        '[Монадические операции](../MONADIC_OPERATIONS.md).', '',
        '`unique(items)` использует общее равенство и оставляет первое появление. Явный `same` заменяет равенство '
        'всего элемента. Вложенные конечные ациклические Arrays сравниваются структурно; типовые токены, '
        'скаляры, текст и ссылки следуют своему действительному договору. `equalFields` и `unique` используют '
        'общий поиск первого различия, без второго текстового сравнения. [Общее равенство](../GENERIC_EQUALITY.md).', '',
        '`then` соединяет общие Patterns. `arrayView`, `element`, `literal`, `within`, `oneOf`, `noneOf`, '
        '`anyElement`, `start`, `end`, `matchedValue`, `captureValue` и `captureValues` работают в выбранном '
        'профиле последовательности. `utf8Text` и `byteText` остаются явно текстовыми конструкторами профиля. '
        '[Общие операции](../GENERIC_OPERATIONS.md).', '',
        '`compose(outer; inner)` строит callable и не исполняет стадии при построении. '
        '`pipe(value; stages)` применяет стадии к принятому значению по порядку; его фактический тип может меняться. '
        '`equals` принимает явную проекцию, `findFirst` — предикат, `allOf` — совместимые предикаты '
        'произвольной сигнатуры, `retry` — operation/retryOn/limit/delay. Прикладные профили Money и Http503 '
        'задают данные и политики, общий алгоритм остаётся в ядре. '
        '[Примеры и зависимости](UNIFIED_OPERATIONS.md).', '',
        '`type` выражает требование типа без конфликта с объявлением `int: x`. '
        '`to` получает входные TYPE и последний TYPE результата: `A0 to A1 R`. '
        'Обозначения TYPE/RAW/PLACE/LAZY_NODE сохраняют роль и не вычисляются как обычное значение только '
        'из-за выбора формы вызова.', '',
        '`retryPost` использует настоящие Message/post, сохраняет конечный результат и учитывает поздние ответы. '
        'Таймаут или отмена дальнейших повторов не означают принудительного завершения удалённого вызова. '
        '`iterateUntilStop` использует принятую декларацию и живые места принимающего исполнения; '
        'нижний мост attemptAccepted явно описан как граница интеграции.', '', tail]
    text='\n'.join(lines)
    text=text.replace('и [текстовые Patterns]','и [общие Patterns]')
    a=text.index('## Названия');b=text.index('## Примеры и метрика',a)
    text=text[:a]+'''## Названия

Имена согласованы с [канонической миграцией](LMX_Fn_Receivers/CANONICAL_MIGRATION.json). Прежние callable aliases не сохраняются. Исторические карты переименований описывают происхождение, а действующий [catalog.json](LMX_Fn_Receivers/catalog.json) задаёт публичные имена, типовые варианты и маршруты обеих форм. Имена контрольных языков в их исходниках остаются родными.

Каррирование называется `curry`, левая свёртка — `foldl`, её префиксы с seed — `scanl`, мемоизация — `memoize`, acquire/release/action — `bracket`. Именованные сигнатуры записываются `Name :: DATA`; построение из TYPE доступно как `to` с типом результата последним. `index` возвращает Maybe индекса, `deleteAt` удаляет полуоткрытый диапазон. Смена формы вызова не меняет ни один из этих договоров.

'''+text[b:]
    path.write_text(text.rstrip()+'\n')
    print(json.dumps({'canonical_names':len(catalog),'variants':variants}))

if __name__=='__main__':main()
