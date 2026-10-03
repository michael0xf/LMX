# L1 → L2 → L3 coding and migration instruction

This document is a practical instruction for moving kernel and application code upward through the current LMX profiles. It is not a replacement for the normative specifications. When an example here and a normative specification disagree, the normative specification wins.

The authoritative language documents are:

- `docs/LMX_semantics.en.md` for L3 semantics;
- `docs/L2_spec_en.md` for L2 machine mechanisms and their L3 boundary;
- `docs/L1_spec_en.md` for L1 and its lowering to target C99;
- `docs/LMX_grammar.en.md`, generated from `provenance/grammar.json`, for source shapes;
- `CORE.md` for the compact core summary.

Implementation state is intentionally kept separate. `steps/current.md`, `next_core_tasks.md`, `steps/native-selfbuild-20260930.md`, and `steps/defects.md` describe released checkpoints, pending work, and measured limitations. The development source under `build/opus_wt/dev/l2src_sandbox` is a mutable implementation worktree, not a normative source. Do not derive a language rule from a temporary worktree branch, generated identifier, diagnostic, or passing fixture.

## 1. Status words used here

Every important statement is classified as one of the following.

- **NORMATIVE** — required by the current language specifications or an accepted author clarification.
- **SUPPORTED** — covered by a released implementation checkpoint and focused evidence identified in the implementation notes. This is a snapshot, not a language restriction.
- **PENDING** — normative behavior whose general implementation or full acceptance evidence is still incomplete.
- **L1 ONLY** — a machine-lowering facility of L1, not a construct that may be introduced into interpreted L3.
- **RAW C** — explicit foreign C ABI syntax. It carries the target C contract, not graph semantics.

Do not turn **PENDING** into a refusal rule. Do not turn **SUPPORTED** into a new semantic exception. A port may temporarily diagnose an unsupported required case, but it must describe that diagnosis as an implementation boundary.

## 2. The three profiles and the direction of migration

### 2.1 L1

**NORMATIVE.** L1 is the direct lowering language toward target C99. It contains explicit pointer declarations, C-shaped arrays, C ABI declarations, raw `c.*` access, platform conditionals, and the kernel's manual arena calls. L1 variables and C aggregate fields are machine objects; they are not automatically LMX graph cells.

Typical L1:

```text
@: int p
p: @x
\p: 7
c.memcpy(dst src n)
```

Conceptual C99:

```c
int *p;
p = &x;
*p = 7;
memcpy(dst, src, n);
```

L1 exists so the L2 compiler and kernel can be lowered portably to C99. It is not the target language for new application semantics.

### 2.2 L2

**NORMATIVE.** L2 contains all of L3 plus explicit machine mechanisms needed to implement the kernel: target C99 machine types, machine addresses and address arithmetic, raw memory/ABI operations, arena construction, native callbacks, mail and scheduling mechanisms. A compiled L2 body may use these operations. The L3 graph interpreter must not execute them.

L2 is where an implementation may say “this value is an `int *` on the target” or “this raw call follows the ABI declared by the included header.” It must not use those facts to redefine a Structure as a C aggregate or a graph reference as an integer address.

### 2.3 L3

**NORMATIVE.** L3 is a subset of L2. L3 contains Structures, receiving expressions, portable reference declaration/acquisition/following, primitive values, Arrays, calls, control bodies, composition, admission, Messages, and high-level operations. It excludes operations whose meaning is numeric machine-address manipulation, unchecked raw memory, or arbitrary `c.*` execution.

The spelling `@` is not banned from L3. In L3 it denotes portable reference behavior: declare a reference variable, obtain a reference to resolved typed data, pass or rebind that reference, and follow it. The same spelling may lower to a C address in native code, but L3 does not thereby acquire pointer arithmetic.

### 2.4 Migration rule

Move a mechanism upward only after identifying its semantic contract.

1. Start with the observable contract, ownership, lifetime, inputs, result, and exits.
2. Separate machine implementation facts from graph meaning.
3. Express the contract through ordinary LMX receiving expressions, Structures, references, Arrays, calls, and admission.
4. Keep only the irreducible machine operation in L2.
5. Keep target-C spelling, header types, and platform selection in L1 or the explicit raw-C door.

A bad migration transliterates C syntax into L3. A correct migration replaces C's implicit context with explicit LMX data and receivers while preserving identity and lifetime.

## 3. One graph, one application rule

### 3.1 Complete retained graph

**NORMATIVE.** Source constructs one complete binary Structure tree containing declarations, values, comments, names, and executable operators in lexical order. A declaration does not execute its body. An executable operator is not moved into a separate “code graph,” “saved-call object,” capsule, or permanent parallel context graph.

Names and comment text may be retained for diagnostics and tooling. Runtime dispatch and value resolution follow resolved graph references and positions, not a name lookup table.

```text
fn: put (int: n) int
return: n

Batch: (put: 7)
```

`Batch` stores one Structure whose body contains the ordinary `put: 7` operator. Defining `Batch` does not call `put`. When execution reaches that operator, normal call rules apply.

### 3.2 “The head consumes the tail”

**NORMATIVE.** Block, short, parenthesized, and explicitly closed spellings all form applications. Resolve the head in its receiving and lexical context before deciding what the tail means.

The role order is:

1. a reserved receiver/operator uses its defined contract;
2. a known callable, including an ordinary named Structure, is called and its resolved contract checks the written actuals;
3. a known primitive is assigned under its contract; a Structure reference uses ordinary callable application, with explicit rebinding selected by `@: b B`;
4. an unknown head in definition position declares a named Structure.

