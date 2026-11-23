#!/usr/bin/env python3
"""Hash the final source/artifact tree, with explicitly ordered self exclusions."""
from pathlib import Path
import hashlib
import json

PATTERNS = Path(__file__).resolve().parents[1]
SPEC = PATTERNS.parent
PACKAGE = PATTERNS / 'LMX_Fn_Receivers'
BASE_SHA = '72eb7cc6e8ee8ede414b457184ce7a54807689a9068ab15e8e986a46e5b9a861'
ORIGINAL_SHA = '4b142bab169cf7cc3fd89766da35b90561f913b68dca3ab1f0725793e4ecb932'
SHORT_EXAMPLES_SHA = '59d38b4b5d20d5aa6d0e9dee785a75c86a7bc30ae7d261642aabf2f90344f2ba'


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
    current_additions = []
    for name in additions['addition_manifests']:
        current_additions.extend(json.loads((PACKAGE / name).read_text())['entries'])
    static = json.loads((PACKAGE / 'tests/STATIC_REPORT.json').read_text())
    assert not static['errors'], 'Fix source checks before publishing manifests'
    package_files = files(PACKAGE, {'MANIFEST.json'})
    write(PACKAGE / 'MANIFEST.json', {
        'revision': 'restored-examples-standard-core-sbcl-2026-11-23',
        'base_archive': '23-Nov-2026.tar.gz', 'base_archive_sha256': BASE_SHA,
        'short_examples_archive': '22-Nov-2026-3.tar.gz', 'short_examples_archive_sha256': SHORT_EXAMPLES_SHA,
        'original_project_archive': 'spec.tar.gz', 'original_project_archive_sha256': ORIGINAL_SHA,
        'public_receivers': len(catalog),
        'uploaded_public_operations_preserved': additions['input_archive_public_count'],
        'public_additions': [row['name'] for row in current_additions],
        'historical_original_public_count': additions['baseline_public_count'],
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
        'edition': '2026-11-23', 'base_archive': '23-Nov-2026.tar.gz', 'base_archive_sha256': BASE_SHA,
        'short_examples_archive': '22-Nov-2026-3.tar.gz', 'short_examples_archive_sha256': SHORT_EXAMPLES_SHA,
        'original_merge_base_archive': 'spec.tar.gz', 'original_merge_base_archive_sha256': ORIGINAL_SHA,
        'scope': 'Complete spec directory; fable_merge is a separate sibling packet',
        'self_excluded': True, 'excluded_metadata': ['.DS_Store', '__pycache__', '*.pyc', '.git'],
        'file_count_without_manifest': len(spec_files), 'files': spec_files,
    })
    print(json.dumps({'package_files': len(package_files), 'patterns_files': len(pattern_files),
                      'spec_files_with_manifest': len(spec_files) + 1}))


if __name__ == '__main__':
    main()
