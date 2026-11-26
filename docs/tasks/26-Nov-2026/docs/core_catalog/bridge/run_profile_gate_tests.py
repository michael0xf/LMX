#!/usr/bin/env python3
"""Unavailable catalogue profiles stay refusing even when ENABLE is defined.

This tests the generated C boundary, without linking APR, SDL, GL, PCG or
LibTomFloat. It is not a test of those libraries or of the LMX runtime.
"""
from __future__ import annotations
import argparse,hashlib,json,os,shlex,subprocess,sys,tempfile
from pathlib import Path

FIXTURES=[
    ('platform_extra:apr','apr_skiplist_init','outside_selected_profile'),
    ('platform_extra:sdl3','glClear','not_built_in_target_graphics_api'),
    ('platform_extra:sdl3','SDL_main','application_implementation_required'),
    ('numeric_extra:pcg-c','pcg_rotr_128','outside_selected_portable_profile'),
    ('numeric_extra:libtomfloat','mpf_from_string','declared_without_implementation'),
]

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--catalog-root',type=Path,required=True)
    ap.add_argument('--report',type=Path,required=True)
    ap.add_argument('--build-dir',type=Path)
    ap.add_argument('--compiler',default=os.environ.get('CC','cc'))
    args=ap.parse_args();catalog=args.catalog_root.resolve();bridge=Path(__file__).resolve().parent
    sys.path.insert(0,str(catalog/'tools'))
    from build_c_catalog import read_catalog,emit_c,macro_id,shim_name
    owned=tempfile.TemporaryDirectory(prefix='lmx-profile-gates-') if args.build_dir is None else None
    build=Path(owned.name) if owned else args.build_dir.resolve();build.mkdir(parents=True,exist_ok=True)
    report={'scope':'Force-enable attempts against five unavailable generated native-call gates; no native provider library is linked.','status':'FAIL','fixtures':[],'commands':[],'not_run':['LMX runtime','real native implementations','other platforms']}
    def run(command):
        p=subprocess.run(list(map(str,command)),capture_output=True,text=True)
        report['commands'].append({'argv':list(map(str,command)),'returncode':p.returncode,'stdout':p.stdout,'stderr':p.stderr})
        if p.returncode:raise RuntimeError('Command failed: '+str(command[0]))
        return p
    try:
        parts=['#include "lmx_catalog_bridge.h"','#include <stdio.h>','#include <string.h>'];entries=[]
        for cid,name,availability in FIXTURES:
            components,_=read_catalog(catalog,component_filter=cid)
            candidates=[e for c in components for e,_ in (c.decode_entry(eid,row) for eid,row in c.entries.items()) if e['name']==name and e.get('publish_candidate')]
            if len(candidates)!=1:raise RuntimeError('Expected one callable contract: '+cid+':'+name)
            e=candidates[0]
            if e['availability']!=availability:raise RuntimeError('Fixture profile changed: '+cid+':'+name)
            generated=emit_c(e)
            parts+=['#define LMXC99_ENABLE_'+macro_id(e)+' 1',generated]
            entries.append(e);report['fixtures'].append({'component':cid,'name':name,'entry_id':e['id'],'availability':availability,'generated_sha256':hashlib.sha256(generated.encode()).hexdigest()})
        parts+=['int main(void) {','  unsigned failures=0, count=0;','  const unsigned char owner=1;','  lmx_catalog_frame frame={0};','  frame.abi_version=1; frame.owner=&owner;']
        for e in entries:
            parts+=['  ++count; frame.result.kind=LMXC_UNSIGNED; frame.result.unsigned_value=777;',
                    '  if ('+shim_name(e)+'(&frame)!=LMXC_REVIEW_REQUIRED || frame.status!=LMXC_REVIEW_REQUIRED || frame.result.kind!=LMXC_NONE || !frame.diagnostic_symbol || strcmp(frame.diagnostic_symbol,'+json.dumps(e['name'])+')) ++failures;']
        parts+=['  printf("{\\"gates\\":%u,\\"failures\\":%u}\\n",count,failures);','  return failures ? 1 : 0;','}']
        source=build/'profile_gates.c';source.write_text('\n'.join(parts)+'\n');binary=build/'profile_gates'
        cc=shlex.split(args.compiler);report['compiler']=run(cc+['--version']).stdout.splitlines()[0]
        run(cc+['-std=c99','-pedantic-errors','-Wall','-Wextra','-Werror','-I',bridge,source,bridge/'lmx_catalog_bridge.c','-o',binary])
        report['execution']=json.loads(run([binary]).stdout)
        report['status']='PASS' if report['execution']=={'gates':len(FIXTURES),'failures':0} else 'FAIL'
    finally:
        # Reports contain reviewable commands but no transient absolute paths.
        text=json.dumps(report,ensure_ascii=False,indent=2)
        text=text.replace(str(build),'$BUILD').replace(str(catalog),'$CATALOG').replace(str(bridge),'$BRIDGE')
        args.report.parent.mkdir(parents=True,exist_ok=True);args.report.write_text(text+'\n')
        if owned:owned.cleanup()
    print(json.dumps({'status':report['status'],'execution':report.get('execution')},ensure_ascii=False))
    return 0 if report['status']=='PASS' else 1

if __name__=='__main__':raise SystemExit(main())
