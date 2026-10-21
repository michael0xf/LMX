# Private122: one explicit typed-value channel at the uniform call boundary

Baseline `fcf8ce47`, exact121 source/header snapshot in
`build/codex_native_values_122`. Codex sole writer/build; goal ACTIVE.

Verified private channel slice, NOT an accepted public ABI or completed native
producer implementation. Public dev is unchanged.
The existing uniform runtime entry is extended with an explicit optional
computed-value input span and the result's context output. These are
activation metadata, not new program graph fields, fat pointer cells,
an opcode or a global/current-call registry. The common value record is
shared by native/walker, not recovered by casting arbitrary raw ABI storage.

All runtime callback types/definitions/call sites and generated adapters must
migrate together; old native objects must NOT be linked or executed under
the new entry type. Ordinary raw-storage APIs remain wrappers around the
same dispatcher with absent context. Typed spans must match their supplied
storage. Dispatch remains by the selected occurrence's native word alone.

Input values are immutable caller-owned computed values. Result context
means only the Model/reference-sheet fields of the ordinary result record;
the existing result witness/raw-storage marshaller owns presence, type and
payload, and must retain that pair for references and clear it for numbers,
throws or stopped calls. Native entries that cannot yet produce a pair leave
it absent; it must never be guessed from payload, layout, history or parent.

## Common implementation and exact bytes

`lmx_value.h.lm1` moves the existing, unchanged-layout `LmxWalkValue` record
out of the walker header so both backends can use it. The historical C type
name is retained. Uniform native entries and the installed prim-walk hook
receive the explicit span and result context as their eighth/ninth arguments.
All canonical declarations/definitions and emitted adapters migrate together.
The selected occurrence's native word still chooses execution; the extra
parameters do not select a Model or execute another graph.

`lmx_call_prim_values` is the common dispatcher. Its legacy raw entry wraps
it with absent metadata. A fresh local result context is passed to the
selected native entry or walker hook. The pair is copied to the caller only
after return, so output-context/input-record alias does not destroy the input
before execution. Nonzero status and a real Message stop clear success context;
stop also clears the raw result. No current-call global or TLS is introduced.

Walked CALL and PRIM pass the already evaluated Value span, including its
CURRENT Model/reference sheet. Both use `lmx_walk_native_result_context` to
marshal a native result: declared result witness/raw storage supplies its
presence/type/payload, and only references retain the returned pair. The
native→walk hook uses the SAME121 typed activation; it detaches the returned
context before releasing scratch. Numeric/void results do not inherit it.

| Exact input | SHA256 |
| --- | --- |
| compiler source | CFD2970C6B47B0B5185265F91470A0DB6F8145D89B4E4F074809B44D98F408C8 |
| common value header source | 1854B27992C102944C5CA004A14A5009AB2557E5262E561BF7B9E2AF96E23585 |
| call source | A13F2685E5ADC74450EB04EE0F76C15F583D0526FCA99A5FF53CAAFCFEBE4BEB |
| walker source | 6C9E8D3E48AD716DF8781F269F96FFA69EE4C51FEB5A54EFA73CDBC1FD645C75 |
| generated frontend C | 4F3CC658FA3E28F29076011828C87EB95F140FF97221ED2A467B8EAA82A3FF6E |
| frontend EXE | CC3809CC74162A59A39B10EC3D194BCDD65ACD1F2075FDE83E73183BBA5F7F2E |
| generated runtime C | CBF312745259638CB1411C6596DAFCF1C8E59B9DE36508D9DF910DCC48037C4A |
| renamed runtime object | 0862A723C400ECE3ACFCBDB5A297F6A76021DBFC7E282F77A7EDBDD0AEB2A1DA |
| normal-main runtime object | 59B72EB9EFDE6A0656613076D7F7C1EB72ECA12ABAE2DB86B81005C75FA0F161 |
| freshly translated kernel C | 6207703197AA2FBCC02A3D3873D1309D89C8BC648550D9EA5FA693CD09DE1AC4 |

The [exact121→122 source patch](witnesses/used-scope-20261020/native-channel122-u0.patch)
has SHA256 `3F8005B4CDFEE9CAC81257C13630D7FBFC3BE1A33CA9CCD258C35419928B972D`.
It changes13 source files (one new header); `git apply --unidiff-zero --check -p0`
passes against exact121. Unrelated source/header bytes are unchanged.

Terminal13469 pins are frozen in
`build/codex_native122_terminal_02.inputs.sha256`, SHA256
`FFC550912960F90CDDF94C76C73C4D4453AFAAFFCB6816DD2DA768F97E0D521A`.
All12155 upstream pins were reverified; final source/header and executed
graph/C/object/EXE hashes and alias proofs were independently checked.
All named build/replay/mutant/kernel workers are terminal. The first terminal
recipe stopped after verifying upstream inputs because PowerShell5.1 kept
a converted JSON array nested inside `@(...)`;02 fixes only receipt parsing.

## Actual assertions and loss controls

