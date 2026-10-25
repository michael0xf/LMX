# Slice218: call, evaluator and admission bodies on L2

The latest local acceptance is recorded below; publication SHA is not yet assigned.
The following preparation sections retain their original chronological boundaries.
Codex is the sole writer/build; the full goal and source-closed S8.6 remain OPEN.

Existing language-owned stage-copy copied 409 known 217 inputs, 0 failed. Six existing bodies moved to the
same values module: `lmx_walk_call`, `lmx_walk_prim`, `lmx_walk_eval_result`, `lmx_walk_eval`,
`lmx_walk_admit`, `lmx_walk_admit_letter`. The module now exports 123 functions; six top-level L1 functions
and the conditional observer remain. The engine delta removes only these six bodies; the remaining
functions, prototypes, observer and three program globals retain their 217 bytes.
No new grammar, compiler rule, ABI, hidden root, global binding, helper or C shim was introduced.
The existing primitive header supplies the existing nine-argument native callback ABI.

## Preserved failures and repair

Initial CALL/PRIM FE01 and backend01 exited 0, without C compilation or execution.
Full-six FE02 refused foreign `work.ty`/`work.num` projections at internal `value_num` arguments.
The existing record declares int/size_t; two exact casts repaired the type boundary without changing logic.
FE03 and both backend03 exited 0. Static C review nevertheless found a real RED in C03
`39CEBEAFECFF7F8437439119481932149F7E56083B5A080F3E4A8D5AAEDA1BA4`:
CALL lines 10903-10910 emitted calls for later `addr:`/`entry:` updates of zero-initialized foreign function-pointer
locals; PRIM line 11215 likewise emitted `entry(record->fn)` instead of assignment, before the real callback.
Those artifacts and the failed source snapshots are preserved. Successful translation was not accepted
as correct C or runtime evidence; C03 was not compiled or run.

FE04 used late initialized declarations instead of mutable callback updates. FE04 exited 0, but backend04
refused 7799:2 because ordinary-language call preparation appeared inside the C function-pointer declaration.
The source/module and backend failure are preserved; no C04 or runtime result is claimed.
FE05 uses the existing explicit C-ABI export `c.lmx_walk_callable_addr` in that initializer, with its exact
LmxEntry cast. This is the same L2-maintained getter, explicit arena and selected callee, not a new lookup
or alternate dispatch. FE05 and both backend05 exited 0.

Independent static delta review of C05 found PASS: late `addr`/CALL `entry`/PRIM `entry` declarations
really initialize at 10901/10903/11207; the erroneous null-update-as-call is absent. CALL selects native
after actuals, publication and map admission; PRIM reads its callback immediately before invocation.
Both retain all nine ABI arguments and the baseline 217 owner/data/code distinctions.
The other four C bodies are byte-identical to C03; their earlier static review found no additional drift.
This repair PASS is static, not proof of executing every callback/evaluator/admission branch.

Final maintained source pins:

- L2: `6569145D32514B353D57F0F7BE73BA618AE014E79C911FAFEFD489BFF65AD379`.
- Engine: `FEED32E63B0058348E11E51B5CC0FBC8190A701DEB14A3A58BEC0D47C9EC32C7`.
- Recipe: `6FEE6135A934727B1778859A457C0CB048B3698FF5567C6740CE1F96378601B7`.
- Module C05: `D336DAA24ED372AA3893222B5D080DE8F83FDCF3C003999036B66FE31BD98A8D`.

API A6C24512/CAPI5A85896F. The local history is recorded in
`build2/codex_fix218/trace/frontend-observations-01.txt`; generated module C is
`build2/codex_fix218/gen/lmx_walk_values-05.c`.

## One unchanged native witness

The unchanged maintained witness source 9D6C468D used actual ordinary216 frontend 09098687 and the 123-export
predefs. Native FE01/session68818 terminal 0 and L1 backend01 exit 0 were observed by the writer/build.
Program L1: `11715967D17093BBCBEE49FAA127E6863ECB8763CBA7C71764AC127A35ED909E`.
Program C: `8FD4ABDCB260092257359573FBF96941FEB3071A25C6B565C11095E137653048`.
One strict CC01 actually exited 0 in 6.7580124 seconds, without another GCC or an old driver.o.
The terminal `NATIVE218_CC_EXIT=0` printed before the JS wrapper TypeError; compilation was not repeated.
EXE: `951E01258F88A3A20D85EE21DF0E640AB3BD537A3C4CC1F1E537A8FC81C78DD6`.
Fresh RUN01 actually exited 0. The saved RUN log was read independently and contains:

- Reparent 29->57, other 11, failed 0.
- Main/worker bindings 1/1, errno 61->62, lane 43, distinct main/worker IDs, ready 1/count 1, failed 0.
- Root 42->43, other 100, turn 0/same 1, report-fields 1/report-value 1, close 0/failed 0.
  The pre-existing failed-child settle diagnostic remains in the log; it is not silently removed.
- Walker value 41->42, saved 41, size_t 18446744073709551614->18446744073709551613,
  null-present 1/held-null 1, char-refused 1/char 65/temporary-char 43, sum 42, overflow 12/division 12, failed 0.
- Boundary key 9/ordinal 1, implicit 1/2, missing 1/boundary 9/classified 3; code 53->111,
  mark 0/sealed-mark 1, failed 0. Final native-closure result fields are all 0.

