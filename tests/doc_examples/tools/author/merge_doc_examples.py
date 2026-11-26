#!/usr/bin/env python3
"""Merge existing-format LMX documentation examples without running a parser.

The active catalogue remains README.md + index.tsv + places.tsv + src/*.lm[3x].
Text identity means CRLF/CR -> LF and exactly one final LF; indentation, spaces,
blank lines within the text and every other byte are preserved. Old source IDs
and recorded execution columns follow that identity, never a fuzzy match.

Usage:
  python -B merge_doc_examples.py ROOT --baseline IMMUTABLE_BASELINE
  python -B merge_doc_examples.py ROOT --baseline IMMUTABLE_BASELINE --check

Optional --path-map JSON maps root-relative old file paths to current file paths.
The default map, when present, is the Haskell migration from this editing run.
All project writes are strictly under ROOT/doc_examples. No spec file is edited.
"""
from __future__ import annotations

import argparse
import collections
import csv
import hashlib
import io
import json
import re
import tempfile
from pathlib import Path

INDEX_FIELDS = ['id', 'kind', 'places', 'p0', 'build', 'run', 'class', 'step_or_fix', 'note']
PLACE_FIELDS = ['id', 'doc', 'kind', 'block', 'line']
RETIRED_FIELDS = INDEX_FIELDS + ['source_sha256', 'source', 'retired_reason', 'successor_ids']
HISTORIC_PLACE_FIELDS = PLACE_FIELDS + ['revision', 'validity']
TRANSITION_FIELDS = ['old_id', 'old_sha256', 'new_id', 'new_sha256', 'evidence',
                     'prior_doc', 'prior_kind', 'prior_block', 'prior_line', 'prior_revision',
                     'current_doc', 'current_kind', 'current_block', 'current_line']
EXTRA_MARKDOWN = ('spec/ARROW_EXAMPLES.md',)


def normalized(data: bytes) -> bytes:
    return data.replace(b'\r\n', b'\n').replace(b'\r', b'\n').rstrip(b'\n') + b'\n'


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def tsv_rows(path: Path):
    if not path.exists():
        return []
    with path.open(encoding='utf-8', newline='') as stream:
        return list(csv.DictReader(stream, delimiter='\t'))


def tsv_text(fields, rows):
    stream = io.StringIO(newline='')
    writer = csv.DictWriter(stream, fieldnames=fields, delimiter='\t',
                            lineterminator='\n', extrasaction='ignore')
    writer.writeheader()
    writer.writerows(rows)
    return stream.getvalue()


def write_if_changed(path: Path, data: bytes):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() == data:
        return
    # Atomic replacement of this one file, without a temporary tree outside scope.
    with tempfile.NamedTemporaryFile(prefix='.merge-', dir=path.parent, delete=False) as stream:
        temporary = Path(stream.name)
        stream.write(data)
    temporary.replace(path)


def heading_key(text: str) -> str:
    text = re.sub(r'\s+#+\s*$', '', text).strip()
    text = re.sub(r'[`*_]', '', text)
    text = re.sub(r'\s+', ' ', text)
    # A case number is a stable section identity even if its explanatory title changed.
    match = re.match(r'^(?:[A-Z]{1,3}\d+[a-z]?|\d{2,3})[.: ]', text)
    return match.group(0).rstrip('.: ') if match else text


