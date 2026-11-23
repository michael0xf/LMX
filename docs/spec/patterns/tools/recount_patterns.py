#!/usr/bin/env python3
"""Recount and validate the nine extended LMX pattern groups.

Run from the unpacked archive root (or use the script's absolute path elsewhere):
    python tools/recount_patterns.py
    python tools/recount_patterns.py --json recount-report.json
    python tools/recount_patterns.py --root path/to/new_parts --json report.json

Only Python's standard library is used. This checks publication consistency,
not language semantics or execution of the example programs. XLSX is checked
for a valid workbook ZIP container; PDF for file presence/signature. Workbook
cell calculations and page rendering remain separate validation tasks.
"""
from __future__ import annotations

import argparse
from lmx_style_variants import validate_variants
import codecs
import csv
import hashlib
import io
import json
import re
import sys
import zipfile
from collections import Counter
from pathlib import Path

LANGUAGES = {
    "LMX": ("lmx", "lm3", "lmx"),
    "TypeScript": ("typescript", "ts", "typescript"),
    "C#": ("csharp", "cs", "csharp"),
    "Java": ("java", "java", "java"),
    "Go": ("go", "go", "go"),
    "Python": ("python", "py", "python"),
    "Erlang": ("erlang", "erl", "erlang"),
    "Rust": ("rust", "rs", "rust"),
    "Haskell": ("haskell", "hs", "haskell"),
    "Scala": ("scala", "scala", "scala"),
}
SCOPES_RU = {
    "core": "Ядро сценария",
    "protocol": "Протокол и порты",
    "executable": "Самостоятельный пример",
}


def canonical_code(code: str) -> str:
    """Exactly the normalization used for the published source files."""
    return code.strip() + "\n"


def historical_code(alternative: dict) -> str:
    """Show required context before the separately retained original client."""
    prefix = alternative.get('context_prefix', '')
    return (canonical_code(prefix) + '\n' if prefix else '') + canonical_code(alternative['code'])


PROCEDURAL_BEGIN = "# BEGIN PROCEDURAL LMX (excluded from character counts)"
PROCEDURAL_END = "# END PROCEDURAL LMX"
ALTERNATIVE_BEGIN = "# BEGIN ALTERNATIVE LMX (excluded from character counts)"
ALTERNATIVE_END = "# END ALTERNATIVE LMX"


def source_parts(text: str) -> tuple[str, str | None]:
    """Count the current listing, retaining the archived original for review."""
    begin,end = (ALTERNATIVE_BEGIN,ALTERNATIVE_END) if ALTERNATIVE_BEGIN in text else (PROCEDURAL_BEGIN,PROCEDURAL_END)
    if begin not in text:
        return text, None
    primary, archive = text.split(begin, 1)
    if end not in archive:
        raise ValueError("Missing end of the alternative LMX listing")
    archive, tail = archive.split(end, 1)
    if tail.strip():
        raise ValueError("Unexpected content after the procedural LMX archive")
    lines = archive.strip("\r\n").splitlines()
    if any(not line.startswith("# ") and line != "#" for line in lines):
        raise ValueError("Procedural LMX must be entirely commented out")
    old = "\n".join(line[2:] if line.startswith("# ") else "" for line in lines)
    return canonical_code(primary), canonical_code(old)


def metrics(code: str) -> dict[str, int]:
    return {
        "nonwhitespace_characters": sum(not ch.isspace() for ch in code),
        "nonblank_lines": sum(bool(line.strip()) for line in code.splitlines()),
        "utf8_bytes": len(code.encode("utf-8")),
    }


def fenced_blocks(text: str) -> tuple[list[tuple[str, str]], bool]:
    """Read unindented Markdown fences; preserve code whitespace exactly."""
    blocks = []
    fence = None
    language = ""
    body: list[str] = []
    for line in text.splitlines(keepends=True):
        if fence is None:
            found = re.match(r"^ {0,3}(`{3,}|~{3,})([^\r\n]*)\r?\n?$", line)
            if found:
                fence = found.group(1)
                language = found.group(2).strip()
                body = []
        else:
            closing = re.match(r"^ {0,3}([`~]+)[ \t]*\r?\n?$", line)
            if closing and set(closing.group(1)) == {fence[0]} and len(closing.group(1)) >= len(fence):
                blocks.append((language, "".join(body)))
                fence = None
            else:
                body.append(line)
    return blocks, fence is None


