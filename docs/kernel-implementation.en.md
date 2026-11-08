# LMX kernel implementation specification: the Lmx graph, primitives, the arena, names

Paired version -- [RU](kernel-implementation.ru.md). The normative sources of the language are the [L3 semantics](LMX_semantics.en.md),
the [grammar](LMX_grammar.en.md), [L2](L2_spec_en.md) and [L1](L1_spec_en.md); this document is the specification of the
**implementation** of the kernel and of the code it emits, by the author's directive of 2026-11-08 (the author's words
verbatim -- the [journal](../LMX_blog/2026-11-08.md), the sections "Остановка инкрементальных кодов идентификаторов…",
"Атом — единственная не-структура…", "namespace — служебные таблицы обхода…", "Чистый граф…", "Единый механизм
неинициализированных примитивов…", "Все проверки — по адресам в арене…", "Замена указателя — при первом присваивании",
"Служебные операторы и ресиверы — без отдельных кодов…", "Термин: примитив, не атом…", "«int без инициализации» —
указатель на ту самую ячейку…"; the relays CODEX-FABLE-AUTHOR-KERNEL-REBUILD-20261108T171209823Z-01,
CODEX-FABLE-AUTHOR-ATOM-ADDRESS-20261108T172249908Z-01, CODEX-FABLE-AUTHOR-NAMESPACE-TRAVERSAL-20261108T172512156Z-01,
CODEX-FABLE-AUTHOR-CLEAN-GRAPH-FRESH-TRAVERSAL-20261108T172943665Z-01,
CODEX-FABLE-AUTHOR-UNIFIED-UNINITIALIZED-TYPES-20261108T180019959Z-01,
CODEX-FABLE-AUTHOR-ARENA-ADDRESS-VERIFICATION-20261108T180226654Z-01,
CODEX-FABLE-AUTHOR-FIRST-ASSIGNMENT-ONLY-20261108T181027312Z-01,
CODEX-FABLE-AUTHOR-OPERATORS-STRING-ADDRESSES-20261108T181832549Z-01,
CODEX-FABLE-AUTHOR-PRIMITIVE-TERMINOLOGY-20261108T182057865Z-01,
CODEX-FABLE-AUTHOR-UNINIT-POINTER-SAME-CELL-20261108T190254726Z-01; Codex's reviews
CODEX-FABLE-KERNEL-SPEC-REVIEW-20261108T175116933Z-01 and CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01 are applied).
Status: **the working specification of the transition; Codex has not declared the document accepted as a whole** -- the
direction and the order of §11 item 0 were allowed by the second review, the implementation has started from the
independent base; there are no open questions to the author. Marks: "norm" -- the author's words or the current book;
"decision" -- the implementer's choice within the norm, checked by Codex.

Codex's graph10/tool11/rt07 implementation executes the Point/take example of §10 and used-field checks through both
consumers; [evidence and limits](../steps/witnesses/clean-call-20261108/notes.md). This is a partial migration:
int results, a body with one return, empty var, positional arguments and int defaults are supported.
The next [graph11/tool11/rt08](../steps/witnesses/clean-expr-20261108/notes.md) normalizes supported expressions:
a binary operation is Lmx [left, operator word, right], a prefix operation [operator word, operand]; construction sets
the nesting and respects P0 separators. Both consumers read this form without precedence parsing. The remaining
operators, body, admission, primitive and root forms are not implemented yet. The specification below
states the target, rather than claiming that the entire existing runtime conforms to it.

<a id="principles"></a>
## 1. Principles (norm)

