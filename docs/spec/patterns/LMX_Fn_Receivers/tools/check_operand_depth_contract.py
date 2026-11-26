#!/usr/bin/env python3
"""Read-only source/metadata ABI checks; never an LMX execution claim."""
from pathlib import Path
import argparse
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    checks = []

    def require(name, passed, evidence):
        checks.append({'name': name, 'passed': bool(passed), 'evidence': evidence})

    texts = {p.relative_to(ROOT).as_posix(): p.read_text()
             for p in sorted((ROOT / 'src').rglob('*.lmx'))}
    roots = {}
    for path, text in texts.items():
        heads = list(re.finditer(r'(?m)^(?:independent:\s*)?([A-Za-z_]\w*):', text))
        for i, match in enumerate(heads):
            roots[match[1]] = (path, text[match.start():heads[i + 1].start()
                                         if i + 1 < len(heads) else len(text)])

    def body(name):
        return roots.get(name, ('', ''))[1]

    expected = r'@: left\s+int: depth(?: 0)?\s+@\[\]: right'
    for name in ['FxPreparedOperands', 'FxOperandInputTypes', 'RxThenOperand', 'RxRepeatOperands']:
        require(name + ' input order', re.search(expected, body(name)), roots.get(name, ('MISSING',))[0])
    require('typed bind tail keeps depth before right',
            re.search(r'int: depth 0\s+@\[\]: right', body('FxBindOperandTail')),
            'src/monadic_forms.lmx')
    require('logical collector has no service depth',
            not re.search(r'(?m)^\s+int: depth', body('RxLogicalArguments')),
            'RxLogicalArguments remains an ordinary two-input helper')
    builder = body('FxAsOperand')
    require('builder labels all three service fields',
            '("left"; "depth"; "right")' in builder and
            all(f'FxOperandInputTypes[{i}]' in builder for i in range(3)),
            'src/coreStandardLisp.lmx')
    require('source result remains exact', 'source\\resultType' in builder and
            'FxWrap\\make(Operand; FxOperandValueEngine\\run;' in builder,
            'FxWrap projects the selected public R/void, engine @ is internal transport')
    require('dependent result policy is explicit',
            'operandDepthSource operation' in builder,
            'PD01 integration contract; this check does not implement the provider')
    engine = body('FxOperandValueEngine')
    require('depth read uses ABI slot 1', 'FxFrameRead\\read(frame; 1)' in engine,
            'left/depth/right indexes are 0/1/2')
    require('right read uses ABI slot 2', 'FxFrameRead\\read(frame; 2)' in engine,
            'left/depth/right indexes are 0/1/2')
    require('ordinary source never receives depth',
            'RxLogicalArguments\\collect(left := left; right := \\right)' in engine and
            'FxApply\\apply(state; args)' in engine,
            'Only logical args reach the original callable')
    require('positive-depth route shares Array executor',
            'FxKernel\\operandDepthContext(frame; args)' in engine and
            'FxArrayDepth\\apply(context; depth; args)' in engine,
            'One lifting body, no per-dot aliases')
    for name in ['FxRecordOperands', 'FxSignatureOperand', 'FxToOperand', 'FxTypeOperand',
                 'FxMaybeBindOperand', 'FxResultBindOperand', 'RxThenOperand',
                 'RxRepeatOperands', 'FxBetween', 'PipeLibrary', 'FindLibrary',
                 'SpecificationLibrary', 'MoneyLibrary', 'RetryLibrary']:
        text = body(name)
        require(name + ' no invented depth exception',
                'FxOperandWhole\\check(depth)' not in text and 'FxDepth' not in text,
                roots.get(name, ('MISSING',))[0])
    definitions = json.loads((ROOT / 'operation_definitions.json').read_text())
    require('metadata ABI order', definitions['operand_contract']['input_order'] ==
            ['left', 'depth', 'right'], 'operation_definitions.json')
    require('explicit depth uses round modifier syntax',
            set(definitions['operand_contract']['depth_syntax']) ==
            {'op', '.op', '.(expression)op'} and
            definitions['operand_contract'].get('depth_modifier_start') == '.(' and
            'never a decimal point' in definitions['operand_contract'].get('depth_modifier_role', ''),
            'The .( sequence starts an operator/function modifier; Array/type brackets are unchanged')
    axis = definitions['operand_contract'].get('axis_depth', {})
    require('metadata uses logical flat Array axes',
            'logical outer axes' in axis.get('basis', '') and
            axis.get('flat_matrix_shape_2x2') == {
                '0': 'whole matrix multiplication',
                '1': 'corresponding row-vector dot products',
                '2': 'scalar componentwise products'},
            'One flat rank-2 Array; depth does not count allocated row containers')
    require('Structure and reference indexing use ordinary contracts',
            'Structure is @[]' in axis.get('structure', '') and
            r'struct[i]\[j]' in axis.get('structure', ''),
            'No separate array-of-arrays kind is introduced')
    for row in definitions['operations']:
        for variant in row['variants']:
            route = variant['operand']['route']
            policy = variant['operand'].get('depth_policy')
            expected_policy = ('ordinary-value-lifting' if route == 'asOperand' or
                               variant['operand']['target'] == 'ArrayBinding\\bind'
                               else 'whole-value-depth0')
            require(row['name'] + '/' + variant['family'] + ' policy',
                    policy == expected_policy, 'operation_definitions.json')
    source = '\n'.join(texts.values())
    require('no fabricated system template object', 'sys\\OPERANDS_TEMPLATE' not in source,
            'Actual DATA fields are supplied by ordinary source composition')
    require('no generated dotted operation aliases',
            not re.search(r'(?m)^\s+@:\s+`?\.\.?\w', texts['src/public_operands.lmx']),
            'Canonical public names remain base names')
    contract = (ROOT / 'PUBLICATION_CONTRACT.md').read_text()
    require('publication contract follows the logical-axis profile',
            'rank metadata of a flat matrix is not an' not in contract and
            'depth 1 invokes vector `*` on corresponding rows' in contract and
            'a .(2)* b' in contract,
            'Source contract and publication guide must not retain the superseded flat=one-level rule')
    failed = [check for check in checks if not check['passed']]
    report = {'status': 'FAIL' if failed else 'PASS', 'kind': 'limited_source_and_metadata_checks',
              'checks': len(checks), 'failed': failed,
              'production_parser': 'NOT_RUN', 'translator': 'NOT_RUN',
              'lmx_runtime': 'NOT_RUN', 'dependent_result_provider': 'PD01_REQUIRED_NOT_IMPLEMENTED',
              'source_sha256': {path: hashlib.sha256(text.encode()).hexdigest() for path, text in texts.items()},
              'metadata_sha256': hashlib.sha256((ROOT / 'operation_definitions.json').read_bytes()).hexdigest(),
              'results': checks}
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items() if key not in {'results', 'source_sha256'}},
                     ensure_ascii=False, indent=2))
    return 1 if failed else 0


if __name__ == '__main__':
    raise SystemExit(main())
