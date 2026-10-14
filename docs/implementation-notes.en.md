# LMX implementation and migration notes

This file **does not define language semantics**. Current rules are in
[L3](LMX_semantics.en.md), the [grammar](LMX_grammar.en.md),
[L2](L2_spec_en.md), and [L1](L1_spec_en.md). The active queue, exact
failures, commands, and dated results belong to the [v3 plan](../next_core_tasks_v3.md),
[defects](../steps/defects.md), and tickets. The earlier route remains in the
[archived v2 plan](https://github.com/michael0xf/LMX/blob/0e0a2978eb237e145e54715de805a88e65264ba4/next_core_tasks_v2.md).
An old passing run does not prove a newer rule.

<a id="source-migration"></a>
## 1. Sources and migration boundary

The maintained source language for the kernel, parser, translators, and
ordinary build is L3 with L2 insertions. L1 is only a generated
L3/L2→L1→C stage; platform bootstrap is one-time. While the closure still
contains maintained handwritten L1 sources or external build/test scripts
organize the regular cycle, §8 is incomplete. Each ported body and header
needs a dependency manifest, test, and removal of the old authoritative body.

<a id="l1-status"></a>
## 2. Translator-L1

The old L1 seed/pin and historical translator self-build are transition
tools, **not** L3/L2 self-build. M4 requires the same flat-declaration
order — name, requirement, initial value — in generated L1: first a
temporary translator accepting both orders, then migration of all emission
paths, sources, and tests, finally removal of the old order and fresh
seed/pin verification. A type expression `@: T` is not a declaration
`@: name T`. Investigate the former bare-statement nullary-call branch
separately; it does not become L3 semantics. The
[migration ticket](../steps/tickets/unique-name-reference-migration-20261014.md)
holds locations and measured starting evidence.

Do not claim old `C:`, `c.struct`, `c.union`, or `synchronized` is
implemented on the strength of historical examples without checking the
handler. Old `throw` payload machine limits are not L2/L3 limits.

<a id="l2-status"></a>
## 3. Translator-L2 and kernel

The physical record is `Lmx {VoidArray array, Lmx *parent, LmxEntry native}`.
`array` contains `void *` child slots; a graph-slot address has type
`void **`. Instance slot count is chosen at creation; published backing
neither grows nor moves. Growing `Thread.children` is a **separate**
List/DynamicArray, not an extension of Lmx or a program field. Launch
service data belongs to the R0 stub. See [L2](L2_spec_en.md#lmx) and
[Thread](L2_spec_en.md#thread).

`LmxThread` embeds `LmxMsg message` by value as its first field; a
plain `LmxMsg` does not expose the Thread tail. The sole child List,
arena ownership, and close follow the common Thread path. Historical
fixed root slots, `LmxLink`, a second child registry, and `settings`
appended to the source graph are rejected designs. Old emergency-slice
measurements live in [migration history](../steps/voidarray-migration.md),
not in today's gate criteria.

[critical_graph_bug](../plan_critical_graph_bug_critical_pointer_to_struct_bug_fix.md)
and [critical_pointer_to_struct_bug](../steps/tickets/critical_pointer_to_struct_bug.md)
remain open. In particular, typed machine-pointer cells, `Array<@T>`,
common `void **` graph-slot access, and full inter-arena copying require
verification. A positive test of one cell does not establish every
generator route, native/walker parity, or safety after freeing the source
arena. `implements` builds address correspondence from actually required
fields; a numeric position alone is not its contract. Current failures
and checks are in the [current kernel gate](../next_core_tasks_v3.md).

The current kernel already distinguishes selected code from supplied
data during activation. The unified language form `call: code data`
and explicit method `var` part are an **approved v3 coding target**, but
remain unimplemented and do not replace current `call: A`. The
[v3 plan](../next_core_tasks_v3.md) includes precomputing a fixed slot
count and checking required `data` fields before execution. Do not guess
a change to initialization semantics.

<a id="l3-status"></a>
## 4. L3 interpreter and admission

The interpreter executes the constructed graph, not a second tree. The
admission contract first analyzes accesses explicitly needed by a
Consumer, then executes that Consumer's explicit behavioral checks.
Without a Consumer, full structural suitability is checked. A successful
address correspondence remains valid after values change; branch
assignment admits the replacement candidate **before storage**. Do not
invalidate correspondence or automatically rerun every check after each
mutation. Known static-call compatibility is established at translation;
an unknown candidate is checked at the required dynamic admission stage.
See [correspondence stability](LMX_semantics.en.md#correspondence-stability)
and the [argument stage](LMX_semantics.en.md#argument-compatibility-stage).

Native/walker parity, publication, and the full source graph remain
within [K01–K12](../next_core_tasks_v3.md); partial guarantees and old
host/root workarounds do not close them.

<a id="test-receiver-proposal"></a>
### 4.1 test: adopted rule, unfinished implementation

The `test` receiver is **adopted**, not a new proposal awaiting approval;
see the [rule](LMX_semantics.en.md#test-receiver-contract). Without an
explicit Consumer, checks come from receiving description `bVar`, not
candidate `aVar`. Analytical suitability of necessary accesses is
checked before running a test; behavioral success exists only on its
completion. A test completes admission already in progress, not a
restart of that same admission.

Code and checks are not yet complete. The exact name `test` is reserved;
ordinary user bindings with that name migrate to `mytest`. Do not rename
`test2`/`test3`, strings, or verbatim historical quotations by substring.
Implementation uses common P0, head resolution, addressing, and
native/walker selection, without a hidden test catalogue, runtime names,
`skip_tests`, or all-tests reruns after mutation. Representation of
failure of the **whole** test set remains undecided.

<a id="open-design"></a>
## 5. Open decisions

- Exact form of whole-`test`-set failure and its relation to declared
  `throw`.
- Unloading a later module whose `independent: immutable` branches are
  retained by physical address in consumers; until decided, ownership
  is explicit and there is no hidden global store.
- Implementation details of the approved `args`/`return`/`var`/`body`
  layout and `call: code data`: read-before-write, hidden inputs,
  `node`, `catch`, and native ABI compatibility. These are N1–N6 work
  items, not a reason to return the model to optional research status.

<a id="grammar-extraction"></a>
## 6. Grammar versus implementation

Grammar specifies P0 shape but does not prove translator support. The sole
anonymous container occupying an entire argument list is transparent
already in P0; completed `f()`, `f: ()`, and `f:` with explicit `---`
have one empty Frame/body shape. An unfinished bare `f:` is invalid; bare
`f` is an atom, not a call. Historical goldens are not automatically
normative. Remaining parser/consumer gaps and exact witnesses are in
[parser fix](../next_parser_fix.md) and [v3 plan](../next_core_tasks_v3.md).
Malformed Mix-mark and `{#...}` diagnostics must not be guessed from old
source text.
