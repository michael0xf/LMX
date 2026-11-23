"""Read the current packet's explicit metadata without changing any source."""
from pathlib import Path
import json


def addition_metadata(library):
    """Historical manifests may repeat an already registered public identity.

    A repeated name must keep the same callable target. Count that identity once;
    retain every declaring manifest for review rather than summing manifest sizes.
    """
    records = {}
    documents = []
    catalog_path=Path(library)/'catalog.json'
    catalog={entry['name']:entry for entry in json.loads(catalog_path.read_text())} if catalog_path.is_file() else {}
    for path in sorted(Path(library).glob('*ADDITIONS*.json')):
        document = json.loads(path.read_text())
        entries = document.get('entries', [])
        documents.append({'file': path.name, 'document': document})
        for entry in entries:
            name = entry['name']
            canonical=catalog.get(name,{})
            admitted={canonical.get('api')} | {v.get('api') for v in canonical.get('variants',[])}
            if name in records and records[name]['api'] != entry['api'] and not {records[name]['api'],entry['api']} <= admitted:
                raise ValueError(f"Conflicting addition target for {name}: {path.name}")
            if name not in records:
                records[name] = dict(entry, metadata_files=[])
                records[name]['variant_apis']=[]
            if entry['api'] not in records[name]['variant_apis']:
                records[name]['variant_apis'].append(entry['api'])
            if canonical:
                records[name]['api']=canonical['api']
                records[name]['source_file']=canonical['source']
            records[name]['metadata_files'].append(path.name)
    return list(records.values()), documents


def implementation_source(entry):
    """Accept both the original module key and a current explicit source path."""
    explicit = entry.get('source_file')
    if explicit:
        return explicit
    source = entry['source']
    if source.endswith('.lmx'):
        return source if source.startswith('src/') else 'src/' + source
    return 'src/' + source + '.lmx'


def restoration_metadata(patterns):
    path = Path(patterns) / 'validation/restoration_baseline_20261123.json'
    return json.loads(path.read_text())
