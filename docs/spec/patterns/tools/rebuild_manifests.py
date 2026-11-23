#!/usr/bin/env python3
"""Hash the final source/artifact tree, with explicitly ordered self exclusions."""
from pathlib import Path
import hashlib
import json

PATTERNS = Path(__file__).resolve().parents[1]
SPEC = PATTERNS.parent
PACKAGE = PATTERNS / 'LMX_Fn_Receivers'
BASE_SHA = '4b142bab169cf7cc3fd89766da35b90561f913b68dca3ab1f0725793e4ecb932'


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
    catalog = json.loads((PACKAGE / 'catalog.json').read_text())
    additions = json.loads((PACKAGE / 'CORE_ADDITIONS_20261123.json').read_text())
    static = json.loads((PACKAGE / 'tests/STATIC_REPORT.json').read_text())
    assert not static['errors'], 'Fix source checks before publishing manifests'
    package_files = files(PACKAGE, {'MANIFEST.json'})
    write(PACKAGE / 'MANIFEST.json', {
        'revision': 'core-comparisons-julia-perl-2026-11-23',
        'base_archive': 'spec.tar.gz', 'base_archive_sha256': BASE_SHA,
        'public_receivers': len(catalog),
        'uploaded_public_operations_preserved': additions['baseline_public_count'],
        'public_additions': [row['name'] for row in additions['entries']],
        'other_named_pattern_symbols': len(json.loads((PACKAGE / 'value_symbols.json').read_text())),
        'implementation_layer': 'single_current_core',
        'kernel_bridges': len(static['provider_methods']),
        'provider_methods': static['provider_methods'],
        'source_parts': static['source_parts'], 'source_lines': static['source_lines'],
        'prepared_assertions': static['prepared_assertions'],
        'named_signature_form': 'Name :: Signature through the ordinary Expression operand protocol; no separate Frame',
        'type_constructor': 'signatureTypes',
        'postfix_type_forms': ['Struct@: ptr', 'type[]: array'],
        'runtime_executed': False, 'manifest_self_excluded': True,
        'files': package_files,
    })
    pattern_files = files(PATTERNS, {'MANIFEST.sha256'})
    (PATTERNS / 'MANIFEST.sha256').write_text(''.join(f"{row['sha256']}  {row['path']}\n" for row in pattern_files))
    spec_files = files(SPEC, {'ARCHIVE_MANIFEST.json'})
    write(SPEC / 'ARCHIVE_MANIFEST.json', {
        'edition': '2026-11-23', 'base_archive': 'spec.tar.gz', 'base_archive_sha256': BASE_SHA,
        'scope': 'Complete spec directory; fable_merge is a separate sibling packet',
        'self_excluded': True, 'excluded_metadata': ['.DS_Store', '__pycache__', '*.pyc', '.git'],
        'file_count_without_manifest': len(spec_files), 'files': spec_files,
    })
    print(json.dumps({'package_files': len(package_files), 'patterns_files': len(pattern_files),
                      'spec_files_with_manifest': len(spec_files) + 1}))


if __name__ == '__main__':
    main()
