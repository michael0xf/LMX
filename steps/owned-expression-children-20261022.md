# Embedded expressions own their prepared children

Groups, signed Frames and address Frames now retain an ordinary child operand
list in L2ValueSpan. Their direct type, CHECK, native and retained-expression
consumers borrow that list. This removes their reconstruction of child source
fields; it does not close every receiving/conversion/call-actual consumer.

Base main is2bc76b08203da2a16a59949ac172c2f3259dc105.
The [two-source patch](witnesses/used-scope-20261020/child156-u0.patch)
applies over Private155. Source replay and regeneration of the application
C header are byte-exact. The
[281-file manifest](witnesses/used-scope-20261020/child156-inputs.json)
changes the compiler, application source header and its generated C header;
278 dependencies remain unchanged. The live snapshot is
build2/codex_child_records156, still private bootstrap rather than public-dev.

## One child lifetime

l2_value_span_prepare uses the existing l2_value_fields constructor for a
group's fields or a selected unary Frame's body. The root operand list owns
these child lists recursively; borrowed span views do not release them.
Partial construction and the final recursive release have the same owner.
No runtime Lmx field, graph opcode or global binding cache is added.

l2_value_children_type folds the held child list through the common value
type rule. CHECK uses l2_check_prepared_values for both ordinary and embedded
lists. Native emission uses l2_emit_native_values with the same children,
preserving grouping, signed promotion, lazy arms and live integer operators.

Address Frames project the child through l2_address_span rather than sending
their body back to the raw target parser. A grouped single place delegates to
that same projector. Retained groups/signs use l2_rw_children and
l2_rw_prepared_texpr; COUNT and EMIT consume the same owned children and
retain the original expression-site coordinates.

The older callable-result receiving check and numeric-conversion call builder
still take raw fields. They are explicitly marked migration debt, not claimed
as closed because a prepared helper now surrounds them. Likewise, INDEX
expression spans inside L2PathStep do not yet own their child lists. Their
future ownership must cover every path copy, view, fact and release together.

## Source-linked evidence

The [child fixture](witnesses/used-scope-20261020/child156-test.c) passes279
assertions on156 and36 shared assertions on155. It covers groups, signed and
address Frames at ranks0,1,2,6,65,129 with qualification.
The first child semantic use has one root selection and,for indexed paths,
one semantic fold. It invokes no additional containing-path adapter after
construction;155's first child type use still adapted its raw body.

Subsequent CHECK, native, retained typing, COUNT and EMIT have zero new root
selections or path folds. Native/type projections also survive poisoning
the child's source name and formal FT row. Geometry and exact types remain
attached to the same held path; COUNT and EMIT agree.

Nested group depths1,4,16,65 are actually processed through type, CHECK,
native, COUNT and EMIT, not just accepted by the parser. All5 measured
allocation sites of the selected nested constructor are individually forced
to fail; every partial child/list/path owner releases exactly once.
These are the measured constructor's five sites, not a claim that every
possible later backend allocation site has been exhaustively enumerated.

Independent INDEX operands still receive their own preparation; the zero
containing-path adapter measurement is not a claim of zero index-expression
adapter calls. Pointer-type spelling and remaining storage projections are
also not hidden inside that measurement.

All17 compatibility profiles retain their oracles and pass:owned398,
metadata336,common INDEX420,dispatch COUNT/EMIT200 and receiving114.
Additional root124,native126 and CHECK153 fixtures pass against the current
frontend. Their original fixture labels remain for comparison; source/C
hashes identify the actual156 execution.

## Actual generated units and values

Final compiler source SHA256 is
4D8970A775F7A9281F43DC108B6CBDD20E850BDE24F59A83622D472FBBDD3850.
Generated application C header SHA256 is
C579557824364B6AF5F7147474521727C8349CDAFC7ECA2850CC5696359D5EDE.
The [receipt](witnesses/used-scope-20261020/child156-evidence.json) and
[terminal records](witnesses/used-scope-20261020/child156-results.json)
pin inputs, tools, generated units and actual observations.

All85 current L1 outputs are literally identical to155. Because the
application header changed, all85 were freshly strict-O2-built and actually
run170 times:162 passes and the same8 copy-related RED observations, with
unchanged native eligibility. Twelve located negative oracles pass24
translator observations;seven further source pairs keep their classifications.

Sixteen fresh auxiliary units add44 runs:32 positive native/forced observations
of deep mixed/permuted/hidden paths and values after writing through taken
addresses, plus12 expected write-drop failures. Actual walked-body counts
are checked. Two genuine Array contract mismatches still refuse;pointer-offset
and opaque-C cases remain native-only.

Constant/string controls add8 old/new units and32 runs(result11,shadow7).
Method-address rebinding adds4 old/new units and16 runs, including the actual
two forced method bodies. The selected final phases total113 fresh strict-O2
units and262 runtime executions, including6 old152 comparison units/24 runs.
They are not262 distinct156 programs or a full GREEN kernel.

The receipt lists14 bounded recipes and hashes. Reproduction needs the
published152 archive and153/154/155/156 patches/manifests, pinned runtime
objects/module inputs and prior compatibility fixtures. A source-header
comment clarified the still-open receiving/conversion debt after the first
build; regeneration proves its C header identical to the one actually
compiled. Header replay uses its own source unit root and real P0 import.
No deleted historical build tree is restored.

## Open work

INDEX child ownership and all copy/view/fact lifetimes, receiving/conversion/
call-actual helpers, own-storage ABI/descriptor/leaf projections, pointer-type
spelling, raw indirect heads and callable/text clients remain open.
Public-dev,the clean kernel,Model/Shelf/K03,L3+L2 self-build and mail are not
closed. A child owner is progress toward the shared result, not proof that
every consumer already uses it.

All work remains in build2; the author's deletion of old build is untouched.
Protected log/117 files are neither read nor staged. One GCC pipeline runs
at a time; goal stays active with its original complete objective.