def split_table_row(line: str) -> list[str]:
    """The generated comparison tables have no unescaped pipes in cells."""
    return [part.strip() for part in re.split(r"(?<!\\)\|", line.strip())[1:-1]]


def audit(root: Path) -> dict:
    """Validate actual comparison boundaries without selecting a shorter style."""
    errors = []
    groups = []
    all_ids = []
    pattern_ids = []
    implementation_ids = []
    styled_ids = []
    compatibility_listing_count = 0
    listing_count = 0
    total_bytes = 0

    def relative(path):
        try:
            return path.relative_to(root).as_posix()
        except ValueError:
            return path.name

    def fail(path, message):
        errors.append({'file': relative(path), 'message': message})

    def read_text(path):
        try:
            return path.read_text(encoding='utf-8')
        except (OSError, UnicodeError) as exc:
            fail(path, f'Cannot read UTF-8 text: {exc.__class__.__name__}: {exc}')
            return None

    def cell(value):
        return value.replace('**', '').strip()

    def table_rows(text):
        return [[cell(value) for value in split_table_row(line)]
                for line in (text or '').splitlines() if line.startswith('|')]

    try:
        manifest = json.loads((root/'comparison_sources/catalog_manifest.json').read_text())
        expected_ids = set(manifest['pattern_ids']) | set(manifest['implementation_ids'])
        if manifest['pattern_ids'] != list(range(1, 91)) or manifest['implementation_ids'] != list(range(91, 100)):
            fail(root/'comparison_sources/catalog_manifest.json', 'Expected the retained 90 scenarios and nine implementation identities')
    except (OSError, ValueError, KeyError) as exc:
        return {'ok': False, 'error_count': 1, 'errors': [{'file': 'comparison_sources/catalog_manifest.json', 'message': str(exc)}]}

    try:
        publication = json.loads((root/'PUBLICATION_DATA.json').read_text())
        documents = {item['stem']: item for item in publication['documents']}
    except (OSError, ValueError, KeyError) as exc:
        fail(root/'PUBLICATION_DATA.json', f'Cannot read the current publication model: {exc}')
        documents = {}

    json_files = sorted(root.glob('[0-9][0-9]_*/patterns.json'))
    if len(json_files) != 9:
        fail(root, f'Expected nine group source indexes; found {len(json_files)}')
    for json_file in json_files:
        directory = json_file.parent
        group_name = directory.name
        raw = read_text(json_file)
        if raw is None:
            continue
        try:
            data = json.loads(raw)
        except json.JSONDecodeError as exc:
            fail(json_file, f'Invalid JSON: {exc}')
            continue
        controls = data.get('languages', [])
        if not isinstance(controls, list) or len(controls) != 2 or len(set(controls)) != 2 or 'LMX' in controls:
            fail(json_file, 'languages must contain exactly two distinct foreign controls')
            continue
        languages = ['LMX'] + controls
        if any(language not in LANGUAGES for language in languages):
            fail(json_file, f'Unsupported language mapping: {languages}')
            continue
        records = data.get('patterns', [])
        if not isinstance(records, list) or any(not isinstance(record, dict) for record in records):
            fail(json_file, 'patterns must be an array of records')
            continue
        expected_sources = set()
        expected_markdown = set()
        expected_csv = []
        pattern_reports = []
        group_comparisons = 0
        comparison_path = directory/f'LMX_Comparison_{group_name}.md'
        comparison_text = read_text(comparison_path)
        summary_table = table_rows(comparison_text)
        summary_rows = {}
        for row in summary_table:
            if row and row[0].isdigit():
                identifier = int(row[0])
                if identifier in summary_rows:
                    fail(comparison_path, f'Duplicate summary row for ID {identifier}')
                summary_rows[identifier] = row
        document = documents.get(f'{group_name}/LMX_Comparison_{group_name}', {})
        expected_table = []
        for view in document.get('sheets', []):
            for table in view.get('tables', []):
                expected_table.append([value.replace('\n', ' ') for value in table['headers']])
                rows = table['rows'] + ([table['total']['values']] if table.get('total') else [])
                expected_table += [['—' if value is None else str(value).replace('|', '\\|').replace('\n', ' ')
                                    for value in row] for row in rows]
        observed_table = [row for row in summary_table if not all(re.fullmatch(r':?-+:?', value) for value in row)]
        if not expected_table or observed_table != expected_table:
            fail(comparison_path, 'Summary tables differ from the current complete-source publication model')
        is_functional = group_name.startswith('09_')

        ordered = sorted(records, key=lambda record: (record.get('paired_with', record['id']), record.get('kind', 'pattern') == 'implementation', record['id']))
        for record in ordered:
            identifier = record.get('id')
            if type(identifier) is not int:
                fail(json_file, f'Non-integer pattern ID: {identifier!r}')
                continue
            all_ids.append(identifier)
            kind = record.get('kind', 'pattern')
            layer = ('implementation' if kind == 'implementation' else 'shared_implementation_client'
                     if record.get('comparison_level') == 'shared_implementation_client' else 'usage'
                     if record.get('implementation_ids') else 'scenario')
            if kind == 'implementation':
                implementation_ids.append(identifier)
                if record.get('paired_with') not in range(1, 91):
                    fail(json_file, f'ID {identifier}: missing valid client pairing')
            elif kind == 'pattern':
                pattern_ids.append(identifier)
            else:
                fail(json_file, f'ID {identifier}: unknown record kind {kind!r}')
            slug = record.get('slug', '')
            if not isinstance(slug, str) or not re.fullmatch(r'[a-z0-9][a-z0-9_]*', slug):
                fail(json_file, f'ID {identifier}: invalid ASCII snake_case slug')
                continue
            stem = f'{identifier:03d}_{slug}'
            markdown_name = stem+'_comparision.md'
            expected_markdown.add(markdown_name)
            markdown_path = directory/markdown_name
            markdown_text = read_text(markdown_path)
            blocks, closed = fenced_blocks(markdown_text or '')
            if not closed:
                fail(markdown_path, 'Unclosed Markdown fence')
            listings = record.get('listings', [])
            if [listing.get('language') for listing in listings] != languages:
                fail(json_file, f'ID {identifier}: expected compatibility mirrors in {languages} order')
                continue
            styled = bool(record.get('lmx_variants'))
            if styled:
                styled_ids.append(identifier)
                if kind == 'implementation':
                    fail(json_file, f'ID {identifier}: shared implementation must have one canonical body')
                for issue in validate_variants(record, directory):
                    fail(json_file, f'ID {identifier}: {issue}')
                if listings[0]['code'] != record['lmx_variants']['functional']['code']:
                    fail(json_file, f'ID {identifier}: LMX compatibility field differs from functional style')
            expected_blocks = []
            measured = {}
            style_metrics = {}
            counted = []
            csv_row = {'id': str(identifier), 'pattern': record.get('name', ''), 'kind': kind,
                       'source': markdown_name}
            if not is_functional:
                csv_row.update(scope=record.get('scope', ''), layer=layer)
            elif styled:
                csv_row['LMX_implementation_characters'] = ''
                csv_row['LMX_implementation_nonblank_lines'] = ''
            else:
                for style in ('procedural', 'functional'):
                    csv_row['LMX_'+style+'_characters'] = ''
                    csv_row['LMX_'+style+'_nonblank_lines'] = ''
            for listing in listings:
                language = listing['language']
                code = listing.get('code')
                if not isinstance(code, str) or not code.strip():
                    fail(json_file, f'ID {identifier}/{language}: empty code')
                    continue
                code = canonical_code(code)
                measured[language] = metrics(code)
                compatibility_listing_count += 1
                folder, extension, tag = LANGUAGES[language]
                source_path = directory/'examples'/folder/f'{stem}.{extension}'
                expected_sources.add(source_path.relative_to(directory).as_posix())
                text = read_text(source_path)
                if text is not None:
                    try:
                        current, archived = source_parts(text) if language == 'LMX' else (text, None)
                        if current != code:
                            fail(source_path, f'ID {identifier}/{language}: source differs from complete canonical code')
                        alternative = record.get('alternative', {}).get(language) if language == 'LMX' else None
                        retained = historical_code(alternative) if alternative else canonical_code(record['procedural_lmx']) if language == 'LMX' and record.get('procedural_lmx') else None
                        if archived != retained:
                            fail(source_path, f'ID {identifier}: archived source does not match its explicit metadata')
                    except ValueError as exc:
                        fail(source_path, str(exc))
                if language == 'LMX' and styled:
                    for style in ('procedural', 'functional'):
                        variant = record['lmx_variants'][style]
                        body = canonical_code(variant['code'])
                        entry = ('lmx', body)
                        if entry not in expected_blocks:
                            expected_blocks.append(entry)
                        expected_sources.add(variant['source_file'])
                        style_metrics[style] = metrics(body)
                        counted.append(('LMX — '+('процедурный' if style == 'procedural' else 'функциональный'), style_metrics[style], variant['source_file']))
                        csv_row['LMX_'+style+'_characters'] = str(style_metrics[style]['nonwhitespace_characters'])
                        csv_row['LMX_'+style+'_nonblank_lines'] = str(style_metrics[style]['nonblank_lines'])
                else:
                    expected_blocks.append((tag, code))
                    label = 'LMX — общая реализация' if is_functional and language == 'LMX' else language
                    counted.append((label, measured[language], source_path.relative_to(directory).as_posix()))
                    prefix = 'LMX_implementation' if is_functional and language == 'LMX' else language
                    csv_row[prefix+'_characters'] = str(measured[language]['nonwhitespace_characters'])
                    csv_row[prefix+'_nonblank_lines'] = str(measured[language]['nonblank_lines'])
                    csv_row[prefix+'_utf8_bytes'] = str(measured[language]['utf8_bytes'])
                variants = record.get('variants', {}).get(language, {})
                if variants and not (language == 'LMX' and styled):
                    selected = record.get('primary_variant', {}).get(language)
                    if selected not in variants or canonical_code(variants.get(selected, '')) != code:
                        fail(json_file, f'ID {identifier}/{language}: compatibility selection differs from its source')

            # Explanatory/archival sources remain verifiable, never inferred as a style.
            alternatives = record.get('alternative', {})
            for language, alternative in alternatives.items():
                expected_blocks.append((LANGUAGES[language][2], historical_code(alternative)))
                if alternative.get('context_prefix'):
                    original = alternative['code']
                    if hashlib.sha256(original.encode()).hexdigest() != alternative.get('preserved_code_sha256'):
                        fail(json_file, f'ID {identifier}/{language}: historical source hash changed')
                    context = next((other for other in records if other['id'] == alternative.get('context_prefix_source_id')), {})
                    if alternative['context_prefix'] != context.get('alternative', {}).get(language, {}).get('code'):
                        fail(json_file, f'ID {identifier}/{language}: historical context mismatch')
            if not alternatives:
                if record.get('procedural_lmx'):
                    expected_blocks.append(('lmx', canonical_code(record['procedural_lmx'])))
                expected_blocks += [(LANGUAGES[language][2], canonical_code(body)) for language, body in record.get('previous_controls', {}).items()]
            for companion in record.get('companion_sources', []):
                name = companion.get('file', '')
                if not name.startswith('examples/') or '..' in Path(name).parts or companion.get('counts_as_primary') is not False:
                    fail(json_file, f'ID {identifier}: invalid companion declaration')
                    continue
                expected_sources.add(name)
                text = read_text(directory/name)
                if text is not None and hashlib.sha256(text.encode()).hexdigest() != companion.get('sha256'):
                    fail(directory/name, 'Companion source differs from recorded hash')
            if blocks != expected_blocks:
                fail(markdown_path, f'ID {identifier}: fenced bodies/order differ from the complete registered comparison and explanatory sources')
            numeric_rows = table_rows(markdown_text)
            for label, counts, source_link in counted:
                expected = [label, str(counts['nonwhitespace_characters']), str(counts['nonblank_lines'])]
                if numeric_rows.count(expected) != 1:
                    fail(markdown_path, f'ID {identifier}/{label}: expected one exact full-source metric row {expected}')
                if f']({source_link})' not in (markdown_text or ''):
                    fail(markdown_path, f'ID {identifier}/{label}: missing source link {source_link}')
            listing_count += len(counted)
            group_comparisons += len(counted)
            total_bytes += sum(counts['utf8_bytes'] for _, counts, _ in counted)
            expected_csv.append(csv_row)
            report = {'id': identifier, 'name': record.get('name'), 'kind': kind, 'layer': layer,
                      'source': markdown_name, 'metrics': measured}
            if styled:
                report['lmx_variants'] = style_metrics
            pattern_reports.append(report)
            row = summary_rows.get(identifier)
            if row is None:
                fail(comparison_path, f'Missing summary row for ID {identifier}')
            else:
                if is_functional:
                    values = ([str(style_metrics[style]['nonwhitespace_characters']) for style in ('procedural', 'functional')]
                              if styled else [str(measured['LMX']['nonwhitespace_characters'])])
                    values += [str(measured[language]['nonwhitespace_characters']) for language in controls]
                    if row[2:] != values:
                        fail(comparison_path, f'ID {identifier}: style/implementation values differ: {row[2:]} != {values}')
                else:
                    for offset, language in enumerate(languages, 2):
                        expected = str(measured[language]['nonwhitespace_characters'])
                        if len(row) <= offset or row[offset] != expected:
                            fail(comparison_path, f'ID {identifier}/{language}: expected complete-source characters {expected}')

        actual_markdown = {path.name for path in directory.glob('*_comparision.md')}
        if actual_markdown != expected_markdown:
            fail(directory, f'Markdown set differs: missing={sorted(expected_markdown-actual_markdown)}, extra={sorted(actual_markdown-expected_markdown)}')
        actual_sources = {path.relative_to(directory).as_posix() for path in (directory/'examples').rglob('*')
                          if path.is_file() and re.match(r'^\d{3}_', path.name)}
        if actual_sources != expected_sources:
            fail(directory/'examples', f'Source set differs: missing={sorted(expected_sources-actual_sources)}, extra={sorted(actual_sources-expected_sources)}')
        if set(summary_rows) != {record['id'] for record in pattern_reports}:
            fail(comparison_path, 'Summary IDs differ from the source index')
        csv_path = directory/f'LMX_Comparison_{group_name}.csv'
        try:
            raw = csv_path.read_bytes()
            if not raw.startswith(codecs.BOM_UTF8):
                fail(csv_path, 'CSV is missing its UTF-8 BOM')
            reader = csv.DictReader(io.StringIO(raw.decode('utf-8-sig'), newline=''))
            header = reader.fieldnames or []
            if is_functional:
                prefixes = ['LMX_procedural', 'LMX_functional', 'LMX_implementation'] + controls
                required = ['id', 'pattern', 'kind', 'source'] + [prefix+'_characters' for prefix in prefixes] + [prefix+'_nonblank_lines' for prefix in prefixes]
            else:
                prefixes = languages
                required = ['id', 'pattern', 'scope', 'kind', 'layer'] + [language+'_characters' for language in languages] + [language+'_nonblank_lines' for language in languages] + ['source']
            optional = {prefix+'_utf8_bytes' for prefix in prefixes}
            if [key for key in header if key not in optional] != required or len(header) != len(set(header)):
                fail(csv_path, f'Unexpected full-source CSV schema: {header}')
            actual = list(reader)
            if len(actual) != len(expected_csv):
                fail(csv_path, f'Expected {len(expected_csv)} CSV rows; found {len(actual)}')
            for position, (row, expected) in enumerate(zip(actual, expected_csv), 2):
                for key in header:
                    if key in expected and row.get(key) != expected[key]:
                        fail(csv_path, f'Row {position}, {key}: {row.get(key)!r} != {expected[key]!r}')
                if None in row:
                    fail(csv_path, f'Row {position}: extra unheaded cells')
        except (OSError, UnicodeError, csv.Error) as exc:
            fail(csv_path, f'Cannot validate CSV: {exc}')
        promised = ['README.md', 'LMX_Design_Patterns.ru.md', 'LMX_Design_Patterns.en.md'] + [f'LMX_Comparison_{group_name}.{extension}' for extension in ('md', 'csv', 'xlsx', 'pdf')]
        for name in promised:
            path = directory/name
            if not path.is_file() or path.stat().st_size == 0:
                fail(path, 'Missing or empty promised deliverable')
        xlsx = directory/f'LMX_Comparison_{group_name}.xlsx'
        if xlsx.is_file():
            try:
                with zipfile.ZipFile(xlsx) as workbook:
                    damaged = workbook.testzip()
                    if damaged:
                        fail(xlsx, f'Damaged ZIP member: {damaged}')
                    for member in ('[Content_Types].xml', 'xl/workbook.xml'):
                        if member not in workbook.namelist():
                            fail(xlsx, f'Missing workbook member {member}')
            except (OSError, zipfile.BadZipFile) as exc:
                fail(xlsx, f'Invalid XLSX container: {exc}')
        pdf = directory/f'LMX_Comparison_{group_name}.pdf'
        if pdf.is_file():
            raw = pdf.read_bytes()
            if not raw.startswith(b'%PDF-') or b'%%EOF' not in raw[-2048:]:
                fail(pdf, 'Missing PDF signature or final EOF marker')
        groups.append({'directory': group_name, 'languages': languages,
                       'pattern_count': sum(record['kind'] == 'pattern' for record in pattern_reports),
                       'implementation_count': sum(record['kind'] == 'implementation' for record in pattern_reports),
                       'comparison_count': len(pattern_reports), 'compatibility_listing_count': 3*len(pattern_reports),
                       'listing_count': group_comparisons, 'patterns': pattern_reports})
    seen = Counter(all_ids)
    if set(seen) != expected_ids or any(count != 1 for count in seen.values()):
        fail(root, f'Each catalog ID must occur once: missing={sorted(expected_ids-set(seen))}, extra={sorted(set(seen)-expected_ids)}, duplicates={dict((key, value) for key,value in seen.items() if value != 1)}')
    if sorted(pattern_ids) != list(range(1, 91)):
        fail(root, 'The original 90 scenario IDs/kinds changed')
    if sorted(implementation_ids) != manifest['implementation_ids']:
        fail(root, 'Implementation IDs/kinds differ from the catalog')
    if sorted(styled_ids) != [82, 83, 84, 85]:
        fail(root, f'The four client style pairs must be082–085: {styled_ids}')
    if compatibility_listing_count != 297 or listing_count != 301:
        fail(root, f'Expected297 compatibility language mirrors and301 comparison listings; found{compatibility_listing_count}/{listing_count}')
    return {'ok': not errors,
            'scope': 'Full-source publication consistency. No claim of LMX execution, parser/type checking, XLSX formula evaluation or PDF visual QA.',
            'method': {'source_normalization': "code.strip() + '\\n', UTF-8/LF",
                       'nonwhitespace_characters': 'Unicode code points with str.isspace()==False; every declaration, Throws entry, comment and literal is counted',
                       'nonblank_lines': 'Nonempty stripped splitlines() entries',
                       'utf8_bytes': 'Complete canonical UTF-8 source including whitespace and final LF',
                       'csv': 'UTF-8 BOM; exact identities, full-source character/line values and optional byte counts',
                       'styles': 'Four client contracts publish both procedural and functional source metrics; common implementations remain one body. Legacy listing.LMX is a compatibility mirror, never a third compared listing.',
                       'alternatives': 'Explicit explanatory sources are checked against their metadata and do not replace either compared style.'},
            'group_count': len(json_files), 'pattern_count': len(pattern_ids), 'implementation_count': len(implementation_ids),
            'comparison_count': len(all_ids), 'compatibility_listing_count': compatibility_listing_count,
            'listing_count': listing_count, 'style_contract_count': len(styled_ids), 'style_listing_count': 2*len(styled_ids),
            'total_source_utf8_bytes': total_bytes, 'error_count': len(errors), 'errors': errors, 'groups': groups}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent, help="Archive root; defaults to the parent of this tools directory")
    parser.add_argument("--json", type=Path, help="Also save the JSON report to this path")
    args = parser.parse_args()
    report = audit(args.root.resolve())
    payload = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(payload, encoding="utf-8")
    sys.stdout.write(payload)
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
