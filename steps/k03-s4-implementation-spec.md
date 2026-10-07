# K03-UNIFIED-HEAD-S4 Implementation Specification

**Date:** 2026-10-06  
**Slice:** K03-UNIFIED-HEAD-S4-20261006-04  
**Parent:** K03-UNIFIED-HEAD-IMPLEMENT-20261006-01  
**Baseline:** c0e3fc5e (RESERVED-NAME-BINDINGS committed/pushed)  
**Owner:** Opus (sole writer/build)

## Purpose

S4 folds duplicate value/return/actual position dispatch logic using the existing unified head/argument model from S1. The goal is to eliminate separate dispatch paths for different contexts and apply a single resolver that determines role contextually.

## Key Concepts

### Existing S1 Model
- **l2_app_head:** Extracts the head text from an application (Frame or atom)
- **l2_app_actuals:** Extracts the arguments/body from an application
- **l2_head_resolve:** Resolves a head text to its semantic role (method, Structure, word, etc.)
- **Bare atom equivalence:** A bare receiver atom like `merge` is equivalent to an empty application `merge()` or `merge: ()`

### Current Duplication
1. **l2_check_primary** (value position) has separate branches for:
   - Atoms (own, formal, slot, local, etc.)
   - Method calls
   - Callable formals
   - Receiver words (merge, length, sizeof, etc.)

2. **l2_check_value_call** (callable in value position) dispatches to l2_check_call with empty body

3. **l2_check_call** (call position) handles similar dispatch but for call context with arguments

4. **l2_check_return_literal** (return position) and **l2_check_ret_convert** (return type conversion) have similar patterns

### S4 Unification Approach

For value positions, the unified flow would be:

```
l2_check_word_value(node, mi, context) 
  -> l2_app_head(node) -> get head text
  -> l2_head_resolve(mi, head) -> determine role
  -> apply contract based on (role, context)
     - value context: result of application consumed
     - return context: result must convert to return type
     - actual context: argument given to formal
```

## Duplication Fold Points

### Point 1: l2_check_primary for callable atoms (Lines 25702-25708)

**Current:**
```
idx: l2_param_find(mi, node\as\atom)
if: idx >= 0 && l2_head_is_callable_formal(...)
    return: l2_check_value_call(...)
if: idx >= 0
    return: 0
if: l2_head_is_method_call(...)
    return: l2_check_value_call(...)
```

**Issue:** Separate dispatch for callable formals vs. methods, both calling l2_check_value_call

**Unified:** Use l2_head_resolve to determine if callable, then apply value contract uniformly

### Point 2: l2_check_return_literal (Lines 4072+)

**Current:** Separate handling of return value checking in l2_check_return_literal

**Unified:** Apply same dispatcher as l2_check_primary but with return context

### Point 3: l2_check_call merge handling (Lines 26093+, 26258+)

**Current:** Separate merge handling in call position

**Unified:** Use l2_app_head/l2_head_resolve to determine merge, apply call contract

## Implementation Plan

### Step 1: Receiving-Prefix Witness (DONE)
- Created `unit_recv_prefix_merge_model.lm2` showing explicit forms
- Added to harness with native + walked versions
- Documents bare vs. explicit application distinction

### Step 2: Create Common l2_check_word_value Dispatcher

New function analogue to l2_check_word_stmt for value contexts:

```c
fn: l2_check_word_value (
    int: mi,
    @: LmP0Text head,
    int: context,  // 1=value, 2=return, 3=actual
    int: arg_count,
    int: formal_idx  // for actual context
) int
  // Resolve head once
  int: role l2_head_resolve(mi, head, @ idx, @ outside)
  // Apply contract based on (role, context)
  // Return result
```

### Step 3: Fold l2_check_primary

Modify l2_check_primary to use l2_check_word_value for atoms:

```
if: node\kind = c.LM_P0_NODE_ATOM
    head: node\as\atom
    if: l2_head_word(head) != 0
        return: l2_check_word_value(mi, head, VALUE_CONTEXT, 0, -1)
    // ... existing non-word atom handling (numbers, literals, etc.)
```

### Step 4: Fold l2_check_call merge handling

Use l2_app_head/l2_app_actuals instead of special merge branches

### Step 5: Apply to return position

Extend dispatcher to return context with type conversion logic

### Step 6: Fold l2_check_fields

Use unified dispatcher for field value checking

## Contracts to Preserve

1. **Q52 Hidden Inputs:** Outer flag in l2_head_resolve result
   - Preserve `outside` flag from resolver
   - Keep Q52 inputs out of normal actual/formal bindings

2. **Descriptor-Only Signatures:** Allow bodiless methods as contracts
   - No changes to signature admission logic
   - Result type still checked

3. **Callable Formal Contract:** Forwarding in arguments
   - When formal is callable, actual is the occurrence, not a call result
   - Binding logic unchanged

4. **Empty Application Equivalence:** Bare H = H() = H: ()
   - All three spellings produce same result
   - No special bare-atom constructor

## Witness/Control Requirements

### Receiving-Prefix Witness (unit_recv_prefix_merge_model)
- Native: Explicit forms work (x: merge: Model, x: merge(Model))
- Walked: Same contract applied
- Collector-reintroduction mutant: Must fail (proves S3 removal was essential)

### Positive Controls
- Noncallable value read/discard
- Callable in value position (method call result)
- Callable formal in value position (occurrence)
- Return value with type conversion
- Actual argument to formal

### Negative Controls
- Missing argument refusal
- Return type incompatibility
- Receiver word with wrong arguments
- Callable without result in value position

## Gate Strategy

1. **Focused:** unit_recv_prefix_merge_model + related merge witnesses
2. **Mutants:** Collector-reintroduction (remove S3 atom-branch cleanup)
3. **Full:** All tests in opus_full_* baseline
4. **Kernel:** Self-build with harness GREEN
5. **L3:** Selftest suites GREEN

## Expected Outcomes

After S4:
- No duplicate dispatch logic for value/return/actual
- l2_head_resolve applied uniformly across contexts
- Bare receiver atoms treated as empty applications
- All existing contracts preserved
- Witnesses prove unified head resolution is semantic requirement

## Open Questions

- Exact form of l2_check_word_value signature
- Where to place unified dispatcher function
- Mapping between old dispatch branches and unified path
- Whether S4 can be done as pure refactoring or requires semantic changes

## Related Slices

- **S1 (Frozen):** l2_app_head, l2_app_actuals, l2_head_resolve model
- **S2+S3 (Frozen):** l2_check_word_stmt for statement dispatch
- **S4 (This):** Extend to value/return/actual dispatch
- **S5:** Definition bodies, unknown heads, dormant construction
- **S6:** Dead slot branch removal, duplicated resolution cleanup
- **S7:** Leading-atom merge operand parsing, sole-container transparency

## References

- Steps/k03-head-census.tsv: Dispatch point inventory
- Fable-continuation-20261003.md: S1-S3 detailed journal
- Current.md: Unified head rule description
- LMX_semantics.en.md: Language specification