Argument count, parentheses, or an empty tail do not override this resolution.

```text
int: i 5       # primitive declaration through the int receiver
i: 7           # assignment to the known primitive
f: x           # call if f has a callable signature accepting this actual
Known: x       # call resolution; arity error if Known is an ordinary named Structure
Unknown: x     # declaration only when Unknown is an unknown head in definition position
```

An ordinary named Structure has a body but no formal arguments or result. Its valid call is nullary. Supplying an actual does not change the syntax class or fall back to declaration or assignment: ordinary call checking reports an arity error. `fn`, `fm`, and `sub` keep their explicitly declared formal and result contracts. This is the settled [Q59](LMX_blog/q/q59.md) rule.

Do not introduce an `int: i: 5` synonym here. The current canonical primitive declaration example is `int: i 5`; nested colon applications remain distinct syntax trees unless their receivers define otherwise.

### 3.3 Unknown and known nested heads

**NORMATIVE.** The same rule applies recursively inside a containing Structure.

```text
C: makeA()
```

If both `C` and `makeA` are unknown in this definition context, this defines `C` with an empty named nested Structure `makeA`. Parentheses alone do not make a call.

If `makeA` is already a callable in the applicable context, the nested node is an ordinary call retained in `C`'s body. It is not executed while `C` is defined. The call is still checked against the resolved callable contract: a nested ordinary named Structure is nullary, while a nested `fn`, `fm`, or `sub` uses its declared signature.

**PENDING.** The current implementation notes still track complete common known/unknown nested-head resolution. Code generators must not add a spelling flag, empty-body exception, or call capsule to bridge this gap.

### 3.4 Signatures are descriptions, not executed declarations

**NORMATIVE.** A callable signature describes transport, admission, defaults, result, and exits. Its forms are not executed as body declarations.

For a nonprimitive model `A`, these formal spellings are synonymous reference transport:

```text
sub: test (A: value)
sub: test (@: A value)
```

Both pass the candidate's Structure descriptor after admission to `A`. Neither allocates an executable reference-variable cell in the callee merely because `@:` appears in the signature.

For a primitive, the distinction remains real:

```text
fn: byValue (int: value) int
fn: byReference (@: int value) int
```

The first receives an integer value. The second receives a reference to an integer. Do not infer the formal's meaning from the C parameter spelling used by one backend.

## 4. Declaration, assignment, and explicit composition

### 4.1 Declaration is not assignment

**NORMATIVE.** Only a declaration introduces an occurrence. Assignment updates the already selected binding after conversion and admission. A repeated assignment does not create a same-name occurrence. A repeated declaration does.

An explicit or hidden input is activation-local. Assigning it does not create or update a public graph field and does not write back to its caller. An own field occupies a real place in the graph and follows ordinary working-cache/publication rules.

Machine locals are visible only forward and down from their declaration site. Methods are visible under the program's method-resolution rules; do not apply variable forward-visibility mechanically to method discovery. An initializer is resolved in the environment preceding the new declaration, then the new occurrence is bound.

### 4.2 No implicit `Model:fresh`

**NORMATIVE.** A known Structure head is a call, not an implicit constructor, clone, typed empty reference, or alias declaration.

```text
A: b
```

If `A` is a known ordinary named Structure, this resolves as a call and then fails the ordinary arity check because that Structure accepts no arguments. If `A` is a `fn`, `fm`, `sub`, or another callable with an explicit input contract, `b` is checked as an actual against that contract. In neither case does failure mean “declare `b` as a fresh A,” “clone A,” or `merge(A, empty)`.

### 4.3 Explicit merge

Use `merge` when a new composed Structure is required:

```text
b: merge A C
```

The operands are `A` and `C`; `b` receives the result. `b` is not silently inserted as a first operand. Merge is explicit construction and has its own copying, reference-retention, parent, identity, and admission rules.

**SUPPORTED/PENDING boundary.** Ordinary merge-result own storage and known-schema result projection have focused implementation work and evidence. The implementation notes still track held operands whose declared view differs from their actual layout, hidden/formal merge operands, and general occurrence-selector projection. Write portable source to the normative rule, but label compiler examples depending on those open cases as **PENDING**.

## 5. Values, references, places, and addresses

### 5.1 Do not conflate these categories

Keep four concepts separate:

- a value, such as integer `5` or a Structure descriptor;
- a place, the storage cell that can be assigned;
- a reference value, which denotes typed data;
- the cell of a reference variable, which stores that reference value.

C often represents several of these with pointer-shaped words. LMX semantics does not collapse them.

### 5.2 Reference declaration

**NORMATIVE.** Reference assignment and ordinary Structure application are separate acts:

```text
b: A       # absent b; equivalent to @: b A
b: args    # application; the selected callable checks its actual arguments
@: b B     # explicit reference reassignment
```

Do not reinterpret this equivalence as permission to erase a written body, merge implicitly, or identify distinct declaration occurrences. Repeated declarations retain separate places. Conversion and implements precede any reference store; a failed check leaves the prior value intact. There is no separate nominal “Type” object: requirements use primitives or ordinary Structures.

Pointer primitives retain their declared depth, for example `@: int p` and `@@: int pp`. Unary `@A` is not the receiver `@:`: it addresses the stored reference and adds a level. Do not port an old `test(A) == test(@A)` assumption.

### 5.3 What `@x` denotes

