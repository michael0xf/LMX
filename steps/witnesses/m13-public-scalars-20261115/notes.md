# Slice396: active public scalar type resolution

Baseline395 is committed/pushed as73196f98420a9ff5d6c0837217bbe1a754b144c9 in main.
All work and commits use this same main checkout. The artifact stage below is not a git worktree.

Pipeline: build2/codex_fix250generationchain01/runs/sol-m13-public-scalars-20261115-01.
Stage: build2/codex_fix250generationchain01/sol-m13-public-scalars-01.
Seed: accepted395 actual G2 frontend/tool/runtime. Runtime ABI395 is unchanged so far.

The existing source contract/interner retains source word, pointer depth, const and raw-C role.
A shared borrowed reader now selects eligible scalar spelling from the ACTIVE primitive.description;
the existing physical profile exporter consumes the same eligibility. Native printing alone projects
that spelling to an alias, using the existing module identity and reversible spelling bytes. It does
not guess a runtime row number, merge semantic aliases, or create a second type registry/parser.
Machine locals use the existing foreign by-value local route, without treating scalars as owned pointers.

The existing L1 header alias receiver is used for ordinary generated units as well. Imports register
their types first; source-order foreign/type collection precedes one validation boundary. The previous
two implicit validations are removed, true duplicate aliases still use the existing rejection, and
a nested L1 body owns its own boundary. Header restrictions remain on the existing header path.

The maintained machine suite accepts an optional explicit PRIMITIVE source for that unit only.
Its ordinary owner retains its own table. The custom fixture's ProbeReal is absent from the runtime
catalog and appears at a different row position. The standard fixture checks original C epsilon and
LLONG_MAX constants as well as round trips, so a narrowed local cannot satisfy the precision oracle.
Both fixtures pass private native03: the machine body executes natively, and each ordinary owner
passes native/forced with root0/root1. Machine assertions do not establish typed Graph Run.
The ordinary public_pointer_names method with double*** also passes all four modes in pointer01;
its generated inline L1 scalar alias is consumed by the changed backend.

The existing partial frontend recipe now selects backend modules through the same explicit module list.
Three unchanged backend translations and libc are verified/reused; two changed backend modules and
their aggregate are really rebuilt. The null selector preserves the whole G1/G2 recipe.

Source01:928 stage verification PASS; Toolhost01 e73716ed and verify-record54/0 PASS.
Stage preparation accidentally overlapped Tool01, but both handles ended0 and its consumed closure was
verified afterward; generated code confirms Values173. Tool02 refused the first L2 translation because
the two new wrapper bodies retained old end targets. Corrected Tool03 on Source03:930 passes,
SHA5e5aad88cd17c961fbddb19d8632a7d164df3117b05aefb40bc785a6223568c0; verify-record54/0 PASS.

FE01 passes Helpers L2, then refuses the new reserved local node in Values. It is renamed entry_node;
Helpers is not translated again. FE02 passes Values/Types, then refuses a nested call/cast/next spelling
in Lower's initializer scanner. Existing typed last/n locals replace it in Lower and Emit.
FE03 on Source06:930 passes all remaining frontend modules and backend StateHelpers. It refuses a
missing tail cutter in backend Emit after moving early validation; that cutter is corrected for Source07.

Reuse manifests grow only with actually completed translations:74,78,86, then102 inputs.
The24 shared declaration ABI files pass verification. Values' new173-function C header is generated
from the passed L1 declaration. Removing a private helper shifts Emit's prototype parameter names;
an exact comparison catches the difference, and its actual C header is regenerated from the passed L1.
The other three completed headers match accepted395 byte for byte. StateHelpers' C header, removed by
the failed backend attempt, is restored only after that exact declaration equality is established.
No frontend body is retranslated for these header preparations.

FE04 on Source07:930 passes backend Emit L2, the changed backend C build95ca3cc3,94 regenerated headers,
the24 ABI checks and frontend L1-to-C. Frontend C compilation finds two raw C argument expressions
using by-value text fields. Existing typed pointer aliases fix only Values in Source08; the new backend
and all other passed translations are reused. FE05 thin80848a7b/hosted1ba15bb5 passes compilation/link.

