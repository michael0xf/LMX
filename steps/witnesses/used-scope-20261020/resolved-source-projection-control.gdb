set pagination off
set confirm off
set print elements 8
file C:/Nyasha_Planet/LMX/build/codex_catalog94_build_01/l2trans.exe
break main
run
set $p = (L2Path *)malloc(sizeof(L2Path))
set $s = (L2PathStep *)malloc(sizeof(L2PathStep))
set $o = (L2ReferenceSource *)malloc(sizeof(L2ReferenceSource))
call (void *)memset($p,0,sizeof(L2Path))
call (void *)memset($s,0,sizeof(L2PathStep))
call (void *)memset($o,0,sizeof(L2ReferenceSource))
set $p->n = 1
set $p->cap = 1
set $p->steps = $s
set $p->leaf_kind = 13
set $p->leaf_ty = 42
set $p->leaf_model = 5
set $p->indexed = 1
set $s->formal = -1
set $s->node_host = -1
set $s->own = -1
set $s->nsrow = -1
set $s->kind = 13
set $s->locus = 7
set $s->elem_model = 5
set $s->elem_ty = 42
set $r = (int)l2_reference_source_of_path($p,$o)
printf "actual compiler94 indexed prepared leaf: answer=%d logical-Model=%d actual-source-schema=%d layout=%d\n",$r,$p->leaf_model,$o->schema,$o->layout
set $p->leaf_kind = 10
set $p->leaf_mi = 42
set $s->kind = 10
set $s->locus = 1
set $r = (int)l2_reference_source_of_path($p,$o)
printf "actual compiler94 composed prepared leaf without declaration row: answer=%d logical-Model=%d actual-source-schema=%d layout=%d\n",$r,$p->leaf_model,$o->schema,$o->layout
call (void)free($o)
call (void)free($s)
call (void)free($p)
quit