**NORMATIVE.** `@x` addresses the resolved value's actual storage. A Structure/Array value is already a descriptor reference; `@x` addresses the cell holding it and adds a level, never returning the descriptor again or the address of a temporary.

| Selected `x` | `@x` denotes |
| --- | --- |
| declared primitive graph field | the real typed primitive cell |
| ordinary Structure | the real reference-holding cell; conceptually `Lmx **` |
| ordinary Array | the cell holding its descriptor reference; one level deeper |
| Array element | the actual typed backing element |
| explicit reference variable | the reference-value cell; depth increases by one |
| primitive formal/dynamic input | its activation-local typed cell |
| nonprimitive formal | its stable activation-owned reference cell, not caller storage or an ABI transport box |

Example:

```text
int: x 5
@: int p @x
\p: 9
```

The store through `p` changes the physical `x` cell. It does not itself assign or dirty a separate cached working value. A later working assignment may publish through the ordinary rule. Address acquisition alone is neither a write nor a lifetime extension.

### 5.4 Portable L3 reference versus L2 machine address

**NORMATIVE.** L3 may declare, obtain, pass, compare under its defined contract, rebind, and follow portable references. L2 additionally permits machine-address operations and raw access under target C99.

Do not serialize a portable reference as an integer and then claim L3 portability. Do not reject `@` merely because native lowering uses `&`. The boundary is the operation's meaning, not its glyph.

### 5.5 Null is present when supplied

A typed null reference is a reference value. It is distinct from an absent actual or hidden input. An omitted reference initializer produces the typed null value. A supplied null must not trigger lexical fallback as though no value was supplied.

### 5.6 No C aggregate by-value substitution

**NORMATIVE.** Passing or returning an ordinary Structure or Array uses its descriptor/reference semantics. It does not copy a generated C aggregate by value. A raw foreign C record explicitly declared through the C ABI may be by value because that is its foreign ABI contract; this does not change ordinary graph values.

## 6. Primitive types and target C99

### 6.1 Exact target types

**NORMATIVE.** L2 machine primitive names denote the corresponding target C99 types. Their width, rank, signedness, conversions, overflow behavior, and ABI follow the target C implementation unless L3 defines a separate high-level operation.

- plain `char` has target C's signedness; it is not forced to `uint8_t`;
- `unsigned char` remains a distinct leaf before integer promotion;
- `int`, `unsigned`, `unsigned long`, and `size_t` retain target rank and representation;
- `size_t` is the target implementation's `size_t`, not a language-defined arithmetic supertype;
- ordinary C integer promotions and usual arithmetic conversions apply to L2 machine arithmetic;
- signed overflow, shift constraints, division behavior, and pointer arithmetic are target-C matters where L2 exposes them.

Do not hard-code Windows widths, LP64 widths, or infer rank from byte width alone. Do not scan platform headers to create a language type universe. A port should obtain ABI facts from the same target C toolchain/profile used for generated C.

### 6.2 L3 arithmetic

L3 may expose portable numeric receiving expressions with stronger, explicit contracts. Such a receiver is not obtained by silently wrapping every L2 arithmetic operation with checks. Conversely, a native high-level implementation must satisfy the same L3 contract as its interpreted form.

### 6.3 Pointer operations are not blanket-forbidden in L2

L2 intentionally admits typed pointer arithmetic and comparisons that target C99 admits. Reject only incompatible operand pairs or operations outside their declared profile. L3 portable references do not thereby inherit numeric pointer arithmetic.

**PENDING.** The implementation plan tracks complete shared C99 result typing across checker, native lowering, and walker arithmetic. Do not encode pairwise name allowlists as a substitute.

## 7. Arrays: descriptor, element type, and paths

This section is intentionally explicit. Most migration errors come from confusing a fixed Array descriptor, a flat rectangular allocation, an Array of references to Arrays, and a dynamic container.

### 7.1 Base descriptor

**NORMATIVE.** A standalone base Array has a minimal typed descriptor:

```c
typedef struct {
    size_t size;
    void *data;
} VoidArray;
```

Typed forms preserve the same two facts with the real element pointer, for example conceptually:

```c
typedef struct {
    size_t len;
    int *data;
} LmxIntArray;

typedef struct {
    size_t len;
    char *data;
} LmxCharArray;
```

`size`/`len` counts elements, never bytes and never capacity. The backing contains exactly that many elements. The base descriptor contains no rank, extents vector, shape, stride table, capacity, reserve state, append cursor, parent, or growth policy.

The first member of `Lmx` is also a `VoidArray`, but there it is the actual array of immediate physical child references. The `Lmx` record and a standalone Array descriptor occupy different classified ranges even though the embedded descriptor has the same C layout.

### 7.2 Dynamic containers are separate

If growth is required, use a separate dynamic descriptor such as:

```c
typedef struct {
    VoidArray array;
    size_t capacity;
} VoidDynamicArray;
```

The capacity belongs to that dynamic descriptor, not to the base Array and not to a hidden prefix in the backing. List is a dynamic container over references; it does not redefine every Array as growable.

### 7.3 General receiver composition

**NORMATIVE.** `[]:` is an ordinary receiver participating in arbitrary nesting:

```text
[]: []: []: values
```

This is not a rank-three special parser production, not a fixed two-level Array feature, and not a new “nested Array” runtime kind. Each independent Array has its own descriptor and length. The receiver chain may have any finite depth supported by ordinary application syntax.

For an Array of Arrays, bind and index ordinary intermediate values:

