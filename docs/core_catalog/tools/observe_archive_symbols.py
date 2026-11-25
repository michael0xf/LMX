#!/usr/bin/env python3
"""Observe native archive definitions and match C census ABI spellings.

An nm match is evidence that this build contains a symbol definition. It does not
prove its C signature, public visibility policy, target ownership, successful
final linkage, or safe coexistence of every archive in one process. Inline APIs,
macros, callbacks and source profiles remain separate from binary definitions.
"""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
import fnmatch
from pathlib import Path
import re
import subprocess


def sha256(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
    return h.hexdigest()


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    origin=ap.add_mutually_exclusive_group(required=True)
    origin.add_argument('--build-dir',type=Path)
    origin.add_argument('--symbol-snapshot',type=Path,help='reuse recorded nm archive records from an earlier --details file')
    ap.add_argument('--inventory',type=Path,required=True)
    ap.add_argument('--summary',type=Path,required=True)
    ap.add_argument('--details',type=Path)
    ap.add_argument('--nm',default='nm')
    ap.add_argument('--exclude-archive',action='append',default=[],help='exclude a relative archive glob, e.g. a stale unselected combined archive')
    a=ap.parse_args();root=a.build_dir.resolve() if a.build_dir else None
    inventory=json.loads(a.inventory.read_text())
    archives=sorted(root.rglob('*.a')) if root else []
    skipped=[p.relative_to(root).as_posix() for p in archives if any(fnmatch.fnmatchcase(p.relative_to(root).as_posix(),g) for g in a.exclude_archive)]
    archives=[p for p in archives if p.relative_to(root).as_posix() not in skipped]
    env=dict(os.environ,LC_ALL='C')

    def scan(path):
        p=subprocess.run([a.nm,'-g','--defined-only','--format=posix',str(path)],text=True,capture_output=True,env=env)
        symbols=[];member=None
        for line in p.stdout.splitlines():
            if line.endswith(']:'):
                member=line.rsplit('[',1)[-1][:-2];continue
            m=re.match(r'^(\S+)\s+([A-Za-z?])(?:\s|$)',line)
            if not m:continue
            name,kind=m.groups()
            symbols.append({'name':name,'type':kind,'member':member})
        return {'archive':path.relative_to(root).as_posix(),'sha256':sha256(path),'bytes':path.stat().st_size,
                'nm_returncode':p.returncode,'nm_diagnostic':p.stderr.strip(),'symbol_count':len(symbols),
                'callable_definition_count':sum(s['type'] in 'TtWwIi' for s in symbols),'symbols':symbols}

    if a.symbol_snapshot:
        records=json.loads(a.symbol_snapshot.read_text())['archives']
        skipped=[r['archive'] for r in records if any(fnmatch.fnmatchcase(r['archive'],g) for g in a.exclude_archive)]
        records=[r for r in records if r['archive'] not in skipped]
    else:
        with ThreadPoolExecutor(max_workers=8) as pool:records=list(pool.map(scan,archives))
    definitions=defaultdict(list)
    for record in records:
        for s in record['symbols']:
            if s['type'] in 'TtWwIi':
                definitions[s['name']].append({'archive':record['archive'],'member':s['member'],'type':s['type']})
    statuses=Counter();by_component=defaultdict(Counter);observations=[]
    for entry in inventory['entries']:
        if not entry.get('pub_candidate'):continue
        found=definitions.get(entry['abi_symbol'],[])
        if entry['classification'] in ('static_inline','static_header_function'):
            status='inline_or_static_C_shim_required'
        elif found:status='matching_global_definition_observed'
        else:status='no_matching_definition_in_scanned_archives'
        statuses[status]+=1;by_component[entry['component']][status]+=1
        observations.append({'entry_id':entry['id'],'component':entry['component'],'name':entry['name'],
                             'abi_symbol':entry['abi_symbol'],'classification':entry['classification'],
                             'source_availability':entry['availability'],'observation':status,'definitions':found})
    summary={
        'schema_version':1,'scope':'Native nm observations of this configured C build; not a final-link or ABI-signature verification.',
        'inventory_sha256':sha256(a.inventory),'source_manifest_sha256':inventory['source_manifest_sha256'],
        'symbol_origin':({'kind':'recorded_nm_snapshot','snapshot_sha256':sha256(a.symbol_snapshot)} if a.symbol_snapshot else {'kind':'live_nm_archive_scan'}),
        'excluded_archives':skipped,
        'archive_count':len(records),'nm_failures':sum(r['nm_returncode']!=0 for r in records),
        'distinct_callable_symbol_spellings':len(definitions),
        'spellings_defined_in_multiple_archives':sum(len({s['archive'] for s in defs})>1 for defs in definitions.values()),
        'candidate_observation_counts':dict(statuses),
        'components':[{'component':cid,**dict(counts)} for cid,counts in sorted(by_component.items())],
        'archives':[{k:v for k,v in r.items() if k!='symbols'} for r in records],
        'limits':[
            'Definitions are collected from all discovered .a files, including dependency/staging copies. Duplicate spelling is not automatically a conflicting final link.',
            'A spelling match may belong to another archive/component; signature and target membership require separate C ABI/link validation.',
            'Missing global definitions are expected for inactive platform/features, header-only implementations, private/static APIs and required application implementations.',
            'Inline and static header functions need typed addressable shims even when a same-named global definition exists elsewhere.',
            'No --whole-archive combined image was linked; alternative profiles and backend lifetimes still require explicit ownership/conversion rules.'
        ]
    }
    a.summary.parent.mkdir(parents=True,exist_ok=True);a.summary.write_text(json.dumps(summary,indent=2)+'\n')
    if a.details:
        a.details.parent.mkdir(parents=True,exist_ok=True)
        a.details.write_text(json.dumps({'summary':summary,'archives':records,'entry_observations':observations},indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k not in ('archives','components','limits')},indent=2))
    raise SystemExit(bool(summary['nm_failures']))


if __name__=='__main__':main()
