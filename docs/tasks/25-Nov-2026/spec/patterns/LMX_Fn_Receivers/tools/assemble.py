"""Rebuild the LMX core receiver sources. Does not execute LMX."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
PARTS = [
    'src/kernel_contracts.lmx',
    'src/failures.lmx',
    'src/reflection.lmx',
    'src/adapter_frames.lmx',
    'src/generic_functions.lmx',
    'src/fn_operand.lmx',
    'src/operation_forms.lmx',
    'src/generic_runtime.lmx',
    'src/reflection_bridges.lmx',
    'src/containers.lmx',
    'src/monadic_forms.lmx',
    'src/sequences_core.lmx',
    'src/sequences_selection.lmx',
    'src/sequences.lmx',
    'src/sequences_mutation.lmx',
    'src/fill.lmx',
    'src/lowerBound.lmx',
    'src/last.lmx',
    'src/collections.lmx',
    'src/structures.lmx',
    'src/generic_combinators.lmx',
    'src/generic_wrappers.lmx',
    'src/coreGenericOperations.lmx',
    'src/coreComparisonGroups.lmx',
    'src/coreComparisonExamples.lmx',
    'src/corePerlExamples.lmx',
    'src/regex/support.lmx',
    'src/regex/text.lmx',
    'src/regex/source.lmx',
    'src/regex/primitives.lmx',
    'src/regex/values.lmx',
    'src/regex/combinators.lmx',
    'src/regex/operations.lmx',
    'src/regex/operands.lmx',
    'src/coreStandardFunctional.lmx',
    'src/coreStandardObjects.lmx',
    'src/coreStandardLisp.lmx',
    'src/coreStandardText.lmx',
    'src/coreStandardNumeric.lmx',
    'src/sequence_profiles.lmx',
    'src/public_operands.lmx',
    'src/public_families.lmx',
    'src/public.lmx',
    'examples/generic_callable_examples.lmx',
    'examples/structure_examples.lmx',
    'examples/fn_and_assignment.lmx',
    'examples/fn_equivalence.lmx',
    'examples/value_generic_examples.lmx',
    'examples/sequence_examples.lmx',
    'tests/adapter_semantics.lmx',
    'examples/run_all.lmx',
]

HEADER = '''# LMX: ОБЩИЕ ПРЯМЫЕ РЕСИВЕРЫ И КОНТЕЙНЕРЫ
# Редакция 2026-11-23. Собрано из src/ и явно запускаемых examples/.
# DATA-описания ядра; старые Int-специализации сюда не входят.
# {public_count} вызовных имён и отдельно готовые Pattern/config/type значения. Каждая Structure — @[].
# FxKernel: 8 исходных границ + 5 фаз вызова + 4 доступа к Array + AE01 + AR01.
# Это проект интеграции; реальное ядро и LMX-fixtures здесь не исполнялись.
# Name :: DATA и -> строят одинаковый позиционный тип, кроме сохранённого отношения именованной сигнатуры с call.
# Ни автоматического запуска, ни новой VM, ни автоматической компиляции.
# Загружать сборку ИЛИ отдельные файлы, не оба варианта вместе.

'''


def assembled():
    public_count = len(json.loads((ROOT/'catalog.json').read_text()))
    chunks = [HEADER.format(public_count=public_count)]
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
