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
    check('callback typedef identities are never C builtin type keywords',not [e['id'] for e in es if e['classification']=='callback' and e['name'] in {'void','int','bool','char','short','long','float','double','unsigned','signed','size_t'}])
    contaminated=[]
    for e in es:
        for p in e.get('parameters',[]):
            if p.get('callback_type_refs') and re.fullmatch(r'(?:const\s+)?(?:void|int|bool|char|short|long|float|double|unsigned|signed|size_t)(?:\s|\*)*',p.get('c_type','')):
                contaminated.append(e['component']+':'+e['name']+':'+p['name'])
    check('ordinary scalar and void-pointer parameters do not inherit false callback typedefs',not contaminated,contaminated)
    check('private and example names not published',not [e['name'] for e in pub if e['name'] in ('main','dummy','defined','T','assert') or e['name'].startswith(('_','mt__','stbi__','stbtt__','glm__'))])
    keys={(e['component'],e['name']):e for e in pub}
    expected={'base:sqlite3':['sqlite3_exec','sqlite3_open','sqlite3_prepare_v2','sqlite3_create_function_v2'],'base:curl':['curl_easy_setopt','curl_multi_socket_action'],'extras:whereami':['wai_getExecutablePath','wai_getModulePath'],'graphics:nanojpeg':['njInit','njDecode','njGetWidth','njGetHeight','njIsColor','njGetImage','njGetImageSize','njDone'],'media:minih264':['H264E_encode','H264E_init','H264E_sizeof','H264E_set_vbv_state'],'base:stb':['stbsp_sprintf','stbsp_snprintf','stbi_load'],'extras:cglm':['glm_vec3_add','glmc_vec3_add','glms_vec3_add','glms_mat4_mul'],'base:linmath':['vec3_add','mat4x4_mul'],'acoustic:liquid_dsp':['resamp_crcf_create','firfilt_rrrf_create','nco_crcf_create'],'sqlite_vec:sqlite_vec':['sqlite3_vec_init','sqlite3_vec_numpy_init','sqlite3_vec_static_blobs_init']}
    missing=[cid+':'+n for cid,names in expected.items() for n in names if (cid,n) not in keys]
    check('named macro expansion and callback-bearing API regression probes',not missing,missing)
    newer_expected={
      'storage_extra:littlefs':['lfs_mount','lfs_file_read','lfs_file_write'],
      'storage_extra:fatfs':['f_mount','f_open','f_read','f_write'],
      'storage_extra:spiffs':['SPIFFS_mount','SPIFFS_open','SPIFFS_read','SPIFFS_write'],
      'storage_extra:heatshrink':['heatshrink_encoder_sink','heatshrink_decoder_poll'],
      'storage_extra:qcbor':['QCBOREncode_Init','QCBOREncode_Finish','QCBORDecode_Init'],
      'storage_extra:tinycbor':['cbor_parser_init','cbor_encoder_init','cbor_encode_int'],
      'storage_extra:flashdb':['fdb_kvdb_init','fdb_tsdb_init','fdb_kv_set'],
      'control_extra:fusion':['FusionAhrsInitialise','FusionAhrsUpdate'],
      'control_extra:fixkalman':['kalman_correct','kalman_predict_x'],
      'control_extra:pid':['PIDController_Init','PIDController_Update'],
      'control_extra:libcanard':['canard_new','canard_ingest_frame','canard_poll'],
      'control_extra:nanomodbus':['nmbs_client_create','nmbs_server_poll','nmbs_read_holding_registers'],
      'control_extra:coremqtt':['MQTT_Init','MQTT_Connect','MQTT_Publish'],
      'control_extra:lwip':['lwip_init','tcp_new','udp_new','pbuf_alloc'],
      'knowledge_extra:pcre2':['pcre2_compile_8','pcre2_match_8','pcre2_code_free_8','pcre2_regcomp'],
      'knowledge_extra:liblbfgs':['lbfgs','lbfgs_parameter_init'],
      'knowledge_extra:libdmtx':['dmtxDecodeCreate','dmtxEncodeDataMatrix'],
      'knowledge_extra:libtiff':['TIFFOpen','TIFFReadScanline','TIFFWriteScanline'],
      'knowledge_extra:libxls':['xls_open_file','xls_parseWorkSheet','xls_cell'],
      'knowledge_extra:matio':['Mat_Open','Mat_CreateVer','Mat_VarRead','Mat_VarWrite'],
      'science_extra:liblsoda':['lsoda','lsoda_prepare','lsoda_free'],
      'science_extra:erfa':['eraAtco13','eraCal2jd','eraEpv00'],
      'pdf_extra:pdfio':['pdfioFileOpen','pdfioFileCreate','pdfioFileClose'],
      'platform_extra:apr':['apr_initialize','apr_pool_create_ex','apr_socket_create','apr_file_open'],
      'platform_extra:apr_util':['apr_xml_parser_create','apr_uri_parse','apr_dbm_open'],
      'platform_extra:sdl3':['SDL_Init','SDL_CreateWindow','SDL_CreateSurface','SDL_CreateAudioStream'],
      'bundles_extra:gb':['gb_alloc','gb_string_make','gb_file_open'],
      'bundles_extra:cute_c2':['c2GJK','c2TOI','c2CircletoCircle'],
      'bundles_extra:cute_tiled':['cute_tiled_load_map_from_memory','cute_tiled_free_map'],
      'bundles_extra:cute_aseprite':['cute_aseprite_load_from_memory','cute_aseprite_free'],
      'bundles_extra:cute_png':['cp_load_png_mem','cp_save_png_to_memory'],
      'bundles_extra:cute_spritebatch':['spritebatch_init','spritebatch_push','spritebatch_flush'],
      'bundles_extra:cute_sync':['cute_mutex_create','cute_threadpool_create'],
      'bundles_extra:cute_net':['cn_client_create','cn_server_create','cn_generate_connect_token'],
      'bundles_extra:cute_sound':['cs_init','cs_read_mem_wav','cs_play_sound'],
      'bundles_extra:ea_libc':['lmx_ea_memcpy','lmx_ea_qsort','lmx_ea_iswalpha'],
      'netsurf_extra:libwapcaplet':['lwc_intern_string','lwc_string_ref'],
      'netsurf_extra:libparserutils':['parserutils_inputstream_create','parserutils_charset_codec_decode'],
      'netsurf_extra:libhubbub':['hubbub_parser_create','hubbub_parser_parse_chunk'],
      'netsurf_extra:libdom':['dom_hubbub_parser_create','dom_xml_parser_create','dom_document_create_element'],
      'netsurf_extra:libcss':['css_stylesheet_create','css_select_style'],
      'netsurf_extra:libsvgtiny':['svgtiny_create','svgtiny_parse'],
      'netsurf_extra:libnsbmp':['bmp_create','bmp_decode','ico_collection_create'],
      'netsurf_extra:libnsgif':['nsgif_create','nsgif_data_scan','nsgif_frame_decode'],
      'scientific_formats:hdf5':['H5Fcreate','H5Dwrite','H5Pset_fapl_mpio','H5LTmake_dataset','H5TBmake_table','H5IMmake_image_24bit','H5DSset_scale'],
      'scientific_formats:netcdf':['nc_create','nc_open','nc_put_var_longlong','nc_inq_format'],
      'scientific_formats:pnetcdf':['ncmpi_create','ncmpi_inq_format','ncmpi_iput_vara_longlong','ncmpi_wait_all'],
      'scientific_formats:libxml2':['xmlReadMemory','xmlDocGetRootElement','xmlFreeDoc','xmlReaderForMemory','xmlNewTextWriterMemory'],
    }
    census_components={c['id'] for c in d['components']}
    for cid,names in newer_expected.items():
        if cid in census_components:
            absent=[name for name in names if (cid,name) not in keys]
            check('new component public API anchors: '+cid,not absent,absent)
    if 'knowledge_extra:pcre2' in census_components:
        excluded=[e for e in pub if e['component']=='knowledge_extra:pcre2' and re.search(r'_(16|32)$',e['name'])]
        check('PCRE2 unused code-unit widths retained as unavailable profiles',bool(excluded) and all(e['availability']=='outside_selected_profile' for e in excluded))
    if 'control_extra:lwip' in census_components:
        check('lwIP socket API not advertised as raw-stack implementation',keys.get(('control_extra:lwip','lwip_socket'),{}).get('availability')=='outside_selected_profile')
    if 'storage_extra:fatfs' in census_components:
        check('FatFs device I/O remains an application port contract',keys.get(('storage_extra:fatfs','disk_read'),{}).get('availability')=='application_implementation_required')
    if 'science_extra:erfa' in census_components:
        erfa_headers=[a.source/'vendor/erfa/src'/name for name in ['erfa.h','erfaextra.h']]
        names=set().union(*(set(re.findall(r'\b(era[A-Z]\w*)\s*\(',path.read_text())) for path in erfa_headers))
        missing_erfa=sorted(n for n in names if ('science_extra:erfa',n) not in keys)
        check('independent ERFA public header declarations all represented',len(names)>200 and not missing_erfa,{'expected_names':len(names),'missing':missing_erfa})
    if 'platform_extra:sdl3' in census_components:
        names=set()
        for path in (a.source/'vendor/sdl3/include/SDL3').glob('*.h'):
            raw=re.sub(r'\bSDL_ALLOC_SIZE2?\s*\([^)]*\)','',path.read_text())
            names.update(re.findall(r'extern\s+SDL_DECLSPEC[^;{}]*?\b(SDL_[A-Za-z0-9_]+)\s*\(',raw,re.S))
        missing_sdl=sorted(n for n in names if ('platform_extra:sdl3',n) not in keys)
        check('independent SDL_DECLSPEC declarations all represented',len(names)>500 and not missing_sdl,{'expected_names':len(names),'missing':missing_sdl})
        callback_names={e['name'] for e in es if e['component']=='platform_extra:sdl3' and e['classification']=='callback'}
        check('SDL calling-convention callback typedefs preserve their real names',{'SDL_EventFilter','SDL_AudioStreamCallback','SDL_CompareCallback','SDL_main_func'}<=callback_names)
        event=keys.get(('platform_extra:sdl3','SDL_SetEventFilter'))
        check('SDL event filter typed parameter recognized without corrupting integers',bool(event) and any(p.get('callback_type_refs') and 'SDL_EventFilter' in p.get('c_type','') for p in event['parameters']))
        strings=keys.get(('platform_extra:sdl3','SDL_strlcpy'))
        check('SDL buffer annotation macros are not mistaken for callback declarators',bool(strings) and all(not p.get('callback') for p in strings['parameters']))
        check('SDL analyzer-only libc declarations stay out of public candidates',all(('platform_extra:sdl3',n) not in keys for n in ('alloca','strdup','strlcat','strlcpy','strtok_r','wcslcat','wcslcpy')))
        gl=[e for e in pub if e['component']=='platform_extra:sdl3' and e['name'].startswith(('gl','egl'))]
        check('SDL bundled graphics declarations do not claim SDL native implementations',bool(gl) and all(e['availability']=='not_built_in_target_graphics_api' for e in gl))
        check('SDL_main remains an application hook',keys.get(('platform_extra:sdl3','SDL_main'),{}).get('availability')=='application_implementation_required')
    if 'platform_extra:apr' in census_components:
        skip=[e for e in pub if e['component']=='platform_extra:apr' and e['name'].startswith('apr_skiplist_')]
        check('APR skipped non-C99 skiplist is an unavailable contract',bool(skip) and all(e['availability']=='outside_selected_profile' for e in skip))
    if 'bundles_extra:gb' in census_components:
        check('gb disabled examples and internal array helper stay unpublished',('bundles_extra:gb','foo') not in keys and ('bundles_extra:gb','gb__array_set_capacity') not in keys)
        platform=[e for e in pub if e['component']=='bundles_extra:gb' and e['name'].startswith('gb_platform_')]
        check('gb optional window backend stays an unavailable profile',bool(platform) and all(e['availability']=='outside_selected_profile' for e in platform))
    if 'bundles_extra:ea_libc' in census_components:
        ea=[e for e in pub if e['component']=='bundles_extra:ea_libc']
        check('embedded libc exposes exactly its 80 namespaced implementations',len(ea)==80 and all(e['name'].startswith('lmx_ea_') for e in ea))
    if 'bundles_extra:cute_sound' in census_components:
        excluded=[keys.get(('bundles_extra:cute_sound',n),{}) for n in ('cs_load_ogg','cs_read_mem_ogg','cs_load_wav_rw')]
        check('cute_sound OGG and SDL2 RWops remain outside the SDL3 WAV profile',all(e.get('availability')=='outside_selected_profile' for e in excluded))
    if 'scientific_formats:pnetcdf' in census_components:
        raw=(a.source/'vendor/pnetcdf/src/include/pnetcdf.h.in').read_text()
        names=set(re.findall(r'^\s*PNETCDF_PUBLIC_API\s+[^;{}]*?\b((?:ncmpi_|cdl_hdr_)[A-Za-z0-9_]+)\s*\(',raw,re.M|re.S))
        missing=sorted(n for n in names if ('scientific_formats:pnetcdf',n) not in keys)
        check('independent complete PnetCDF public annotations represented including CDF header parser',len(names)==924 and not missing,{'expected_names':len(names),'ncmpi_names':sum(n.startswith('ncmpi_') for n in names),'cdf_header_parser_names':sum(n.startswith('cdl_hdr_') for n in names),'missing':missing})
    for cid,name in [('scientific_formats:netcdf','nc_close'),('scientific_formats:pnetcdf','ncmpi_close')]:
        if cid in census_components:
            e=keys.get((cid,name),{})
            check('scientific integer file IDs are owner-bound resources: '+cid,e.get('ffi_disposition')=='typed_scientific_resource_bridge' and any(p.get('name')=='ncid' and p.get('semantic_role')=='native_resource_id' for p in e.get('parameters',[])))
    if 'scientific_formats:hdf5' in census_components:
        names=set();comp=next(c for c in d['components'] if c['id']=='scientific_formats:hdf5')
        for header in comp['headers']:
            path=a.source/header.removeprefix('third_party/lmx_c99_compact/')
            names.update(re.findall(r'^\s*(?:H5_DLL|H5_HLDLL)\s+[^;{}]*?\b(H5[A-Za-z0-9_]+)\s*\(',path.read_text(),re.M|re.S))
        missing=sorted(n for n in names if ('scientific_formats:hdf5',n) not in keys)
        check('independent HDF5 core and HL annotated functions represented',len(names)>800 and not missing,{'expected_names':len(names),'missing':missing})
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
