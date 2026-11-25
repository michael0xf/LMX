#!/usr/bin/env python3
"""Hash the final source/artifact tree, with explicitly ordered self exclusions."""
from pathlib import Path
import hashlib
import json

PATTERNS = Path(__file__).resolve().parents[1]
SPEC = PATTERNS.parent
PACKAGE = PATTERNS / 'LMX_Fn_Receivers'


def files(root, exclude):
    result = []
    for path in sorted(root.rglob('*')):
        if not path.is_file() or path.name in {'.DS_Store'} or path.suffix == '.pyc':
            continue
        if '__pycache__' in path.parts or '.git' in path.parts:
            continue
        relative = path.relative_to(root).as_posix()
        if relative in exclude:
            continue
        if path.is_symlink():
            raise ValueError('Unexpected symlink: ' + str(path))
        raw = path.read_bytes()
        result.append({'path': relative, 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()})
    return result


def write(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n')


def main():
    provenance = json.loads((PATTERNS / 'validation/expansion_baseline_20261124.json').read_text())
    base = provenance['base_archive']
    historical = provenance.get('historical_provenance', {})
    catalog = json.loads((PACKAGE / 'catalog.json').read_text())
    additions = json.loads((PACKAGE / 'CORE_ADDITIONS_20261123.json').read_text())
    current_additions = []
    for name in additions['addition_manifests']:
        current_additions.extend(json.loads((PACKAGE / name).read_text())['entries'])
    static = json.loads((PACKAGE / 'tests/STATIC_REPORT.json').read_text())
    assert not static['errors'], 'Fix source checks before publishing manifests'
    package_files = files(PACKAGE, {'MANIFEST.json'})
    write(PACKAGE / 'MANIFEST.json', {
        'revision': 'examples-expansion-current-statistics-doc-examples-2026-11-24',
        'base_archive': base['name'], 'base_archive_sha256': base['sha256'],
        'historical_provenance': historical,
        'public_receivers': len(catalog),
        'uploaded_public_operations_before_canonicalization': base['public_names'],
        'historical_public_additions': [row['name'] for row in current_additions],
        'historical_original_public_count': additions['baseline_public_count'],
        'other_named_pattern_symbols': len(json.loads((PACKAGE / 'value_symbols.json').read_text())),
        'implementation_layer': 'single_current_core',
        'kernel_bridges': len(static['provider_methods']),
        'provider_methods': static['provider_methods'],
        'source_parts': static['source_parts'], 'source_lines': static['source_lines'],
        'prepared_assertions': static['prepared_assertions'],
        'named_signature_form': 'Name :: Signature through the ordinary Expression operand protocol; no separate Frame',
        'type_constructor': '->: ordered TYPE inputs followed by the result TYPE',
        'postfix_type_forms': ['Struct@: ptr', 'type[]: array'],
        'runtime_executed': False, 'manifest_self_excluded': True,
        'files': package_files,
    })
    sbcl = PATTERNS / 'examples/SBCL_comparison'
    sbcl_files = files(sbcl, {'MANIFEST.sha256'})
    (sbcl / 'MANIFEST.sha256').write_text(''.join(f"{row['sha256']}  {row['path']}\n" for row in sbcl_files))
    pattern_files = files(PATTERNS, {'MANIFEST.sha256'})
    (PATTERNS / 'MANIFEST.sha256').write_text(''.join(f"{row['sha256']}  {row['path']}\n" for row in pattern_files))
    spec_files = files(SPEC, {'ARCHIVE_MANIFEST.json'})
    write(SPEC / 'ARCHIVE_MANIFEST.json', {
        'edition': '2026-11-24', 'base_archive': base['name'], 'base_archive_sha256': base['sha256'],
        'historical_provenance': historical,
        'scope': 'Complete post-merge spec directory, including integrated contracts, sources, comparisons and answers to Fable; not the member list of the changes-only archive.',
        'delivery_mode': 'changes_only',
        'delta_manifest': 'CHANGES_2026-11-24.json at archive root',
        'fable_answers': 'FABLE_CLARIFICATIONS.md',
        'self_excluded': True, 'excluded_metadata': ['.DS_Store', '__pycache__', '*.pyc', '.git'],
        'file_count_without_manifest': len(spec_files), 'files': spec_files,
    })
    print(json.dumps({'package_files': len(package_files), 'patterns_files': len(pattern_files),
                      'spec_files_with_manifest': len(spec_files) + 1}))


if __name__ == '__main__':
    main()