def scan_markdown(path: Path, root: Path, data: bytes):
    """CommonMark-style fences, same raw-body policy as the existing audit."""
    lines = data.replace(b'\r\n', b'\n').replace(b'\r', b'\n').splitlines(keepends=True)
    active = None
    ordinal = 0
    headings = []
    section_counts = collections.Counter()
    places = []
    for number, line in enumerate(lines, 1):
        plain = line.rstrip(b'\n')
        if active is None:
            heading = re.match(rb'^ {0,3}(#{1,6})[ \t]+(.+?)\s*$', plain)
            if heading:
                level = len(heading.group(1))
                label = heading_key(heading.group(2).decode('utf-8'))
                headings = [(depth, name) for depth, name in headings if depth < level]
                headings.append((level, label))
            match = re.fullmatch(rb'( {0,3})(`{3,}|~{3,})([^\r\n]*)', plain)
            if not match:
                continue
            indent, marker, info = match.groups()
            if marker.startswith(b'`') and b'`' in info:
                continue
            info = info.strip().decode('utf-8')
            language = info.split()[0].lower() if info else ''
            active = {'line': number + 1, 'char': marker[:1], 'width': len(marker),
                      'is_lmx': language == 'lmx', 'body': [],
                      'heading_path': [name for _, name in headings]}
        else:
            closing = re.fullmatch(rb' {0,3}(' + re.escape(active['char']) + rb'{'
                                   + str(active['width']).encode() + rb',})[ \t]*', plain)
            if closing:
                if active['is_lmx']:
                    ordinal += 1
                    section = tuple(active['heading_path'])
                    section_counts[section] += 1
                    code = normalized(b''.join(active['body']))
                    places.append({'doc': 'docs/' + path.relative_to(root).as_posix(),
                                   'kind': 'block', 'block': str(ordinal),
                                   'line': str(active['line']), 'data': code,
                                   'sha256': sha(code), 'heading_path': list(section),
                                   'section_ordinal': section_counts[section]})
                active = None
            else:
                active['body'].append(line)
    if active and active['is_lmx']:
        raise ValueError(f'Unclosed LMX fence: {path}:{active["line"] - 1}')
    for place in places:
        place['section_count'] = section_counts[tuple(place['heading_path'])]
    return places


def in_scope(path: Path, patterns: Path):
    suffix = path.suffix.lower()
    if suffix == '.md' or suffix == '.lm3':
        return True
    return suffix == '.lmx' and 'LMX_Fn_Receivers' not in path.relative_to(patterns).parts


def input_paths(root: Path):
    patterns = root / 'spec/patterns'
    paths = {path for path in patterns.rglob('*')
             if path.is_file() and in_scope(path, patterns)}
    paths.update(root/relative for relative in EXTRA_MARKDOWN if (root/relative).is_file())
    return sorted(paths)


def discover(root: Path):
    observations = []
    input_hashes = {}
    for path in input_paths(root):
        raw = path.read_bytes()
        if path.suffix.lower() == '.md':
            found = scan_markdown(path, root, raw)
            observations.extend(found)
            if found:
                input_hashes[path.relative_to(root).as_posix()] = sha(raw)
        else:
            input_hashes[path.relative_to(root).as_posix()] = sha(raw)
            code = normalized(raw)
            observations.append({'doc': 'docs/' + path.relative_to(root).as_posix(),
                                 'kind': 'file', 'block': '-', 'line': '1',
                                 'data': code, 'sha256': sha(code),
                                 'heading_path': [], 'section_ordinal': 0, 'section_count': 1})
    return observations, input_hashes


def snapshot_digest(hashes):
    return sha(json.dumps(hashes, ensure_ascii=False, sort_keys=True,
                          separators=(',', ':')).encode('utf-8'))


def place_key(place):
    return place['doc'], place['kind'], str(place['block'])


def strip_docs(path):
    return path.removeprefix('docs/')


def load_path_map(path: Path | None):
    if path is None or not path.exists():
        return {}
    return json.loads(path.read_text(encoding='utf-8'))


def remapped_doc(doc, mapping):
    relative = strip_docs(doc)
    return 'docs/' + mapping.get(relative, relative)