Native01 refuses all four L2 cases before execution: a synthetic table header probes Lmx before the source
catalog is registered, and scalar_row's eager prim_load poisons pr_ready. Source09 adds a quiet table_find
readiness guard while leaving prim_load strict. FE06 hosted10eb91e6 passes; native02 now passes the old
exact scalar unit in all four modes and both forward_header twins in prod/observe/native/forced/root0/root1,
including their walked/native counts. Those control binaries are retained.
The two new units still fail L2: sizeof(float) and ProbeReal's declaration role use prim_type_word through
ptr_type_word, which lacks the active scalar fallback. Source10 connects that common route, preserving raw C.
FE07 thin013f78ce/hostedce2e5493 passes the Types-only build and native03 passes both new machine units.
Source11 adds only the ordinary pointer fixture; compiler code remains Source10. Tool03 selftest reports
zero failures. The canonical manifest matches Source11 exactly, and repo/stage verification passes931 inputs.
Final manifest SHAae015927aa7075a1ca5a9716a6cb416cc0fe8ce6ff290f6313e73a6612739fd5.
Whole quick01 passes on frozen Source11: genuine G1 builds and tests whole G2, each generation passes9
smoke cases, tool startup/hash and a356-file consumed closure. Fixedpoint02 passes29 checks, including
G1/G2 generated L1/C, normalized executables, prod/observe runtime objects, headers, consumed manifests,
canonical/source equality and repo/stage verification931.

Prepared fixedpoint01 was not run: its two seed395/runtime object comparisons became inapplicable when
the new resolver changed generated C aliases. Read-only review of the whole driver.c diff confirms only
three verified alias substitutions and two added include/typedef pairs; all other text agrees. This is
review evidence, not an additional test gate. Cross-version object equality is not claimed. Fixedpoint02
retains all29 applicable checks, including actual new G1/G2 runtime object equality.

Actual G2 frontend SHA6337a681878b7b0cbcb097c9a841c99d2cad52e7483bf27f4303bb6bebe5b5d5;
Tool SHAbf419e67ee8d60207bf90eb08b61e6bd2bc77754fbecd068c3eaf51df1e26e0d.
Runtime prod90d44af7516e8202046baa456c802831a6713d91206a07f5f669816f2db37d6e,
observe8054aa9503d850909f611d12dcb54e0eb47326089b301c7499f2599ae482e74c.

G2 targeted01 is NOT a passing SUITE: the root command mistakenly supplied the runtime directory as
the prod object, and all8 links refused. L2/L1/C compilation had passed. The same8 existing p.o files
were linked with the correct driver.o by the external linker; no source translation or C compilation
was repeated. The existing L2 driver itself asserted entry7 in16 runs (four cases, native/forced,
root0/root1), all exit0 with81/85 driver checks. Cases: public_scalar_resolver, public_scalar_active,
public_pointer_names, exact_scalar_storage. Logs remain under g2-targeted01/*/recovery-run-root*.log;
the failed suite log and original LD logs remain unchanged. This recovery is not reported as SUITE4/0.

Standard G2 Graph01 build passes, SHAd8458bbc363be5d56834033e5bb3fc2437428243e650cc660ebe11dc3dcda861.
declared_model_interface, construction_paths_owned_data and declared_model_missing pass interp/native/forced;
the last retains expected build4. Graph checks3/0. All code producers are terminal.
Standard G2 render01 passes35 paired chapters,14 implements cases and both source snapshots; generated
semantics are unchanged. Docs-check01 reached EOL after the earlier phases passed, but the root had not
created PRIVATE_OUT, so os_run could not write its log. It did not measure a bad line ending.
Fresh docs-check02 with both new directories passes35/14/27/44/615, links/LF28277. git diff --check passes.
Final indexed docs-check01 passes35/14/27/44/615, links/LF28283, with26 owned files staged.
Gate result annotations are added as outputs after the check, not as new semantic inputs.
Both working/index diff checks pass; commit/push396 follow directly in main. Semantics source and grammar are unchanged.
No implementation-wide success is claimed.

Continue the [main v3](../../../next_core_tasks_v3.md) and [common pipeline](../../current.md).
Owned public scalar actual/result snapshots and ABI-checked ordinary receiving remain the next connected
work, followed by typed Run/FFI/Foreign-Array and shared cache/flush. Complete M11/M13/M14 remain OPEN.