1. **Lmx structures suffice to describe everything**, expressions, methods and arrays included. The program, its data and
   its current state are one Lmx graph; there is no second AST, no data graph, no "prepared" result of the translator and
   no hidden copy of the source ([L2 §2.1](L2_spec_en.md#interpretable-tree)). "Everything here is simply a structure"
   (the author, 18:18Z): code and data are the same Lmx; the role is decided by the place and the head, not by the kind of
   memory.
2. **Every verification goes by addresses in the arena; addresses do not change** (the author, 18:02Z: "все верификации
   производим по адресам в арене, и имя тоже сравниваем по адрресу его в арене. Адреса не меняются"). Every check -- of
   a type, a kind, a name, a correspondence, an admission -- rests on the address of a primitive, an Lmx or a string in
   the typed arena: the address tells the object (§2.1, §5.1). A name is compared by the address of the single reused
   string of its spelling (§4) -- not by bytes, not by a hash, not by an incremental code. The addresses of existing cells
   and strings never move; growth and attaching of regions keep them (§2.3).
3. **The only non-Structure is the primitive** (the author, 17:22Z; the term -- 18:20Z: "Это надо называть не атом а
   примитив. Атом это понятие парсера"). `int: i 5` is put as a primitive: a typed arena cell holding 5. Its address
   tells everything: the **type** -- from the registered typed region of the arena in which the address lies; the **name**
   -- from the address → name table; the **value** -- by reading the cell itself. No wrappers, leaves, "occurrences" or
   other entities between the field of the containing Lmx and the primitive; the field of an Lmx is a `void *` cell
   referring to the primitive's cell itself or to an Lmx (§3.1).
4. **One mechanism of uninitialized primitives in all structures and in the signature** (the author, 18:00Z and 18:10Z).
   For every primitive type T there is a distinct type "T without initialization", told apart by the same mechanism --
   by the region in which the address lies. The author, 19:02Z: "Сделайте тип "int без инициализации" указателем на ту
   самую ячейку (массив в арене, указателей на такие ячейки), при этом даже отпадает необходимость менять тип при первом
   присваивании" -- `uninit:T` is a **pointer primitive** from a typed region of pointers, pointing at a **pre-existing**
   cell of T with an unchanging address and type, not yet written. `int: i` is a `void *` field pointing at such an
   `uninit:int` pointer, which points at the `int` cell of the place `i`; `int: i 0` is a field pointing at an `int` cell
   holding 0 directly; one representation in code, data and signatures, with no mark, flag, bitmap or walker table. **The
   first assignment** writes the value into **the same** cell of T and turns the field onto it directly; no other cell is
   allocated, the cell's type and address do not change, there is no reclassification; later writes go into that cell by
   the ordinary contract (the author, 18:10Z: "При первом присваивании!"). The earlier answer "in code it is an atom with
   some random value" is replaced by this decision.
5. **No parallel hidden structures of the program** at the interpreter or the translator. The service traversal tables
   ("namespace" in the author's words) are the implementer's to design, but **they are kept nowhere outside a
   traversal**: every traversal starts with empty tables, uses them and destroys them on any exit; they do not lie in the
   graph, beside it, in the arena as mandatory preparation, in a module, a cache or hidden state; a repeated traversal
   after a change of the graph takes everything from its current content (§5.2). The address → name table (§5.1), the
   index of typed regions (§2.1) and the string table with its index (§4) are arena and process state, not traversal
   tables; they are not mixed with the temporary traversal tables.
6. **Identifiers are reused strings with stable addresses.** A spelling is interned at input (parsing text, loading a
   unit, `fromLmx`, attaching a foreign region); from then on a name is a pointer to the single string of that spelling,
   and identifiers are compared by pointer. No string comparison in an executor and no separate numeric code as identity.
   Each process has one canonical pointer per spelling; the pointers of the translator's process are not the addresses of
   another process, so a loaded unit normalizes its strings into the loading process's pointers at load (§4, §7).
   **Service operators and receivers are no exception** (the author, 18:18Z: "никакие служебные операторы и ресиверы при
   такой схеме никаких отдельных кодов не имеют!! Те же адреса строк : "for", "=", "**" и что угодно. У нас все -- просто
   структура"): `for`, `=`, `**`, `fn`, `merge` are the same strings of the `text` region, recognized by address; there
   are no separate codes of operators, receivers or language words -- neither as numbers nor as kinds of memory regions
   (§2.2); there is no hidden program of codes (§3.3, §6.2).
7. **The arena attaches new memory regions and types them.** Addressable cells never move; the graph needs no dynamic
   arrays in the arena: sizes are known at construction, growth attaches a new region instead of moving the old one.
8. **One contract for all:** source → construction of a clean Lmx graph → that same graph is consumed by **both** the
   translator **and** the interpreter (§1a). The built graph holds nothing but Lmx and primitives: no prepared interfaces,
   no plans, no traversal data, no stored results of name resolution (§3.5), none disguised as Lmx. The P0 parse tree is
   the builder's internal matter, not a mandatory input of the translator; saved translator tables are not an input of
   the interpreter.
9. **Native and the interpreter execute one and the same graph** with one semantics of reading, writing, `dirty` and
   publication ([L2 §10–11](L2_spec_en.md#own)); emitted `native` needs no names at a call; the interpreter recognizes a
   head by the address of its word and finds places by name through the tables of its own traversal (§5.2, §6.2).
10. **What is unclear is asked, not guessed.** Questions go to Codex as a minimal case; what Codex forwards to the author
    is not implemented before the answer, the rest continues. The author's model is not reopened.

<a id="contract"></a>
## 1a. The one contract: the builder and the two consumers (norm)

```text
source text ──► builder (parsing + construction) ──► a clean Lmx graph in the arena
                                                        │ primitives, Lmx, the address → name table, typed regions
                                            ┌───────────┴───────────┐
                                      interpreter                translator (emits native)
                                      walks the graph            walks the same graph
```

**The builder** is the only place where text becomes a graph: parsing (P0 today) and construction of cells in the regions
of the receiving arena, interning of spellings (§4), filling of the address → name table (§5.1). Its boundary is the
finished graph; the parse tree, its arenas and any working data of the builder are destroyed on leaving the construction
(like traversal data, §5.2). The builder resolves no names: a written name stays in the graph as a word primitive (§3.5).
**The consumers** -- the interpreter (§6) and the translator (§7) -- read one and the same graph and prepare nothing in it
for each other. The translator emits native bodies and the unit's loading code. The loading code is a **generated
initialization of the same clean graph**: the exact cells in typed regions, their links, the rows of the address → name
table, the `native` references -- through the common low-level graph constructor used by parsing, by `fromLmx` and by
the loader alike (a decision confirmed by Codex on 2026-11-08: this is not the former generated operations, place tables
and hidden interfaces; the unit keeps no source text as a reserve for execution or recovery; embedding the P0 parser into
loading is not required). Native bodies are bound to callables by the addresses of the built graph. Construction from
`fromLmx`, `merge`, a child reservation and mail is the same constructor with the same boundary.

<a id="arena"></a>
## 2. The arena

### 2.1 Regions (decision)

The arena of a Message is a list of **regions** (`LmxSegment`). A region is one contiguous block of cells of one C type
and one stride: `{ base, stride, type, count, used, next, owner }`. The region's type comes from a closed inventory
(§2.2). A region is never reallocated; when its cells run out, the arena attaches the next region of the same type.
Address → type is a lookup of the region by the half-open interval `[base, base + stride·count)`; the interval index is
ordered by address and lives outside the graph as arena state (not a traversal table: it is the means of learning a type
from an address, §1 item 2). Today's `LmxPool`/`LmxChunk`/`LmxRange` are the same idea (a pool of chunks of one stride,
intervals), but with profiles, roles and side arrays (`links`, `slot_owner`, `holder`, `side_cells`) that §9 removes.

### 2.2 Region types (decision; a finite inventory)

| Type | Cell | Content |
|---|---|---|
| `int`, `char`, `unsigned char`, `size_t`, `unsigned`, `ulong` | a number of the machine type | a number primitive; `int: i 5` is an `int` cell holding 5 |
| `uninit:int`, `uninit:char`, `uninit:unsigned char`, `uninit:size_t`, `uninit:unsigned`, `uninit:ulong` | `void *` -- a pointer to a cell of T | the pointer primitive "T without initialization" (§1 item 4): points at the pre-existing, not yet written cell of T of a place `int: i` without a value or of a mandatory formal `int: q`; the region kind of this pointer is the only carrier of the state "without initialization", the cell of T itself lies in the region of T and never changes its type |
| `uninit:ref` | `void *` -- a pointer to a `ref` cell | a reference place without a promised initial address -- `@: p`, `ptr: @()` ([book :487](LMX_semantics.en.md#explicit-copy)); the author's analogy "for all primitives" extends directly to the pointer receiver, which has "the same place and value forms as `int`" (confirmed by Codex, review 2) |
| `word` | `const char *` | a word primitive: a pointer to the interned string of a spelling -- operators (`+`, `\`, `[]`, `:=`), receiver and language words (`fn`, `if`, `return`, `node`, `int`), any written name (§3.5) |
| `ref` | `void *` | a reference cell: a slot of an Lmx field or of an Array element, the cell of a pointer `@: p T` after the first address write; holds the address of a primitive or an Lmx, or 0 |
| `lmx:data`, `lmx:immutable`, `lmx:result` | `Lmx` | the header of an ordinary Structure, of an immutable Structure (`independent: immutable`) and of a Structure **created by executing the `fn` receiver** ([L2 §2.1](L2_spec_en.md#interpretable-tree): the pool of `fn` results receives only a structure created by executing `fn`, not a Structure with similar parts; [§3](L2_spec_en.md#type-by-range): ordinary and immutable in different regions, not a C type per model) |
| `lmx:array<T>`, T ∈ {`int`, `char`, `unsigned char`, `size_t`, `unsigned`, `ulong`, `ref`} | `Lmx` | the header of a graph Array with the requirement T on its elements ([L2 §3](L2_spec_en.md#type-by-range): for an Array the range also tells the element type); the backing is `count` `ref` slots (§3.1) |
| `text` | `char` | string bytes: interned spellings of names and operators (§4), user string literals |
| `name` | `{ void *address; const char *name }` | a row of the address → name table (§5.1) |

The header kinds are the finite inventory of the physical kinds of [L2 §3](L2_spec_en.md#type-by-range): ordinary,
immutable, an `fn` result, an Array with its element type; the kind is read from the region in which the Lmx's own address
lies, with one common Lmx record (§3.1); neither the header nor a cell carries a tag. **A region kind is not an opcode:**
an `fn`/`fm`/`sub` definition, a statement, an expression and a data Structure are the same Lmx of the ordinary kind;
their role is read from the address of the head word (§3.3, §6.1), not from the header's region. The service types
(`name`, the interval index) are visible to the arena and the executors but are not values of the language. User models
produce no region types: a Structure of any model is an `lmx` cell plus its slots.

### 2.3 Allocation at input and construction (norm + decision)

Before translation the unit's graph is known in full, so an emitted unit declares the **exact** sizes of its regions by
type (the number of `int`, `uninit:int`, `ref`, `lmx:*`, `word`, … cells, the length of `text`) and builds the graph in
them without intermediate dynamic arrays (the cell of T of a place without a value is allocated at construction together
with the `uninit:T` pointer onto it, §3.2). Growth at run time -- `merge`, a receiver's result, `fromLmx`, a child
reservation, attaching mail, executing a declaration with an initializer (§3.4) -- takes cells from the current region of
the needed type and attaches a new one when it is full; the size of a new region is the arena's policy (decision; not
less than requested), the addresses of earlier cells do not change. `lmx_arena_attach` moves the donor's regions into the
receiver's list without relocation ([L2 §6](L2_spec_en.md#arena)); `mark`/`revert` roll back a failed construction,
releasing the regions attached since the mark and restoring `used` of the earlier ones.

### 2.4 Collection (decision)

Liveness is reachability from the roots ([book §22](LMX_semantics.en.md#memory)). Marking goes by regions: each region has
a bitmap of live cells for the current generation (a service traversal table, built by the pass and discarded); a cell is
marked by nothing. The traversal follows the slots of `lmx` cells (the address in each `ref` cell of the backing), pointer
cells, `parent` and the address → name table (the rows of live addresses live, the rows of dead ones are dropped). An
`uninit:T` pointer from which the slot was turned by the first assignment onto the cell of T itself is collected **only
if no other live references to it exist**: the first assignment itself destroys nothing; the cell of T lives while the
slot or taken addresses refer to it. A region with no live cells is released whole; a region with live cells stays and its
free cells are reused (decision; no compaction -- addresses are immovable).

<a id="lmx"></a>
## 3. The Lmx graph

### 3.1 The Lmx record (decision within [L2 §2](L2_spec_en.md#lmx))

```text
struct: Lmx
    @: Lmx parent        # structural parent (the lexical tree), 0 at the root
    LmxEntry: native     # the native entry or 0: the stored body is executed
    size_t: count        # the number of fields of a Structure or of elements of an Array
    @: void storage      # the neutral address of the backing: the first of count slots; 0 for an empty Structure/Array
end: Lmx
```

**A slot** is a `ref` (`void *`) cell of the backing: a field of a Structure or an element of an Array. It is the
"`void *` field" of the author's words (§1 item 4): a slot has a stable address and holds the address of its value -- a
primitive (`uninit:T` included), an Lmx, or 0. The backing of any Lmx, **the language Array included**, is `count` slots
(one representation "in all structures", confirmed by Codex, review 2: there is no special inline form of a language Array
even for an already filled array; the typed element cells themselves may lie contiguously in an immovable region; raw C
storage and the `c.*` door are a separate existing contract, [L2 §19](L2_spec_en.md#lowlevel-array)). **How to read the
value is told by the region of the address held in the slot**, and the kind of the Lmx itself by the region of its header
(§2.2): an Array of references and a Structure both have slots and empty ones have no backing at all, so telling an Array
from a Structure and learning the element requirement is possible only by the header's region. Access to a value cell
goes through its real type by address classification, not by casting `void *` to an arbitrary array. `count` is fixed at
construction: a Structure does not grow by slots ([L2 §10](L2_spec_en.md#own)); `merge` builds a new Lmx; an Array carries
exactly `count` elements ([L2 §5](L2_spec_en.md#method-array)).

The address `@x` ([L2 §18](L2_spec_en.md#lowlevel-address)): for a Structure/Array -- the address of the slot holding the
reference to the header; for a primitive -- its typed cell, which exists from construction and changes neither its
address nor its type: before the first assignment the slot leads to it through the `uninit:T` pointer, afterwards
directly, and an `@i` taken before the first write addresses the same `int` cell as after it (the author, 19:02Z; the
question of the second review is closed). Taking an address reads no unwritten bytes. The contracts of `@i`, of the
reference value `@: p i`, of a formal's address and of a hidden input are distinct and are not mixed (the book:
[addresses](LMX_semantics.en.md#explicit-copy), [dynamic visibility](LMX_semantics.en.md#dynamic)).

### 3.2 The primitive (norm: the author, 17:22Z, 18:00Z, 18:10Z, 18:20Z, 19:02Z)

**The term.** The only entity of the graph that is not an Lmx is called a **primitive**; in the relays and journal sections
before 18:20Z it was called an "atom" -- those quotations are not rewritten, and the term "atom" in this document remains
only for the parser's notion (a P0 atom).

A primitive is one arena cell outside the `lmx:*` regions: a number, a pointer "without initialization", a word (§2.2) or
a reference. A primitive has no header; its type is the region's type, its name a row of the address → name table (if the
primitive is named), its value the cell. `int: i 5` in the body of a Structure `S`: an `int` cell = 5 in the `int` region;
a slot of `S` holds its address; a row of the name table `(the cell's address) → "i"`. Reading `S\i`: find the slot of `S`
whose cell is named `i` (§5.1), read the cell by its type. Writing `S\i: 7` writes into the same cell by the ordinary write
contract ([L2 §10–11](L2_spec_en.md#own)).

**A place without a value.** `int: x` in code, in data and in a signature: at construction the place receives its own
`int` cell in the `int` region (not yet written; every primitive place has its own cell -- two places never share one, a
literal of code is not shared with a place) and a pointer primitive onto it in the `uninit:int` region; the slot points at
that pointer. "Without initialization" is the distinct type of this pointer, recognizable by address only (§1 item 4);
the same for every primitive. It is not zero, not an arbitrary value, not a mark outside the graph; the book:
[:432](LMX_semantics.en.md#construction) -- no invented initial value, in a signature a mandatory formal;
[:123](LMX_semantics.en.md#fields) -- a repeat without a value writes nothing and only checks the contract (there is no
separate policy of repeated declarations; REPEATED-DECL-OTHER-KINDS is unchanged). `int: x 0` is a slot onto an `int` cell
= 0 directly. The difference between a mandatory formal `int: q` and a default `int: q 0` is the general address
classification of what the slot points at, without a signature wrapper, a mask or a side mark. The name `x` is a table
row for the address of the `int` cell (it exists from construction; the `uninit:int` pointer is not named).

**The first assignment** (`x: 5`, a formal receiving an argument): the received value is written into **the same** `int`
cell, and the slot is turned from the `uninit:int` pointer onto that cell directly; the cell is not allocated anew, its
type and address do not change, nothing is moved, the name row stays in place; the `uninit:int` pointer stays alive only
while other references to it exist (§2.4). **All later writes** go into that cell by the ordinary contract: no new
primitive, no rebinding of the slot; cell addresses are immovable (the author, 18:10Z). The check by both executors:
`int: i`; keep `@i` without reading unwritten bytes; `i: 5`; reading through the kept address gives 5; `i: 7` gives 7 at
the same address.

**Reading a place without a value** (Codex, review 2): the existing general admission and `convert` apply -- an
`uninit:int` value is not a ready `int`, and without a provided conversion integer arithmetic does not get its bytes; this
is **not** a general prohibition on passing or inspecting the `uninit:T` value itself in a position that receives it. A
static refusal by the translator comes only at a provably inadmissible **reached** use, not because the initial graph
contains `uninit:int`: `int: x`, `x: 5`, … `x + 1` works. No hidden initialization flag, no zero or random value.

### 3.3 An expression (norm: the author's example `x+1`)

`x + 1` is an Lmx of the ordinary kind with three fields: field 0 → the word primitive `x` (the written name: a `word`
cell with the canonical pointer to the string `x`; resolved into a place at execution through the current traversal's
table, §3.5), field 1 → the word primitive `+` (a `word` cell with a pointer to the interned string `+`; an implementation
decision: a physical word cell with a pointer to the canonical string, with no opcode and no occurrence entity), field 2 →
the number primitive `1` (an `int` cell belonging to this expression). No typed operation record (`LmxOp`), no frame with
numeric selectors and no special kind of memory for code: the interpreter recognizes the operation by comparing the
word's pointer with the interned strings of the operators (§6.2), and the operand types by the regions of their cells
after the names are resolved. The head and the arguments of any written Frame `head: a b c` are the same Lmx: field 0 the
head (the word of a receiver, an operator or a name), then the arguments; a nested Structure of a body is a child Lmx with
`parent` on the containing one.

### 3.4 Callables, var and data (norm + decision)

`fn: take (Point: p; int: q) int … end: take` is the Lmx of the written Frame, **of the ordinary kind** (§2.2), with exactly
five fields: field 0 the word primitive `fn` (the written head; the role is read by the word's pointer, §6.2 -- not by the
region kind), fields 1–4 the four parts ([book](LMX_semantics.en.md#method-parts)): `args` -- the Lmx of the formals,
`return` -- the Lmx of the result requirement, `var` -- the Lmx of own fields, `body` -- the Lmx of statements. There are
no hidden parts or roles; the name `take` is a row of the name table for this Lmx's address. `sub: … end: sub` is the word
`sub` and three parts (`args`, `var`, `body`); `fm` likewise. A Structure **created by executing** the `fn` receiver is
put into the `lmx:result` region ([L2 §2.1](L2_spec_en.md#interpretable-tree)) -- a classification of the result of
execution, not of the definition and not of a Structure with similar parts.

**Formals** are slots of `args` with the same representation as any place (§3.2): `int: q` → an `uninit:int` pointer onto
the formal's `int` cell (named `q`) -- a mandatory formal; `int: q 0` → an `int` cell = 0 -- a default, read, not
evaluated; `int: q f()` → the Lmx of the initializer -- a computed default, evaluated at each call that omits `q` (the
author's decision on computed defaults, [journal 2026-11-07](../LMX_blog/2026-11-07.md)); `@: p` without an address → an
`uninit:ref` pointer onto a `ref` cell; `Point: p` without a value → the slot points at the **ordinary declaration Lmx**
from the source graph `[Point, p]` (the requirement word and the name word), which keeps the requirement `Point` and the
absence of a candidate -- with no separate non-Lmx entity or `uninit:lmx` mark (a representation decision, confirmed by
Codex, review 2). A formal's description is not executed as a body ([book :684](LMX_semantics.en.md#method-parts)); the
actual binding of an argument and the default are not mixed ([book, callable parts](LMX_semantics.en.md#method-parts)); the formal's value in
a call lives in the activation frame (§6.3), and the `args` slot is not changed by a call.

**`data`** is an ordinary Lmx of slots onto primitives and nested Lmx. **`var`** is the same Lmx; a field with a computed
initializer (`int: r take(Point, 1)`) holds in its slot, until executed, the address of the Lmx of the declaration
statement (`[int, r, [take, Point, 1]]` -- the type word, the name word, the call Lmx): a declaration not yet executed,
with no hidden source and no early execution of effects at construction. Executing the statement is the first assignment
of the place `r`: an `int` cell is taken from the region, the slot is rewritten to its address, the published value
replaces the initializer ([book](LMX_semantics.en.md#ordinary-var), §10); later writes into `r` go into that cell. An
activation is not a graph: its working values, argument places and temporaries live in the executor's C frame (§6.3).

### 3.5 Names: words in the graph, resolution by the traversal (decision, checked by Codex, review 2)

The builder **does not bake** name resolution into the graph: every written name -- in a head, in an argument, in a path,
in an operand of an expression, in the named supply `a := v` -- stays a word primitive with the canonical pointer to its
string (§4). Resolving a name into a place is done by the consumer during its own traversal, taking into account the
current activation, the selected `code`/`data` and the current content of the graph: the nearest local binding of the
calling expression, the dynamic input it inherited along the chain of activations, then the lexical fallback by `parent`
([book §12, :827–829](LMX_semantics.en.md#dynamic)); a field of the selected `data` in `call: code data` -- by its slots;
the bindings found are maps **of the current traversal only** (§5.2), not a result stored in the graph. Direct graph
references in slots are only the real links of the language: the value of `@: p Model`, a field holding a Structure, an
address written by the program -- not a hidden outcome of resolution. The working values of different recursive
activations each live in their own frame and are not read from the shared formal or its default. The translator resolves
the same words during its translation with its own tables and emits native by the addresses found (§7); a change of code
resets such native (§6.5). Verifiability: after construction the P0 tree is absent (its arenas are released), and the next
traversal starts with empty tables -- checked by the clean-traversal criterion (§11 item 6b). `toLmx` prints a word by its
string, and a named primitive or Lmx by the address → name table.

<a id="names"></a>
## 4. Identifier strings (norm)

One spelling is one string in the process: the bytes of an interned spelling lie in the `text` region of the arena that
owns the string table and are never moved or released before the process ends. **The string state** -- the process's
string table (decision: one per process, like today's `lmx_ids`, but holding strings only) and its lookup index by bytes
-- is process state, like the address → name table and the region index (§1 item 5), not a temporary traversal table: it
exists for the whole process and is needed only at the input boundary. Interning -- the only operation that compares
bytes -- runs at the input boundaries: P0 parsing (every atom and head receives the pointer to its string together with
the token's bytes), unit loading (the unit's strings are already interned by the translator -- the emitted code carries
their table and turns it into process addresses once at load), `fromLmx`, attaching regions of another process (§8). From
then on pointers everywhere: comparing identifiers is comparing addresses of strings in the arena (§1 item 2); `toLmx`
prints the bytes by pointer. An exact identifier in backquotes is the same string as its value without the quotes
([grammar §§3.4.2–3.4.3](LMX_grammar.en.md)). User string values are not identifiers and are not interned. There is no
numeric code of a spelling, an operator or a receiver: the author's decision of 2026-11-07 about the code is replaced by
his decisions of 2026-11-08, and the book's paragraphs are updated as superseded (Codex's confirmation of 2026-11-08, no
separate ACK of the author). The former "exactly two tables" refers to names -- address → name and spelling → string
address at the input boundary -- and not to temporary traversal tables (§5.2).

<a id="tables"></a>
## 5. Tables

### 5.1 Address → name (norm: "the name is learnt from the address->name table")

One table per arena: rows `{ address, name }`, where `address` is the address **of the named primitive or Lmx itself** (the
author's norm of 17:22Z: the address of a primitive gives its type, name and value; an Lmx likewise; Codex, review 2 -- not
the slot's address, not an "occurrence", not a key "owner + number") and `name` a pointer to an interned string.
Operations: `name_of(address)` (bisection by address in the ordered table or an index by regions -- decision),
`named_field(lmx, name)` -- the slot of the Lmx whose content (the address of a primitive or an Lmx; for a place without a
value -- the address of the cell of T behind the `uninit:T` pointer) is named `name`: a walk over the Lmx's slots with one
`name_of` per slot and pointer comparison. A place's cell is named from construction, and the first assignment changes
nothing in the table (§3.2). The table is filled at construction (the names of declarations), at `merge`/copying (the
copy of a named address gets a row with the same name pointer), at `fromLmx`; the rows of dead addresses are removed by
collection. Uniqueness follows the book ([names and paths](LMX_semantics.en.md#fields)): a Structure as **data** never has
several same-named fields, and `named_field` over data is unambiguous; a Structure as **code** (source text) may repeat
definitions of one head, told apart by the source occurrence -- `s\[N]field` with zero-based `N` selects the Nth field of
that name in field order, and `named_field(lmx, name, N)` over code counts occurrences in field order; every repeated
head is its own Lmx or cell with its own table row. The semantics of repeated declarations and its narrow pause
(REPEATED-DECL-OTHER-KINDS) are not changed by this. This is the only structure of names; there is no
`LmxSourceName (key, port) → code`, no "place tables", no ordinal numbers of names.

### 5.2 Service traversal tables (norm: "do them as you like", but "kept nowhere outside a traversal")

**Lifetime.** A traversal is one execution (the activation of a root and everything it calls), one translation of a unit,
one collection pass, one construction (`merge`, a copy, `fromLmx`, loading). Service traversal tables are created empty
on entering a traversal, live in its frame (the C stack or the traversal's scratch) and are destroyed on **every** exit
-- normal, by a throw, by an error and by a Thread stop; nothing remains for the next traversal. They are not in the
graph, beside it, in the arena as mandatory preparation, in a module, a cache, a static variable or any other hidden
state; a repeated traversal after a change of the graph starts with clean tables and gets everything from the current
content of the graph and the arena. The address → name table (§5.1), the interval index of the regions (§2.1) and the
process string table with its byte index (§4) are not traversal tables: they are arena and process state, defined by the
author as the means of learning a name, a type and a string; they are not mixed with the temporary traversal tables.

**What a traversal has (decision, open list):** the interpreter -- activation frames and their working values, the name
resolution table of the current traversal (the "namespace": word → the place found for the current activation and the
selected `code`/`data`, §3.5), working `implements` maps for the given reception; the collector -- the liveness map by
regions for the pass; the builder -- the source → copy map of one `merge`/copy, the parse tree and the parsing arenas; the
translator -- scopes, the signature intern, the unit's emission plan for the duration of its translation. None of them is
read by `toLmx`, carried by copying or needed by the next traversal.

**`implements` correspondences (decision, confirmed by Codex 2026-11-08):** the proven correspondence between the used
fields of a model and the physical fields of a candidate is data of the reception or traversal that established it: a
reception holds its map for the duration of the operations it needs (reading, writing, taking an address, publishing
`dirty`), and the next traversal rebuilds it from the graph; the arena has no persistent `lmx_arena_impl`. If the language
returns a value or a Structure to the user, that graph value is not mixed with the algorithm's internal cache. The text
of [L2 §14](L2_spec_en.md#implements) about storing the correspondence is updated to this norm.

<a id="interpreter"></a>
## 6. The interpreter

### 6.1 Traversal

Executing a body is a walk over the Lmx of statements in field order. A statement is an Lmx (§3.3): the executor classifies
the address of field 0 by region: a word primitive → the role by the word's pointer: a language word
(`if`/`while`/`return`/…), a receiver (`fn`, `int`, `merge`, `@`, …), an operator or a name -- a name is resolved into a
place through the current traversal's table (§3.5); a place holding an Lmx with the head `fn`/`fm`/`sub` (the role by the
address of the head word), applied with arguments → a call ([L2 §11](L2_spec_en.md#call)); a primitive or a data place →
a value. A bare atom does not call ([READ.ME](../READ.ME)); an ordinary Structure is executed through `call`. An expression
`a op b` is three fields; the operands are evaluated recursively: a number primitive -- the value of the cell of its type,
a nested Lmx -- the result of its traversal, a name -- reading the cell of the place found, by its type (an `uninit:T`
value -- by the general admission, §3.2). No pre-translation of a body into operation frames: today's `LMX_WALK_OP_*`
frames and `LmxOp` are a second tree, removed by §9 (K03 of plan v3).

### 6.2 Roles by pointers

The language words are interned by the kernel first at process start (`fn`, `fm`, `sub`, `if`, `else`, `while`, `for`,
`until`, `return`, `break`, `continue`, `throw`, `catch`, `merge`, `implements`, `convert`, `interpreter`, `adopt`,
`independent`, `call`, `const`, `immutable`, `var`, `node`, `int`, `char`, `size_t`, `unsigned`, `ulong`, `void`, the
operators `+ - * / % = != < <= > >= && || ! & | ^ ~ << >> := \ @ [] ()`) and are available to the executors as constant
pointers (`lmx_word_if`, …): these constants are the addresses of the same strings of the `text` region, not separate
codes; service operators and receivers have neither numeric codes nor a special representation (the author, 18:18Z) --
`for`, `=`, `**` in the graph are word primitives with the addresses of their strings, and both consumers, the translator
and the interpreter, recognize them alike, by comparing the address. "Is this the word `if`" is a comparison of the
field's pointer with the constant. A user's name in a word field (§3.5) is looked up in the book's order by pointer
comparison: the local binding of the current activation, the inherited dynamic input along the chain of activations, then
the lexical fallback by `parent` (`named_field` over the slots of a known Structure -- the selected `data`, the callable's
formals, own fields); not found -- the implicit throw by the book.

### 6.3 Activation

An activation is the executor's C frame (like today's `LmxWalkFrame`): the selected code and data, the arena, `node` (the
callable's lexical parent), the argument and working-value cells, the result, the throw pad, the name resolution table of
this traversal. The working values of own fields are the frame's cache, published into the graph's cells at checkpoints
([book §12](LMX_semantics.en.md#dynamic)); no "bindings by code" (`LmxActivationBinding`) are needed: a formal is the
address of its slot in `args` (a description: the requirement, the default, `uninit:T` or a declaration without a
candidate), an argument is a frame cell found by position or by name (§5.1); receiving an argument is the first
assignment of the frame's argument place. Reception, `implements` by used fields, conversion routes and throws follow the
current book; the carrier changes, not the rules (`:=`, `merge`, positional `a(5)`/`a: 5`, q/z, AXBY are kept -- §11).

### 6.4 Copying, merge, attaching

`merge`/a copy build a new Lmx with one source → copy address map (a service table for the duration of the operation):
`lmx` cells and primitives (a place without a value is copied as a cell of T and an `uninit:T` pointer onto the copy -- it
stays a place without a value; words are copied as cells with the same string pointer) are copied into the regions of
their types in the receiving arena, slots are rewritten by the map, `parent` onto the copies, shared targets and cycles
are kept ([L2 §13](L2_spec_en.md#copy-merge)); the rows of the name table are copied with the same name pointer for the
copies' addresses; interned strings are shared by the process, nothing to copy. Attaching the regions of another arena of
the same process touches neither cells nor names; attaching from another process (mail between processes, §8) passes
through a `fromLmx`-like interning boundary. `independent: immutable` follows the book.

### 6.5 Resetting `native` on a write (decision; the norm is [L2 §11](L2_spec_en.md#call))

The norm ([L2 §11, the paragraph on writing](L2_spec_en.md#call)): the common write path, with the place and the value
admitted, resets `native` of the **code places** linked to the changed cell (the direct path at the write, the working
`dirty` at the publication checkpoint); **changing an ordinary data value keeps the entry**; the link to a code place
may belong to an enclosing Structure, not only to the Structure with the written slot; writing into the slot and
removing the inputs of changed code are atomic for the next or a recursive dispatch; a refused invalidation stays before
publication. The implementation tells **code from data by the place of the write**, not by transitive reachability of
the graph and not by the name or the reference through which the write is made: the write path knows the slot it writes
into and the Lmx that slot belongs to. An **executed Lmx** is one that execution reads as code: a callable
`fn`/`sub`/method with its parts `args`, `return`, `body`; an ordinary executed Structure without `fn` parts -- the
Message root with statements, a Structure executed through `call: code data` or `call: code code` ([L2
§11](L2_spec_en.md#call)); a statement inside them; a declaration statement not yet executed (§3.4). A slot belongs to
**code** if execution reads its content as a part of a statement of an executed Lmx -- the head, a word, a literal, an
operand, a nested statement; then the code itself changes, and the `native` of that Lmx and of every callable whose code
contains or refers to it are reset. A slot belongs to **data** if it is the place of a value the executed code reads: a
declared place after its declaration ran (`int: x 5` -- the cell `x`), a field of a data Structure, of `data`, of `var`
or of the root as a store of values -- such a write keeps `native`. The role is read from the Lmx itself and the slot's
position in it, not from the names `args`/`return`/`body`, not from the name of the destination place and not from the
reference: a write through an alias, or through a Structure handed over as `data`, into a statement of an Lmx that
anyone executes is a write into code, and `native` is reset; the name `data` by itself grants no exemption from
invalidation. For a write into code, the `native` of the callables in whose parts the changed Lmx lies (the `parent`
chain) and of the callables whose code refers to it by a slot (a shared code substructure after `merge`/copying, or a
reference to code held in data) are reset -- the latter are found by a **fresh traversal** from the roots of the current
traversal (the Message root, the live activations, the mail) over the statements of the executed Lmx with `native` ≠ 0
and over the Lmx references inside them, without entering data values; there is no index between traversals, only a map
**of this traversal** is allowed (§5.2). Separate witnesses (§11 item 6): (1) changing an ordinary `x` read by the body
(a field of the root, of `var` or a declared place) -- `native` kept, the next call reads the new value; (2) changing a
literal or an operator in `body` -- every `native` whose code contains or refers to it is reset; (3) code shared by two
callables (code aliases) -- both are reset; (4) a change incompatible with the former entry -- a refusal before
publication; (5) changing a statement of an ordinary executed Structure without `fn` parts through a reference handed to
it as `data` -- its `native` is reset, while writing a value through the same reference keeps it. The first assignment
and a write into an existing cell obey one rule -- the slot's ownership decides. No `parent` is introduced for a
primitive.

<a id="native"></a>
## 7. Native

The translator is a consumer of the clean Lmx graph (§1a), not of the parse tree: its input is the unit's built graph in
the translation arena, and everything it knows about the program it reads from slots, cells, the address → name table and
the regions; it resolves the names itself during its translation (§3.5), and its scopes, signature intern and emission plan
are tables of its traversal, destroyed when the translation ends (§5.2). For every body with `native` it emits C code that
reads and writes **the same cells**: a field's slot is known as the k-th `ref` cell of the backing of the selected Lmx, the
value's type by the region of the address in the slot and the declaration, values are machine operations on the cells;
the temporary results of expressions live in the C frame and are not addressable ([L2 §18](L2_spec_en.md#lowlevel-address));
the first assignment of a place without a value is the same kernel operation as in the interpreter (a write into the
pre-existing cell of T, the slot turned onto it), later writes go into the cell. No names are needed at a call -- the call
goes by the address of the callable Lmx and its `native`. Where native must find a field by name at run time (the data of
`call: code data`, dynamic visibility), it calls the kernel's same `named_field` with the string pointer (a constant of the
unit). An emitted unit consists of: the unit's string table (bytes; at load one interning call per string, the result an
array of pointers `l2_names[K]`), the exact region sizes, the generated initialization of the clean graph through the
common constructor (§1a), the native bodies. Native/interpreter parity is checked by the same regressions on both routes.

<a id="codec"></a>
## 8. toLmx and fromLmx

`toLmx` walks the current graph: for a slot it prints the cell's value by the region's type (a place on an `uninit:T`
pointer is a declaration without a value, `int: x`), the address's name from the address → name table (if any), a word as
the bytes of its interned string, an Lmx recursively (an Lmx with a word head as a Frame `head: …`); the order and the
composition are the current ones ([book](LMX_semantics.en.md#source-codec)). `fromLmx` parses the text with the common P0,
interns the spellings (§4), builds Lmx and primitives in the regions of the receiver's arena (a place without a value -- a
cell of T and an `uninit:T` pointer onto it; names -- words), fills the name table. Between processes bytes of text
travel, not addresses.

<a id="audit"></a>
## 9. Audit of the existing parallel representations

| Today | What it is | Decision |
|---|---|---|
| `lmx_ids` (two tables "code → name", "name → code", unit codes `l2_ids[K]`, `LMX_ID_*`) | a numeric code as the identity of a spelling | replace by the string table (§4): identity is the string's address; word constants are the pointers of §6.2 |
| `LmxSourceName {key, port, code, place_spec, model_layout, place_uses, place_callable}` and `lmx_source_names` | the binding "occurrence + port → code" with side place maps | replace by the address → name table (§5.1); no place maps: a field is a slot |
| `lmx_walk_input_width` counts an ordinary Structure's interface by the positive ports of the name table; the emitter creates those rows (`lmx_source_name_set_at` by `m_dyn`) -- Codex's example | the interface is derived from a side table, not from the graph | a Structure's interface is its slots (`count`, named addresses); hidden inputs by §6.3 |
| Place tables `[m, SIZE_MAX, (code, type)…]` (`lmx_source_places_set`, the `PLACE` frame, `LmxCallPlaces`) | a static description of a procedure's places beside the graph | remove: a place is a slot; a name is a word resolved by the traversal (§3.5) |
| `LmxActivationBinding {code, storage, type, value}`, `lmx_activation_bind` | binding a name by code in an activation | remove: a formal/input is the address of a slot (§6.3), resolution is the traversal's table |
| A place without a value is a cell holding zero or garbage; every write (`lmx_value_store`) goes into that cell | the state "not initialized" is indistinguishable or outside the graph | an `uninit:T` pointer onto the cell of T by region; the first assignment writes into the same cell and turns the slot onto it, later writes go into it (§3.2) |
| The walker's frames `LMX_WALK_OP_*` (66 operations), `LmxOp {code}`, `lmx_walk_frame_profiled`, numeric selectors in slots (`lmx_walk_store_size`), `OF`/`AT`/`PUT_OF` by slot numbers | a second tree of the body -- pre-translation into operations | remove (K03): a body is an Lmx of words, primitives and nested Lmx (§3.3, §6.1) |
| The binder's `l2_bn` name arrays, `lmx_call_bind_*` by codes | argument names as codes | by the string pointers in the word primitives of the named supply |
| `LmxPool.role/profile/sealed`, `LmxRange.links/slot_owner/holder/side_*` | side arrays of intervals and result profiles | the physical kinds are header regions (§2.2, [L2 §3](L2_spec_en.md#type-by-range)); the role of a definition is its head word |
| `LmxImplEntry/LmxImplContract` (`implements` maps) | the address correspondence of a model and a candidate | data of the reception/traversal (§5.2): held for the duration of its operations, rebuilt by the next traversal |
| The arena's persistent `implements` map (`lmx_arena_impl`, `LmxImplEntry.exec_map`, `lmx_arena_impl_prune`) | prepared correspondences that outlive a traversal | data of the reception/traversal (§5.2): remove the persistent store, L2 §14 updated |
| `LmxCodeLink`/`lmx_code_*` (side chains "cell → code places" for the `native` reset), `LmxArena.reset_gen`, `LmxChunk.value_contexts`, the `LmxWalkValue` contexts of pointer cells | side state between traversals and of cells | the `native` reset by the slot's ownership by code and by a fresh traversal of the callables' parts (§6.5); type and context are the address's region |
| The translator: `LmP0Text\code`, `l2_words`, `lm_compiler_text_same` by codes (the stopped WIP 308), the signature intern by codes | numeric codes in the translator | `LmP0Text` carries the interned string's pointer from parsing; comparisons are of pointers; the signature intern by pointers |
| The L1 translator (`l1_text_eq`, `l1_head_is`, …) | string comparison | the pointers of the same interned strings (one P0 for both translators) |
| The P0 parse tree as the translator's input (the frontend reads `LmP0Node/Frame/Field`), its arenas and indexes (`l2_pd`, `pdx`) | a separate form of the program for one consumer | the translator reads the clean Lmx graph (§1a, §7); P0 is inside the builder and is destroyed with the construction |
| The unit's graph builders in emitted code: `lmx_walk_frame_profiled` with operations, `lmx_source_name_set*`, `l2_ids_load`, place tables, `l2_sc*` | a generated second form of the program (operations, places, hidden interfaces) | remove; what remains is the generated initialization of the **clean** graph through the common constructor -- cells, slots, words, address → name, regions, `native` references (§1a) |

What stays: `Lmx.parent`, `Lmx.native`, the arena with regions and the interval index, Message/Thread/mail, `implements`
as a rule (its carrier is a service table of the reception), copying by one map, collection by reachability.

<a id="example"></a>
## 10. A worked example

```text
Point:
    int: y 0
    int: x 0
end: Point
fn: take (Point: p; int: q) int
    return: p\y * 10 + q
end: take
int: r take(Point, 1)
```

**The graph after construction, before execution.** The unit's root is an `lmx:data` Lmx with three slots. Slot 0 → the
Lmx `Point` (`lmx:data`, two slots → `int` cells 0 and 0 in the `int` region; the name table rows for those cells'
addresses are `y`, `x`; for the Lmx's address, `Point`). Slot 1 → the Lmx `take` (`lmx:data`, five fields: the word `fn`;
`args` -- an Lmx with two slots: `p` → the declaration Lmx `[Point, p]` (the requirement and name words; the name row `p`
is for this Lmx's address), `q` → an `uninit:int` pointer onto the formal's unwritten `int` cell (a mandatory formal; the
row `q` is for that cell's address); `return` -- an Lmx with a field → the word `int`; `var` -- an empty Lmx; `body` -- an
Lmx with one statement; the row `take` is for the Lmx `take`'s address). Slot 2 → the Lmx of the declaration statement
`[int, r, [take, Point, 1]]`: field 0 → the word `int`, field 1 → the word `r`, field 2 → the call Lmx: field 0 → the word
`take`, field 1 → the word `Point`, field 2 → an `int` cell 1. Nothing is resolved in advance: `take` and `Point` are
words; there is no cell `r` yet -- the initializer is not evaluated, slot 2 holds the statement (§3.4). The statement of
`take`'s body is the Lmx `[return, E]`, where `E` = `[[[p, \, y], *, 10], +, q]`: all names and operators are words
(`return`, `p`, `\`, `y`, `*`, `+`, `q`), `10` is an `int` cell.

The unit's regions: `lmx:data` -- the root, `Point`, `take`, its four parts, the declaration `[Point, p]`, the `return`
statement, the three expression Lmx of `E`, the declaration statement, the call Lmx; `int` -- `y`, `x`, the cell of `q`,
`1`, `10`; `uninit:int` -- the pointer onto the cell of `q`; `word` -- `fn`, `Point` and `p` (the formal's declaration),
`int` (the result requirement), `int`, `r`, `take`, `Point` (the declaration statement and the call), `return`, `p`, `\`,
`y`, `*`, `+`, `q`; `ref` -- the slots of all Lmx; `text` -- the strings `Point y x take p q return r int fn` and the
language words of the kernel. The name table: `Point`, `y`, `x`, `take`, `p`, `q` -- for the addresses of the Lmx and
primitives themselves; no row `r` yet. `toLmx` prints the same program: slot 2 is an Lmx with the word head `int` →
`int: r take(Point, 1)`; the field names `Point`, `y`, `x` come from the table.

**Execution.** The interpreter walks the root by slots; slot 2 is an Lmx with the word head `int` → a declaration with a
computed initializer; the call Lmx: the head is the word `take`, resolved by this traversal's table into the root's slot 1
-- an Lmx with the head `fn` → a call; an activation in a C frame; the frame's argument places receive their first
assignment: the word `Point` is resolved into the Lmx `Point`, `p` receives its address by `implements` (the used field
`y`; the correspondence map is data of this reception, §5.2), the `int` cell of the frame's argument place `q` receives 1;
the body: `return` is a word; `E`: `p\y` → `named_field(value of p, y)` → the `int` cell 0; `0 * 10 + 1` = 1 (temporaries
in the frame). The result 1 is the first assignment of the place `r`: a new `int` cell from the `int` region, 1 is written
into it, the row `r` for its address is added to the name table, the root's slot 2 is rewritten from the statement's
address to this cell's address; the declaration statement and the call Lmx, referred to by nobody else, are collected
(§2.4). Now `toLmx` prints `int: r 1` -- the published value replaced the initializer ([book](LMX_semantics.en.md#ordinary-var));
a later `r: 2` writes 2 into the same cell (a data write, `native` entries are kept, §6.5). Native for `take`: the
translator resolved the words `p`, `y`, `q` at translation; the C code reads the formal `p`'s slot of its frame, calls
`named_field` with the constant `l2_names[Y]`, reads the `int` cell, multiplies, adds the cell of `q`, returns; the unit's
loading code is the generated initialization of this same graph through the common constructor (§1a): region sizes,
cells, slots and words, the rows of the name table, `native` at `take`.

<a id="transition"></a>
## 11. The transition plan (agreed with Codex in the second review)

The transition runs as the one existing L2/L3 pipeline (one writer/build), in slices, each recorded and checked by Codex;
code is written only in the agreed part. Checks go by the risk of a slice's change: the affected fixtures on native and the
interpreter, the short cycle of the whole chain ([READ.ME](../READ.ME)); the full checks -- the whole regression registry
(139 rows of `selfbuild/tests/full-suite.tsv`, native and forced, both roots), bootstrap quick and full, docs check -- at
the end of a stage and before every publication, not on every small slice. Earlier decisions and receipts remain history;
the earlier PASS results of the stopped slices prove nothing about the new implementation; the stopped mutants, bootstrap
and publication of 308 are not run; the task is closed neither by a document nor by one quick.

0. **The vertical slice -- first** (allowed by Codex, review 2; without another ACK). A minimal builder → one clean graph →
   both consumers, in this order: (a) a graph with an already initialized `int`, arithmetic and a repeated write
   (`int: x 5`, `x: x + 1`, `x: 7`); (b) the first assignment (`int: x`, `x: 5`, `x + 1`), including with an address taken
   in advance (`int: i`; `@i` kept without reading unwritten bytes; `i: 5` -- reading through the address gives 5; `i: 7`
   -- 7 at the same address; the author, 19:02Z), and separate clean traversals (a second traversal of the same graph with
   empty tables); (c) the example of §10 in full -- regions with `uninit:int`, slots, word primitives, the address → name
   table, the interpreter by §6, the translator by §7 with native for `take` and the generated initialization of the graph,
   `toLmx` before and after, native/interpreter parity, the clean-traversal criterion (item 6b). The new path is built
   beside the old one under a separate tool entry and does not touch the old emission until it covers the fixture.
1. **Extending the graph by the registry's fixtures**, in groups by risk: expressions and `:=`, `merge` and copying, Array
   (slots, §3.1), `var`/`data` and `call: code data`, throws and `catch`, dynamic visibility, the named supply, q/z, AXBY
   -- every moved row passes native and forced on the new path.
2. **Removing the old carriers as coverage grows** (the map in item 7): `lmx_ids`/codes → strings; `LmxSourceName`, place
   tables, `LmxActivationBinding` → slots, words and the name table; `LMX_WALK_OP_*`/`LmxOp` → the Lmx of statements;
   profiles and side arrays → regions; the persistent `implements` map → reception data; `LmxCodeLink` → §6.5.
3. **The translator over the graph in full.** The frontend reads the unit's clean graph instead of the P0 tree; the parse
   tree and the builder's arenas are destroyed with the construction; the L1 translator compares the pointers of the same
   strings; the stopped WIP 308 is not used.
4. **Arena regions as the only storage.** `LmxPool/LmxChunk/LmxRange` → regions with the interval index; exact region sizes
   in the emission; attach/mark/revert/GC by §2.
5. **The full final checks:** the whole registry on both executors, bootstrap quick and full, checks, landing, docs render
   and check; item 6 in full.
6. **Acceptance of the transition.** (a) No comparison of identifier strings in any executing chain or any translator pass
   (an audit by grep for `memcmp/strcmp/strncmp` with a classification of the remainders by role), no `LmxSourceName`, place
   tables, `LmxOp`, numeric codes, persistent traversal maps, initialization marks outside regions, name-resolution results
   stored in the graph; (b) **the clean traversal criterion**, by language fixtures (`lmxtool`/L2, not a maintained
   Python/Perl runner): a program P (1) is built and executed -- the result R1 is compared with the expected E1, on native
   and on the interpreter each; (2) is changed during execution (a field write, `merge`, code built from data) and
   executed again -- the result R2 is compared with the expected result E2 of the **changed** program (not with R1),
   native and interpreter each for that state; (3) `toLmx` of the changed graph, `fromLmx` into a **second arena alive at
   the same time as the first**, execution there -- R3 = E2, and the next clean traversal of the first arena yields E2
   again; between traversals no live object of traversal tables and no P0 tree exist in the process (a release check on
   all exits, including a throw and a Thread stop); (c) `toLmx` of a unit with `data`, `var`, a place without a value, a
   method, an expression and an Array matches the program in composition and order; (d) the separate witnesses of the
   `native` reset (§6.5); (e) native/interpreter parity on the whole registry; (f) the full self-build.
7. **The removal map of the prepared form** (what disappears at which stage): stage 2 -- `lmx_ids`, `l2_ids`, codes,
   `LmxSourceName`, place tables, `PLACE`, `LmxCallPlaces`, `LmxActivationBinding`, the `lmx_source_name_*_at` ports, the
   `LMX_WALK_OP_*` frames, `LmxOp`, numeric slot selectors, `l2_bn`, `LmxPool.role/profile`, the `LmxRange` side arrays,
   `LmxCodeLink`, the persistent `implements` map, `LmxChunk.value_contexts`; stage 3 -- `LmP0Text\code`, `l2_words`, the
   P0 tree as the frontend's input, the predef indexes `l2_pd`/`pdx`, the generated `l2_rw*` builders; stage 4 --
   `LmxPool/LmxChunk/LmxRange`.

**Decided by Codex's second review** (CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01): the name goes by the address
of the primitive or Lmx itself (§5.1); reading a place without a value -- the general admission and `convert`, with no
static refusal by the mere presence of `uninit:T` (§3.2); `@: p` without an address -- `uninit:ref`, `Point: p` without a
value -- the ordinary declaration Lmx (§3.4); an Array -- an Lmx with slots and no special inline form (§3.1). The only
question of the second review -- what an `@i` taken before the first assignment addresses -- was **closed by the author at
19:02Z** (CODEX-FABLE-AUTHOR-UNINIT-POINTER-SAME-CELL-20261108T190254726Z-01): "T without initialization" is a pointer onto
that very cell of T, the cell's type does not change at the first assignment, `@i` before and after addresses one cell
(§1 item 4, §3.1, §3.2); there are no open questions to the author.
