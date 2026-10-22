# Prepared primary bodies

Private slice160 gives general Frame values an owned written body and
trailer before lexical or effect analysis selects the head's role. It builds
on `a37fe71a4e0353e3af0550c6d6ce11fdc258d860` in
`build2/codex_primary_children160`. The compiler and application source and
generated header change; 278 of the 281 source/header inputs stay unchanged.
The old directory being deleted externally remains untouched.

## Body ownership before head role

`L2PrimaryBody` is compilation metadata, not a runtime graph object. It owns
prepared field lists for a Frame's written body and trailer and borrows the
unchanged source node. Existing groups, signs and address Frames keep their
ordinary expression children rather than duplicate them as another body.
The shared head-grammar cache is warmed during construction and retains its
ordinary compilation lifetime. No name, opcode or variable binding table is
added to the runtime graph.

The constructor does not require every body to be a numeric expression.
Type-only operands, named wrappers, ordinary actuals and control statements
retain their source topology. A bare receiver token at the end of a list is
not treated as an invocation by the ownership constructor; its receiving
contract determines whether it has a value.

The common recursive copy operation covers the new body and trailer owners.
A completed record copy preserves nested type/map verdicts; a fresh semantic
view resets them. Copies never parse source coordinates. Partial-copy
failure releases only the partial copy and preserves the original owners.
Bound-fact replacement and path-child teardown recognize primary owners too.

## Analysis consumers

Lexical and effect visitors borrow the prepared lists. Their raw and held
entries share the same head-role decisions; the held entry has no raw-body
retry. Lexical analysis reads written occurrences, not a reconstructed
formal-ordered P0 body. A named argument visits its owned payload instead
of counting the argument label as a free value name. Address and cast roles
continue to distinguish storage from value reads and type syntax.

Effect analysis makes fresh semantic views in the current environment. It
keeps the ordinary control-body scope and trailer handling rather than
copying an earlier native verdict or introducing a special capture path.
Missing prepared children are an internal failure, not permission to
silently skip a body or parse it again.

The compact `\(@: q[0])` witness is still distinct from the separated prefix
`\ (@: q[0])`. It demonstrates body ownership before head role; its flags
alone do not admit a callable or dereference.

## Verification

The original positive compact-primary fixture remains preserved as
82 assertions with 2 failures on frozen159. The current implementation
passes those same 82 assertions without changing the positive expectations.
Its lexical and effect traversals make zero path-adapter calls after
construction, including compact-head preparation.

The expanded fixture passes 199 assertions: independent copies, completed
versus fresh verdicts, source identity, type-only and named bodies, a real
return trailer and an ordinary separate `else` Frame, and scope balance.
All 22 measured constructor and 21 recursive-copy allocation sites are
actually refused, with cleanup checked at the compilation lifetime of the
head cache. Earlier fixture-development observations remain in the
[fixture history](witnesses/used-scope-20261020/primary160-fixture-history.json):
an incorrect one-root/trailer assumption, its bounded abort, and the
corrected source-shape assertions. The compiler is unchanged between these
fixture runs.

The receipt and independent audit bind the results to exact source, header,
frontend, fixture, generated L1/C/object/executable and runtime bytes.
The selected phases comprise 129 fresh strict-O2 units and 326 actual runs.
All 17 compiler profiles pass, as do receiving61, INDEX61, child281,
owned2026, root124, native134 and CHECK159. All 85 corpus L1 outputs are
literal-identical to159 but were freshly compiled and run: 162 positive
runs and the same 8 copy-family failures. These are not counted as newly
passing tests. Actual-value recipes check deep
mapped paths, writes and addresses in native and forced execution, including
walked-body observations. Physical C-pointer methods that remain native-only
are not described as interpreted methods.

Reproduce from the frozen159 closure with the
[source patch](witnesses/used-scope-20261020/primary160-u0.patch),
[input manifest](witnesses/used-scope-20261020/primary160-inputs.json),
[build recipe](witnesses/used-scope-20261020/primary160-build.ps1) and
[verification recipe](witnesses/used-scope-20261020/primary160-verify.ps1).
[Evidence](witnesses/used-scope-20261020/primary160-evidence.json),
[actual results](witnesses/used-scope-20261020/primary160-results.json) and
[independent audit](witnesses/used-scope-20261020/primary160-audit.ps1)
record the exact observations and limits.

## Remaining application consumers

General CHECK/type/native/retained primary call-body consumers still have raw
argument routes. They must consume a common formal-ordered application plan
over these owned children, including type-only and named/default roles,
rather than prepare fields after selecting a backend. Structure-level and
body-level trailer contracts also require that same complete plan; this
Frame ownership slice does not establish their complete semantic handling.

Nonnumeric receiving, own-storage ABI/descriptor/leaf projections, pointer
type spelling and indirect/callable/text clients remain open. This is a
source-analysis foundation, not proof of a single path algorithm throughout
the compiler, the public-dev kernel, Model/Shelf/K03 closure, self-build or
mail completion. The full §§8/8a goal stays active.