```text
[]: []: b a[i]
[]: c: b[j]
```

No implementation may special-case exactly `[]: []:` or store a fixed rank of two.

The two lines above are the normative receiver-composition example, including the second colon. General arbitrary-depth lowering through all consumers is still pending under `ARRAY-COMPOSITION-DEPTH`; do not present this example as compiler-supported until its focused evidence exists.

### 7.4 Flat rectangular Arrays

**NORMATIVE.** Adjacent index suffixes are the C-like flat rectangular form:

```text
matrix[i][j]
cube[i][j][k]
```

The source declaration supplies the extents needed to lower row-major strides. The runtime base descriptor still stores only the total element count and backing. Rank and per-dimension lengths are not recovered from the descriptor.

For extents `[d0, d1, ..., dn-1]`, full coordinates lower conceptually to one flat index:

```text
(((i0 * d1 + i1) * d2 + i2) ... * dn-1 + in-1)
```

**L2:** indexing follows target C99 and performs no automatic bounds check.

**L3:** rectangular access validates the final linearized index against the descriptor's total length. It does not perform an independent bound check for every coordinate. Intermediate arithmetic must not wrap and thereby forge an in-range final index. Consequently `[0, 3]` in a `[2, 3]` rectangle denotes the same flat position as `[1, 0]`; final index `6` is out of bounds for total length `6`.

Do not add a dimensions table merely to perform per-coordinate checks. If an application needs shape as data, it must carry an explicit shape Structure under its own contract.

### 7.5 Indexing the currently selected value

**NORMATIVE.** A backslash followed by an unnamed index means “index the Array value selected so far”:

```text
a[i]\[j]\[k]
```

The first suffix indexes `a`. Each `\[j]` or `\[k]` indexes the value returned by the preceding step. This is the ordinary typed path mechanism and can mix fields and indices.

It is not the same as:

```text
a[i][j][k]
```

The adjacent form indexes one flat rectangular original Array using source strides. The backslash form follows independent descriptors one step at a time.

### 7.6 Nameless Array index versus named occurrence selector

The name after the bracket is decisive:

```text
a\[i]          # nameless step: index Array a
s\[N]name      # named step: select occurrence N of field name in Structure s
```

An unqualified Structure field name selects its last occurrence. `[0]name` selects the first, `[1]name` the second, and so on in lexical occurrence order. An occurrence number is not the physical field index among all fields.

Do not infer Array indexing merely because brackets occur. Do not infer an occurrence selector when no field name follows the brackets.

### 7.7 Arrays of references

An Array element may be a primitive or a reference to a nonprimitive value. An Array of references to Arrays is not a rectangular multidimensional Array. Selecting a reference element yields that reference; a later unnamed index follows the selected Array descriptor.

```text
rows[i]\[j]
```

Here `rows[i]` may be a reference to an independently allocated row Array. Its lifetime, element type, admission, and length remain those of that row.

Do not represent reference Arrays as untyped `void *` Arrays and reconstruct element contracts from C names. Pointer depth and the semantic element contract must survive checker, native transport, and walker transport.

### 7.8 Addressing Array data

In L2:

```text
@array[i]
```

denotes the actual typed backing element. It must not read the element into a temporary and address the temporary. `@array` addresses the cell holding the descriptor reference, not the descriptor, first element or implicit C array decay.

In L3, the equivalent reference operation remains portable only under the declared Array/reference contract; raw backing arithmetic remains L2.

### 7.9 `length`

**NORMATIVE.** `length` consumes the selected Array value and reads its descriptor's element count. It does not branch on the source spelling, number of path steps, element type name, or nesting depth.

Thus the same operation applies to a direct Array, an Array obtained through a field, and an Array selected by `a[i]\[j]`. An implementation must not introduce separate “one-dimensional,” “two-dimensional,” or “mainArgs” length paths.

### 7.10 Character Arrays and C strings

**NORMATIVE.** An LMX character Array stores exactly its declared character elements. Its `len` excludes a trailing NUL that is not part of the value.

For process argument `"ok"`, the LMX character Array length is `2`, not `3`.

A C string is a foreign representation requiring a NUL terminator. Conversion at the raw-C boundary may allocate, borrow, or otherwise provide a NUL-terminated buffer under an explicit lifetime contract. That conversion must not change the base LMX Array length or make all char Arrays C strings.

Plain `char` retains target C signedness. Character storage identity is still ordinary typed-cell identity: two mutable declared char fields initially holding the same character are distinct addressable cells. Immutable literal interning does not merge mutable declared storage.

### 7.11 Current implementation boundary

**SUPPORTED.** Released checkpoints described in `steps/native-selfbuild-20260930.md` cover whole-Array descriptor addressing and value projection, shared indexed expression spans, typed pointer/value transport, and several native/walker reference cases.

**PENDING.** The same notes explicitly retain semantic Array formal projection, some descriptor-reference following cases, arbitrary receiver composition in all consumers, general occurrence/use-edge projection, and some walker/copy combinations. An example that uses these is normative but must be marked unverified until its focused native and actual-walker evidence exists.

## 8. Paths, repeated names, and resolution

### 8.1 Path is semantic, not C punctuation

