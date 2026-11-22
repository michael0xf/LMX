"""Rebuild the LMX core receiver sources. Does not execute LMX."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
PARTS = [
    'src/kernel_contracts.lmx',
    'src/reflection.lmx',
    'src/generic_functions.lmx',
    'src/fn_operand.lmx',
    'src/generic_runtime.lmx',
    'src/reflection_bridges.lmx',
    'src/containers.lmx',
    'src/collections.lmx',
    'src/structures.lmx',
    'src/generic_combinators.lmx',
    'src/generic_wrappers.lmx',
    'src/public.lmx',
    'examples/generic_callable_examples.lmx',
    'examples/structure_examples.lmx',
    'examples/fn_and_assignment.lmx',
    'examples/fn_equivalence.lmx',
    'examples/value_generic_examples.lmx',
    'examples/run_all.lmx',
]

HEADER = '''# LMX: ОБЩИЕ ПРЯМЫЕ РЕСИВЕРЫ И КОНТЕЙНЕРЫ
# Редакция 2026-11-22. Собрано из src/ и явно запускаемых examples/.
# DATA-описания ядра; старые Int-специализации только в legacy, не здесь.
# 61 встроенный receiver, доступный напрямую без client import. Каждая Structure — массив @.
# FxKernel требует 8 явно описанных тонких мостов. Ядро здесь не исполнялось.
# Name :: DATA и signatureTypes взаимозаменяемы, кроме сохранённого отношения именованной сигнатуры с call.
# Ни автоматического запуска, ни новой VM, ни автоматической компиляции.
# Загружать сборку ИЛИ отдельные файлы, не оба варианта вместе.

'''


def assembled():
    chunks = [HEADER]
    for name in PARTS:
        chunks.append(f'# SOURCE: {name}\n')
        chunks.append((ROOT / name).read_text(encoding='utf-8').rstrip() + '\n\n')
    return ''.join(chunks)

if __name__ == '__main__':
    text = assembled()
    path = ROOT / 'LMX_Receivers.lmx'
    path.write_text(text, encoding='utf-8')
    print(json.dumps({'file': path.name, 'parts': len(PARTS),
                      'lines': len(text.splitlines()), 'bytes': path.stat().st_size}, ensure_ascii=False))

