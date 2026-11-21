# Assignment is not declaration — historical correction

**Status:** the 2026-09-28 Fable documentation task is complete; this file
is not a second specification or a new implementation ticket. The author's
technical words and Q50–Q52 answers remain in
[the journal](https://github.com/michael0xf/LMX/blob/0a764078/LMX_blog/2026-09-27.md) and
[closed questions](https://github.com/michael0xf/LMX/blob/0a764078/LMX_blog/q/q52.md). Current rules are in
[L3 semantics](../LMX_semantics.en.md#publication),
[L2 addressing](../L2_spec_en.md#lowlevel-address), and
[plan v3](../../next_core_tasks_v3.md).

An assignment updates a resolved place; it does not by itself create a
second field, write back to the caller, or replace its own executable
operator in the source graph. Explicit and hidden arguments are
activation-local unless an explicit declaration establishes graph-backed
storage. Declared fields may use the established load/cache/dirty
publication mechanism. A bare assignment to an outer `y` inside a method
therefore does not create a method field `y`; the operator remains in the
complete graph. Address-taking selects the real typed storage, not a
temporary cache or the pointee descriptor.

This corrected the abandoned argument-to-own-field promotion. Old
`sticky`/`active` tests, same-name occurrence rules, `node\[N]field`, and
claims that `@Structure` yields a descriptor are **historical**, not
alternate current contracts. A repeated declaration now assigns the
single existing place under [M3](../../next_core_tasks_v3.md); that is
not assignment creating another declaration. The separately proposed
explicit `var` layout is still research, not an automatic amendment to
this rule.

Implementation and native/walker evidence belong to
[K03–K12](../../next_core_tasks_v3.md) and the
[pointer critical ticket](../../steps/tickets/critical_pointer_to_struct_bug.md),
not to the old applied-report logs in this file's Git history.
