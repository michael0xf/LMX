#!/usr/bin/env python3
"""Independent structural and public-surface acceptance checks for the census."""
import argparse,collections,hashlib,json,re
from pathlib import Path

def main():
    ap=argparse.ArgumentParser();ap.add_argument('source',type=Path);ap.add_argument('inventory',type=Path);ap.add_argument('--output',type=Path);a=ap.parse_args()
    d=json.loads(a.inventory.read_text());es=d['entries'];fail=[];checks=[]
    def check(label,ok,detail=None):
        checks.append({'check':label,'passed':bool(ok),'detail':detail})
        if not ok:fail.append(label)
    manifest=json.loads((a.source/'SOURCES.json').read_text())
    check('all manifest component identities covered',len(d['components'])>=112 and {c['id'] for c in d['components']}=={c['id'] for c in manifest['components']})
    check('every component has inventory entries',{c['id'] for c in d['components']}=={e['component'] for e in es})
    check('stable entry IDs unique',len(es)==len({e['id'] for e in es}))
    check('complete callable dispositions',all(e.get('ffi_disposition') and isinstance(e.get('pub_candidate'),bool) for e in es))
    bad=[]
    for h in d['header_coverage']:
        p=a.source/h['path'].removeprefix('third_party/lmx_c99_compact/')
        if not p.exists() or hashlib.sha256(p.read_bytes()).hexdigest()!=h['sha256']:bad.append(h['path'])
    check('all inventoried source surfaces match SHA-256',not bad,bad)
    missing_surfaces=[x for x in d['diagnostics'] if x.get('severity')=='missing_declared_surface']
    check('every declared public surface pattern resolves',not missing_surfaces,missing_surfaces)
    pub=[e for e in es if e['pub_candidate']]
    callable_keys=[(e['component'],e['name']) for e in pub]
    check('one callable identity per component/name across linkage profiles',len(callable_keys)==len(set(callable_keys)))
    check('callbacks macros templates SQL are not binary-callable candidates',all(e['classification'] in ('function','static_inline','static_header_function') for e in pub))
    check('private and example names not published',not [e['name'] for e in pub if e['name'] in ('main','dummy','defined','T','assert') or e['name'].startswith(('_','mt__','stbi__','stbtt__','glm__'))])
    keys={(e['component'],e['name']):e for e in pub}
    expected={'base:sqlite3':['sqlite3_exec','sqlite3_open','sqlite3_prepare_v2','sqlite3_create_function_v2'],'base:curl':['curl_easy_setopt','curl_multi_socket_action'],'extras:whereami':['wai_getExecutablePath','wai_getModulePath'],'graphics:nanojpeg':['njInit','njDecode','njGetWidth','njGetHeight','njIsColor','njGetImage','njGetImageSize','njDone'],'media:minih264':['H264E_encode','H264E_init','H264E_sizeof','H264E_set_vbv_state'],'base:stb':['stbsp_sprintf','stbsp_snprintf','stbi_load'],'extras:cglm':['glm_vec3_add','glmc_vec3_add','glms_vec3_add','glms_mat4_mul'],'base:linmath':['vec3_add','mat4x4_mul'],'acoustic:liquid_dsp':['resamp_crcf_create','firfilt_rrrf_create','nco_crcf_create'],'sqlite_vec:sqlite_vec':['sqlite3_vec_init','sqlite3_vec_numpy_init','sqlite3_vec_static_blobs_init']}
    missing=[cid+':'+n for cid,names in expected.items() for n in names if (cid,n) not in keys]
    check('named macro expansion and callback-bearing API regression probes',not missing,missing)
    check('NanoJPEG exact public header API',len([e for e in pub if e['component']=='graphics:nanojpeg'])==8)
    check('minih264 exact public header API',len([e for e in pub if e['component']=='media:minih264'])==4)
    check('SQLite callback stays parameter of sqlite3_exec',any(p.get('callback') for p in keys['base:sqlite3','sqlite3_exec']['parameters']))
    check('varargs retained for curl_easy_setopt',any(p.get('variadic') for p in keys['base:curl','curl_easy_setopt']['parameters']))
    # Separate independent extraction anchored on the public MA_API declaration
    # annotation. This does not reuse the inventory tokenizer.
    raw=(a.source/'vendor/miniaudio/miniaudio.h').read_text()
    boundary=re.search(r'^#if defined\(MINIAUDIO_IMPLEMENTATION\)',raw,re.M)
    surface=raw[:boundary.start()] if boundary else ''
    expected_ma=set(re.findall(r'^MA_API\s+[^;{}]*?\b(ma_[A-Za-z0-9_]+)\s*\(',surface,re.M))
    missing_ma=sorted(n for n in expected_ma if ('media:miniaudio',n) not in keys)
    check('independent miniaudio MA_API declarations all represented',len(expected_ma)>900 and not missing_ma,{'expected_names':len(expected_ma),'missing':missing_ma})
    check('declaration annotation macros have metadata-only disposition',all(e['ffi_disposition']=='metadata_only_non_runtime_macro' for e in es if e.get('macro_role') in ('declaration_annotation','compile_time_contract','configuration_or_alias') and e['classification']=='function_macro'))
    check('upstream renamed quadrature APIs resolve canonical ABI symbols',all(e.get('alias_of') and e['abi_symbol'].startswith('lmx_') and not e['pub_candidate'] for e in es if e['availability']=='upstream_symbol_renamed'))
    check('canonical callable headers are include spellings',all(e.get('canonical_header') and not re.search(r'\s|\+',e['canonical_header']) for e in pub))
    check('embedded utf8proc API is retained without another backend copy',('databases:mongo_c_driver','utf8proc_map') in keys and ('systems:lz4','XXH64') in keys,
          'utf8proc under MongoDB and legacy xxHash under LZ4 remain source components of their original backends.')
    added_expected={
      'numeric_extra:libbf':['bf_add','bfdec_add','bf_sqrt','mp_mul'],
      'numeric_extra:softfloat':['f16_add','f128_add','f128M_add'],
      'numeric_extra:libfixmath':['fix16_mul','fix16_from_int'],
      'numeric_extra:libfixmatrix':['mf16_mul','qf16_mul','v3d_add'],
      'numeric_extra:fp16':['fp16_ieee_from_fp32_value','lmx_fp16_ieee_to_float'],
      'numeric_extra:cminpack':['hybrd','lmdif','enorm','qrfac'],
      'numeric_extra:imath':['mp_int_add','mp_rat_add','MP_DIGITS','MP_ALLOC','MP_USED','MP_SIGN','MP_NUMER_P','MP_DENOM_P'],
      'numeric_extra:pffft':['pffft_transform','pffftd_transform','pffastconv_apply'],
      'numeric_extra:pcg-c':['pcg_setseq_64_xsh_rr_32_random_r','pcg_setseq_64_rxs_m_xs_64_random_r'],
      'numeric_extra:libtomfloat':['mpf_add','mpf_mul','mpf_sqrt','mpf_from_string','mpf_to_string'],
      'text_hash_extra:libdivsufsort':['divsufsort','divsufsort64'],
      'text_hash_extra:libtess2':['tessNewTess','tessTesselate'],
      'text_hash_extra:libccd':['ccdGJKIntersect','ccdVec3Add','ccdQuatRotVec'],
      'text_hash_extra:inih':['ini_parse','ini_parse_string'],
      'text_hash_extra:isocline':['ic_readline'],
      'text_hash_extra:libunibreak':['set_linebreaks_utf8','set_wordbreaks_utf16','set_graphemebreaks_utf32'],
      'text_hash_extra:xxhash_modern':['XXH32','XXH64','XXH128','XXH3_64bits'],
    }
    cids={c['id'] for c in d['components']}
    missing=[cid+':'+name for cid,names in added_expected.items() if cid in cids for name in names if (cid,name) not in keys]
    if cids.intersection(added_expected):
        check('added library known API probes',not missing,missing)
    if 'numeric_extra:cminpack' in cids:
        raw=(a.source/'vendor/cminpack/include/cminpack.h').read_text()
        cm_names=set(re.findall(r'__cminpack_func__\(\s*(\w+)\s*\)\s*\(',raw))
        missing=sorted(n for n in cm_names if ('numeric_extra:cminpack',n) not in keys)
        check('all default-double CMINPACK generated functions represented',len(cm_names)==25 and not missing,{'expected_names':len(cm_names),'missing':missing})
        e=keys.get(('numeric_extra:cminpack','hybrd'))
        check('callback typedef parameters resolved as callbacks',bool(e) and any(p.get('callback_type_refs') for p in e['parameters']))
    if 'numeric_extra:libbf' in cids:
        rewritten=[e for e in pub if e['component']=='numeric_extra:libbf' and e['name'].startswith(('mp_','dbuf_'))]
        check('LibBF auxiliary ABI avoids LibTomMath/global collisions',bool(rewritten) and all(e['abi_symbol']=='lmx_bf_'+e['name'] for e in rewritten))
    if 'numeric_extra:pcg-c' in cids:
        e=keys.get(('numeric_extra:pcg-c','pcg_rotr_128'))
        check('PCG 128-bit profile retained but explicitly unavailable in portable target',bool(e) and e['availability']=='outside_selected_portable_profile')
    if 'numeric_extra:libtomfloat' in cids:
        missing_impl=[keys.get(('numeric_extra:libtomfloat',n)) for n in ('mpf_from_string','mpf_to_string')]
        check('LibTomFloat missing definitions are contract-only stubs',all(e and e['availability']=='declared_without_implementation' and e['ffi_disposition']=='unimplemented_declaration_contract' for e in missing_impl))
    if 'text_hash_extra:libccd' in cids:
        check('libccd canonical include directory preserved',all(e['canonical_header'].startswith('ccd/') for e in pub if e['component']=='text_hash_extra:libccd'))
    if 'text_hash_extra:xxhash_modern' in cids:
        modern=[e for e in pub if e['component']=='text_hash_extra:xxhash_modern']
        check('modern xxHash ABI/include isolation from legacy xxHash',bool(modern) and all(e['canonical_header']=='lmx_xxhash_modern.h' and e['abi_symbol']=='LMXC99_XXH_'+e['name'] for e in modern))
    short_expected={'c-ares':['ares_init','ares_getaddrinfo'],'cares':['ares_init','ares_getaddrinfo'],'c_ares':['ares_init','ares_getaddrinfo'],
                    'libevent':['event_base_new','event_new'],'mdns':['mdns_socket_open_ipv4','mdns_query_send']}
    for cid in cids:
        short=cid.split(':',1)[-1]
        if short in short_expected:
            missing=[n for n in short_expected[short] if (cid,n) not in keys]
            check('new networking public API: '+cid,not missing,missing)
    report={'result':'PASS' if not fail else 'FAIL','checks':checks,'failed':fail,'execution_status':'Static/source acceptance only. No collection link test or LMX runtime test.'}
    if a.output:a.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(report,ensure_ascii=False,indent=2))
    raise SystemExit(bool(fail))

if __name__=='__main__':main()
