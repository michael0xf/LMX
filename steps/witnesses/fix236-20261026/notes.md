# Frontend views and libc declarations

Verified236, 2026-10-26. Base main:
d5f55c48d14ce1f0bd26da606591308ccc79c221.

The corrected whole short bootstrap finishes with exit0, nine smoke rows
and zero failures. G1 builds G2; both start, hash a file and replace the
working tool. This is the current mixed bootstrap, not source-closed S8.6.

## Source changes

Three ordinary L2 modules replace265 frontend functions:101 views,
113 context helpers and51 type helpers. Their source SHA prefixes are
9E57E19D,00C459FD andE7ECAA5A. The remaining frontend has1637 definitions
and the same732 root storage declarations. Address aliases refer to the
existing C cells; they do not introduce copied state. Old argument/result
types and operation order are preserved.

RecipeBE47E03C generates those modules before their consumers and cleans
65 generated targets. The existing preflight refusals led to exact C
argument casts, one declaration-scope fence, unary operand grouping and
the old size_t pointer offset. They did not change grammar, checking,
admission or runtime guards. The frozen preflight receipt separates
earlier refused sources from the corrected inputs.

L3 writer51 prints28 bodyless libc declarations and three includes as
ordinary L1 output text. Its4520-byte output has SHA83263D08. It is generated
at20:20:10.5005398 UTC, before the consumers in this cold chain. The
maintained libc_abi.lm1 input is removed; p0.list is empty. The ordinary
selection is53 runtime/compiler/support inputs, eight tools and17 tests:
78 maintained inputs in total.

The explicit l1src/libc_abi.lm1 import is resolved from the stage's src
directory. It is inline L1, not a C include selected through GCC -I.
The recipe produces it or fails; it does not select the removed maintained
copy. No new L2 mechanism or second parse was introduced.

## Actual chain

Warm seed77823 finishes0 and supplies toolCFB12131. It uses explicitly
supplied historical/generated declarations and is not the cold proof.
Cold copy20505 finishes0/78files/0failed. The source manifest98BA1F54
passes language and GNU verification.

Whole67744 runs from a fresh guarded directory,20:19:24.7890916 through
21:24:22.0459956 UTC,3897.256904 seconds. Prelaunch free virtual memory
is3411112 KiB, above the838861 KiB guard.

| Artifact | Actual SHA prefix |
| --- | --- |
| Frontend source / C / executable | 00C9AD77 / B25227C9 / CE7501E0 |
| Production / observed runtime | 120A0981 / DC776EE3 |
| G1 / G2 and working executable | 7C7F4CC3 / 3EB0AFE2 |
| Both tool L1 / C / object | 1145B17C / 05171BAA / CC50F887 |

G1 L1/C are pinned at20:49:56.4525170 UTC after translation and before
either tool executable exists. G2 independently passes the two GNU
expected hashes at21:14:55.6146934 UTC during C compilation, before its
link. Object equality is checked after completion. Executable raw hashes
differ; the working executable has the actual G2 hash.
EXE-SAME returns1/exit0; working/G2 raw cmp is0.

Actual G2 language verification and GNU checks pass source78, expected2,
canonical8 and runtime53. The nine prepared source patches replay from
published235 with --fuzz=0 and reproduce canonical8, with the old ABI
absent. The public Git source delta carries these changes; this packet
does not duplicate the large source patches.

Serial dependency-only commands select19 frontend and40 runtime headers,
all in this cold stage's generated header directory. The saved dependency
receipt hashes those files; component records do not individually record
every implicit header hash. No second C object build was performed.

## Preserved values and remaining work

The four existing native/forced root0/1 owner logs retain:

```text
A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
counts A1=42 A2=42 B1=43
after A1 count100: A1=101 A2=43
r=142 p.y=42 p.x=1 p.pad=9 q.w=10
refusals C=30 Thin=33 Far=34 y=2
seven unused=3 called-plus1=8
```

The S8.1 receipt binds31 actual source/compiler/runtime/program/object/log
pins. Those programs link production120A, not observedDC776. Their declared
Point/Leaf layouts are not a candidate assembled from previously unknown
graph fields. There is no fresh A1 read after the last A2 call, new opcode
body-walk trace or general admission closure claim.

Common used-interface narrowing/UNKNOWN, clean native/Q49, remaining
frontend/backend/libc/tooling closure, full-bundle S8.6 and mailT01–T26
remain OPEN. The old backend executable's linkage to its claimed source
and the external libc support object are not closed by this slice.
The next frontend/support/backend preparations are private, not236 execution.

A first postterminal read tried a nonexistent boot-quick-01/record.txt.
The actual component records and bootstrap summary are preserved instead.
The first documentation check still saw the deleted ABI in Git's index;
the deletion was staged and the check repeated without changing the checker.
Packet text uses LF; raw pins refer to the unchanged consumed artifacts.
