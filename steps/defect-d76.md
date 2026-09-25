# D-76: a path through a `@: T` reference to a named Structure

Ticket: fable's answer, `steps/tickets-20260925.md` §6 (Opus: «D-76 — твой следующий»).  Branch
`claude/continue-opus-next-doc-rvjocj`, base main `bcad1f0`.

## Plan

1. The norm of the C type: `@: T` of a named Structure T is ONE level, `@: Lmx` -- its value is the
   Structure itself, the pointee its pointer cell holds, the value `@mo` gives (D-53) and `T: mo`'s
   slot holds.  Two sites made it `@@: Lmx` (depth + 1): `l2_resolve_type_atom` and the shared
   pointer-local table `l2_ptr_type_word`.
2. The lowering of a path through such a reference, in the path walk every reader and writer shares
   (`l2_path_root` / `l2_path_kind` / `l2_emit_path_to`):
   - a formal `@: T m`: typed T at registration (`l2_nsty_set`), as `T: m` is;
   - a local `@: T r` (a C local, `l2_ml_*`): a path root, its value the Structure;
   - a reference field `@: T q`: a segment the walk goes on through, into its pointee T.
3. Rows (success 7): a local, a formal, a reference field, each read and written through; corpus diff.
