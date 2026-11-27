#!/usr/bin/env python3
"""Generate required semantic observations, never simulated LMX successes."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[1]
MODES=('interpreter_interpreter','interpreter_native','native_interpreter','native_native')

def main():
    cases=[]
    def add(group, scenario, expected):
        cases.append({'id':group+str(1+sum(c['id'].startswith(group) for c in cases)).zfill(3),
            'scenario':scenario,'expected':expected,'modes':{m:'NOT_RUN' for m in MODES}})
    for kind in ['[]int','[]long','[]float','[]double','[]char','[]@ references','Structure mixed fields','Structure []@ holding Array references','empty dense Array','empty Structure','one element']:
        add('EQ', 'unique on '+kind, 'Stable first occurrences, fresh outer result with promised storage profile; input, typed element records and reference targets preserved')
    for scenario, expected in [
        ('same scalar/same Array/mixed Array versus scalar','Use ordinary scalar equality, recursive sequence equality, and false for the Array/scalar split'),
        ('explicit equivalence comparator','Comparator controls duplicates through the same stable scan; no second unique algorithm'),
        ('ordinary numeric equality across admitted numeric types','Use the existing equality result, with no extra type-code identity restriction'),
        ('NaN, signed zero and user references','Preserve existing ordinary equality semantics; no invented total equality or pointer policy'),
        ('referenced mixed Structures','Compare recursively with shared equalFields and keep surviving actual records; Structure is []@, not a separate nested-array storage kind'),
        ('uninitialised scalar element','Use the ordinary uninitialised-read contract; no fabricated ready value'),
        ('non-Array source','Ordinary Array admission rejects before traversal'),
        ('invalid/throwing comparator','Predicate/result admission and original declared failures remain visible'),
        ('source mutation during equality','Forbidden by the equivalence/stable-input contract, not silently supported'),
        ('memoize / membership / key / mismatch / search / grouping','All default equality users reach FxValueSame/FxSequenceDifference; explicit comparison remains optional')]:add('EQ',scenario,expected)
    for kind in ['int','long','float','double','char','[]char','dense Array','Structure','reference','callable','ready null reference','empty Array']:
        add('MON','some/ok/err/done capture '+kind,'Capture one whole admitted record before default @ admission; preserve actual type, referenced target and exact container result')
    for scenario,expected in [
        ('err with formal reason','The shared constructor adapter calls its sole input positionally, so reason is supplied correctly'),
        ('none / err bind chain','No skipped callback is run or read; preserve original inactive container'),
        ('Maybe, Result and Array under canonical bind','Select declared semantic family before input admission; never choose by fields or overload definition order'),
        ('half chain ordinary and operand forms','Identical left-to-right calls, values, effects and exact @FxMaybe result'),
        ('Array bind empty/multiple outputs/type-changing outputs','One FxSeqBind traversal with flattening in order and exact []@ result'),
        ('Array bind callback returns non-Array','Reject by ordinary Array admission; do not wrap singleton silently'),
        ('bind empty right chain','Reject FxArity rather than return fabricated unit'),
        ('constructor uninit/type-only/void','Do not read uninit payload or invent a value for void; TYPE and VALUE routes remain separate'),
        ('constructor dynamic binding and mutable references','Ordinary parent/binding/lifetime behavior, one capture, no hidden environment'),
        ('bind callback declared failure','Finite target failures propagate with original name and typed payload')]:add('MON',scenario,expected)
    for kind in ['[]int','[]double','[]char','mixed Structure','Structure []@ holding Array references','empty typed Array']:
        add('PAT','ArrayView of '+kind,'One Pattern engine over actual units; literal/element/class/choice/repetition/capture preserve unit and slice profile')
    for scenario,expected in [
        ('utf8Text versus byteText','Keep explicit scalar/octet decoding, encoding checks and exact text slices'),
        ('literal multi-element Array versus element(Array value)','Literal matches a sequence; element matches one complete referenced Array value under ordinary reference rules'),
        ('within custom ordered type','Use selected order and type-preserving bound adapter; no char-only assumption'),
        ('satisfy and boundaryOf empty source','Validate real unary predicate signature before reading units; no fake integer probe'),
        ('then call and operand with text/Array sources','Same generic normalized Pattern composition and source domain'),
        ('sameAs capture','Shared range equality; full source position and capture context preserved'),
        ('matchedValue/captureValue/captureValues','Return values through actual source domain slice, with dense/mixed/text profiles retained'),
        ('replacement literal versus callable','Role selected before matching; callback receives Match and returns whole actual record; validate against source domain'),
        ('zero-width match repeated/split/replace','Progress policy prevents loops and retains one ordinary algorithm'),
        ('ASCII/line/boundary text profiles applied to Array','Admit explicit declared profile or reject; never guess text from fields or element values')]:add('PAT',scenario,expected)
    for scenario,expected in [
        ('-> inputs then final result token','Both forms construct identical full input/result requirements; void and nullary contracts preserved'),
        ('type(value) including uninitialised record','Observe the record type without reading payload'),
        ('pipe empty/type-changing/callable result','Empty R=T; exact final R, no fixed-@ public result, no invocation of a returned callable'),
        ('pipe invalid stage signature','Builder rejects non-unary or no-result stages before publishing; actual value admission occurs at reached call'),
        ('retry predicate/delay/limit','Original result type preserved; no policy on final attempt; delay only between retries; original errors stay errors'),
        ('join separator profiles','Generic explicit separator and text default share FxStdJoin; no separate text copying loop'),
        ('cycle negative policy','Default finite generic cycle and explicit rejectNegative retain separate requested policies through one loop'),
        ('trim/pad/translate/remove on nontext Array','Explicit members/predicate/fill/order are used; text defaults apply only to actual text profile'),
        ('range custom type','Explicit domain validates finite progress, step direction, actual output storage and endpoint rules'),
        ('format/parse selected codec','Codec selection determines exact types/errors; exact integer profile remains available'),
        ('quoted exact names and unary places','Canonical name only; ++var/var++/--var/var-- preserve before/after result and one assignable place'),
        ('RAW/FORM/PLACE/TYPE/void/control forms','Translator routes original role, owner, lifetime, effects and result; no eager VALUE adapter for non-VALUE forms')]:add('GEN',scenario,expected)
    for scenario, expected in [
        ('three service inputs and original user arity', 'left/depth/right; optional depth belongs to this wrapper occurrence, not the ordinary source logical arguments'),
        ('absent depth and an outer dynamic depth field', 'Absence keeps the ordinary method contract and does not read slot 1 or autofill from a same-named outer field'),
        ('explicit depth zero', 'Supplied slot 1 is read once; zero selects maximum logical-axis traversal, never whole-argument invocation'),
        ('op and .(expression)op', 'Only absent or explicit modifier; .op/repeated dots are removed; .( is never a decimal point'),
        ('effectful or skipped depth expression', 'Demand once in its original context; no evaluation during grouping or a skipped RAW branch'),
        ('non-int transport or negative standard Map depth', 'Non-int violates the shared int formal; negative is rejected by standard Map, not by generic transport; no truncation, synthetic exception or extra throws'),
        ('custom depth meaning', 'Direct custom method receives the int actual, including a negative integer if its own contract permits; no automatic PD01/Map, zero reinterpretation or Array-rank check'),
        ('flat shape (2 2), ordinary arithmetic and explicit depth', {'inputs': {'A': {'shape': [2, 2], 'values': [1, 2, 3, 4]}, 'B': {'shape': [2, 2], 'values': [5, 6, 7, 8]}}, 'plain_and_depth_0_or_2_times': {'shape': [2, 2], 'values': [5, 12, 21, 32]}, 'depth1_times': 'Pass row cells to base; scalar-only numeric * rejects them unless a compatible row base contract is declared; never implicitly remap', 'plain_matmul': {'shape': [2, 2], 'values': [19, 22, 43, 50]}, 'depth1_matmul': {'shape': [2], 'values': [17, 53]}, 'storage': 'Flat backing with logical axes; no row-storage hierarchy'}),
        ('positive depth above Array rank', 'Reject before a base call or destination write; scalar/held actuals do not add axes'),
        ('no second automatic Map', 'After outer traversal call the selected base directly; unsupported cells diagnose, while explicit nested operations retain their ordinary contracts'),
        ('frame matching and held values', 'Iterated frames match exactly; original scalars and held actuals add none; a one-element Array is not a scalar'),
        ('Structure []@ and actual references', 'Typed-record slots supply actual values; real references remain references; no []@ exclusion or blind pointer traversal'),
        ('exact result at runtime-selected depth', 'PD01 derives full R and frame+resultCellShape without probing source code; heterogeneous outputs may use ordinary Structure assembly'),
        ('empty frame and void source', 'No callback or sample call for empty frame, no Array<void>; frame () has one application'),
        ('whole TYPE/RAW/PLACE/Maybe/Pattern profile', 'Absent modifier retains consuming roles; an explicit depth requires a compatible profile. Explicit zero does not denote whole'),
        ('prefix absence and empty right', 'Missing left differs from a present value and present empty right; equivalence belongs to the selected method'),
        ('native result ABI', 'Require dependent result admission and the matching ABI; no hidden compilation or universal boxing')]:add('DEPTH', scenario, expected)
    for scenario, expected in [
        ('missing versus empty axisRules', 'Missing chooses whole/automatic profile; present empty structure selects independent outer axes'),
        ('binary product versus min-plus', 'Same indexed term loop, independent kernel/reducer: */+ versus +/min; no inference of min or max from +'),
        ('unary sums, products and diagonal', '[+ axis:] and [+ i:j] sum; [* axis:] and [* i:j] multiply; geometry forms do not reduce'),
        ('whole and indexed division', '[/] solves X B=A; explicit [/ rules] applies the declared pairwise division plan, not solve'),
        ('empty reduction with S different from R', 'Identity/seed/factory starts still pass through finish S->R; first requires admission/mapToState Z->S'),
        ('short circuit before next term', 'An explicitly allowed stop state is checked before the next term/kernel invocation; skipped callbacks and errors remain skipped'),
        ('empty output frame versus empty reduced domain', 'Zero free axis gives no outputs/callbacks; an existing output with zero reduced terms needs its declared empty contract'),
        ('ordinary profile copy and context', 'copy/merge combine real fields and method references, preserving ordinary parent/dynamic scope; no string registry or per-symbol loop')]:add('INDEX', scenario, expected)
    for scenario, expected in [
        ('elementwise := rotation', 'Capture all RHS values and complete admissions before writes; preserve real places and snapshot result'),
        ('slice .: broadcasting', 'Right-align RHS axes to the fixed slice shape, allow explicit singleton-axis repetition and original scalar expansion; do not reevaluate RHS'),
        ('minimal fuse result then assignment', 'Scalar/Map fresh result with no intermediate Array; external := or .: then keeps ordinary snapshot assignment'),
        ('unsupported fuse reduction/contraction/store', 'Diagnostic unless a separate capability is implemented; no hidden materialization, implicit streaming store or partial-write behavior')]:add('TENSOR', scenario, expected)
    catalog=json.loads((ROOT/'catalog.json').read_text())
    for row in catalog:
        for variant in row['variants']:
            add('FORM',row['name']+' / '+variant['family']+' ordinary versus operand',
                {'call':variant['call'],'operand':variant['operand'],'roles':variant['roles'],
                 'contract':variant['implementation_contract'],
                 'observation':'Same existing body/owner and actual result, evaluation order, accepted argument mapping, finite effects and short-circuit behavior'})
    result={'scope':'Required semantic acceptance after implementation of the documented publication hooks; no LMX runtime has been executed',
        'runtime_executed':False,'source_fixture':'generic_operations.lmx',
        'specifications':['../../../GENERIC_EQUALITY.md','../../../MONADIC_OPERATIONS.md','../../../GENERIC_OPERATIONS.md','../../../OPERATION_FORMS.md','../../../OPERATOR_DEPTH.en.md','../PUBLICATION_CONTRACT.md'],
        'canonical_operations':len(catalog),'canonical_variants':sum(len(x['variants']) for x in catalog),'cases':cases}
    (ROOT/'tests/generic_operations_acceptance.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'prepared_cases':len(cases),'canonical_variants':result['canonical_variants'],'runtime_executed':False}))

if __name__=='__main__':main()