Exact local records: `build2/codex_fix218/trace/native-closure-01.observations.txt` and
`build2/codex_fix218/trace/native-closure-01.RUN.log`.
These executions are native C-door helper evidence, not genuine walking of all six moved bodies or
all their branches. No new witness, assertion matrix or runner was added.
Seed/ordinary SHORT 218, publication/replay acceptance and source-closed S8.6 remain OPEN;
no complete uniform native/runtime-callable/admission/signature or full-goal result is inferred.

## Combined next slice after216 publication

Verified216 code201938e9a424df2b91e2ccb3cba74536abf6cc40/recordcb5507c8a415f1bbb1ea13ce2e76156328443070
are pushed; main and13 raw Git blobs match. Root216 historical manifest pin now refers to that code blob/frozen216 recipe.
The next single slice218 combines the19 prepared217 bodies with these6 bodies,98->123 machine exports;
only6 top-level L1 fn/3 globals/conditional observer remain. The intermediate217 draft is NOT bootstrapped separately.
Actual218 native compilation/execution above covers current123 predefs, without claiming individual25-body branch coverage.
Final3 GNU-U0 patches from frozen216 replay with --fuzz=0/rawcmp0 in218/runs/replay-from216-01.
Initial2/from217 and separate217 preparation receipts remain historical, not an additional accepted release.
Root/stage218 recipe raw-equal6FEE6135. Eight independent source/module/header pins are recorded BEFORE ordinary generation;
GNU0. No compiler/grammar/new runner/ABI/signature exception, globals deletion or observer shim is added.
Compatible seed218/session91496 starts2026-10-25 13:41:37 UTC from actual216 G2/working708A39F4,
FE09098687/source09649180/C0C476E32, production runtime5194C29A; fresh runs/seed-tool-01.
Maintained218 src/tools/headers/tests and root recipe are frozen while it runs. Seed/startup/hash/ONE ordinary SHORT218
and actual current runtime remain pending. This mixed bootstrap is not source-closed S8.6.

Seed/session91496 now actually terminates0 (observed13:55:05 UTC): L179B5C38E/C7DB772AD/EXED470A20D.
Both generated L1/C were independently copied/pinned13:48:16 while both future G1 outputs were absent;
the seed later reports the same hashes. Fresh startup/hash40430 actualexit0/13checks0roots.
ONE ordinary SHORT218/session36182 starts13:55:48 UTC from that actual started seed in fresh runs/bootstrap-quick-01.
All218 maintained inputs/root recipe stay frozen. Runtime/ordinary218 reproduction/G1/G2/start/hash/replace remain pending.

## Actual ordinary218 acceptance,2026-10-25

ONE SHORT218/session36182 now terminates outer0/BOOT218_EXIT=0:
13:55:48→14:26:12 UTC,1824 observedseconds; smoke6/0/13checks0roots.
RuntimeC4E4DB5AA/prod7098BDC6/observe199B506D; ordinaryFE9E288AA9/source09649180/C0C476E32.
All four existing native/forced ownerroot0/1 logs were read by main, not accepted from an ACK:
calls41/41/42/42/43/42,counts42/42/43,afterA1count100 A1=101/A2=43;
runtime142,p.y42,p.x1,p.pad9,q.w10; Cbindingrefusal30,Thin33,FarBare34/y2,
unusedformal3/calledplus1=8. Actual2links/8libraryobjects/currentprod7098BDC6,notobserve199B506D.
A separate read-only provenance audit matches36commands/168hashrecords/80files,allkind0/exit0.
These are the existing small witnesses, not25/25 moved-body or all-branch coverage.

G1 7F3E79433814829B1C7620E1626E2EA28521EFBC650FB86330607462A6636B19
actually invokes build-self to buildG2; both start/hash and become the working binary.
G2+working3DB51437B8E78C38DE74118FEEC112275E1F4C3179BFFBA0212194B9E6800011;
GNU working/G2 rawcmp0. Both L179B5C38E/C7DB772AD match the independent seed;
the two G2peer pins were saved14:13:18 before both G2outputs existed.
Final17pins language9684/GNU0; EXE-SAME1/session70522 actualexit0/13checks0roots.
Ordinary218FE reproduces the executed native218
program L111715967/C8FD4ABDC rawcmp0/language64928/2pinsPASS, without C recompilation/rerun.

Full35 verified runtime L2 sources are now in maintained dev/l2src_sandbox.
34 are raw equal to frozen218 stage sources. The values source removes only two EOF LF
for repository diff-check (stage6569145D/179633bytes→canonicalDEC369EB/179631bytes);
the actual executed source remains the stage hash, not silently relabelled.
All70 explicit path/hash pairs pass language7794/GNU0. No old maintained L1 was deleted
or legacy route retired here; canonical preparation integration remains OPEN.
The next source-first header recipe is isolated219, NOT accepted as executed by218.
Frozen218 is not rebuilt. Mixed bootstrap/externalBASE/remaining handwritten compiler+P0,
globals/retention/uniform native/runtime-callable/signature/admission and mail/full8/8a remain OPEN.

Final manifest612/110AB3D9D76EF936004CDDE29915D24A82DB0B47A3A5F511F49EAFBC3DA7C523
is generated by actualG1/session72019, verified by language44765 and independent GNU, all0/612files0failed.
The manifest covers the frozen executed inputs/artifacts and explicit canonical source bytes;
packet text copies may be LF-normalized, while hash references continue naming the preserved stage bytes.
Publication/main raw readback is pending, not inferred from these local checks.