Ordinary LMX follows fields with `\`:

```text
value\field
value\[1]field
value\array\[i]\member
```

Ordinary LMX does not acquire `.` or `->`. L1/raw C may lower explicitly imported ABI access to C member syntax. A graph Structure remains a graph Structure even if its native representation contains pointers.

### 8.2 Repeated names

Declarations with the same name remain separate occurrences. Bare `name` selects the last occurrence. `[N]name` selects the explicit occurrence in lexical order.

This rule is used for paths and must also be preserved by structural admission where a Consumer explicitly uses an occurrence. It is not permission to validate every unused required occurrence or to collapse different uses into one name lookup.

**PENDING.** General Consumer used-edge projection preserving LAST versus explicit ORDINAL is tracked as an implementation dependency. Do not add a merge-only selector table, runtime name registry, or hard-coded maximum uses list.

### 8.3 Source order and capture

Declarations and operators remain in lexical order. A local value is visible forward and down. Nested scopes choose the nearest preceding eligible binding. A later declaration must not satisfy an earlier call merely because a whole-method scan discovered its name.

A captured value keeps the physical identity required by its category:

- primitives use a distinct captured cell when the language requires retained mutable storage;
- Structure/Array values transport their descriptor/reference, not a by-value clone;
- explicit reference variables preserve reference-cell depth;
- copying a graph preserves alias topology through the common copy map.

Do not repair capture by installing a persistent runtime name table. Compiler-owned source-site metadata may select an already declared binding; runtime execution then uses resolved references.

## 9. Raw C and foreign ABI

### 9.1 Explicit door only

**NORMATIVE.** `c.*` is the explicit raw C door. Examples include `c.sizeof`, `c.memcpy`, or a header-declared foreign function. The prefix is syntax-transparent: it does not create a language registry of permitted names.

Do not add:

- a whitelist of C function or member names;
- a header scanner that turns arbitrary C declarations into LMX semantics;
- name-specific exceptions such as treating `c.Lmx` differently solely because its spelling matches a kernel type;
- automatic graph semantics for a foreign C struct;
- fallback parsing of arbitrary C text as LMX.

The included header or explicit L1 ABI declaration defines the C object. The C compiler remains authoritative for target ABI constraints not represented in LMX.

### 9.2 Foreign aggregates

Header-unit `struct:`, `enum:`, `type:`, `foreign:`, and `fnptr:` describe actual C ABI. A by-value foreign aggregate is allowed only through that explicit ABI. It must not be confused with an ordinary nonprimitive LMX Structure, whose value is transported by descriptor/reference.

### 9.3 `sizeof`

Distinguish a type operand from a value operand.

```text
c.sizeof(c.LmxArena)  # raw C sizeof of an ABI type token
sizeof: int           # L2 sizeof receiver with a language type operand
sizeof: value         # L2 sizeof receiver with a resolved value operand
```

The `c.sizeof(...)` operand belongs wholly to the explicit raw-C door; LMX does not reinterpret selected raw tokens as language declarations or hidden inputs. Separately, the language `sizeof:` receiver distinguishes its type operand from its value operand. A language type operand is shape/type information, not a free value use; a language value operand follows ordinary source visibility. Do not add a name-specific parser or whitelist that makes raw C names participate in LMX lookup.

Do not assume all data pointers have the same size unless target C guarantees the compared types. Portable tests compare the same declared pointer type or query each target type directly.

## 10. Storage, lifetime, and activation

### 10.1 Typed arenas and stable cells

The L2 arena classifies half-open address ranges by physical kind/type and owner. A typed service pool grows by adding chunks; it does not `realloc` existing live cells. A live cell address therefore remains stable for the cell's lifetime.

Classification is representation support, not a second candidate-admission mechanism. A range proves the physical machine type of an address; structural `implements` plus Consumer tests prove admissibility.

### 10.2 Structure node versus child slots

The base node is conceptually:

```c
typedef struct Lmx {
    VoidArray array;
    struct Lmx *parent;
    LmxEntry native;
} Lmx;
```

`array` is first and holds the node's physical child references. `parent` is the immediate lexical/structural parent. `native` selects execution. A primitive's child-reference slot is not its primitive data cell. For a Structure/Array held by reference, the language value itself is that reference, and `@field` addresses its real reference-holding place, not the descriptor. Do not generalize the primitive distinction into a ban on addressing a reference cell. Neither case permits a cache, temporary or ABI carrier as the language place; exact storage types are part of the pointer-repair acceptance.

### 10.3 Activation state

Each call has activation-local formal values, hidden inputs, temporary results, catches, and working caches. These are not automatically graph fields. Their storage lasts for the activation and must outlive nested scratch marks that use them. Returning an address to an automatic activation cell does not extend its lifetime, exactly as returning the address of a C automatic object is invalid.

An own graph declaration has graph storage and identity. A machine-local declaration has activation storage. The compiler may optimize a working value, but optimization must preserve which physical cell `@` denotes and when publication occurs.

### 10.4 Re-entry

Re-entering a callable creates a new activation, not a fresh duplicate lexical Structure. The same declared own field is the same physical graph cell unless explicit construction/copy created a different graph. Working caches are activation-local. Dirty writes and publication follow the common rule at every depth; an outer clean cache must not overwrite an inner published write.

### 10.5 Control bodies and loops

An `if`, loop, catch body, or other nested body is a Structure in the complete graph. Reaching it enters the appropriate dynamic control region in the current callable activation; it does not create another procedure activation, a new language level, or a detached data graph. A callable invocation or re-entry, not an ordinary control body, creates a separate activation.

Declarations in a hosted/repeated body are reached according to control flow. Omitted reference initialization must set null on every reached declaration, including a later loop iteration after the prior iteration stored a non-null value. A declaration is not merely one-time C static initialization.

`break`, `continue`, return, throw, and stop must unwind the correct dynamic control region while retaining the graph and publication semantics specified for the operation.

## 11. Calls, native code, and the walker

### 11.1 One callable occurrence

An ordinary callable occurrence contains its graph body and a native implementation word. There is no parallel callable-occurrence/context graph, native-name dispatch table, or “compiled callable” language class. An implementation may use method descriptors and activation records as runtime metadata; those do not replace the callable occurrence or create another language object.

At call time:

- non-null `occurrence.native` selects the native implementation;
- null `occurrence.native` selects the interpreter for the retained L3 body;
- one call never runs both;
- absence of a native implementation is not a failure if the retained body is valid L3;
- the dispatcher does not select by source name, generated C symbol, method number, or original un-copied occurrence.

Graph copy carries the native word and relocates graph references through the common map. Replacing/clearing a copied occurrence's native word must affect dispatch of that copied occurrence, not the original.

### 11.2 Native and walked semantics must agree

Native and walked execution share:

- actual evaluation order and exactly-once rules;
- explicit and hidden input formation;
- conversion and admission;
- result category and typed storage;
- catches and thrown values;
- publication/checkpoint behavior;
- stop propagation;
- selected `self`/owner identity.

A generated C call to a fixed helper symbol is correct only when it is inside the selected native implementation's own internals. It is not a substitute for dispatching an ordinary source call through the selected occurrence.

### 11.3 Complete graph requirement

Native compilation does not authorize omitting the operator body. Every supported L3 body intended for interpretation must have its executable graph attached and reachable in the correct role/sequence. Merely emitting disconnected operator frames is insufficient.

Likewise, a walker test proves actual interpretation only when the selected callable has no native word and the root/caller reaches it through the graph. A “walk methods” flag or opcode count alone is not proof.

### 11.4 Current implementation status

**SUPPORTED.** The released uniform-dispatch work described in `steps/native-selfbuild-20260930.md` routes ordinary selectors through the selected occurrence's native word and includes native/walk/stop evidence.

**PENDING.** Canonical full-body/copy closure, Array formals, general callable-actual projection, selector/use-edge admission, and some unknown/nested-head cases remain explicit dependencies. Consult the current plan before labeling a new case supported.

## 12. Conversion and admission

### 12.1 Two mandatory stages

Candidate admission has two distinct stages:

1. analytical, directional structural `implements(candidate, requirement, Consumer)` over the paths and callable uses required by Consumer;
2. successful interpretation of all unit tests defined by that Consumer against the already constructed graph.

A matching machine type, address range, source name, signature fragment, or native callback does not replace either stage.

### 12.2 Conversion precedes structural admission

When a receiving context admits conversions, form the source value through the selected conversion, then perform structural admission on the resulting candidate, then store only on success. Failure leaves the destination value and dirty state unchanged.

Do not add defensive runtime validation after compiler metadata has already established an invariant merely to compensate for missing type propagation. Conversely, do not skip runtime admission where the L3 contract actually requires Consumer tests.

### 12.3 Actual layout provenance

A value viewed through model `A` may physically be a larger/reordered Structure `B`. Admission correspondence must preserve the actual physical layout selected for the value. It must not substitute the required model, the first merge operand, or a C name as the value's origin.

Compiler declaration identity may be represented by an opaque module-lifetime token in metadata. Such a token is not a new language value, graph node, global name registry, or base `Lmx` field. Unknown runtime provenance remains unproved; it must not be forged from the requirement.

## 13. Returns, throws, stop, and mail

### 13.1 Normal result and status are separate

A callable's ordinary result has its declared type/category and storage. A throwing callable additionally returns/propagates status and payload according to its exit contract. Do not store a pointer result in an integer status word or treat a nonzero result as a throw.

A procedure with no language result still has a call/status contract. Discarding a result is a receiving-context decision; it must not make the callee's actual result representation untyped.

### 13.2 Throw

Throw conversion, catch selection, payload transport, and post-call propagation must be the same for native and walked calls. A catch body is an ordinary retained control Structure. A caught failure must not publish a refused destination write.

### 13.3 Stop

Stop is not a normal result and not an arbitrary invalid status. It stops evaluation at the defined boundary:

- later actuals and the receiver are not evaluated after a stop from an earlier actual;
- a stopped callee does not manufacture a result;
- caller temporaries and publication unwind correctly;
- the public boundary reports the defined stopped outcome;
- clearing a native word and walking the same body preserves the behavior.

Do not model stop as a language exception if the current contract defines it separately.

### 13.4 Messages and mail

An executable Thread contains a by-value `LmxMsg` prefix plus Thread-only state. A standalone Message is not upgraded into a Thread by address coincidence. Mail, scheduling, and child membership do not become fields of every Message. The sole child List is allocated in the parent's arena and held directly by existing `Thread.children`; neither it nor a settings reference is appended as an implicit source field. Launch service data/settings stay in the already defined R0 parent stub and are passed explicitly. The source body's field count, order and nesting remain determined by the source.

`sendMessage` and `receiveMessage` remain high-level wrappers over one underlying mail mechanism. A failed turn publishes no outgoing letters. A taken letter is not available through a second API. Address/delivery services resolve and hand off; they do not inspect the recipient mailbox or invent a second queue.

When migrating mail code upward:

1. keep the physical Message/arena ownership transition in L2;
2. express letter shapes, candidate admission, selection, and wrapper calls in L3;
3. keep OS synchronization and atomic primitives below the high-level contract;
4. do not copy Java manager classes, IDs, or a parallel membership registry into the kernel.

## 14. Migration patterns

### 14.1 C pointer parameter to portable reference

C:

```c
void set_value(int *p) { *p = 7; }
```

L2/L3 contract:

```text
sub: setValue (@: int p)
    \p: 7
    return