def load_catalogue(root: Path):
    directory = root / 'doc_examples'
    metadata = []
    texts = {}
    for row in tsv_rows(directory / 'index.tsv'):
        if row['id'].startswith('#'):
            metadata.append(row)
            continue
        candidates = [p for suffix in ('.lm3', '.lmx')
                      for p in (directory/'src'/(row['id']+suffix),
                                directory/'retired/src'/(row['id']+suffix)) if p.is_file()]
        if not candidates:
            raise ValueError('Missing source for catalogue ID ' + row['id'])
        raw = candidates[0].read_bytes()
        texts[row['id']] = {'row': {key: row[key] for key in INDEX_FIELDS},
                           'data': normalized(raw), 'extension': candidates[0].suffix}
    for row in tsv_rows(directory / 'retired.tsv'):
        source = directory / row['source']
        data = normalized(source.read_bytes())
        if row['id'] in texts:
            raise ValueError('ID is both active and retired: ' + row['id'])
        if sha(data) != row['source_sha256']:
            raise ValueError('Retired source hash drift: ' + row['id'])
        texts[row['id']] = {'row': {key: row[key] for key in INDEX_FIELDS},
                           'data': data, 'extension': source.suffix}
    active_places = tsv_rows(directory/'places.tsv')
    receipt_path = directory/'merge_receipt.json'
    receipt = json.loads(receipt_path.read_text()) if receipt_path.exists() else {}
    return texts, metadata, active_places, receipt


def source_id_prefix(place):
    if place['doc'] == 'docs/spec/ARROW_EXAMPLES.md':
        return 'ARROW_EXAMPLES'
    relative = Path(place['doc'].removeprefix('docs/spec/patterns/'))
    return relative.with_suffix('').as_posix().replace('/', '__')


def new_id(occurrences, reserved):
    # Markdown-backed texts use the established stable bNN rule, not the current ordinal.
    blocks = sorted((p for p in occurrences if p['kind'] == 'block'),
                    key=lambda p: (p['doc'], int(p['block'])))
    if blocks:
        prefix = source_id_prefix(blocks[0])
        number = 1
        while f'{prefix}.b{number:02}' in reserved:
            number += 1
        return f'{prefix}.b{number:02}', '.lm3'
    place = min(occurrences, key=lambda p: p['doc'])
    prefix = source_id_prefix(place)
    extension = Path(place['doc']).suffix.lower()
    if prefix not in reserved:
        return prefix, extension
    # File-only source versions need an opaque key distinct from the former bytes.
    number = 2
    while f'{prefix}.v{number:02}' in reserved:
        number += 1
    return f'{prefix}.v{number:02}', extension


def historic_observations(root, places, observation_map, revision):
    observations = []
    for place in places:
        observed = observation_map.get(place_key(place))
        if not observed:
            continue
        observations.append({key: value for key, value in observed.items() if key != 'data'}
                            | {'id': place['id'], 'revision': revision})
    return observations


def transition_rows(prior, current, path_map):
    """Only exact path/section-slot evidence; never infer a semantic replacement."""
    file_by_doc = {p['doc']: p for p in current if p['kind'] == 'file'}
    sections = collections.defaultdict(list)
    for place in current:
        if place['kind'] == 'block':
            sections[(place['doc'], tuple(place['heading_path']))].append(place)
    rows = []
    seen = set()
    for previous in prior:
        target_doc = remapped_doc(previous['doc'], path_map)
        current_place = None
        if previous['kind'] == 'file':
            current_place = file_by_doc.get(target_doc)
            evidence = 'renamed_source_file_path' if target_doc != previous['doc'] else 'source_file_path'
        else:
            group = sections.get((target_doc, tuple(previous.get('heading_path', []))), [])
            previous_count = previous.get('section_count', 0)
            if group and len(group) == previous_count:
                ordinal = previous.get('section_ordinal', 0)
                current_place = next((p for p in group if p['section_ordinal'] == ordinal), None)
            evidence = 'unique_document_section' if previous_count == 1 else 'unchanged_section_slot_count'
        if current_place is None or previous['sha256'] == current_place['sha256']:
            continue
        row = dict(old_id=previous['id'], old_sha256=previous['sha256'],
                   new_id=current_place['id'], new_sha256=current_place['sha256'],
                   evidence=evidence, prior_doc=previous['doc'], prior_kind=previous['kind'],
                   prior_block=str(previous['block']), prior_line=str(previous['line']),
                   prior_revision=previous['revision'], current_doc=current_place['doc'],
                   current_kind=current_place['kind'], current_block=str(current_place['block']),
                   current_line=str(current_place['line']))
        key = tuple(row[field] for field in TRANSITION_FIELDS)
        if key not in seen:
            seen.add(key)
            rows.append(row)
    return sorted(rows, key=lambda r: (r['old_id'], r['new_id'], r['prior_doc'], r['prior_line']))


