# Local declarations and explicit initialization

> **Historical notes · 27 November 2026.** The numeric `uninit` code in the local-leaf examples is historical. The TypeRef remains in the record with zero value payload. Local initialization and writes into a selected graph place retain their distinct contracts. [Current references](README.md#standalone-status)

**Status:** applied documentation requirement, reconciled through 2026-11-21.
The current [construction](../spec/LMX_semantics.en.md#construction),
[declaration arguments](LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md),
and [binding rules](LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md) govern this note.

The program remains one complete source graph. Receivers, declarations, executable assignments, written groups,
and field order are preserved as written. Computations and transformations occur exclusively in the namespace.
Terminal primitive declarations alone have the direct `{type value}` representation. A declaration establishes
a place under its role; assignment changes an existing resolved place without implicitly replacing its own
source operator or creating another field. The primitive leaf is part of the complete literal source graph,
at the address held by its Structure cell. Ordinary explicit graph assignment can replace any addressed
receiver structure; executable edits use the existing compile/endturn restart boundary when required.

In executed CODE, explicit initialization can be written:

~~~lmx
int: i
i := findValue()
~~~

The assignment executes when reached. If no permitted ordinary input source supplies it, the first declaration
establishes an uninitialized int place; it does not silently substitute zero. The single declaration int: i `findValue()` instead declares/updates the place and obtains
its initializer under the ordinary declaration contract. A bare findValue reference does not call it, and
i: `findValue()` is an ordinary structural form, not assignment.

An uninitialized graph leaf is the code `uninit:int` alone, with zero value bytes. It contains no hidden
preallocated int cell or nested record. Initializing the execution-local i leaves that source leaf unchanged;
an explicit graph assignment to `M\i` replaces its selected fragment with the supplied `{int value}`.
No stable raw payload address across that replacement is promised. [Author clarification](LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

A direct source path such as `M\i` addresses the corresponding graph record; it does not evaluate a stored call or
read a hidden activation cache. A computed namespace input obtains its value on demand through the common
mechanism. There is no eager entry pass over all initializers. Ready primitive declarations such as int: i 5 use
their direct typed representation.

Supplying a place-declaration receiver as a CODE argument is a distinct operation: it is read as DATA and retains
the initializer unexecuted. If its name matches receiving DATA, the declaration description is substituted in that
call namespace; otherwise the entire Structure occupies the current argument position. Later execution of the
accepted form establishes or updates its root place in the receiving namespace and leaves the form available
for execution again. This creates no source-code field or new physical parent. The separate `import`, `copy`, and `merge` contracts always consume CODE arguments, wherever written. Bare reference/anonymous-Structure sources remain values, while an explicit source call executes on consumption; no DATA-argument variant is needed.

Same-level CODE redeclaration uses the existing place and does not clear it when no new RHS is supplied.
A nested declaration shadows an outer one with a distinct place. DATA duplicates are physical occurrences,
addressed by `S\[N]field`. In [binding §7.4](LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md)'s exact
inline case, the new no-RHS local is `uninit:int`: the inline scope is not a new callable caller, and the stated
actual caller has no x to supply. The outer x = 5 stays unchanged; a reached required check refuses the absence.
This follows from the existing caller-source rule without an additional initialization mechanism.

Writing a bound name does not promote it into a method field. Own actual/autofill/fallback places have no
write-back; a transparent caller binding writes the caller's real place immediately. Explicit graph paths follow
ordinary restrictions. No hidden constructor, persistent auxiliary graph, automatic local publication, or new var
layout is introduced here. See [assignment is not declaration](assignment_is_not_declaration.en.md).