```

Use L3 if the operation is only typed reference following. Use L2 if it performs numeric address manipulation or raw-memory operations.

### 14.2 C struct pointer to ordinary Structure formal

Do not translate:

```c
int read(A *a);
```

into an assumed by-value `A` C aggregate. For an ordinary LMX model:

```text
fn: read (A: a) int
return: a\value
```

`a` is descriptor/reference transport with admission to `A`. `@: A a` is synonymous in the signature only. The executable receiver `@: b A` selects reference assignment; `b: args` instead applies the selected Structure. Signature descriptions do not collapse unary address depth.

### 14.3 C heap vector to fixed Array

C:

```c
struct IntArray { size_t len; int *data; };
```

LMX base Array carries the same minimal facts. Allocation/ownership is expressed by the creator and arena. Do not add capacity unless the value is explicitly a dynamic container.

### 14.4 Pointer-of-pointer rows to Array of Array references

C's `T **rows` alone does not provide row lengths or ownership. In LMX each row is an independent Array descriptor, and the outer Array stores references under its element contract. For an outer Array whose selected rows are Arrays of `int`, use an already declared destination:

```text
int: cell 0
cell: rows[i]\[j]
```

The step after `\` indexes the Array value produced by `rows[i]`. An intermediate row name would require its own explicit typed binding under the ordinary receiver contract; an unknown `row: ...` would instead define a named Structure. Do not write adjacent `rows[i][j]` unless the declaration is the flat rectangular form with source strides. General Array-of-Array receiver composition remains subject to the **PENDING** boundary in §7.11.

### 14.5 C flexible builder to explicit merge

Replace implicit constructor/clone assumptions with explicit composition:

```text
result: merge Model Overrides
```

Then admit `result` where the receiving context requires it. Do not overload `Model: result Overrides` to mean construction when `Model` is already known.

### 14.6 C callback table to callable Structures

Represent callable occurrences as ordinary Structures with signatures, retained bodies, captures, and optional native words. Dispatch by the actual selected occurrence. Do not generate a name switch or use the original declaration's C symbol after the occurrence was copied or merged.

### 14.7 Raw library operation

Keep the raw call behind a small L2/native implementation with an L3 contract. The high-level receiver specifies inputs, ownership, result, failures, and tests. The native implementation uses explicit `c.*`/header ABI. The interpreter may run an alternative retained L3 body only when that body contains no L2/raw operation.

## 15. Two-generation port and self-build discipline

The target route is L3/L2 self-build without handwritten L1 source for migrated components. Generated L1 remains a valid intermediate stage. A one-time trusted C bootstrap may start the route, but the language-owned build must perform and test two successive self-replacements; two ordinary compilations without replacing the active tool are insufficient.

A credible port demonstrates at least two language-owned replacement generations:

1. bootstrap/current `G0` builds `G1` from the L2/L3 sources, using generated L1 and C99 as intermediates where required;
2. the language-owned procedure runs the required compiler/kernel/native-and-walker tests on `G1`, then replaces the active compiler with that tested `G1`;
3. active `G1` builds `G2` from the same sources;
4. the same language-owned procedure tests `G2`, then replaces the active compiler with tested `G2`; generated-artifact comparison may add evidence but is not an additional mandatory self-build condition;
5. native and actual-walker witnesses remain distinct and meaningful, and mutation controls show that required relationships are observed rather than inferred from text names.

Do not claim self-build merely because generated C compiles once, because two binaries were produced, or because artifacts compare without both replacement generations' mandatory tests. Do not require the intermediate generated L1 to disappear; the goal is to remove handwritten L1 as the source of migrated L2/L3 components, not to remove the lowering stage. The migrated route must not depend on handwritten L1 headers, build drivers, or helper tools as its maintained source; required such material is generated from the language-owned sources.

Platform dependencies must be explicit:

- target C compiler and ABI facts;
- OS headers and foreign declarations;
- atomic/thread/mail backend;
- process launcher and filesystem interfaces;
- generated include/link dependencies.

No language rule may depend on one workstation path, PowerShell behavior, a generated temporary name, or a host-specific primitive width.

## 16. Acceptance requirements for migrated code

For each migrated mechanism, record all three layers separately.

### 16.1 Normative acceptance

- Which receiving expression defines the contract?
- Which values, places, references, and identities are observable?
- Which lifetime owns every address?
- Which conversion and admission apply?
- What are the normal result, declared throws, stop behavior, and publication boundary?
- Is the body valid L3, or does it require L2/native lowering?

### 16.2 Native evidence

- The selected occurrence's native word is actually used.
- Arguments are evaluated once in source order.
- Hidden inputs and captures use the correct source occurrence.
- Typed results and throw/status storage are distinct.
- No per-call persistent arena cell is leaked for scalar temporaries.
- Addresses refer to the intended real data cells.

### 16.3 Walker evidence

- The tested callable's native word is empty.
- The executable body is attached and reachable, not an orphan frame.
- The root/caller actually reaches it.
- Results, admission, publication, throws, stop, and identity match native execution.
- A nonzero or otherwise unmistakable success oracle proves that the body ran.

### 16.4 Mutation evidence

Prefer mutations that change one semantic relationship:

- select the original callable instead of the copied occurrence;
- address a temporary or graph slot instead of the data cell;
- collapse present null into absence;
- evaluate an actual twice or out of order;
- detach the body while leaving an orphan operator frame;
- change Array element type, pointer depth, ordinal, or final bound;
- restore implicit `Model:fresh`;
- skip admission or publish after refusal;
- convert stop into normal completion;
- substitute the required schema or first merge operand for actual provenance.

A compiler crash, unrelated diagnostic, stale product file, or empty-success exit is not a qualifying detection.

## 17. Migration checklist

Before replacing an L1/C mechanism with L2/L3, answer every item.

### Syntax and resolution

- Is the head reserved, known callable, known non-callable, or unknown in definition position?
- Is the form a signature or an executable application?
- Are nested heads resolved by the same rule?
- Is any old behavior relying on implicit construction from a known Structure?

### Values and storage

- Is each operand a value, place, held reference, or reference cell?
- Does `@` address the actual typed data?
- Is null distinguished from absent?
- Are Structure/Array values transported by descriptor rather than C aggregate copy?
- Does the lifetime cover every retained address?

### Arrays

- Is this one flat rectangular Array or independent Arrays linked by references?
- Are adjacent `[][]` and backslash `\[i]` used intentionally?
- Does the descriptor contain only count and backing?
- Is `length` read from the selected descriptor?
- Is L2 unchecked and L3 checking only the final flat rectangular index?
- Are character lengths NUL-free unless explicitly converted to C string?

### Calls and execution

- Does the actual selected occurrence choose native versus walker?
- Is the complete body retained and attached?
- Are arguments, hidden inputs, captures, result, throws, and stop shared semantically?
- Does copying/merging preserve occurrence identity and actual layout provenance?

### Portability

- Are machine types taken from target C99 rather than guessed widths?
- Is raw C behind the explicit door with header-defined ABI?
- Is any name/type allowlist being introduced?
- Does the code require an undocumented header scanner or process-global registry?
- Can the port complete two compiler generations with generated L1 as intermediate?

## 18. Common forbidden shortcuts

Do not implement or document any of the following as language semantics:

- `A: b` as implicit clone/fresh construction when `A` is known;
- a special two-dimensional `[]: []:` parser or runtime Array kind;
- rank, shape, capacity, or hidden prefixes in the base Array descriptor;
- per-coordinate L3 bounds checks for flat rectangular syntax;
- a fixed maximum path depth, receiver depth, argument count, or construction chain;
- `@Structure` lowered as the descriptor itself instead of the real cell holding its reference;
- address-taking as automatic dirty/sticky publication;
- nonprimitive Structure transport as a C by-value aggregate;
- all pointer-shaped values treated as the same reference category;
- present typed null treated as an omitted argument;
- known-call failure falling back to declaration;
- native dispatch by generated C symbol or source name;
- detached “saved call,” duplicate code graph, or persistent execute(code, data) companion graph;
- runtime execution by diagnostic name-table lookup;
- C header scanning/name allowlists as the raw-C type system;
- a name-specific `Lmx`, `Array`, `List`, `mainArgs`, or root exception;
- a merge-only type registry, selector table, or first-operand schema substitute;
- rewriting historical fixtures to conceal a normative disagreement.

## 19. Reading implementation claims safely

Use the following order when evaluating whether an example can be relied upon today.

1. Read the normative rule in the specifications.
2. Check `steps/current.md` and the top/current sections of `steps/native-selfbuild-20260930.md`.
3. Check the corresponding open defect or plan item.
4. Identify the released source checkpoint, not only a mutable worktree hash.
5. Inspect a focused native witness and an actual-walker witness where interpretation is claimed.
6. Inspect meaningful mutations and the final corpus comparison.
7. Label remaining cases **PENDING**, without changing their normative meaning.

Historical blogs, old generated outputs, previous parser goldens, and closed tickets are provenance. They do not override a later accepted rule. In particular, older NUL-inclusive process-argument wording, implicit known-Model construction, first-occurrence defaults, and special two-Array lowering must not be resurrected from historical artifacts.

## 20. Compact reference table

| Topic | L1 | L2 | L3 |
| --- | --- | --- | --- |
| Ordinary Structure | no automatic graph semantics | graph value plus native implementation | graph value |
| `@` | C pointer declaration/address | portable reference plus machine address operations | portable reference only; no numeric address manipulation |
| primitive arithmetic | target C99 lowering | target C99 machine semantics | profile-defined portable operation |
| base Array | C array lowering where specified | typed descriptor and unchecked access | typed descriptor; checked high-level access |
| rectangular `[][]` | contiguous C storage | flat source-stride indexing, unchecked | final flat-index bound |
| `a[i]\[j]` | lowering detail only | follow selected Array descriptor | same portable path semantics |
| raw `c.*` | explicit C door | usable only in native/L2 body | absent from interpreted body |
| nonprimitive formal | explicit ABI if foreign | descriptor/reference transport | descriptor/reference transport |
| `merge` | kernel lowering | explicit graph composition | explicit graph composition |
| dispatch | emitted C mechanism | selected occurrence's `native` word | same; null word walks retained body |
| throw/stop/mail | kernel implementation | machine mechanism | high-level contract |

The central migration rule is simple: preserve the language value, identity, receiving context, and graph first; then choose the lowest machine mechanism needed to implement it. Never let a convenient C representation become a new LMX semantic category.
