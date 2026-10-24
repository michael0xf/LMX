# The author's two forms of `const char * var`: a check with the published frontend

Opus, 2026-10-24. Codex relayed the author's instruction (CODEX-AUTHOR-CONST-FORMS-20261024-A), quoted verbatim:
«Проверь, что существующая форма L2 действительно даёт "const char * var" как "const: var: @: char" и "const: @: var
char" без расширения языка. Пусть Opus продолжает к самосборке, не ожидая ревью; все вопросы — тебе». Codex asked for
both exact forms, each in its own function, with Verified188's published frontend, without the draft of slice 190 and
without a new syntax or a branch by form; it read the common path declaration → contract (kind 3, depth 1) → formal and
type emission in the code, and the forms had not been run.

The sources are two machine modules of one function each, whose formal named `var` is written in the form, and whose
body compares it with 0:
- `form1.lm2`: `fn: const_form1 (const: var: @: char) int`;
- `form2.lm2`: `fn: const_form2 (const: @: var char) int`.

The runs are `run-01.command`, as run, in `build2/const-forms-01` after the quick bootstrap of slice 189 had ended
(nothing ran beside them); their output is `run-01.out`.

| Step | Tool | Result |
| --- | --- | --- |
| L2 → L1, each form | Verified188's frontend `build2/opus_fix188/boot-quick-01/frontend/l2trans.exe` (`1F7AF31B…`), `--library --machine` | exit 0 twice: `form1.lm1`, `form2.lm1` |
| L1 → C, each | `bin/l1trans.exe` (`601D350E…`) | exit 0 twice: `form1.c`, `form2.c` |
| C, each | `C:/Qt/Tools/mingw1310_64/bin/gcc.exe -std=c99 -fsyntax-only -Wall -Wextra` | exit 0 twice, no diagnostic |

Both forms give one contract. The L1 formal is `const: @(char l2_p0_0)`, and the C prototype and definition are
`int const_form1(const char * l2_p0_0)` and `int const_form2(const char * l2_p0_0)`: `const` qualifies the `char`, not
the pointer (not `char * const`). The literal name `var` is the formal's name; the C parameter is spelled by its
position (`l2_p0_0`), as every machine function's formal is. The two L1 files and the two C files differ only in the
function's name. Nothing was changed in the frontend or the language for this.

Not checked: a write through the formal, the forms as locals, a caller passing `char *`.

## Evidence

`evidence.list` names 10 files: the two sources, the commands and their output, the generated L1 and C, the frontend
and l1trans. `evidence.sha256` holds their SHA-256, written by Verified188's tool (`manifest-01.command`,
`manifest-01.out`: `MANIFEST 10 files, 0 failed`). The copies here have LF line ends and no trailing blanks or blank
last lines; the manifest hashes the original bytes in `build2`.