The [executed fixture](witnesses/used-scope-20261020/native-channel122-test.c)
has SHA256 `D36F63D894E5F4BDB829343D5D178A1CAF86420763EB8CBAD03425FF301F887F`.
Its [inherited72 adapter](witnesses/used-scope-20261020/codex_native122_inherited.c)
has SHA256 `26EE7BF52E0B86CFF30E6CAFB4BD974E3BE5D5413BA70F1FB2277558D458DB9D`;
only the native callback arity changes, all72 prior oracles remain. The final
fixture executes93 checks/0 failures, O2/strict, against a freshly compiled
122 anchor and runtime, never a seven-argument native object.

New checks execute real nine-argument native callbacks, native→native re-entry,
native→walk and walk→native→walk; CALL and PRIM share the result marshaller.
Actual CURRENT E maps to9, not stored D's7. Real writes/taken-address replacement
observe41/43 and unchanged neighbor7. It covers caller-input immutability,
input/output-record alias, present null, unannotated results clearing stale
context, half-present context rejection by the SAME receiver, failure status,
numeric123 width and shared receiving-record immutability. A real entered
Thread/Message stop writes a success pair/raw result in the callback, then
the common dispatcher clears both and the Thread leaves normally.

Three explicit generated-runtime-C loss controls run the IDENTICAL93 fixture:
drop actual span18 FAIL; drop native result pair8 FAIL; drop walk-hook return
pair2 FAIL. All exit1 through assertions, no setup refusal or crash. This
proves transport sensitivity, not generated-native expression annotation.

Fresh122 kernel01 translates its source again and executes unchanged62
context,57 relocation+20 carry,789 template,54 pending and48 priority checks,
all GREEN. Its recipe's final text still says121; the actual stage path,
headers and kernel C SHA above are122, not a reused121 compiled unit.

## Fresh source matrix and provenance limits

`build/codex_native122_values_03.ps1`, session56192/PID13144, startUTC
2026-10-21T11:45:33.7771641Z, TERMINAL0. All85 units were freshly translated
L2→L1→C, compiled and linked under the new callback type:170 actual runs,
162 GREEN and8 unchanged copy RED, with exact old exits and7 oracles retained.
Original154+target4 stay GREEN. `--walk-methods`, root mode and measured native
bindings are preserved; this is not just forcing a walked root around old
native methods. Old native unit/anchor objects are NOT reused. The unchanged
external libc56 object is reused; its generated C has no uniform-call entries.

`inventory.json` SHA is
`E0B62DCD1C9B7F540A292CD0FD8060493B19D6A5D686E53EB91B17BF09AA9E9B`;
`summary.json` SHA is
`55BADCF769FD405F2F6071717DC8C7FE449587EF57899951B202B4C8133A92E5`.
Commands/CWD, input arguments, generated graph/C/object/EXE and compiler/runtime
SHA values are retained per row. This is a focused85-unit matrix, NOT full gate.

Earlier replay receipts did not pin every historical L2 source pathname.
The new ledger proves14 byte-identical aliases by SHA and `fc /b`; for5 other
sources, the pinned118 frontend re-executes the original command and reproduces
the EXACT frozen118 graph SHA. Those5 current sources are now pinned, but their
historical source bytes are NOT claimed proved. The completed summary's field
`ByteIdenticalAliases=19` is misnamed: it counts ALL ledger entries,14 byte
aliases PLUS5 graph reconstructions, not19 byte-identical sources. The original
summary is preserved unchanged; `input-aliases.json` carries the distinction.

## Preserved failed attempts

Build01 omitted regeneration of the changed merge header and left three direct
saved-entry calls at seven arguments: strict compilation refused them. Build02
repairs those sites; the first fresh anchor then finds emitted direct mail/
call helper calls with seven arguments. Build03 repairs those emitted calls
and the fresh85-unit matrix compiles with strict incompatible-pointer guards.
No old native object is run to conceal this ABI dependency.

Values01/02 stop during input-provenance preflight, before GCC;03 adds the
explicit byte-alias/graph-reconstruction ledger above. First93 predecessor
fixture01 executes91/0; its drop-span mutant crashes in TEST `n_half_pair`,
which dereferenced a missing optional span. GDB identifies that exact line.
Fixture02 adds null guards only to test callbacks (no oracle relaxed) and two
real-stop checks:93/0; all three93 loss controls then fail assertions normally.
All failed bytes and logs are preserved; a crash is not counted as a useful
negative-value assertion.

## Still open / next dependency

Generated native body expression/binding/path/copy producers still do not
fully consume/produce the pair. Typed bodies need the SAME explicit channel;
the callable-merge adapter forwards result context but currently passes an
absent input span after `l2_mad_inputs` because its typed remapping is NOT yet
implemented. T5/T7 constructors, primitive admission/copy producers, physical
field/index metadata and relocation/lifetime through the final copy map stay
OPEN. They must not infer a Model from first admission, physical template,
parent or pointer payload, or re-evaluate indices.

Copy positives remain8 RED; last full112 gate stays1011 FAIL/3754, not rerun
here. Public dev remains compiler56/runtime69/reader76. Clean kernel, complete
native/walker path unification, §§8/8a self-build and T01–T26 are NOT complete.
Goal and hourly lmx-goal remain ACTIVE. Continue the SAME result/value channel
through native producers; do not turn these channel-only fixtures into a claim
that the existing copy failure is fixed.
