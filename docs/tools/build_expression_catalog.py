"""Documentation profile projection; not a runtime registry or implementation claim."""
from pathlib import Path
import hashlib
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'core_catalog/core'
SOURCE='spec/patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx'
ROWS=[]
def add(name,family,roles,body,surface=None,contract='spec/TENSOR_EXPRESSIONS.md'):
    ROWS.append(dict(name=name,family=family,roles=roles,expression_form=surface or name,
        depth_input='depth',operand_input_order=['left','depth','right'],
        depth_syntax='.(general expression); absent is distinct from 0; no .op abbreviation',
        depth_default='selected profile; plain Map defaults to scalar cells (0)',
        receiver=f'`{name}`' if not name.isidentifier() else name,
        implementation=body,source=SOURCE,contract=contract,
        status='DOCUMENTED_PROFILE_AND_INTEGRATION_BODY',production_binding='NOT_RUN',lmx_executed=False))
for n in '+ - * / % ** & | ^ ~ ! << >> = != < <= > >='.split():
    add(n,'scalar-map',['VALUE'],r'FxArrayElementwise\apply / FxArrayDepth\apply')
for n in '+= -= *= /= %= **= &= |= ^= <<= >>= ++var var++ --var var--'.split():
    add(n,'pointwise-update',['PLACE','VALUE'],r'snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result')
add(':=','pointwise-assignment',['PLACE','VALUE'],r'FxArrayAssignPrepared\assign')
add('.:','slice-broadcast-assignment',['PLACE','VALUE'],r'broadcast RHS map -> FxArrayAssignPrepared\assign')
for n in ['+','-','*','/','\\','**','=','!=']:
    add(n,'whole-linear-algebra',['VALUE'],r'FxArrayProduct\multiply -> FxArrayIndexed\apply' if n=='*' else (r'FxMatrixPower\power (integer exponent)' if n=='**' else 'selected declared whole profile'),surface='['+n+']')
add('op','explicit-indexed-profile',['VALUE'],r'FxArrayIndexed\apply + FxArrayIndexedCell\at',surface='[op axisRules; options -> outputOrder]')
for surface,family in [('[+ 1:]','unary-sum'),('[* 1:]','unary-product'),('[+ 0:1]','trace-sum'),('[* 0=1]','diagonal-view'),('[* -> 1,0]','permutation-view')]:
    add(surface[1],family,['VALUE'],'ordinary selected index/geometry profile',surface=surface)
add('fuse','minimum-scalar-map-fresh-result',['RAW'],r'FxFusePrepared\run',contract='spec/FUSION.en.md')
add('?:','lazy-conditional',['VALUE','RAW','RAW'],'existing conditional demand',contract='spec/TERNARY_AND_SLICES.en.md#conditional')
add('slice','signed-strided-slice',['VALUE','VALUE'],'shared slice normalization',contract='spec/TERNARY_AND_SLICES.en.md#slice-receiver')
def build():
    OUT.mkdir(parents=True,exist_ok=True)
    data=dict(edition='2026-11-28',scope='Documentation profiles, not runtime registration.',source_sha256=hashlib.sha256((ROOT/SOURCE).read_bytes()).hexdigest(),canonical_spec='spec/TENSOR_EXPRESSIONS.md',forms=ROWS,note='Ordinary LMX configuration; absent depth and axisRules remain absent; exact names are opaque.')
    (OUT/'array_expression_forms.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    lines=['# Tensor/RAW/PLACE profile inventory, 2026-11-28.','# DATA only; production binding and LMX execution: NOT_RUN.','','ArrayExpressionForms:']
    for i,row in enumerate(ROWS,1):
        lines.append(f'    entry{i:03}:')
        for key in ['name','family','receiver','expression_form','depth_input','depth_syntax','depth_default','implementation','source','contract','status','production_binding']:
            lines.append(f'        []char: {key} {json.dumps(row[key],ensure_ascii=False)}')
        lines.append('        int: executed 0')
    (OUT/'array_expression_forms.lmx').write_text('\n'.join(lines)+'\n')
    text=r'''# Массивные, индексные и матричные профили

Редакция 2026-11-28. [LMX-опись](array_expression_forms.lmx) и
[JSON-проекция](array_expression_forms.json) описывают канонические операции и
профили; это не второй runtime-диспетчер.

Обычные арифметика, сравнения и обновления работают поэлементно. `*` и `[*]`
различаются выбором Map и whole матричного профиля. Явные `[op rules]` выбирают
индексный kernel с независимо объявленным reducer. Бинарный `*` может иметь
default суммирования; для `+`, `&`, `^` reducer не угадывается. `[+ 1:]` — сумма,
`[* 1:]` — произведение, `[+ 0:1]` — след. Пустые axisRules дают внешнее
произведение и не совпадают с отсутствующим списком в `[*]`.

**left, depth, right** сохраняют отсутствие actual. `.(depth)` задаёт глубину обхода внешних осей; 0 означает максимум. `.op` не является
сокращением. Структурные вызовы используют базовое имя с формалом depth.
Конфигурация профиля — обычная LMX-структура; методы — обычные ссылки.

`:=` присваивает поэлементно со снимком RHS и проверками до записи.
`target[:] .: values` присваивает срезу с выравниванием справа и транслированием
осей размера 1. Оба используют одно тело snapshot/admission/write с разными
подготовленными картами RHS.

Минимальный `fuse` принимает Scalar/Map со свежим результатом. Неподдержанный
план с редукцией, contraction или streaming store диагностируется. RAW/PLACE/
TYPE/DATA не проходят через eager VALUE. Structure `[]@` не исключается из
Arrays: применимость определяется типами ячеек и конкретным kernel.

[Полная норма и каталог](../../spec/TENSOR_EXPRESSIONS.md),
[depth](../../spec/OPERATOR_DEPTH.ru.md), [подпарсер](../../spec/BRACKET_SUBPARSER.ru.md),
[общие LMX-тела](../../spec/patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx).
[Матричные backend и альтернативы](../matrix/README.ru.md) задают допуск
конкретных C entry, численного профиля, layout, ошибок и владения.
`[**]` с целым показателем использует одно общее `FxMatrixPower\power`;
другие matrix functions этим не реализуются.
Production parser/translator/runtime: **NOT_RUN**.

| Имя | Expression | Профиль | Роли | Общее тело/граница |
| --- | --- | --- | --- | --- |
'''
    for row in ROWS:
        esc=lambda x:x.replace('|',r'\|')
        text+=f"| `{esc(row['name'])}` | `{esc(row['expression_form'])}` | {row['family']} | {', '.join(row['roles'])} | `{esc(row['implementation'])}` |\n"
    (OUT/'ARRAY_EXPRESSIONS.md').write_text(text)
    return len(ROWS)
if __name__=='__main__':print(f'{build()} documented profiles; production NOT_RUN.')