def check(root: Path, baseline: Path):
    observations, hashes = discover(root)
    directory = root/'doc_examples'
    texts, metadata, active_places, receipt = load_catalogue(root)
    index = [r for r in tsv_rows(directory/'index.tsv') if not r['id'].startswith('#')]
    active = {r['id']: r for r in index}
    retired = {r['id']: r for r in tsv_rows(directory/'retired.tsv')}
    errors = []
    by_hash = {}
    for identifier, entry in texts.items():
        digest = sha(entry['data'])
        if digest in by_hash:
            errors.append('duplicate text: '+identifier+' and '+by_hash[digest])
        by_hash[digest] = identifier
    current_map = {place_key(p): p for p in observations}
    counts = collections.Counter()
    indexed_places = set()
    for place in active_places:
        key = place_key(place)
        if key in indexed_places:
            errors.append('duplicate active place '+repr(key))
        indexed_places.add(key)
        counts[place['id']] += 1
        observed = current_map.get(key)
        if place['id'] not in active:
            errors.append('place has no active index row '+place['id'])
        elif observed is None:
            errors.append('place absent from current source '+repr(key))
        elif observed['data'] != texts[place['id']]['data']:
            errors.append('place bytes differ '+repr(key))
        elif str(place['line']) != str(observed['line']):
            errors.append('place line differs '+repr(key))
    if indexed_places != set(current_map):
        errors.append('current occurrence set differs from places.tsv')
    for identifier, row in active.items():
        if int(row['places']) != counts[identifier] or not counts[identifier]:
            errors.append('wrong active place count '+identifier)
    expected_active = {identifier+texts[identifier]['extension'] for identifier in active}
    actual_active = {p.name for p in (directory/'src').iterdir() if p.is_file()}
    if actual_active != expected_active:
        errors.append('active src file set differs from index')
    expected_retired = {identifier+texts[identifier]['extension'] for identifier in retired}
    actual_retired = {p.name for p in (directory/'retired/src').iterdir() if p.is_file()} if (directory/'retired/src').exists() else set()
    if actual_retired != expected_retired:
        errors.append('retired source file set differs from retired.tsv')
    for folder in (directory/'src', directory/'retired/src'):
        for path in folder.glob('*'):
            if path.is_file() and normalized(path.read_bytes()) != path.read_bytes():
                errors.append('noncanonical LF/final LF '+str(path.relative_to(directory)))
    baseline_texts, _, _, _ = load_catalogue(baseline)
    for identifier, entry in baseline_texts.items():
        if identifier not in texts or texts[identifier]['data'] != entry['data']:
            errors.append('baseline ID/text was lost or reused '+identifier)
        if identifier in active:
            for field in ('p0','build','run','class','step_or_fix','note','kind'):
                if active[identifier][field] != entry['row'][field]:
                    errors.append('historical field changed for identical text '+identifier+'/'+field)
    if receipt.get('input_snapshot_sha256') != snapshot_digest(hashes):
        errors.append('source snapshot changed since merge')
    result = {'status': 'FAIL' if errors else 'PASS', 'errors': errors,
              'active_texts': len(active), 'active_places': len(active_places),
              'file_places': sum(p['kind']=='file' for p in active_places),
              'block_places': sum(p['kind']=='block' for p in active_places),
              'retired_texts': len(retired), 'parser_or_runtime_executed': False,
              'snapshot_sha256': snapshot_digest(hashes)}
    return result


