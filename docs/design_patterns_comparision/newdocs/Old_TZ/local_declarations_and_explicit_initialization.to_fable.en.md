# Local declarations and explicit initialization

**Status:** applied documentation requirement, reconciled through 2026-11-21.
The current [construction](../LMX_semantics.en.md#construction),
[declaration arguments](../TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md),
and [binding rules](../TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md) govern this note.

The program remains one complete source graph. Receivers, declarations, executable assignments, written groups,
and field order are preserved as written. Computations and transformations occur exclusively in the namespace.
Terminal primitive declarations alone have the direct `{type value}` representation. A declaration establishes
a place under its role; assignment changes an existing resolved place without replacing its source operator
or creating another field.

In executed CODE, explicit initialization can be written:

~~~lmx
int: i
i := findValue()
~~~

The assignment executes when reached. The first declaration establishes an uninitialized int place; it does not
silently substitute zero. The single declaration int: i `findValue()` instead declares/updates the place and obtains
its initializer under the ordinary declaration contract. A bare findValue reference does not call it, and
i: `findValue()` is an ordinary structural form, not assignment.

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
addressed by `S\[N]field`. The one unresolved initialization control case for a new uninitialized inline local is
explicitly isolated in [binding §7.4](../TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md);
it does not affect explicit initialization examples.

Writing a bound name does not promote it into a method field. Own actual/autofill/fallback places have no
write-back; a transparent caller binding writes the caller's real place immediately. Explicit graph paths follow
ordinary restrictions. No hidden constructor, persistent auxiliary graph, automatic local publication, or new var
layout is introduced here. See [assignment is not declaration](assignment_is_not_declaration.en.md).
