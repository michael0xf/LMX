# Merge documentation follow-up — historical decision index

**Status:** the 2026-09-28 Fable follow-up is complete, not a fresh
request to change the runtime or reopen its questions. The detailed
N01–N04 questionnaire, reviewed snapshots, acceptance table, and edit
report remain in Git history. Apply the latest
[semantics](../LMX_semantics.en.md), [plan v3](../../next_core_tasks_v3.md),
and [earlier correction](merge_documentation_corrections.en.md).

| Finding in the old task | Outcome and current boundary |
| --- | --- |
| N01 — callable descriptions | [Author answer Q48](https://github.com/michael0xf/LMX/blob/0a764078/LMX_blog/q/response48.md) belongs to the former whole-callable example. Under the current [composition contract](../LMX_semantics.en.md#composition), composing code and composing the input description are distinct operations. Input declarations/defaults belong to the callable's single `data`; `args` in [call/fncall](../LMX_semantics.en.md#call-receivers) is the actual supplied-value Structure. Former separate-formal-part examples no longer define the language. |
| N02 — working-state publication | [Current M14 call frames](../LMX_semantics.en.md#call-frame-20261115) have independent locals without write-back. Load-dirty, a shared direct-access value cache and flush() are cancelled. Earlier publication decisions are historical. |
| N03 — same-name occurrence choice | Repeated physical fields remain distinct and use `S\[N]field`; in code a repeated declaration updates the already visible local under the common rules. See [current names and paths](../LMX_semantics.en.md#fields) and [M14](../../next_core_tasks_v3.md#native-structures). |
| N04 — overloaded prose | The bilingual composition section was split editorially. Subsequent rules govern any later rewrite; old paragraph count is not an acceptance condition. |

Other still-useful conclusions: `merge` copies the used mutable graph,
does not bind a method's arguments or reorder dynamic-before-lexical input
priority, and does not share an ordinary callable occurrence merely
because its native implementation can be reused. The original task
required `const` alongside `independent: immutable` for retained branches;
that exclusivity is historical after the later author decision. See the
[current merge note](merge_documentation_corrections.en.md).

If a new contradiction really survives these later decisions, record
both current rules and a minimal distinguishing program and ask the author
before implementing a special case. The old N01–N03 questions themselves
are closed and must not be sent again.