def merge(root: Path, baseline: Path, path_map, revision):
    directory = root/'doc_examples'
    observations, input_hashes = discover(root)
    baseline_observations, _ = discover(baseline)
    baseline_map = {place_key(p): p for p in baseline_observations}
    baseline_texts, base_metadata, baseline_places, _ = load_catalogue(baseline)
    current_texts, current_metadata, previous_places, previous_receipt = load_catalogue(root)
    known = dict(baseline_texts)
    for identifier, value in current_texts.items():
        if identifier in known and known[identifier]['data'] != value['data']:
            raise ValueError('An existing ID was reused for different text: '+identifier)
        known[identifier] = value
    # A not-run marker is not a recorded parser return code. Keep the original
    # catalogue's '-' convention for an unavailable result, with explicit
    # NOT_RUN state in the note and receipt. Historical baseline codes are intact.
    for identifier, item in known.items():
        if identifier not in baseline_texts and item['row']['p0'] == 'NOT_RUN':
            item['row']['p0'] = '-'
        if identifier not in baseline_texts:
            note = item['row']['note']
            if note.startswith('добавлено или изменено редакцией '):
                item['row']['note'] = re.sub(
                    r'^добавлено или изменено редакцией \d{4}-\d{2}-\d{2};',
                    f'добавлено или изменено редакцией {revision};', note)
    by_hash = {}
    for identifier, item in sorted(known.items()):
        digest = sha(item['data'])
        if digest in by_hash:
            raise ValueError('Different IDs already store identical text: '+identifier+' / '+by_hash[digest])
        by_hash[digest] = identifier
    occurrences = collections.defaultdict(list)
    for place in observations:
        occurrences[place['sha256']].append(place)
    reserved = set(known)
    active = {}
    allocated = []
    # Choose deterministically by location rather than hash order.
    hashes_by_location = sorted(occurrences, key=lambda h: min((p['doc'], p['kind'], int(p['line'])) for p in occurrences[h]))
    for digest in hashes_by_location:
        places = occurrences[digest]
        if digest in by_hash:
            identifier = by_hash[digest]
        else:
            identifier, extension = new_id(places, reserved)
            reserved.add(identifier)
            allocated.append(identifier)
            row = dict(id=identifier, kind='fragment', places='0', p0='-',
                       build='-', run='-', **{'class':'не проверен'}, step_or_fix='-',
                       note=f'добавлено или изменено редакцией {revision}; P0 NOT_RUN: production parser недоступен; новый текст, прежний вердикт не переносился')
            known[identifier] = {'row':row,'data':places[0]['data'],'extension':extension}
            by_hash[digest] = identifier
        row = dict(known[identifier]['row'])
        row['places'] = str(len(places))
        active[identifier] = row
        for place in places:
            place['id'] = identifier

    prior = historic_observations(baseline, baseline_places, baseline_map, 'baseline:2026-11-24')
    # Previous merge anchors were recorded when those exact documents were current.
    prior.extend(previous_receipt.get('active_place_anchors', []))
    # Stable historical transitions keep their original prior-side observations.
    prior.extend(previous_receipt.get('retired_place_anchors', []))
    unique_prior = {}
    for place in prior:
        key = (place['id'],place['doc'],place['kind'],str(place['block']),str(place['line']),place['revision'])
        unique_prior[key] = place
    prior = list(unique_prior.values())
    transitions = transition_rows(prior, observations, path_map)
    successors = collections.defaultdict(set)
    for row in transitions:
        successors[row['old_id']].add(row['new_id'])
    retired_ids = set(known) - set(active)
    retired_rows = []
    for identifier in sorted(retired_ids):
        item = known[identifier]
        retired_rows.append(dict(item['row'], source_sha256=sha(item['data']),
                                 source=f'retired/src/{identifier}{item["extension"]}',
                                 retired_reason='changed_at_recorded_place' if successors[identifier] else 'no_current_occurrence',
                                 successor_ids=';'.join(sorted(successors[identifier]))))
    historic_places = []
    for place in sorted(prior, key=lambda p:(p['id'],p['doc'],int(p['line']),p['revision'])):
        if place['id'] in retired_ids:
            historic_places.append({key:str(place[key]) for key in PLACE_FIELDS} |
                                   {'revision':place['revision'],'validity':'historical_not_active'})

    current_digest = snapshot_digest(input_hashes)
    anchors = [{key:value for key,value in place.items() if key!='data'} |
               {'revision':revision+':'+current_digest[:16]} for place in observations]
    baseline_ids = set(baseline_texts)
    summary = {'active_texts':len(active),'active_places':len(observations),
               'file_places':sum(p['kind']=='file' for p in observations),
               'block_places':sum(p['kind']=='block' for p in observations),
               'unchanged_baseline_texts':len(set(active)&baseline_ids),
               'new_active_texts_since_baseline':len(set(active)-baseline_ids),
               'retired_baseline_texts':len(baseline_ids-set(active)),
               'retired_texts_all_known_revisions':len(retired_ids),
               'new_ids_ever_allocated_since_baseline':len(set(known)-baseline_ids),
               'p0_recorded_not_rerun':dict(collections.Counter(row['p0'] for row in active.values())),
               'classes':dict(collections.Counter(row['class'] for row in active.values())),
               'kinds':dict(collections.Counter(row['kind'] for row in active.values())),
               'traceability_rows':len(transitions)}
    receipt = {'format':'doc-examples-merge-v1','revision':revision,
               'normalization':'CRLF/CR to LF; exactly one final LF; all other bytes, spaces and indentation preserved',
               'scope':'all .lm3, non-package .lmx, and lmx-tagged Markdown fences under spec/patterns, plus explicit spec/ARROW_EXAMPLES.md',
               'explicit_additional_markdown':list(EXTRA_MARKDOWN),
               'parser_execution':'NOT_RUN','build_execution':'NOT_RUN','runtime_execution':'NOT_RUN',
               'unverified_p0_representation':"index.tsv p0='-' and class='не проверен'; note and receipt explicitly say NOT_RUN",
               'input_snapshot_sha256':current_digest,'input_hashes':input_hashes,
               'baseline_index_sha256':sha((baseline/'doc_examples/index.tsv').read_bytes()),
               'summary':summary,'allocated_ids_since_baseline':sorted(set(known)-baseline_ids),
               'active_place_anchors':anchors,
               'retired_place_anchors':[p for p in prior if p['id'] in retired_ids],
               'transition_policy':'Exact file path (including explicit migration map), or same Markdown heading path with equal block-slot counts. This records changed occurrence slots, not inferred semantic equivalence. No fuzzy matching.',
               'file_version_policy':'A changed file-only text whose path-derived ID is already reserved receives .v02, .v03, etc. Old IDs never change their code.'}

    readme = f'''# Примеры документации как программы

Каталог объединяет LMX-примеры из `spec/patterns` в принятом формате: исходные `.lm3`, блоки Markdown с меткой `lmx` и `.lmx` вне пакета `LMX_Fn_Receivers`. По отдельному указанию автора включён также **`spec/ARROW_EXAMPLES.md`**, в том числе самостоятельный пример с `@Binary: add`. В `places.tsv` сохранены проектные пути: `docs/spec/patterns/...` и дополнительный `docs/spec/ARROW_EXAMPLES.md`; в этом архиве им соответствуют `spec/patterns/...` и `spec/ARROW_EXAMPLES.md` рядом с `doc_examples`. Один различный текст хранится один раз; все его действующие места перечислены отдельно.

Исходные `.lmx` самого пакета `LMX_Fn_Receivers` не включаются: у них остаётся собственная приёмка ядра. Его Markdown-блоки включаются как обычные примеры документации. Код Haskell, Julia, Scala, Perl и других языков не добавляется в LMX-каталог. Вне `spec/patterns` включён только явно названный `ARROW_EXAMPLES.md`; массовый сбор остальных документов `spec` не выполняется. Табличные объявления стрелки отдельно покрывает исходник `patterns/examples/signatures/arrow_signatures.lm3`, но он не заменяет самостоятельные блоки этого документа.

## Состояние редакции {revision}

В активном каталоге **{summary['active_texts']} различных текстов** и **{summary['active_places']} действующих мест**: {summary['file_places']} файловых и {summary['block_places']} блочных. По сравнению с базовым каталогом {summary['unchanged_baseline_texts']} текстов сохранили исходные байты и идентификаторы, {summary['new_active_texts_since_baseline']} активных текстов новые, {summary['retired_baseline_texts']} прежних текстов больше не встречаются в текущей документации.

**Новый production P0/parser, сборка Graph и интерпретатор здесь не запускались.** Для нового или изменённого текста в прежнем TSV-формате стоит `p0=-`, класс `не проверен`, `build/run=-`; в примечании и JSON receipt это состояние явно названо **NOT_RUN**. Знак `-` не является кодом успешного разбора. Прежние `p0`, `build`, `run`, класс, вид и примечание сохранены только для точно того же текста после описанной ниже нормализации. Это исторические результаты, а не подтверждение исполнения этой редакции. В активном индексе сейчас: {', '.join(str(value)+' с p0='+key for key,value in sorted(summary['p0_recorded_not_rerun'].items()))}.

Исходная редакция 2026-11-24 содержала 432 текста и 839 мест. Её P0-приёмка через lmx-dev (`hosted-static-21-7`, Graph `dfa3bc9a`) и более ранние пометки остаются в соответствующих строках только при неизменном коде. Известный долг группового `:=` не исправляется добавлением скобок и не объявляется прошедшим разбором. Строка `#graph` по-прежнему описывает историческую Graph-сборку колонок build/run.

## Формат и идентичность текста

- `src/<id>.lm3` или `src/<id>.lmx` — единственный активный экземпляр текста. Нормализация **только** заменяет CRLF/CR на LF и оставляет ровно один завершающий LF. Пробелы, отступы, начальные и внутренние пустые строки не удаляются; `.strip()` к коду не применяется.
- `places.tsv` содержит прежние колонки `id`, `doc`, `kind`, `block`, `line`. Для файла `kind=file`, `block=-`, `line=1`. Для Markdown `block` — действующий номер LMX-блока в документе, `line` — первая строка его содержимого. Эти координаты вычислены по текущим исходникам.
- `index.tsv` сохраняет прежние девять колонок и строку `#graph`. `places` — текущее количество мест. `p0=0` означает ранее зафиксированный успешный разбор; `p0=-` с классом `не проверен` означает **NOT_RUN**, то есть разбор нового текста не выполнялся. В колонку с результатом P0 не добавляется новый словесный код. Знак `-` в build/run также означает отсутствие соответствующего исполнения.
- Идентификатор `.bNN` — устойчивый ключ текста, а не текущий порядковый номер блока. Неизменный код сохраняет ID даже после переноса документа. Для нового текста берётся свободный номер документа; IDs активных и уже снятых текстов зарезервированы.
- Собственные новые блоки дополнительного документа получают ключи `ARROW_EXAMPLES.bNN`. Его канонический путь в places — `docs/spec/ARROW_EXAMPLES.md`; обходы через `../` для прохождения старой проверки префикса не используются.
- Идентификатор файлового текста строится из пути от `spec/patterns`, без расширения, с `__` вместо `/`. Если изменённый текст есть также в Markdown, используется новый `.bNN`. Для **file-only** версии, чей прежний path-ID уже занят другими байтами, добавляется `.v02`, `.v03` и далее. Это различает версии без переиспользования старого ID и переноса чужого P0.
- Новые тексты временно имеют справочный вид `fragment`; классификацию `program` для полного runtime-прогона определяет исполнитель. Вид ранее существовавшего неизменного текста сохранён.

## Снятые тексты и происхождение изменений

`retired.tsv` и `retired/src` содержат **{summary['retired_texts_all_known_revisions']}** прежних текстов, которых сейчас нет в области обхода. Их исходные ID, байты, SHA-256 и исторические результаты сохранены. Они исключены из активных `src`, `index.tsv` и `places.tsv`; одинаковый текст не хранится одновременно в active и retired.

`retired_places.tsv` — исторические координаты, явно помеченные `historical_not_active`. Они не выдаются за действующие ссылки. `transitions.tsv` связывает изменившееся место с текущим ID только по проверяемому совпадению файлового пути, явному переносу пути или устойчивому разделу Markdown. Это запись о смене текста в месте, не утверждение семантической эквивалентности. Там, где однозначного соответствия нет, successor не выдумывается. Возврат ранее снятого неизменного текста активирует прежний ID.

`merge_receipt.json` сохраняет хэши входных документов, точный снимок обнаруженных мест и итог сверки. Поля `parser_execution`, `build_execution` и `runtime_execution` равны `NOT_RUN`; статическая сверка каталога не является parser receipt.

## Классы

Классы прежнего формата сохранены: `fixed`, `parser-debt:<шаг>`, `refused`, `doubt`, `не проверен`, `-`. Класс задаётся нормой и историей приёмки, а не автоматически объявляется успешным по совпадению файлов. Новый текст получает `не проверен` до реального разбора.

## Повторная сборка и сверка

Внешний скрипт `merge_doc_examples.py ROOT --baseline BASELINE` повторно читает текущие документы, дедуплицирует нормализованный текст и обновляет координаты. Его режим `--check` проверяет активные места, исходники, хэши, отсутствие дублей и сохранение исходных ID/результатов. Скрипт не изменяет `spec` и не запускает production parser. После любой правки Markdown его следует повторить, чтобы номера строк снова соответствовали текущему дереву.

Независимая scope-aware копия `audit_merged_catalogue.py` исходного аудитора сверяет активный каталог с документацией и единственным явно добавленным `ARROW_EXAMPLES.md`. Старый `audit_catalogue.py` знает только прежнюю область patterns. Файлы retired не являются текущими примерами и не должны попадать в обычный активный прогон.
'''

    # If another agent regenerated a source while discovery/planning ran, do not
    # publish a mixed snapshot. Rerunning after that writer finishes is sufficient.
    _, fresh_hashes = discover(root)
    if fresh_hashes != input_hashes:
        raise RuntimeError('Documentation changed during discovery; no catalogue files written. Rerun merge.')

    for identifier, row in active.items():
        item = known[identifier]
        write_if_changed(directory/'src'/(identifier+item['extension']), item['data'])
    for identifier in retired_ids:
        item = known[identifier]
        write_if_changed(directory/'retired/src'/(identifier+item['extension']), item['data'])
    metadata = current_metadata or base_metadata
    write_if_changed(directory/'index.tsv', tsv_text(INDEX_FIELDS, metadata+[active[k] for k in sorted(active)]).encode())
    ordered_places = sorted(observations, key=lambda p:(p['doc'], 0 if p['kind']=='file' else 1, int(p['line'])))
    write_if_changed(directory/'places.tsv', tsv_text(PLACE_FIELDS, ordered_places).encode())
    write_if_changed(directory/'retired.tsv', tsv_text(RETIRED_FIELDS, retired_rows).encode())
    write_if_changed(directory/'retired_places.tsv', tsv_text(HISTORIC_PLACE_FIELDS, historic_places).encode())
    write_if_changed(directory/'transitions.tsv', tsv_text(TRANSITION_FIELDS, transitions).encode())
    write_if_changed(directory/'README.md', readme.encode())
    # The receipt intentionally describes the snapshot, not elapsed time, so a
    # no-op rerun can be compared byte-for-byte once the allocated IDs are settled.
    write_if_changed(directory/'merge_receipt.json', (json.dumps(receipt, ensure_ascii=False, indent=2)+'\n').encode())
    allowed_active = {identifier+known[identifier]['extension'] for identifier in active}
    for path in (directory/'src').glob('*'):
        if path.is_file() and path.name not in allowed_active:
            path.unlink()
    allowed_retired = {identifier+known[identifier]['extension'] for identifier in retired_ids}
    for path in (directory/'retired/src').glob('*'):
        if path.is_file() and path.name not in allowed_retired:
            path.unlink()
    result = check(root, baseline)
    return dict(summary, new_ids_allocated_this_run=len(allocated)), result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', type=Path)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--revision', default='2026-11-24')
    parser.add_argument('--path-map', type=Path,
                        default=Path(__file__).parent/'haskell/path_mapping.json')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    root, baseline = args.root.resolve(), args.baseline.resolve()
    if root == baseline:
        parser.error('The immutable baseline must not be the writable working root')
    if args.check:
        result = check(root, baseline)
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        summary, result = merge(root, baseline, load_path_map(args.path_map), args.revision)
        print(json.dumps({'merge':summary,'verification':result}, ensure_ascii=False, indent=2))
    raise SystemExit(0 if result['status']=='PASS' else 1)


if __name__ == '__main__':
    main()
