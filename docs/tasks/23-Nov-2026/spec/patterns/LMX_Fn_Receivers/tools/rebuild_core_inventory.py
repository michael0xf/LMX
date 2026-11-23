#!/usr/bin/env python3
"""Publish the direct-core list from the same catalog used by kernel exports."""
from collections import defaultdict
import json
from pathlib import Path
import re

PACKAGE = Path(__file__).resolve().parents[1]
SPEC = PACKAGE.parents[1]


def family(row):
    src = row['source']
    if '/regex/' in src:
        return 'Text patterns and matching'
    if 'corePerlExamples' in src or 'coreJuliaExamples' in src:
        return 'Stable ordering and distinct values'
    if 'coreComparisonExamples' in src:
        return 'Declared-form iteration and ordered ranges'
    if 'coreComparisonGroups' in src:
        return 'Selection, predicates, equality and Message retry'
    if 'sequence' in src or 'collections' in src:
        return 'Universal sequences'
    if 'containers' in src:
        return 'Value containers and trampoline'
    if 'reflection' in src or 'structures' in src:
        return 'Reflection and structure composition'
    return 'Callable construction, composition and lifetime'


def main():
    catalog = json.loads((PACKAGE/'catalog.json').read_text())
    names = [row['name'] for row in catalog]
    assert len(names) == len(set(names)), 'Duplicate public name'
    assert all(re.fullmatch(r'[a-z][A-Za-z0-9]*', n) for n in names), 'Public functions require lowerCamelCase'
    groups = defaultdict(list)
    for row in catalog:
        assert (PACKAGE/row['source']).is_file(), row['source']
        groups[family(row)].append(row)
    lines = [
        '# Direct functions for the current LMX core', '',
        'Edition: **23 November 2026**, based on the newly uploaded `spec.tar.gz`.', '',
        f'This is the common integration inventory of **{len(catalog)} public callable/operand names**. '
        'It is generated from the same [catalog](patterns/LMX_Fn_Receivers/catalog.json) as '
        '[the constant exports](patterns/LMX_Fn_Receivers/src/public.lmx). '
        'All belong to the current kernel. Clients call them directly; there is no optional '
        'LMX library import or parallel version of these facilities.', '',
        'Public names use **lowerCamelCase**. Existing single-word identifiers remain lowercase. '
        'Implementation groups, types, named failures, ready Pattern values and symbolic language '
        'operators are separate categories; they are not extra functions in this count.', '',
        'Each linked source contains the LMX algorithm. `BODY_WITH_BRIDGE` means that the algorithm '
        'uses the documented common kernel interfaces; it does not mean a native implementation '
        'has been supplied or executed. The archive contains no runnable LMX kernel. '
        '[Kernel requirements](patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) identify the exact '
        'remaining integration boundaries. All runtime acceptance cases remain NOT_RUN.', '',
        '## Use and implementation are separate comparisons', '',
        'LMX examples use these core functions. Control-language usage examples use real language '
        'facilities or named established libraries. Our independently written foreign implementations '
        'are retained beside LMX implementations for comparison; they are not dependencies of those '
        'foreign clients. See the [comparison revision](patterns/CORE_COMPARISONS_2026-11-23.md) '
        'for client-to-implementation links, external packages and completeness boundaries.', '',
        'A complete implementation here means the stated operation contract: arbitrary admitted '
        'payload types and finite sizes where applicable, empty inputs, failure propagation, '
        'ordering and lifecycle behavior. It does not claim to reproduce every unrelated API of '
        'a larger package such as `scala.util.Using` or a retry framework. Application fixtures '
        '(for example, integer halving or a Money record) do not specialize the core helper.', '',
        '## Message and asynchronous execution', '',
        'A mutable asynchronous algorithm runs in its owning `Message` and uses the existing '
        '[post/reply transport](LMX_semantics.en.md#thread-message-api), including the HTTP profile. '
        'Callbacks, declaration places and mutable state do not become shared references across arenas. '
        'Posting the entire owning method is sufficient for synchronous combinators such as '
        '`trampoline` or `bracket`; a second scheduler inside them would duplicate transport. '
        'Their source comments state that boundary explicitly.', '',
        '`bracket` protects acquisition/action/release in one owning activation. If its action '
        'posts unrelated work and returns immediately, that work does not extend the resource lifetime. '
        'A timeout is notification under the transport contract; it does not cancel an in-flight '
        'operation, discard its later reply or permit reclaiming a live Message arena. Stateful '
        'retry policy is specified separately from synchronous declared-failure `retryCall`.', '',
        '## Function inventory', '',
    ]
    for title, rows in groups.items():
        lines.extend(['### '+title, '', '| Function / operand | Contract | LMX source |', '| --- | --- | --- |'])
        for row in rows:
            signature=row['signature'].replace('|',r'\|')
            scope=row['scope'].replace('|',r'\|')
            link='patterns/LMX_Fn_Receivers/'+row['source']
            lines.append(f"| `{signature}` | {scope} | [{Path(row['source']).name}]({link}) |")
        lines.append('')
    lines.extend([
        '## Integration and acceptance', '',
        '1. Preserve the existing complete graph, DATA ownership, declaration-argument behavior and '
        'ordinary interpreter/native dispatch. Do not introduce a second callable representation.',
        '2. Bind the narrow interfaces listed in the kernel requirements to existing kernel algorithms. '
        'An algorithm body is not replaced by a new opaque primitive with the same name.',
        '3. Include all catalog exports, operand metadata/priorities and named failures. Keep `replaceRange`, '
        '`splice` and text `replace` distinct; retain the exact existing `Name :: DATA` operand contract.',
        '4. Run the package acceptance cases and the comparison-specific cases on interpreter/native '
        'paths. A source-consistency check is not a runtime PASS.',
        '5. Use the [Fable merge packet](../fable_merge/README.md) to review against the exact uploaded '
        'preimages. Source changes and generated statistics are separate patches.', '',
        'Regeneration: `python3 patterns/LMX_Fn_Receivers/tools/rebuild_catalog.py`, then '
        '`python3 patterns/LMX_Fn_Receivers/tools/rebuild_core_inventory.py`. '
        'The kernel exports, inventory and examples must use the same public names.', '',
    ])
    (SPEC/'CORE_FUNCTIONS.md').write_text('\n'.join(lines),encoding='utf-8')
    print(json.dumps({'public_functions':len(catalog),'families':len(groups),'target':'CORE_FUNCTIONS.md'}))


if __name__=='__main__':main()
