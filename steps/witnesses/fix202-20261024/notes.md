# Slice202: inbox backing checks inside the existing monitor

Verified202; code SHA is recorded after the source/evidence commit. Base is record `bcef747f` / Verified201 code `e71cd436`.
Codex is the sole writer/build; Opus remains stopped. Frozen201 is unchanged.
Stage `build2/codex_fix202` copies only src/headers/tests/tools, excluding the protected basename.

## Source change and boundary

The three prechecks identified by
[POST-INBOX-PRECHECK-OUTSIDE-MONITOR](../../defects.md#post-inbox-precheck-outside-monitor)
read `inbox.array.data` only AFTER successful entry to the same existing monitor:
`lmx_post_accept`, `lmx_post_accept_transfer`, `lmx_post_take_inbox`.
Null-box/lane guards remain before entry. Every new null-backing return first leaves that monitor.
No second lock, atomic protocol, module state, hidden unit/root/context, layout, C ABI or language/admission change.
Init/close retain their existing quiescence requirement. The port count remains19 of35.

Actual generated C has entry before backing read in all three paths
(accept495/501, transfer621/627, take695/701), with leave on null backing.
The inherited201 prechecks were also present in200 handwritten L1; the finding was source-derived,
not a measured runtime failure and not caused by the OS thread-ID substitution.
This patch does not claim complete mailbox race freedom, all ownership/mail contracts or T01–T26.

## Actual results

- Direct L2→L1→C and strict C syntax passed; only unused-result-temp warnings.
  Silent successful translation tee sinks were not created; no empty logs have been invented.
- Preliminary runtime202 completed: exit0, `REBUILD runtime 0 failures`, smoke6/0.
  The four actual S81 native/forced logs retain41,41,42,42,43,42; after A1 count100,101/43;
  runtime candidate142/y42/x1/pad9/w10; refusals30/33/34; callable3/8.
- The EXISTING maintained L2 mailbox witness is unchanged (`D117CC22…`). Its native execution
  against202 observes wrapped count4/capacity4, producers64/64, delivered64/64/128, distinct IDs1,
  `POST checks failed=0`, exit0. Caller-owned worker arguments live through joins.
  This is native C-door callback transport, not interpretation of a machine callback body.
- Source recovery is a delta from frozen201, not a creating patch. Successful zero-fuzz replay and
  raw cmp are captured by `source-replay-03.command`/`.txt`. Two prior capture attempts failed before
  applying anything (missing directory, then patch-path depth); their original failed logs remain on stage.
  Source/header comparison lists only post L2 and its generated L1; all C/L1 headers are unchanged.

## Inputs and remaining work

Post L2 `3DE44700…`, generated L1 `C5012F2F…`, direct C `9896AE94…`;
post L1 header `DC9F4E81…`, C header `1DCA7325…`.
Repo/stage recipe remains `7BA2E8BF…`; compiler source `DE127434…`.
Runtime C `70CBB2B6…`, production object `98BBDF67…`, observed object `0F36C50B…`.
The unchanged witness builds to EXE `8E1023F7…` against this runtime.

Seed202 completed: exit0, `REBUILD tool 0 failures`, start/hash/smoke pass;
EXE `B4A8DC74…`, L1 `4D1FA6A3…`, C `865C32AD…`.
The compiler derives the unit-name hash from the input path (`l2trans.lm1:7216–7220`):
after normalizing only that prefix, seed L1/C equal201's tool bytes. The recipe is unchanged.
ONE short bootstrap202 completed: exit0,0 failures, smoke6/0; operator-observed interval1337s.
G1 actually built G2; both tools started/hashed their source and replaced the working binary.
G1 EXE `A9E1690C…`; G2/working `FCE66178…`. G0/G1/G2 L1/C match, normalized `EXE-SAME 1`;
raw EXEs are not asserted equal. All23 expected byte equalities pass the existing language verifier.
Manifest125 passes that verifier and independent GNU `sha256sum -c`, both terminal0.
The final source/header comparison still lists only post L2/generated L1; headers remain byte-equal.
The exact read-only GCC dependency query, run after pipeline terminal with ordinary runtime flags/include order,
selects202's post/storage headers. Actual runtime commands bind new source3DE447 to generated C5012F2F;
its C/object bytes equal preliminary202. All four final S81 logs were read and retain the values above.
No wide corpus, new test campaign/runner, or fatal deadline campaign is required by this patch.
Clock/deadline/schedule are not implementation in202. During the202 wait, a separate203 source/recipe draft
was prepared without changing any202 input or the repo recipe. All three modules pass direct L2→L1→C syntax;
clock uses an ordinary pure L2 difference helper with explicit uint64_t inputs. The attempted unknown C-scalar
local declarations remain unsupported; no compiler/type-dictionary/language change fixes or hides that limit.
No203 completed runtime/bootstrap or new port count is claimed here.
The other16 kernel modules, driver, translators/tooling closure, arbitrary runtime-callable/Q49,
all mail contracts and true L3+L2 self-build remain OPEN.
Record copies use LF and trim trailing whitespace; the manifest pins original raw stage bytes.
The source delta is kept as a raw patch, not normalized proof text. Frozen202 inputs will not be edited after publication.
