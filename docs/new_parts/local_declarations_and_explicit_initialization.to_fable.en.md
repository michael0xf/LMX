# Local declarations and explicit initialization — historical handoff

**Status:** the Fable documentation handoff and Q51/Q52 discussion were
completed in 2026-09. Its old edits, code census, and then-open questions
are in Git history and [the author's answers](https://github.com/michael0xf/LMX/blob/0a764078/LMX_blog/q/q51.md).
This note is not a command to revive the withdrawn execution-pair model
or to overwrite the [current semantics](../LMX_semantics.en.md).

The program remains one complete source Structure: declarations, values,
and executable assignment operators stay in source order. A declaration
establishes its value storage. Assignment changes the resolved value but
does not replace the operator or create another field. An explicit path
such as `M\i` addresses storage at a declaration, not an instruction
node or an activation cache. A hidden input assigned inside `M` does not
thereby become `M\i` or write back to the caller. See
[assignment is not declaration](assignment_is_not_declaration.en.md) and
[L3 publication](../LMX_semantics.en.md#publication).

For computed initialization, the current explicit-call example is:

```text
int: i
i: findValue()
```

The second line runs when control reaches it; inspecting the graph does
not run it. The old example `i: findValue` reflected the former bare-name
call rule and is **superseded** by [M1](../../next_core_tasks_v3.md).
Simple known-value declarations such as `int: i 5` retain their
construction-time initialization rule. Do not invent a hidden constructor,
a second persistent data graph, or a special first-read initialization.

The old categorical ban on a `var` section was a response to an
unrequested hidden auxiliary graph. The author's new *explicit* `var`
proposal is [under study](../../next_core_tasks_v3.md); it does not
yet change the current representation or initializer timing.
Native/walker and path checks remain tracked in
[the current kernel plan](../../next_core_tasks_v3.md).
