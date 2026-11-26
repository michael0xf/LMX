#!/usr/bin/env python3
# SPDX-License-Identifier: 0BSD
"""Audit the selected production archives, excluding duplicate build/install copies.

Run from any directory:
  python3 audit_symbols.py /path/to/build-c99 --output symbols.json

The external provider list reflects this snapshot's full root CMake composition.
Partial builds intentionally fail if one of those required providers is missing.
The result is a name-collision audit, not a whole-archive link or runtime proof.
"""
from pathlib import Path
from datetime import datetime, timezone
import argparse, concurrent.futures, collections, hashlib, json, re, shlex, shutil, subprocess
def parse_args():
    parser=argparse.ArgumentParser(description="Audit strong exported symbols in the complete LMX C99 collection build. Requires GNU-compatible nm and a completed CMake Ninja or Makefiles build.")
    parser.add_argument("build_dir", type=Path, help="Completed root CMake build directory")
    parser.add_argument("--output", type=Path, help="Write the detailed JSON report here; otherwise print it to stdout")
    return parser.parse_args()

args=parse_args()
build=args.build_dir.resolve()
if not build.is_dir():
    raise SystemExit("Not a build directory: "+str(build))
if shutil.which("nm") is None:
    raise SystemExit("A GNU-compatible nm executable is required on PATH")
primary=[]
missing=[]
excluded=[]
ninja_file=build/"build.ninja"
static_rules=[]
if ninja_file.is_file():
    generator="Ninja"
    for line in ninja_file.read_text().splitlines():
        if line.startswith("build ") and ": C_STATIC_LIBRARY_LINKER" in line:
            static_rules.append(line[6:].split(": ",1)[0].replace("$ "," "))
else:
    generator="CMake Makefiles"
    for link in build.rglob("CMakeFiles/*.dir/link.txt"):
        # CMake runs this link script in the corresponding target build directory.
        target_directory=link.parent.parent.parent
        for line in link.read_text().splitlines():
            tokens=shlex.split(line)
            if not tokens or Path(tokens[0]).name not in ("ar", "llvm-ar", "gcc-ar"):
                continue
            candidate=next((token for token in tokens[1:] if token.endswith(".a")),None)
            if candidate is not None:
                archive=Path(candidate)
                if not archive.is_absolute(): archive=target_directory/archive
                try: static_rules.append(str(archive.resolve().relative_to(build)))
                except ValueError: raise SystemExit("Unexpected archive outside build directory: "+str(archive))
                break
if not static_rules:
    raise SystemExit("No CMake production archive rules found; use a completed Ninja or Makefiles build")
for name in sorted(set(static_rules)):
    if name=="extensions/media/webp/libwebpdecoder.a":
        excluded.append({"path":name,"reason":"Alternative decode-only WebP target; full libwebp is selected."})
    elif not (build/name).is_file():
        missing.append({"path":name,"reason":"Declared optional/internal build target was not produced by the accepted full composition."})
    else:
        primary.append(name)
external=[
 'libsodium-stage/lib/libsodium.a',
 'extensions/postgresql/stage/lib/liblmx_pq.a',
 'extensions/platform_extra/apr-install/lib/libapr-1.a',
 'extensions/platform_extra/apu-install/lib/libaprutil-1.a',
 'extensions/scientific_hdf5/install/lib/libhdf5.a',
 'extensions/scientific_hdf5/install/lib/libhdf5_hl.a',
 'extensions/scientific_pnetcdf/pnetcdf-install/lib/libpnetcdf.a',
 'extensions/scientific_netcdf/libxml2-install/lib/libxml2.a',
 'extensions/scientific_netcdf/netcdf-install/lib/libnetcdf.a',
]
for name in external:
    if not (build/name).is_file(): raise SystemExit('Expected external production archive missing: '+name)
    primary.append(name)
# Nested ExternalProject CMake directories can also contain Makefiles link.txt.
# Their installed provider is the canonical target, so do not count both.
external_build_prefixes=(
    "extensions/scientific_hdf5/hdf5-build/",
    "extensions/scientific_netcdf/libxml2-build/",
    "extensions/scientific_netcdf/netcdf-build/",
)
primary=sorted({name for name in primary if not name.startswith(external_build_prefixes)})
for p in sorted(build.rglob('*.a')):
    name=str(p.relative_to(build))
    if name not in primary and not any(e['path']==name for e in excluded):
        excluded.append({'path':name,'reason':'ExternalProject build/install duplicate, selected dependency copy or internal merged archive; primary provider selected once.'})
def read_archive(name):
    path=build/name
    before=hashlib.sha256(path.read_bytes()).hexdigest()
    p=subprocess.run(['nm','-A','-g','--defined-only','-P',str(path)],capture_output=True,text=True,check=True)
    records=[]; weak=0
    for line in p.stdout.splitlines():
        m=re.match(r'^.*?\[([^\]]+)\]:\s+(\S+)\s+(\S)\s+',line)
        if not m: continue
        obj,symbol,kind=m.groups()
        if kind in 'WwVvu': weak+=1; continue
        if kind not in 'TDBRSGCIA': continue
        records.append((symbol,{'archive':name,'object':obj,'kind':kind}))
    after=hashlib.sha256(path.read_bytes()).hexdigest()
    if before!=after: raise RuntimeError('Archive changed while auditing: '+name)
    return {'path':name,'bytes':path.stat().st_size,'sha256':before,'strong_symbols':len(records),'excluded_weak_symbols':weak},records
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
    results=list(pool.map(read_archive,primary))
index=collections.defaultdict(list)
for meta,records in results:
    for symbol,provider in records: index[symbol].append(provider)
collisions=[{'symbol':symbol,'providers':providers} for symbol,providers in sorted(index.items()) if len({p['archive'] for p in providers})>1]
internal=[{'symbol':symbol,'providers':providers} for symbol,providers in sorted(index.items()) if len(providers)>1 and len({p['archive'] for p in providers})==1]
report={'schema_version':1,'date_utc':datetime.now(timezone.utc).date().isoformat(),'scope':'Selected production static archives from the complete CMake composition; external providers represented once by their installed/archive target.','method':'nm -A -g --defined-only -P; strong T/D/B/R/S/G/C/I/A symbols, excluding W/V and GNU unique u; compare names across distinct primary archives.','build_generator':generator,'build_root':'build directory (paths below are relative to the complete CMake build)','selected_archive_count':len(primary),'selected_archive_bytes_sum':sum(m['bytes'] for m,r in results),'strong_definition_count':sum(len(r) for m,r in results),'distinct_strong_names':len(index),'duplicate_strong_name_count':len(collisions),'collisions':collisions,'same_archive_repeated_strong_definitions':internal,'archives':[m for m,r in results],'excluded_existing_archives':excluded,'unbuilt_nonselected_cmake_archives':missing,'limitations':['A symbol-name collision audit is not a whole-archive link proof or a final executable test.','Archive byte sums are not linked runtime size or RAM use.','Platform SDK/MPI/system-library symbols outside the archived collection are not included.','This audit does not certify runtime interoperability of arbitrary optional backends.']}
if args.output:
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n")
    keys=["selected_archive_count","selected_archive_bytes_sum","strong_definition_count","distinct_strong_names","duplicate_strong_name_count","collisions"]
    print(json.dumps({key:report[key] for key in keys},indent=2))
else:
    print(json.dumps(report,ensure_ascii=False,indent=2))
if collisions or internal:
    raise SystemExit(1)
