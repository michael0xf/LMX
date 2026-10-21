# CURRENT value context — private119 WIP

Baseline:`d71d2b3a`,exact118 source snapshot in
`build/codex_value_context_119`. Only `lmx_implements.lm1` and its header
change initially;no pointer ABI,Model pool,graph field or opcode is added.
This is the common admission input needed by computed reference values,
not a claim that those producers or copies already carry CURRENT Model.

The existing two-field sourceContext graph is a representation adapter.
`lmx_implements_admit_receiving_parts` accepts its same CURRENT Model and
declared-reference sheet directly. Both ordinary graph adapters and future
typed-value producers use one receiving-record decoder and one templates
resolver. Explicit absence cannot recover record child4;half-present and
malformed components refuse. No source graph is allocated or modified to
wrap the pair. This prepares native and walker to pass metadata belonging
to the same once-computed value instead of reevaluating a path prefix.

Actual119 source/header SHA256:

- `lmx_implements.lm1`: `1F065B6AB03EEB93A316318A7FA7182585380C7DAAEF33A5317BEC12108DE446`.
- `lmx_implements.h.lm1`: `DD16F2543C5A3BBD237910BAA8FBE316FBE35C91C87505C524C5ACCC0114820F`.
- Generated kernel C: `850212A2177D31B6DF0C150E3A285E97C3ACDED65C4DE35AF36097208E1F2DD9`.
- Generated driver C: `674C65C4ED3B697280ACED2EC55B4C56319CB8738213ED10CF4A7823A7C361DB`.
- Actual runtime object: `5F24D49F6777367E29073D810B9A049122D4222BAB30595EC4D614B42387D9EA`.

Actual62 context assertions GREEN (the inherited36 plus26 direct-component
checks). Original57+20 copy/789 templates/54 pending/48 priority checks are
also GREEN. Direct components test both current namespaces,real9 versus7,
write41,taken-address replacement43,ordinal/LAST maps,interleaving,absence,
malformed/half-present components,missing CURRENT proof and shared-record
immutability. They allocate no temporary graph wrapper for the pair.

Fixture01 has62/1 FAIL because its new absence assertion over-specified
UNKNOWN. Read-only `absence02.gdb` measures NO0 at that exact direct call,
with no receiving-map publication;the inherited36 already require !=YES.
Fixture02 makes that same no-admission check. Production bytes and all
existing oracles are unchanged;the failed fixture and both traces remain.
This is not a changed positive-language oracle or a hidden kernel failure.

O2/strict runtime built. `codex_context119_replay_02.ps1` is TERMINAL0,
session92846/PID14220,startUTC2026-10-21T10:39:49.6864036Z. It performs85
real relinks and170 real executions:original154 and target4 GREEN;copy12
still8 RED/4 GREEN. Every copied positive's7 oracle is unchanged. None of
the source current-Model/copy positives is declared fixed.

This runtime-only replay reuses byte-pinned118 unit objects:there is no new
L2/L1/unit compilation and no119 compiler. The frontend is exact118 and
the only header delta is an added function prototype,not an ABI/layout
change. Original argv,cwd,check counts and machine-binding evidence are
retained per execution. Input checks cover371 paths. Replay01 stopped
before GCC because a library path was not explicitly in the118 receipt;
replay02 proves it byte-identical to the pinned library at the other path
(SHA256 `1EDAE70A026B25652420E7ECD2FF8361D848D476B78CDC448A5DE0FEC55576D7`).
That alias is included in119 pins. Future LmxWalkValue layout changes MUST
recompile every consuming unit;this relink recipe cannot be reused for them.

Published [exact118→119 patch](witnesses/used-scope-20261020/value-context119-u0.patch),
SHA256 `38408A97902BFCD24BBE6B17B206F515B79A9D95D987782251CB8E80940134FD`.
`git apply --unidiff-zero --check` passes against exact118. The exact
[executed62-check fixture](witnesses/used-scope-20261020/value-context119-test.c)
has SHA256 `6CEBD5272EC2B469A0710500CD4F824446C4EE67AC58B2E9941A32C4E1918784`;
its [inherited helper](witnesses/used-scope-20261020/codex_context119_prior_fixture.c)
has SHA256 `9C6D069F15CA24B4B7E84A94FE307278B729C606D34006DBC1D53DED6802B2F2`.
The helper is the published114 fixture with only main renamed;no oracle is
removed. Generated pending-views kernel C and119 headers are its build inputs.

Terminal9856 pins:`build/codex_context119_terminal_01.inputs.sha256`,SHA256
`1887BD1887F26C88F5DB823BD93D62E3911BC1F8818B92A3E98641FE6FA7E6DE`.
All9153 upstream118 terminal pins checked;all compiler/layout headers and
unrelated source bytes independently match118. Failed fixture01/preflight
replay01 remain pinned alongside their completed successors. All described
workers are terminal;their old PIDs do not denote current live work.

Next connected work remains value producer/working/input/result transport
and the same final relocation map for copied Models. Public dev unchanged;
full clean kernel,self-build and §§8/8a remain OPEN. Goal ACTIVE.
